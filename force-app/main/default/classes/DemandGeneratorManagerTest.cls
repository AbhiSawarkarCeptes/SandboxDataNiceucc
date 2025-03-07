@isTest
public class DemandGeneratorManagerTest {
    
    @isTest
    private static void coverCreateMultipleDemand() {
        List<Account_Master__c> amList = new List<Account_Master__c>();
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'Trade Receivable';
        am1.Tax_Rate__c = 'GST 0%';
        am1.Type__c = 'Others';
        amList.add(am1);
        
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Discount/rebate credit note';
        am2.Tax_Rate__c = 'GST 0%';
        am2.Type__c = 'VAT';
        amList.add(am2);
        
        insert amList;
        
        Map<String, Id> recordMap = new Map<String,Id>();
        recordMap  = TestDataFactory.createMasterProject('Sobha'); 
        Id optyId = recordMap.get('OPPORTUNITY'); 
        Id unitId = recordMap.get('UNIT');
        Id towerid = recordMap.get('TOWER');
        Id projectid = recordMap.get('PROJECT');
        Id projectChargesId = recordMap.get('BASIC');
        
        Unit__c unitToUpdate = new Unit__c();
        unitToUpdate.Id = unitId;
        unitToUpdate.OC_Received__c = true;
        update unitToUpdate;
        
        Tower__c tower = [SELECT Id, Name FROM Tower__c WHERE Id = :towerid];
        
        Quotation__c quote = createQuotation(optyId, recordMap.get('PLAN'), unitId);     
        
        Payment_Milestones__c pm = createPaymentMilestone(quote.Id,tower.Id,projectChargesId);
                
        
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
        b.PCC_Status__c = 'Pending for Audit Approval';
        insert b; 
        
        quote.Booking__c = b.Id;
        update quote;      
        
        Receipt__c objRec = new Receipt__c();
        objRec.Project__c = projectId ;
        objRec.Opportunity__c = optyId;
        objRec.Project_Unit__c = unitId;
        objRec.Booking__c = b.Id;
        objRec.Receipt_No_Manual__c = '12';
        objRec.Receipt_Status__c = 'Processed';
        objRec.Mode__c = 'Cheque';
        objRec.Cheque_DD__c = '12';
        objRec.Remarks__c = true;
        objRec.Total_Amount__c = 100;
        objRec.Manual_Receipt_Date__c = System.today();
        objRec.Receipt_Date__c = System.today().addDays(-1);
        objRec.Cheque_DD_Date__c = System.today();
        objRec.Token_Amount_Receipt__c = true;
        objRec.On_Account_Money__c = 0;
        objRec.Currency__c = 'Indian Rupee';
        insert objRec; 
        
        b.Receipts__c = objRec.id;
        update b;
        
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = projectId ;
        r2.Project_Unit__c = unitId;
        r2.Opportunity__c = optyId;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Token_Amount_ST__c = true;
        r2.Total_Amount__c = 8400;
        r2.Booking__c = b.Id; 
        insert r2;    
        
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        Applicant_Details__c ad1 = new Applicant_Details__c();
        ad1.Name = 'A One';
        ad1.Type_Of_Applicant__c = 'Individual Buyer';
        ad1.Subtype_Of_Applicant__c = 'Indian National';
        ad1.One_Passport_Size_Color_Photograph__c = true;
        ad1.Permanent_Address__c = 'Perma Addressia';
        ad1.Email_Address__c = 'a1.one@gmail.com';
        ad1.Mobile_Number__c = '989898989';
        ad1.DOB__c = system.today().addMonths(-12);
        ad1.Booking__c = b.Id;
        applicantDetailsList.add(ad1);
        
        Applicant_Details__c ad2 = new Applicant_Details__c();
        ad2.Name = 'A Four';
        ad2.Type_Of_Applicant__c = 'Individual Buyer';
        ad2.Subtype_Of_Applicant__c = 'Indian National';
        ad2.One_Passport_Size_Color_Photograph__c = true;
        ad2.Permanent_Address__c = 'Perma Addressia';
        ad2.Email_Address__c = 'a2.one@gmail.com';
        ad2.Mobile_Number__c = '8080808080';
        ad2.DOB__c = system.today().addMonths(-12);
        ad2.Booking__c = b.Id;
        applicantDetailsList.add(ad2);
        
        Applicant_Details__c ad3 = new Applicant_Details__c();
        ad3.Name = 'A Three';
        ad3.Type_Of_Applicant__c = 'Individual Buyer';
        ad3.Subtype_Of_Applicant__c = 'Indian National';
        ad3.One_Passport_Size_Color_Photograph__c = true;
        ad3.Permanent_Address__c = 'Perma Addressia';
        ad3.Email_Address__c = 'a3.one@gmail.com';
        ad3.Mobile_Number__c = '9090909090';
        ad3.DOB__c = system.today().addMonths(-12);
        ad3.Booking__c = b.Id;
        applicantDetailsList.add(ad3);
        
        Applicant_Details__c ad4 = new Applicant_Details__c();
        ad4.Name = 'A Four';
        ad4.Type_Of_Applicant__c = 'Individual Buyer';
        ad4.Subtype_Of_Applicant__c = 'Indian National';
        ad4.One_Passport_Size_Color_Photograph__c = true;
        ad4.Permanent_Address__c = 'Perma Addressia';
        ad4.Email_Address__c = 'a3.one@gmail.com';
        ad4.Mobile_Number__c = '9090909090';
        ad4.DOB__c = system.today().addMonths(-12);
        ad4.Booking__c = b.Id;
        applicantDetailsList.add(ad4);
        
        Applicant_Details__c ad5 = new Applicant_Details__c();
        ad5.Name = 'A Five';
        ad5.Type_Of_Applicant__c = 'Individual Buyer';
        ad5.Subtype_Of_Applicant__c = 'Indian National';
        ad5.One_Passport_Size_Color_Photograph__c = true;
        ad5.Permanent_Address__c = 'Perma Addressia';
        ad5.Email_Address__c = 'a3.one@gmail.com';
        ad5.Mobile_Number__c = '9090909090';
        ad5.DOB__c = system.today().addMonths(-12);
        ad5.Applicant_Number__c = 'Primary Applicant';
        ad5.PancardNo__c = 'PA101010';
        ad5.Address_Proof_Document__c = 'Driving License';
        ad5.Address_Proof_Number__c = 'addkdljf';
        ad5.Booking__c = b.Id;
        applicantDetailsList.add(ad5);
        insert applicantDetailsList;
        
        quote.Booking__c = b.Id;
        
        update quote;
        
        Unit__c u = [Select Id, Name, Unit_Status__c from Unit__c where Id = :unitId];
        u.Unit_Status__c = 'Sold';
        u.Customers__c = optyId;
        u.Booking__c = b.Id;
        update u;
        
        Opportunity o = [Select Id, Name, S_Active__c, StageName from Opportunity where id =:optyId];
        o.StageName = 'Booking confirmed';
        o.S_Active__c = true;
        o.Unit__c = unitId;
        
        update o;
        test.StartTest();
        List<Demand__c> demandList = DemandGeneratorManager.createMultipleDemand(new Set<String>{pm.Id});
        DemandGeneratorManager.sendDemandToCustomer(new Set<String>{demandList[0].Id});
        test.StopTest();
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
    
    private static Payment_Milestones__c createPaymentMilestone (Id quote,Id TowerId,Id ProjectCharges) {
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
        pm.Invoice_Due_Date__c = System.Today();
        pm.is_demand_raised__c = false;
        pm.Collection_Status__c = 'Not Submitted';
        pm.Finance_Status__c = 'Not Started';
        pm.Audit_Status__c = 'Not Started';
        pm.CFO_Status__c = 'Not Started';
        pm.Milestone_Due_Date__c = System.today() +2 ;
        pm.C1_Amount__c = 1;
        pm.C1_IGST__c = 1;
        pm.C1_SGST__c = 1;
        pm.C1_CGST__c = 1;
        pm.C10_Amount__c = 1;
        pm.C10_IGST__c = 1;
        pm.C10_SGST__c = 1;
        pm.C10_CGST__c = 1;
        pm.C11_Amount__c = 1;
        pm.C11_CGST__c = 1;
        pm.C11_IGST__c = 1;
        pm.C11_SGST__c = 1;
        pm.C12_Amount__c = 1;
        pm.C12_CGST__c = 1;
        pm.C12_IGST__c = 1;
        pm.C12_SGST__c = 1;
        pm.C13_Amount__c = 1;
        pm.C13_CGST__c = 1;
        pm.C13_IGST__c = 1;
        pm.C13_SGST__c = 1;
        pm.C14_Amount__c = 1;
        pm.C14_CGST__c = 1;
        pm.C14_IGST__c = 1;
        pm.C14_SGST__c = 1;
        pm.C15_Amount__c = 1;
        pm.C15_CGST__c = 1;
        pm.C15_IGST__c = 1;
        pm.C15_SGST__c = 1;
        pm.C16_Amount__c = 1;
        pm.C16_CGST__c = 1;
        pm.C16_IGST__c = 1;
        pm.C16_SGST__c = 1;
        pm.C17_Amount__c = 1;
        pm.C17_CGST__c = 1;
        pm.C17_IGST__c = 1;
        pm.C17_SGST__c = 1;
        pm.C18_Amount__c = 1;
        pm.C18_CGST__c = 1;
        pm.C18_IGST__c = 1;
        pm.C18_SGST__c = 1;
        pm.C19_Amount__c = 1;
        pm.C19_CGST__c = 1;
        pm.C19_IGST__c = 1;
        pm.C19_SGST__c = 1;
        pm.C2_Amount__c = 1;
        pm.C2_IGST__c = 1;
        pm.C2_SGST__c = 1;
        pm.C2_CGST__c = 1;
        pm.C20_Amount__c = 1;
        pm.C20_CGST__c = 1;
        pm.C20_IGST__c = 1;
        pm.C20_SGST__c = 1;
        pm.C21_Amount__c = 1;
        pm.C21_CGST__c = 1;
        pm.C21_IGST__c = 1;
        pm.C21_SGST__c = 1;
        pm.C22_Amount__c = 1;
        pm.C22_CGST__c = 1;
        pm.C22_IGST__c = 1;
        pm.C22_SGST__c = 1;
        pm.C23_Amount__c = 1;
        pm.C23_CGST__c = 1;
        pm.C23_IGST__c = 1;
        pm.C23_SGST__c = 1;
        pm.C24_Amount__c = 1;
        pm.C24_CGST__c = 1;
        pm.C24_IGST__c = 1;
        pm.C24_SGST__c = 1;
        pm.C25_Amount__c = 1;
        pm.C25_CGST__c = 1;
        pm.C25_IGST__c = 1;
        pm.C25_SGST__c = 1;
        pm.C3_Amount__c = 1;
        pm.C3_IGST__c = 1;
        pm.C3_SGST__c = 1;
        pm.C3_CGST__c = 1;
        pm.C4_Amount__c = 1;
        pm.C4_IGST__c = 1;
        pm.C4_SGST__c = 1;
        pm.C4_CGST__c = 1;
        pm.C5_Amount__c = 1;
        pm.C5_IGST__c = 1;
        pm.C5_SGST__c = 1;
        pm.C5_CGST__c = 1;
        pm.C6_Amount__c = 1;
        pm.C6_IGST__c = 1;
        pm.C6_SGST__c = 1;
        pm.C6_CGST__c = 1;
        pm.C7_Amount__c = 1;
        pm.C7_IGST__c = 1;
        pm.C7_SGST__c = 1;
        pm.C7_CGST__c = 1;
        pm.C8_Amount__c = 1;
        pm.C8_IGST__c = 1;
        pm.C8_SGST__c = 1;
        pm.C8_CGST__c = 1;
        pm.C9_Amount__c = 1;
        pm.C9_IGST__c = 1;
        pm.C9_SGST__c = 1;
        pm.C9_CGST__c = 1;
        pm.Charge1Percentage__c = 1;
        pm.Charge10Percentage__c = 1;
        pm.Charge12Percentage__c = 1;
        pm.Charge11Percentage__c = 1;
        pm.Charge13Percentage__c = 1;
        pm.Charge14Percentage__c = 1;
        pm.Charge15Percentage__c = 1;
        pm.Charge16Percentage__c = 1;
        pm.Charge17Percentage__c = 1;
        pm.Charge19Percentage__c = 1;
        pm.Charge2Percentage__c = 1;
        pm.Charge20Percentage__c = 1;
        pm.Charge21Percentage__c = 1;
        pm.Charge22Percentage__c = 1;
        pm.Charge23Percentage__c = 1;
        pm.Charge24Percentage__c = 1;        
        pm.Charge8Percentage__c = 1;
        pm.Charge7Percentage__c = 1;
        pm.Charge6Percentage__c = 1;
        pm.Charge25Percentage__c = 1;
        pm.Charge4Percentage__c = 1;
        pm.Charge5Percentage__c = 1;
        pm.Charge3Percentage__c = 1;
        
        pm.Charge_1_Lookup__c = ProjectCharges;
        pm.Charge_10_Lookup__c = ProjectCharges;
        pm.Charge_11_Lookup__c = ProjectCharges;
        pm.Charge_12_Lookup__c = ProjectCharges;
        pm.Charge_13_Lookup__c = ProjectCharges;
        pm.Charge_14_Lookup__c = ProjectCharges;
        pm.Charge_15_Lookup__c = ProjectCharges;
        pm.Charge_16_Lookup__c = ProjectCharges;
        pm.Charge_17_Lookup__c = ProjectCharges;
        pm.Charge_18_Lookup__c = ProjectCharges;
        pm.Charge_19_Lookup__c = ProjectCharges;
        pm.Charge_2_Lookup__c = ProjectCharges;
        pm.Charge_20_Lookup__c = ProjectCharges;
        pm.Charge_21_Lookup__c = ProjectCharges;
        pm.Charge_22_Lookup__c = ProjectCharges;
        pm.Charge_23_Lookup__c = ProjectCharges;
        pm.Charge_24_Lookup__c = ProjectCharges;
        pm.Charge_25_Lookup__c = ProjectCharges;
        pm.Charge_3_Lookup__c = ProjectCharges;
        pm.Charge_4_Lookup__c = ProjectCharges;
        pm.Charge_5_Lookup__c = ProjectCharges;
        pm.Charge_6_Lookup__c = ProjectCharges;
        pm.Charge_7_Lookup__c = ProjectCharges;
        pm.Charge_8_Lookup__c = ProjectCharges;
        pm.Charge_9_Lookup__c = ProjectCharges;
        
        insert pm;        
        return pm;                  
    } 
}