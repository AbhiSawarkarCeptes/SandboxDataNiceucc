@isTest
public class TestUpdateConsStageNew {

@isTest
private static void testPlannedCons(){

    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha');

    Test.startTest();
    PageReference pRef =  Page.UpdateConsStageNew;
    Test.setcurrentPage(pRef);
    Apexpages.currentPage().getParameters().put('Pid', recordMap.get('PROJECT'));    
    UpdateConsStageNew uc = new UpdateConsStageNew();
    uc.getTowerSelectList();
    uc.towerId = recordMap.get('TOWER');
    uc.getConstructionSelectList();
    uc.stageId = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    uc.updateType = 'plannedDate';
    uc.plannedDate = System.today().addDays(40);   
    uc.save();
    uc.cancel();
    uc.dummy();
    uc.refresh();
    
    UpdateConsStageNew uc1 = new UpdateConsStageNew();
    uc1.getTowerSelectList();
    uc1.towerId = recordMap.get('TOWER');
    uc1.getConstructionSelectList();
    uc1.stageId = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    uc1.save();
    
    UpdateConsStageNew uc2 = new UpdateConsStageNew();
    uc2.getTowerSelectList();
    uc2.towerId = recordMap.get('TOWER');
    uc2.getConstructionSelectList();
    uc2.stageId = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    uc2.updateType = 'plannedDate';
    uc2.save();
    Test.stopTest();
 }
 
 @isTest
private static void testActualCons(){

    Map<String, Id> recordMap = new Map<String,Id>();
    recordMap  = TestDataFactory.createMasterProject('Sobha'); 
    Id projCharges = recordMap.get('BASIC');
    Id consStage = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    
    Quotation__c quote = new Quotation__c();        
    quote.Opportunity__c = recordMap.get('OPPORTUNITY');
    quote.Payment_Plan__c = recordMap.get('PLAN');
    quote.Unit__c = recordMap.get('UNIT');
    quote.Basic_Original_PSF__c = 12;
    quote.Charge1Bucket__c = 'Agreement Value';
    quote.Charge1Name__c = 'Basic';
    quote.Charge1Value__c = 1123;
    
    quote.Charge2Bucket__c = 'Agreement Value';
    quote.Charge2Name__c = 'Floor Rise';
    quote.Charge2Value__c = 1123;
    
    quote.Charge3Bucket__c = 'Agreement Value';
    quote.Charge3Name__c = 'PLC';
    quote.Charge3Value__c = 1123;          
    insert quote;
    
    Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
    pm1.Charge_1_Lookup__c = projCharges;
    pm1.Project_Construction_Stages__c = consStage;
    update pm1;      
       
    Booking__c b = new Booking__c();
    b.Booking_Date__c = system.now().addDays(-10);
    b.Project__c = recordMap.get('PROJECT');
    b.Opportunity__c = recordMap.get('OPPORTUNITY');
    b.Unit__c = recordMap.get('UNIT');
    b.status__c = 'Processed';
    b.Quotation__c = quote.Id;
    b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
    b.Future_Correspondence_Contact__c = 'First Applicant';
    b.Agreement_Value__c = 6000000;
    b.Stage_of_Booking__c = 'Booked';
    insert b;
     
    Id unitId = recordMap.get('UNIT');
    Unit__c u = [SELECT Id, Booking__c, Unit_Status__c FROM Unit__c WHERE Id = :unitId];
    u.Booking__c = b.Id;
    u.Unit_Status__c = 'Sold';
    update u;
        
    Test.startTest();
    PageReference pRef1 =  Page.UpdateConsStageNew;
    Test.setcurrentPage(pRef1);
    Apexpages.currentPage().getParameters().put('Pid', recordMap.get('PROJECT'));    
    UpdateConsStageNew uc1 = new UpdateConsStageNew();
    uc1.getTowerSelectList();
    uc1.towerId = recordMap.get('TOWER');
    uc1.getConstructionSelectList();
    uc1.stageId = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    uc1.updateType = 'completionDate';
    uc1.dueDate = System.today(); 
    uc1.objattachment.name = 'Certificate';
    uc1.objattachment.body = Blob.valueOf('Architect Certificate'); 
    uc1.save();
       
    UpdateConsStageNew uc2 = new UpdateConsStageNew();
    uc2.getTowerSelectList();
    uc2.towerId = recordMap.get('TOWER');
    uc2.getConstructionSelectList();
    uc2.stageId = recordMap.get('PROJECTCONSTRUCTIONSTAGE1');
    uc2.updateType = 'completionDate';
    uc2.save();
    Test.stopTest();
 }
 
 private static Payment_Milestones__c createPaymentMilestone(Id quote) {
    
    Payment_Milestones__c pm = new Payment_Milestones__c();
    pm.Time_Period__c = 'Days';
    pm.Number_Of_Days__c = 0;
    pm.Milestone_Type_edit__c = 'Construction Linked';
    pm.Is_Combination_Milestone__c = false;
    pm.Quotation__c = quote;
    pm.Charge1Name__c = 'Basic';
    pm.Charge1Percentage__c = 5;
    pm.C1_Amount__c = 10000;          
    pm.C1_CGST__c = 12369;
    pm.C1_SGST__c = 0;
    pm.Milestone_Due_Date__c = System.today().addDays(60);
    pm.is_demand_raised__c = false;
    pm.Collection_Status__c = 'Not Submitted';
    pm.Finance_Status__c = 'Not Started';
    pm.Audit_Status__c = 'Not Started';
    pm.CFO_Status__c = 'Not Started';       
    insert pm;        
    return pm;                  
}       
}