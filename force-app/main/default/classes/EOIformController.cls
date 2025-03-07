public class EOIformController {
    public EOI_Form__c EOI {get;set;}
    public Id EOIId;
    public Channel_Partner__c channelPartner {get;set;}
    public List <Sobha_connect__c> SC{get;set;}
    public String bookingSourceCompany {get;set;}
        public EOIformController(){
        
        //EOI.EOI_Date__c = system.now();
        
         if(ApexPages.currentPage().getParameters().get('id') != null){
            EOIId= ApexPages.currentPage().getParameters().get('id');
            
            }            
             if(EOIId != null) {
                
                eoi=[select Id, OwnerId, Name,Sales_Manager__r.Name, Unit_Number__c,Unit_Number__r.Tower__r.RDS_Company_Code__r.Project_Name_ID__c,Unit_Number__r.Puchase_Price__c,Unit_Number__r.Unit_type__c,
                     Unit_Number__r.Configuration__c,Unit_Number__r.Unit_No__c,Unit_Number__r.Tower__r.RDS_Company_Code__r.Developer_ID__c, Salutation__c, Primary_Applicant_Name__c,
                     Passport_Registration_Number1__c, Valid_until__c, Country_of_Issue_Registration__c,Source_of_EOI__c,Salutation3__c,Salutation4__c,Secondary_Sales_Head__r.Name,
                     Name_of_Authorized_Signatory__c, Correspondence_Address__c, Contact_Details__c, E_mail__c, Salutation2__c,
                     Second_Applicant_Name__c, Passport_Registration_Number2__c, Valid_Until2__c,Secondary_Sales_Manager__r.Name,
                     Country_of_Issue_Registration2__c, Name_of_Authorized_Signatory2__c, Correspondence_Address2__c,
                     Mobile__c, Email2__c, Thrid_Applicant_Name__c,  Valid_until3__c,Passport_Registration_Number33__c,
                     Country_of_Issue_Registration3__c, Name_of_Authorized_Signatory3__c, Correspondence_Address3__c,EOI_Date__c,
                     Mobile3__c, E_mail3__c, Fourth_Applicant_Name__c, Passport_Registration_Number4__c, Valid_until4__c,
                     Country_of_Issue_Registration4__c, Name_of_Authorized_Signatory4__c, Correspondence_Address4__c, 
                     Mobile4__c, Email4__c, Channel_Partner__c, Sobha_Connect__c, Sales_Manager__c, Sales_Head__c,Pre_Registration_Amount__c, Channel_Partner__r.Name,Channel_Partner__r.contact_person__c,
                     Secondary_Sales_Manager__c,Sales_Head__r.name, Secondary_Sales_Head__c, Mobile1__c from EOI_Form__c where id=:EOIId];
                 system.debug('b@@@'+eoi);
            }
             if(eoi.Channel_Partner__c != null){
                channelPartner = [SELECT Name,Contact_Person__c  FROM Channel_Partner__c WHERE Id = :eoi.Channel_Partner__c];
            }
            // Fetching Sobha Connect details
            if(eoi.Sobha_Connect__c != null) {
                SC = [SELECT Name__c, Contact_Person__c FROM Sobha_Connect__c WHERE Id = :eoi.Sobha_Connect__c];
            }
            if(eoi.Source_of_EOI__c== 'Channel Partner' || eoi.Source_of_EOI__c== 'Sobha Connect'){
                if(eoi.Source_of_EOI__c== 'Channel Partner' && channelPartner != null){        
                    bookingSourceCompany = channelPartner.Name;         
                   
                } 
                if(eoi.Source_of_EOI__c == 'Sobha Connect' && sc != null ){      
                    bookingSourceCompany = sc[0].Name__c;         
                    
            
        }
    }
} 

}