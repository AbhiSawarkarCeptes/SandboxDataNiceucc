@isTest
public class Test_MB_BookingTriggerHandler {
    
    public static testMethod void sendToMobileAPI() {
        
        Test_MB_MockupClass.responseBodyWrapper wrap = new Test_MB_MockupClass.responseBodyWrapper();
        wrap.result = '[{\"attributes\":{\"type\":\"Booking__c\",\"url\":\"/services/data/v58.0/sobjects/Booking__c/a065t000001RQc4AAG\"},\"Booking_Date__c\":\"2023-09-08T00:00:00.000+0000\",\"Project__c\":\"a0R5t000002NB8wEAG\",\"Tower__c\":\"a0k5t000000y73wAAA\",\"Opportunity__c\":\"0065t000008Twg6AAC\",\"Quotation__c\":\"a0S5t000000vRScEAM\",\"Unit__c\":\"a0n5t000001ZZymAA\"}]';
        
        Map<String,Id> recordIdMap = new Map<String,Id>();
        recordIdMap = TestDataFactory.createMasterProject('Sobha Hartland');
        
        Quotation__c q = new Quotation__c();
        q.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        q.Unit__c = recordIdMap.get('UNIT');
        q.Payment_Plan__c = recordIdMap.get('PLAN');
        q.Quote_Status__c = 'Valid';
        insert q; 
        
        List<Booking__c> newBookingLst = new List<Booking__c>();
        List<Booking__c> oldBookingLst = new List<Booking__c>();
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = System.today().addDays(-10);
        b.Project__c = recordIdMap.get('PROJECT');
        b.Tower__c = recordIdMap.get('TOWER');
        b.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b.Quotation__c = q.Id;
        b.Unit__c = recordIdMap.get('UNIT');
        b.Agreement_Value__c = 2500000;
        b.Status__c = 'UnProcessed';
        b.Total_Interest_Till_Date__c = 15000;
        b.Stage_of_Booking__c = 'Booked';
        b.Verification_status__c = 'Not Started';
        b.Booking_Approver_Audit__c = 'Not Started';
        b.Call_Disposition__c = 'Not Started';   
        b.Primary_Applicant_Email__c = 'test@test.com';
        insert b;
        newBookingLst.add(b);
        
        Booking__c b2 = new Booking__c();
        b2.Booking_Date__c = System.today().addDays(-10);
        b2.Project__c = recordIdMap.get('PROJECT');
        b2.Tower__c = recordIdMap.get('TOWER');
        b2.Opportunity__c = recordIdMap.get('OPPORTUNITY');
        b2.Quotation__c = q.Id;
        b2.Unit__c = recordIdMap.get('UNIT');
        b2.Agreement_Value__c = 2500000;
        b2.Status__c = 'UnProcessed';
        b2.Total_Interest_Till_Date__c = 5000;
        b2.Stage_of_Booking__c = 'Booked';
        b2.Verification_status__c = 'Not Started';
        b2.Booking_Approver_Audit__c = 'Not Started';
        b2.Call_Disposition__c = 'Not Started';   
        b2.Primary_Applicant_Email__c = 'test@test.com';
        insert b2;
        oldBookingLst.add(b2);
        
        
        
        String newBookingString = JSON.serialize(newBookingLst);
        String oldBookingString = JSON.serialize(oldBookingLst); 
        System.debug('string json   '+newBookingString);
        
        Test.setMock(HttpCalloutMock.class, new Test_MB_MockupClass(JSON.serialize(wrap), 200, 'OK'));
        
        BookingTriggerHandler.sendToMobileAPI(newBookingString, oldBookingString, false);
    }

}