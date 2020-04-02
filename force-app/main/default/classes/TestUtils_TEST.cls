@isTest(isParallel=true)
public with sharing class TestUtils_TEST {
    
    /**
     * @description get mock payment event to use in unit tests
     * @param String currencyCode, USD or other currency code
     * @param Integer amount, payment amount
     * @param Date paymentDate, payment date
     * @param String firstName, first name 
     * @param String lastName, last name
     * @param String email, email
     * @return PaymentEvent
     */
    public static PaymentEvent getPaymentEventMock(String currencyCode, Integer amount, Date paymentDate, 
                                                            String firstName, String lastName, String email) {

        // payment intent && payload
        PaymentEvent.PaymentIntent intent = new PaymentEvent.PaymentIntent();
        intent.amount = amount;
        intent.currencyCode = currencyCode;
        intent.paymentDate = paymentDate;
        intent.firstName = firstName;
        intent.lastName = lastName;
        intent.email = email;
        intent.paymentSource = new PaymentEvent.PaymentSource();
        intent.paymentTransaction = new PaymentEvent.PaymentTransaction();

        // payment payload
        PaymentEvent.Payload payload = new PaymentEvent.Payload();
        payload.paymentIntent = intent;        

        // payment header
        PaymentEvent.Header header = new PaymentEvent.Header();        

        // payment userInfo
        PaymentEvent.UserInfo userInfo = new PaymentEvent.UserInfo();

        // create PaymentEvent instance
        PaymentEvent pe = new PaymentEvent();
        pe.Payload = payload;
        pe.UserInfo = userInfo;
        pe.Header = header;

        return pe;

    }

    /**
     * @description get an instance of data lake api response
     * @param String key
     * @param String merchantId
     * @param String offset
     * @param String shardId
     * @param String type
     * @param String responseValue
     * @return DataLakeApiResponse
     */
    public static DataLakeApiResponse getDataLakeApiResponse(String key, String merchantId, String offset, 
                                                                String shardId, String type, String responseValue ) {

        DataLakeApiResponse response = new DataLakeApiResponse();
        response.key = key;
        response.merchant_id = merchantId;
        response.offset = offset;
        response.shard_id = shardId;
        response.timestamp = DateTime.now();
        response.type = type;
        response.value = responseValue;
        
        return response;

    }

    /**
     * @description get an instance of DataChangeNotification using info passed by parameter
     * @param String topic
     * @param List<String> lShards
     * @return DataChangeNotification
     */
    public static ChangeNotificationController.DataChangeNotification getDataChangeNotification(
                                                                                            String topic, 
                                                                                            List<String> lShards
                                                                                        ) {
        
        // create payload
        ChangeNotificationController.DataChangeNotificationPayload dcnPayload = 
                                new ChangeNotificationController.DataChangeNotificationPayload();
        dcnPayload.start_time = System.now().addDays(-1);
        dcnPayload.end_time = System.now();
        dcnPayload.changed_shards = lShards;
        
        // create change notification controller
        ChangeNotificationController.DataChangeNotification dcn = 
                                new ChangeNotificationController.DataChangeNotification();
        dcn.payload = dcnPayload;
        dcn.topic = topic;        
		// return 
        return dcn;
        
    }
    
    /**
	* @description create User records
	* @param Id User profile Id
	* @param Integer number of records to create
	* @param Boolean should records be inserted
	* @return List<User>
	*/
    public static List<User> createUser(Id profileId, Integer numberOfUsers, Boolean doInsert) {
        String randomName = string.valueOf(Datetime.now()).replace('-', '').replace(':', '').replace(' ','');
        
        List<User> newUsers = new List<User>();
        for(Integer x=0; x<numberOfUsers; x++){
            User u = new User(
                ProfileId = profileId,
                FirstName = 'Test',
                LastName = 'User' + x,
                Alias = 'alias' + x,
                Email = 'testStdUser@test.com',
                Username = 'testUser' + randomName + x + '@test.com',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey ='en_US');
            newUsers.add(u);
        }
        if (doInsert){
            insert newUsers;
        }
        return newUsers;
    }

    public static void createTestServiceInfoData() {
        List<Service_Info__c> newServiceInfoList = new List<Service_Info__c>();

        Service_Info__c newServiceInfo1 = ServiceInfoUtils.createServiceInfo('testService', 'key1', 'value1', true);
        Service_Info__c newServiceInfo2 = ServiceInfoUtils.createServiceInfo('testService', 'key2', 'value2', false);

        newServiceInfoList.add(newServiceInfo1);
        newServiceInfoList.add(newServiceInfo2);

        insert newServiceInfoList;
    }

    public static void createTestServiceInfoData(String service, String key, String value, Boolean isSecret) {
        Service_Info__c newServiceInfo = ServiceInfoUtils.createServiceInfo(service, key, value, isSecret);

        insert newServiceInfo;
    }
}