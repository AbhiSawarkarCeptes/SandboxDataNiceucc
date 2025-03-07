public class DSPALetterController {
    public boolean displayPopup {get; set;} 
    public String toEmail {get;set;}
    public String ccEmail {get;set;}
    public List<Attachment> attachmentList{get;set;}
    public String transIds = null; 
    public String msg {get;set;}
    public Boolean showButton {get;set;}
    public String framesrc {get; set;}
    public List<PropStrength__Transaction_Requests__c> transactionRequestList {get;set;}
    //public String email1{get;set;}
    //public String email2{get;set;}
    
    public DSPALetterController() {
        transIds = ApexPages.currentPage().getParameters().get('Id');
        msg = '';
        //email1 = '';
        //email2 = '';
        showButton = false;
        transMethod();
    }
    
    public void transMethod() {
        if(!String.isBlank(transIds)) {
            transactionRequestList = [SELECT Id,PropStrength__Application_Booking__r.PropStrength__Primary_Customer__c,
                                      PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c
                                      FROM PropStrength__Transaction_Requests__c 
                                      WHERE Id =: transIds 
                                      AND RecordType.Name =: 'DSPA Process' 
                                      AND PropStrength__Application_Booking__r.DSPA_Executed__c =: false
                                      AND PropStrength__Application_Booking__r.DSPA_Execution_Date__c =: null
                                      AND DSPA_Created__c = false
                                     AND DCR_Created__c = false];
            if(transactionRequestList.isEmpty()) {
                showButton = false;
                msg = 'DSPA Already Generated.';
            } else {
                showButton = true;
                if(transIds != null && transIds != '') {
                    framesrc = '/apex/DSPALetter_Light?id='+transIds;
                } 
            }
        }
    }
    
    /*public void EmailSPALetter() { 
        if(!transactionRequestList.isEmpty()) {
            //OrgWideEmailAddress owea = new OrgWideEmailAddress();
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if(!test.isRunningTest())
                owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address =: transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c limit 1];
            System.debug(ccEmail+'--test---'+toEmail);
            String url = '/apex/SPALetter?Id=' + transIds;
            PageReference rateProfile = new PageReference(url);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment(); //create attachment
            attachment.setFileName('SPA Letter.pdf');
            if(!test.isRunningTest())
                attachment.setBody(rateProfile.getContentAsPDF());
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            if(!test.isRunningTest())
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            message.setSubject('SPA Letter');
            message.setHTMLBody('Hi Letter HERE'); 
            if(String.isNotBlank(toEmail))
                message.setToAddresses( toEmail.split(',')  );
            //if(owea != null && owea.size() > 0)
            //  message.setOrgWideEmailAddressId(owea[0].Id);
            if(String.isNotBlank(ccEmail))
                message.setCcAddresses(ccEmail.split(',')); 
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
            closePopup();
        }
    }*/
    
    Public pageReference SaveAndEmailPdf() {
        if(!transactionRequestList.isEmpty()) {
            System.debug('transactionRequestList::' + transactionRequestList);
            List<Attachment> insertList = new List<Attachment>();
            List<PropStrength__Transaction_Requests__c> updateTranList = new List<PropStrength__Transaction_Requests__c>();
            PageReference pdf;
            pdf = Page.DSPALetter;
            pdf.getParameters().put('id',(String)transactionRequestList[0].id); 
            pdf.setRedirect(true);
            Blob b ;
            if(!Test.isRunningTest())
                b= pdf.getContent();
            try {
                for(PropStrength__Transaction_Requests__c tran : transactionRequestList) {
                    Attachment att = new Attachment();
                    att.ParentId = tran.Id;
                    att.Name = 'DSPA Letter.pdf';
                    att.Body = b;
                    insertList.add(att);
                    
                    PropStrength__Transaction_Requests__c trans = new PropStrength__Transaction_Requests__c();
                    trans.Id = tran.Id;
                    trans.DSPA_Created__c  = true;
                    updateTranList.add(trans);
                }
                if(!insertList.isEmpty()) {
                    insert insertList;
                    system.debug('insertList::'+insertList);
                }
                if(!updateTranList.isEmpty()) {
                    update updateTranList;
                    system.debug('updateTranList::'+updateTranList);
                }
            }catch (exception ex){
                msg = String.valueOf(ex.getMessage());
            }
            return new pageReference('/'+transIds);
        }
        return null;
    }
    
    public pagereference docancel(){
        return new pageReference('/'+transIds);
    }
    
    public String getChooserender() {
        System.debug('View*-*-*- ' + ApexPages.currentPage().getParameters().get('view'));
        if (ApexPages.currentPage().getParameters().get('view') != null){
            System.debug('html*-*-*-');
            return null;
        }        
        else {
            System.debug('pdf*-*-*-');
            return 'pdf';
        }
    }
    
    public void showPopup() { 
        displayPopup = true;     
    }
    
    public void closePopup() {        
        displayPopup = false;    
    }
}