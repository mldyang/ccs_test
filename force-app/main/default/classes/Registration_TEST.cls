@isTest
public with sharing class Registration_TEST {

    @isTest
    static void testSuccessfulFirstRegistration() {
        String jsonBody = JSON.serialize(getTestDataPopulatedStructure());

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Registration';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
     
        Registration.register();

        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @isTest
    static void testSuccessfulUpdateRegistration() {
        String jsonBody = JSON.serialize(getTestDataPopulatedStructure());

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        // First registration
        req.requestURI = '/services/apexrest/Registration';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;
        Registration.register();

        // Modify the body and do registration for an update
        jsonBody = JSON.serialize(modifyTestDataPopulatedStructure(getTestDataPopulatedStructure()));
        req.requestBody = Blob.valueof(jsonBody);
        
        Test.startTest();

        Registration.register();

        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);

        List<Service_Info__c> serviceInfoList = [SELECT Id, Key__c, Service__c, Value__c FROM Service_Info__c];

        System.assertEquals(8, serviceInfoList.size());

        for (Service_Info__c serviceInfo : serviceInfoList) {
            System.assert(serviceInfo.Value__c.endsWith('-UPDATED'), 'The service info was not properly updated');
            System.assert(!serviceInfo.Key__c.endsWith('-UPDATED'), 'The service info was not properly updated');
        }
    }

    @isTest
    static void testDeserializationError() {
        String jsonBody = JSON.serialize(getTestDataPopulatedStructure());
        
        // Invalidate the json string. 
        jsonBody = jsonBody.subString(1);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Registration';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
     
        Registration.register();

        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
        List<RegistrationResponse> regResponse = getRRsFromResponseBody(RestContext.response.responseBody.toString());
        System.assertEquals(1, regResponse.size());

        System.assertEquals(HealthCheck.ERR_PARSING, regResponse[0].errors[0].errorMessage);
        System.assertEquals(HealthCheck.ERR_CODE_PARSING, regResponse[0].errors[0].errorCode);
    }

    public static Map<String, Map<String, List<Map<String, String>>>> getTestDataPopulatedStructure() {
        Map<String, Map<String, List<Map<String, String>>>> structureToSerialize = new Map<String, Map<String, List<Map<String, String>>>>();

        Map<String, String> apiKeyMap = new Map<String, String>();
        apiKeyMap.put('key', 'apiKey');
        apiKeyMap.put('value', 'a5146b4b-3d2b-4fc4-a5e5-8387968859a4');
        apiKeyMap.put('isSecret', 'true');

        Map<String, String> tenantIdMap = new Map<String, String>();
        tenantIdMap.put('key', 'tenantId');
        tenantIdMap.put('value', 'a5146b4b-3d2b-4fc4-a5e5-8387968859a4');
        tenantIdMap.put('isSecret', 'false');

        Map<String, String> rolesMap = new Map<String, String>();
        rolesMap.put('key', 'roles');
        rolesMap.put('value', 'makana.role1, makana.role2, makana.role3');
        rolesMap.put('isSecret', 'false');


        Map<String, String> baseURLMap = new Map<String, String>();
        baseURLMap.put('key', 'baseURL');
        baseURLMap.put('value', 'https://someURL.execute-api.us-west-2.amazonaws.com/v1');
        baseURLMap.put('isSecret', 'false');

        List<Map<String,String>> keyValuePairListForMakana = new List<Map<String, String>>();
        keyValuePairListForMakana.add(apiKeyMap);
        keyValuePairListForMakana.add(tenantIdMap);
        keyValuePairListForMakana.add(rolesMap);
        keyValuePairListForMakana.add(baseURLMap);


        List<Map<String,String>> keyValuePairListForPayments = keyValuePairListForMakana.clone();

        Map<String, List<Map<String, String>>> serviceToKeyListValues = new Map<String, List<Map<String, String>>>();
        serviceToKeyListValues.put('makana', keyValuePairListForMakana);
        serviceToKeyListValues.put('payment', keyValuePairListForPayments);

        structureToSerialize.put('applications', serviceToKeyListValues);

        return structureToSerialize;
    }

    public static Map<String, Map<String, List<Map<String, String>>>> modifyTestDataPopulatedStructure(Map<String, Map<String, List<Map<String, String>>>> structureToSerialize) {
        Map<String, List<Map<String, string>>> serviceToKeyValuePairMap = structureToSerialize.get('applications');

        for (String service : serviceToKeyValuePairMap.keyset()) {
            List<Map<String, string>> keyValuePairList = serviceToKeyValuePairMap.get(service);
            
            for (Map<String, String> keyValuePairMap : keyValuePairList) {
                for (String key : keyValuePairMap.keyset()) {

                    if (key == 'value') {
                        string value = keyValuePairMap.get(key);

                        value += '-UPDATED';

                        keyValuePairMap.put(key, value);
                    }
                }
            }
        }
        
        return structureToSerialize;
    }

    private static List<RegistrationResponse> getRRsFromResponseBody(String responseBody) {
        List<RegistrationResponse> regResponseList = new List<RegistrationResponse>();

        List<Object> responseList = 
            (List<Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());

        for (Integer i = 0; i < responseList.size(); i ++) {
            String objString = JSON.serialize(responseList[i]);
            
            regResponseList.add((RegistrationResponse)JSON.deserialize(objString, RegistrationResponse.class));
        }

        return regResponseList;
    }
}