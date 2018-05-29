@isTest
private class EmployeeTriggerTest {
	
	@testSetup static void setup() {
		Employee__c employee1 = new Employee__c(	First_Name__c = 'TestF', Last_Name__c='TestL', 
				Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
			);

		insert employee1;
	}

	@isTest static void testInsertTriggerBeforeErr() {

		Employee__c employee2 = new Employee__c(	First_Name__c = 'TestF', Last_Name__c='TestL', 
				Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
			);

		Test.startTest();
		Database.SaveResult result = Database.insert(employee2, false);
		Test.stopTest();

		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('Employee with such data already exists!',
                             result.getErrors()[0].getMessage());
	}
	
	@isTest static void testInsertTriggerBefore() {

		Employee__c employee2 = new Employee__c(	First_Name__c = 'TestFD', Last_Name__c='TestL', 
				Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
			);

		Test.startTest();
		Database.SaveResult result = Database.insert(employee2);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().size() == 0);
	}
	
	@isTest static void testUpdateTriggerBeforeErr() {

		Employee__c employee2 = new Employee__c(	First_Name__c = 'TestFD', Last_Name__c='TestL', 
				Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
			);

		insert employee2;
		employee2.First_Name__c = 'TestF';

		Test.startTest();
		Database.SaveResult result = Database.update(employee2, false);
		Test.stopTest();

		System.assert(!result.isSuccess());
		System.assert(result.getErrors().size() > 0);
		System.assertEquals('Employee with such data already exists!',
                             result.getErrors()[0].getMessage());

	}

	@isTest static void testUpdateTriggerBefore() {

		Employee__c employee2 = new Employee__c(	First_Name__c = 'TestFD', Last_Name__c='TestL', 
				Birthday__c=system.today(), IT_Department__c='QA', Level__c='Junior', 	Start_Date__c=system.today()
			);

		insert employee2;
		employee2.First_Name__c = 'Test';

		Test.startTest();
		Database.SaveResult result = Database.update(employee2);
		Test.stopTest();

		System.assert(result.isSuccess());
		System.assert(result.getErrors().size() == 0);

	}
}