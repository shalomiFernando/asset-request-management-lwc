@IsTest
public class AssetRequestControllerTest {

    private static List<Asset_Request__c> createSampleRequests(Integer count) {
        List<Asset_Request__c> reqs = new List<Asset_Request__c>();
        for (Integer i = 0; i < count; i++) {
            reqs.add(new Asset_Request__c(
                Employee_Name__c = 'Employee ' + i,
                Department__c = 'IT',
                Asset_Type__c = 'Laptop',
                Requested_Date__c = Date.today().addDays(-i),
                Required_By_Date__c = Date.today().addDays(5),
                Quantity__c = 1,
                Priority__c = 'High',
                Status__c = 'Draft',
                Employee_Email__c = 'abc@gmail.com'
            ));
        }
        insert reqs;
        return reqs;
   }

    @IsTest
    static void testAssetRequests() {
        createSampleRequests(3);

        Test.startTest();
        List<Asset_Request__c> results = AssetRequestController.assetRequests();
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Should return all records');
    }

    @IsTest
    static void testSaveAssetRequest() {
        Map<String, String> request = new Map<String, String>{
            'employeeName' => 'John Doe',
            'employeeEmail' => 'john@example.com',
            'department' => 'Finance',
            'justification' => 'Need laptop',
            'assetType' => 'Laptop',
            'priority' => 'High',
            'dateRequired' => String.valueOf(Date.today().addDays(3)),
            'dateRequested' => String.valueOf(Date.today()),
            'quantity' => '2'
        };

        Test.startTest();
        Asset_Request__c saved = AssetRequestController.saveAssetRequest(request);
        Test.stopTest();

        System.assertNotEquals(null, saved.Id, 'Record should be inserted');
        System.assertEquals('Draft', saved.Status__c, 'Status should default to Draft');
        System.assertEquals(2, saved.Quantity__c, 'Quantity should be parsed correctly');
    }

    @IsTest
    static void testGetUser() {
        Test.startTest();
        User u = AssetRequestController.getUser();
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), u.Id, 'Should return current user');
    }

    @IsTest
    static void testGetPaginatedRequests_NoFilters() {
        createSampleRequests(10);

        Test.startTest();
        Map<String, Object> result = AssetRequestController.getPaginatedRequests(1, 5, null);
        Test.stopTest();

        List<Asset_Request__c> records = (List<Asset_Request__c>) result.get('records');
        Integer total = (Integer) result.get('totalRecords');

        System.assertEquals(5, records.size(), 'Should return first 5 records');
        System.assertEquals(10, total, 'Total records should match');
    }

    @IsTest
    static void testGetPaginatedRequests_WithFilters() {
        createSampleRequests(5);

        Map<String, Object> filters = new Map<String, Object>{
            'employeeName' => 'Employee 1',
            'department' => 'IT',
            'assetType' => 'Laptop',
            'status' => 'Draft',
            'priority' => 'High',
            'dateFrom' => String.valueOf(Date.today().addDays(-3)),
            'dateTo' => String.valueOf(Date.today())
        };

        Test.startTest();
        Map<String, Object> result = AssetRequestController.getPaginatedRequests(1, 10, filters);
        Test.stopTest();

        List<Asset_Request__c> records = (List<Asset_Request__c>) result.get('records');

        System.assert(records.size() > 0, 'Filtered results should return at least one record');
    }

    @IsTest
    static void testSetPickListValues() {
        List<String> fields = new List<String>{ 'Priority__c', 'Status__c' };

        Test.startTest();
        Map<String, List<String>> result = AssetRequestController.setPickListValues(fields);
        Test.stopTest();

        System.assert(result.containsKey('Priority__c'), 'Should contain Priority__c values');
        System.assert(result.get('Priority__c').size() > 0, 'Picklist should have values');
    }

    @IsTest
    static void testUpdateAssetRequests() {
        List<Asset_Request__c> reqs = createSampleRequests(2);
        reqs[0].Status__c = 'Approved';

        Test.startTest();
        AssetRequestController.updateAssetRequests(reqs);
        Test.stopTest();

        Asset_Request__c updated = [SELECT Status__c FROM Asset_Request__c WHERE Id = :reqs[0].Id];
        System.assertEquals('Approved', updated.Status__c, 'Record should be updated');
    }
}