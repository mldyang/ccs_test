@isTest
public with sharing class ServiceInfoUtils_TEST {
    @isTest
    static void testCreateServiceInfo() {
        Test.startTest();
        Service_Info__c newServiceInfo = ServiceInfoUtils.createServiceInfo('testService', 'key', 'value', false);

        System.assertEquals('testService', newServiceInfo.Service__c);
        System.assertEquals('key', newServiceInfo.Key__c);
        System.assertEquals('value', newServiceInfo.Value__c);
        System.assertEquals(false, newServiceInfo.Is_Secret__c);
        Test.stopTest();
    }

    @isTest
    static void testGetAllData() {
        TestUtils_TEST.createTestServiceInfoData();

        Test.startTest();

        Map<String, String> allServiceInfo = ServiceInfoUtils.getAllData('testService');


        System.assertEquals(2, allServiceInfo.size());

        System.assertEquals(true, allServiceInfo.containsKey('key1'));
        System.assertEquals(true, allServiceInfo.containsKey('key2'));

        System.assertEquals('value1', allServiceInfo.get('key1'));
        System.assertEquals('value2', allServiceInfo.get('key2'));
        Test.stopTest();
    }

    @isTest
    static void testGetSensitiveData() {
        TestUtils_TEST.createTestServiceInfoData();

        Test.startTest();
        Map<String, String> allServiceInfo = ServiceInfoUtils.getAllSensitiveData('testService');

        
        System.assertEquals(1, allServiceInfo.size());

        System.assertEquals(true, allServiceInfo.containsKey('key1'));

        System.assertEquals('value1', allServiceInfo.get('key1'));
        Test.stopTest();
    }

    @isTest
    static void testGetNonsensitiveData() {
        TestUtils_TEST.createTestServiceInfoData();

        Test.startTest();
        Map<String, String> allServiceInfo = ServiceInfoUtils.getAllNonsensitiveData('testService');

        
        System.assertEquals(1, allServiceInfo.size());

        System.assertEquals(true, allServiceInfo.containsKey('key2'));

        System.assertEquals('value2', allServiceInfo.get('key2'));
        Test.stopTest();
    }

    
}