@RestResource(urlMapping='/HealthCheck')
global with sharing class HealthCheck {

    @HttpPost
    global static void checkHealth() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try { 

            npsp__Data_Import_Settings__c dataImportSettings = npsp.UTIL_CustomSettings_API.getDataImportSettings();
            if(dataImportSettings.npsp__Field_Mapping_Method__c == 'Data Import Field Mapping'){
                res.statusCode = 200;
            }

            List<SetupEntityAccess> seas = [SELECT Id, Parent.Name, Parent.Profile.Id
                                                FROM SetupEntityAccess
                                                WHERE SetupEntityId in (SELECT Id
                                                                        FROM ApexClass
                                                                        WHERE Name = 'ChangeControllerNotification')];

            if (!seas.isEmpty()){
                res.statusCode = 200;
            }
        } catch (Exception e) {
            //res.responseBody = Blob.valueOf(JSON.serialize(checkResponses));
            res.statusCode = 400;
            return;
        }
    }
}