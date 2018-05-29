({
	doInit : function(component, event, helper) {

		var eventProjectId = event.getParam("projectId");
		var projectName = event.getParam("projectName");
		component.set('v.projectId', eventProjectId);
		component.set('v.projectName', projectName);

		var projectId = component.get('v.projectId');
		if (projectId == '') {
			console.log('From doInit - projectId = empty');
			return;
		}
		helper.getEmployees(component);
	},

	getFilteredData : function(component, event, helper) {
		var filterData = component.find('filterForm');		
		var filterValue = {
			name : '',
			department : '',
			level : ''
		};
		for (var i = 0; i < filterData.length; i++) {
			if (filterData[i].get('v.name') == 'inpName') {
				filterValue.name = filterData[i].get('v.value');
			} else if (filterData[i].get('v.name') == 'selDepat') {
				filterValue.department = filterData[i].get('v.value');
			} else if (filterData[i].get('v.name') == 'selLevel') {
				filterValue.level = filterData[i].get('v.value');
			}
		}
		helper.getEmployeesByFilter(component, filterValue);
	}, 

	sortByClick : function(component, event, helper) {
		var wrappEmployee = component.get('v.wrappEmployee');
		var btnClick = event.getSource();
		var btnName = btnClick.get('v.name');
		var btnValue = btnClick.get('v.value');
		helper.getSortValues(component, wrappEmployee, btnName, btnValue);
	}




})