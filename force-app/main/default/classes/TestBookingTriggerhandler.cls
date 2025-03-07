@isTest
public class TestBookingTriggerhandler {

    @isTest
    static void testSendToMobileAPI() {
        Mobile_TestUtil.createBooking();
        
        Map<id,Booking__c> bOldMap = new Map<id,Booking__c>();
        List<Booking__c> bNewList = new List<Booking__c>();
        Booking__c b = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                    SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                    From Booking__c limit 1];
        b.SPA_Executed__c = '';
        b.Current_Status__c = 'Signed by Client';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Pre_registration__c = 'Not Initiated';
        update b;
        bOldMap.put(b.id,b);
        
        b.Status__c = 'Cancelled';
        b.Reason_For_Cancellation_D__c = 'Test';
        b.Primary_Applicant_Name__c = 'Test name';
        b.Primary_Applicant_Email__c = 'testtest@test.com';
        b.Handover_Date__c = System.today().addDays(30);
        b.SPA_Executed__c = 'SPA Sent through Docusign';
        b.Current_Status__c = 'Sent to Client';
        b.Booking_Approver_Audit__c = 'Accepted';
        //b.Pre_registration__c = 'Completed';
        update b;
        
        Booking__c b1 = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                            SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                            From Booking__c where id =:b.id];
        
        bNewList.add(b1);

        Test.startTest();
        
        String newBookingString = JSON.serialize(bNewList);
        String oldBookingString = JSON.serialize(bOldMap);

        // Call the sendToMobileAPI method
        BookingTriggerHandler.sendToMobileAPI(newBookingString, oldBookingString, true);
        BookingTriggerHandler.sendToMobileAPI(newBookingString, null, true);
        BookingTriggerHandler.requestBodyWrapper r = new BookingTriggerHandler.requestBodyWrapper();

        // Stop Test and check the debug logs or add assertions as needed
        Test.stopTest();
    }
    
    @isTest
    static void testSendToMobileAPI2() {
        
        Profile prof = [select id from profile where name LIKE '%System Administrator%' LIMIT 1];
        userRole ur = [SELECT Id, Name FROM UserRole WHERE Name = 'Sales Head 1'];
        User usr = new User();
        usr.firstName = 'test1';
        usr.lastName = 'test2';
        usr.profileId = prof.id;
        usr.Alias = 'sdffer';
        usr.username = 'testsdncbjdsc@test.com';
        usr.email = 'testcdscdvcdv@test.com';
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.UserRoleId = ur.id;
        usr.IsActive=true;
        insert usr;
        
        
        System.runas(usr){
            User usrRec = [Select id from user where profile.name LIKE '%System Administrator%' and isActive = true LIMIT 1];
              
         
            Mobile_TestUtil.createBooking();
        
            Map<id,Booking__c> bOldMap = new Map<id,Booking__c>();
            List<Booking__c> bNewList = new List<Booking__c>();
            Booking__c b = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,Unit__c,
                        SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                        From Booking__c limit 1];
            b.SPA_Executed__c = '';
            b.Current_Status__c = 'Signed by Client';
            update b;
            bOldMap.put(b.id,b);
            String oldBookingString = JSON.serialize(bOldMap);
            
            Unit__c unitRec = [Select id, Unit_Status__c from Unit__c where Id = :b.Unit__c];
            unitRec.Unit_Status__c = 'Available';
            unitRec.Reason_for_Cancellation__c = 'xyz';
            update unitRec;
            Test.startTest();
            Payment_Request__c pr = new Payment_Request__c();
            pr.name__c = 'yamini';
            pr.Email__c = 'yamini.jakka@ceptes.com';
            pr.Mobile_Number__c='9550987889';
            pr.Emirates_Id_Passport_Number__c='12xgy';
            pr.Mode__c = 'OTC Deposits';
            pr.Status__c='Approved';
            pr.Amount__c = 123;
            pr.Unit__c = unitRec.Id;
            pr.Approved_Date_and_Time__c=System.today();
            pr.From_Booking__c = false;
            pr.Sales_Manager__c = usrRec.Id;
            insert pr; 
            
            unit_hold_request__c newsale1 = new unit_hold_request__c();
            newsale1.Agent_Name__c = 'yamni1';
            newsale1.Blocking_Amount_Paid__c = 123;
            newsale1.Payment_Request__c = pr.Id;
            
            newsale1.Approval_Status__c = 'Pending';
            newsale1.DLD_Amount__c = 1234;
            newsale1.DP_Amount__c = 1234;
            newsale1.DLD_Amount_2__c = 1342;
            newsale1.DP_Amount_2__c = 321;
            newsale1.How_Many_Applicants__c = 'One Applicant';
            newsale1.Sales_Head_Value__c = usrRec.Id;
            newsale1.OwnerId = usrRec.Id;
            newsale1.Sales_Head_VP__c = usrRec.Id;
            newsale1.Sales_Manager_Value__c = usrRec.Id;
            newsale1.Approved_Date__c = System.today()+5;
            insert newsale1;
                
            newsale1.Approval_Status__c = 'Approved';
            newsale1.Booking__c = b.id;
            update newsale1;
                
            b.Status__c = 'Booking In Process';
            b.Primary_Applicant_Name__c = 'Test name';
            b.Primary_Applicant_Email__c = 'testtest@test.com';
            b.Handover_Date__c = System.today().addDays(30);
            b.SPA_Executed__c = 'SPA Sent through Docusign';
            b.Current_Status__c = 'Sent to Client';
            update b;
            
            Booking__c b1 = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                                SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                                From Booking__c where id =:b.id];        
            bNewList.add(b1);        
            String newBookingString = JSON.serialize(bNewList);

            // Call the sendToMobileAPI method
            BookingTriggerHandler.sendToMobileAPI(newBookingString, oldBookingString, true);
            BookingTriggerHandler.sendToMobileAPI(newBookingString, null, true);
            BookingTriggerHandler.requestBodyWrapper r = new BookingTriggerHandler.requestBodyWrapper();
            
            // Stop Test and check the debug logs or add assertions as needed
        }        
        
        Test.stopTest();
    }
    
     @isTest
    static void testSendToMobileAPI3() {
        Mobile_TestUtil.createBooking();
        
        Map<id,Booking__c> bOldMap = new Map<id,Booking__c>();
        List<Booking__c> bNewList = new List<Booking__c>();
        Booking__c b = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                    SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                    From Booking__c limit 1];
        b.SPA_Executed__c = '';
        b.Current_Status__c = 'Signed by Client';
        update b;
        bOldMap.put(b.id,b);
        String oldBookingString = JSON.serialize(bOldMap);
        
        b.Status__c = 'Booking In Process';
        b.Primary_Applicant_Name__c = 'Test name';
        b.Primary_Applicant_Email__c = 'testtest@test.com';
        b.Handover_Date__c = System.today().addDays(30);
        b.SPA_Executed__c = 'SPA Executed';
        b.Current_Status__c = 'Sent to Client';
        update b;
        
        Booking__c b1 = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                            SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                            From Booking__c where id =:b.id];
        
        bNewList.add(b1);

        Test.startTest();
        
        String newBookingString = JSON.serialize(bNewList);

        // Call the sendToMobileAPI method
        BookingTriggerHandler.sendToMobileAPI(newBookingString, oldBookingString, true);
        BookingTriggerHandler.sendToMobileAPI(newBookingString, '', true);
        BookingTriggerHandler.requestBodyWrapper r = new BookingTriggerHandler.requestBodyWrapper();

        // Stop Test and check the debug logs or add assertions as needed
        Test.stopTest();
    }
    
    @isTest
    static void testSendToMobileAPI4() {
        Mobile_TestUtil.createBooking();
        
        Map<id,Booking__c> bOldMap = new Map<id,Booking__c>();
        List<Booking__c> bNewList = new List<Booking__c>();
        Booking__c b = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                    SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                    From Booking__c limit 1];
        b.SPA_Executed__c = '';
        b.Current_Status__c = 'Signed by Client';
        update b;
        bOldMap.put(b.id,b);
        String oldBookingString = JSON.serialize(bOldMap);
        
        b.Status__c = 'Booking In Process';
        b.Primary_Applicant_Name__c = 'Test name';
        b.Primary_Applicant_Email__c = 'testtest@test.com';
        b.Handover_Date__c = System.today().addDays(30);
        b.SPA_Executed__c = 'SPA Executed';
        b.Current_Status__c = 'Sent to Client';
        update b;
        
        Booking__c b1 = [Select id, Name, Primary_Applicant_Name__c, Primary_Applicant_Email__c, Handover_Date__c,
                            SPA_Executed__c, Current_Status__c, Booking_Approver_Audit__c, Pre_registration__c, Status__c
                            From Booking__c where id =:b.id];
        
        bNewList.add(b1);

        Test.startTest();
        
        String newBookingString = JSON.serialize(bNewList);

        // Call the sendToMobileAPI method
        BookingTriggerHandler.sendToMobileAPI(newBookingString, null, true);
        //BookingTriggerHandler.requestBodyWrapper r = new BookingTriggerHandler.requestBodyWrapper();

        // Stop Test and check the debug logs or add assertions as needed
        Test.stopTest();
    }
    
    
}