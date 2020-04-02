@RestResource(urlMapping='/HealthCheck')
global with sharing class HealthCheck {
    public static final String APP_PARAM = 'applications';
    public static final String APP_PAYMENTS = 'payments';

    public static final String ERR_PARSING = System.label.hcErrorParsingRequest;
    public static final String ERR_CODE_PARSING = 'PARSING_FAILED';

    public static final String ERR_UNKNOWN_APP = System.label.hcErrorUnknownApp;
    public static final String ERR_CODE_UNKNOWN_APP = 'UNKNOWN_APP';

    /*******************************************************************************************************
    * @description Method that takes in a list of application names and attempts to run a health check for
    * each.  It returns a list of HealthCheckResponse objects in a serialized JSON string.
    */
    @HttpPost
    global static void checkHealth() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestJSON = RestContext.request.requestBody.toString(); 

        HealthCheckResponse[] checkResponses = new HealthCheckResponse[]{};

        String[] appsToCheck = new String[]{};

        //Deserialize request body and convert to list of application names to check.
        try { 
            Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(requestJSON);

            List<Object> appObjs = (List<Object>)jsonMap.get(APP_PARAM);

            for (Object appObj : appObjs) {
                appsToCheck.add(String.valueOf(appObj));
            }
        } catch (Exception e) {
            HealthCheckResponse.Error error = new HealthCheckResponse.Error(ERR_CODE_PARSING,ERR_PARSING);
            HealthCheckResponse checkResponse = new HealthCheckResponse(null,false);
            checkResponse.errors.add(error);
            checkResponses.add(checkResponse);
            res.responseBody = Blob.valueOf(JSON.serialize(checkResponses));
            res.statusCode = 400;
            return;
        }

        //Loop through each app and perform checks, storing the results in a HealthCheckResponse Map.
        for (String app : appsToCheck) {
            HealthCheckResponse checkResponse = new HealthCheckResponse(app,true);

            if (app == APP_PAYMENTS) {
                HealthCheckPayments.checkHealth(checkResponse);
            } else {
                HealthCheckResponse.Error error = new HealthCheckResponse.Error(ERR_CODE_UNKNOWN_APP,ERR_UNKNOWN_APP);
                checkResponse.result = false;
                checkResponse.errors.add(error);
            }

            checkResponses.add(checkResponse);
        }

        res.responseBody = Blob.valueOf(JSON.serialize(checkResponses));
        res.statusCode = 200;
    }
}