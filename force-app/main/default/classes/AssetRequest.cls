public class AssetRequest {
	public static Map<string, string> getPickListValues(){
        try {
            Map<string, string> maplist = new Map<string, string>();
            Schema.DescribeFieldResult result = Asset_Request__c.Department__c.getDescribe();
            List<Schema.PicklistEntry> pList = result.getPicklistValues();

            for (Schema.PicklistEntry entry : pList) {
                if (entry.isActive()) {
                    maplist.put(entry.getValue(), entry.getLabel());
                    System.debug('Value: ' + entry.getValue());
                    System.debug('Label: ' + entry.getLabel());
                }
            }

            return maplist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Map<String, String> getActivePicklistValues(Schema.sObjectField field) {
        Map<String, String> values = new Map<String, String>();
        for (Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                values.put(entry.getValue(), entry.getLabel());
            }
        }
        return values;
    } 
    
    public static Map<String, List<String>> setPickListValues(List<String> fieldNames) {
        Map<String, List<String>> result = new Map<String, List<String>>();
       
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Asset_Request__c.fields.getMap();
        
        for (String field : fieldNames) {
            if (fieldMap.containsKey(field)) {
                List<String> values = new List<String>();
                for (Schema.PicklistEntry entry : fieldMap.get(field).getDescribe().getPicklistValues()) {
                    if (entry.isActive()) {
                        values.add(entry.getValue());
                    }
                }
                result.put(field, values);
            }
        }
        return result;
    }
}