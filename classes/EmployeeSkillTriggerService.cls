public with sharing class EmployeeSkillTriggerService {

	public static void checkAvailabilityTimeEmployees(List<EmployeeSkill__c> skills) {
		//Get ids Employees 
		List<String> ids = EmployeeSkillTriggerService.getIdsEmployee(skills);
		//Get WrappEmployee with Properties
		List<WrappEmployee> wrapEmployees = EmployeeSkillTriggerService.getListWrappEmployees(ids);
		//Check the time
		EmployeeSkillTriggerService.timeCheck(wrapEmployees, skills);

		//Sum Project Fields
		EmployeeSkillTriggerService.sumFieldsProject(skills);
	}

	public static void recalculateFieldsProject(List<EmployeeSkill__c> skills) {
		
		EmployeeSkillTriggerService.sumFieldsProject(skills);

	}

	private static void sumFieldsProject(List<EmployeeSkill__c> skills) {
		try {
			List<String> projectIds = EmployeeSkillTriggerService.getProjectIds(skills);
			List<Project__c> projects = EmployeeSkillTriggerService.getProjects(projectIds);
			
			for (Project__c project : projects) {
				Integer dev = 0;
				Integer qa = 0;
				Set<Id> checkEmpId = new Set<Id>();
				for (EmployeeSkill__c skill : project.EmployeeSkills__r) {
					if (checkEmpId.add(skill.Employee__c)) {
						if (skill.Employee__r.isActive__c &&
							(skill.Employee__r.End_Date__c == null || skill.Employee__r.End_Date__c > System.today())) {
							System.debug(skill.Employee__r.IT_Department__c);
							if (skill.Employee__r.IT_Department__c == 'DEV') {
								dev++;
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

		} catch (DMLException e) {
            System.debug('DMLException caught: ' + e.getMessage());
        } catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }
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
					(SELECT Name, Employee__c, Employee__r.isActive__c, 
					Employee__r.IT_Department__c, Employee__r.End_Date__c   
					FROM EmployeeSkills__r) 
				FROM Project__c WHERE Id IN :ids
			];
		} catch (QueryException e) {
		System.debug('QueryException caught: ' + e.getMessage());
		}	
		return projects;
	}

	private static List<String> getIdsEmployee(List<EmployeeSkill__c> skills) {
		List<String> ids = new List<String>();
		if (!skills.isEmpty()) {
			for (EmployeeSkill__c skill : skills) {
				ids.add(skill.Employee__c);
			}
		} else {
			System.debug('Error - Trriger is empty!');
		}
		return ids;
	}

	private static List<WrappEmployee> getListWrappEmployees(List<String> ids) {
		List<WrappEmployee> wrapEmployees = new List<WrappEmployee>();
		try {
			List<AggregateResult> listEmplSkills = 
				[SELECT Employee__c, max(Employee__r.Availability__c) Availability, 
				SUM(Assigned_Time__c)TotalHours FROM EmployeeSkill__c 
				WHERE Employee__c IN :ids GROUP BY Employee__c];

			for (AggregateResult eSkill : listEmplSkills ) {
				WrappEmployee wEmp = new WrappEmployee();
				Integer tH = Integer.valueOf((Decimal)eSkill.get('TotalHours'));
				Integer avabil = Integer.valueOf((Decimal)eSkill.get('Availability'));
				wEmp.id = (String)eSkill.get('Employee__c');
				wEmp.totalHours = tH;
				wEmp.availability = avabil;
				wrapEmployees.add(wEmp);
			}
			
		} catch (QueryException e) {
            System.debug('QueryException caught: ' + e.getMessage());
        } catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }
		return wrapEmployees;
	}

	private static void timeCheck(List<WrappEmployee> wrapEmpls, List<EmployeeSkill__c> skills ){
		if (!wrapEmpls.isEmpty()) {

			for (WrappEmployee wEmp : wrapEmpls) {
				if (wEmp.totalHours > wEmp.availability) {
					for (EmployeeSkill__c skill : skills) {
						if (wEmp.id == skill.Employee__c) {
							skill.addError('The employee\'s time threshold is too high!');
						}
					}
				}
			}

		} else {
			System.debug('Error - time check');
		}
	}

	public class WrappEmployee {
	
		public String id {get; set;}
		public Integer totalHours {get; set;}
		public Integer availability {get; set;}
		
	}
}