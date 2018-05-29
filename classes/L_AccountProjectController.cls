public class L_AccountProjectController {

    @AuraEnabled
    public static String getAccountsWithProject() {

        if (!Schema.getGlobalDescribe().get('Account').getDescribe().isAccessible()
                || !Schema.getGlobalDescribe().get('Project__c').getDescribe().isAccessible()) {
            throw new AuraHandledException('Access error');
        }

        Account[] accountWithProjectsList = [
                SELECT id, Name, (
                        SELECT id, Name, Team_Members__c
                        FROM Projects__r
                )
                FROM Account
                WHERE Id IN (SELECT Account__c FROM Project__c)
                ORDER BY Name
                LIMIT 20
        ];
        List<AccountWithProjectsWrapper> AccountWithProjectWrapperList = formAccountWithProjectsWrapper(accountWithProjectsList);
        return JSON.serialize(AccountWithProjectWrapperList);
    }

    @AuraEnabled
    public static String getAccountProjects(Id accountId) {

        if (!Schema.getGlobalDescribe().get('Account').getDescribe().isAccessible()
                || !Schema.getGlobalDescribe().get('Project__c').getDescribe().isAccessible()) {
            throw new AuraHandledException('Access error');
        }

        Account[] accountWithProjectsList;
        try {
            accountWithProjectsList = [
                    SELECT Id,Name, (
                            SELECT id,Name
                            FROM Projects__r
                    )
                    FROM Account
                    WHERE Id = :accountId
            ];
        } catch (DmlException e) {
            throw new AuraHandledException('You try to break us');
        }
        List<AccountWithProjectsWrapper> AccountWithProjectWrapperList = formAccountWithProjectsWrapper(accountWithProjectsList);
        return JSON.serialize(AccountWithProjectWrapperList);
    }

    private static List<AccountWithProjectsWrapper> formAccountWithProjectsWrapper(List<Account> accountWithProjectsList) {

        Map<Id, AccountWithProjectsWrapper> accountWithProjectsWrapperMap = new Map<Id, L_AccountProjectController.AccountWithProjectsWrapper>();
        Map<Id, AccountProjects> AccountProjectsWrapperMap = new Map<Id, L_AccountProjectController.AccountProjects>();
        List<Id> projectIdList = new List<Id>();
        Map<Id, List<Id>> projectIdEmployeeIdMap = new Map<Id, List<Id>>();

        for (Account accountWithProjects : accountWithProjectsList) {

            AccountWithProjectsWrapper account = new AccountWithProjectsWrapper();
            account.accountId = accountWithProjects.Id;
            account.accountName = accountWithProjects.Name;
            accountWithProjectsWrapperMap.put(accountWithProjects.Id, account);

            for (Project__c project : (Project__c[]) accountWithProjects.Projects__r) {

                AccountProjects accountProject = new AccountProjects();
                accountProject.projectId = project.Id;
                accountProject.projectName = project.Name;
                accountProject.accountId = accountWithProjects.Id;
                AccountProjectsWrapperMap.put(project.Id, accountProject);
                projectIdList.add(project.Id);
            }
        }

        List<AggregateResult> employeeCount = [
                SELECT project__c, COUNT_DISTINCT(Employee__c) employeeCount
                FROM EmployeeSkill__c
                WHERE project__c IN :projectIdList AND Employee__R.isActive__c = true
                GROUP BY project__c
        ];

        AggregateResult[] projectAndEmployeeId = [SELECT employee__c,project__c from EmployeeSkill__c where project__c IN :projectIdList group By employee__c, project__c];
        for (AggregateResult projectWithEmployeeId : projectAndEmployeeId) {
            Id projectId = (id) projectWithEmployeeId.get('project__c');
            Id employeeId = (id) projectWithEmployeeId.get('employee__c');
            if (!projectIdEmployeeIdMap.containsKey(projectId)) {
                List<Id> employeeIdsList = new List<Id>();
                employeeIdsList.add(employeeId);
                projectIdEmployeeIdMap.put(projectId, employeeIdsList);
            } else {
                projectIdEmployeeIdMap.get(projectId).add(employeeId);
            }
        }
        for (AggregateResult countEmployeeOnProject : employeeCount) {
            Id projectId = (Id) countEmployeeOnProject.get('project__c');
            AccountProjects accountProject = AccountProjectsWrapperMap.get(projectId);
            accountProject.teamMembers = (Integer) countEmployeeOnProject.get('employeeCount');
            accountProject.employeeIds = projectIdEmployeeIdMap.get(projectId);
        }
        for (AccountProjects project : AccountProjectsWrapperMap.values()) {
            System.debug(project);
            AccountWithProjectsWrapper account = accountWithProjectsWrapperMap.get(project.accountId);
            if (account.accountProjects == null) {
                List<AccountProjects> accountProject = new List<AccountProjects>();
                accountProject.add(project);
                account.accountProjects = accountProject;
            } else {
                account.accountProjects.add(project);
            }
        }

        return accountWithProjectsWrapperMap.values();
    }

    public class AccountWithProjectsWrapper {
        public String accountName { get; set; }
        public Id accountId { get; set; }
        public AccountProjects[] accountProjects { get; set; }
    }

    public class AccountProjects {
        public Id projectId { get; set; }
        public String projectName { get; set; }
        public Integer teamMembers { get; set; }
        public List<Id> employeeIds { get; set; }
        public Id accountId;
    }
}