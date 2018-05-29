public with sharing class EmployeeSkillTriggerHandler {
	
	public EmployeeSkillTriggerHandler() {
        this.manage();
	}

    public void manage() {
        
        if (Trigger.isBefore) {
            //DO Some for future


        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {

                EmployeeSkillTriggerHelper.insertTriggerAfter(Trigger.new); 
            }
            else if (Trigger.isUpdate) {

                EmployeeSkillTriggerHelper.insertTriggerAfter(Trigger.new);
            }
            else if (Trigger.isDelete) {

                EmployeeSkillTriggerHelper.deleteTriggerAfter(Trigger.old);
            }
            else if (Trigger.isundelete) {
                
                EmployeeSkillTriggerHelper.undeleteTriggerAfter(Trigger.new);
            }
        }
    }
}