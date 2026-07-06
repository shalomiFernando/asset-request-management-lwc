public with sharing class AssetRequestController {
    
    @AuraEnabled(cacheable=true)
    public static List<Asset_Request__c> assetRequests(){
        try {
            return[
                SELECT Name, Employee_Name__c, Department__c, Asset_Type__c,
                       Requested_Date__c, Required_By_Date__c, Quantity__c, 
                       Priority__c, Status__c, Estimated_Cost__c, Manager_Comments__c
                FROM Asset_Request__c
                ORDER BY Name
            ];
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Asset_Request__c saveAssetRequest(Map<String, string> request){
        System.debug('Asset Request ' + request);
        try {
            Asset_Request__c newRequest = new Asset_Request__c();

            newRequest.Employee_Name__c = (String)request.get('employeeName');
            newRequest.Employee_Email__c = (String)request.get('employeeEmail');
            newRequest.Department__c = (String)request.get('department');
            newRequest.Business_Justification__c = (String)request.get('justification');
            newRequest.Asset_Type__c = (String)request.get('assetType');
            newRequest.Priority__c = (String)request.get('priority');

            if (request.get('dateRequired') != null && String.valueOf(request.get('dateRequired')) != '') {
                newRequest.Required_By_Date__c = Date.valueOf((String)request.get('dateRequired'));
            }
            if (request.get('dateRequested') != null && String.valueOf(request.get('dateRequested')) != '') {
                newRequest.Requested_Date__c = Date.valueOf((String)request.get('dateRequested'));
            }
            if (request.get('quantity') != null && String.valueOf(request.get('quantity')) != '') {
                newRequest.Quantity__c = Integer.valueOf((String)request.get('quantity'));
            }

            newRequest.Status__c = 'Draft';

            System.debug('newRequest: '+newRequest);

            insert newRequest;
            Asset_Request__c insertedAssetRequest = [SELECT Id
                                                     FROM Asset_Request__c
                                                     WHERE Id =: newRequest.Id];

            return insertedAssetRequest;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static User getUser(){
        try {
            Id currentUserId = UserInfo.getUserId();
            User currentUser = [
                SELECT Name, Title 
                FROM User 
                WHERE Id = :currentUserId
            ];
        
            return currentUser;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPaginatedRequests(Integer pageNumber,Integer pageSize,Map<String, Object> filters) {
    
        Map<String, Object> response = new Map<String, Object>();
        List<String> whereClauses = new List<String>();

        if (filters != null) {

            if (isNotBlank(filters.get('employeeName'))) {
                whereClauses.add(
                    'Employee_Name__c LIKE \'%' +
                    String.escapeSingleQuotes(String.valueOf(filters.get('employeeName'))) +
                    '%\''
                );
            }

            if (isNotBlank(filters.get('department'))) {
                whereClauses.add(
                    'Department__c = \'' +
                    String.escapeSingleQuotes(String.valueOf(filters.get('department'))) +
                    '\''
                );
            }

            if (isNotBlank(filters.get('assetType'))) {
                whereClauses.add(
                    'Asset_Type__c = \'' +
                    String.escapeSingleQuotes(String.valueOf(filters.get('assetType'))) +
                    '\''
                );
            }

            if (isNotBlank(filters.get('status'))) {
                whereClauses.add(
                    'Status__c = \'' +
                    String.escapeSingleQuotes(String.valueOf(filters.get('status'))) +
                    '\''
                );
            }

            if (isNotBlank(filters.get('priority'))) {
                whereClauses.add(
                    'Priority__c = \'' +
                    String.escapeSingleQuotes(String.valueOf(filters.get('priority'))) +
                    '\''
                );
            }

            Date dateFrom = safeConvertDate(filters.get('dateFrom'));
            Date dateTo   = safeConvertDate(filters.get('dateTo'));

            if (dateFrom != null) {
                whereClauses.add('Requested_Date__c >= ' + dateFrom.format());
            }

            if (dateTo != null) {
                whereClauses.add('Requested_Date__c <= ' + dateTo.format());
            }
        }

        String whereClause = whereClauses.isEmpty()
            ? ''
            : ' WHERE ' + String.join(whereClauses, ' AND ');

        Integer totalRecords = Database.countQuery(
            'SELECT COUNT() FROM Asset_Request__c' + whereClause
        );

        Integer offsetValue = (pageNumber - 1) * pageSize;

        String mainQuery =
            'SELECT Id, Name, Employee_Name__c, Department__c, Asset_Type__c, Requested_Date__c, ' +
            'Required_By_Date__c, Quantity__c, Priority__c, Status__c, Estimated_Cost__c, Manager_Comments__c ' +
            'FROM Asset_Request__c' +
            whereClause +
            ' ORDER BY CreatedDate DESC' +
            ' LIMIT ' + pageSize +
            ' OFFSET ' + offsetValue;

        List<Asset_Request__c> records = Database.query(mainQuery);

        response.put('records', records);
        response.put('totalRecords', totalRecords);
        return response;
    }

    private static Boolean isNotBlank(Object val) {
        if (val == null) return false;
        String s = String.valueOf(val).trim().toLowerCase();
        return s != '' && s != 'undefined' && s != 'null';
    }

    private static Date safeConvertDate(Object val) {
        if (val == null) return null;

        String raw = String.valueOf(val).trim();
        if (raw == '') return null;

        if (raw.contains('T')) {
            raw = raw.substring(0, raw.indexOf('T'));
        }

        try {
            return Date.valueOf(raw);
        } catch (Exception e) {
            System.debug('Invalid date ignored: ' + raw);
            return null;
        }
    }

    @AuraEnabled
    public static Map<String, List<String>> setPickListValues(List<String> fieldNames){
        try {
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
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}