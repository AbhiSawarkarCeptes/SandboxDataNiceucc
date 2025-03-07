public class N_WelcomeLetterPDFController{
    Id bId;
    public Booking__c b{get; set;}
    public String ref {get;set;}
    public Date todayDate {get;set;}

    public N_WelcomeLetterPDFController(){
        
        ref = '';
        todayDate = System.Today();
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '')
            bId =  ApexPages.currentPage().getParameters().get('Id');  
            
        b = [SELECT Opportunity__r.Primary_Name__c, Opportunity__r.Primary_Email__c, Opportunity__r.Primary_Phone__c, 
             Opportunity__r.Permanent_Address__c, Unit__r.Name, Unit__r.Tower__r.Name,Opportunity__r.Other_Applicants_Name__c, Unit__r.Tower__r.RDS_Company_Code__r.Name,
             Unit__r.Tower__r.Address__c,Opportunity__r.Other_Applicants_Email__c, Unit__r.Project__r.Name    
             FROM Booking__C WHERE Id = :bId];  
        
        if(b != null){
            if(b.Unit__r.Name != null && String.isNotBlank(b.Unit__r.Name))
                ref = 'Unit No. ' + b.Unit__r.Name + ', ';  
            //if(b.Unit__r.Tower__r.Name != null && String.isNotBlank(b.Unit__r.Tower__r.Name))
                //ref += b.Unit__r.Tower__r.Name + ', ';
            if(b.Unit__r.Tower__r.RDS_Company_Code__r.Name != null && String.isNotBlank(b.Unit__r.Tower__r.RDS_Company_Code__r.Name))
                ref += b.Unit__r.Tower__r.RDS_Company_Code__r.Name + ', ';
            if(b.Unit__r.Tower__r.Address__c != null && String.isNotBlank(b.Unit__r.Tower__r.Address__c))
                ref += b.Unit__r.Tower__r.Address__c;
                
        
        }   
    }  
    
    
      
}