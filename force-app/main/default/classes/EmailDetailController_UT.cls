@isTest
public class EmailDetailController_UT {
    public static testMethod void EmailDetail() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        
        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress12@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2325t';
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;
        
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Contact__c = con.id;
        eml.PropStrength__Subject__c ='test email';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        insert eml;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(eml);
        EmailDetailController controller = new EmailDetailController(stdController);
        
        controller.updateStatus();
        controller.checkParentObjType();
        controller.reply();
        controller.draft();
        controller.replyToAll();
        controller.forward();
        Test.stopTest();
    }
}