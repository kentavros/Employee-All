({
	handleAccountChange : function(component, event, helper) {
		helper.setNewProjects(component);
		helper.clearNewEmployee(component);
		component.set('v.clearLookup',true);
	},

	clearAccountSearch : function(component, event, helper) { 
		var clearStatus = event.getParam("clearStatus");
		if(clearStatus){
			helper.setNewProjects(component);
			component.find("selectedAccount").set('v.disabled',false);
		}
		helper.clearNewEmployee(component);
	},
	accountSearch : function(component, event, helper) {
	    helper.clearNewEmployee(component);
		var accountId = event.getParam("accountId");
		var allProjects = component.get('v.allProjects');
		var projectForSelectedAccount =[];
		component.find("selectedAccount").set('v.disabled',true);
		projectForSelectedAccount = helper.newProjects(allProjects,accountId);


		if (projectForSelectedAccount.length == 0){
			helper.searchProjects(component,accountId);
		} else {
			component.set("v.projectsForSelectedAccount",projectForSelectedAccount);
		}

	 },
	doInit : function(component, event, helper) {  
		helper.initComponent(component);
	},
	openDetailsWindow : function(component, event, helper) {
		helper.createDetailsWindow(component, event);
	},
	addNewEmployee : function(component, event, helper){
		helper.addNewEmployee(component,event);
	},
	updateEmployeeCount : function(component, event, helper){
	    var projectId = event.getParam('projectId');
	    var employeeId = event.getParam('employeeId');

	    var allProjects = component.get('v.allProjects');
	    var selectedAcc = component.get('v.projectsForSelectedAccount');
//console.log(selectedAcc);
	    allProjects = helper.newEmployeeCount(allProjects,projectId,employeeId);
	    selectedAcc = helper.newEmployeeCount(selectedAcc,projectId,employeeId);
        component.set('v.allProjects',allProjects);
        component.set('v.projectsForSelectedAccount',selectedAcc);
    }
})