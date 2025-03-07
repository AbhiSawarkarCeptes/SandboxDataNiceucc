public class CompletionNoticeController {
    public String oppId;
    public Opportunity Customer {get; set;}
    //Id bId;
    //public Booking__c b{get; set;}
    public String ref {get;set;}
    public Date todayDate {get;set;}
    public Date completiondate {get;set;}
    
    public CompletionNoticeController(){
        
        ref = '';
        todayDate = System.Today();
        
        /*   if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '')
        bId =  ApexPages.currentPage().getParameters().get('Id');  
        
        b = [SELECT Opportunity__r.Primary_Name__c, Opportunity__r.Primary_Email__c, Opportunity__r.Primary_Phone__c, 
        Opportunity__r.Permanent_Address__c, Unit__r.Name, Unit__r.Tower__r.Name,Opportunity__r.Other_Applicants_Name__c, Unit__r.Tower__r.RDS_Company_Code__r.Name,
        Unit__r.Tower__r.Address__c,Opportunity__r.Other_Applicants_Email__c, Unit__r.Project__r.Name,Unit__r.Tower__r.Date_of_Completion__c    
        FROM Booking__C WHERE Id = :bId];  */
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
            oppId = ApexPages.currentPage().getParameters().get('id');
        if(oppId != null && oppId != '') {   
            Customer = [SELECT id, Name, Primary_Email__c, Other_Applicants_Email__c, Primary_Name__c,Primary_Phone__c, Other_Applicants_Name__c,Unit__r.Name,
                        Mailing_Address__c,Permanent_Address__c,Booking__r.Name, Booking__r.Unit__r.Unit_Status__c, Booking__r.Agreement_Value__c,
                        Project__r.name, Unit__r.Chargeable_Area__c, Booking__r.No_of_Earmarked_Parking__c, Unit__r.Tower__r.Name,Unit__r.Tower__r.Date_of_Completion__c,            
                        Booking__r.Unit__r.Tower__r.Cluster__r.Name,  Booking__r.Unit__r.Legal_Entity__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Address__c,
                        Booking__r.Unit__r.Name, Account.PersonMobilePhone,Unit__r.Project_Unit_Type__r.Name                                                                     
                        FROM Opportunity WHERE id = :oppId];  
            
            completiondate = Customer.Unit__r.Tower__r.Date_of_Completion__c;
            
            if(Customer != null){
                if(Customer.Unit__r.Name != null && String.isNotBlank(Customer.Unit__r.Name))
                    ref = 'Unit No. ' + Customer.Unit__r.Name + ', ';  
                //if(b.Unit__r.Tower__r.Name != null && String.isNotBlank(b.Unit__r.Tower__r.Name))
                //ref += b.Unit__r.Tower__r.Name + ', ';
                if(Customer .Unit__r.Tower__r.RDS_Company_Code__r.Name != null && String.isNotBlank(Customer.Unit__r.Tower__r.RDS_Company_Code__r.Name))
                    ref += Customer.Unit__r.Tower__r.RDS_Company_Code__r.Name + ', ';
                if(Customer.Unit__r.Tower__r.Address__c != null && String.isNotBlank(Customer.Unit__r.Tower__r.Address__c))
                    ref += Customer.Unit__r.Tower__r.Address__c;
                
                
            }   
        }  
    }
}