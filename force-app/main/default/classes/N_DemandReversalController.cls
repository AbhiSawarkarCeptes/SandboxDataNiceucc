public class N_DemandReversalController{
    String dId;
    Demand__c dmnd;
  
    public N_DemandReversalController(){
        dmnd = new Demand__c();
        
        if (Apexpages.Currentpage().getParameters().get('id') != null && Apexpages.Currentpage().getParameters().get('id') != '')
            dId = Apexpages.Currentpage().getParameters().get('id');
        
        if(string.isNotBlank(dId) && dId != null){
            dmnd = [SELECT Id, Name, Demand_Status__c, Booking__c, Booking__r.Opportunity__c, Payment_Milestones__c, Booking__r.Project__c, Registration_Collection_Control_Report__c, 
                    Booking__r.Unit__c, Total_Amount_with_Tax_Demanded__c, Remarks__c, Debit_Type__c, Payment_Towards__c, Total_Amount_Account__c, Total_Tax_Account__c, Corporate_Collection_Control_Report__c,
                    Total_Amount_with_Tax_Account__c, Business_Unit__c, Business_Unit_Code__c, Receipt__c, Tax_Rate__c, Total_Amount_Demanded__c, Total_Tax_Demanded__c, Milestone_Name__c
                    From Demand__c where id = :dId];
        } 
    }
    
    public PageReference createCreditNote(){
         if(dmnd.Demand_Status__c != null && dmnd.Demand_Status__c != '' && dmnd.Demand_Status__c == 'Reversed'){
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, 'This demand is already reversed'));
             return null;                     
        } else {
            List<Account_Master__c> amDebit = [select Id, Name from Account_Master__c where Name = 'Receipt transfer credit (swap)' LIMIT 1];
       
            Receipt__c r = new Receipt__c();
            r.Description__c = 'Credit Note for Demand Rejection: '+ dmnd.Name + ' /' + dmnd.Milestone_Name__c;
            r.Demand__c = dId;        
            r.Booking__c = dmnd.Booking__c;
            r.Opportunity__c = dmnd.Booking__r.Opportunity__c;
            r.Project__c = dmnd.Booking__r.Project__c;
            r.Project_Unit__c = dmnd.Booking__r.Unit__c;
            r.Amount_Rs__c = dmnd.Total_Amount_with_Tax_Demanded__c;
            r.Total_Amount__c = dmnd.Total_Amount_with_Tax_Demanded__c;
            r.Credit_Note_Amount__c = dmnd.Total_Amount_Demanded__c;
            r.Tax_Amount__c = dmnd.Total_Tax_Demanded__c;
            r.Tax_Rate__c = dmnd.Tax_Rate__c;
            r.Mode__c = 'Credit Note';
            r.Cheque_DD_Date__c = system.today();
            r.Receipt_Status__c = 'Cleared';
            r.Payment_Towards__c = dmnd.Payment_Towards__c ;
            r.Physically_Cheque_Received__c = true;
            r.Banking__c = 'Payment Successful';
            r.Reason_for_rejection_new__c = 'Accepted';
            r.GL_Date__c = System.Today(); //// credit note creation date
            r.Receipt_Date__c = System.Today(); //// receipt creation date
            r.Cheque_DD_Date__c = System.Today();
            r.Debit_Account__c = dmnd.Total_Amount_Account__c;//Added by Dipak for SOB-1469 //amDebit.size() > 0 ? amDebit[0].id : null;
            r.Tax_Debit_Account__c = dmnd.Total_Tax_Account__c;
            r.Credit_Account__c = dmnd.Total_Amount_with_Tax_Account__c;//Added by Dipak for SOB-1469 //dmnd.Total_Amount_with_Tax_Account__c;       
            r.Business_Unit__c = dmnd.Business_Unit__c;
            r.Business_Unit_Code__c = dmnd.Business_Unit_Code__c;
            r.Is_Reversed_Receipt__c = true;  
            r.Hide_From_SOA__c  = true;  
            r.Registration_Collection_Control_Report__c = dmnd.Registration_Collection_Control_Report__c;
            r.Corporate_Collection_Control_Report__c = dmnd.Corporate_Collection_Control_Report__c;                          
            insert r;
            
            dmnd.Remarks__c = 'Reversed from Actions';
            dmnd.Demand_Status__c = 'Reversed';
            dmnd.Receipt__c = r.Id;
            update dmnd; 
            return new PageReference('/'+ r.Id);     
        }     
    }
}