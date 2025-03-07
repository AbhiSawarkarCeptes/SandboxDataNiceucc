@isTest
public class N_BookingApproverTest{

@isTest
private static void testGetBookingList(){
 Project__c pro;
 Unit__c unit1;
 Unit__c unit2;
 Opportunity opty1;
 ProjectCharges__c projchrg1;
 Payment_Plan__c paymentplan;
 Quotation__c quotation;
 //Booking__c book;
 Booking__c book1;
 Receipt__c receipt;
 
 pro = TestDataFactory.createProject('Sobha_project', '123'); // create project
 List<Cluster__c> cList = TestDataFactory.createClusters(3, pro.Id); // create cluster
       
 List<Tower__c> tList = TestDataFactory.createTowers(4, pro.Id); // create tower
 
 unit1 = new Unit__c();
 List<Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, pro.Id); // create unit
 unit1 = uList[0];
 unit1.Unit_Status__c = 'Booked';
 update unit1;
 
 unit2 = new Unit__c();
 unit2 = uList[1];
 
 Account acc = TestDataFactory.createPATemplate('Test1 Test2', 'test12@stetig.in','1234567891',false); // create account
 
 opty1 = new Opportunity(); // create opty
 opty1.Project__c = pro.Id;
 opty1.name = 'Test1';
 opty1.StageName = 'Open';
 opty1.Unit__c = unit1.Id;
 opty1.CloseDate = system.today().adddays(5);
 opty1.Status__c = 'Active';
 opty1.AccountId = acc.Id;
 opty1.Sales_Manager__c = 'SM2@g.com';
 insert opty1;
 
 projchrg1 = new ProjectCharges__c(); // create projectcharges
 projchrg1.name = 'Basic';
 projchrg1.Active__c = true;
 projchrg1.Project__c = pro.id;
 projchrg1.Calculatedas__c = 'Rate list at Unit level';
 projchrg1.ChargeBucket__c = 'Agreement Value';
 projchrg1.Taxable__c = 67.0;
 projchrg1.SGST__c = 9.0;
 projchrg1.CGST__c = 9.0;
 projchrg1.IGST__c = 0.0;
 insert projchrg1; 
 
 paymentplan = new  Payment_Plan__c(); // create payment plan
 paymentplan.name = 'Standard Plan';
 paymentplan.Plan_Code__c = '003';
 paymentplan.Tower__c = tList[0].id;
 paymentplan.Project__c = pro.id; 
 paymentplan.NoofMilestones__c = 25;
 paymentplan.Charge1Name__c = 'Basic';
 paymentplan.Charge_1_Total__c = 100;
 insert paymentplan;
 
 quotation = new Quotation__c(); // create quotation
 quotation.Quote_Status__c = 'Valid';
 quotation.Payment_Plan__c = paymentplan.id;
 quotation.Unit__c = unit1.Id;
 quotation.Opportunity__c = opty1.Id;
 quotation.Token_Amount__c =110000;
 quotation.ST_Token_Amount__c = 1000;
 quotation.Allow_booking_without_full_token__c = TRUE;
 quotation.Total_Agreement_Value_Bucket__c = 60422880;
 quotation.SGST_on_Total_Agreement_Value_Bucket__c = 2537761;
 quotation.CGST_on_Total_Agreement_Value_Bucket__c = 100000;
 quotation.IGST_on_Total_Agreement_Value_Bucket_del__c = 0;
 quotation.Car_Park_Type_1__c = 'Tandem';
 quotation.Car_Park_Type_2__c = 'Open';
 quotation.Car_Park_Type_3__c = 'Stack';
 quotation.Car_Park_Count_1__c = 1;
 quotation.Car_Park_Count_2__c = 1;
 quotation.Car_Park_Count_3__c = 1;
 insert quotation;
 
 book1 = new Booking__c();
 book1.Project__c =  pro.id; 
 book1.Opportunity__c = opty1.Id; 
 book1.Quotation__c = quotation.Id;
 book1.Booking_Date__c = System.Today();
 book1.Verification_status__c = 'Submitted';
 book1.Unit__c = unit1.Id;
 book1.Booking_Approver_Audit__c = 'Not Started';
 book1.Verification_status__c = 'Accepted';
 book1.Status__c  = 'Booking In Process';
 book1.Stage_of_Booking__c = 'Booked';
 book1.Agreement_Value__c = 3000000; 
 insert book1;
 
 receipt = new Receipt__c();
 receipt.Receipt_Status__c = 'Cleared';
 receipt.Total_Amount__c = 300000;
 receipt.Amount_Rs__c = 300000;
 receipt.Currency__c = 'AED';
 receipt.Booking__c = book1.Id;
 receipt.Opportunity__c = opty1.Id;
 receipt.Project__c =  pro.id; 
 receipt.Project_Unit__c = unit1.Id;
 insert receipt;
  
  test.startTest();
  
  pageReference pageRef = page.N_BookingApproverAuditPage;
  Test.setCurrentPage(pageRef);
  N_BookingApproverAuditController bookapprover = new N_BookingApproverAuditController();  
  bookapprover.rwList[0].b.Select_All_Audit__c = true;
  bookapprover.rwList[0].selectedVal = 'Rejected';
  bookapprover.rwList[0].comment = 'Rejected';
  bookapprover.Save(); 
  bookapprover.Back();
  test.stopTest();  
 }
}