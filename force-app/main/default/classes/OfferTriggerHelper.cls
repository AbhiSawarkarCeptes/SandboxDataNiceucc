/*********************************************************************
* Class Name  :   OfferTriggerHelper
* Description :   Helper class for the OfferTrigger
* Created Date:   05/06/2022
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History :
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 29/06/2022
Gourav Gour 28/02/2024
Gourav Gour 10/04/2024
Gourav Gour 23/08/2024
*********************************************************************/
public class OfferTriggerHelper {
    public static Boolean isRun = true;
    public static Boolean isRunAfter = true;
    public static Boolean isRunFirst = true;
    // variables
    Public static Boolean firstcall=false;
    
    //Added by Deepak sharma on 05 June 2023 to fill Hold amount
    public static void updateUserManagerValues(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> UserId = new Set<Id>();
        for(PropStrength__Offer__c offer: newOfferList) {
            System.debug(offer.CreatedDate+'  '+offer.PropStrength__Total_Sales_Consideration__c);
            if( (oldOfferMap == null && (offer.Sales_Manager__c != null ) ) ||
               ( oldOfferMap != null && (offer.Sales_Manager__c != null && offer.Sales_Manager__c != oldOfferMap.get(offer.Id).Sales_Manager__c ) ))  {
                   UserId.add(offer.Sales_Manager__c);
               }
            if( (oldOfferMap == null && offer.Secondary_Sales_Manager__c != null ) ||
               ( oldOfferMap != null && (offer.Secondary_Sales_Manager__c != null && offer.Secondary_Sales_Manager__c != oldOfferMap.get(offer.Id).Secondary_Sales_Manager__c ) ))  {
                   UserId.add(offer.Secondary_Sales_Manager__c);
               }
        }
        SYstem.debug('UserId*---'+UserId);
        if(!UserId.isEmpty()) {
            Map<Id, User> mapOfUserRec = new Map<Id, User>([SELECT id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId,Manager.Manager.Manager.ManagerId from User WHERE Id IN :UserId]);
            if(!mapOfUserRec.isEmpty()) {
                for(PropStrength__Offer__c offer: newOfferList) {
                    if(mapOfUserRec.containskey(offer.Sales_Manager__c)){
                        offer.Sales_Head__c = mapOfUserRec.get(offer.Sales_Manager__c).ManagerId;
                        if(mapOfUserRec.get(offer.Sales_Manager__c).Manager != null)
                            offer.Sales_VP__c = mapOfUserRec.get(offer.Sales_Manager__c).Manager.ManagerId;
                        if(mapOfUserRec.get(offer.Sales_Manager__c).ManagerId != null && mapOfUserRec.get(offer.Sales_Manager__c).Manager.ManagerId != null)
                            offer.Sales_SVP__c = mapOfUserRec.get(offer.Sales_Manager__c).Manager.Manager.ManagerId;
                    }
                    
                    if(mapOfUserRec.containskey(offer.Secondary_Sales_Manager__c)){
                        offer.Secondary_Sales_Head__c = mapOfUserRec.get(offer.Secondary_Sales_Manager__c).ManagerId;
                        if(mapOfUserRec.get(offer.Secondary_Sales_Manager__c).ManagerId != null)
                            offer.Secondary_Sales_VP__c = mapOfUserRec.get(offer.Secondary_Sales_Manager__c).Manager.ManagerId;
                        if(mapOfUserRec.get(offer.Secondary_Sales_Manager__c).ManagerId != null && mapOfUserRec.get(offer.Secondary_Sales_Manager__c).Manager.ManagerId != null)
                            offer.Secondary_Sales_SVP__c = mapOfUserRec.get(offer.Secondary_Sales_Manager__c).Manager.Manager.ManagerId;
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma on 05 June 2023 to fill Hold amount
    public static void holdAmountField(List<PropStrength__Offer__c> newOfferList) {
        Set<Id> propIds = new Set<Id>();
        for(PropStrength__Offer__c offer: newOfferList) {
            System.debug(offer.CreatedDate+'  '+offer.PropStrength__Total_Sales_Consideration__c);
            if(offer.PropStrength__Property__c != null) {
                propIds.add(offer.PropStrength__Property__c);
            }
        }
        if(!propIds.isEmpty()) {
            Map<Id, PropStrength__Property__c> propertyMap = new Map<Id, PropStrength__Property__c>([SELECT Id, Requisite_Hold_Payment__c, Requisite_Hold_Payment_Type__c, PropStrength__Total_Sales_Consideration__c FROM PropStrength__Property__c WHERE Id IN :propIds]);
            if(!propertyMap.isEmpty()) {
                List<PropStrength__Offer__c> updOffer = new List<PropStrength__Offer__c>();
                for(PropStrength__Offer__c offer: newOfferList) {
                    if(offer.PropStrength__Property__c != null && propertyMap.containsKey(offer.PropStrength__Property__c)) {
                        if(propertyMap.get(offer.PropStrength__Property__c).Requisite_Hold_Payment_Type__c == 'Amount') {
                            updOffer.add(new PropStrength__Offer__c(Id = offer.Id, Hold_Amount__c = propertyMap.get(offer.PropStrength__Property__c).Requisite_Hold_Payment__c));
                        } else if(propertyMap.get(offer.PropStrength__Property__c).Requisite_Hold_Payment_Type__c == '%') {
                            updOffer.add(new PropStrength__Offer__c(Id = offer.Id, Hold_Amount__c = (offer.PropStrength__Total_Sales_Consideration__c * propertyMap.get(offer.PropStrength__Property__c).Requisite_Hold_Payment__c) / 100));
                        }
                    }
                }
                
                if(!updOffer.isEmpty()) {
                    update updOffer;
                }
            }
        }
    }
    
    //Added by Deepak sharma on 06 June 2023 to fill Offer Valid Date
    //Last Modified by Deepak on 18 October 2023 to update Offer valid till date as per tower single and multiple hold duration
    public static void offerValidDate(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> projIds = new Set<Id>();
        Set<Id> propIds = new Set<Id>();
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.PropStrength__Project__c != null) {
                projIds.add(offer.PropStrength__Project__c);
            }
            if(offer.PropStrength__Property__c != null) {
                propIds.add(offer.PropStrength__Property__c);
            }
        }
        Map<Id, PropStrength__Projects__c> projMap = new Map<Id, PropStrength__Projects__c>();
        Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>();
        
        if(!projIds.isEmpty()) {
            projMap = new Map<Id, PropStrength__Projects__c>([SELECT Id, Payment_Method_Single_Hold_Duration__c, Payment_Method_Multiple_Hold_Duration__c FROM PropStrength__Projects__c WHERE Id IN :projIds]);
        }
        
        if(!propIds.isEmpty()) {
            propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, PropStrength__Tower__c, PropStrength__Tower__r.Payment_Method_Single_Hold_Duration__c, PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c FROM PropStrength__Property__c WHERE Id IN :propIds]);
        }
        
        for(PropStrength__Offer__c offer: newOfferList) {
            System.debug('====Test==='+offer.Payment_Method__c);
            System.debug('====Test==='+oldOfferMap.get(offer.Id).Payment_Method__c);
            if(offer.Payment_Method__c != oldOfferMap.get(offer.Id).Payment_Method__c) {
                if(offer.PropStrength__Property__c != null && propMap.containsKey(offer.PropStrength__Property__c) && offer.Payment_Method__c == 'Single' && propMap.get(offer.PropStrength__Property__c).PropStrength__Tower__r.Payment_Method_Single_Hold_Duration__c != null) {
                    offer.Offer_Valid_Till__c = offer.CreatedDate.addHours(Integer.valueOf(propMap.get(offer.PropStrength__Property__c).PropStrength__Tower__r.Payment_Method_Single_Hold_Duration__c));
                } else if(offer.PropStrength__Property__c != null && propMap.containsKey(offer.PropStrength__Property__c) && offer.Payment_Method__c == 'Multiple' && propMap.get(offer.PropStrength__Property__c).PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c != null) {
                    offer.Offer_Valid_Till__c = offer.CreatedDate.addHours(Integer.valueOf(propMap.get(offer.PropStrength__Property__c).PropStrength__Tower__r.Payment_Method_Multiple_Hold_Duration__c));
                } else if(offer.PropStrength__Project__c != null && projMap.containsKey(offer.PropStrength__Project__c) && offer.Payment_Method__c == 'Single' && projMap.get(offer.PropStrength__Project__c).Payment_Method_Single_Hold_Duration__c != null) {
                    offer.Offer_Valid_Till__c = offer.CreatedDate.addHours(Integer.valueOf(projMap.get(offer.PropStrength__Project__c).Payment_Method_Single_Hold_Duration__c));
                } else if(offer.PropStrength__Project__c != null && projMap.containsKey(offer.PropStrength__Project__c) && offer.Payment_Method__c == 'Multiple' && projMap.get(offer.PropStrength__Project__c).Payment_Method_Multiple_Hold_Duration__c != null) {
                    offer.Offer_Valid_Till__c = offer.CreatedDate.addHours(Integer.valueOf(projMap.get(offer.PropStrength__Project__c).Payment_Method_Multiple_Hold_Duration__c));
                }
            }
        }
    }
    
    //Added by Deepak sharma on 06 June 2023 to change Offer Status field
    public static void statusChange(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Boolean flag = FALSE;
        System.debug(newOfferList);
        System.debug(isRun);
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.Offer_Valid_Till__c > System.Now() && offer.Total_Pre_Payment_Received__c >= offer.Hold_Amount__c && offer.Total_Pre_Payment_Received__c != oldOfferMap.get(offer.Id).Total_Pre_Payment_Received__c) {
                offer.PropStrength__Status__c = 'Pre-Closed Won';
                offer.Offer_Sent_For_Final_Approval__c = System.Now();
                flag = TRUE;
                /*Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
approvalRequest.setComments('Offer Submitted for approval');
approvalRequest.setObjectId(offer.Id);
Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
System.debug('offer submitted for approval successfully: '+approvalResult.isSuccess());*/
            }
        }
        System.debug(flag);
        if(flag) {
            Set<Id> propIds = new Set<Id>();
            for(PropStrength__Offer__c offer: newOfferList) {
                if(offer.PropStrength__Property__c != null) {
                    propIds.add(offer.PropStrength__Property__c);
                }
            }
            if(!propIds.isEmpty()) {
                Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, (SELECT Id, PropStrength__Status__c FROM PropStrength__Offers__r) FROM PropStrength__Property__c WHERE Id IN :propIds]);
                List<PropStrength__Offer__c> offList = new List<PropStrength__Offer__c>();
                if(!propMap.isEmpty()) {
                    for(PropStrength__Property__c prop : propMap.values()) {
                        if(!prop.PropStrength__Offers__r.isEmpty()) {
                            for(PropStrength__Offer__c off : prop.PropStrength__Offers__r) {
                                if(!oldOfferMap.containsKey(off.Id)) {
                                    offList.add(new PropStrength__Offer__c(Id = off.Id, PropStrength__Status__c = 'Closed Lost'));
                                }
                            }
                        }
                    }
                    System.debug('offList: ' + offList);
                    if(!offList.isEmpty()) {
                        update offList;
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma on 12 Sep 2023 to change Offer Status field when one offer is closed won
    // Added Code BY Gourav Gour Update PPLI Final CheckBox on Status Closed Won
    public static void closeLostAll(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> propId = new Set<Id>();
        Set<Id> pplanIds = new Set<Id>();
        for(PropStrength__Offer__c offer : newOfferList) {
            if(offer.PropStrength__Property__c != null && offer.PropStrength__Status__c == 'Closed Won' && offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c) {
                propId.add(offer.PropStrength__Property__c);
            }
            if(offer.PropStrength__Payment_Plan__c != null && offer.PropStrength__Status__c == 'Closed Won' && offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c) {
                pplanIds.add(offer.PropStrength__Payment_Plan__c);
            }
        }
        List<PropStrength__Payment_Plan_Line_Items__c> ppliUpdate = new List<PropStrength__Payment_Plan_Line_Items__c>();
        if(!pplanIds.isEmpty()) {
            List<PropStrength__Payment_Plan__c> pPlanList = [SELECT ID, (SELECT Id, PropStrength__Order__c FROM PropStrength__Payment_Plan_Line_Items1__r  
                                                                         ORDER BY PropStrength__Order__c DESC LIMIT 1) 
                                                             FROM PropStrength__Payment_Plan__c WHERE Id IN :pplanIds];
            for(PropStrength__Payment_Plan__c ppl : pPlanList) {
                if(ppl.PropStrength__Payment_Plan_Line_Items1__r.size() > 0 && ppl.PropStrength__Payment_Plan_Line_Items1__r[0].PropStrength__Order__c != null && ppl.PropStrength__Payment_Plan_Line_Items1__r[0].PropStrength__Order__c != 1) {
                    ppliUpdate.add(new PropStrength__Payment_Plan_Line_Items__c(Id = ppl.PropStrength__Payment_Plan_Line_Items1__r[0].Id, PPLI_Final__c = true));
                }
            }
            if(!ppliUpdate.isEmpty()) {
                update ppliUpdate;
            }
        }
        System.debug(propId);
        if(!propId.isEmpty()) {
            List<PropStrength__Property__c> propList = [SELECT Id, (SELECT Id, PropStrength__Status__c FROM PropStrength__Offers__r) FROM PropStrength__Property__c WHERE Id IN :propId];
            List<PropStrength__Offer__c> updateOfferList = new List<PropStrength__Offer__c>();
            
            for(PropStrength__Property__c prop : propList) {
                if(!prop.PropStrength__Offers__r.isEmpty()) {
                    for(PropStrength__Offer__c offer : prop.PropStrength__Offers__r) {
                        if(!oldOfferMap.containsKey(offer.Id) && offer.PropStrength__Status__c != 'Closed Lost') {
                            updateOfferList.add(new PropStrength__Offer__c(Id=offer.Id, PropStrength__Status__c='Closed Lost'));
                        }
                    }
                }
            }
            System.debug(updateOfferList);
            if(!updateOfferList.isEmpty()) {
                update updateOfferList;
            }
        }
        
    }
    
    //Added by Deepak sharma on 17 Oct 2023 to change record type of primary customer when one offer is pre-closed won
    public static void updateRecTypeContact(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        List<Contact> updateContact = new List<Contact>();
        Set<Id> contId = new Set<Id>();
        
        for(PropStrength__Offer__c offer : newOfferList) {
            if(offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c && offer.PropStrength__Status__c == 'Pre-Closed Won' && offer.PropStrength__Primary_Contact__c != null) {
                contId.add(offer.PropStrength__Primary_Contact__c);
            }
        }
        
        if(!contId.isEmpty()) {
            Map<Id, Contact> contList = new Map<Id, Contact>([SELECT Id, RecordType.Name FROM Contact WHERE Id IN :contId]);
            Id customerContRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            
            for(PropStrength__Offer__c offer : newOfferList) {
                if(offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c && offer.PropStrength__Status__c == 'Pre-Closed Won' && offer.PropStrength__Primary_Contact__c != null) {
                    if(contList.get(offer.PropStrength__Primary_Contact__c).RecordType.Name == 'Prospect') {
                        updateContact.add(new Contact(Id=offer.PropStrength__Primary_Contact__c, RecordTypeId=customerContRecType));
                    }
                }
            }
            
            if(!updateContact.isEmpty()) {
                update updateContact;
            }
        }
    }
    
    //Added by Deepak sharma on 01 May 2024 for show error on offer
    public static void validateDLDAmountValue(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        list<String> listOfofferids = new list<String>();
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.DLD_Amount__c != oldOfferMap.get(offer.Id).DLD_Amount__c || offer.DLD_Amount_2__c != oldOfferMap.get(offer.Id).DLD_Amount_2__c) {
                listOfofferids.add(offer.Id);
            }
        }
        if(listOfofferids.size() > 0){
            Map<String,PropStrength__Offer__c> mapOfOfferRec = new Map<String,PropStrength__Offer__c>([SELECT Id, DLD_Amount__c, DLD_Amount_2__c,
                                                                                                       PropStrength__Property__r.PropStrength__Total_Sales_Consideration__c,
                                                                                                       PropStrength__Property__r.DLD_Admin_Fees__c,PropStrength__Property__r.Knowledge_Fees__c FROM PropStrength__Offer__c WHERE Id IN : listOfofferids]);
            for(PropStrength__Offer__c offerRec :  newOfferList){
                if(mapOfOfferRec.containsKey(offerRec.Id)){
                    System.debug(offerRec.DLD_Amount__c+'-****-'+mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.PropStrength__Total_Sales_Consideration__c);
                    Decimal totalSalesVal = 0;
                    if(mapOfOfferRec.get(offerRec.Id).PropStrength__Property__c != null && mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.PropStrength__Total_Sales_Consideration__c != null)
                        totalSalesVal = (mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.PropStrength__Total_Sales_Consideration__c * 4) /100;
                    System.debug(offerRec.DLD_Amount__c+ '**---*-'  + offerRec.DLD_Amount_2__c);
                    Decimal totalValue =  offerRec.DLD_Amount__c != null ? offerRec.DLD_Amount__c : 0  + offerRec.DLD_Amount_2__c != null ? offerRec.DLD_Amount_2__c : 0 ;
                    if(mapOfOfferRec.get(offerRec.Id).PropStrength__Property__c != null){
                        totalValue += (mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.DLD_Admin_Fees__c != null ? mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.DLD_Admin_Fees__c : 0 ) +
                            (mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.Knowledge_Fees__c != null ? mapOfOfferRec.get(offerRec.Id).PropStrength__Property__r.Knowledge_Fees__c : 0 ) ;
                    }
                    System.debug(totalSalesVal+'-****-'+totalValue);
                    if(totalValue > totalSalesVal){
                        offerRec.addError('DLD Allocation in the PR cannot be more than 4% of the Unit Price');
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma on 16 Nov 2023 to check Sum of DLD and DP amount equal to Payment Request amount
    public static void validationOnDPDLDAmt(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.DLD_Amount__c != oldOfferMap.get(offer.Id).DLD_Amount__c || offer.DP_Amount__c != oldOfferMap.get(offer.Id).DP_Amount__c) {
                if(offer.Payment_Request_1_Amount__c != null && offer.DLD_Amount__c != null && offer.DP_Amount__c != null && offer.DLD_Amount__c+offer.DP_Amount__c != offer.Payment_Request_1_Amount__c) {
                    offer.addError(' PR 1 Not Tagged OR Sum of DLD and DP amount must be equal to PR 1 Amount');
                }
            }
            if(offer.DLD_Amount_2__c != oldOfferMap.get(offer.Id).DLD_Amount_2__c || offer.DP_Amount_2__c != oldOfferMap.get(offer.Id).DP_Amount_2__c) {
                if(offer.Payment_Request_2_Amount__c != null && offer.DLD_Amount_2__c != null && offer.DP_Amount_2__c != null && offer.DLD_Amount_2__c+offer.DP_Amount_2__c != offer.Payment_Request_2_Amount__c) {
                    offer.addError(' PR 2 Not Tagged OR Sum of DLD 2 and DP amount 2 must be equal to PR 2 Amount');
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 09 Apr 2024 to check DLD amount fields
    public static void validationOnDLDAmt(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> propId = new Set<Id>();
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.PropStrength__Property__c != null) {
                if(offer.DLD_Amount__c != null && offer.DLD_Amount__c != oldOfferMap.get(offer.Id).DLD_Amount__c) {
                    propId.add(offer.PropStrength__Property__c);
                } else if(offer.DLD_Amount_2__c != null && offer.DLD_Amount_2__c != oldOfferMap.get(offer.Id).DLD_Amount_2__c) {
                    propId.add(offer.PropStrength__Property__c);
                }
            }
        }
        
        if(!propId.isEmpty()) {
            Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, PropStrength__Total_Sales_Consideration__c, PropStrength__Super_Area__c, 
                                                                                                 (SELECT Id, PropStrength__Fixed_Charge__c, PropStrength__Rate_per_unit_Area__c FROM PropStrength__Property_Charges__r) 
                                                                                                 FROM PropStrength__Property__c WHERE Id IN :propId AND PropStrength__Total_Sales_Consideration__c != null]);
            
            Map<Id, Decimal> recentPurchasePrice = new Map<Id, Decimal>();
            for(PropStrength__Property__c prop : propMap.values()) {
                if(prop.PropStrength__Total_Sales_Consideration__c != null) {
                    recentPurchasePrice.put(prop.Id, prop.PropStrength__Total_Sales_Consideration__c);
                }
                
                if(!prop.PropStrength__Property_Charges__r.isEmpty()) {
                    Decimal total = 0;
                    for(PropStrength__Property_Charges__c prOth : prop.PropStrength__Property_Charges__r) {
                        if(prOth.PropStrength__Rate_per_unit_Area__c != null) {
                            total += (prOth.PropStrength__Rate_per_unit_Area__c * prop.PropStrength__Super_Area__c);
                        } else if(prOth.PropStrength__Fixed_Charge__c != null) {
                            total += prOth.PropStrength__Fixed_Charge__c;
                        }
                    }
                    Decimal alreadyTot = 0;
                    
                    if(recentPurchasePrice.containsKey(prop.Id)) {
                        alreadyTot = recentPurchasePrice.get(prop.Id);
                    }
                    
                    recentPurchasePrice.put(prop.Id, (total + alreadyTot));
                }
            }
            
            for(PropStrength__Offer__c offer: newOfferList) {
                if(offer.PropStrength__Property__c != null && recentPurchasePrice.containsKey(offer.PropStrength__Property__c)) {
                    Decimal amt = (recentPurchasePrice.get(offer.PropStrength__Property__c) * 0.04) + 1160;
                    if(offer.DLD_Amount__c != null && offer.DLD_Amount__c != oldOfferMap.get(offer.Id).DLD_Amount__c && offer.DLD_Amount__c > amt) {
                        offer.addError('DLD Amount Can not be greater than ' + amt);
                    }
                    if(offer.DLD_Amount_2__c != null && offer.DLD_Amount_2__c != oldOfferMap.get(offer.Id).DLD_Amount_2__c && offer.DLD_Amount_2__c > amt) {
                        offer.addError('DLD Amount 2 Can not be greater than ' + amt);
                    }
                }
            }
        }
    }
    
    //Added by Deepak sharma on 20 Nov 2023 to create Pre-Payment record on closed won (on update)
    public static void createPrePaymentOnCloseWon(List<PropStrength__Offer__c> newOfferList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        //Set<Id> offerId = new Set<Id>();
        List<Payment_Request__c> updatePrList = new List<Payment_Request__c>();
        
        for(PropStrength__Offer__c offer: newOfferList) {
            if(offer.PropStrength__Status__c == 'Pre-Closed Won' && offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c) {
                Payment_Request__c pr1 = null;
                Payment_Request__c pr2 = null;
                
                if(offer.Payment_Request_1__c != null) {
                    pr1 = new Payment_Request__c(Id=offer.Payment_Request_1__c);
                }
                if(offer.Payment_Request_2__c != null) {
                    pr2 = new Payment_Request__c(Id=offer.Payment_Request_2__c);
                }
                
                if(offer.DP_Amount__c != null && offer.DP_Amount__c > 0 && offer.Payment_Request_1__c != null) {
                    pr1.Towards_Unit_Price_Amount__c = offer.DP_Amount__c;
                }
                if(offer.DP_Amount_2__c != null && offer.DP_Amount_2__c > 0 && offer.Payment_Request_2__c != null) {
                    pr2.Towards_Unit_Price_Amount__c = offer.DP_Amount_2__c;
                }
                if(offer.DLD_Amount__c != null && offer.DLD_Amount__c > 0 && offer.Payment_Request_1__c != null) {
                    pr1.Towards_Pre_Registration_Amount__c = offer.DLD_Amount__c;
                }
                if(offer.DLD_Amount_2__c != null && offer.DLD_Amount_2__c > 0 && offer.Payment_Request_2__c != null) {
                    pr2.Towards_Pre_Registration_Amount__c = offer.DLD_Amount_2__c;
                }
                
                if(pr1 != null) {
                    updatePrList.add(pr1);
                }
                if(pr2 != null) {
                    updatePrList.add(pr2);
                }
            }
        }
        
        if(!updatePrList.isEmpty()) {
            update updatePrList;
        }
        
        // if(!offerId.isEmpty()) {
        //System.debug('offerId****');
        // System.debug(offerId);
        //Map<Id, PropStrength__Offer__c> offMap = new Map<Id, PropStrength__Offer__c>([SELECT Id, Payment_Request_1__c, Payment_Request_2__c, Payment_Request_1__r.Cheque_No__c, Payment_Request_2__r.Cheque_No__c, Payment_Request_1__r.Account_Received_Date__c, Payment_Request_2__r.Account_Received_Date__c, Payment_Request_1__r.Cheque_Date__c, Payment_Request_2__r.Cheque_Date__c, Payment_Request_1__r.Mode__c, Payment_Request_2__r.Mode__c, Payment_Request_1__r.Instrument_Date__c, Payment_Request_2__r.Instrument_Date__c, Payment_Request_1__r.Instrument_Number__c, Payment_Request_2__r.Instrument_Number__c, Payment_Request_1__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c, Payment_Request_2__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c FROM PropStrength__Offer__c WHERE Id IN :offerId]);
        
        //List<PropStrength__PrePayment_Received__c> createprePRRecsList = new List<PropStrength__PrePayment_Received__c>();
        
        // for(PropStrength__Offer__c offer: newOfferList) {
        //if(offer.PropStrength__Status__c == 'Pre-Closed Won' && offer.PropStrength__Status__c != oldOfferMap.get(offer.Id).PropStrength__Status__c) {
        //  if(offer.DP_Amount__c != null && offer.DP_Amount__c > 0) {
        //    if(!offMap.isEmpty() && offMap.containsKey(offer.Id)) {
        //      String instrumentNumber = '';
        //    Date instrumentDate = null;
        
        //  if(offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'Cheque') {
        //    instrumentNumber = offMap.get(offer.Id).Payment_Request_1__r.Cheque_No__c;
        //  instrumentDate = offMap.get(offer.Id).Payment_Request_1__r.Cheque_Date__c;
        //}
        //if(offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'Credit Card' || offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'CDM Cash' || offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'International Wire Transfer' || offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'CDM Cheque') {
        //instrumentNumber = offMap.get(offer.Id).Payment_Request_1__r.Instrument_Number__c;
        //instrumentDate = offMap.get(offer.Id).Payment_Request_1__r.Instrument_Date__c;
        //}
        //if(offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'Website' || offMap.get(offer.Id).Payment_Request_1__r.Mode__c == 'Domestic Wire Transfer') {
        //  instrumentDate = offMap.get(offer.Id).Payment_Request_1__r.Instrument_Date__c;
        // }
        //createprePRRecsList.add(new PropStrength__PrePayment_Received__c(PropStrength__Payment_Date__c = System.Today(), PropStrength__Amount__c = offer.DP_Amount__c, PropStrength__Payment_Mode__c = offMap.get(offer.Id).Payment_Request_1__r.Mode__c, PropStrength__Offer__c=offer.Id, Instrument_Date__c = instrumentDate, GL_Date__c = instrumentDate, Instrument_Number__c = instrumentNumber, Approval_Status__c = 'Approved', Bank_GL__c = offMap.get(offer.Id).Payment_Request_1__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c, Payment_Clearance_Date__c = offMap.get(offer.Id).Payment_Request_1__r.Account_Received_Date__c));
        //}
        //}
        
        //  System.debug('createprePRRecsList****');
        //System.debug(createprePRRecsList);
        //if(offer.DP_Amount_2__c != null && offer.DP_Amount_2__c > 0) {
        //  if(!offMap.isEmpty() && offMap.containsKey(offer.Id)) {
        //    String instrumentNumber = '';
        //  Date instrumentDate = null;
        
        //if(offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'Cheque') {
        //  instrumentNumber = offMap.get(offer.Id).Payment_Request_2__r.Cheque_No__c;
        //instrumentDate = offMap.get(offer.Id).Payment_Request_2__r.Cheque_Date__c;
        // }
        //if(offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'Credit Card' || offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'CDM Cash' || offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'International Wire Transfer' || offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'CDM Cheque') {
        //  instrumentNumber = offMap.get(offer.Id).Payment_Request_2__r.Instrument_Number__c;
        //instrumentDate = offMap.get(offer.Id).Payment_Request_2__r.Instrument_Date__c;
        //}
        // if(offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'Website' || offMap.get(offer.Id).Payment_Request_2__r.Mode__c == 'Domestic Wire Transfer') {
        //    instrumentDate = offMap.get(offer.Id).Payment_Request_2__r.Instrument_Date__c;
        //}
        
        //createprePRRecsList.add(new PropStrength__PrePayment_Received__c(PropStrength__Payment_Date__c = System.Today(), PropStrength__Amount__c = offer.DP_Amount_2__c, PropStrength__Payment_Mode__c = offMap.get(offer.Id).Payment_Request_2__r.Mode__c, PropStrength__Offer__c=offer.Id, Instrument_Date__c = instrumentDate, GL_Date__c = instrumentDate, Instrument_Number__c = instrumentNumber, Approval_Status__c = 'Approved', Bank_GL__c = offMap.get(offer.Id).Payment_Request_2__r.Property__r.PropStrength__Tower__r.RDS_Company_Code__c, Payment_Clearance_Date__c = offMap.get(offer.Id).Payment_Request_2__r.Account_Received_Date__c));
        //}
        // }
        
        //System.debug('createprePRRecsList****');
        //System.debug(createprePRRecsList);
        //}
        // }
        
        //System.debug('createprePRRecsList****');
        //System.debug(createprePRRecsList);
        
        // if(!createprePRRecsList.isEmpty()) {
        //insert createprePRRecsList;
        //}
        //}
    }
    
    public static boolean runOnce(){
        if(isRun) {
            isRun=false;
            return true;
        }else{
            return isRun;
        }
    }
    
    public static boolean runOnceAfter(){
        if(isRunAfter) {
            isRunAfter=false;
            return true;
        }else{
            return isRunAfter;
        }
    }
    
    //Added by Deepak Sharma on 27'Nov 2023 to map Sales & Source Manager section from enquiry to offer before insert
    public static void mapSalesNSourceSection(List<PropStrength__Offer__c> offerList, Map<Id, PropStrength__Offer__c> oldOfferMap, String actionType) {
        Set<Id> enqId = new Set<Id>();
        for(PropStrength__Offer__c offer: offerList) {
            if(actionType == 'Insert') {
                if(offer.PropStrength__Request__c != null) {
                    enqId.add(offer.PropStrength__Request__c);
                }
            }
            if(actionType == 'Update') {
                if(offer.PropStrength__Request__c != null && offer.PropStrength__Request__c != oldOfferMap.get(offer.Id).PropStrength__Request__c)  {
                    enqId.add(offer.PropStrength__Request__c);
                }
            }
        }
        
        if(!enqId.isEmpty()) {
            Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, Split_Deals__c,
                                                                                              Sales_Head__c, Sales_Manager__c, 
                                                                                              Sourcing_Manager_1__c, Sourcing_Manager_2__c,
                                                                                              Sourcing_Manager_3__c, Secondary_Sales_Head__c,
                                                                                              Secondary_Sales_Manager__c, Closing_Manager_1__c,
                                                                                              Closing_Manager_2__c, Closing_Manager_3__c,
                                                                                              Sales_VP__c, Sales_SVP__c, Secondary_Sales_VP__c, Secondary_Sales_SVP__c
                                                                                              FROM PropStrength__Request__c WHERE Id IN :enqId]);
            
            for(PropStrength__Offer__c offer: offerList) {
                if(actionType == 'Insert') {
                    if(offer.PropStrength__Request__c != null && enqMap.containsKey(offer.PropStrength__Request__c)) {
                        offer.Split_Deals__c = enqMap.get(offer.PropStrength__Request__c).Split_Deals__c;
                        offer.Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Sales_Head__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_Head__c : null;
                        offer.Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Sales_Manager__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_Manager__c : null;
                        offer.Sourcing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_1__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_1__c : null;
                        offer.Sourcing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_2__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_2__c : null;
                        offer.Sourcing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_3__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_3__c : null;
                        offer.Secondary_Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Head__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Head__c : null;
                        offer.Secondary_Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Manager__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Manager__c : null;
                        offer.Closing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_1__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_1__c : null;
                        offer.Closing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_2__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_2__c : null;
                        offer.Closing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_3__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_3__c : null;
                        
                        offer.Sales_VP__c = enqMap.get(offer.PropStrength__Request__c).Sales_VP__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_VP__c : null;
                        offer.Secondary_Sales_VP__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_VP__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_VP__c : null;
                        offer.Sales_SVP__c = enqMap.get(offer.PropStrength__Request__c).Sales_SVP__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_SVP__c : null;
                        offer.Secondary_Sales_SVP__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_SVP__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_SVP__c : null;
                        
                        /*
if(offer.Split_Deals__c == null) {
offer.Split_Deals__c = enqMap.get(offer.PropStrength__Request__c).Split_Deals__c;
}
if(offer.Sales_Head__c == null) {
offer.Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Sales_Head__c;
}
if(offer.Sales_Manager__c == null) {
offer.Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Sales_Manager__c;
}

if(offer.Sourcing_Manager_1__c == null) {
offer.Sourcing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_1__c;
}

if(offer.Sourcing_Manager_2__c == null) {
offer.Sourcing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_2__c;
}

if(offer.Sourcing_Manager_3__c == null) {
offer.Sourcing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_3__c;
}

if(offer.Secondary_Sales_Head__c == null) {
offer.Secondary_Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Head__c;
}

if(offer.Secondary_Sales_Manager__c == null) {
offer.Secondary_Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Manager__c;
}

if(offer.Closing_Manager_1__c == null) {
offer.Closing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_1__c;
}

if(offer.Closing_Manager_2__c == null) {
offer.Closing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_2__c;
}

if(offer.Closing_Manager_3__c == null) {
offer.Closing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_3__c;
}
*/
                    }
                }
                if(actionType == 'Update') {
                    if(offer.PropStrength__Request__c != null && offer.PropStrength__Request__c != oldOfferMap.get(offer.Id).PropStrength__Request__c && enqMap.containsKey(offer.PropStrength__Request__c)) {
                        offer.Split_Deals__c = enqMap.get(offer.PropStrength__Request__c).Split_Deals__c;
                        offer.Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Sales_Head__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_Head__c : null;
                        offer.Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Sales_Manager__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_Manager__c : null;
                        offer.Sourcing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_1__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_1__c : null;
                        offer.Sourcing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_2__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_2__c : null;
                        offer.Sourcing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_3__c != null ? enqMap.get(offer.PropStrength__Request__c).Sourcing_Manager_3__c : null;
                        offer.Secondary_Sales_Head__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Head__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Head__c : null;
                        offer.Secondary_Sales_Manager__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Manager__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_Manager__c : null;
                        offer.Closing_Manager_1__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_1__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_1__c : null;
                        offer.Closing_Manager_2__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_2__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_2__c : null;
                        offer.Closing_Manager_3__c = enqMap.get(offer.PropStrength__Request__c).Closing_Manager_3__c != null ? enqMap.get(offer.PropStrength__Request__c).Closing_Manager_3__c : null;
                        
                        offer.Sales_VP__c = enqMap.get(offer.PropStrength__Request__c).Sales_VP__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_VP__c : null;
                        offer.Secondary_Sales_VP__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_VP__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_VP__c : null;
                        offer.Sales_SVP__c = enqMap.get(offer.PropStrength__Request__c).Sales_SVP__c != null ? enqMap.get(offer.PropStrength__Request__c).Sales_SVP__c : null;
                        offer.Secondary_Sales_SVP__c = enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_SVP__c != null ? enqMap.get(offer.PropStrength__Request__c).Secondary_Sales_SVP__c : null;
                    }
                }
            }
        }
    }
    
    //Added by Nishank Manwani on 15-Jan-2024 to check the Broker Account/Primary Customer is Blacklisted or not
    // Modification by Deepak on 06-02-2024
    public static void checkBlacklisted (List<PropStrength__Offer__c> offerList, Map<Id, PropStrength__Offer__c> oldOfferMap) {
        Set<Id> brokerAccountId = new Set<Id>();
        Set<Id> primaryContactId = new Set<Id>();
        Set<String> blockIds = new Set<String>();
        List<PropStrength__Offer__c> offerHaveToBeCheck = new List<PropStrength__Offer__c>();
        if(oldOfferMap != null) {
            for(PropStrength__Offer__c rec : offerList) {
                if( rec.PropStrength__Broker_Account__c != oldOfferMap.get(rec.Id).PropStrength__Broker_Account__c
                   || rec.PropStrength__Primary_Contact__c != oldOfferMap.get(rec.Id).PropStrength__Primary_Contact__c
                   || rec.PropStrength__Property__c != oldOfferMap.get(rec.Id).PropStrength__Property__c) {
                       offerHaveToBeCheck.add(rec);
                   }
            }
        }
        else {
            offerHaveToBeCheck.addAll(offerList);
        }
        if(!offerHaveToBeCheck.isEmpty()) {
            for(PropStrength__Offer__c offerRec : offerHaveToBeCheck) {
                if(offerRec.PropStrength__Broker_Account__c != null) {
                    brokerAccountId.add(offerRec.PropStrength__Broker_Account__c);
                }
                if(offerRec.PropStrength__Primary_Contact__c != null) {
                    primaryContactId.add(offerRec.PropStrength__Primary_Contact__c);
                }
            }
            
            
            List<Blacklisted__c> blackList = [SELECT Id, Channel_Partner__c, Customer__c, Unit__c, From_Date__c, To_Date__c,  RecordType.name 
                                              FROM Blacklisted__c 
                                              WHERE Blacklisted__c = true AND ((From_Date__c = null OR From_Date__c <= TODAY) AND (To_Date__c >= TODAY OR To_Date__c = null)) AND (Channel_Partner__c IN :brokerAccountId OR Customer__c IN: primaryContactId)];
            for(Blacklisted__c rec : blackList) {
                if(rec.RecordType.name  == 'Broker') {
                    blockIds.add(rec.Channel_Partner__c+'');
                }
                if(rec.RecordType.name == 'Customer') {
                    if(rec.Unit__c != null) {
                        blockIds.add(rec.Customer__c + '_' + rec.Unit__c);
                    }
                    else {
                        blockIds.add(rec.Customer__c + '_');
                    }
                }
            }
            
            for(PropStrength__Offer__c offerRec : offerList) {
                if(blockIds.contains(offerRec.PropStrength__Broker_Account__c+'')) {
                    offerRec.addError('This broker can not be selected on offer as it is blacklisted.');
                    continue;
                }
                if(offerRec.PropStrength__Primary_Contact__c != null &&  (blockIds.contains(offerRec.PropStrength__Primary_Contact__c+'_'+offerRec.PropStrength__Property__c) || blockIds.contains(offerRec.PropStrength__Primary_Contact__c+'_'))) {
                    offerRec.addError('Offer can not be created on this property for the selected contact as the contact is blacklisted.');
                }
            }
        }
    }
    
    public static void handleHasValues(list<PropStrength__Offer__c> offerNewList, map<Id,PropStrength__Offer__c> offerOldMap){
        System.debug('Hello test 2');
        map<string,string> fieldMapping = new map<string,string>();
        list<Offer_Attribution_Modelling__mdt> mappingList = [Select Offer_Source_Field__c,Offer_Hash_Field__c from Offer_Attribution_Modelling__mdt];
        for(Offer_Attribution_Modelling__mdt mapping : mappingList){
            if(mapping.Offer_Source_Field__c!=null && mapping.Offer_Hash_Field__c!=null){
                fieldMapping.put(mapping.Offer_Source_Field__c,mapping.Offer_Hash_Field__c);
            }
        }
        Set <String> fields = new Set <String>();
        for ( Schema.SObjectField objField : Schema.SObjectType.PropStrength__Offer__c.fields.getMap().values() ) {
            fields.add( objField.getDescribe().getName());
        }
        if(fieldMapping.size()>0){
            set<string> attributionFieldList = fieldMapping.keySet();
            List<PropStrength__Offer__c> insertOfferHasValues = new List<PropStrength__Offer__c>();
            for(PropStrength__Offer__c offerRec : offerNewList){
                for(string aField : attributionFieldList){
                    if( fields.contains(aField)) {
                        aField = aField.trim();
                        if(offerRec.get(aField) != null && offerRec.get(aField) != ''){
                            //   offerRec.put(fieldMapping.get(aField), OfferTriggerHelper.getSha256(string.valueOf(offerRec.get(aField))));
                        }
                    }
                }
            }
        }
    }
    
    public static String getSha256(String input)
    {
        Blob hash = Crypto.generateDigest('SHA-256', BLOB.valueOf(input));
        
        String encryptedString =EncodingUtil.convertToHex(hash);
        
        System.debug('encryptedString : '+encryptedString);
        return encryptedString;
    }
    
    //Added by Nishank Manwani on 15-Jan-2024 to check if the current date lies between two given dates.
    public static Boolean isTodayWithinRange(Date startDate, Date endDate) {
        Date today = System.Today();
        
        if (today >= startDate && today <= endDate) {
            return true;
        } else {
            return false;
        }
    }
    
    //Added By Nishank Manwani on 08-04-2024 to check Allocated SM
    public static void checkAllocatedSm(List<PropStrength__Offer__c> offerList) {
        Set<Id> propId = new Set<Id>();
        for(PropStrength__Offer__c off : offerList) {
            if(off.PropStrength__Property__c != null) {
                propId.add(off.PropStrength__Property__c);
            }
        }
        
        if(!propId.isEmpty()) {
            Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, Allocated_SM__c FROM PropStrength__Property__c 
                                                                                                 WHERE Id IN :propId]);
            
            for(PropStrength__Offer__c off : offerList) {
                if(off.PropStrength__Property__c != null) {
                    // if(propMap.get(off.PropStrength__Property__c).Allocated_SM__c == null) {
                    //     off.addError('Please Fill Allocated SM field on Property.');
                    // } else
                    if(propMap.get(off.PropStrength__Property__c).Allocated_SM__c != null && propMap.get(off.PropStrength__Property__c).Allocated_SM__c != UserInfo.getUserId()) {
                        off.addError('This user is not allowed to create Payment Request.');
                    }
                }
            }
        }
    }
    public static void updateBookFormCreated(List<PropStrength__Offer__c> offerList, Map<Id,PropStrength__Offer__c> oldOfferMap) {
        Map<String, String> vpToSalesOpsId = new Map<String, String>();
        for(Booking_Form_Mapping__mdt mdt : Booking_Form_Mapping__mdt.getAll().values()) {
            String vpId = String.valueOf(mdt.VP_User_Id__c).length() > 15 ? String.valueOf(mdt.VP_User_Id__c).subString(0,15) : String.valueOf(mdt.VP_User_Id__c);
            String salesOpsId = String.valueOf(mdt.Sales_Ops_Executive_Id__c).length() > 15 ? String.valueOf(mdt.Sales_Ops_Executive_Id__c).subString(0,15) : String.valueOf(mdt.Sales_Ops_Executive_Id__c);
            vpToSalesOpsId.put(vpId, salesOpsId);
        }
        for(PropStrength__Offer__c off : offerList) {
            // off.PropStrength__Status__c == 'Pre-Closed Won'
            if(off.Sales_VP__c != null && ( off.PropStrength__Status__c == 'Closed Won' || off.PropStrength__Status__c == 'Pre-Closed Won' ) && off.PropStrength__Status__c != oldOfferMap.get(off.Id).PropStrength__Status__c) {
                String vpId = String.valueOf(off.Sales_VP__c).length() > 15 ? String.valueOf(off.Sales_VP__c).subString(0,15) : String.valueOf(off.Sales_VP__c);
                if(vpToSalesOpsId.containsKey(vpId)) {
                    off.Booking_Form_to_be_Created_By__c = vpToSalesOpsId.get(vpId);
                }
            }
            // Gourav Gour, Conditions added on 23/08/2024
            if(off.PropStrength__Status__c == 'Discount Approved' && off.PropStrength__Approval_Status__c == 'Approved' && (off.PropStrength__Status__c != oldOfferMap.get(off.Id).PropStrength__Status__c || off.PropStrength__Approval_Status__c != oldOfferMap.get(off.Id).PropStrength__Approval_Status__c)) {
                off.PropStrength__Discount_Type__c = off.DiscountType_UM__c != null ? off.DiscountType_UM__c : null;
                off.PropStrength__Discount__c = off.Discount_UM__c != null ? off.Discount_UM__c : null;
                off.PropStrength__Discount_Amount__c = off.Discount_Amount_UM__c != null ? off.Discount_Amount_UM__c : null;
            }
        }
    }
    
    /* public static void invokeApprovalProcess(List<PropStrength__Offer__c> offerList, Map<Id,PropStrength__Offer__c> oldOfferMap) {
String approvalProcessName ='';
Id currentUserId = System.userInfo.getUserId();
User currentUser = [SELECT id, name, UserRole.Name FROM USER WHERE Id =:currentUserId];

String currentUserRoleName = currentUser.UserRole.Name ?? '';

if(String.isNotBlank(currentUser.UserRole.Name) && currentUserRoleName.containsIgnoreCase('Senior Vice President')) {
approvalProcessName = 'Offer_Closed_Won_Submitter_SVP';
}else if(String.isNotBlank(currentUser.UserRole.Name) && currentUserRoleName.containsIgnoreCase('Vice President')) {
approvalProcessName = 'Offer_Closed_Won_Submitter_VP';
}else if(String.isNotBlank(currentUser.UserRole.Name) && currentUserRoleName.containsIgnoreCase('Sales Manager')) {
approvalProcessName = 'Offer_Closed_Won_Submitter_SM';
}else if(String.isNotBlank(currentUser.UserRole.Name) && currentUserRoleName.containsIgnoreCase('Sales Head')) {
approvalProcessName = 'Offer_Closed_Won_Submitter_SH';
}else if(String.isNotBlank(currentUser.UserRole.Name) && currentUserRoleName.containsIgnoreCase('Chief Marketing Officer')) {
approvalProcessName = 'Offer_Closed_Won_Submitter_SH';
}
List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
for(PropStrength__Offer__c offer : offerList) {
id recordId = offer.id;
System.debug(Approval.isLocked(recordId));
if(!Approval.isLocked(recordId) && offer.PropStrength__Status__c != oldOfferMap.get(offer.id).PropStrength__Status__c && offer.PropStrength__Status__c == 'Pre-Closed Won') {
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Submitting request for approval ');
req1.setObjectId(offer.id);
req1.setProcessDefinitionNameOrId(approvalProcessName);
req1.setSkipEntryCriteria(true);
requests.add(req1);
}
}


Approval.ProcessResult[] processResults = null;
try {
processResults = Approval.process(requests, true);
}catch (System.DmlException e) {
System.debug('Exception Is ' + e.getMessage());
}
} */
    
    public static void afterUpdate(List<PropStrength__Offer__c> newList, Map<Id, PropStrength__Offer__c> oldMap) {
        List<PropStrength__Offer__c> listOfOfferRec =  new List<PropStrength__Offer__c>();
        System.debug(newList[0].Booked_Date__c+'**-***'+oldMap.get(newList[0].id).Booked_Date__c);
        for(PropStrength__Offer__c offrRec : newList){
            if(offrRec.Booked_Date__c != null && oldMap.get(offrRec.id).Booked_Date__c == null
               && offrRec.PropStrength__Status__c == 'closed won' ){
                   listOfOfferRec.add(offrRec);
               }
        }
        if(listOfOfferRec.size() > 0)
            updateCreateSBTR(listOfOfferRec, oldMap);
        
    }
    
    public static void updateCreateSBTR(List<PropStrength__Offer__c> newList, Map<Id, PropStrength__Offer__c> oldMap) {
        firstcall = true;
        List<SBTR__c> sbtrList = new List<SBTR__c>();
        //List<SBTR__c> newCreatedSbtr = new List<SBTR__c>();
        Map<Id,PropStrength__Offer__c> updateOfferSbtrCreatedDate = new Map<Id,PropStrength__Offer__c>();
        
        Map<String, List<SBTR__c>> offerIdBySBTRListMap = new Map<String, List<SBTR__c>>();
        Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap = new Map<String, List<Payment_Milestones__c>>();
        Map<String, Collection_Report__c> offerNameByCollReportMap = new Map<String, Collection_Report__c>();
        List<string> quottationIds = new List<string>();
        Boolean isInsert = oldMap == null;
        Boolean isUpdate = oldMap != null;
        List<String> oppList = new List<String>();
        List<String> NSAList = new List<String>();
        Map<String, List<PropStrength__Offer__c>> offerListMap = new Map<String, List<PropStrength__Offer__c>>();
        Map<String, List<PropStrength__Application_Booking__c>> bookingListMap = new Map<String, List<PropStrength__Application_Booking__c>>();
        List<date> bookingDate = new List<date>();
        List<string> applicantList = new List<string>();
        List<PropStrength__Offer__c> offerList = new List<PropStrength__Offer__c>();        
        Set<Id> ContactIds = new Set<Id>();
        for(PropStrength__Offer__c offer : [SELECT Id, Name, PropStrength__Property__r.PropStrength__Property_Name__c, PropStrength__Property__r.PropStrength__Super_Area__c, Booked_Date__c,Sales_Head__c, Secondary_Sales_Manager__c,
                                            Sales_VP__r.name,Secondary_Sales_VP__r.name,PropStrength__Saleable_Area__c, Sales_SVP__c, Sales_SVP__r.Name, 
                                            PropStrength__Property__r.PropStrength__Chargeable_Area__c,PropStrength__Property__c, Blocking_Amount_Paid__c,
                                            Sales_Manager__r.name, Secondary_Sales_Manager__r.name, Sales_Head__r.Name, Split_Deals__c,  Secondary_Sales_Head__r.name,    
                                            PropStrength__Broker_Account__c, PropStrength__Broker_Account__r.Name, PropStrength__Broker_Account__r.PropStrength__Broker_Code__c, PropStrength__Super_Area__c,Declared_Date__c,
                                            PropStrength__Request__c, PropStrength__Request__r.Type_Of_Enquiry__c,PropStrength__Total_Sales_Consideration__c, PropStrength__Request__r.PropStrength__Request_Source__c,
                                            PropStrength__Request__r.Enquiry_Source__c,Deal_Type_Wholesale_Retail__c, TowerName__c, PropStrength__Request__r.PropStrength__Enquiry_Close_Date__c,
                                            Approval_Date_and_Time__c,PropStrength__Project__c,PropStrength__Project__r.PropStrength__Sub_Category__c,
                                            Sales_Manager__r.Manager.name,Secondary_Sales_Manager__r.Manager.name, PropStrength__Request__r.Name,
                                            Sales_Manager__c,Secondary_Sales_Head__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Completion_Certificate_Date__c,
                                            PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.Name, PropStrength__Primary_Contact__r.PropStrength__Nationality__c
                                            FROM PropStrength__Offer__c WHERE Id IN:newList ]) {
                                                offerList.add(offer);
                                                ContactIds.add(offer.PropStrength__Primary_Contact__c);
                                            }
        
   
        Map<id,SBTR__c> sbtrListofPrevious = new Map<id,SBTR__c>();
        
        for(Quotation__c quotation : [SELECT Id,(SELECT Id, Milestone_Due_Date__c,Total_Installment__c,Charge1Percentage__c 
                                                 FROM Payment_Milestones__r order by Milestone_Due_Date__c Desc ) FROM Quotation__c WHERE Id IN:quottationIds]) {
                                                     quotationIdBypaymentmilstoneListMap.put(quotation.Id,quotation.Payment_Milestones__r);
                                                 }
        list<string> oldBookingId = new list<string>();
        Map<String, List<Cancelled_Unit_Detail__c>> NSAUnitListMap = new Map<String, List<Cancelled_Unit_Detail__c>>();
        for(unit_hold_request__c NSA : [SELECT Id,(select id,Old_Unit__r.name,Old_Booking_Date__c,Old_Booking__c from Exit_Unit_Details__r) 
                                        FROM unit_hold_request__c WHERE Id In: NSAList]) {
                                            NSAUnitListMap.put(NSA.Id,NSA.Exit_Unit_Details__r);
                                            for(Cancelled_Unit_Detail__c cancelledUnit : NSA.Exit_Unit_Details__r) {
                                                oldBookingId.add(cancelledUnit.Old_Booking__c);
                                            }
                                            
                                        }
        map<string,string> oldbbokingtoTo = new map<string,string>();
        
        Map<String, List<SBTR__c>> existingSBTRMap = new Map<String, List<SBTR__c>>();
        
        for(PropStrength__Application_Booking__c bk : [
            SELECT Id, PropStrength__Booking_Date__c, PropStrength__Primary_Applicant_Name__c FROM PropStrength__Application_Booking__c WHERE PropStrength__Primary_Applicant_Name__c IN:ContactIds
        ])
        {
            DateTime dT = bk.PropStrength__Booking_Date__c;
            Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
            if(bookingListMap.containsKey(d+'-'+bk.PropStrength__Primary_Applicant_Name__c)){
                bookingListMap.get(d+'-'+bk.PropStrength__Primary_Applicant_Name__c).add(bk);
            } else {
                bookingListMap.put(d+'-'+bk.PropStrength__Primary_Applicant_Name__c, new List<PropStrength__Application_Booking__c>{bk});
            }
        }
        
        
        
        for(PropStrength__Offer__c offer : offerList) {
            
            if ( (isUpdate || isInsert ) ){
                boolean checkbulkbooking = false;
                DateTime dT = offer.Booked_Date__c;
                Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
                if(bookingListMap.get(d+'-'+offer.PropStrength__Primary_Contact__c) != null && bookingListMap.get(d+'-'+offer.PropStrength__Primary_Contact__c).size() >= 3){
                    checkbulkbooking = true;
                }
                List<SBTR__c> existing = new List<SBTR__c>();
                offerIdBySBTRListMap.put(offer.Name, new List<SBTR__c>());
                updateOfferSbtrCreatedDate.put(offer.id, new PropStrength__Offer__c(id= offer.id, SBTR_Created__c = true));
                offerIdBySBTRListMap.get(offer.Name).add(createSBTR(offer,quotationIdBypaymentmilstoneListMap,checkbulkbooking,NSAUnitListMap,1,oldbbokingtoTo));
                System.debug(offerIdBySBTRListMap.size()+'--offerIdBySBTRListMap*---'+offerIdBySBTRListMap);
                if (offer.Split_Deals__c) {
                    updateOfferSbtrCreatedDate.put(offer.id, new PropStrength__Offer__c(id= offer.id, SBTR_Created__c = true));
                    offerIdBySBTRListMap.get(offer.Name).add(createSBTR(offer,quotationIdBypaymentmilstoneListMap,checkbulkbooking,NSAUnitListMap,2, oldbbokingtoTo));
                }
                System.debug(offerIdBySBTRListMap.size()+'--offerIdBySBTRListMap*---'+offerIdBySBTRListMap);
            }
            
        }
        for(Collection_Report__c collReport : [ SELECT Id, Booking__c FROM Collection_Report__c WHERE Booking__c IN :offerIdBySBTRListMap.keySet()]){
            offerNameByCollReportMap.put(collReport.Booking__c, collReport);
        }
        for(String offerName : offerIdBySBTRListMap.keySet()) {
            if (offerNameByCollReportMap.containsKey(offerName)) {
                for(SBTR__c sbtr : offerIdBySBTRListMap.get(offerName)) {
                    //sbtr.Collection_Report__c  = offerNameByCollReportMap.get(offerName).Id;
                    
                    //sbtrList.add(sbtr);
                }
            }
            else{
                //sbtrList.addAll( offerIdBySBTRListMap.get(offerName));
            }
        }
        
        
        
        System.debug('sbtrList*---'+sbtrList);
        if (!sbtrList.isEmpty()) {
            Upsert sbtrList;
            update updateOfferSbtrCreatedDate.values();
            isRunFirst = false;
        }
    }
    
    public static SBTR__c createSBTR(PropStrength__Offer__c offer,Map<String, List<Payment_Milestones__c>> quotationIdBypaymentmilstoneListMap,
                                     boolean checkbulkbooking,  Map<String, List<Cancelled_Unit_Detail__c>> NSAUnitListMap,
                                     integer checkSBTRNumber,map<string,string> oldbbokingtoTo) {
                                         SBTR__c sbtr = new SBTR__c();
                                         /*sbtr.Offer__c = offer.Id;
                                         sbtr.Booked_Date__c = offer.Booked_Date__c;
                                         sbtr.Channel_Partner__c = offer.PropStrength__Broker_Account__c;                                         
                                         integer checkApplicant = 1;
                                         string applicantName;
                                         sbtr.Unit__c = offer.PropStrength__Property__c;
                                         sbtr.Sales_Manager__c = offer.Sales_Manager__r.name;
                                         sbtr.Secondary_Sales_Manager__c = offer.Secondary_Sales_Manager__r.Name;
                                         sbtr.Name_of_Party__c = offer.PropStrength__Primary_Contact__c != null ? offer.PropStrength__Primary_Contact__r.Name : null;
                                        // sbtr.Primary_Customer_Nationality__c = offer.PropStrength__Primary_Contact__c != null ? offer.PropStrength__Primary_Contact__r.PropStrength__Nationality__c != null ? offer.PropStrength__Primary_Contact__r.PropStrength__Nationality__c: null : null;
                                         system.debug('checkSBTRNumber'+checkSBTRNumber);
                                         
                                         if(checkSBTRNumber == 1){
                                             //sbtr.Attended_by__c = offer.Sales_Manager__r.name; // add this 1 and 2
                                             sbtr.Sales_Manager__c = offer.Sales_Manager__r.name;
                                             sbtr.Team_Head_2__c = offer.Secondary_Sales_VP__r.name;
                                             sbtr.Sales_Head__c =  offer.Sales_Manager__r.Manager.name;
                                         }
                                         else if(checkSBTRNumber != null){
                                            // sbtr.Attended_by__c = offer.Secondary_Sales_Manager__r.Name; // add this 1 and 2
                                             sbtr.Sales_Manager__c = offer.Secondary_Sales_Manager__r.name;
                                             //sbtr.Team_Head__c = offer.Sales_VP__r.name;
                                             //sbtr.Team_Head_2__c = offer.Secondary_Sales_VP__r.name;
                                             sbtr.Sales_Head__c =  offer.Secondary_Sales_Manager__r.Manager.name;
                                         }
                                        // sbtr.Saleable_Area_sq_ft__c = offer.PropStrength__Super_Area__c;
                                         //sbtr.Sale_Value_AED__c = offer.Purchase_Price_Only__c;
                                         sbtr.Chargeable_Area_sq_ft__c = offer.PropStrength__Super_Area__c;
                                         sbtr.Bulk_Deal__c= checkbulkbooking;
                                         if(checkbulkbooking)
                                         {
                                             sbtr.Bulk_Booking_Date__c= date.valueof(offer.Booked_Date__c);
                                         }
                                         // sbtr.Project_Sub_Type__c = offer.PropStrength__Project__r.PropStrength__Sub_Category__c ; // field does not exist
                                         sbtr.Opportunity_Date_PS__c = offer.PropStrength__Request__c != null ? offer.PropStrength__Request__r.PropStrength__Enquiry_Close_Date__c != null ? offer.PropStrength__Request__r.PropStrength__Enquiry_Close_Date__c : null : null;
                                         sbtr.Source_Classification_1__c = offer.PropStrength__Request__c != null ? offer.PropStrength__Request__r.Type_Of_Enquiry__c != null ? offer.PropStrength__Request__r.Type_Of_Enquiry__c : null : null;
                                         sbtr.Source_Classification_2__c = offer.PropStrength__Request__c != null ? offer.PropStrength__Request__r.PropStrength__Request_Source__c != null ? offer.PropStrength__Request__r.PropStrength__Request_Source__c : null : null;
                                         sbtr.Sale_Value_at_Offer_Level__c = offer.PropStrength__Total_Sales_Consideration__c != null ? offer.PropStrength__Total_Sales_Consideration__c : null;
                                         //sbtr.Name_of_Party__c = offer.Source_Classification_1__c;
                                         sbtr.Broker_Company_Name_Offer__c = offer.PropStrength__Broker_Account__c != null ? offer.PropStrength__Broker_Account__r.Name : null;
                                         sbtr.Project_SubType__c = offer.TowerName__c != null ? offer.TowerName__c : null;
                                         sbtr.Attended_by__c = offer.Split_Deals__c ? offer.Secondary_Sales_Manager__r.Name : offer.Sales_Manager__r.name;
                                         sbtr.Saleable_Area_sq_ft__c = offer.PropStrength__Property__c != null? Offer.PropStrength__Property__r.PropStrength__Super_Area__c : null;
                                         sbtr.Initial_POP_Date__c = offer.Approval_Date_and_Time__c != null ? offer.Approval_Date_and_Time__c.date() : null;
                                         sbtr.Sr_VP_PS__c = offer.Sales_SVP__c != null ? offer.Sales_SVP__r.Name : null;
                                         // sbtr.CM_Product_Group__c = offer.Source_Classification_1__c;
                                         sbtr.Deal_Type__c = offer.Deal_Type_Wholesale_Retail__c;
                                         sbtr.Manual_BookingAmount_Received__c = offer.Blocking_Amount_Paid__c != null ? offer.Blocking_Amount_Paid__c : null;
                                         sbtr.SFDC_CPID__c = offer.PropStrength__Broker_Account__c != null ?  offer.PropStrength__Broker_Account__r.PropStrength__Broker_Code__c != null ? offer.PropStrength__Broker_Account__r.PropStrength__Broker_Code__c : null : null;
                                         sbtr.Team_Head__c = offer.Sales_VP__r.name;
                                         sbtr.CM_Include__c = 'Yes';
                                         sbtr.Opportunity_ID_PS__c  = offer.PropStrength__Request__c != null ? offer.PropStrength__Request__r.Name : null;
                                         sbtr.Collection_10__c = 'No'; //  check chnage condition
                                          sbtr.Team_Head_2__c = offer.Secondary_Sales_VP__r.name;
                                         sbtr.Declared_Date__c = offer.Declared_Date__c;*/
                                         return sbtr;
                                     }
    
    public static void SBTRValidation(List<PropStrength__Offer__c> newList, Map<Id, PropStrength__Offer__c> oldMap) {
        for(PropStrength__Offer__c offrRec : newList){
            if( offrRec.Booked_Date__c != oldMap.get(offrRec.id).Booked_Date__c &&
               offrRec.Booked_Date__c != null && oldMap.get(offrRec.id).Booked_Date__c != null
               && offrRec.PropStrength__Status__c == 'closed won' ){
                   offrRec.addError('You cannot change the date value, SBTR has already been created.');
               }
        }
    }
    
    public static void giveAccessOfRecord(List<PropStrength__Offer__c> enqList, Map< id, PropStrength__Offer__c> oldMap){
        Map<Id, Id> enqSalesManagerMap = new Map<Id,Id>();
        Set<Id> offerIdSet = new Set<Id>();
        for(PropStrength__Offer__c enq : enqList){
            if(oldMap == null && enq.Sales_Manager__c != null || (oldmap != null &&  enq.Sales_Manager__c != null && oldMap.get(enq.id).Sales_Manager__c != enq.Sales_Manager__c)){
                enqSalesManagerMap.put(enq.id, enq.Sales_Manager__c);
            }
            if(oldmap != null &&  oldMap.get(enq.id).Sales_Manager__c != null && oldMap.get(enq.id).Sales_Manager__c != enq.Sales_Manager__c){
                
                offerIdSet.add(enq.id);
                
            }
        }
        
        if(offerIdSet.size()>0){
            List<PropStrength__Offer__Share> recordsToDelete = [SELECT Id 
                                                                FROM PropStrength__Offer__Share 
                                                                WHERE ParentId IN :offerIdSet ];
            
            if(!recordsToDelete.isEmpty()){
                try{
                    Database.Delete(recordsToDelete, false);
                }
                catch(Exception e ){
                    system.debug(' exception here');
                }
            }
        }
        if(enqSalesManagerMap.size()>0){
            List<PropStrength__Offer__Share> jobList = new List<PropStrength__Offer__Share>();
            for(Id enqid : enqSalesManagerMap.keyset()){
                PropStrength__Offer__Share jobShr  = new PropStrength__Offer__Share();
                
                jobShr.ParentId = enqid;
                jobShr.UserOrGroupId = enqSalesManagerMap.get(enqid);
                
                jobShr.AccessLevel = 'Read';
                
                jobShr.AccessLevel = 'Edit';
                
                jobList.add(jobShr);
                
                
            }
            if(jobList.size()>0){
                try{
                    Database.SaveResult[] lsr = Database.insert(jobList,false);
                }
                catch(Exception e ){
                    system.debug(' exception here');
                }
                
            }
            
        }
    }
}