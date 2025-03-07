@isTest(SeeAllData=True)
Private class testValidationfortimeslot {
    @isTest
    Private static void Validationfortimeslot(){
        Test.startTest();
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
       // Payment_Milestones__c pm = createPaymentMilestone(quote.Id);
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.now().addDays(-10);
        b.Project__c = projectId;
        b.Opportunity__c = optyId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Stage_of_Booking__c = 'Booked';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;    
        insert b;  
              
        Time_Slot_For_Handover__c ts =new Time_Slot_For_Handover__c();
        ts.Booking__c =b.Id;
        ts.CRM_Excutive__c ='Usman Sheikh';
        ts.Timings__c ='4 PM -5 PM';
        ts.QT_Keepout_Date__c = System.today();
        ts.Scheduled_Date__c= System.today().addDays(10);
        insert ts;
        
        Time_Slot_For_Handover__c ts1 =new Time_Slot_For_Handover__c();
        ts1.Booking__c =b.Id;	
        ts1.CRM_Excutive__c ='';
        ts1.Timings__c ='';
      //  ts.QT_Keepout_Date__c = System.today();
        ts1.Scheduled_Date__c= System.today().addDays(9);
       // insert ts1;
      
        ts.Booking__c =b.id;
        ts.CRM_Excutive__c ='Usman Sheikh';
        ts.Timings__c ='4 PM -5 PM';
        ts.QT_Keepout_Date__c = System.today();
        ts.Scheduled_Date__c= System.today().addDays(9);
        update ts;
        Test.stopTest();
    }  
    
    private static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
   
    Quotation__c objQuote1 = new Quotation__c();        
    objQuote1.Opportunity__c = opp ;
    objQuote1.Payment_Plan__c = pp ;
    objQuote1.Unit__c = ut1;
    objQuote1.Basic_Original_PSF__c = 12;
    objQuote1.Charge1Bucket__c = 'Agreement Value';
    objQuote1.Charge1Name__c = 'Basic';
    objQuote1.Charge1Value__c = 1123;
    objQuote1.Charge2Bucket__c = 'Agreement Value';
    objQuote1.Charge2Name__c = 'Floor Rise';
    objQuote1.Charge2Value__c = 1123;
    
    objQuote1.Charge3Bucket__c = 'Agreement Value';
    objQuote1.Charge3Name__c = 'PLC';
    objQuote1.Charge3Value__c = 1123;
           
    objQuote1.Charge4Bucket__c = 'Other Charges';
    objQuote1.Charge4Name__c = 'test';
    objQuote1.Charge4Value__c = 1123;
    objQuote1.Final_Approved_Date__c = System.today();
    insert objQuote1;
    return objQuote1;
} 
}