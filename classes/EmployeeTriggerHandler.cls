public class EmployeeTriggerHandler {

    public EmployeeTriggerHandler() {
        this.manage();
    } 

    public void manage() {
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                
                EmployeeTriggerHelper.insertTriggerBefore(Trigger.new);
            }
            else if (Trigger.isDelete) {

                EmployeeTriggerHelper.deleteTriggerBefore(Trigger.oldMap); 
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isUpdate) {

                EmployeeTriggerHelper.updateTriggerAfter(Trigger.new, Trigger.oldMap); 

            } else if (Trigger.isUndelete) {

                EmployeeTriggerHelper.undeleteTrigger(Trigger.new, Trigger.newMap);
                
            } 
        } 
    }
    
}