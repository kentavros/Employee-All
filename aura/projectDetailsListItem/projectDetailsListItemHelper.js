({
	showOrHideEditForm : function(cmp) {
		cmp.set('v.showEditForm', !cmp.get('v.showEditForm'));
	},

	showOrHideSpinner : function(cmp) {
		cmp.set('v.showSpinner', !cmp.get('v.showSpinner'));
	},

	destroyEditForm : function(cmp) {
		var editForm = cmp.find('edit_form');
		editForm.destroy();
	},
	
	setNewValueForEmployeeSkill : function(cmp, event) {
		var response = event.getParam('response');
		var assignedTimeFieldValue = response.fields.Assigned_Time__c.value;
		var positionFieldValue = response.fields.Position__c.value;
		
		var employeeSkill = cmp.get('v.employeeSkill');
		/* minus old Assigned Time  from sum */
		var newSumAssignedTime = employeeSkill.employeeSumAssignedTime - employeeSkill.assignedTime;
		/* plus new Assigned Time from response */
        newSumAssignedTime = newSumAssignedTime + assignedTimeFieldValue;

        employeeSkill.employeeSumAssignedTime = newSumAssignedTime;
        employeeSkill.employeeFreeHours = employeeSkill.employeeAvailability - employeeSkill.employeeSumAssignedTime;
		employeeSkill.assignedTime = assignedTimeFieldValue;
		employeeSkill.position = positionFieldValue;
		cmp.set('v.employeeSkill', employeeSkill);
	},

	showToast : function(type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: msg,
            duration:'1000',
            key: 'announcement',
            type: type,
            mode: 'dismissible'
        });
        
        toastEvent.fire();
	},
	
	showEditFormErrors : function (event) {
		var error = event.getParam('error');
		
		if (error.data.output.errors.length > 0) {
			var msg = '';

			error.data.output.errors.forEach(element => {
				msg = msg + ' ' + element.message;
			});

			this.showToast('error', error.message, msg);
		}
		else {
			this.showToast('error', '', error.message);
		}
	},

	createEditForm : function(cmp) {
		var components = [
			[// 0
				"lightning:recordEditForm",
				{
					'aura:id' : "edit_form",
					'class' : "slds-grid slds-col",
					'objectApiName' : "EmployeeSkill__c",
					'recordId' : cmp.get("v.employeeSkill.Id"),
					'onsubmit' : cmp.getReference("c.handleEditFormSubmit"),
					'onsuccess' : cmp.getReference("c.handleEditFormSuccess"),
					'onerror' : cmp.getReference("c.handleEditFormError"),
				}
			],
			[// 1
				"lightning:messages",
				{}
			],
			[// 2
				"lightning:inputField",
				{
					'fieldName' : 'Position__c'
				}
			],
			[// 3
				"lightning:inputField",
				{
					'fieldName' : 'Assigned_Time__c'
				}
			],
			[// 4
				"lightning:layoutItem",
				{
					'class' : 'slds-m-top_medium'
				}
			],
			[// 5
				"lightning:button",
				{
				    'class' : 'slds-float_right',
					'type' : 'submit',
					'label' : 'Save',
					'variant' : 'brand',
				}
			],
			[// 6
				"lightning:button",
				{
				    'class' : 'slds-float_left',
					'onclick' : cmp.getReference("c.onclickCencelEditForm"),
					'label' : 'Cencel',
					'variant' : 'neutral',
				}
			],
		];

		var callBackFunction =	function(components, status, errorMessage) {
			if (status === "SUCCESS") {
				var editForm = components[0];
				var messages = components[1];
				var inputFieldPosition = components[2];
				var inputFieldAssignedTime = components[3];
				var layoutItem = components[4];
				var buttonSave = components[5];
				var buttonCencel = components[6];

				var layoutItemBody = layoutItem.get("v.body");
				layoutItemBody.push(buttonSave);
				layoutItemBody.push(buttonCencel);
				layoutItem.set("v.body", layoutItemBody);

				var editFormBody = editForm.get("v.body");
				// editFormBody.push(messages);
				editFormBody.push(inputFieldPosition);
				editFormBody.push(inputFieldAssignedTime);
				editFormBody.push(layoutItem);
				editForm.set("v.body", editFormBody);

				var placeForEditForm = cmp.find('place_for_edit_form');
				var placeForEditFormBody = placeForEditForm.get('v.body');
				placeForEditFormBody.push(editForm);
				placeForEditForm.set('v.body', placeForEditFormBody);
			}
			else if (status === "INCOMPLETE") {
				console.log("createEditForm() | No response from server or client is offline.")
				// Show offline error
			}
			else if (status === "ERROR") {
				console.log("createEditForm() | Error: " + errorMessage);
				// Show error message
			}
		};


		$A.createComponents(components, callBackFunction);
	},
})