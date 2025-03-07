@isTest
public class PCCTest {
    
    private static testMethod void testPCC(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Primary_Number__c = '98762342';
        insert acc;
        
        Project__c proj = new Project__c();         
        proj.Configuration__c='1.5 BHK';
        proj.Max_Budget__c=10000;
        proj.Min_Budget__c=10000;
        proj.Expiry_Days__c = 10;
        proj.name = 'ParkWest';
        proj.Project_Code__c = 'test';
        insert proj;
        
        Tower__c tw = new Tower__c();        
        tw.Name = 'Maple B';
        tw.project__c = proj.Id;
        insert tw;
        
        List<User> User = [Select Id, Name, IsActive from User where isActive = True];
        
        Channel_Partner__c cp = new  Channel_Partner__c();
        cp.Contact_Person__c = 'Test CP';
        cp.Sales_Manager__c = User[0].Id;
        cp.Channel_Relationship_Manager__c = User[0].Id;
        cp.Sales_Manager_s_Line_Manager__c = User[0].Id;
        cp.Channel_Relationship_Head__c = User[0].Id;
        insert cp;
        
        Opportunity objOpp = new Opportunity();
        objopp.Name = 'TestOpp';
        objopp.Accountid = acc.Id;
        objopp.CloseDate = System.today().addDays(30);
        objopp.StageName = 'Qualification';//'Unit Booked';
        objopp.Project__c = proj.Id;               
        insert objOpp;
        
        
        Unit__c objUnit = new Unit__c ();
        objUnit.name = 'testUnit1';
        objUnit.Project_Property_Type__c = 'Residential';
        objUnit.Carpet_Area__c = 1233;
        objUnit.Chargeable_Area__c = 1234; 
        objUnit.Balcony_Area_Sq_Ft__c = 123;
        objUnit.Project__c = proj.Id;
        objUnit.Tower__c = tw.Id;
        insert objUnit;
        Payment_Plan__c pp = new Payment_Plan__c();
        pp.NoofMilestones__c = 1;
        insert pp;
        
        Quotation__c objQuote1 = new Quotation__c();
        
        objQuote1.Opportunity__c = objOpp.Id;
        objQuote1.Payment_Plan__c = pp.Id;
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
        
        objQuote1.Car_Park_Type_1__c = 'Open';
        objQuote1.Car_Park_Count_1__c = 1;
        objQuote1.Earmarked_Type_1__c = 'Open';
        objQuote1.Earmarked_Count_1__c = 1;
        
        objQuote1.Unit__c = objUnit.Id;              
        insert objQuote1;
        
        Booking__c bk = new Booking__c();          
        bk.Quotation__c = objQuote1.Id;
        bk.Booking_Date__c = system.now();
        bk.Unit__c = objUnit.Id;
        bk.Project__c = proj.Id;
        bk.Source_of_Booking__c = 'Channel Partner';
        bk.Channel_Partner__c = cp.Id;   
        bk.Opportunity__c = objOpp.Id;
        bk.Agreement_Value__c = 3000000;  
        insert bk;
        Applicant_Details__c applicant = new Applicant_Details__c ();
        applicant.Name = 'New Man1';
        applicant.Salutation__c = 'Mr.';       
        applicant.DOB__c = system.today();
        applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        applicant.Pincode__c = 444444;
        applicant.Country__c = 'India';
        applicant.City__c = 'Nagpur'; 
        applicant.Applicant_Number__c = 'Primary Applicant';
        applicant.Mailing_Address__c = '101 Kumar Vastu';        
        applicant.Mailing_Country__c= 'India';
        applicant.Mailing_State__c = 'Gujarat';
        applicant.Mailing_City__c = 'Ahmedabad';
        applicant.State__c = 'Gujarat';   
        applicant.Mailing_Pincode__c = 123456;    
        applicant.Mobile_Number__c = '909090901';
        applicant.Email_Address__c = 'newman@justnow1.com'; 
        applicant.Booking__c = bk.Id;  
        applicant.Valid_Until_Passport__c = System.today().addDays(200);      
        insert applicant;
        
        
        Test.startTest();
        PageReference testPage = Page.PCCVFPAGE;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('bookingId',String.valueOf(bk.Id));
        PCC pcc = new PCC();
        SendPccAction.sendPCCs(new List<Id>{bk.Id});
        SendPccAction.sendPcc(bk.Id);
        S_NumberToWord.convertNumbertoWords(2134);
        S_NumberToWord.CurrencyToWordsFormatAED(222);
        S_NumberToWord.CurrencyToWordsFormatAED(222.2);
        S_NumberToWord.CurrencyToWordsFormat(222);
        S_NumberToWord.NumberToWords(22);
        Test.stopTest();
    }
    
}