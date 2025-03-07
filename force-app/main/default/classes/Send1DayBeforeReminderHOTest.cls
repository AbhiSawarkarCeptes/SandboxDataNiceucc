@isTest
public class Send1DayBeforeReminderHOTest {
    @testSetup
    static void setupTestData() {
        user us = TestDataFactorySobha.createUser(null);
        insert us;

        Account testAccount = TestDataFactorySobha.createAccount(null);
        insert testAccount;
        
        Contact testContact = TestDataFactorySobha.createContact(null);
        insert testContact;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', Name = 'Test Project', PropStrength__Active__c = true, T_link_Demand_Days__c = 1, Transfer_Charges_Title_Transfer__c = 10, Transfer_Charges_No_Title_Transfer__c = 10);
        insert proj;
        
        PropStrength__Tower__c tower = new PropStrength__Tower__c(PropStrength__Tower_Name__c = 'T1 P1 Tower', PropStrength__Project_Name__c =  proj.Id, PropStrength__Tower_Code__c = 'A1',CRM_Executive__c = UserInfo.getUserId());
        insert tower;
        
        PropStrength__Property_Type__c propType = new PropStrength__Property_Type__c(PropStrength__Project__c = proj.Id, PropStrength__Active__c = true, PropStrength__Area__c = 5000, PropStrength__Pricing_Expire__c = false, PropStrength__Property_Type_Code__c = '3 BR Zazen');
        insert propType;
        
        PropStrength__Property__c prop = new PropStrength__Property__c(PropStrength__Tower__c  = tower.id, Requisite_Hold_Payment_Type__c = 'Amount', Requisite_Hold_Payment__c = 1000, RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get('Plots').getRecordTypeId(), PropStrength__Property_Type__c = propType.Id, PropStrength__Project_Name__c = proj.Id, PropStrength__Active__c = true,Annexure_Document_Uploaded__c=System.Today().addDays(-1));
        insert prop;
        
        PropStrength__Income_Charges__c inc = new PropStrength__Income_Charges__c(Name='Transfer Fee', PropStrength__Income_Charge_Code__c = 'Transfer Fee', PropStrength__Amount__c = 10, PropStrength__Additional_Service_Tax__c = 9.00, PropStrength__Service_Tax__c = 10.00, RecordTypeId = Schema.SObjectType.PropStrength__Income_Charges__c.getRecordTypeInfosByName().get('Fixed').getRecordTypeId(), PropStrength__Project__c=proj.Id, PropStrength__Active__c = TRUE, PropStrength__Tax_Type__c = 'Fixed', PropStrength__Type__c = 'Fixed', PropStrength__Category__c = 'Transfer Of Property');
        insert inc;
        
        PropStrength__Offer__c offer = new PropStrength__Offer__c(Payment_Method__c = 'Single', PropStrength__Is_Brokrage_Calculated__c = true, PropStrength__Transaction__c= true, PropStrength__Project__c = proj.Id, PropStrength__Property__c = prop.Id, PropStrength__Property_Type__c = propType.Id, PropStrength__Primary_Contact__c = testContact.Id);
        insert offer;
        
        PropStrength__Application_Booking__c testBooking = new PropStrength__Application_Booking__c(MOU_Executed__c = true, DSPA_Transaction_Exception__c=true,PropStrength__Property__c = prop.Id,DSPA_Executed__c = false,PropStrength__Offer__c= offer.Id,PropStrength__Booking_Date__c = System.Today().addDays(-1), PropStrength__Booking_Through__c = 'Direct', PropStrength__Total_Basic_Sales_Price__c = 10000, PropStrength__Project__c = proj.Id,
                                                                                             PropStrength__Status__c ='Audit Approved',PropStrength__Active__c = true,PropStrength__Applicant_Email__c ='Test@gmail.com',PropStrength__Primary_Customer__c = testContact.Id, Title_Deed_Transfer_Executed__c=TRUE,
                                                                                             MOU_Transaction_Exception__c = true,Title_Deed_Process_Exception__c = true);
        insert testBooking ; 
    }
    @isTest
    static void testSendEnvelopeMethod() {
        User user = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        System.runAs(user) {
            EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'Send_1_Day_Before_Reminder_HO',
            Name = 'Send 1 Day Before Reminder HO',
            TemplateType = 'text',
            Subject = 'Test Email Subject',
            FolderId = UserInfo.getUserId(),
            HtmlValue = '<html><body>Test Email Body</body></html>');            
        insert emailTemplate;
        }
        PropStrength__Application_Booking__c booking = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        List<PropStrength__Application_Booking__c> bookingList = new List<PropStrength__Application_Booking__c>{booking};
       
        Test.startTest();
        Send1DayBeforeReminderHO.sendEnvelopeMethod(bookingList);
        Test.stopTest();

         Integer finalEmailCount = Limits.getEmailInvocations();
         //System.assertEquals(initialEmailCount + 1, finalEmailCount, 'One email should be sent.');

    }
}