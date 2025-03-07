/*********************************************************************
 * Class Name  :   ApplicationBookingCallDetailTrigHelper
 * Description :   Helper Class of ApplicationBookingCallDetailTrigger
 * Created Date:   28/05/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 28/05/2024
 *********************************************************************/
public class ApplicationBookingCallDetailTrigHelper {

    //Added by Nishank Manwani on 28/05/2024 to update No_of_Non_Contactable_Count__c field on alteration of Application Booking Call Detail Record
    public static void updateNumberOnBooking(List<Application_Booking_Call_Detail__c> cdList) {
        Set<Id> bookId = new Set<Id>();
        
        for(Application_Booking_Call_Detail__c acd : cdList) {
            if(acd.Application_Booking__c != null && acd.Call_Update__c == 'Not Contactable') {
                bookId.add(acd.Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> updatebookList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, 
                                                                (SELECT Id FROM Application_Booking_Call_Details__r WHERE Call_Update__c = 'Not Contactable') 
                                                                FROM PropStrength__Application_Booking__c 
                                                                WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c book : bookList) {
                updatebookList.add(new PropStrength__Application_Booking__c(Id=book.Id, No_of_Non_Contactable_Count__c = book.Application_Booking_Call_Details__r.size()));
            }

            if(!updatebookList.isEmpty()) {
                update updatebookList;
            }
        }
    }

    //Added by Nishank Manwani on 28/05/2024 to update No_of_Non_Contactable_Count__c field on update of Application Booking Call Detail Record
    public static void updateNumberOnBookingOnUpd(List<Application_Booking_Call_Detail__c> cdList, Map<Id, Application_Booking_Call_Detail__c> oldCdMap) {
        Set<Id> bookId = new Set<Id>();
        
        for(Application_Booking_Call_Detail__c acd : cdList) {
            if(oldCdMap.get(acd.Id).Call_Update__c != acd.Call_Update__c && acd.Application_Booking__c != null) {
                bookId.add(acd.Application_Booking__c);
            }
        }

        if(!bookId.isEmpty()) {
            List<PropStrength__Application_Booking__c> updatebookList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Application_Booking__c> bookList = [SELECT Id, 
                                                                (SELECT Id FROM Application_Booking_Call_Details__r WHERE Call_Update__c = 'Not Contactable') 
                                                                FROM PropStrength__Application_Booking__c 
                                                                WHERE Id IN :bookId];

            for(PropStrength__Application_Booking__c book : bookList) {
                updatebookList.add(new PropStrength__Application_Booking__c(Id=book.Id, No_of_Non_Contactable_Count__c = book.Application_Booking_Call_Details__r.size()));
            }

            if(!updatebookList.isEmpty()) {
                update updatebookList;
            }
        }
    }

    //Added by Nishank Manwani on 28-05-2024 to update Last_Non_Contactable_Sent_Date_and_time__c on booking
    public static void updateLastNonContDtTime(List<Application_Booking_Call_Detail__c> cdList) {
        Map<Id, PropStrength__Application_Booking__c> updatebookMap = new Map<Id, PropStrength__Application_Booking__c>();

        for(Application_Booking_Call_Detail__c cd : cdList) {
            if(cd.Application_Booking__c != null && cd.Call_Date_Time__c != null && cd.Call_Update__c == 'Not Contactable') {
                updatebookMap.put(cd.Application_Booking__c, new PropStrength__Application_Booking__c(Id=cd.Application_Booking__c, Last_Non_Contactable_Sent_Date_and_time__c = cd.Call_Date_Time__c));
            }
        }

        if(!updatebookMap.isEmpty()) {
            update updatebookMap.values();
        }
    }
}