public with sharing class EmployeeSkillTriggerHelper {
	
	public static void insertTriggerAfter(List<EmployeeSkill__c> skills) {

		EmployeeSkillTriggerService.checkAvailabilityTimeEmployees(skills);
	}

	public static void deleteTriggerAfter(List<EmployeeSkill__c> skills) {

		EmployeeSkillTriggerService.recalculateFieldsProject(skills);
	}

	public static void undeleteTriggerAfter(List<EmployeeSkill__c> skills) {
		
		EmployeeSkillTriggerService.checkAvailabilityTimeEmployees(skills);
		
	}
}