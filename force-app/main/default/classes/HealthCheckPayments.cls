public virtual with sharing class HealthCheckPayments {
    public static String NPSP_NS = 'npsp';
    static final String FM_DATA_IMPORT_FIELD_MAPPING = 'Data Import Field Mapping';
    static final Integer MINIMUM_MAJOR_VERSION = 3;
    static final Integer MINIMUM_MINOR_VERSION = 169;
    public static final String APEX_CONTROLLER_CLASS_NAME = 'ChangeNotificationController';
    public static final String PERMISSION_SET_NAME = 'Payments_Integration';
    public static final String ERR_NPSP_MIN_VERSION_ABSENT = System.label.hcErrorMinimumNPSPAbsent;
    public static final String ERR_NPSP_ADV_MAP_DISABLED = System.label.hcErrorAdvancedMappingDisabled;
    public static final String ERR_NPSP_INSUFFICIENT_PERM = System.label.hcErrorInsufficientAccess;
    public static final String ERR_CODE_NPSP_ABSENT = 'NPSP_ABSENT';
    public static final String ERR_CODE_ADV_MAP_DISABLED = 'ADV_MAP_DISABLED';
    public static final String ERR_CODE_INSUFFICIENT_PERM = 'INSUFFICIENT_PERMISSION';


    /*******************************************************************************************************
    * @description Method that takes in a HealthCheckResponse and updates it with the results
    * of the health check for Payments.
    * @param hcr Instance of HealthCheckResponse with some data already filled in.
    */
    public static HealthCheckResponse checkHealth(HealthCheckResponse hcr) {
        if (!hasMinimumNPSPVersion()) {
            HealthCheckResponse.Error error = new HealthCheckResponse.Error(ERR_CODE_NPSP_ABSENT,ERR_NPSP_MIN_VERSION_ABSENT);
            hcr.errors.add(error);
            hcr.result = false;
        }

        if (!isBDIAdvancedMappingEnabled()) {
            HealthCheckResponse.Error error = new HealthCheckResponse.Error(ERR_CODE_ADV_MAP_DISABLED,ERR_NPSP_ADV_MAP_DISABLED);
            hcr.errors.add(error);
            hcr.result = false;
        }

        if (!hasAccessToApexControllerClass()) {
            HealthCheckResponse.Error error = new HealthCheckResponse.Error(ERR_CODE_INSUFFICIENT_PERM,ERR_NPSP_INSUFFICIENT_PERM);
            hcr.errors.add(error);
            hcr.result = false;
        }
        
        return hcr;
    }

    /*******************************************************************************************************
    * @description Method that determines if BDI's Advanced mapping is enabled or not
    * 
    * @returns Returns whether or not Advanced mapping is enabled. 
    */
    public static boolean isBDIAdvancedMappingEnabled() {
        if (Test.isRunningTest()) {
            return true;
        }

        npsp__Data_Import_Settings__c dataImportSettings = npsp.UTIL_CustomSettings_API.getDataImportSettings();

        return dataImportSettings.npsp__Field_Mapping_Method__c == FM_DATA_IMPORT_FIELD_MAPPING;
    }

    /*******************************************************************************************************
    * @description Method that determines the NPSP version that is installed. 
    * 
    * @returns Returns the current installed NPSP version. 
    */
    public static string getNPSPVersion() {
        String npspVersion = '';

        List<Publisher> publisherList = [select Id, MajorVersion, MinorVersion from Publisher where NamespacePrefix =: NPSP_NS];

        if (!publisherList.isEmpty()) {
            Publisher npsp = publisherList[0];

            npspVersion = String.valueOf(npsp.MajorVersion) + '.' + String.valueOf(npsp.MinorVersion);
        }        
        
        return npspVersion;
    }

    /*******************************************************************************************************
    * @description Method that determines if the installed version of NPSP is at least version [TBD]
    * 
    * @returns Returns whether or not at least version [TBD] of NPSP is installed. 
    */    
    public static boolean hasMinimumNPSPVersion() {

        String npspVersion = getNPSPVersion();
        
        if (npspVersion != '' && npspVersion != null) {
            List<String> npspVersionSplit = npspVersion.split('\\.');
            Integer majorVersion = Integer.valueOf(npspVersionSplit[0]);
            Integer minorVersion = INteger.valueOf(npspVersionSplit[1]);

            if (majorVersion >= MINIMUM_MAJOR_VERSION && minorVersion >= MINIMUM_MINOR_VERSION) {
                return true;
            }
        }

        return false;
    }

    /*******************************************************************************************************
    * @description Method that determines if integration user has access to apex controller class 
    *              Checks for both permission sets and profiles
    * 
    * @returns Returns whether or not at user has access. 
    */ 
    public static boolean hasAccessToApexControllerClass() {

        Set<Id> permissionSetIds = new Set<Id>();
        Set<Id> profileIds = new Set<Id>();
        String namespace = UTIL_Namespace.getNamespace();

        //find all profiles and permissions that provide access to apex controller class
        List<SetupEntityAccess> seas = [SELECT Id, Parent.Name, Parent.Profile.Id 
                                        FROM SetupEntityAccess 
                                        WHERE SetupEntityId in (SELECT Id 
                                                                FROM ApexClass 
                                                                WHERE Name = :APEX_CONTROLLER_CLASS_NAME 
                                                                AND NamespacePrefix = :namespace)];
        
        for (SetupEntityAccess sea : seas){
            //permission sets do not have profileIds
            if (sea.Parent.Profile.Id == null){
                if (sea.parent.id != null){
                    permissionSetIds.add(sea.parent.id);
                }
            } else {
                profileIds.add(sea.parent.profile.id);
            }
        }~
        
        //determine if permission sets that have access is assigned to user
        if (permissionSetIds.size()>0){
            List<PermissionSetAssignment> psa = [SELECT Id 
                                                 FROM PermissionSetAssignment
                                                 WHERE AssigneeId = :UserInfo.getUserId() 
                                                 AND PermissionSet.Id IN :permissionSetIds];
            if (psa.size()>0){
                return true;
            }
        }
        //determine if profiles that have access matches the user's profile
        if (profileIds.size()>0){
            if (profileIds.contains(userInfo.getProfileId())){
                return true;
            }
        }
        
        return false;
    }
}