({
	getEmployees : function(component) {
		var action = component.get('c.getFilteredEmployees');
		action.setParams({
			"name" : '',
			"department" : '',
			"level" : ''
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set('v.wrappEmployee', result);

				this.getPicklistValue(component, 'Employee__c', 'IT_Department__c', 'v.depatmentPick');
				this.getPicklistValue(component, 'Employee__c', 'Level__c', 'v.levelPick');
				this.getPicklistValue(component, 'EmployeeSkill__c', 'Position__c', 'v.positionPick');

			} else {
				console.log("Error request. Response: " + state);
			}
		});
		$A.enqueueAction(action);
	},

	getEmployeesByFilter : function(component, params) {
		var action = component.get('c.getFilteredEmployees');
		action.setParams({
			"name" : params.name,
			"department" : params.department,
			"level" : params.level
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set('v.wrappEmployee', result);
			} else {
				console.log("Error request. Response: " + state);
			}
		});
		$A.enqueueAction(action);
	},

	getPicklistValue : function(component, obj, field, compName) {
		var action = component.get('c.getPicklistValues');
		action.setParams({
			"objName" : obj,
			"fieldName" : field
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set(compName, result);
			} else {
				console.log("Error request. Response: " + state);
			}
		});
		$A.enqueueAction(action);
	},

	getSortValues : function(component, arrObj, name, value) {

		if (name == 'sortName') {
			var sortField = 'firstName';
			if (value) {
				this.sortUp(component, arrObj, sortField);
				component.set('v.sortName', !value);
				
			} else {
				this.sortDown(component, arrObj, sortField);
				component.set('v.sortName', !value);
			}
		} else if (name == 'sortHours'){
			var sortField = 'freeHours';
			if (value) {
				this.sortUp(component, arrObj, sortField);
				component.set('v.sortHours', !value);	
			} else {
				this.sortDown(component, arrObj, sortField);
				component.set('v.sortHours', !value);
			}
		} else if (name == 'sortDepat') {
			var sortField = 'department';
			if (value) {
				this.sortUp(component, arrObj, sortField);
				component.set('v.sortDepat', !value);
			} else {
				this.sortDown(component, arrObj, sortField);
				component.set('v.sortDepat', !value);
			}
		} else if (name == 'sortLevel'){
			var sortField = 'level';
			if (value) {
				this.sortUp(component, arrObj, sortField);
				component.set('v.sortLevel', !value);
			} else {
				this.sortDown(component, arrObj, sortField);
				component.set('v.sortLevel', !value);
			}
		}
	},

	sortUp : function(component, arrObj, name) {
		arrObj.sort(function(a, b){
			var propA = a[name];
			var propB = b[name];
			
			if (typeof(propA) == "string" || typeof(propB) == "string") {
				propA = String(propA).toLowerCase();
				propB = String(propB).toLowerCase();
			}
			return propA == propB ? 0 : +(propA > propB) || -1;
		});
		component.set('v.wrappEmployee', arrObj);
	},

	sortDown : function(component, arrObj, name) {
		arrObj.sort(function(a, b){
			var propA = a[name];
			var propB = b[name];
			if (typeof(propA) == "string" || typeof(propB) == "string") {
				propA = String(propA).toLowerCase();
				propB = String(propB).toLowerCase();
			}
			return propA == propB ? 0 : +(propA < propB) || -1;
		});
		component.set('v.wrappEmployee', arrObj);
	},


})