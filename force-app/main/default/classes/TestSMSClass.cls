@isTest
private  Class TestSMSClass{
  @isTest  
    private static void CallSMS() {
        
        //create Account
        Account acc = createPATemplate('TestPA1' , 'testleada@xanadutest.com', '9876544441', '+91', false);
        
        //create Opportunity
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, 1);
        
        //create vendor
        Vendor__c vend = new Vendor__c();
        vend.Name = 'testsms';
        vend.Vendor_URL__c = 'http://msg.ad-ventura.ae/app/smsapi/index.php';
        vend.Vendor_Status__c = true;
        vend.Param_1_Name__c = 'key';
        vend.Param_1_Status__c = true;
        vend.Param_1_Value__c = '1425637452';
        
        vend.Param_2_Name__c = 'campaign';
        vend.Param_2_Status__c = true;
        vend.Param_2_Value__c = '7896';
        
        vend.Param_3_Name__c = 'routeid';
        vend.Param_3_Status__c = true;
        vend.Param_3_Value__c = '42';
        
        vend.Param_4_Name__c = 'type';
        vend.Param_4_Status__c = true;
        vend.Param_4_Value__c = 'text';
        
        vend.Param_5_Name__c = 'contacts';
        vend.Param_5_Status__c = true;
        
        vend.Param_6_Status__c = true;
        vend.Param_6_Name__c = 'senderid';
        vend.Param_6_Value__c = 'MSG ALERT';
        
        vend.Param_7_Name__c = 'msg';
        vend.Param_7_Status__c  = true;      
        
        vend.Param_8_Name__c = 'routeid';
        vend.Param_8_Status__c = true;
        vend.Param_8_Value__c = '78';
        insert vend;
        
        // create sms schedule sms
        SMS_Schedule_SMS_c__c ss  = createSMSRecord(oList[0].Id, acc.personMobilePhone);
    
    }   
@isTest     
    private static void CallSMSDubai() {
        
        //create Account
        Account acc1 = createPATemplate('TestPA2' , 'testlead2@xanadutest.com', '987654444', '+971', false);
        
        //create Opportunity
        List<Opportunity>  oList1 = createOpptyForAccount(acc1.Id, 1);
        
         //create vendor
        Vendor__c vend = new Vendor__c();
        vend.Name = 'testsms';
        vend.Vendor_URL__c = 'http://msg.ad-ventura.ae/app/smsapi/index.php';
        vend.Vendor_Status__c = true;
        
        vend.Param_1_Name__c = 'key';
        vend.Param_1_Status__c = true;
        vend.Param_1_Value__c = '7896gjkuko78';
        
        vend.Param_2_Name__c = 'campaign';
        vend.Param_2_Status__c = true;
        vend.Param_2_Value__c = '0560';
        
        vend.Param_3_Name__c = 'routeid';
        vend.Param_3_Status__c = true;
        vend.Param_3_Value__c = '42';
        
        vend.Param_4_Name__c = 'type';
        vend.Param_4_Status__c = true;
        vend.Param_4_Value__c = 'text';
        
        vend.Param_5_Name__c = 'contacts';
        vend.Param_5_Status__c = true;
        
        vend.Param_6_Status__c = true;
        vend.Param_6_Name__c = 'senderid';
        vend.Param_6_Value__c = 'MSG ALERT';
        
        vend.Param_7_Name__c = 'msg';
        vend.Param_7_Status__c  = true;      
        
        vend.Param_8_Name__c = 'routeid';
        vend.Param_8_Status__c = true;
        vend.Param_8_Value__c = '96';
        insert vend;
        
         // create sms schedule sms
        SMS_Schedule_SMS_c__c ss  = createSMSRecord(oList1[0].Id, acc1.personMobilePhone);
    
    }
    
     public static Account createPATemplate(String accName, String Email, String Mobile, String Code, Boolean isMaster) {
     List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
     Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordTypeId = personAccountRecordType[0].id, MasterRecord__c = isMaster, Country_Code__c = Code);
     insert a;
     return a;
  }
    
    public static List<Opportunity> createOpptyForAccount(Id  accId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', S_Budget_In_lacs__c = 5000000, closeDate=System.today());
      oList.add(o);            
    }
    insert oList;
    return oList;
  }
  
  public static SMS_Schedule_SMS_c__c createSMSRecord(Id oppId, String mobile){
       SMS_Schedule_SMS_c__c s = new SMS_Schedule_SMS_c__c();
       s.Context_Record__c = oppId;
       s.Immediate__c = True;
       s.Sender_Mobile__c= mobile;
       s.SMS_Long_text__c= 'Message from test class';
       insert s;
       return s;       
   }
}