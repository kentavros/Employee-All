({
	fireEventWithFilterValues : function(cmp) {
		var selectedPositionValue = cmp.get('v.selectedPositionValue');

		/* Fire event with action and btn label to 'RandomWords.cmp' */
		cmp.getEvent("eventSelectedFilter")
		.setParams({
			"position" : selectedPositionValue,
		})
		.fire();
	}
})