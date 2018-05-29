({
	addEmployee : function(component, event, helper) {
		var wEmployee = JSON.parse(JSON.stringify(component.get('v.wEmployee')));
		var projectId = component.get('v.projectId');
		var position = component.get('v.selPosValue');
		var hours = component.get('v.hour');
        var hours = +hours;
		//console.log(typeof hours);
        //console.log(hours);
        if (!hours) {
            var title = 'ERROR HOURS FIELD ADDED!';
			var msg = 'Check field \'Hours\' and enter valid data! (Example: Hour - min 1, max 8)';
			helper.showToast('Error', title, msg );
			return false;
        } 
		if (!helper.validateField(hours, position, projectId)) {
			var title = 'ERROR ADDED!';
			var msg = 'Check field and enter all valid data! (Example: Hour - min 1, max 8)';
			helper.showToast('Error', title, msg );
			return false;
		}

		wEmployee.projectId = projectId;
		wEmployee.position = position;
		wEmployee.hours = hours;
		var arrWEmployee = [];
		arrWEmployee.push(wEmployee);
		var stringToSend = JSON.stringify(arrWEmployee);
		helper.addEmplToProject(component, stringToSend);
	}
})