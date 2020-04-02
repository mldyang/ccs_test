@isTest
private with sharing class HealthCheckPayments_TEST {

    public static final String PERMISSION_SET_NAME = 'Payments_Integration';

    @isTest
    static void healthCheckPaymentsReturnResult() {

        String jsonBody = '{"'+ HealthCheck.APP_PARAM + '" : ["' + HealthCheck.APP_PAYMENTS + '"]}';

        System.debug('JSON BODY IS: ' + jsonBody);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/HealthCheck';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        //must run in a context of a user that has the proper permission
        Profile pfStandard = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        List<User> stdUsers = TestUtils_TEST.createUser(pfStandard.Id, 1, true);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET_NAME];
        insert new PermissionSetAssignment(AssigneeId = stdUsers[0].id, PermissionSetId = ps.Id);
        
        System.runAs(stdUsers[0]){
            Test.startTest();
            HealthCheck.checkHealth();
            Test.stopTest();
        }

        PackageLicense[] pLic = [SELECT NamespacePrefix 
                                FROM PackageLicense 
                                WHERE NamespacePrefix =: HealthCheckPayments.NPSP_NS LIMIT 1];

        System.assertEquals(200, RestContext.response.statusCode);
        
        HealthCheckResponse[] hcrs = getHCRsFromResponseBody(RestContext.response.responseBody.toString());

        System.assertEquals(1, hcrs.size());

        System.assertEquals(HealthCheck.APP_PAYMENTS,hcrs[0].applicationName);

        //This switch is needed to account for the fact that orgs may or may not have npsp installed.
        //It could be replaced by implementing mock/stub
        if (!HealthCheckPayments.hasMinimumNPSPVersion()) {
            System.assertEquals(false, hcrs[0].result);
            System.assertEquals(HealthCheckPayments.ERR_NPSP_MIN_VERSION_ABSENT, hcrs[0].errors[0].errorMessage);
            System.assertEquals(HealthCheckPayments.ERR_CODE_NPSP_ABSENT, hcrs[0].errors[0].errorCode);
        } else {
            System.assertEquals(true, hcrs[0].result);
        }
    }

    @isTest
    static void healthCheckPaymentsFailCheck() {

        String jsonBody = '{"'+ HealthCheck.APP_PARAM + '" : ["' + HealthCheck.APP_PAYMENTS + '"]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/HealthCheck';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        //Setting the namespace value to some fake value so it cannot be found.
        HealthCheckPayments.NPSP_NS = 'jdlkfjisnednfa';
        HealthCheck.checkHealth();

        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        HealthCheckResponse[] hcrs = getHCRsFromResponseBody(RestContext.response.responseBody.toString());

        System.assertEquals(1,hcrs.size());
        System.assertEquals(false,hcrs[0].result);

        System.assertEquals(HealthCheck.APP_PAYMENTS, hcrs[0].applicationName);
        System.assertEquals(HealthCheckPayments.ERR_CODE_NPSP_ABSENT, hcrs[0].errors[0].errorCode);
        System.assertEquals(HealthCheckPayments.ERR_NPSP_MIN_VERSION_ABSENT, hcrs[0].errors[0].errorMessage);
    }

    private static HealthCheckResponse[] getHCRsFromResponseBody(String responseBody) {
        HealthCheckResponse[] hcrs = new HealthCheckResponse[]{};
        List<Object> responseList = 
            (List<Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());

        for (Integer i = 0; i < responseList.size(); i ++) {
            String objString = JSON.serialize(responseList[i]);
            hcrs.add((HealthCheckResponse)JSON.deserialize(objString, HealthCheckResponse.class));
        }

        return hcrs;
    }
}