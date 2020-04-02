@isTest
private class ccsBatch_TEST {

    @isTest
    static void testBatchUpdate() 
    {
        Account acct = new Account(Name='Test');
        insert acct;
        
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i=0 ;i <200;i++)
        {
            Opportunity opp = new Opportunity();
            opp.Name ='Name'+i;
            opp.CloseDate = Date.today();
            opp.StageName = 'Prospecting';
            opps.add(opp);
        }
        
        insert opps;
        
        Test.startTest();
        ccsBatch b = new ccsBatch();
        DataBase.executeBatch(b);             
        Test.stopTest();
        
        Opportunity oppResult = [SELECT Id, Name, npsp__In_Kind_Description__c
                                                 FROM Opportunity
                                                 WHERE Id =:opps[0].Id];
        
        system.assertEquals('Name0Updated', oppResult.Name);
        system.assertEquals('NPSPUpdated', oppResult.npsp__In_Kind_Description__c);
    }

}