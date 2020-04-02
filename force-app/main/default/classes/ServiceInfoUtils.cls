public with sharing class ServiceInfoUtils {
    public static final String APP_CONST = 'applications';
    public static final String SERVICE_CONST = 'service';
    public static final String ISSECRET_CONST = 'issecret';
    public static final String KEY_CONST = 'key';
    public static final String VALUE_CONST = 'value';
    public static final String TRUE_CONST = 'true';
    public static final String FALSE_CONST = 'false';

    private static final Map<String, String> fieldMappingConstant = new Map<String, String>{KEY_CONST => 'Key__c', 
                                                                                            VALUE_CONST => 'Value__c', 
                                                                                            ISSECRET_CONST => 'Is_Secret__c',
                                                                                            SERVICE_CONST => 'Service__c'};

    public static Service_Info__c updateExistingServiceInfo(Service_Info__c serviceInfo, String service, String Key, String value, Boolean isSecret) {
        serviceInfo.Service__c = service;
        serviceInfo.Key__c = key;
        serviceInfo.Value__c = value;
        serviceInfo.Is_Secret__c = isSecret;
        serviceInfo.Service_Key__c = service + '::' + key;

        return serviceInfo;
    }

    public static Service_Info__c createServiceInfo(String service, String key, String value, Boolean isSecret) {
        // Do CRUD/FLS checks? 

        Service_Info__c serviceInfo = new Service_Info__c(Service__c = service, 
                                                        Key__c = key, 
                                                        Value__c = value, 
                                                        Is_Secret__c = isSecret,
                                                        Service_Key__c = service + '::' + key);

        return serviceInfo;
    }

    public static Service_Info__c updateExistingServiceInfo(Service_Info__c serviceInfo, Map<String, String> keyValuePairs) {
        for (String key : keyValuePairs.keyset()) {

            // Name space???
            Object value = keyValuePairs.get(key);
            serviceInfo = setValue(serviceInfo, key, value);
        }

        serviceInfo.Service_Key__c = serviceInfo.Service__c + '::' + serviceInfo.Key__c;

        return (Service_Info__c)serviceInfo;
    }

    public static Service_Info__c createServiceInfo(String service, Map<String, String> keyValuePairs) {
        Service_Info__c serviceInfo = new Service_Info__c();
        serviceInfo = setValue(serviceInfo, SERVICE_CONST, service);

        for (String key : keyValuePairs.keyset()) {

            // Name space???
            Object value = keyValuePairs.get(key);
            serviceInfo = setValue(serviceInfo, key, value);
        }

        serviceInfo.Service_Key__c = serviceInfo.Service__c + '::' + serviceInfo.Key__c;

        return serviceInfo;
    }

    public static List<Service_Info__c> createServiceInfo(String serviceName, List<Map<String, String>> serviceInfoListToInsert) {
        List<Service_Info__c> newServiceInfoListToInsert = new List<Service_Info__c>();

        for (Map<String, String> serviceInfoMap : serviceInfoListToInsert) {
            Service_Info__c newServiceInfo = new Service_Info__c();
            newServiceInfo = setValue(newServiceInfo, SERVICE_CONST, serviceName);

            for (String key : serviceInfoMap.keyset()) {

                // Name space???
                Object value = serviceInfoMap.get(key);
                newServiceInfo = setValue(newServiceInfo, key, value);
            }

            newServiceInfo.Service_Key__c = newServiceInfo.Service__c + '::' + newServiceInfo.Key__c;

            newServiceInfoListToInsert.add(newServiceInfo);
        }

        return newServiceInfoListToInsert;
    }
    

    public static String getValue(String service, String key) {
        // Do CRUD/FLS checks? 

        Map<String, String> serviceInfoMapping = getAllData(service);
        
        if (!serviceInfoMapping.isEmpty() && serviceInfoMapping.containsKey(key)) {
            return serviceInfoMapping.get(key);
        }

        return null;
    }

    public static Map<String, String> getAllData(String service) {
        
        // Do CRUD/FLS checks? 
        Map<String, string> serviceInfoMapping = new Map<String, String>();

        // If the service mapping is not cached, query for it, build the map, cache it, return it
        List<Service_Info__c> queriedServiceInfoList = queryServiceInfo(service, null);
        
        serviceInfoMapping = buildServiceInfoMap(queriedServiceInfoList);

        return serviceInfoMapping;
    }

    public static Map<String, String> getAllSensitiveData(String service) {
        // Do CRUD/FLS checks? 
        Map<String, string> serviceInfoMapping = new Map<String, String>();

        // If the service mapping is not cached, query for it, build the map, cache it, return it
        List<Service_Info__c> queriedServiceInfoList = queryServiceInfo(service, true);
        
        serviceInfoMapping = buildServiceInfoMap(queriedServiceInfoList);

        return serviceInfoMapping;
    }

    public static Map<String, String> getAllNonsensitiveData(String service) {
        // Do CRUD/FLS checks?
        Map<String, string> serviceInfoMapping = new Map<String, String>();

        // If the service mapping is not cached, query for it, build the map, cache it, return it
        List<Service_Info__c> queriedServiceInfoList = queryServiceInfo(service, false);
        
        serviceInfoMapping = buildServiceInfoMap(queriedServiceInfoList);

        return serviceInfoMapping;
    }

    public static Map<String, string> buildServiceInfoMap(List<Service_Info__c> queriedServiceInfoList) {
        Map<String, string> serviceInfoMapping = new Map<String, string>();

        for (Service_Info__c serviceInfo : queriedServiceInfoList) {
            serviceInfoMapping.put(serviceInfo.Key__c, serviceInfo.Value__c);
        }

        return serviceInfoMapping;
    }

    public static List<Service_Info__c> queryServiceInfo(String service, Boolean isSensitive) {
        return queryServiceInfo(new List<String>{service}, isSensitive);
    }

    public static List<Service_Info__c> queryServiceInfo(List<String> serviceList, Boolean isSensitive) {

        // Do we need to care about namespace????
        String serviceInfoQueryString = 'SELECT Key__c, Service__c, Value__c, Is_Secret__c ' + 
                                        'FROM Service_Info__c ';

        String whereClause = 'WHERE Service__c in: serviceList ';
        String limitClause = 'Limit 25000';


        if (isSensitive != null) {
            whereClause += 'AND Is_Secret__c = ' + String.valueOf(isSensitive) + ' ';
        }

        serviceInfoQueryString = serviceInfoQueryString + whereClause + limitClause;


        List<Service_Info__c> queriedServiceInfo = Database.query(serviceInfoQueryString);

        return queriedServiceInfo;
    }

    public static Service_Info__c setValue(Service_Info__c serviceInfo, String key, Object value) {

        if (key.trim().toLowerCase() == ISSECRET_CONST) {
            if (((String)value).trim().toLowerCase() != TRUE_CONST && ((String)value).trim().toLowerCase() != FALSE_CONST) {
                throw new JSONException();
            }

            value = Boolean.valueOf(value);
        }

        serviceInfo.put(fieldMappingConstant.get(key.trim().toLowerCase()), value);

        return serviceInfo;
    }
}