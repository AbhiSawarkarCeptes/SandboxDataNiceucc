public class NewSaleApprovalClass {
    @InvocableMethod (label='Update PR With New Sale Approval')
    public static void updatePRWithNewSaleApproval(List<Id> nsaList){
        try{
            list<Payment_Request__c> prListToUpdate = new list<Payment_Request__c>();
            set<string> unitIds = new set<string>();
            map<string,string> prToNewSalesApproval = new map<string,string>();
            for(unit_hold_request__c nsa : [select Id,Payment_Request__c,Payment_Request__r.Unit__c,Payment_Request__r.Name__c,Payment_Request__r.Email__c,Payment_Request__r.Mode_Option__c from unit_hold_request__c where Id IN: nsaList]){
                if(nsa.Payment_Request__c != null){
                    if(nsa.Payment_Request__r.Mode_Option__c == 'Single Mode'){
                        Payment_Request__c pr = new Payment_Request__c(Id=nsa.Payment_Request__c);
                        pr.New_Sale_Approval__c = nsa.Id;
                        prListToUpdate.add(pr);
                    }
                    else if(nsa.Payment_Request__r.Mode_Option__c == 'Multi Mode'){
                        if(nsa.Payment_Request__r.Unit__c != null){
                            unitIds.add(nsa.Payment_Request__r.Unit__c);
                            string key = nsa.Payment_Request__r.Unit__c+'##'+nsa.Payment_Request__r.Name__c+'##'+nsa.Payment_Request__r.Email__c;
                            prToNewSalesApproval.put(key,nsa.Id);
                        }
                    }
                }
            }
            if(unitIds.size()>0){
                for(Payment_Request__c pReq : [select Id,Unit__c,Name__c,Email__c,New_Sale_Approval__c from Payment_Request__c where Unit__c IN: unitIds and Mode_Option__c = 'Multi Mode']){
                    string k = pReq.Unit__c+'##'+pReq.Name__c+'##'+pReq.Email__c;
                    if(prToNewSalesApproval.containsKey(k)){
                        pReq.New_Sale_Approval__c = prToNewSalesApproval.get(k);
                        prListToUpdate.add(pReq);
                    }
                }
            }   
            if(prListToUpdate.size()>0){
                update prListToUpdate;
            }
        }
        catch(Exception e){
            system.debug('UpdatePRWithNewSaleApproval Error: '+e.getMessage());
        }
    }
}