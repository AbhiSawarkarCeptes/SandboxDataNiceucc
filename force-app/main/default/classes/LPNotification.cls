public class LPNotification {
    @InvocableMethod(label='Send Demand Notification' description='Demand Id and Booking Id To be send')
   public static void resendNotification(List<Demand__c> demandList){
       Boolean canSendEmail = true;
       Booking__c booking = [SELECT Id, Total_Interest_Till_Date__c,VAT_On_Interest_Amount__c,Project__c,Unit__c,Primary_Applicant_Email__c,Opportunity__c,Primary_Applicant_Name__c,CRM_Executive__r.Name,
                   Opportunity__r.Other_Applicants_Name__c, Unit__r.Tower__r.Collection_Executive__c,Unit__r.Tower__r.Collection_Executive__r.Name, Opportunity__r.Other_Applicants_Email__c,Unit__r.Name,
                   LastModifiedDate, Tower__c,Unit__r.Tower__r.Stop_Automatic_Email__c,Project__r.Name FROM Booking__c WHERE Id =: demandList[0].Booking__c ];

       canSendEmail = !booking.Unit__r.Tower__r.Stop_Automatic_Email__c;

       Demand__c demand = [SELECT Id, Name, Invoice_Date__c,Unit__r.Name, Due_Date__c, Invoice_Number__c, 
                                   Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__c,Payment_Milestones__c,
                                   Booking__r.Opportunity__r.Name,  Booking__r.Opportunity__r.Unit__r.Name, 
                                   Booking__r.Primary_Applicant_Email__c, Total_Amount_Demanded__c,
                                   Booking__r.Opportunity__r.Unit__r.Tower__r.Name, 
                                   Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name, AttachmentId__c 
                                   FROM Demand__c WHERE Id =: demandList[0].Id ];
       
       Blob PDFbody;
       Blob htmlBody;

       String executiveName='';
       executiveName = booking.Unit__r.Tower__r.Collection_Executive__c != null ? booking.Unit__r.Tower__r.Collection_Executive__r.Name : '';
       List<String> toAddress = new List<String>();
       List<String> otherApplicantEmail = new List<String>();
       List<String> toCCAddress = new List<String>();
       toCCAddress.add(System.label.CollectionTeamEmail);
       toCCAddress.add('sfnotifications@sobharealty.com'); 
       List<ContentVersion> listContentVersion = new List<ContentVersion>();
       PageReference pageRef = Page.Latepaymentcharges;
       pageRef.getParameters().put('bookingId',booking.Id);
       pageRef.getParameters().put('demandId',demand.Id);
       System.debug(' pageRef = '+pageRef);
       System.debug(' PDFbody = '+PDFbody);
           
       if(!test.isRunningTest()) {
           PDFbody = pageRef.getContentAsPDF();
           // String content = pageRef.getContentAsPDF().toString();
           // if (content.contains('Error in PDF LP')) {
           //     canSendEmail = false;
           // }
       }else {
           htmlBody = Blob.valueof('Dummy Content for Test Methods');
           PDFbody = Blob.valueOf('Some Text');
       }
       Set<String> contId = new Set<String>();
       
       ContentVersion cont = new ContentVersion();
       cont.Title = demand.Invoice_Number__c + '-' + demand.Booking__r.Opportunity__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Cluster__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Tower__r.Name + '-' + demand.Booking__r.Opportunity__r.Unit__r.Name + system.now();
       cont.VersionData = PDFbody;
       cont.ExternalDocumentInfo1 = demand.Id;
       cont.PathOnClient = demand.Invoice_Number__c +'.pdf';
       cont.ContentLocation = 'S';
       cont.Description = 'LPC for :' + demand.Booking__r.Opportunity__r.Name;
       cont.TagCSV = 'LPC for :' + demand.Booking__r.Opportunity__r.Name;
       listContentVersion.add(cont);
       System.debug(' listContentVersion '+listContentVersion);

       insert listContentVersion;
       System.debug(' listContentVersion '+listContentVersion);
       for (ContentVersion cv : listContentVersion) {
           contId.add(cv.Id);
       }
       System.debug(' contId '+contId);            
       List<ContentDocumentLink> cDeList = new List<ContentDocumentLink>();
       for (ContentVersion CV : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contId ]) {
           ContentDocumentLink cDe = new ContentDocumentLink();
           cDe.ContentDocumentId = CV.ContentDocumentId;
           cDe.LinkedEntityId = '0582o0000002N5c'; 
           cDe.ShareType = 'I';
           cDe.Visibility  = 'AllUsers';
           cDeList.add(cDe);
       } 
       System.debug(' cDeList '+cDeList); 
       try {
           insert cDeList; 
       } catch (Exception e) {}
       
       List<FeedItem> flList = new List<FeedItem>();
       for (ContentVersion CV : listContentVersion) {
           if(CV.ExternalDocumentInfo1 == demand.Id){
               FeedItem elm = new FeedItem(Body = 'Post with related document body', ParentId = demand.Id, RelatedRecordId = CV.Id, Type = 'ContentPost');
               flList.add(elm);
           }
       }
       System.debug(' demand '+demand); 
       insert flList;
       
       List<Demand__c> dmandListForUpdate = new List<Demand__c>();
       for (ContentVersion CV : listContentVersion) {
           if(CV.ExternalDocumentInfo1 == demand.Id){
               demand.AttachmentId__c = CV.id;
               dmandListForUpdate.add(demand); 
           }
       }
       System.debug(' dmandListForUpdate '+dmandListForUpdate); 
       update dmandListForUpdate; 
       
       // Take the PDF content
       Blob b;
       if(!Test.isRunningTest()){
           b = pageRef.getContent();   
       } else {
           b = Blob.valueOf('Test123');
       }

       Map<string,OrgWideEmailAddress> owaMap = new Map<string,OrgWideEmailAddress>();
       System.debug(' owaMap '+owaMap); 
       for(OrgWideEmailAddress owa : [SELECT id,DisplayName, Address FROM OrgWideEmailAddress]){
           owaMap.put(owa.Address,owa);
       }
       
       // Create the email attachment
       Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
       efa.setFileName('LatePaymentCharge.pdf');
       efa.setBody(b);
       
       if(booking.Primary_Applicant_Email__c != null){
           toAddress.add(booking.Primary_Applicant_Email__c);
       }
       if(booking.Opportunity__r.Other_Applicants_Email__c != null){
           otherApplicantEmail = booking.Opportunity__r.Other_Applicants_Email__c.split('\\,');
       }
       for(String s : otherApplicantEmail){
           if(!s.containsIgnoreCase('null')){
               toAddress.add(s);
           }
       }
       
       //Creating the email to be sent
       String body = '<br>Dear '+booking.Primary_Applicant_Name__c;
       if(booking.Opportunity__r.Other_Applicants_Name__c != null){
           body += booking.Opportunity__r.Other_Applicants_Name__c;
       }
       body += ',</br>';
       body += '<p>Hope you are doing well.</p>';
       if(booking.Project__r.Name.contains('Siniya')){
           body += '<p>Thank you for your purchase in our prestigious project Sobha Al Siniya FZC.</p>';
       }else{
           body += '<p>Thank you for your purchase in our prestigious project Sobha Realty .</p>';
       }
       body += '<p>With reference to the Unit '+booking.Unit__r.Name +' you have purchased, please find attached the late payment notice for your quick reference.</p>';
       if(booking.Project__r.Name.contains('Siniya')){
           body += '<span>Should you require any further assistance in this regard, feel free to contact us on the email address <a href="mailto:"'+System.Label.Collection_Siniya_Email+'">'+System.Label.Collection_Siniya_Email+'</a> or the mailing address mentioned in the letter.</span></br></br>';
       }else{
           body += '<span>Should you require any further assistance in this regard, feel free to contact us on the email address <a href="mailto:"'+System.Label.collection_email+'">'+System.Label.collection_email+'</a> or the mailing address mentioned in the letter.</span></br></br>';
       }
       body += '<span>Please log on to our website <a href="https://www.sobharealty.com/">www.sobharealty.com</a> for further information about our current and upcoming projects.</span></br>';
       body += '<p>Have a nice day!</p>';
       body += '<p>Thanks & Regards, </p>';
       body +=  '<p>'+executiveName+'</p>';
       body += '<p>Collection Team.</p>';
       body += '<a href="https://www.facebook.com/SobhaRealty/" style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPN&oid=00D1t000000G1gX"></img></a>&nbsp;';
       body += '<a href="https://www.instagram.com/sobharealty/"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPO&oid=00D1t000000G1gX"></img></a>&nbsp;';
       body += '<a href="https://www.youtube.com/channel/UCKIR9isiNyYq1T0GSnIUyHQ"  style="margin-top:10px; display:block; float:left; width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPS&oid=00D1t000000G1gX" ></img></a>&nbsp;';
       body += '<a href="https://www.linkedin.com/company/sobharealty/"  style="margin-top:10px; display:block; float:left;width:2.5%; height:1%; margin-right:5px; overflow-y:hidden"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPX&oid=00D1t000000G1gX"></img></a>&nbsp;';
       body += '<a href="https://www.sobharealty.com/" style="float:left; margin-top: 5px;height:1%;overflow-y:hidden">sobharealty.com</a>';
       body += '<br/><br/>';
       body += '<p><a href="https://www.sobharealty.com/"><img src="https://EU25.salesforce.com/servlet/servlet.ImageServer?id=0152o000006ZNPc&oid=00D1t000000G1gX" style="float:left; width:25%;"></img></a></p>';
       System.debug(' body = '+body);
       Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
       email.setSubject('Late Payment Charge Notice - Unit '+booking.Unit__r.Name+', Project-'+booking.Tower__c+' ');
       email.setHtmlBody(body);
       email.setToAddresses(toAddress);
       email.setCcAddresses(toCCAddress);
       email.setWhatId(booking.Id);
       if(booking.Project__r.Name.contains('Siniya')){
           email.setOrgWideEmailAddressId(owaMap.get(System.Label.Collection_Siniya_Email).id);
       }else{
           email.setOrgWideEmailAddressId(owaMap.get(System.Label.collection_email).id);
       }
       email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
       System.debug(' email = '+email);
       if(System.label.isAllowToSendLatePaneltyEmail == 'Sent Email' && canSendEmail == true){
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
       }
   }

}