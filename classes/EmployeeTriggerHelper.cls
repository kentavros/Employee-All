public with sharing class EmployeeTriggerHelper {
	
	public static void insertTriggerBefore(List<Employee__c> employees){

		EmployeeTriggerService.checkDuplicateEmployees(employees);
		EmployeeTriggerService.checkPartTime(employees);

	}

	public static void updateTriggerAfter(List<Employee__c> newEmployees, Map<Id,SObject> oldMapData ) {

		EmployeeTriggerService.checkDuplicateEmployees(newEmployees);
		EmployeeTriggerService.checkPartTime(newEmployees);
		EmployeeTriggerService.checkDataBeforeProjectCount(newEmployees, oldMapData); 
		
	}

	public static void deleteTriggerBefore(Map<Id,SObject> oldMapData) {

		EmployeeTriggerService.recalculateFieldsProject(oldMapData); 
		
	}

	public static void undeleteTrigger(List<Employee__c> employees, Map<Id,SObject> newMapData) {

		EmployeeTriggerService.checkDuplicateEmployees(employees);
		EmployeeTriggerService.checkPartTime(employees);
		EmployeeTriggerService.checkDataBeforeProjectCount(new List<Employee__c>(), newMapData);

	}

}