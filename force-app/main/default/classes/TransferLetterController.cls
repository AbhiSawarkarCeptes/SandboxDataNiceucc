public class TransferLetterController {
	
    public string strId;
    public PropStrength__Application_Booking__c booking {get; set;}
    public PropStrength__Transaction_Requests__c tranReq {get; set;}
    Public list<PropStrength__Applicant_Detail__c> applicantList {get; Set;}
    Public Map<String, PropStrength__Applicant_Detail__c> appliDetMap{get; Set;}
    Public Map<Integer, PropStrength__Customer_Detail__c> custDetMap{get; Set;}
    public List<Integer> countList {get; Set;}
    Public String keyValue {get; set;}
    Public set<String> keys {get; set;}
    Public PropStrength__Customer_Detail__c customerDetail {get; set;}
    Public String floorInWords {get; set;}
    public Boolean fromLightning {get;set;}
    
    public TransferLetterController(){
        fromLightning = false;
        strId = ApexPages.currentPage().getParameters().get('id');
        keyValue = '';
        tranReq = [Select id, PropStrength__Application_Booking__c, New_Purchase_Value__c 
                   from PropStrength__Transaction_Requests__c 
                   where id =: strID];

         if(ApexPages.currentPage().getParameters().containsKey('frmLgtng') && ApexPages.currentPage().getParameters().get('frmLgtng') == 'true') {
            fromLightning = true;
         }
        
        List<PropStrength__Customer_Detail__c> cusDetList = [Select id, PropStrength__Contact__r.PropStrength__Contact_Name__c, PropStrength__Contact__r.Passport_Number__c,
                         PropStrength__Contact__r.PropStrength__Nationality__c, PropStrength__Contact__r.MailingStreet, PropStrength__Contact__r.MailingCity, PropStrength__Contact__r.MailingState, 
                         PropStrength__Contact__r.MailingPostalCode, PropStrength__Contact__r.MailingCountry,
                         PropStrength__Contact__r.MobilePhone, PropStrength__Contact__r.Email, PropStrength__Type__c
                        from PropStrength__Customer_Detail__c 
                        where PropStrength__Transaction_Request__c =: strID
                        And PropStrength__Active__c = true ORDER BY PropStrength__Type__c];
        if(!cusDetList.isEmpty()) {
            customerDetail = cusDetList[0];
        }
        
        booking = [Select id, PropStrength__Property__r.PropStrength__House_Unit_No__c, PropStrength__Project__r.Name, POA_Name__c,
                   PropStrength__Property__r.PropStrength__Super_Area__c, PropStrength__Property__r.PropStrength__Floor_Number__c
                   from PropStrength__Application_Booking__c 
                   where Id = :tranReq.PropStrength__Application_Booking__c];
        
        applicantList = [Select id, PropStrength__Type__c, PropStrength__Applicant_Acc__r.PropStrength__Contact_Name__c,
                         PropStrength__Applicant_Acc__r.PropStrength__Nationality__c, PropStrength__Applicant_Acc__r.Passport_Number__c,
                         PropStrength__Applicant_Acc__r.MailingStreet, PropStrength__Applicant_Acc__r.MailingCity, PropStrength__Applicant_Acc__r.MailingState, 
                         PropStrength__Applicant_Acc__r.MailingPostalCode, PropStrength__Applicant_Acc__r.MailingCountry,
                         PropStrength__Applicant_Acc__r.MobilePhone, PropStrength__Applicant_Acc__r.Email
                         from PropStrength__Applicant_Detail__c 
                         where PropStrength__Application__c = :tranReq.PropStrength__Application_Booking__c 
                         And PropStrength__Active__c = true];
        
        appliDetMap = new Map<String, PropStrength__Applicant_Detail__c>();
        custDetMap = new Map<Integer, PropStrength__Customer_Detail__c>();
        countList = new List<Integer>();
        applicantDetailsFetch(applicantList);
        customerDetailFetch(cusDetList);
        floorInWords = Utilities.changeToWords(String.valueOf(((integer)booking.PropStrength__Property__r.PropStrength__Floor_Number__c).format()), false);
        
    }
    
    public void applicantDetailsFetch(List<PropStrength__Applicant_Detail__c> applicantList){
        System.debug('==>applicantList==>'+ applicantList);
        for(PropStrength__Applicant_Detail__c appDet: applicantList){
           appliDetMap.put(appDet.PropStrength__Type__c, appDet);
           keyValue += ' ' + appDet.PropStrength__Type__c;
            System.debug('Entry');
        }
        keys = appliDetMap.keySet();
        System.debug('==>appliDetMap==>'+ appliDetMap);
    }

    public void customerDetailFetch(List<PropStrength__Customer_Detail__c> customerDetailList){
        System.debug('==>customerDetailList==>'+ customerDetailList);
        Integer count = 0;
        for(PropStrength__Customer_Detail__c cusDet: customerDetailList){
            count+=1;
            countList.add(count);
            custDetMap.put(count, cusDet);
            System.debug('Entry');
        }
        System.debug('==>custDetMap==>'+ custDetMap);
    }

     public pagereference docancel(){
        if(strId != null && strId != ''){
            return new pageReference('/'+strId);
        }else
            return null;
    }
    
    public pageReference savepdf(){
    if(strId != null && strId != ''){
        tranReq = [Select id, PropStrength__Customer_Transfer_Type__c, PropStrength__Status__c, Transfer_Charges_Raised_to_Customer__c from PropStrength__Transaction_Requests__c where ID =:strID];
       
            List<Attachment> allAttachment = new List<Attachment>();
            allAttachment = [SELECT Id, Name FROM Attachment WHERE parentid =: strId];

            for(Attachment abc : allAttachment){
                if(abc.Name == 'Transfer Letter.pdf'){
                    delete abc;
                }else if(abc.Name == 'Transfer & Assignment Agreement.pdf'){
                    delete abc;
                } 
              }
            
        string aName ;
        
        if(tranReq.PropStrength__Status__c == 'Assignment: Update Applicants & Verify Applicants'){
        	if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer')
            {
                tranReq.PropStrength__Status__c = 'Transfer & Assignment Agreement Generated';
                aName= 'Transfer & Assignment Agreement';
            }else{
                tranReq.PropStrength__Status__c = 'Transfer Letter Generated';
                 aName= 'Transfer Letter';
            }
         update tranReq;
        }
             String frmsrc = '';
            if(tranReq.PropStrength__Customer_Transfer_Type__c == 'No Title Transfer'){
           frmsrc = '/apex/TransferAndAssignmentAgreement?id='+strId;
         }else if(tranReq.PropStrength__Customer_Transfer_Type__c == 'Title Transfer'){
           frmsrc = '/apex/TransferLetter_TR?id='+strId;
         }
            
            PageReference p1 = new PageReference(frmsrc);   
            Attachment a1 = new Attachment();
                a1.parentid = strId;
                a1.name = aName + '.pdf';
                 if (Test.IsRunningTest())
                 {
                     a1.body =Blob.valueOf('UNIT.TEST');
                 }
                 else{
                     a1.body = p1.getContent();
                 }
           
           insert a1;
        
        
        
            if(strid != null && strid != ''){
                if(fromLightning) {
               return new pageReference('/lightning/r/PropStrength__Transaction_Requests__c/'+strid+'/view');
                }else {
return new pageReference('/'+strId);
               }
            }
        
    }        
        return null;
      }
}