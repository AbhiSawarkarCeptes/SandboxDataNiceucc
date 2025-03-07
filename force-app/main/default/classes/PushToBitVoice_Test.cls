@isTest
public Class PushToBitVoice_Test{
  public static testMethod void testPushToBitVoice() {
    Churned_Leads__c c = new Churned_Leads__c(Name = 'System Administrator');
    insert c;
    Test.startTest();
    Lead leadRecord = new Lead();
    leadRecord.FirstName = 'Sri';
    leadRecord.LastName = 'K';
    leadRecord.Email = 'sri.k@gmail.com';
    leadRecord.Status = 'Open';
    leadRecord.RDS_Country_Code__c = '971';
    leadRecord.Primary_Number__c = '8786534567';
    insert leadRecord;
    
    List<Lead> lstRecords = new list<Lead>();lstRecords.add(leadRecord);
    ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(lstRecords);
    ssc.setSelected(lstRecords);
    PushToBitVoice pbv = new PushToBitVoice(ssc);
    pbv.push();
    
    Test.stopTest();
  }
}