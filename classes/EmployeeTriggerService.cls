public with sharing class EmployeeTriggerService {

	public static void checkDuplicateEmployees(List<Employee__c> employees) {
		List<String> firstName = new List<String>();
		List<String> lastName = new List<String>();
		List<Date> birthday = new List<Date>();

		for (Employee__c employee : employees) {
			firstName.add(employee.First_Name__c);
			lastName.add(employee.Last_Name__c);
			birthday.add(employee.Birthday__c);
		}

		List<Employee__c> employeesList = [SELECT Id, First_Name__c, Last_Name__c, Birthday__c FROM Employee__c 
			WHERE First_Name__c IN :firstName AND Last_Name__c IN :lastName AND Birthday__c IN :birthday];

		if(!employeesList.isEmpty()) {
			for (Employee__c emDublic : employeesList) {
				for (Employee__c employee : employees) {
					if (emDublic.First_Name__c == employee.First_Name__c && 
						emDublic.Last_Name__c == employee.Last_Name__c &&
						emDublic.Birthday__c == employee.Birthday__c &&
						emDublic.Id != employee.Id) {
							employee.addError('Employee with such data already exists!');
					}
				}
			}
		}
	}

	/**
	* Instead of Process Builder
	*/
	public static void checkPartTime(List<Employee__c> employees) {
		for (Employee__c empl : employees) {
			if (!empl.Part_Time__c && empl.Availability__c != 8) {
				empl.Availability__c = 8;
			}
		}
	}

	/**
	* Filtring data before sum fields project
	*/
	public static void checkDataBeforeProjectCount(List<Employee__c> employees, Map<Id,SObject> mapData) {
		Map<Id,Employee__c> myMapData = (Map<Id,Employee__c>)mapData;
		List<Employee__c> needUpdateEmployees = EmployeeTriggerService.getFiltringData(employees, myMapData);
		if (!needUpdateEmployees.isEmpty()) {
			EmployeeTriggerService.sumFieldsProject(needUpdateEmployees);
		} else {
			System.debug('Update without sum fields method');
		}
	}

	/**
	* Filtring Data for update and delete 
	 */
	private static List<Employee__c> getFiltringData(List<Employee__c> employees, Map<Id,Employee__c> oldMapData) {
		List<Employee__c> needUpdateEmployees = new List<Employee__c>();
		if (!employees.isEmpty()) {
			for (Employee__c empl : employees) {

				Employee__c oldEmpl =oldMapData.get(empl.Id);
				if ((empl.isActive__c != oldEmpl.isActive__c 
				|| empl.IT_Department__c != oldEmpl.IT_Department__c || empl.End_Date__c != oldEmpl.End_Date__c)) {
					//&&	(empl.End_Date__c == null || empl.End_Date__c > System.today())
					needUpdateEmployees.add(empl);
					// System.debug('dddd');
				}
			}
		} else {
			for (Id key : oldMapData.keySet()) {
				if ((oldMapData.get(key).isActive__c == true) && 
				(oldMapData.get(key).IT_Department__c == 'DEV' || oldMapData.get(key).IT_Department__c == 'QA')) {
					needUpdateEmployees.add(oldMapData.get(key));
				}
			}
		}
		return needUpdateEmployees;
	}

	public static void recalculateFieldsProject(Map<Id,SObject> mapData) {
		Map<Id,Employee__c> oldMapData = (Map<Id,Employee__c>)mapData;
		List<Employee__c> needUpdateEmployees = EmployeeTriggerService.getFiltringData(new List<Employee__c>(), oldMapData);
		if (!needUpdateEmployees.isEmpty()) {
			EmployeeTriggerService.minusFieldsProject(needUpdateEmployees);
		} else {
			System.debug('Delete without recalculate fields method');
		}

	}


	private static void minusFieldsProject(List<Employee__c> employees) {
		try {
			List<EmployeeSkill__c> skills = EmployeeTriggerService.getSkills(employees);
			if (!skills.isEmpty()) {
				List<String> projectIds = EmployeeTriggerService.getProjectIds(skills);
				List<Project__c> projects = EmployeeTriggerService.getProjects(projectIds);
				for (Project__c project : projects) {
					Set<Id> checkEmpId = new Set<Id>();
					for (EmployeeSkill__c skill : project.EmployeeSkills__r) {
						if (checkEmpId.add(skill.Employee__c)) {
							for (Employee__c empl : employees) {
								if (skill.Employee__c == empl.Id) {
									if (skill.Employee__r.isActive__c &&
										(skill.Employee__r.End_Date__c == null || skill.Employee__r.End_Date__c > System.today())) {
										if (skill.Employee__r.IT_Department__c == 'DEV') {
											project.Developers__c = project.Developers__c - 1;
										} else if (skill.Employee__r.IT_Department__c == 'QA') {
											project.QA_s__c = project.QA_s__c - 1;
										}
									}
								}
							}
						}
					}
				}
				update projects;
			} else {
				System.debug('Skills not found');
			}
		} catch (DMLException e) {
            System.debug('DMLException caught: ' + e.getMessage());
        } catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }
	}

	private static void sumFieldsProject(List<Employee__c> employees) {
		try {
			List<EmployeeSkill__c> skills = EmployeeTriggerService.getSkills(employees);
			if (!skills.isEmpty()) {
				List<String> projectIds = EmployeeTriggerService.getProjectIds(skills);
				List<Project__c> projects = EmployeeTriggerService.getProjects(projectIds);
				
				for (Project__c project : projects) {
					Integer dev = 0;
					Integer qa = 0;
					Set<Id> checkEmpId = new Set<Id>();
					for (EmployeeSkill__c skill : project.EmployeeSkills__r) {
						if (checkEmpId.add(skill.Employee__c)) {
							if (skill.Employee__r.isActive__c &&
								(skill.Employee__r.End_Date__c == null || skill.Employee__r.End_Date__c > System.today())) {
								if (skill.Employee__r.IT_Department__c == 'DEV') {
									dev++;
									System.debug(dev);
								} else if (skill.Employee__r.IT_Department__c == 'QA') {
									qa++;
								}
							}
						} 
					}

					project.Developers__c = dev;
					project.QA_s__c = qa;
				}
				update projects;
			} else {
				System.debug('Skills not found');
			}
		} catch (DMLException e) {
            System.debug('DMLException caught: ' + e.getMessage());
        } catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }
	}

	private static List<EmployeeSkill__c> getSkills(List<Employee__c> employees) {
		List<EmployeeSkill__c> skills = new List<EmployeeSkill__c>();
		try {
			skills = [
				SELECT Project__c, Employee__c FROM EmployeeSkill__c WHERE Employee__c IN :employees
				]; 
		} catch (QueryException e) {
            System.debug('QueryException caught: ' + e.getMessage());
        }
		return skills;
	}

	private static List<String> getProjectIds(List<EmployeeSkill__c> skills) {
		List<String> projectIds = new List<String>();
		for (EmployeeSkill__c skill : skills) {
			projectIds.add(skill.Project__c);
		}
		return projectIds;
	}

	private static List<Project__c> getProjects(List<String> ids) {
		List<Project__c> projects = new List<Project__c>();
		try {
			projects =[
				SELECT Id, Developers__c, QA_s__c,
					(SELECT Employee__c, Employee__r.isActive__c, Employee__r.IT_Department__c, Employee__r.End_Date__c 
					FROM EmployeeSkills__r) 
				FROM Project__c WHERE Id IN :ids
			];
		} catch (QueryException e) {
		System.debug('QueryException caught: ' + e.getMessage());
		}	
		return projects;
	}


}