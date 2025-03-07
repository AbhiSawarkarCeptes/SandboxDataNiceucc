public class InvocableBulkAccept {
    public class InputValues {
        
        @InvocableVariable(required=true label='List of ids for where clause only supports object ids' )
        public List<Id> ids;
        
        @InvocableVariable(required=true label='Action name' )
        public String actionName;
        
    }
    
    @InvocableMethod(label='UpdateRecordBasedOnIds')
    public static void BulkUpdateRecordList(List<InputValues> inputValue) {
        List<Id> ids = inputValue.get(0).ids; 
        String action = inputValue.get(0).actionName;
        DateTime currentTime = System.now();
        String userId = UserInfo.getUserId(); // Present user Id
        list<Business_Process_Step__c> UpdateList = new list<Business_Process_Step__c>();
        String status='Open';
        //query to retrieve only status as open records out of selected records
        String soqlQuery='SELECT Id,Sequence__c,Business_Process_Step__c.Business_Process__c,Accepted_Time__c,Final_Accepted_Time__c,Completed_Time__c,OwnerId,Status__c FROM Business_Process_Step__c WHERE Id IN : ids and Status__c=: status';
        Map<Id, Business_Process_Step__c> nextRecordMap = new Map<Id, Business_Process_Step__c>();
        system.debug(soqlQuery);
        
        
        
        switch on action {
            when 'Accept' {
                //try {
                    list<Business_Process_Step__c> ObjectList = database.query(soqlQuery);
                    for(Business_Process_Step__c bps : ObjectList){
                        System.debug('bps '+bps.Id);
                        bps.Final_Accepted_Time__c=currentTime;
                        if(bps.Accepted_Time__c==null){
                            bps.Accepted_Time__c=currentTime;
                        }
                        
                        bps.OwnerId=userId;
                        UpdateList.add(bps);
                    }
                    if(!UpdateList.isEmpty())
                    {
                        database.update(UpdateList, false); 
                        system.debug('Update list within approve: '+UpdateList);
                    }
                /*}
                catch (exception ex) {
                    system.debug(ex.getMessage());
                }*/
            }
            when 'Approve' {
                try {
                    list<Business_Process_Step__c> ObjectList = database.query(soqlQuery);
                    for(Business_Process_Step__c bps : ObjectList){
                        bps.Approval_Status__c = 'Approved';
                        
                        UpdateList.add(bps);
                        if (!nextRecordMap.containsKey(bps.Business_Process__c)) 
                        {
                            nextRecordMap.put(bps.Business_Process__c, bps);
                        }
                    }
                     system.debug('next Record Map: '+nextRecordMap);
                    if(!UpdateList.isEmpty())
                    {
                        database.update(UpdateList, false); 
                        //handleNextRecord(nextRecordMap);
                        system.debug('Update list within approve: '+UpdateList);
                    }
                }
                catch (exception ex) {
                    system.debug(ex.getMessage());
                }
            }
            when 'Reject' {
                list<Business_Process_Step__c> ObjectList = database.query(soqlQuery);
                    for(Business_Process_Step__c bps : ObjectList){
                        bps.Approval_Status__c = 'Rejected';
                        UpdateList.add(bps);
                    }
                update UpdateList;
            }
            
            
        }
    }
    
    /*public static void handleNextRecord(Map<Id, Business_Process_Step__c> recMap)
    {
        system.debug('Business_Process_Step__c map '+recMap);
        set<Id> parentIds= new set<Id>(recMap.keySet());
        //Map<Id, List<Business_Process_Step__c>> allRecsMap=new Map<Id, List<Business_Process_Step__c>>();
        String qry='SELECT Id,Business_Process_Step__c.Business_Process__c, Assigned_Time__c,Status__c,Sequence__c FROM Business_Process_Step__c WHERE Business_Process__c IN: parentIds';
        List<Business_Process_Step__c> recs=database.query(qry);
        List<Business_Process_Step__c> updateList= new List<Business_Process_Step__c>();
        for (Id idee:parentIds)
        {	
            Business_Process_Step__c recCheck= recMap.get(idee); 
            for(Business_Process_Step__c rec:recs)
            {
                if(rec.Business_Process__c==idee && rec.Sequence__c == recCheck.Sequence__c+1)
                { 
                    rec.Status__c='Open';
                    rec.Final_Assigned_Time__c=System.now();
                    if(rec.Assigned_Time__c==null){
                        rec.Assigned_Time__c=System.now();
                    }
                    
                    updateList.add(rec);                    
                }
            }
            //allRecsMap.put(idee,temp1);
        }
        system.debug('UpdateList '+UpdateList);
        if(!UpdateList.isEmpty())
            update updateList;
    }*/
    
    
}