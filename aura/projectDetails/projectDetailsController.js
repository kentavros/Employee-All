({
	doInit : function(cmp, event, helper) {
		helper.getAllEmployeeSkillsForProject(cmp);
		helper.getPicklistValuesForFilter(cmp, 'EmployeeSkill__c', 'Position__c');
	},

	handleEventSelectedFilter : function(cmp, event, helper) {
		helper.doFiltration(cmp, event);
	},

	getEmployeeSkillsForProject : function(cmp, event, helper) {
		helper.getAllEmployeeSkillsForProject(cmp);
	},
})