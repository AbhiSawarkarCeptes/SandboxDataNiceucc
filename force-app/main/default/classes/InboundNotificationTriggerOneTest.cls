@isTest
public class InboundNotificationTriggerOneTest {
    static testMethod void notifyMethod() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        User us = new User(Alias = 'newUser', Email = 'neaer@gmail.com', 
                            EmailEncodingKey='UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', ProfileId = p.Id, Phone='4567890121',
                            TimeZoneSidKey='America/Los_Angeles', UserName='neadcscwr@testorg.com');
        insert us;
        
        Country_Code_Master__c codeMaster = new Country_Code_Master__c();
        codeMaster.Country_Name__c = 'India';
        codeMaster.Country_Code__c = '+91';
        codeMaster.Phone_length__c = 13;
        insert codeMaster;
        
        Contact testContact = new Contact(LastName = 'Test Contact', Phone = '4567890123', VCC1__Phone_Encrypted__c = '4567890123', Country_Code__c = '+91');
        insert testContact;
        
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', 
                                                                        DLD_Executive__c = UserInfo.getUserId(), 
                                                                        Name = 'Test Project', 
                                                                        PropStrength__Active__c = true, 
                                                                        T_link_Demand_Days__c = 1);
        insert proj;
        
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = testContact.Id;
        enq.PropStrength__Project__c = proj.Id;
        enq.Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert enq; 
        
        VCC1__Inbound_Notification__c inno = new VCC1__Inbound_Notification__c();
        inno.VCC1__Agent_User__c = us.id;
        inno.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inno.VCC1__Dialed_Number__c = '1100220021';
        inno.VCC1__Record_Id__c = testcontact.id;
        inno.VCC1__Type__c = 'Call Start';
        inno.VCC1__Call_Type__c = 'Inbound';
        inno.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        inno.VCC1__Call_hopped__c = true;
        insert inno;
        
        VCC1__Inbound_Notification__c inbo = new VCC1__Inbound_Notification__c();
        inbo.VCC1__Agent_User__c = us.id;
        inbo.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inbo.VCC1__Dialed_Number__c = '1100220021';
        inbo.VCC1__Record_Id__c = testcontact.id;
        inbo.VCC1__Type__c = 'Call End';
        inbo.VCC1__Call_Type__c = 'Inbound';
        inbo.VCC1__Call_id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        insert inbo;
        System.assert(inbo.id != null);
        
        VCC1__Call_Record__c vcr = new VCC1__Call_Record__c();
        vcr.VCC1__Call_Type__c = 'Inbound';
        vcr.VCC1__Status__c = 'Received';
        vcr.VCC1__Call_Id__c = 'u33hbuwc-cbhuwc-wdc82e3edb-ach982h';
        vcr.VCC1__Contact__c = testcontact.id;
        vcr.VCC1__Recording_URL__c = 'www.google.com';
        vcr.VCC1__Call_Start_IBN__c = inno.Id;
        vcr.VCC1__Call_End_IBN__c = inbo.Id;
        insert vcr;
        
        VCC1__Inbound_Notification__c innos = new VCC1__Inbound_Notification__c();
        innos.VCC1__Agent_User__c = us.id;
        innos.VCC1__Calling_Number_Encrypted__c = '4567890123';
        innos.VCC1__Dialed_Number__c = '1100220021';
        innos.VCC1__Record_Id__c = testcontact.id;
        innos.VCC1__Type__c = 'Call Start';
        innos.VCC1__Call_Type__c = 'Outbound';
        innos.VCC1__Call_id__c = 'u33hwc-cbhuwc';
        innos.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert innos;
        
        VCC1__Inbound_Notification__c inboe = new VCC1__Inbound_Notification__c();
        inboe.VCC1__Agent_User__c = us.id;
        inboe.VCC1__Calling_Number_Encrypted__c = '4567890123';
        inboe.VCC1__Dialed_Number__c = '1100220021';
        inboe.VCC1__Record_Id__c = testcontact.id;
        inboe.VCC1__Type__c = 'Call End';
        inboe.VCC1__Call_Type__c = 'Outbound';
        inboe.VCC1__Call_id__c = 'u33hwc-cbhuwc';
        inboe.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert inboe;
        System.assert(inbo.id != null);
        
        VCC1__Call_Record__c vcrRec = new VCC1__Call_Record__c();
        vcrRec.VCC1__Call_Type__c = 'Outbound';
        vcrRec.VCC1__Status__c = 'Received';
        vcrRec.VCC1__Call_Id__c = 'u33hwc-cbhuwc';
        vcrRec.VCC1__Contact__c = testcontact.id;
        vcrRec.VCC1__Recording_URL__c = 'www.google.com';
        vcrRec.VCC1__Call_Start_IBN__c = innos.Id;
        vcrRec.VCC1__Call_End_IBN__c = inboe.Id;
        vcrRec.VCC1__Call_Initiate_Record_Id__c = testcontact.id;
        insert vcrRec;
        
        Task tasRecord = new Task();
        tasRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales and Sales').getRecordTypeId();
        tasRecord.Task_type__c = 'Presales Call';
        tasRecord.Subject = 'Outbound Received Call ';
        tasRecord.WhoId = testcontact.Id;
        tasRecord.WhatId = enq.Id;
        tasRecord.Call_Record__c = vcrRec.Id;
        tasRecord.CallObject = 'u33hwc-cbhuwc';
        tasRecord.ActivityDate = System.today();
        tasRecord.Communication_type__c = 'Outbound Call';
        tasRecord.CallType = 'Outbound';
        insert tasRecord;
        
        tasRecord.Call_Attempt_Status__c = 'No Contact - Follow-up';
        update tasRecord;
    }
}