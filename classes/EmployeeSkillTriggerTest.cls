@isTest
private class EmployeeSkillTriggerTest {

	@testSetup static void setup() {
		Employee__c employee = new Employee__c(	First_Name__c = 'TestF', Last_Name__c='TestL', 
			Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
		);
		insert employee;

		Project__c project = new Project__c(
			Name = 'Test', 	Start_Date__c = system.today(), Priority__c = 'Hot'
		);
		insert project;

		EmployeeSkill__c skill1 = new EmployeeSkill__c(
			Name='Test', Position__c = 'Tester', Assigned_Time__c=6.0, Employee__c = employee.Id,
			Project__c = project.Id
		);
		insert skill1;
	}

	@isTest static void testInsertTriggerAfterErr() {
		Project__c project = [SELECT Id FROM Project__c WHERE Name='Test'];
		Employee__c employee = [SELECT Id FROM Employee__c WHERE First_Name__c = 'TestF'];

		EmployeeSkill__c skill2 = new EmployeeSkill__c(
			Name='Test2', Position__c = 'Tester', Assigned_Time__c=8.0, Employee__c = employee.Id,
			Project__c = project.Id
		);

		Test.startTest();
		Database.SaveResult result = Database.insert(skill2, false);
		Test.stopTest();

		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('The employee\'s time threshold is too high!',
                             result.getErrors()[0].getMessage());
	}

	@isTest static void testInsertTriggerAfter() {
		Project__c project = [SELECT Id FROM Project__c WHERE Name='Test'];
		Employee__c employee = [SELECT Id FROM Employee__c WHERE First_Name__c = 'TestF'];

		EmployeeSkill__c skill2 = new EmployeeSkill__c(
			Name='Test2', Position__c = 'Tester', Assigned_Time__c=1.0, Employee__c = employee.Id,
			Project__c = project.Id
		);

		Test.startTest();
		Database.SaveResult result = Database.insert(skill2);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().size() == 0);
	}

	@isTest static void testUpdateTriggerAfterErr() {
		Project__c project = [SELECT Id FROM Project__c WHERE Name='Test'];
		Employee__c employee = [SELECT Id FROM Employee__c WHERE First_Name__c = 'TestF'];
		
		EmployeeSkill__c skill2 = new EmployeeSkill__c(
			Name='Test', Position__c = 'Tester', Assigned_Time__c=1.0, Employee__c = employee.Id,
			Project__c = project.Id
		);
		insert skill2;
		skill2.Assigned_Time__c = 5.0;

		Test.startTest();
		Database.SaveResult result = Database.update(skill2, false);
		Test.stopTest();

		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('The employee\'s time threshold is too high!',
			result.getErrors()[0].getMessage());
	}	


	@isTest static void testUpdateTriggerAfter() {
		Project__c project = [SELECT Id FROM Project__c WHERE Name='Test'];
		Employee__c employee = [SELECT Id FROM Employee__c WHERE First_Name__c = 'TestF'];
		EmployeeSkill__c skill1 = [SELECT Id, Assigned_Time__c FROM EmployeeSkill__c WHERE Name='Test'];

		skill1.Assigned_Time__c = 8.0;

		Test.startTest();
		Database.SaveResult result = Database.update(skill1);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().size() == 0);
	}	
}