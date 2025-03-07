public class RemainderNoticeController {
    Id bId;
    public Booking__c b{get; set;}
    public Decimal amountToBePaid{get;set;}
    public legal_entity__c le {get;set;}
    public Demand__c demandData{get; set;}
    public String dueAmountText{get; set;}
    public Integer dueAmountInt{get; set;}
    public String dueDays{get; set;}
    
    
    public RemainderNoticeController() {
        
        if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != '')
            bId =  ApexPages.currentPage().getParameters().get('Id');  

        Decimal totalAmountDemanded = 0;
        Decimal TotalonAccountmoney = 0;
        String legalEntityId = '';
        demandData = [SELECT id,OutStanding_days_calculated__c, Ageing__c, Booking__c,
                                      Booking__r.Milestone_Due_Till_Date__c,Agreement_Value_Balance__c,
                          			  booking__r.Total_On_Account_Money_With_Registration__c,booking__r.Unit__r.Name,
                          			  booking__r.Due_Payments__c,booking__r.Total_Interest_Till_Date__c,
                                      Last_Reminder_Notice_Amount_1__c,Last_Reminder_Notice_Amount2__c,Reminder_Notice1__c,
                                      Reminder_Notice2__c,Reminder_Sent_Date_2__c,booking__r.name,Reminder_Sent_Date1__c,
                                      Total_Amount_Demanded__c,booking__r.Opportunity__r.Primary_Email__c,
                      				  booking__r.SPA_Executed_Date__c,Date_for_Late_Payment_Calculation__c
                      	              FROM Demand__c 
                                      WHERE ID =: bId	
                                     ];
        b = [SELECT ID,Primary_Applicant_Name__c,unit__r.Name,Booking_Date__c,Primary_Applicant_Address__c,Purchase_Price_Only__c,
             Name,Milestone_Due_Till_Date__c, Total_On_Account_Money_With_Registration__c,Project_Name__c,OwnerId,SPA_Executed_Date__c,
             Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Primary_Name__c,unit__c,unit__r.Legal_Entity__r.Id
                          FROM Booking__c
                          WHERE Id =: demandData.Booking__c];
        if(b.Unit__r.legal_entity__r.id != null){
            legalEntityId = b.Unit__r.legal_entity__r.id;
            le = [Select Name,Account_Name_Flat_Cost__c, Account_Number_Flat_Cost__c, Bank_Name_Flat_Cost__c,
                  Branch_Name_Flat_Cost__c,IFSC_Code_Flat_Cost__c, MICR_Code_Flat_Cost__c,
                  RDS_PAN_No__c,RDS_Company_Name__c,Account_Name_Service_Tax__c,Account_Number_Service_tax__c, 
                  Bank_Name_Service_tax__c,Branch_Name_Service_Tax__c, IFSC_Code_Service_Tax__c, MICR_Code_Service_Tax__c, 
                  RDS_Service_Tax_No__c,RDS_Address1__c,RDS_Address2__c, RDS_City__c, RDS_Pin_Code__c, CIN__c,
                  Account_Name_Other_Charges__c,Account_Number_Other_Charges__c,Bank_Name_Other_Charges__c,Branch_Name_Other_Charges__c,
                  IFSC_Code_Other_Charges__c,MICR_Code_Other_Charges__c,Account_Name_Other_Charges_Tax__c,Account_Number_Other_Charges_Tax__c,
                  Bank_Name_Other_Charges_Tax__c,Branch_Name_Other_Charges_Tax__c,IFSC_Code_Other_Charges_Tax__c,
                  MICR_Code_Other_Charges_Tax__c,GST__c,SPV_Bank_Account__c,RDS_Status__c,RDS_TDS_Circle__c,RDS_Phone__c,
                  RDS_Company_ID__c,RDS_Company_Code__c, IBAN__c, IBAN_Tax__c, Favouring__c
                  FROM Legal_Entity__c where Id = :legalEntityId];
            
        }
        if(demandData.Total_Amount_Demanded__c != null){
            totalAmountDemanded = demandData.Total_Amount_Demanded__c;
        }
        amountToBePaid = totalAmountDemanded;
        if(amountToBePaid != null){
            dueAmountInt = Integer.valueOf(amountToBePaid);
            dueAmountText = NumberToText.convert(dueAmountInt);
        }
        
        
        if(demandData.Date_for_Late_Payment_Calculation__c == System.today()){
            dueDays = 'by end of the day';
        }else{
            dueDays = 'within 15 days';
        }
    }

}