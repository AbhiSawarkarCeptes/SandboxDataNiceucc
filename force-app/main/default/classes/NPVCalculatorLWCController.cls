/*********************************************************************
 * Class Name  :   NPVCalculatorLWCController
 * Description :   Controller class for the NPVCalculatorLWC VF component. This class
                       will handle to query payment , PPD NPV slabs records
 * Created Date:   17/05/2023
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Deepak Sharma
   Last Modified By :   Deepak Sharma 19/05/2023
 *********************************************************************/
public class NPVCalculatorLWCController {
    public Boolean showAlert {get;set;}
    public String baseUrl {get;set;}
    
    public NPVCalculatorLWCController() {
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Id recID = Apexpages.currentpage().getparameters().get('id');
        PropStrength__Application_Booking__c book = [SELECT Id, PropStrength__Primary_Applicant_Name__c, PropStrength__Total_Paid_Percent__c, PropStrength__Booking_Through__c FROM PropStrength__Application_Booking__c WHERE Id = :recId];
        if(book.PropStrength__Total_Paid_Percent__c > 10 && book.PropStrength__Booking_Through__c != 'Employee Reference') {
            showAlert = false;
        } else {
            showAlert = true;
        }
    }

    @AuraEnabled(Cacheable=false)
    public static List<PropStrength__Application_Booking__c> ppdRecords(String bookId) {
        return [SELECT Id, Name, PropStrength__Primary_Applicant_Name__c, PropStrength__Status__c, PropStrength__Property_Name__c, Project_Name__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Code__c, PropStrength__Total_Paid_Percent__c, (SELECT Id, Name, PropStrength__Amount_Percent__c, PropStrength__Milestone_Name__c, PropStrength__Payment_Due_Date__c, PropStrength__Milestone__r.PropStrength__Milestone_Name__c , PropStrength__Balance__c, PropStrength__Amount_Due_Plus_Tax__c FROM PropStrength__Payment_Plan_Details__r ORDER BY PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c) FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
    }

    @AuraEnabled(Cacheable=false)
    public static List<PropStrength__Received_Payment__c> paymentRecords(String bookId) {
        Id payRecRecType = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        List<PropStrength__Application_Booking__c> booking =  [SELECT Id, PropStrength__Primary_Applicant_Name__c, PropStrength__Booking_Date__c, (SELECT Id, Name, PropStrength__Payment_Date__c, PropStrength__Amount__c FROM PropStrength__Payments_Cheques__r WHERE Rebate_Calculated__c = FALSE AND PropStrength__Receipt_Reversed__c = FALSE AND PropStrength__Amount_Due_Type__c != 'Receipt Reversal' AND PropStrength__Amount_Due_Type__c = 'Installment' AND RecordTypeId = :payRecRecType) FROM PropStrength__Application_Booking__c WHERE Id = :bookId];
        List<PropStrength__Received_Payment__c> finalPaymentRec = new List<PropStrength__Received_Payment__c>();

        if(!booking.isEmpty() && !booking[0].PropStrength__Payments_Cheques__r.isEmpty()) {
            List<PropStrength__Received_Payment__c> paymentRecs = booking[0].PropStrength__Payments_Cheques__r;
            List<Id> paymentId = new List<Id>();
            System.debug('paymentRecs: '+paymentRecs);
            for(Integer i = 0; i < paymentRecs.size(); i++) {
                paymentId.add(paymentRecs[i].Id);
            }
            System.debug('paymentId: '+paymentId);

            Map<Id, PropStrength__Received_Payment__c> paymentRecords = new Map<Id, PropStrength__Received_Payment__c>([SELECT Id, PropStrength__Payment_Date__c, PropStrength__Amount__c, Name, PropStrength__Amount_Due_Type__c, (SELECT Id, PropStrength__Milestone_Payment_Recieved_cur__c, PropStrength__Payment_Plan_Detail__r.PropStrength__Payment_Due_Date__c, PropStrength__Payment_Plan_Detail__c FROM PropStrength__Other_Charge_Due_Partitions__r WHERE PropStrength__Payment_Plan_Detail__c != null) FROM PropStrength__Received_Payment__c WHERE PropStrength__Amount_Due_Type__c != 'Rebate' AND Id IN :paymentId]);
            Set<Id> showPaymentId = new Set<Id>();
            
            if(!paymentRecords.isEmpty()) {
                List<PropStrength__Received_Payment__c> payRec = paymentRecords.values();
                System.debug('payRec: '+payRec);
                for(Integer i = 0; i < payRec.size(); i++) {
                    if(!payRec[i].PropStrength__Other_Charge_Due_Partitions__r.isEmpty()) {
                        List<PropStrength__Other_Charge_Due_Partition__c> plirecs = payRec[i].PropStrength__Other_Charge_Due_Partitions__r;
                        System.debug('plirecs: '+plirecs);
                        for(Integer j = 0 ; j < plirecs.size(); j++) {
                            System.debug(plirecs[j].PropStrength__Payment_Plan_Detail__r.PropStrength__Payment_Due_Date__c > payRec[i].PropStrength__Payment_Date__c);
                            System.debug(booking[0].PropStrength__Booking_Date__c);
                            System.debug(payRec[i].PropStrength__Payment_Date__c);
                            System.debug(booking[0].PropStrength__Booking_Date__c.daysBetween(payRec[i].PropStrength__Payment_Date__c));
                            System.debug(booking[0].PropStrength__Booking_Date__c.daysBetween(payRec[i].PropStrength__Payment_Date__c) > 30);
                            if(plirecs[j].PropStrength__Payment_Plan_Detail__r.PropStrength__Payment_Due_Date__c > payRec[i].PropStrength__Payment_Date__c && booking[0].PropStrength__Booking_Date__c.daysBetween(payRec[i].PropStrength__Payment_Date__c) > 30) {
                                showPaymentId.add(payRec[i].Id);
                            }
                        }
                    }
                }

                System.debug('showPaymentId: '+showPaymentId);

                if(!showPaymentId.isEmpty()) {
                    for(PropStrength__Received_Payment__c payment : paymentRecs) {
                        if(showPaymentId.contains(payment.Id)) {
                            finalPaymentRec.add(paymentRecords.get(payment.Id));
                        }
                    }                  
                }
            }
        }
        return finalPaymentRec;
    }

    @AuraEnabled(Cacheable=false)
    public static String npvSlabsRecords() {
        List<NPV_Slab__c> slabRecs = [SELECT Id, Name, Rebate__c, Days_to__c, Days_From__c FROM NPV_Slab__c];
        String objs = '';
        for(NPV_Slab__c slabRec : slabRecs) {
            objs += '{"Id":"'+slabRec.Id+'","Name":"'+slabRec.Name+'","Rebate":"'+slabRec.Rebate__c+'","DaysTo":"'+slabRec.Days_to__c+'","DaysFrom":"'+slabRec.Days_From__c+'"} ';
        }
        if(objs != '') {
            objs = objs.substring(0, objs.length()-1);
        }
        return objs;
    }

    @AuraEnabled(Cacheable=false)
    public static String createTransationRequest(String totalPaymentAmt, String totalRebateAmt, String differentialRebateAmt, String bookId, String selPaymentId) {
        Id transReqRecTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get('Advance Payment Rebate').getRecordTypeId();
        List<PropStrength__Transaction_Requests__c> existingTransRequest = [SELECT Id FROM PropStrength__Transaction_Requests__c WHERE (PropStrength__Status__c != 'Rejected' AND PropStrength__Status__c != 'Request Completed') AND RecordTypeId = :transReqRecTypeId AND PropStrength__Application_Booking__c = :bookId];
        if(existingTransRequest.isEmpty()) {
            PropStrength__Transaction_Requests__c transReq = new PropStrength__Transaction_Requests__c(Payment_Date__c = System.Today(), RecordTypeId = transReqRecTypeId, Actual_Advance_Amount__c = Decimal.valueOf(totalPaymentAmt), Advance_Payment_Rebate_Amount__c = Decimal.valueOf(totalRebateAmt), PropStrength__Application_Booking__c = bookId, Selected_Payment__c = selPaymentId, Differential_Rebate_Amount__c = Decimal.valueOf(differentialRebateAmt));
            insert transReq;
            return transReq.Id;
        }
        return null;
    }
}