public with sharing class L_EmployeeController {

	@TestVisible private static Integer forTest = 0;

	@AuraEnabled
	public static List<String> getPicklistValues(String objName, String fieldName) {
		List<String> picklistValue= new List<String>();
		//Get Object
		Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();
		try {
			
			Schema.DescribeSObjectResult objectDesc = allObjects.get(objName).getDescribe();
			Map<String, Schema.SObjectField> fieldsMap = objectDesc.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
			
			List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pickEntry : picklistEntry) {
				picklistValue.add(pickEntry.getValue());
			}

		} catch(NullPointerException e) {
			System.debug('NullPointerException caught msg: ' + e.getMessage() + 'Line ' + e.getLineNumber());
			// if(Test.isRunningTest()) {
			// 	L_EmployeeController.forTest = 1;
			// }
		} catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }
		return picklistValue;
	}

	@AuraEnabled
	public static List<WrappEmployee> getFilteredEmployees(String name, String department, String level) {
		List<Employee__c> employees = new List<Employee__c>();
		try {
			String strQuery = 'SELECT Id, First_Name__c, Last_Name__c, Level__c, ' +  
				+'Availability__c, IT_Department__c, End_Date__c, isActive__c FROM Employee__c';
			if (name != '' || department != '' || level != '' ){
				if (name != '') {
					String strWhere = ' WHERE ';
					String findName = '(First_Name__c LIKE \'%'+ name +'%\'  OR Last_Name__c LIKE \'%'+ name +'%\')';
					//Add to query
					strQuery += strWhere + findName;
				} 
				if (department != '' || level != '') {
					String strAndOrWhere = (name != '')? ' AND ' : ' WHERE ';  
					//Add to query
					strQuery += strAndOrWhere;
					if (department != '' && level != '') {
						String strDepartAndLevel = '(IT_Department__c = \''+ department
							+'\' AND Level__c = \''+ level +'\')';
						//Add to query
						strQuery += strDepartAndLevel;
					} else {
						if (department != '') {
							String strDepart = '(IT_Department__c = \''+ department + '\')';
							//Add to query
							strQuery += strDepart;
						} else {
							String strLevel = '(Level__c = \''+ level +'\')';
							//Add to query
							strQuery += strLevel;
						}
					}
				}
			}
			String strLimit = ' LIMIT 30';
			strQuery += strLimit;
			List<SObject> sobjList = Database.query(strQuery);
			employees = (List<Employee__c>)sobjList;
		} catch(NullPointerException e) {
			System.debug('NullPointerException caught: ' + e.getMessage());
		} catch (QueryException e) {
			System.debug('QueryException caught: ' + e.getMessage());
		} catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage());
        }

		Map<Id, WrappEmployee> wEmployees = L_EmployeeController.getWrappEmployees(employees);
		List<WrappEmployee> wEmployeesAndHours =  L_EmployeeController.getTotalAndFreeHours(wEmployees);
		return wEmployeesAndHours;
	}
	
	private static Map<Id, WrappEmployee> getWrappEmployees(List<Employee__c> listEmpls) {
		Map<Id, WrappEmployee> wEmployees = new Map<Id, WrappEmployee>();
		//Filtering Employees
		for (Employee__c empl : listEmpls) {
			if (empl.isActive__c && (empl.End_Date__c == null || empl.End_Date__c < System.today())) {
				WrappEmployee wEmpl = new WrappEmployee();
				wEmpl.id = empl.Id;
				wEmpl.firstName = empl.First_Name__c;
				wEmpl.lastName = empl.Last_Name__c;
				wEmpl.level = empl.Level__c;
				wEmpl.department = empl.IT_Department__c;
				wEmpl.availability = (Integer)empl.Availability__c;
				wEmpl.isActive = empl.isActive__c;
				wEmployees.put(wEmpl.id, wEmpl);
			}
		}
		return wEmployees;
	}
	
	private static List<WrappEmployee> getTotalAndFreeHours(Map<Id, WrappEmployee> mapWrappEmployees){
		List<WrappEmployee> listWEmpls = new List<WrappEmployee>();
		List<AggregateResult> skills = [
			SELECT Employee__c, SUM(Assigned_Time__c) TotalHours 
			FROM EmployeeSkill__c WHERE Employee__c IN :mapWrappEmployees.keySet() GROUP BY Employee__c
		];
		for (AggregateResult skill : skills) {
			
			Id id = (Id)skill.get('Employee__c');
			if (mapWrappEmployees.containsKey(id)) {
				Integer tH = Integer.valueOf(skill.get('TotalHours'));
				Integer avail = mapWrappEmployees.get(id).availability;
				Integer fH = avail - tH;
				mapWrappEmployees.get(id).totalHours = tH;
				mapWrappEmployees.get(id).freeHours = fH;
			}
		}
		for (Id id : mapWrappEmployees.keySet()){
			if (mapWrappEmployees.get(id).freeHours == 0) {
				mapWrappEmployees.get(id).freeHours = mapWrappEmployees.get(id).availability;
			}
			if (mapWrappEmployees.get(id).totalHours != mapWrappEmployees.get(id).availability) {
				listWEmpls.add(mapWrappEmployees.get(id));
			} 
		}
		return listWEmpls;
	}

	@AuraEnabled
	public static void addEmployeeToProject(String jsonWEmployees) {
		List<WrappEmployee> wEmpls = (List<L_EmployeeController.WrappEmployee>)JSON.deserialize(jsonWEmployees, List<L_EmployeeController.WrappEmployee>.class);
		try {
			if (!wEmpls.isEmpty()){
				List<EmployeeSkill__c> skills = new List<EmployeeSkill__c>();
				for(WrappEmployee wEmpl : wEmpls ) {
					EmployeeSkill__c skill = new EmployeeSkill__c(
						Employee__c = (String)wEmpl.id, 
						Assigned_Time__c = (Integer)wEmpl.hours, 
						Project__c = (String)wEmpl.projectId, 
						Position__c=(String)wEmpl.position
					);
					skills.add(skill);
				}
				insert skills;
			}
		} catch(DmlException e){
            System.debug('DmlException caught: ' + e.getMessage() + 'Line ' + e.getLineNumber());
			throw new AuraHandledException('Error!!! ');
		} catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage() + 'Line ' + e.getLineNumber());
        }
	}
	
	
	public class WrappEmployee{
		@AuraEnabled
		public Id id {get; set;}
		@AuraEnabled
		public String firstName {get; set;}
		@AuraEnabled
		public String lastName {get; set;}
		@AuraEnabled
		public String level {get; set;}
		@AuraEnabled
		public String department {get; set;}
		@AuraEnabled
		public Boolean isActive {get; set;}
		@AuraEnabled
		public Integer freeHours {get; set;} { freeHours = 0; }
		@AuraEnabled
		public Integer totalHours {get; set;}
		@AuraEnabled
		public Integer availability {get; set;}
		@AuraEnabled
		public String projectId {get; set;}
		@AuraEnabled
		public String position {get; set;}
		@AuraEnabled
		public Integer hours {get; set;}
		
	}
}