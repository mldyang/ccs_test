@isTest
private with sharing class HealthCheck_TEST {

    @isTest
    static void shouldThrowParsingError() {

        //This string has incorrect syntax and should generate the parsing error.
        String jsonBody = '{"'+ HealthCheck.APP_PARAM + '" : [\'' + HealthCheck.APP_PAYMENTS + '"]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/HealthCheck';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
     
        HealthCheck.checkHealth();

        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
        HealthCheckResponse[] hcrs = getHCRsFromResponseBody(RestContext.response.responseBody.toString());
        System.assertEquals(1, hcrs.size());

        System.assertEquals(HealthCheck.ERR_PARSING, hcrs[0].errors[0].errorMessage);
        System.assertEquals(HealthCheck.ERR_CODE_PARSING, hcrs[0].errors[0].errorCode);
    }

    @isTest
    static void shouldGiveUnknownApp() {
        String fakeTestAppName1 = 'xlksijjgi';
        String fakeTestAppName2 = 'wionvwind';

        //This string has a fake app name that should give an uknown app error
        String jsonBody = '{"'+ HealthCheck.APP_PARAM + '" : ["' + fakeTestAppName1 + '","' + fakeTestAppName2 +'"]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/HealthCheck';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
     
        HealthCheck.checkHealth();

        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);

        HealthCheckResponse[] hcrs = getHCRsFromResponseBody(RestContext.response.responseBody.toString());

        System.assertEquals(false, hcrs[0].result);
        System.assertEquals(fakeTestAppName1, hcrs[0].applicationName);
        System.assertEquals(HealthCheck.ERR_CODE_UNKNOWN_APP, hcrs[0].errors[0].errorCode);
        System.assertEquals(HealthCheck.ERR_UNKNOWN_APP, hcrs[0].errors[0].errorMessage);

        System.assertEquals(false, hcrs[1].result);
        System.assertEquals(fakeTestAppName2, hcrs[1].applicationName);
        System.assertEquals(HealthCheck.ERR_CODE_UNKNOWN_APP, hcrs[1].errors[0].errorCode);
        System.assertEquals(HealthCheck.ERR_UNKNOWN_APP, hcrs[1].errors[0].errorMessage);
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