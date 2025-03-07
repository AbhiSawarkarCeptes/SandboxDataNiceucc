public with sharing class BrokerRenewalNOCDocusignUtil {
    public static Broker_Renewal__c getBrokerRenewal(Id renewId) {
        Broker_Renewal__c renew = [SELECT Id, Name_as_per_trade_license__c, Mobile_No__c, Al_Siniya_Partner__c,
                        Email_ID_1__c, Broker_Category_Type_Doc__c, Owner.Name, CreatedDate
                        FROM Broker_Renewal__c 
                        WHERE id=:renewId LIMIT 1];
        return renew;
    }
    public static Id getFileId(Id renewId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:renewId 
                                                AND ContentDocument.title LIKE 'NOC -%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        if(docList.size() > 0) {
            return docList[0].ContentDocumentId;
        }
        return null;
    }
    public static Id getFileId1(Id renewId) {
        List<ContentDocumentLink> docList = [SELECT ContentDocumentId,ContentDocument.title,Id,LinkedEntityId,ShareType 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:renewId 
                                                AND ContentDocument.title LIKE 'Agreement -%'
                                                ORDER BY ContentDocument.CreatedDate desc];   
        if(docList.size() > 0) {
            return docList[0].ContentDocumentId;
        }
        return null;
    }
    public static void docusignPostProcessing(String envelopeId, 
                                                    Id renewId, 
                                                    Id myDocumentId, 
                                                    Map<String,String> emailToRoleMap) {
    
        List<dfsle__EnvelopeStatus__c> docusignStatusList = [Select Id,dfsle__DocuSignId__c, Envelope_Type__c, Envelope_Recipient_Type__c
                                                                From dfsle__EnvelopeStatus__c
                                                                Where dfsle__DocuSignId__c=:envelopeId];
    
        if (docusignStatusList.size() > 0) {
            dfsle__EnvelopeStatus__c ds = docusignStatusList[0];
            ds.Envelope_Type__c = 'Broker Renew Noc';
            ds.Broker_Renewal__c = renewId;
            update ds;

            List<dfsle__RecipientStatus__c> rsToUpdateList = new List<dfsle__RecipientStatus__c>();
            List<dfsle__RecipientStatus__c> docusignReceipentStatusList = [Select id,dfsle__RoutingOrder__c,Broker_Account__c,
                                                                                dfsle__Email__c,Envelope_Type__c,
                                                                                Envelope_Recipient_Type__c 
                                                                            From dfsle__RecipientStatus__c
                                                                            Where dfsle__EnvelopeStatus__c=:docusignStatusList[0].id];

            Integer i = 1;
            for (dfsle__RecipientStatus__c rs:docusignReceipentStatusList) {
                String drsKey=rs.dfsle__Email__c+'_'+rs.dfsle__RoutingOrder__c;
                System.debug('key is:====> '+drsKey);

                if (emailToRoleMap.containsKey(drsKey)) {
                    rs.Broker_Renewal__c = renewId;
                    rs.Envelope_Recipient_Type__c = emailToRoleMap.get(drsKey);
                    rs.Envelope_Type__c = 'Broker Renew Noc';
                    System.debug('Standard DRS records for Booking: '+rs);
                    rsToUpdateList.add(rs);
                }
                i += 1;
            }                                                       
            update rsToUpdateList;
            system.debug(rsToUpdateList);
        }
    }
    public static String docusignEmailBody(Broker_Renewal__c renew) {
        /*  return 
          'Dear Sir/Madam \n\n'+
          'Please find attached the NOC Form for the property purchased from Sobha LLC (“<b>Seller</b>”). The document once opened shall be signed and returned to the Seller. \n\n'+
          'The said document when executed will be kept in safe custody of the Seller, and one soft copy will be provided to you for your records. \n'+
          '<ol>'+
          '<li>Click on Review document and enter the OTP received on your registered mobile number to procced to sign.</li>'+
          '<li>Click on the Start to initiate the signing.</li>'+
          '<li>Draw the Initials and Signature and follow the Docusign flow to sign the Document</li> '+
          '<li>Click on Finish once the document is complete.</li></ol>\n'+
          '<ol>'+
          'On agreeing and consenting on below, the Purchaser(s) jointly, severally and irrevocably accept that: \n \n'+
          'The instructions for signing the document via DocuSign are as below: \n\n'+
          '<li>You have read and understood the terms and conditions of the NOC Form. Further, you agree and acknowledge that you have duly understood the content and that by signing the NOC Form in electronic form you will be bound by it as if you have signed the document in ink;</li>\n'+
          '<li>You agree to the comply with the restrictions and penalties as specified in the NOC Form.</li>\n'+
          '<li>You have agreed to comply with the payment plan mentioned in the NOC Form and shall always adhere to the same and make timely payments;</li> \n'+
          '<li>You agree and consent to share your personal details including bank details to the Seller as per the applicable data protections laws applicable in the UAE and Seller undertakes that such data shall be used only for the purposes of this sale and purchase transaction and other offers and proposals by the Seller, during the course;</li>\n'+
          '<li>You confirm that you shall never contravene the electronic signature. It is further agreed and acknowledged that the electronic signature shall be enforceable before the non-exclusive jurisdiction of the courts of UAE, and you shall not object to it on the account of it being an electronic signature;</li>\n'+
          '<li>You confirm that you are the only individual authorized to access the NOC Form received from the Seller electronically. You must not share or disclose the password or other secure method to access NOC Form delivered electronically. You must take all reasonable measures to protect the access devices to prevent unauthorized access to NOC Form delivered electronically;</li>\n'+
          '<li>You hereby agree to notify the Seller promptly of any changes to mailing address, e-mail address, or other information. You agree to hold harmless the Seller (including its Shareholder, Director, Representative, Employees, parent company)  in connection with the your failure to provide current and valid contact information;</li>\n'+
          '<li>You agree to defend, indemnify and hold harmless the Seller, its affiliates, licensors and service providers, and its and their respective officers, directors, employees, contractors, agents, licensors, suppliers, successors and assigns from and against any claims, liabilities, damages, judgments, awards, losses, costs, expenses or fees (including reasonable attorneys’ fees) arising out of or relating to your violation of the terms and conditions mentioned herein.</li>\n'+
          '<li>You hereby acknowledge and agree that the Seller is the sole and exclusive owner of the Intellectual Property and that any goodwill or other right, interest or benefit flowing directly or indirectly from the Intellectual Property is and remains at all times the sole property of the Seller. You agree that it shall not utilize any of the Intellectual Property of the Seller for the purposes of selling or marketing the property.</li>\n'+
          '<li>You hereby agree to adhere and comply with the Federal Decree-Law No. 46/2021 on Electronic Transactions and Trust Services and any other laws and regulations applicable in the UAE. </li>\n'+
          '<li>You hereby acknowledge and undertake that you shall submit the NOC Form within seven (07) calendar days from the date of receiving the NOC Form, to the Seller’s portal, and the failure to do so shall result in auto rejection of the reservation made on your behalf for the unit in the Seller’s system. Upon rejection of the NOC Form from the Seller’s system, the Seller shall have the right to sell the unit to any third party without any requirement to notify you about the same. </li>\n'+
          '</ol>'+
          '\n'+
          'For any clarifications, please reach out to us on contact no: +97144238064 and email: helpdesk@sobharealty.com\n'+
          'For further updates and queries post signing, please contact with your Sales Manager \n\n'+
          'Thank you,\n'+
          'Yours faithfully \n'+
          'Sobha Realty</p>\n';*/
          String recipientName;
          if(renew.Al_Siniya_Partner__c) {
            recipientName =  system.label.Siniya_Island_Final_Signatory_Name;
          } else if(renew.Broker_Category_Type_Doc__c != null && renew.Broker_Category_Type_Doc__c.contains('UAE')){
              recipientName = system.label.UAE_Category_Name;
          } else {
              recipientName = system.label.VP_First_Name+' '+system.label.VP_Last_Name;
          }
          String baseUrl = Url.getOrgDomainURL().toExternalForm();
          String url = baseUrl + '/' + renew.id;
          return 
          '<p> Dear '+recipientName+' ,</p> '+
           '<p>'+
           'Please be informed that the agreement and NOC for the registration of '+renew.Name_as_per_trade_license__c+' is ready for Signature. Please find the details below.'+
          '</p>   '+
          
    
          '<table border="1" >'+
              '<tr>'+
                  '<td>Broker Name</td>'+
                  '<td>'+renew.Name_as_per_trade_license__c+'</td> '+                 
              '</tr>'+
              '<tr>'+
                  '<td>Broker Category</td>'+
                  '<td>'+renew.Broker_Category_Type_Doc__c+'</td>'+
                  
              '</tr>'+
              '<tr>'+
                  '<td>Created Date</td>'+
              '<td>'+renew.createdDate+'</td>'+
                  
              '</tr> '+
                  '<tr>'+
                  '<td>CHRM</td>'+
              '<td>'+renew.Owner.Name+'</td>'+
              '</tr>'+
              '<tr>'+
              '<td>Status</td>'+
                  '<td>Awaiting VP signature</td>'+                  
              '</tr>'+
              '<tr>'+
                  '<td>Audit History</td>'+
                  '<td>Request Approved by Audit</td>'+                   
              '</tr>'+
          '</table>'+
              // '<p>'+
              //     'Kindly find the docuSign links for your signature above(Click Review Document). </p>'+
              //'<p>'+
              //'<a href="'+ url+'">Click here</a> to approve/reject in salesforce  </p>'+
              ''+
          '<p>Thank you.</p>'+
          '<p>Best regards,</p>'+
          '<p>Salesforce</p>';
      }
}