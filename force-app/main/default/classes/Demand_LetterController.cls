public class Demand_LetterController {
    Public PropStrength__Received_Payment__c pay                    {get;set;}
    Public List<PropStrength__Received_Payment__c> payList          {get;set;}
    Public String payId                                             {get;set;}
    public List<PropStrength__Applicant_Detail__c> AppDetailLst     {get;set;}
    public List<Bank_GL__c> BankGLlist 								{get;set;}
    public Bank_GL__c BankGl 										{get;set;}
    Public PropStrength__Tax_Record__c tax		                    {get;set;}
    public string paymentId{
        get;
        set{
            paymentId = value;
            if(paymentId != null)
                demandLetterControllermethod();
        }
    }
    
    
    public  Demand_LetterController() {
        
        pay = new PropStrength__Received_Payment__c();
        tax = new PropStrength__Tax_Record__c();
        BankGLlist = new list<Bank_GL__c>(); 
        payId = ApexPages.currentPage().getParameters().get('id');
        if(paymentId != null)
            payId = paymentId; 
        demandLetterControllermethod();
    }
    
    public void demandLetterControllermethod() {
        set<string> projectId = new set<string>();
        if(payId != null && payId != ''){
            pay = [Select id,Name,PropStrength__Application_Booking__r.PropStrength__Booking_Date__c ,
                   PropStrength__Application_Booking__r.PropStrength__Super_Area__c,PropStrength__Application_Booking__r.PropStrength__Project__c,
                   PropStrength__Application_Booking__r.PropStrength__Revised_Total_Sales_Consideration__c,
                   PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__GST_Status__c,
                   PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c,
                   PropStrength__Actual_Payment_Date__c,PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Amount_Due__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Payment_Plan_Line_Item__r.PropStrength__Order__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Total_Other_Charges_Dues__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Total_Service_Tax_Due_on_BSP__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Total_Service_TAx_due_on_Other_Charges__c,
                   PropStrength__Payment_Plan_Detail__r.PropStrength__Amount_Percent__c,
                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Name,
                   PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingStreet, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.Email, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCity, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingState, PropStrength__Application_Booking__r.PropStrength__Primary_Customer__r.MailingCountry,
                   PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                   PropStrength__Application_Booking__r.PropStrength__Project__r.Name
                   from PropStrength__Received_Payment__c 
                   where id =: payId ];
        }
        system.debug('====pay====='+pay);
        
        //================================Bank GL Start =================================================================//
        if(pay.PropStrength__Application_Booking__r.PropStrength__Project__c != null){
            projectId.add(pay.PropStrength__Application_Booking__r.PropStrength__Project__c);
        }
        
        system.debug('====projectId====='+projectId);
        if(!projectId.isEmpty()){
            BankGLlist = [select id,name ,Beneficiary__c,Account_Number__c,
                          IBAN__c,Swift_Code__c,Bank_Name__c,Bank_Account_Type__c
                          from Bank_GL__c where Project__c =: projectId];
            system.debug('=====BankGLlist===='+BankGLlist);
            
            if(!BankGLlist.isEmpty()){
                for(Bank_GL__c Bank : BankGLlist){
                    if(Bank.Bank_Account_Type__c.containsIgnoreCase('Escrow Account')){
                        BankGl = bank; 
                    }
                }
            }
        }
        //================================Bank GL End=================================================================//
        
        //================================Tax Record Start =================================================================//
        
        tax = [select id,name,PropStrength__New_Tax_Percentage__c,PropStrength__Tax_Percentage__c
               from PropStrength__Tax_Record__c];
       
        //================================Tax Record End =================================================================//
        
    }
    
    
}