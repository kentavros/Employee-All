({
	onclickEditButton : function(cmp, event, helper) {
		helper.showOrHideEditForm(cmp);
		helper.createEditForm(cmp);
	},

	onclickCancelEditForm : function(cmp, event, helper) {
		helper.showOrHideEditForm(cmp);
		helper.destroyEditForm(cmp);
	},
	
	handleEditFormSubmit : function(cmp, event, helper) {
		helper.showOrHideSpinner(cmp); 
	},
	
	handleEditFormSuccess : function(cmp, event, helper) {
		helper.showOrHideEditForm(cmp);
		helper.showOrHideSpinner(cmp);
		helper.setNewValueForEmployeeSkill(cmp, event);
		helper.destroyEditForm(cmp);
		helper.showToast('success', 'Saved!', 'Data updated successfully!');
	},
	
	handleEditFormError : function(cmp, event, helper) {
		helper.showOrHideSpinner(cmp);
		helper.showEditFormErrors(event);

		// console.log(JSON.parse(JSON.stringify(error)));
	},
})