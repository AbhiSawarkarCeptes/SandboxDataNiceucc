public class N_FileNotePDFController{
public Id fnId;
public File_Note__c f {get;set;}
public String purchasePrice {get;set;}
public String bookingDate {get;set;}
public String crmStatus {get;set;}
public String financeStatus {get;set;}
public String auditStatus {get;set;}
public String cfoStatus {get;set;}

public N_FileNotePDFController(){
    crmStatus = '';
    financeStatus = '';
    auditStatus = '';
    cfoStatus = '';
    
    if(Apexpages.currentPage().getParameters().get('Id') != null && Apexpages.currentPage().getParameters().get('Id') != '')
        fnId = Apexpages.currentPage().getParameters().get('Id');
    
    f = [SELECT Id, Name, Category__c, Description__c, Opportunity__c, Unit__r.Name, Booking__r.Primary_Applicant_Name__c, Quotation__r.Name,
         CRM__r.Name, Audit__r.Name, Finance__r.Name, CFO__r.Name, Booking__r.Agreement_Value__c, Booking__r.Sales_Managers__r.Name,
         Booking__r.Name, Approval_Status__c, Owner.Name, Booking__r.Stage_of_Booking__c, Booking__r.Booking_Date__c
         FROM File_Note__c WHERE Id = :fnId];
    
    if(f != null){
        purchasePrice = InventoryCostServices.INFormatR(f.Booking__r.Agreement_Value__c); 
        bookingDate = f.Booking__r.Booking_Date__c.Date().format();
        if(f.Approval_Status__c != null){
            if(f.Approval_Status__c == 'CRM Approved - Submitted to Finance'){
                crmStatus = 'Approved';
            }
            else if(f.Approval_Status__c == 'Finance Approved - Submitted to Audit'){
                crmStatus = 'Approved';
                financeStatus = 'Approved';     
            }
            else if(f.Approval_Status__c == 'Audit Approved - Submitted to CFO'){
                crmStatus = 'Approved';
                financeStatus = 'Approved';   
                auditStatus = 'Approved';        
            }
            else if(f.Approval_Status__c == 'CFO Approved'){
                crmStatus = 'Approved';
                financeStatus = 'Approved';   
                auditStatus = 'Approved'; 
                cfoStatus = 'Approved';
            }
            else if(f.Approval_Status__c == 'CFO Rejected'){
                crmStatus = 'Rejected';
                financeStatus = 'Rejected';   
                auditStatus = 'Rejected'; 
                cfoStatus = 'Rejected';
            }
            else if(f.Approval_Status__c == 'Audit Rejected'){
                crmStatus = 'Rejected';
                financeStatus = 'Rejected';   
                auditStatus = 'Rejected'; 
            }
            else if(f.Approval_Status__c == 'Finance Rejected'){
                crmStatus = 'Rejected';
                financeStatus = 'Rejected';   
            }
            else if(f.Approval_Status__c == 'CRM Rejected'){
                crmStatus = 'Rejected';
            }        
        }
    }
}
}