public class PreRegistrationNoticeController{

    public String noticeDate{get;set;}
    public Id bookId {get;set;}
    public Booking__c b {get;set;} 
    public List<Applicant_Details__c> primApplicant {get;set;} 
    public String Ref {get;set;}
    public String KnowledgefeesString {get;set;}
    public String DLDfeesString {get;set;}
    public String DLDKnowledgefeesString {get;set;}
    public String DLDAdminfeesString {get;set;}
    public String DLDTotalfeesString {get;set;}
    Map<String, Integer> projChargeSeq;
    public List<Quotation__c> qList {get; set;}
    public String bankAddress {get;set;}

    public PreRegistrationNoticeController(){
      Ref = ''; 
      KnowledgefeesString = '';
      DLDfeesString = '';
      DLDAdminfeesString = '';
      DLDKnowledgefeesString  ='';
      DLDTotalfeesString = '';
      projChargeSeq = new Map<String,Integer>();
      bankAddress ='';
      primApplicant = new List<Applicant_Details__c>();
      
    
      if(ApexPages.currentPage().getParameters().get('Id') != null && ApexPages.currentPage().getParameters().get('Id') != ''){
          bookId = ApexPages.currentPage().getParameters().get('Id');              
      }
       
      if(bookId != null){
       b = [SELECT Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c, Opportunity__r.Permanent_Address__c, Opportunity__r.Primary_Email__c,
            Opportunity__r.Primary_Phone__c, Unit__r.Name, Unit__r.Tower__r.Name, Unit__r.Tower__r.RDS_Company_Code__r.Name,
            Unit__r.Tower__r.Address__c, Project__r.Name, Agreement_Value__c, Quotation__c, Unit__r.Project__r.Name, Unit__r.Tower__r.Id,
            Unit__r.Project__r.Address__c, Unit__r.Project__r.Website__c, Opportunity__r.Other_Applicants_Email__c, Opportunity__r.Other_Applicant_Mobile_Number__c 
            FROM Booking__c WHERE Id = :bookId];
      }
      noticeDate = System.Today().format();
      
      primApplicant = [SELECT Salutation__c, Name, Opportunity__c, Booking__c from Applicant_Details__c 
                       WHERE Booking__c= : b.Id];
                       
      
      
    //// Concatinating Ref
    if(b != null){    
      if(b.Unit__r.Name != null && String.isNotBlank(b.Unit__r.Name))
          Ref = 'Unit No. ' + b.Unit__r.Name + ', ';  
      //if(b.Unit__r.Tower__r.Name != null && String.isNotBlank(b.Unit__r.Tower__r.Name))
        //  Ref += b.Unit__r.Tower__r.Name + ', ';
      if(b.Unit__r.Tower__r.RDS_Company_Code__c != null && String.isNotBlank(b.Unit__r.Tower__r.RDS_Company_Code__c))
          Ref += b.Unit__r.Tower__r.RDS_Company_Code__r.Name + ', ';
      if(b.Unit__r.Tower__r.Address__c != null && String.isNotBlank(b.Unit__r.Tower__r.Address__c))
          Ref += b.Unit__r.Tower__r.Address__c;
     
     ////// For DLD Charges
      String qId = b.Quotation__c;
      String queryString = '';
      for(Integer i = 1; i<=25; i++) {
        queryString += 'Charge' + i + 'Name__c'   + ',';
        queryString += 'Charge' + i + 'Value__c'  + ',';
        queryString += 'Charge' + i + 'Bucket__c' + ',';                               
      }
    
      queryString += 'Name, Unit__r.Id, Unit__r.Project__r.Name, Unit__r.Typology__c, Unit__r.Tower__r.Name, Unit__r.Tower__r.Cluster__r.Name, Unit__r.Tower_No__c,'+
                    'Unit__r.Floor__c, Unit__r.Unit_No__c, Unit__r.Unit_Status__c, Unit__r.No_of_Bedroom__c, Total_Other_Charges_Bucket__c,'+ 
                    'Unit__r.Super_Builtup_Area_Sq_Ft__c, Total_Agreement_Value_Bucket__c, Premium1_Original_PSF__c, Total_SD_Registration_Bucket__c,' +
                    'Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.Favouring__c, Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c, Unit__r.Unit_Type__c,' +
                    'Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c, Unit__r.Tower__r.Building_Number__c, Unit__r.Tower__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c, Unit__r.Floor_No_to_print__c,' +                                                                    
                    'Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c, Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c, Payment_Plan__r.Disclaimer__c, Unit__r.Configuration__c, Unit__r.Chargeable_Area__c,' +
                    'Unit__r.Tower__r.RDS_Company_Code__r.Developer_ID__c,  Unit__r.Name, Unit__r.Tower__r.RDS_Company_Code__r.Project_Name_ID__c, Floor_Rise_Original_PSF__c, Opportunity__r.AccountId, CreatedDate ';                                            
           if (qId != null) {
                queryString = 'Select ' + queryString  +' FROM Quotation__c WHERE Id = \'' + qId + '\'' ;
                qList = Database.Query(queryString);
           }
           
           
       
     
     if(qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != null || qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c != ''){
           bankAddress = qList[0].Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c;
           if(qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c != null || qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c != ''){
               bankAddress += ', ' + qList[0].Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c;
      }
     }      
     projChargeSeq = InventoryCostServices.getProjectChargesSequence(b.Unit__r.Project__r.Name, b.Unit__r.Tower__r.Id);
     if(!projChargeSeq.isEmpty() && projChargeSeq.size() > 0) {     
         integer knowledgefeesseq = projChargeSeq.get('Knowledge Fees'); 
         if(!String.isBlank(String.valueOf(knowledgefeesseq))) {
             if(qList[0].get('Charge' + knowledgefeesseq + 'Value__c') != null){
                 KnowledgefeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c'));                                     
             }                 
         }          
         integer DLDfeesseq = projChargeSeq.get('DLD'); 
         if(!String.isBlank(String.valueOf(DLDfeesseq ))) {
             if(qList[0].get('Charge' + DLDfeesseq + 'Value__c') != null){
                 DLDfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c'));                        
             }
         }
        integer DLDAdminfeesseq = projChargeSeq.get('DLD Admin Fees'); 
             if(!String.isBlank(String.valueOf(DLDAdminfeesseq ))) {
                 if(qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c') != null){
                     DLDAdminfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c'));                         
                 }
             }
        
        
     if(!String.isBlank(String.valueOf(knowledgefeesseq)) &&  !String.isBlank(String.valueOf(DLDAdminfeesseq ))){
        if(qList[0].get('Charge' + knowledgefeesseq + 'Value__c') != null && !String.isBlank(String.valueOf(DLDfeesseq ))){
             DLDKnowledgefeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c') + 
                                      (Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c'));
          
          if(!String.isBlank(String.valueOf(DLDAdminfeesseq ))) {
                 if(qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c') != null){
         
                  DLDTotalfeesString = InventoryCostServices.InFormat((Decimal)qList[0].get('Charge' + knowledgefeesseq + 'Value__c') + 
                                      (Decimal)qList[0].get('Charge' + DLDfeesseq + 'Value__c') + (Decimal)qList[0].get('Charge' + DLDAdminfeesseq + 'Value__c'));
                     
                     }
              }  
        
           }
        } 
        
        
      
     }
    }
  }
 }