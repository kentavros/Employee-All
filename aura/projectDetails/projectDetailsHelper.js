({
    /* Silly request on the Server */
    sendRequest : function(cmp, apexMethodName, methodParams, callbackFunction) {
        let request = cmp.get('c.' + apexMethodName);
        
        if (methodParams) {
            request.setParams(methodParams);
        }
        
        if (callbackFunction) {
            request.setCallback(this, callbackFunction);
        }
        
        $A.enqueueAction(request);
	},

    getAllEmployeeSkillsForProject : function(cmp) {
		let projectId = {
			'Id' : cmp.get('v.projectId')
		};

        let callback = function(response) {
            if ( "SUCCESS" === response.getState() ) {
				cmp.set("v.allEmployeeSkillsForProjectList", response.getReturnValue());
                cmp.set("v.filteredEmployeeSkillsForProjectList", response.getReturnValue());
//                console.log(response.getReturnValue());
//                console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                
            }
            else {
                console.log( "Failed with state: " +
                            response.getState() +
                            " in getAllEmployeeSkillsForProject()" );
            }
        };
        
        this.sendRequest(cmp, "getEmployeeSkillsByProjectID", projectId, callback);
    },

    getPicklistValuesForFilter : function(cmp, objectName, fieldName) {
		let params = {
			'objectName' : objectName,
			'fieldName' : fieldName
		};

        let callback = function(response) {
            if ( "SUCCESS" === response.getState() ) {
				var picklistValuesForFilterMap = cmp.get('v.picklistValuesForFilterMap');
				picklistValuesForFilterMap[params.fieldName] = response.getReturnValue();

				cmp.set("v.picklistValuesForFilterMap", picklistValuesForFilterMap);
            }
            else {
                console.log( "Failed with state: " +
                            response.getState() +
                            " in getPicklistValuesForFilter()" );
            }
        };
        
        this.sendRequest(cmp, "getPicklistValuesFromObject", params, callback);
    },

    doFiltration : function(cmp, event) {
        var selectedPosition = event.getParam('position');

		var allEmployeeSkillsForProjectList = cmp.get('v.allEmployeeSkillsForProjectList');
		var filteredEmployeeSkillsForProjectList = cmp.get('v.filteredEmployeeSkillsForProjectList');
		
		if (!selectedPosition) {
			filteredEmployeeSkillsForProjectList = allEmployeeSkillsForProjectList;
		}
		else {
			var filteredEmployeeSkillsForProjectList = allEmployeeSkillsForProjectList.filter(function(employeeSkill) {
				if(employeeSkill.position == selectedPosition) {
					return true;
				}
            });
		}

		cmp.set('v.filteredEmployeeSkillsForProjectList', filteredEmployeeSkillsForProjectList);
    }
})