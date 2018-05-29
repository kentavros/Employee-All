public with sharing class L_ProjectDetailsController {


    @AuraEnabled
    public static List<EmployeeSkillWrapper> getEmployeeSkillsByProjectID(String Id) {
        EmployeeSkill__c[]  employeeSkillList = new EmployeeSkill__c[]{};
        
        try {
            for (EmployeeSkill__c[] employeeSkillListBatch : [
                    SELECT Id,
                        Employee__r.First_Name__c,
                        Employee__r.Last_Name__c,
                        Employee__r.Availability__c,
                        Assigned_Time__c,
                        Position__c,
                        Project__c
                    FROM EmployeeSkill__c
                    WHERE Project__c = :Id
                ]) {

                employeeSkillList.addAll(employeeSkillListBatch);
            }
        }
        catch (QueryException e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.debug(e.getLineNumber());
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.debug(e.getLineNumber());
        }

        return L_ProjectDetailsController.createListWithEmployeeSkillWrapper(employeeSkillList);
    }

    @AuraEnabled
    /* Return all values from picklist */
    public static List<String> getPicklistValuesFromObject(String objectName, String fieldName) {
        return L_SchemaService.getPicklistValues(objectName, fieldName);
    }

    /* Return list with wrapped EmployeeSkills */
    private static List<EmployeeSkillWrapper> createListWithEmployeeSkillWrapper(EmployeeSkill__c[] employeeSkillList) {
        if (employeeSkillList.isEmpty()) {
            return null;
        }
        
        Map<Id,Integer> employeeIDAndSumAssignedTimeMap = L_ProjectDetailsController.createMapEmployeeIDAndSumAssignedTime(employeeSkillList);

        EmployeeSkillWrapper[] employeeSkillWrapperList = new EmployeeSkillWrapper[]{};

        for (EmployeeSkill__c employeeSkill : employeeSkillList) {
            Integer employeeAvailability = Math.round((Decimal)employeeSkill.Employee__r.Availability__c);
            Integer employeeSumAssignedTime = employeeIDAndSumAssignedTimeMap.get(employeeSkill.Employee__c);

            Integer freeHours = employeeAvailability - employeeSumAssignedTime;

            EmployeeSkillWrapper employeeSkillWrapper = new EmployeeSkillWrapper();
            employeeSkillWrapper.Id = employeeSkill.Id;
            employeeSkillWrapper.employeeID = employeeSkill.Employee__c;
            employeeSkillWrapper.projectID = employeeSkill.Project__c;
            employeeSkillWrapper.position = employeeSkill.Position__c;
            employeeSkillWrapper.assignedTime = Math.round((Decimal)employeeSkill.Assigned_Time__c);
            employeeSkillWrapper.employeeAvailability = Math.round((Decimal)employeeSkill.Employee__r.Availability__c);
            employeeSkillWrapper.employeeFreeHours = freeHours;
            employeeSkillWrapper.employeeSumAssignedTime = employeeSumAssignedTime;
            employeeSkillWrapper.employeeFirstName = employeeSkill.Employee__r.First_Name__c;
            employeeSkillWrapper.employeeLastName = employeeSkill.Employee__r.Last_Name__c;

            employeeSkillWrapperList.add(employeeSkillWrapper);
        }

        return employeeSkillWrapperList;
    }

    private static Map<Id,Integer> createMapEmployeeIDAndSumAssignedTime(EmployeeSkill__c[] employeeSkillList) {
        Id[] employeeIDs = new Id[]{};

        for (EmployeeSkill__c employeeSkill : employeeSkillList) {
            employeeIDs.add(employeeSkill.Employee__c);
        }

        AggregateResult[] sumEmployeeAssignedTimeList = new AggregateResult[]{};

        try {
            for (AggregateResult[] sumEmployeeAssignedTimeListBatch : [
                    SELECT Employee__r.Id, SUM(Assigned_Time__c) SUM
                    FROM EmployeeSkill__c
                    WHERE Employee__c = :employeeIDs
                    GROUP BY Employee__r.Id
                ]) {

                sumEmployeeAssignedTimeList.addAll(sumEmployeeAssignedTimeListBatch);
            }
        }
        catch (QueryException e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.debug(e.getLineNumber());
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getTypeName());
            System.debug(e.getLineNumber());
        }

        Map<Id,Integer> employeeIDAndSumAssignedTimeMap = new Map<Id,Integer>();

        for (AggregateResult result : sumEmployeeAssignedTimeList) {
            employeeIDAndSumAssignedTimeMap.put((Id)result.get('Id'), Math.round((Decimal)result.get('sum')));
        }

        return employeeIDAndSumAssignedTimeMap;
    }

    public class EmployeeSkillWrapper {
        @AuraEnabled
        public Id Id {get; set;}
        @AuraEnabled
        public Id employeeID {get; set;}
        @AuraEnabled
        public Id projectID {get; set;}
        @AuraEnabled
        public String position {get; set;}
        @AuraEnabled
        public Integer assignedTime {get; set;}
        @AuraEnabled
        public Integer employeeAvailability {get; set;}
        @AuraEnabled
        public Integer employeeFreeHours {get; set;}
        @AuraEnabled
        public Integer employeeSumAssignedTime {get; set;}
        @AuraEnabled
        public String employeeFirstName {get; set;}
        @AuraEnabled
        public String employeeLastName {get; set;}
    }
}