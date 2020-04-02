@isTest
private with sharing class HealthCheck_TEST {

    @isTest
    static void healthCheckPaymentsReturnResult() {

        String jsonBody = '{"'+ 'applications' + '" : ["' + 'payments' + '"]}';

        System.debug('JSON BODY IS: ' + jsonBody);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/HealthCheck';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        npsp__Data_Import_Settings__c dataImportSettings = new npsp__Data_Import_Settings__c();
        dataImportSettings.npsp__Field_Mapping_Method__c = 'Data Import Field Mapping';

        Test.startTest();
        HealthCheck.checkHealth();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);

    }
}