public class BookingApprovalTriggerHandler {
    
    Public static void UpdateFieldsBeforeApproval(list<booking__c> newList, map<Id,Booking__c> oldMap){
        Map<Id,Booking__c> bookingMap = new Map<Id,Booking__c>();
        boolean submitForApproval = false;
        for(Booking__c b :newList){
            
            If(b.Sales_Managers__c != oldMap.get(b.id).Sales_Managers__c && b.Sales_Managers__c != b.Previous_Sales_Managers__c){
                b.Previous_Sales_Managers__c = b.Sales_Managers__c;
                b.Sales_Managers__c = oldMap.get(b.id).Sales_Managers__c;
                system.debug('current '+b.Sales_Managers__c);
                system.debug('previous '+b.Previous_Sales_Managers__c);
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Sales_Head__c != oldMap.get(b.id).Sales_Head__c && b.Sales_Head__c != b.Previous_Sales_Head__c){
                b.Previous_Sales_Head__c = b.Sales_Head__c;
                b.Sales_Head__c = oldMap.get(b.id).Sales_Head__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Secondary_Sales_Manager__c != oldMap.get(b.id).Secondary_Sales_Manager__c && b.Secondary_Sales_Manager__c != b.Previous_Secondary_Sales_Manager__c){
                b.Previous_Secondary_Sales_Manager__c = b.Secondary_Sales_Manager__c;
                b.Secondary_Sales_Manager__c = oldMap.get(b.id).Secondary_Sales_Manager__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Secondary_Sales_Head__c != oldMap.get(b.id).Secondary_Sales_Head__c && b.Secondary_Sales_Head__c != b.Previous_Secondary_Sales_Head__c){
                b.Previous_Secondary_Sales_Head__c = b.Secondary_Sales_Head__c;
                b.Secondary_Sales_Head__c = oldMap.get(b.id).Secondary_Sales_Head__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Channel_Partner__c != oldMap.get(b.id).Channel_Partner__c && b.Channel_Partner__c != b.Previous_Channel_Partner__c){
                b.Previous_Channel_Partner__c = b.Channel_Partner__c;
                b.Channel_Partner__c = oldMap.get(b.id).Channel_Partner__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Sobha_Connect__c != oldMap.get(b.id).Sobha_Connect__c && b.Sobha_Connect__c != b.Previous_Sobha_Connect__c){
                b.Previous_Sobha_Connect__c = b.Sobha_Connect__c;
                b.Sobha_Connect__c = oldMap.get(b.id).Sobha_Connect__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Source_of_Booking__c != oldMap.get(b.id).Source_of_Booking__c && b.Source_of_Booking__c != b.Previous_Source_of_Booking__c){
                b.Previous_Source_of_Booking__c = b.Source_of_Booking__c;
                b.Source_of_Booking__c = oldMap.get(b.id).Source_of_Booking__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            If(b.Sub_Source__c != oldMap.get(b.id).Sub_Source__c && b.Sub_Source__c != b.Previous_Sub_Source__c){
                b.Previous_Sub_Source__c = b.Sub_Source__c;
                b.Sub_Source__c = oldMap.get(b.id).Sub_Source__c;
                b.SM_SD_Change_Status__c = 'Submit to Saima';
            }
            if(b.SM_SD_Change_Status__c != oldMap.get(b.Id).SM_SD_Change_Status__c && b.SM_SD_Change_Status__c == 'Approved by Saima'){
                If(b.Previous_Sales_Managers__c != null && b.Previous_Sales_Managers__c != ''){
                    b.Sales_Managers__c = b.Previous_Sales_Managers__c;
                }
                If(b.Previous_Sales_Head__c != null && b.Previous_Sales_Head__c != ''){
                    b.Sales_Head__c = b.Previous_Sales_Head__c;
                }
                If(b.Previous_Secondary_Sales_Manager__c != null && b.Previous_Secondary_Sales_Manager__c != ''){
                    b.Secondary_Sales_Manager__c = b.Previous_Secondary_Sales_Manager__c;
                }
                If(b.Previous_Secondary_Sales_Head__c != null && b.Previous_Secondary_Sales_Head__c != ''){
                    b.Secondary_Sales_Head__c = b.Previous_Secondary_Sales_Head__c;
                }

                If(b.Previous_Channel_Partner__c != null && b.Previous_Channel_Partner__c != ''){
                    b.Channel_Partner__c = b.Previous_Channel_Partner__c;
                }
                If(b.Previous_Sobha_Connect__c != null && b.Previous_Sobha_Connect__c != ''){
                    b.Sobha_Connect__c = b.Previous_Sobha_Connect__c;
                }
                If(b.Previous_Source_of_Booking__c != null && b.Previous_Source_of_Booking__c != ''){
                    b.Source_of_Booking__c = b.Previous_Source_of_Booking__c;
                }
                If(b.Previous_Sub_Source__c != null && b.Previous_Sub_Source__c != ''){
                    b.Sub_Source__c = b.Previous_Sub_Source__c;
                }
                bookingMap.put(b.Id,b);
            }
            else if(b.SM_SD_Change_Status__c != oldMap.get(b.Id).SM_SD_Change_Status__c && b.SM_SD_Change_Status__c == 'Rejected by Saima'){
                b.Previous_Sales_Managers__c = b.Sales_Managers__c;
                b.Previous_Sales_Head__c = b.Sales_Head__c;
                b.Previous_Secondary_Sales_Manager__c = b.Secondary_Sales_Manager__c;
                b.Previous_Secondary_Sales_Head__c = b.Secondary_Sales_Head__c;

                b.Previous_Channel_Partner__c = b.Channel_Partner__c;
                b.Previous_Sobha_Connect__c = b.Sobha_Connect__c;
                b.Previous_Source_of_Booking__c = b.Source_of_Booking__c;
                b.Previous_Sub_Source__c = b.Sub_Source__c;
            }
        }
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> OppList = new List<Opportunity>();
        Map<Id,Id> oppIdToBookingIdMap = new Map<Id,Id>();
        If(bookingMap.Keyset().size()>0){
            For(Booking__c b :bookingMap.values()){
                if(b.Opportunity__c != null){
                    Opportunity opp = new Opportunity();
                    opp.Sales_Manager_lookup__c = b.Sales_Managers__c;
                    opp.Secondary_Sales_Manager__c = b.Secondary_Sales_Manager__c;
                    opp.Secondary_Sales_Head__c = b.Secondary_Sales_Head__c;
                    opp.Sales_Head_Lookup__c = b.Sales_Head__c;
                    opp.Booking_Source__c = b.Source_of_Booking__c;
                    opp.Booking_Sub_Source__c = b.Sub_Source__c;
                    opp.Channel_Partner__c = b.Channel_Partner__c;
                    opp.Sobha_Connect__c = b.Sobha_Connect__c;
                    opp.Id = b.Opportunity__c;
                    //Add Opp fields
                    OppList.add(opp);
                    oppIds.add(opp.Id);
                    oppIdToBookingIdMap.put(opp.Id,b.Id);
                }
            }
            if(oppList.size()>0){
                update oppList;
            }
            List<Customer_Registration__c> svfList = [Select Id from Customer_Registration__c where Opportunity__c In :OppIds];
            for(Customer_Registration__c svf :svfList){
                //add site visit form fields bookingMap.get(oppIdToBookingIdMap.get(svf.Opportunity__c)).Field__c
            }
            if(svfList.size()>0){
                Update svfList;
            }
            
            list<unit_hold_request__c> NSAlist = [Select Id,Booking__c from unit_hold_request__c where Booking__c In :bookingMap.keyset()];
            for(unit_hold_request__c nsa : NSAlist){
                nsa.Sales_Manager_Value__c = bookingMap.get(nsa.Booking__c).Sales_Managers__c;
                nsa.Sales_Head_Value__c = bookingMap.get(nsa.Booking__c).Sales_Head__c;
                nsa.Secondary_Sales_Head__c = bookingMap.get(nsa.Booking__c).Secondary_Sales_Head__c;
                nsa.Secondary_Sales_Manager__c = bookingMap.get(nsa.Booking__c).Secondary_Sales_Manager__c;
                //Add NSA fields bookingMap.get.get(nsa.Booking__c).Field__c
            }
            if(NSAlist.size()>0){
                Update NSAlist;
            }
        }
    }
    public static void submitForApproval(list<booking__c> newList){
        for(Booking__c b : newList){
            If(b.SM_SD_Change_Status__c == 'Submit to Saima'){
				Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(b.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(UserInfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('SM_and_SD_change_approval');
            req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);                
            }
            
        }
        
    }
}