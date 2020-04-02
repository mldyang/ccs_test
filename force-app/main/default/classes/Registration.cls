@RestResource(urlMapping='/Registration')
global with sharing class Registration {
    public static final String ERR_CODE_ERROR = 'ERROR';
    public static final String ERR_ERROR = System.label.regError;

    public static final String ERR_CODE_PARSING = 'PARSING_FAILED';
    public static final String ERR_PARSING = System.label.hcErrorParsingRequest;

    public static final String ERR_CODE_DMLERROR = 'DML_ERROR';
    public static final String ERR_DML_ERROR = System.label.regDMLError;

    @HttpPost
    global static void register() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String requestJSON = RestContext.request.requestBody.toString(); 
        List<RegistrationResponse> responseList = new List<RegistrationResponse>();

        try {
            List<Service_Info__c> serviceInfoToUpsertList = new List<Service_Info__c>();
            Map<String, Map<String, List<Map<String, String>>>> jsonMap = new Map<String, Map<String, List<Map<String, String>>>>();
            Map<String, List<Map<String, String>>> serviceToKeyValuePairs = new Map<String, List<Map<String, String>>>();

            try {
                jsonMap = (Map<String, Map<String, List<Map<String, String>>>>)JSON.deserialize(requestJSON, Map<String, Map<String, List<Map<String, String>>>>.class);
                serviceToKeyValuePairs = jsonMap.get(ServiceInfoUtils.APP_CONST);
            } catch (Exception e) {
                response = setErrorResponse(response, ERR_CODE_PARSING, ERR_PARSING, responseList, 400);

                return;
            }
            
            for (String service : serviceToKeyValuePairs.keyset()) {
                List<Map<String, String>> keyValueList = serviceToKeyValuePairs.get(service);
                List<Service_Info__c> newServiceInfo = new List<Service_Info__c>();

                try {
                    // If there are no existing records for the service, just create all new service info records. 
                    newServiceInfo = ServiceInfoUtils.createServiceInfo(service, keyValueList);
                } catch (JSONException e) {
                    response = setErrorResponse(response, ERR_CODE_PARSING, ERR_PARSING, responseList, 400);

                    return;
                }

                serviceInfoToUpsertList.addAll(newServiceInfo);
            }

            try {
                // FLS/CRUD checks would happen here. 
                upsert serviceInfoToUpsertList Service_Key__c;
            } catch (DMLException e) {
                response = setErrorResponse(response, ERR_CODE_DMLERROR, ERR_DML_ERROR, responseList, 500);

                return;
            }

            for (String service : serviceToKeyValuePairs.keyset()) {
                RegistrationResponse registrationResponse = new RegistrationResponse(service, true);

                responseList.add(registrationResponse);
            }

            response.statusCode = 200;
        } catch (Exception e) {
            response = setErrorResponse(response, ERR_CODE_ERROR, ERR_ERROR, responseList, 400);
        }
    }

    public static RestResponse setErrorResponse(RestResponse response, String errorCode, String errorMessage, List<RegistrationResponse> responseList, Integer httpCode) {
        RegistrationResponse registrationResponse = new RegistrationResponse(null, false);
        RegistrationResponse.Error error = new RegistrationResponse.Error(errorCode, errorMessage);
        
        registrationResponse.errors.add(error);
        responseList.add(registrationResponse);
        response.responseBody = Blob.valueOf(JSON.serialize(responseList));
        response.statusCode = httpCode;
        
        return response;
    }
}