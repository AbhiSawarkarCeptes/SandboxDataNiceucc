/*********

Class Name HandoverDocumentGeneration
Created By Tania Chattopadhyay
Created Date 20 Jan 2022

**********/
public class HandoverDocumentController{

public String currentRecordId {get;set;}
//public String parameterValue {get;set;}
public Booking__c acc{get;set;}
public List<Applicant_Details__c> app {get;set;}
public HandOver_CheckList__c handoverChecklist {get;set;}
public Map<Applicant_Details__c,Integer> mapadd{get;set;}
public Integer siz {get;set;}
public Integer count;
 
    public HandoverDocumentController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        acc = [select id ,name, Unit__r.Name, Unit__r.Main_Door_Keys__c, Unit__r.Internal_Door_Keys__c, Unit__r.Parking_Bay_Allocation_No__c,
        Unit__r.Parking_Remote_Access__c, Unit__r.Access_Cards__c, Unit__r.Residents_Manual__c, Tower__c, Unit__r.Legal_Entity__r.RDS_Address1__c,Unit__r.Legal_Entity__r.Favouring__c,
        Unit__r.Legal_Entity__r.Bank_Name_Flat_Cost__c,Handover_Schdule_Date__c,
        Unit__r.Legal_Entity__r.Account_Number_Flat_Cost__c, Unit__r.Legal_Entity__r.IBAN__c,
        Unit__r.Legal_Entity__r.MICR_Code_Flat_Cost__c,Unit__r.Tower__r.Name, Unit__r.Sub_project_tower__c , Unit__r.Legal_Entity__r.Name,Unit__r.Legal_Entity__r.Project_Name_ID__c, Unit__r.Project__r.Name from Booking__c where id =: currentRecordId ];
        
      //  parameterValue = ApexPages.CurrentPage().getparameters().get('nameParam');
        
        mapadd = new Map<Applicant_Details__c, Integer>();
        
        app=[select id,Name,Salutation__c,Mailing_Address__c,Mobile_Number__c,
        Email_Address__c, Passport_Copy_Details__c, PassportNoDetails__c, Valid_Until_Passport__c,
        Nationality__c from Applicant_Details__c where Booking__c =: currentRecordId ];                      
        
        handoverChecklist = [select id, Name, Booking__c,ExpectedMoveinRentaldetailsComments__c,On_Completion_Due_Amount_Paid_Comments__c,
        PCI_Cheques_Comments__c,DEWA_Registration_Confirmation_Comments__c,ServiceChargesComments__c,SPA_Executed_Comments__c,
        Pre_registration_Completed_Comments__c,PCCReceipt_Comments__c,MoveInformVehicleregistratioComments__c,PCILetterofUndertakingComments__c,
        TitleDeedchargesComments__c,CustomerFeedbackformComments__c,EscrowAccountLetterComments__c,HandoverOfPossessionLetterComments__c ,
        Customer_Feedback_form__c,DEWA_Registration_Confirmation__c,Escrow_Account_Letter__c,Expected_Move_in_Rental_details__c,
        Handover_Of_Possession_Letter__c,LastModifiedById,Move_In_form_Vehicle_registration_form__c,On_Completion_Due_Amount_Paid__c,
        PCC_Receipt__c,PCI_Letter_of_Undertaking__c,PCI_Cheques__c,Pre_registration_Completed__c,Service_Charges__c,
        SPA_Executed__c,Title_Deed_charges__c from HandOver_CheckList__c where Booking__c =: currentRecordId ORDER BY Id DESC LIMIT 1 ];
        
        /*********** Comma Separated between Apex : Repeat Applicant Details ***********/
        siz = app.size();
        count = 0;
        for(Applicant_Details__c  a : app) {
            count++;
            mapadd.put(a,count);                           
        }   
       
    }   
}