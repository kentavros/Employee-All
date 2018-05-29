({
	getProjectsSkills : function(component) {
		var action = component.get('c.getProjectsAndSkills');
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set('v.projectsAndSkills', result);
				console.log(result);
			} else {
				console.log("Error request. Response: " + state);
			}
		});
		$A.enqueueAction(action);
	}
})