global Class UnitHoldController {
    @AuraEnabled
    public static string submit(string recordId) {
        Units_Hold_For_SM__c req = [SELECT Id, Status_O__c, Approval_Status__c, (SELECT Id FROM Attachments) FROM Units_Hold_For_SM__c WHERE Id =: recordId];
        //System.Assert(false,'test:'+req.Approval_Status__c);
        List<ContentDocumentLink> cList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        String txt = '';
        if(req.Approval_Status__c == '' || req.Approval_Status__c == null || Test.isRunningTest()) {
            Boolean flag = false;
            Boolean up = false;
            if(req.Status_O__c == 'Payment Collected') {
                if(req.Attachments.size() > 0 || cList.size() > 0) {
                
                ///*Meena: Code for validation of Unit Hold
                /* Units_Hold_For_SM__c unit_blck= [SELECT Id,Unit__C,Status_O__c,Approval_Status__c FROM Units_Hold_For_SM__c WHERE Id =: recordId];
                Units_Hold_For_SM__c cnt = [SELECT Id FROM Units_Hold_For_SM__c WHERE Unit__c =: unit_blck.Unit__C AND Status_O__c='Payment Collected' AND Approval_Status__c='Approved'];
                
                if(cnt.Id != null || cnt.Id !='')
                {
                throw new AuraHandledException('Unit is already booked. Please select another unit');

                }*/
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); req1.setComments('Submitting request for approval'); req1.setObjectId(req.id); Approval.ProcessResult result = Approval.process(req1); flag = result.isSuccess();
                }else {
                    up = true;
                }
            }else {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval');
                req1.setObjectId(req.id);
                Approval.ProcessResult result = Approval.process(req1);
                flag = result.isSuccess();
            }
            if(up) {
                txt = 'Please upload the Proof of Payment before submitting the record for approval.';
            }else {
                if(!flag) {
                    txt = 'Unable to submit the record for approval ! Please contact system administrator';
                }else {
                    txt = 'Record has been submitted for approval';
                }
            }  
        } 
            if(req.Approval_Status__c == 'Pending for Approval') {
                txt = 'Record has been submitted for approval already ! Please wait for the approver\'s response.';
            }else if(req.Approval_Status__c == 'Approved') {
                txt = 'Record has been Approved already !';
            }else if(req.Approval_Status__c == 'Rejected') {
                txt = 'Record has been Rejected already !';
            }
        
        return txt;
    }

    @InvocableMethod(label='Assign to Queue')
    public static void updateNSABookingFormUser(List<Id> newSaleApprovalIds) {

        String sbfUserId;
        Id newSaleApprovalId = newSaleApprovalIds[0];
        List<Booking_Form_Mapping__mdt> bookingFormMetadata = [SELECT ID,	Sales_Ops_Executive_Id__c, VP_User_Id__c FROM Booking_Form_Mapping__mdt];
        Map<Id,Id> mapVpToExecutiveId = new Map<Id,Id>();
        for(Booking_Form_Mapping__mdt mapping :bookingFormMetadata ){
            mapVpToExecutiveId.put(mapping.VP_User_Id__c, mapping.Sales_Ops_Executive_Id__c);
        }
        unit_hold_request__c newSaleReq = [Select id,Booking_Form_To_be_Created_By__c,Sales_Head_VP__c  From unit_hold_request__c where id=:newSaleApprovalId];
        if(newSaleReq.Sales_Head_VP__c != null && mapVpToExecutiveId.containsKey(newSaleReq.Sales_Head_VP__c)){
            newSaleReq.Booking_Form_To_be_Created_By__c = mapVpToExecutiveId.get(newSaleReq.Sales_Head_VP__c);
            update newSaleReq;
        
        }
    }
}