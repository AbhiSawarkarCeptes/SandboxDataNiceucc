public with sharing class DocusignRecipientStatusTgrHandler {
    public static void updateTransRequest(List<dfsle__RecipientStatus__c> trsList, Map<Id, dfsle__RecipientStatus__c> trsMap) {
        Map<Id, dfsle__RecipientStatus__c> recipientRec = new Map<Id, dfsle__RecipientStatus__c>([SELECT Id , dfsle__EnvelopeStatus__c,Application_Booking__c,dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.name, dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.Email,dfsle__EnvelopeStatus__r.Application_Booking__c,Broker_Ledger__c,dfsle__EnvelopeStatus__r.Broker_Ledger__c,
                                                                                                  dfsle__EnvelopeStatus__r.Application_Booking__r.House_Unit_No__c,dfsle__EnvelopeStatus__r.Envelope_Type__c, dfsle__EnvelopeStatus__r.Transaction_Request__c,dfsle__Status__c, Transaction_Request__c, dfsle__EnvelopeStatus__r.Broker_Account__c, dfsle__EnvelopeStatus__r.Broker_Renewal__c FROM  dfsle__RecipientStatus__c WHERE Id  =: trsList]);
        List<PropStrength__Transaction_Requests__c> trUpdate = new List<PropStrength__Transaction_Requests__c>();
        List<PropStrength__Application_Booking__c> bookingUpdate = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> bookingUpdate1 = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> bookingUpdate2 = new List<PropStrength__Application_Booking__c>();
        List<PropStrength__Application_Booking__c> bookingUpdate3 = new List<PropStrength__Application_Booking__c>();
        List<Account> accList = new List<Account>();
        List<Broker_Renewal__c> brokerRenewList = new List<Broker_Renewal__c>();
        List<PropStrength__Broker_Ledger__c> BrokerLedgerList = new List<PropStrength__Broker_Ledger__c>();
        List<String> bookingIds = new List<String>();
        List<String> bookingIdsforGroup = new List<String>();
        String lastApplicantName = '';
        String UserId = '';
        List<String> applicantId = new List<String>();
        List<String> statusId = new List<String>();
        for(dfsle__RecipientStatus__c rec : trsList) {
            System.debug('rec*----'+rec.Name);
            statusId.add(rec.id);
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Booking Form') {
                bookingIds.add(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c);
                if(rec.name.contains('AD'))
                    applicantId.add(rec.dfsle__Email__c);
            }
            System.debug('applicantId**-'+applicantId);
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Booking Form' && rec.Name == 'Sales Head' && rec.dfsle__Status__c == 'Completed') {
                bookingIdsforGroup.add(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c);
            }
        }
        List<PropStrength__Application_Booking__c> bookingRecList = [SELECT Id, SBF_Assigned_To__c  FROM PropStrength__Application_Booking__c
                                                                  WHERE Id =: bookingIds];
        
        List<dfsle__RecipientStatus__c> trsListDESC = [SELECT id,name,dfsle__Status__c, dfsle__Sequence__c FROM dfsle__RecipientStatus__c WHERE Id In: statusId order by createddate DESC];
        
        List<PropStrength__Group_Member__c> listOfGrpmem = new List<PropStrength__Group_Member__c>();
        if(bookingIdsforGroup.size() > 0 && bookingRecList.size() > 0 && bookingRecList[0].SBF_Assigned_To__c == null){
            List<PropStrength__Group_Member__c> groupMemberRec = [SELECT Id,PropStrength__Assignment_Group__c,PropStrength__Active__c, PropStrength__Assignment_Group__r.PropStrength__Active__c,PropStrength__Order__c
                                                                  ,PropStrength__Last_Assigned__c,PropStrength__User__c FROM PropStrength__Group_Member__c WHERE PropStrength__Assignment_Group__r.Name = 'SBF Assignment' Order by PropStrength__Order__c ASC];
            Integer i=1;
            Integer j=0;
            String firstUserId = '';
            String firstUserGroupId = '';
            String prevGroupMemberId = '';
            for(PropStrength__Group_Member__c groupMember : groupMemberRec){
                if(i==1){
                    firstUserId =  groupMember.PropStrength__User__c;
                    firstUserGroupId = groupMember.Id;
                }
                if(groupMember.PropStrength__Last_Assigned__c){
                    PropStrength__Group_Member__c grpMen = new PropStrength__Group_Member__c();
                    grpMen.Id = groupMember.Id;
                    grpMen.PropStrength__Last_Assigned__c = false;
                    listOfGrpmem.add(grpMen);
                    prevGroupMemberId = groupMember.PropStrength__User__c;
                    j = i + 1;
                    if(groupMemberRec.size() == i){
                        PropStrength__Group_Member__c CurrentgrpMen = new PropStrength__Group_Member__c();
                        CurrentgrpMen.Id = firstUserGroupId;
                        CurrentgrpMen.PropStrength__Last_Assigned__c = true;
                        listOfGrpmem.add(CurrentgrpMen);
                        UserId = firstUserId;
                        break;
                    }
                }
                if(i == j){
                    PropStrength__Group_Member__c CurrentgrpMen1 = new PropStrength__Group_Member__c();
                    CurrentgrpMen1.Id = groupMember.Id;
                    CurrentgrpMen1.PropStrength__Last_Assigned__c = true;
                    listOfGrpmem.add(CurrentgrpMen1);
                    UserId = groupMember.PropStrength__User__c;
                    break;
                }
                i++;
            }
            System.debug('--*tt--'+UserId);
            System.debug('--*tt--'+listOfGrpmem);
            if(listOfGrpmem.size() > 0){
                update listOfGrpmem;
            }
            
        }
        Map<String,PropStrength__Applicant_Detail__c> mapOfBookingAndAppDetail = new Map<String,PropStrength__Applicant_Detail__c>();
        Integer i=1;
        List<PropStrength__Applicant_Detail__c> applicants = [SELECT Id, Name,Signed_By_Applicant__c , PropStrength__Applicant_Email__c,PropStrength__Applicant_Acc__c, PropStrength__Applicant_Mobile__c, PropStrength__Type__c, 
                                                              PropStrength__Applicant_Acc__r.PropStrength__Account_Type__c, PropStrength__Applicant_Acc__r.name
                                                              FROM PropStrength__Applicant_Detail__c
                                                              WHERE PropStrength__Application__c IN: bookingIds AND PropStrength__Active__c = TRUE AND Send_for_Docusign__c = true 
                                                              ORDER BY PropStrength__Type__c ASC];
        for(PropStrength__Applicant_Detail__c appDetail : applicants){
            mapOfBookingAndAppDetail.put(appDetail.name, appDetail);
            if(i == applicants.size())
                lastApplicantName = appDetail.name;
            i++;
        }
        List<PropStrength__Applicant_Detail__c> updateApplicantList = new List<PropStrength__Applicant_Detail__c>();
        List<OrgWideEmailAddress> owdEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress limit 1];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(dfsle__RecipientStatus__c rec : trsListDESC) {
            System.debug('-----TestingDeepak---->'+ recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c);
            System.debug('-----TestingDeepak---->'+ rec.dfsle__Status__c);
            System.debug('-----TestingDeepak---->'+ rec.Name);
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'SPA') {
                if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'SPA Executed',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, SPA_Execution_Date__c = System.Now()));
                    break;
                }
                else if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(SPA_Signed_by_Authorised_Signatory_Date__c = System.now(), PropStrength__Status__c = 'SPA Sent to CRM Controller for Stamp',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'SPA Sent to Seller Representative for Signature',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, SPA_Verified_By_Audit__c = true, SPA_Verified_by_Audit_Date__c = System.Now()));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'SPA Sent to Audit for Verification', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, Digi_Signed_SPA_Received_From_Customer__c = true, SPA_Sent_for_Audit_Verification__c = true, SPA_Sent_for_Audit_Verification_Date__c = System.Now()));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Declined') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Rejected by Audit', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, SPA_Rejected_by_Audit_Date__c = System.Now()));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'MOU') {
                if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'MOU Executed',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'MOU Sent to CRM Controller for Stamp', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, MOU_Signed_by_Final_Approvers__c = true));
                    break;
                }
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Customer Signed MOU sent for Final Approval',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, MOU_Sent_for_Final_Approval_Date__c = System.Now(), MOU_Sent_for_Final_Approval__c = true, MOU_Verified_by_Audit_Date__c = System.Now(), MOU_Verified_by_Audit__c = true));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'Customer Signed MOU sent to Audit team for Verification',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, Signed_MOU_Sent_for_Audit_Verification__c = true, Signed_MOU_Sent_to_Audit_Date__c = System.Now(), MOU_Signed_by_the_Customer_Date__c =  System.Now(), MOU_Signed_by_the_Customer__c = true));
                    break;
                }
                else if(rec.Name.contains('AD ') && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'MOU Sent to Customer for Digital Signature', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, MOU_Sent_to_Customer_for_Digi_Sign__c = true, MOU_Sent_to_Customer_for_Digi_Sign_Date__c = System.Now(), MOU_Verification_Date__c = System.Now(), MOU_Verified_by_Development_Legal_Team__c = true));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'DSPA') {
                if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'DSPA Executed',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'DSPA Sent to CRM Controller for Stamp',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, DSPA_Signed_by_Final_Approvers__c = true));
                    break;
                }
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'DSPA Sent to Seller Representative for Signature',Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, DSPA_Verified_By_Audit__c = true, DSPA_Verified_by_Audit_Date__c = System.Now(), DSPA_Sent_for_Final_Signature__c = true ,DSPA_Sent_for_Final_Signature_Date__c = System.Now()));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(PropStrength__Status__c = 'DSPA Sent to Audit for Verification', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c, Digi_Signed_DSPA_Received_From_Customer__c = true, DSPA_Sent_for_Audit_Verification__c = true, DSPA_Sent_for_Audit_Verification_Date__c = System.Now()));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Booking Form') {
                System.debug(rec.Name+'--lastApplicantName*---*--*'+lastApplicantName);
                if(mapOfBookingAndAppDetail.containskey(rec.Name) && rec.dfsle__Status__c == 'Completed' && mapOfBookingAndAppDetail.get(rec.Name).Signed_By_Applicant__c == false ){
                    System.debug(rec.Name+'*---*--*'+rec.dfsle__Status__c);
                    PropStrength__Applicant_Detail__c appDetailRec = new PropStrength__Applicant_Detail__c();
                    appDetailRec.Id = mapOfBookingAndAppDetail.get(rec.Name).Id;
                    appDetailRec.Signed_By_Applicant__c = true;
                    updateApplicantList.add(appDetailRec);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(rec.Name == lastApplicantName && mapOfBookingAndAppDetail.containskey(lastApplicantName)){
                        
                        if(owdEmail.size() > 0) {
                            email.setOrgWideEmailAddressId(owdEmail.get(0).Id);
                        }
                        email.setTargetObjectId(mapOfBookingAndAppDetail.get(rec.Name).PropStrength__Applicant_Acc__c);
                        
                        email.setSubject('Confirmation regarding the recent Docusign for Unit '+recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.House_Unit_No__c+'.');
                        email.setHtmlBody('Dear '+mapOfBookingAndAppDetail.get(rec.Name).PropStrength__Applicant_Acc__r.name+'<br/><br/>Greetings from Sobha!<br/><br/> Thank you form completing Docusign for the unit no.' +recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.House_Unit_No__c
                            +'.<br/><br/> This is to acknowledge that your signed booking form has been submitted and well received by us at Sobha Realty. It will be now verified by our internal team. If anything is required will be required,then our sales team will contact you. <br/><br/> Upon completion of internal validation process, you will receive executed booking on your registered email id.<br/><br/> For any further queries please contact '+
                            recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.name+' with email -'+ recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.Email);
                        
                    }
                    else{
                        if(owdEmail.size() > 0) {
                            email.setOrgWideEmailAddressId(owdEmail.get(0).Id);
                        }
                        email.setTargetObjectId(mapOfBookingAndAppDetail.get(rec.Name).PropStrength__Applicant_Acc__c);
                        email.setSubject('Confirmation regarding the recent Docusign '+recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.House_Unit_No__c+'.');
                        email.setHtmlBody('Dear '+mapOfBookingAndAppDetail.get(rec.Name).PropStrength__Applicant_Acc__r.name+'<br/><br/>'+ 'Greetings from Sobha!<br/><br/> Thank you form completing Docusign for the unit no.' +recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.House_Unit_No__c
                            +'.<br/><br/> This is to acknowledge that your signed booking form has been submitted. It has now been forwarded to the next applicant to complete Docu Sign process. Once all signatures will be completed from other applicant/s, booking form will be submitted for verification to our internal team.'
                            +'If anything is required will be required, then our sales team will contact you. <br/><br/> Upon completion of internal validation process, you will receive executed booking on your registered email id.<br/><br/> For any further queries please contact '+
                            recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.name+' with email -'+ recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__r.Sales_Manager__r.Email +'.');
                    }
                    
                    allmsg.add(email);
                }
                
                System.debug(rec.Name+'booking*---'+rec.dfsle__Status__c);
                //  Commented By Gourav Gour 9/8/2024
               /* if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    bookingUpdate.add(new PropStrength__Application_Booking__c( Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c, Booking_Form_Executed__c = true));
                    
                }*/
                if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Completed' && recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c != null) {
                    bookingUpdate.add(new PropStrength__Application_Booking__c( Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c, Booking_Form_Executed__c = true));
                    
                }
                // Updated By Gourav Gour 9/8/2024
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    bookingUpdate1.add(new PropStrength__Application_Booking__c(PropStrength__Status__c = 'Audit Approved',
                                            Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c,
                                            Booking_Form_Verified__c = true, Current_Status__c = 'Audit Accepted',
                                            Booking_Form_Verified_by_Audit_Date__c = System.Today()));
                }
                // Updated By Gourav Gour 9/8/2024
                else if(rec.Name == 'Broker Account' && rec.dfsle__Status__c == 'Sent') {
                    bookingUpdate3.add(new PropStrength__Application_Booking__c(Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c,
                                                                                Booking_Form_Signed_by_Customer__c = true, Current_Status__c = 'Signed by Client', Signed_Date__c = System.now()));
                    
                }
                else if(rec.Name == 'Sales Operations' && rec.dfsle__Status__c == 'Sent' && bookingRecList.size() > 0 && bookingRecList[0].SBF_Assigned_To__c == null) {
                    bookingUpdate2.add(new PropStrength__Application_Booking__c(SBF_Assigned_To__c = UserId,
                    Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Application_Booking__c) );
                    
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Transfer & Assignment') {
                if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(T_A_Agreement_Stamped_by_CRM_Controller__c = System.now(), Agreement_Docusign_Completed__c = true, PropStrength__Status__c = 'T&A Agreement Stamped by CRM Controller', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(T_A_Agreement_Sent_to_CRM_Controller__c = System.now(), T_A_Agreement_Signed_by_Seller_Rep__c = System.now(), PropStrength__Status__c = 'T&A Agreement Sent to CRM Controller', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( T_A_Agreement_Sent_to_Seller_Rep__c = System.now(), T_A_Agreement_Approved_by_Audit__c = System.now(), PropStrength__Status__c = 'T&A Agreement Sent to Seller Representative', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( T_A_Agreement_Sent_to_Audit_for_Approval__c = System.now(), T_A_Agreement_Signed_by_Buyer__c = System.now(), PropStrength__Status__c = 'T&A Agreement Sent to Audit for Approval', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Buyer 1' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( T_A_Agreement_Signed_by_Seller__c = System.now(), T_A_Agreement_Sent_to_Buyer_for_Digi__c = System.now(), PropStrength__Status__c = 'T&A Agreement Sent to Buyer for Digi Sign', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Applicant 1' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( T_A_Agreement_Sent_to_Seller_for_Digi__c = System.now(), PropStrength__Status__c = 'T&A Agreement Sent to Seller for Digi Sign', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'NOC TR') {
                if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Completed') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(NOC_Stamped_by_CRM_Controller__c = System.now(), NOC_DocSign_Completed__c = true, PropStrength__Status__c = 'NOC Stamped by CRM Controller', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'CRM Document Controller' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c(NOC_Sent_to_CRM_Controller__c = System.now(), NOC_Signed_by_Seller_Representative__c = System.now(), PropStrength__Status__c = 'NOC Sent to CRM Controller for Stamp', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Seller Representative' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( NOC_Sent_to_Seller_Rep_for_Signature__c = System.now(), NOC_Approved_by_Audit__c = System.now(), PropStrength__Status__c = 'NOC Sent to Seller Representative for Signature', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
                else if(rec.Name == 'Audit Team' && rec.dfsle__Status__c == 'Sent') {
                    trUpdate.add(new PropStrength__Transaction_Requests__c( NOC_Sent_to_Audit_for_Approval__c = System.now(), PropStrength__Status__c = 'NOC Sent to Audit for Approval', Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Transaction_Request__c));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Broker Agreement') {
                if(rec.dfsle__Sequence__c == 2 && rec.dfsle__Status__c == 'Sent') {
                    accList.add(new Account(Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Broker_Account__c, PropStrength__Broker_Approval_Status__c = 'Agreement created and sent for signature', Agreement_Created_Sent_Date__c = System.Today()));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Broker Renew Agreement') {
                if(rec.dfsle__Sequence__c == 2 && rec.dfsle__Status__c == 'Sent') {
                    brokerRenewList.add(new Broker_Renewal__c(Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Broker_Renewal__c, Broker_Approval_Status__c = 'Agreement created and sent for signature'));
                    break;
                }
            }
            if(recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Envelope_Type__c == 'Invoice') {
                if(rec.dfsle__Status__c == 'Sent') {
                    BrokerLedgerList.add(new PropStrength__Broker_Ledger__c(Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Broker_Ledger__c, PropStrength__Approval_Status__c = 'Invoice Sent for Signature'));
                    break;
                }
                if(rec.dfsle__Status__c == 'Completed') {
                    BrokerLedgerList.add(new PropStrength__Broker_Ledger__c(Id = recipientRec.get(rec.Id).dfsle__EnvelopeStatus__r.Broker_Ledger__c, PropStrength__Approval_Status__c = 'Signed Invoice Received'));
                    break;
                }
            }
        }
        System.debug('___testing__'+trUpdate);
        if(!trUpdate.isEmpty()) {
            update trUpdate;
        }
        System.debug('___testing__'+bookingUpdate);
        if(!bookingUpdate.isEmpty()) {
            update bookingUpdate;
        }
        if(!bookingUpdate1.isEmpty()) {
            update bookingUpdate1;
        }
        if(!bookingUpdate2.isEmpty()) {
            update bookingUpdate2;
        }
        if(!bookingUpdate3.isEmpty()) {
            update bookingUpdate3;
        }
        if(!updateApplicantList.isEmpty()) {
            update updateApplicantList;
        }
        if(!accList.isEmpty()) {
            update accList;
        }
        if(!brokerRenewList.isEmpty()) {
            update brokerRenewList;
        }
        if(!BrokerLedgerList.isEmpty()) {
            update BrokerLedgerList;
        }
        if(allmsg.size() > 0){
            System.debug('allmsg*----'+allmsg);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(allmsg);
            inspectResults(results);
        }
    }
    
    // Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        // sendEmail returns an array of result objects.
        // Iterate through the list to inspect results.
        // In this class, the methods send only one email,
        // so we should have only one result.
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());
            }
        }
        return sendResult;
    }
}