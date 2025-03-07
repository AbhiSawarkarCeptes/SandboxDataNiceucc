@isTest
public Class ClickToDial_Test{
  public static testMethod void testAutoPopulateNumbers() {
    Test.startTest();
        Lead leadRecord = new Lead();
        leadRecord.lastName = 'Satish';
        leadRecord.MobilePhone = '8987898765';
        leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
        leadRecord.Primary_Number__c = '8976543456';
        leadRecord.Last_Call_Attempt_Status__c = 'visit proposed';
        insert leadRecord; 
        
        Lead_Auto_Convert_Status__c lacs = new Lead_Auto_Convert_Status__c();
        lacs.Name = 'visit proposed';
        insert lacs;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Number__c = '98762342';
        insert acc;
        
        List<BitVoice__c> bvList = new List<BitVoice__c>();
        BitVoice__c bvRec = new BitVoice__c();
        bvRec.Name = 'Make Calls';bvRec.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/makecall/yRdXznO2PqAsCx9con/';
        bvList.add(bvRec);
        
        BitVoice__c bvRec1 = new BitVoice__c();
        bvRec1.Name = 'CDR';bvRec1.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/cdr/yRdXznO2PqAsCx9con/';
        bvList.add(bvRec1);   
        
        BitVoice__c bvRec2 = new BitVoice__c();
        bvRec2.Name = 'Bulk Call';bvRec2.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/bulkdata';
        bvList.add(bvRec2);  
        insert bvList; 
        
        CDR_Temp__c  cdrTemp = new CDR_Temp__c();
        cdrTemp.Lead__c = leadRecord.id;
        cdrTemp.Phone_Number__c = '8987898765';
        cdrTemp.Completed__c = false;
        cdrTemp.UID__c = '1234';
        insert cdrTemp;
            
        ClickToDial.findObjectAPIName(leadRecord.id);
        ClickToDial.autoConvertLead(leadRecord.id);
   
    Test.stopTest();
  }
  
  public static testMethod void testAutoPopulateNumbers2() {
    Test.startTest();
    
        List<BitVoice__c> bvList = new List<BitVoice__c>();
        BitVoice__c bvRec1 = new BitVoice__c();
        bvRec1.Name = 'CDR';bvRec1.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/cdr/yRdXznO2PqAsCx9con/';
        bvList.add(bvRec1);
        insert bvList;
        
        Lead leadRecord = new Lead();
        leadRecord.lastName = 'Satish';
        leadRecord.MobilePhone = '8987898765';
        leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
        leadRecord.Primary_Number__c = '8976543456';
        leadRecord.Last_Call_Attempt_Status__c = 'visit proposed';
        insert leadRecord;
        
        CDR_Temp__c  cdrTemp = new CDR_Temp__c();
        cdrTemp.Lead__c = leadRecord.id;
        cdrTemp.Phone_Number__c = '8987898765';
        cdrTemp.Completed__c = false;
        cdrTemp.UID__c = '1234';
        insert cdrTemp;
        
        Test.setMock(HttpCalloutMock.class, new FetchCdrMock());
        ClickToDial.fetchCRD(String.valueOf(leadRecord.Id), String.valueOf(leadRecord.MobilePhone));
   
    Test.stopTest();
  }
  
  public static testMethod void testAutoPopulateNumbers3() {
      
    List<BitVoice__c> bvList = new List<BitVoice__c>();
    BitVoice__c bvRec2 = new BitVoice__c();
    bvRec2.Name = 'Bulk Call';bvRec2.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/bulkdata';
    bvList.add(bvRec2);  
    insert bvList; 
    
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PushToBitVoiceMock());
        ClickToDial.pushBulkCalls('[1234]');
    Test.stopTest();
  }
  
  public static testMethod void testAutoPopulateNumbers4() {
      
    List<BitVoice__c> bvList = new List<BitVoice__c>();
    BitVoice__c bvRec = new BitVoice__c();
    bvRec.Name = 'Make Calls';bvRec.URL__c = 'http://sobha-harland-jtndbmbkbr.dynamic-m.com:9253/app/api/makecall/yRdXznO2PqAsCx9con/';
    bvList.add(bvRec);  
    insert bvList; 
    
    Lead leadRecord = new Lead();
    leadRecord.lastName = 'Satish';
    leadRecord.MobilePhone = '8987898765';
    leadRecord.Last_Call_Attempt_Status__c = 'visit confirmed';
    leadRecord.Primary_Number__c = '8976543456';
    leadRecord.Last_Call_Attempt_Status__c = 'visit proposed';
    insert leadRecord;
    
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CallByIdMock());
        ClickToDial.callById(String.valueOf(leadRecord.Id));
    Test.stopTest();
  }
}