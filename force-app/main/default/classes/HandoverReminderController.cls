public class HandoverReminderController {
    
    public String oppId;
    public Opportunity Customer {get; set;}
    public String ref {get;set;}
    public Date todayDate {get;set;}
    public Date completiondate {get;set;}
    public Date handoverdate {get;set;}
    Public String dewano{get;set;}
    public String towerName{get;set;}
    
    public HandoverReminderController(){
        
        ref = '';
        todayDate = System.Today();
        
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '')
            oppId = ApexPages.currentPage().getParameters().get('id');
        if(oppId != null && oppId != '') {   
            Customer = [SELECT id, Name, Primary_Email__c,booking__r.Tower_Name__c, Other_Applicants_Email__c, Primary_Name__c,Primary_Phone__c, Other_Applicants_Name__c,Unit__r.Name,
                        Mailing_Address__c,Permanent_Address__c,Booking__r.Name, Booking__r.Unit__r.Unit_Status__c, Booking__r.Agreement_Value__c,
                        Project__r.name, Unit__r.Chargeable_Area__c, Booking__r.No_of_Earmarked_Parking__c, Unit__r.Tower__r.Name,Unit__r.Tower__r.Date_of_Completion__c,            
                        Booking__r.Unit__r.Tower__r.Cluster__r.Name,  Booking__r.Unit__r.Legal_Entity__r.name, Unit__r.Tower__r.RDS_Company_Code__r.Name, Unit__r.Tower__r.Address__c,
                        Booking__r.Unit__r.Name, Account.PersonMobilePhone,Unit__r.Project_Unit_Type__r.Name ,Booking__r.Handover_Date__c,Booking__r.Dewa_Number__c,Booking__r.Project__r.name                                                                    
                        FROM Opportunity WHERE id = :oppId];  
            
            completiondate = Customer.Unit__r.Tower__r.Date_of_Completion__c;
            handoverdate = Customer.Booking__r.Handover_Date__c;
            dewano =Customer.Booking__r.Dewa_Number__c;
            towerName = Customer.booking__r.Tower_Name__c;
            
            if(Customer != null){
                if(Customer.Unit__r.Name != null && String.isNotBlank(Customer.Unit__r.Name))
                    ref = 'Unit No. ' + Customer.Unit__r.Name + ', ';  
                
                if(Customer .Unit__r.Tower__r.RDS_Company_Code__r.Name != null && String.isNotBlank(Customer.Unit__r.Tower__r.RDS_Company_Code__r.Name))
                    ref += Customer.Unit__r.Tower__r.RDS_Company_Code__r.Name + ', ';
                if(Customer.Unit__r.Tower__r.Address__c != null && String.isNotBlank(Customer.Unit__r.Tower__r.Address__c))
                    ref += Customer.Unit__r.Tower__r.Address__c;
            }   
        }  
    }
}