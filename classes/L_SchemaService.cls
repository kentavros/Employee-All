public class L_SchemaService {
	public static List<String> getPicklistValues(String objectName, String fieldName) {
		List<String> picklistValue = new List<String>();
		/* Get all Objects from org */
		Map<String, Schema.SObjectType> allObjects = Schema.getGlobalDescribe();

		/* Exit if the object does not exist */
		if (!allObjects.containsKey(objectName)) {
			System.debug('Error on Object Name');
			return null;
		}
	
		Schema.DescribeSObjectResult objectDesc = allObjects.get(objectName).getDescribe();
		/* Get all Fields of the Object */
		Map<String, Schema.SObjectField> fieldsMap = objectDesc.fields.getMap();

		/* Exit if the field does not exist in this object */
		if (!fieldsMap.containsKey(fieldName)) {
			System.debug('Error on Field Name in Object');
			return null;
		}

		Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldName).getDescribe();
		if (fieldResult.getType() != Schema.DisplayType.PICKLIST) {
			System.debug('Error on Field Type in Object');
			return null;
		}

		List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
		/* Exit if the picklist values are empty in this object */
		if (picklistEntry.isEmpty()) {
			System.debug('Error, picklist values are empty in Object');
			return null;
		}

		/* Fill list with picklist values */
		for (Schema.PicklistEntry pickEntry : picklistEntry) {
			picklistValue.add(pickEntry.getValue());
		}

		return picklistValue;
	}
}