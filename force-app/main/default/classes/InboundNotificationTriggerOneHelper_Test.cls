@isTest
public class InboundNotificationTriggerOneHelper_Test {

    @isTest static void createEnquiryTest(){
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '4567890123', VCC1__Phone_Encrypted__c = '4567890123', Country_Code__c = '+91');
        insert testContact;
        
        VCC1__Inbound_Notification__c inno = new VCC1__Inbound_Notification__c();
        inno.VCC1__Agent_User__c = u.id;
        inno.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inno.VCC1__Dialed_Number__c = '1100220021';
        inno.VCC1__Record_Id__c = testcontact.id;
        inno.VCC1__Type__c = 'Call Start';
        inno.VCC1__Call_Type__c = 'Inbound';
        inno.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        inno.VCC1__Call_hopped__c = true;
        insert inno;
        
        List<VCC1__Inbound_Notification__c> newInboundNotificationList = new List<VCC1__Inbound_Notification__c>{inno};
        Test.startTest();
        InboundNotificationTriggerOneHelper.createEnquiry(newInboundNotificationList);
        Test.stopTest();
    }
}