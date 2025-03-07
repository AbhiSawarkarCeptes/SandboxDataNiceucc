public class MouLetterController {
    public boolean displayPopup {get; set;} 
    public String toEmail {get;set;}
    public String ccEmail {get;set;}
    public List<Attachment> attachmentList{get;set;}
    public String transIds = null; 
    public List<PropStrength__Transaction_Requests__c> transactionList  {get;set;}
    public String msg {get;set;}
    public Boolean showButton {get;set;}
    public String framesrc {get; set;}
    public List<PropStrength__Transaction_Requests__c> transactionRequestList {get;set;}
    public PageReference pdf;
    public String mailingAdd {get; set;}
    public List<PropStrength__Payment_Plan_Details__c> paymetDetailsList {get; set;}
    Public Decimal totalAmount {get; set;}
    AggregateResult aggResOfPPD {get; set;}
    Public String amountInWord {get; set;}
    Public String amountRateInWord {get; set;}
    
    public MouLetterController() {
        transIds = ApexPages.currentPage().getParameters().get('Id');
        msg = '';
        showButton = false;
        transMethod();
    }
    
    public void transMethod() {
        if(!String.isBlank(transIds)) {
            transactionRequestList = [SELECT Id, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.PropStrength__Contact_Name__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Passport_Number__c,
                                      PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__c,PropStrength__Application_Booking__r.PropStrength__Project__r.Customer_Care_Email_ID__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.PropStrength__Nationality__c,
                                      PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState,
                                      PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingPostalCode, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c,
                                      PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Super_Area__c, PropStrength__Application_Booking__r.PropStrength__Revised_Agreement_Amount__c, PropStrength__Application_Booking__r.PropStrength__Basic_Sale_Price__c,
                                      PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Floor__r.PropStrength__Floor_Area__c, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry, PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.name,
                                      PropStrength__Application_Booking__r.PropStrength__Super_Area__c, PropStrength__Application_Booking__r.House_Unit_No__c
                                      FROM PropStrength__Transaction_Requests__c 
                                      WHERE Id =: transIds 
                                      AND MOU_Created__c =: false
                                      AND RecordType.Name =: 'MOU Process' 
                                      AND PropStrength__Application_Booking__r.MOU_Executed__c =: false
                                      AND PropStrength__Application_Booking__c != null 
                                      AND PropStrength__Application_Booking__r.MOU_Execution_Date__c = null];
            
            mailingAdd = transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet + ' ' + transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity + ' ' + transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState + ' ' + transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingPostalCode + ' ' + transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry ; 
            
            paymetDetailsList = [Select id, PropStrength__Milestone_Name__c, PropStrength__Payment_Due_Date__c,
                                 PropStrength__Amount_Percent__c, PropStrength__Total_Amount_Due__c
                                 from PropStrength__Payment_Plan_Details__c 
                                 where PropStrength__Application_Booking__c =: transactionRequestList[0].PropStrength__Application_Booking__c order by Name];

            aggResOfPPD = [Select Sum(PropStrength__Total_Amount_Due__c)
                           from PropStrength__Payment_Plan_Details__c 
                           where PropStrength__Application_Booking__c =: transactionRequestList[0].PropStrength__Application_Booking__c
                           Group by PropStrength__Application_Booking__c Limit 1
                          ];
            totalAmount = (Decimal)aggResOfPPD.get('expr0');
            amountInWord = numberToWord((Integer)transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Revised_Agreement_Amount__c);
            amountRateInWord = numberToWord((Integer)transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Basic_Sale_Price__c);
            
            if(transactionRequestList.isEmpty()) {
                showButton = false;
                msg = 'MOU Already Generated.';
            } else {
                showButton = true;
                if(transIds != null && transIds != '') {
                    if(transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.name == 'Tranquility Plots'){
                        framesrc = '/apex/MOU_TranquilityPlots_Letter?id='+transIds;  
                        pdf = Page.MOU_TranquilityPlots_Letter_pdf;
                    }else if(transactionRequestList[0].PropStrength__Application_Booking__r.PropStrength__Project__r.Master_Project__r.name == 'Sobha Hartland'){
                      framesrc = '/apex/MOU_HartlandPlots_Letter?id='+transIds;  
                       pdf = Page.MOU_HartlandPlots_Letter_pdf;
                    }
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
            String url = '/apex/MouLetter?Id=' + transIds;
            PageReference rateProfile = new PageReference(url);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment(); //create attachment
            attachment.setFileName('MOU Letter.pdf');
            if(!test.isRunningTest())
                attachment.setBody(rateProfile.getContentAsPDF());
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
            if(!test.isRunningTest())
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            message.setSubject('MOU Letter');
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
        System.debug('transactionRequestList::' + transactionRequestList);
        if(!transactionRequestList.isEmpty()) {
            System.debug('transactionRequestList::' + transactionRequestList);
            List<Attachment> insertList = new List<Attachment>();
            List<PropStrength__Transaction_Requests__c> updateTranList = new List<PropStrength__Transaction_Requests__c>();
            //PageReference pdf;
            //pdf =  Page.MOU_TranquilityPlots_Letter;
            
           
            Blob b ;
            if(!Test.isRunningTest()){
                 pdf.getParameters().put('id',(String)transactionRequestList[0].id);
                 b= pdf.getContent();
            }
            else{
                b = blob.valueOf('Unit.Test');
            }
                
            System.debug(b);
            for(PropStrength__Transaction_Requests__c tran : transactionRequestList) {
                Attachment att = new Attachment();
                att.ParentId = tran.Id;
                att.Name = 'MOU Letter.pdf';
                att.Body = b;
                att.ContentType = 'application/pdf';
                System.debug('bob' + b);
                System.debug('Att' + att);
                
                insertList.add(att);
                
                PropStrength__Transaction_Requests__c trans = new PropStrength__Transaction_Requests__c();
                trans.Id = tran.Id;
                trans.MOU_Created__c = true;
                // trans.MOU_Sent_to_Development_and_Legal_Team__c = true;
                // trans.MOU_Sent_to_Development_Legal_Date__c = Date.today();
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
    
    public Static String numberToWord(Integer value ){
        Map<integer, string> preDefineNumber = new Map<integer, String>{0 => 'Zero ', 1 => 'One ', 2 => 'Two ', 3 => 'Three ', 4 => 'Four ', 5 => 'Five ', 6 => 'Six ', 7 => 'Seven ', 8 => 'Eight ', 9 => 'Nine ',
            															10 => 'Ten ', 11 => 'Eleven ', 12 => 'Twelve ', 13 => 'Thirteen ', 14 => 'Fourteen ', 15 => 'Fifteen ', 16 => 'Sixteen ', 17 => 'Seventeen ',
            															18 => 'Eighteen ', 19 => 'Nineteen ', 20 => 'Twenty ', 30 => 'Thirty ', 40 => 'Fourty ',50 => 'Fifty ',60 =>'Sixty ',70 => 'Seventy ', 80 => 'Eighty ',90 => 'Ninty '};
    	String numberToWord = '';
        while(value > 0){
            if(value <= 20){
                numberToWord += preDefineNumber.get(value);
                return numberToWord;
            }else if(value < 100){
                integer num = value/10;
                num *= 10;
                numberToWord += preDefineNumber.get(num); 
                value = Math.mod(value,10);
                
            }else if(value < 1000){
                
                numberToWord += preDefineNumber.get(value/100) + 'Hundread ';
                value = Math.mod(value,100);
                
            }else if(value < 1000000) {
                
                numberToWord += numberToWord(value/1000) + 'thousand ';
                value = Math.mod(value,1000);
                
            }else if(value < 1000000000){
               
                numberToWord += numberToWord(value/1000000) + 'Million ';
                value = Math.mod(value,1000000);
                
            }
             
  		}
        return numberToWord ;
     }
}