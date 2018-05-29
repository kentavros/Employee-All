@isTest
private class L_EmployeeControllerTest {



	@testSetup static void setup() {
		Employee__c employee = new Employee__c(	First_Name__c = 'TestF', Last_Name__c='TestL', 
			Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	
			Start_Date__c=system.today(), isActive__c= true
		);
		Employee__c employee2 = new Employee__c(	First_Name__c = 'TestF2', Last_Name__c='TestL2', 
			Birthday__c=system.today(), IT_Department__c='DEV', Level__c='Junior', 	
			Start_Date__c=system.today(), isActive__c= true
		);
		List<Employee__c> employees = new List<Employee__c>();
		employees.add(employee);
		employees.add(employee2);

		insert employees;


		// Account acc = new Account(Name = 'Test');
		// insert acc; 

		// Project__c project = new Project__c(
		// 	Name = 'Test', 	Start_Date__c = system.today(), Priority__c = 'Hot', Account__c = acc.Id
		// );
		// insert project;

		// EmployeeSkill__c skill1 = new EmployeeSkill__c(
		// 	Position__c = 'Tester', Assigned_Time__c=6.0, Employee__c = employee.Id,
		// 	Project__c = project.Id
		// );
		// insert skill1;
	}




	
	@isTest static void testGetPicklistValues() {
		List<String> pickListValues = new List<String>();
		pickListValues = L_EmployeeController.getPicklistValues('Employee__c', 'IT_Department__c');

		System.assert(pickListValues.size() > 0);

	}

	@isTest static void testGetPicklistValuesNullPointerExcep() {
		List<String> pickListValues = new List<String>();
		pickListValues = L_EmployeeController.getPicklistValues('ERROREmployee__c', 'IT_Department__c');

		System.assertEquals(1, L_EmployeeController.forTest);

	}


	@isTest static void testGetFilteredEmployees() {
		List<L_EmployeeController.WrappEmployee> wEmpls = L_EmployeeController.getFilteredEmployees('','','');
		System.assertEquals(2, wEmpls.size());

		List<L_EmployeeController.WrappEmployee> wEmpls2 = L_EmployeeController.getFilteredEmployees('TestF2','','');
		System.assertEquals(1, wEmpls2.size());

		List<L_EmployeeController.WrappEmployee> wEmpls3 = L_EmployeeController.getFilteredEmployees('TestF2','DEV','');
		System.assertEquals(1, wEmpls3.size());

		List<L_EmployeeController.WrappEmployee> wEmpls4 = L_EmployeeController.getFilteredEmployees('TestF2','DEV','Junior');
		System.assertEquals(1, wEmpls4.size());

	}
	

	
}