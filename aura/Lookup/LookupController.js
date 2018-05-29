({
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
		component.set('v.clearLookup',false);
	},
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    clearSelection1 : function(component, event, helper){
        if(event.getParam('value') == true){
            helper.clearSelection(component, event, helper);
            if(document.getElementById('combobox-unique-id') != null && document.getElementById('combobox-unique-id') != undefined){
                document.getElementById('combobox-unique-id').value = '';
            }
        }
    },
    clearAutocomplete : function(component, event, helper){
        if(event.target.getAttribute("autocomplete") !== "off"){
                    event.target.setAttribute("autocomplete","off");
        }
    }
})