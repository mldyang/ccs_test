global class ccsBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, npsp__In_Kind_Description__c FROM Opportunity';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
         for(Opportunity opp : scope)
         {
             opp.Name = opp.Name + 'Updated';  
             opp.npsp__In_Kind_Description__c  = 'NPSPUpdated';
         }
         update scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}