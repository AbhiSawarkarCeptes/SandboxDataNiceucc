@isTest
private  Class ProcessMissedCallsSchedular_Test{
    public static testMethod void testProcessMissedCallsSchedular() {
    Test.startTest();
      
    Lead leadRecord = new Lead();
    leadRecord.lastName = 'Satish';
    leadRecord.MobilePhone = '8987898765';
    leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
    leadRecord.Primary_Number__c = '98762342';
    leadRecord.Latest_Next_Action_Date__c = system.today() + 2;
    insert leadRecord;
    
    List<BitVoice__c> bvList = new List<BitVoice__c>();
    BitVoice__c  bv = new BitVoice__c();
    bv.Name = 'ClearCallback';
    bv.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/clearcallback/yRdXznO2PqAsCx9con/';
    bvList.add(bv);
    
    BitVoice__c  bv1 = new BitVoice__c();
    bv1.Name = 'Missed Calls';
    bv1.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/missedcdr/yRdXznO2PqAsCx9con';
    bvList.add(bv1); 
    
    BitVoice__c  bv2 = new BitVoice__c();
    bv2.Name = 'Callback';
    bv2.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/callback';
    bvList.add(bv2);

    insert bvList;
    

    Test.setMock(HttpCalloutMock.class, new PushToBitVoiceMock());
    ProcessMissedCallsSchedular.callBack(leadRecord.id);
    ProcessMissedCallsSchedular.clearCallBack('98762342');
    
    String json = '[{\"mid\":\"100\",\"number\":\"042924333\",\"mtime\":\"1557313211\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"},{\"mid\":\"101\",\"number\":\"043555582\",\"mtime\":\"1557641699\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"1\"},{\"mid\":\"102\",\"number\":\"0564017612\",\"mtime\":\"1558000832\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"}]';
    List<MissedCallsParser> r = MissedCallsParser.parse(json);
    MissedCall__c m = ProcessMissedCallsSchedular.createRecord(r[0]);
    
    //ProcessMissedCallsSchedular p = new ProcessMissedCallsSchedular();
    //p.execute(null);
    
    /*
    ProcessMissedCallsSchedular.callBack(leadRecord.id);
    ProcessMissedCallsSchedular.clearCallBack('8987898765');
    ProcessMissedCallsSchedular.process();
     String json = '[{\"mid\":\"100\",\"number\":\"042924333\",\"mtime\":\"1557313211\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"},{\"mid\":\"101\",\"number\":\"043555582\",\"mtime\":\"1557641699\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"1\"},{\"mid\":\"102\",\"number\":\"0564017612\",\"mtime\":\"1558000832\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"}]';
        List<MissedCallsParser> r = MissedCallsParser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        MissedCallsParser objMissedCallsParser = new MissedCallsParser(System.JSON.createParser(json));
    
    MissedCall__c mc = ProcessMissedCallsSchedular.createRecord(objMissedCallsParser);  */
    Test.stopTest();
    }
    
    public static testMethod void testProcessMissedCallsSchedular2() {
        Test.startTest();
            Lead leadRecord = new Lead();
            leadRecord.lastName = 'Satish';
            leadRecord.MobilePhone = '8987898765';
            leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
            leadRecord.Primary_Number__c = '98762342';
            leadRecord.Latest_Next_Action_Date__c = system.today() + 2;
            insert leadRecord;
            
            List<BitVoice__c> bvList = new List<BitVoice__c>();
            BitVoice__c  bv = new BitVoice__c();
            bv.Name = 'ClearCallback';
            bv.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/clearcallback/yRdXznO2PqAsCx9con/';
            bvList.add(bv);
            
            BitVoice__c  bv1 = new BitVoice__c();
            bv1.Name = 'Missed Calls';
            bv1.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/missedcdr/yRdXznO2PqAsCx9con';
            bvList.add(bv1); 
            
            BitVoice__c  bv2 = new BitVoice__c();
            bv2.Name = 'Callback';
            bv2.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/callback';
            bvList.add(bv2);
        
            insert bvList;
            Test.setMock(HttpCalloutMock.class, new ProcessMock());
            ProcessMissedCallsSchedular.process();
        Test.stopTest();
    }
}