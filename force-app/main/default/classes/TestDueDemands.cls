@isTest
public class TestDueDemands {
    @isTest
private static void demands2() {    
    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerId = recordMap.get('TOWER');
    Id projectId = recordMap.get('PROJECT');
    
    Tower__c tower = [SELECT Id, Name, Cluster__c,Project__c FROM Tower__c WHERE Id =:towerId];
    Unit__c uni = [SELECT Id,Project__c,Tower__r.Name FROM Unit__c WHERE Tower__c =: tower.iD];
    
    Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = projectId ;
    b.Opportunity__c = optyId;
    b.Unit__c = uni.ID;
    b.status__c = 'Processed';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;
    b.Stage_of_Booking__c = 'Booked';
    b.PCC_Status__c = 'Approved by Audit';
    b.Milestone_Due_Till_Date__c = 500000;
    b.Remainder_Notice__c = false;
  
    insert b;
          
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    pm1.Number_Of_Days__c = 15;
    update pm1; 
             
    quote.Booking__c = b.Id;
    update quote;
     Legal_Entity__c l = new Legal_Entity__c();
    l.Account_Holder__c = 'xyz';
    l.Account_Name_Flat_Cost__c = 'xyz';
    l.IFSC_Code_Flat_Cost__c = 'xyz';
    l.IFSC_Code_Service_Tax__c ='xyz';
    l.MICR_Code_Flat_Cost__c = 'fgh';
    l.Favouring__c = 'dfg';
    l.Bank_Name_Flat_Cost__c = 'tyu';
    insert l;
    Unit__c u = [Select Id, Name, Unit_Status__c,project__c from Unit__c where Id = :unitId];
    u.Unit_Status__c = 'Sold';
    u.Customers__c = optyId;
    u.Booking__c = b.Id;
      u.Legal_Entity__c = l.id;
    update u;
    
    Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
    o.StageName = 'Booking confirmed';
    o.S_Active__c = true;
    o.Unit__c = uni.Id;
    o.Other_Applicants_Email__c = 'yamini.jakka@test.com';
    o.Other_Applicants_Name__c = 'Yamini';
    update o;
   
    Test.startTest();
    Receipt__c r2 = new Receipt__c();
    r2.Cheque_DD_Amount_Rs__c = 8;
    r2.Cheque_DD__c = '9088881';
    r2.Cheque_DD_Date__c = system.today();
    r2.Project__c = projectId;
    r2.Project_Unit__c = unitId;
    r2.Opportunity__c = optyId;
    r2.CheckReceipt__c = true;
    r2.Physically_Cheque_Received__c = true;
    r2.Approval_Status__c = 'Approved';
    r2.Receipt_Date__c = system.today();
    r2.DraweeBank__c = 'CITI';
    r2.Total_Amount__c = 11;
    r2.Amount_Rs__c = 8;
    r2.Amount_Advanced__c = 0;
    r2.mode__c = 'Cheque';
    r2.Currency__c = 'Indian Rupee';
     r2.Registration_Collection_Control_Report__c = 2;
    r2.Booking__c = b.Id;
    insert r2;           

    Demand__c d = new Demand__c();
    d.Payment_Milestones__c = pm1.id;
    d.Quotation__c = quote.id;
    d.Booking__c = b.id;
    d.Invoice_Date__c = system.today();
    d.Due_Date__c = system.today()+14; 
    d.Debit_Demanded__c = 100000;
    d.Debit_Paid__c = 20;
    d.Debit_Type__c = 'Cheque Bounce';
    d.Debit_Tax_Demanded__c = 100;
    d.Debit_Tax_Paid__c = 20;
    d.Debit_SGST__c = 50;
    d.Demand_Status__c = 'Reversed';
    d.Agreement_Value_Paid__c=400;
    d.Service_Tax_on_Agreement_Value_Paid__c = 200;
    d.Debit_CGST__c = 50;
    d.Unit__c = uni.Id;
    insert d;
     Demand__c d1 = new Demand__c();
    d1.Payment_Milestones__c = pm1.id;
    d1.Quotation__c = quote.id;
    d1.Booking__c = b.id;
    d1.Invoice_Date__c = system.today();
    d1.Due_Date__c = system.today(); 
    d1.Debit_Demanded__c = 100000;
    d1.Debit_Paid__c = 20;
    d1.Debit_Type__c = 'Cheque Bounce';
    d1.Debit_Tax_Demanded__c = 100;
    d1.Debit_Tax_Paid__c = 20;
    d1.Debit_SGST__c = 50;
    d1.Demand_Status__c = 'Reversed';
    d1.Agreement_Value_Paid__c=400;
    d1.Service_Tax_on_Agreement_Value_Paid__c = 200;
    d1.Debit_CGST__c = 50;
    d1.Unit__c = uni.Id;
    insert d1;
	
    List<String> demandIdList = new List<String>();
    demandIdList.add(d.id);
    demandIdList.add(d1.id);
  	DueDemandsController.getDueDemands();
    DueDemandsController.demandActions('15days',demandIdList);
    DueDemandsController.demandActions('onduedate',demandIdList);
    DueDemandsController.sendEmail('15days',demandIdList);
    DueDemandsController.sendEmail('onduedate',demandIdList);
    DueDemandsController.amountToBePaid=0;
     System.debug('I am Total_On_Account_Money_With_Registration__c '+b.Total_On_Account_Money_With_Registration__c);
    System.debug('I am Total_On_Account_Money__c  '+b.Total_On_Account_Money__c );
    System.debug('I am Registration_Amount_Paid__c   '+b.Registration_Amount_Paid__c  );
    System.debug('I am Credit_Card_Charges_Colleceted__c   '+b.Credit_Card_Charges_Colleceted__c );
    System.debug('I am VAT_Reduction_From_PPP__c '+b.VAT_Reduction_From_PPP__c);
    System.debug('I am unit '+uni.Tower__r.Name);
    DueDemandsController.getDueDemandsForTower(tower.Name,uni.Project__c,'15days');
    DueDemandsController.getDueDemandsForTower(tower.Name,uni.Project__c,'onduedate');
    DueDemandsController.getDueDemandsForTower(tower.Name,uni.Project__c,'All');
    DueDemandsController.getProjects();
   
    Test.stopTest();            
}
       @isTest
private static void demands1() {    
    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id optyId = recordMap.get('OPPORTUNITY'); 
    Id unitId = recordMap.get('UNIT');
    Id towerId = recordMap.get('TOWER');
    Id projectId = recordMap.get('PROJECT');
     Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = projectId ;
    b.Opportunity__c = optyId;
    b.Unit__c = unitId;
    b.status__c = 'Processed';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;
    b.Stage_of_Booking__c = 'Booked';
    b.PCC_Status__c = 'Approved by Audit';
    b.Milestone_Due_Till_Date__c = 50000;
    b.Remainder_Notice__c = false;
    insert b;
          
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    pm1.Number_Of_Days__c = 15;
    update pm1; 
             
    quote.Booking__c = b.Id;
    update quote;
     Legal_Entity__c l = new Legal_Entity__c();
    l.Account_Holder__c = 'xyz';
    l.Account_Name_Flat_Cost__c = 'xyz';
    l.IFSC_Code_Flat_Cost__c = 'xyz';
    l.IFSC_Code_Service_Tax__c ='xyz';
    l.MICR_Code_Flat_Cost__c = 'fgh';
    l.Favouring__c = 'dfg';
    l.Bank_Name_Flat_Cost__c = 'tyu';
    insert l;
    Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
    u.Unit_Status__c = 'Sold';
    u.Customers__c = optyId;
    u.Booking__c = b.Id;
      u.Legal_Entity__c = l.id;
    update u;
    
    Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
    o.StageName = 'Booking confirmed';
    o.S_Active__c = true;
    o.Unit__c = unitId;
    o.Other_Applicants_Email__c = 'yamini.jakka@test.com';
    o.Other_Applicants_Name__c = 'Yamini';
    update o;
    
    List<Payment_Milestones__c> pmList = new List<Payment_Milestones__c>();
    pmList = [select id,name from Payment_Milestones__c where Quotation__c =: quote.id];
    Test.startTest();
   
    Receipt__c r1 = new Receipt__c();
    r1.Cheque_DD_Amount_Rs__c = 200000;
    r1.Cheque_DD__c = '908888';
    r1.Cheque_DD_Date__c = system.today();
    r1.Project__c = projectId;
    r1.Project_Unit__c = unitId;
    r1.Opportunity__c = optyId;
    r1.CheckReceipt__c = true;
    r1.Token_Amount_Receipt__c = true;
    r1.Physically_Cheque_Received__c = true;
    r1.Approval_Status__c = 'Approved';
    r1.Receipt_Date__c = system.today();
    r1.DraweeBank__c = 'Axis Bank';
    r1.Total_Amount__c = 80000;
    r1.Amount_Rs__c = 80000;
    r1.Amount_Advanced__c = 0;
    r1.mode__c = 'Cheque';
    r1.Currency__c = 'Indian Rupee';
    r1.Registration_Collection_Control_Report__c = 20000;
    r1.Booking__c = b.Id;
    insert r1;
    
    
     Demand__c d1 = new Demand__c();
    d1.Payment_Milestones__c = pmList[0].id;
    d1.Quotation__c = quote.id;
    d1.Booking__c = b.id;
    d1.Invoice_Date__c = system.today();
    d1.Due_Date__c = system.today()-50; 
    d1.Debit_Demanded__c = 1000;
    d1.Debit_Paid__c = 20;
    d1.Debit_Type__c = 'Cheque Bounce';
    d1.Debit_Tax_Demanded__c = 100;
	d1.Debit_Tax_Paid__c = 20;
    d1.Debit_SGST__c = 50;
    d1.Agreement_Value_Paid__c=400;
    d1.Service_Tax_on_Agreement_Value_Paid__c = 200;
    d1.Debit_CGST__c = 50;
//d1.OutStanding_days_calculated__c = '40 days';
    insert d1;
  
	
    List<string> demandIdList = new List<String>();
    List<Demand__c> demandList = [SELECT ID FROM Demand__c];
    for(Demand__c dList : demandList){
        demandIdList.add(dList.Id);
    }
    
     PageReference myVfPage = Page.DueDemand;
    Test.setCurrentPage(myVfPage);
        
    ApexPages.currentPage().getParameters().put('id',d1.Id);
    RemainderNoticecontroller ac = new RemainderNoticecontroller();
  	
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
private static Payment_Milestones__c createPaymentMilestone (Id quote) {
    
    Payment_Milestones__c pm = new Payment_Milestones__c();
    pm.Charge1Percentage__c = 1;
    pm.Time_Period__c = 'Days';
    pm.Number_Of_Days__c = 10;
    pm.Milestone_Type_edit__c = 'Date Linked';
    pm.Is_Combination_Milestone__c = false;
    pm.Quotation__c = quote;
    pm.Charge1Name__c = 'Basic';
    pm.Charge1Percentage__c = 5;
    pm.C1_Amount__c = 10000;  
    pm.C1_CGST__c = 12369;
    pm.C1_SGST__c = 2475;
    pm.is_demand_raised__c = false;
    pm.Collection_Status__c = 'Not Submitted';
    pm.Finance_Status__c = 'Not Started';
    pm.Audit_Status__c = 'Not Started';
    pm.CFO_Status__c = 'Not Started';       
    insert pm;        
    return pm;                  
 } 
}