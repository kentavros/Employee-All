({
	doInit : function(component, event, helper) {
		helper.getProjectsSkills(component);
	},

	clickAddEmployee : function(component, event, helper) {
		// console.log('click!');
		var btnClicked = event.getSource();
		var projectId = btnClicked.get("v.name");
		component.set('v.projectId', projectId);
		// console.log(projectId);
		
		
	}
})