({
	addEmplToProject : function(component, strJsonArr) {
		var action = component.get('c.addEmployeeToProject');
		action.setParams({
			"jsonWEmployees" : strJsonArr
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS') {
				this.refreshEvent(component, event);
				var title = 'SUCCESS ADDED!';
				var msg = 'An employee is assigned to a project !';
				this.showToast('success', title, msg );
				this.fireEventSuccesAdded(component, event);
			} else {
				console.log("Error request!!. Response: " + state);
				var title = 'ERROR ADDED!';
				var msg = 'The employee\'s time threshold is too high!';
				this.showToast('Error', title, msg );
			}
		});
		$A.enqueueAction(action);
	},

	refreshEvent : function(component, event) {
		var updateEvent = component.getEvent('UpdateEmployeesEvent');
		updateEvent.fire();
	}, 

	validateField : function(hours, position, projectId) {
		//var hours = +hours;
		if (hours > 8 || hours < 1 || hours == null) {
			return false;
		}
		else if (position == null || position == '') {
			return false;
		}
		else if (projectId == null || projectId == '') {
			return false;
		}
		return true;
	},

	showToast : function(type, title, msg) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title : title, 
			message: msg,
			duration:'2000',
			type: type,
			mode: 'dismissible'
		});
		toastEvent.fire();
	},

	fireEventSuccesAdded : function(component, event) {
		var projectId = component.get('v.projectId');
		var employee = component.get('v.wEmployee');
		var employeeId = employee.id;
		var cmpEvent = $A.get("e.c:EmployeeSuccessAddedToProjectEvent");
		cmpEvent.setParams({
			'projectId' : projectId,
			'employeeId' : employeeId
		});
		cmpEvent.fire();
		// console.log(employeeId);
		
	}
})