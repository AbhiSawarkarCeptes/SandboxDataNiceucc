public class N_SPAPDFController {
    Id BookingId;
    public Booking__c b {get;set;}
    public List <Applicant_Details__c> listAppDetails {get;set;}
    public List <ADWrapper> adList {get;set;}
    public decimal purchasePrice;
    public String purchasePriceString {get;set;}
    public List <PMWrapper> pmwList {get;set;}
    public String qId;
    public List<Quotation__c> qList;
    public List<Payment_Milestones__c> pmList;
    public Map<String, Integer> projChargeSeq = new Map<String,Integer>();
    public String additionalCarPark {get;set;}

    public N_SPAPDFController(){
         adList = new List <ADWrapper>();
         pmwList = new List<PMWrapper>();
         pmList  = new List<Payment_Milestones__c>();
         purchasePrice = 0;

        if(ApexPages.currentPage().getParameters().get('id') != null){
            BookingId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if(BookingId != null){
            b = [SELECT Quotation__r.Id, Unit__r.Chargeable_Area__c, Unit__r.Tower__r.District__c, Unit__r.Permitted_Use__c,
                 Unit__r.Tower__r.RDS_Company_Code__r.IBAN__c, Unit__r.Tower__r.RDS_Company_Code__r.MICR_Code_Flat_Cost__c, 
                 Unit__r.Tower__r.RDS_Company_Code__r.Bank_Name_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.RDS_Address1__c, 
                 Unit__r.Tower__r.RDS_Company_Code__r.Account_Number_Flat_Cost__c, Unit__r.Tower__r.RDS_Company_Code__r.Account_Holder__c,
                 Quotation__r.TotalEarmarkedCarpark__c, Quotation__r.TotalAdditionalCarpark__c, Unit__r.Project_Property_Type__c,
                 Unit__r.Tower__r.DLD_Building_Number__c, Agreement_Value__c, Tax_on_Purchase_Price__c,Tower__c, Unit__r.Tower__r.Cluster__r.Name,
                 Unit__r.Unit_No__c, Unit__r.Floor_No_to_print__c, Unit__r.Tower__r.RDS_Company_Code__r.Developer_ID__c, Unit__r.Plot_Area__c,
                 Unit__r.Tower__r.RDS_Company_Code__r.Project_Name_ID__c, Unit__r.Tower__r.Date_of_Completion__c, Unit__r.Plot_Number__c                                             
                 FROM Booking__c WHERE Id = :BookingId];   
        }
        if(b != null){
            if(b.Agreement_Value__c != null)
                purchasePrice = b.Agreement_Value__c;
       //     if(b.Tax_on_Purchase_Price__c != null)
              //  purchasePrice += b.Tax_on_Purchase_Price__c; 
            purchasePriceString = InventoryCostServices.INFormatR(purchasePrice );   
            if(b.Quotation__r.TotalAdditionalCarpark__c != null){
                if(b.Quotation__r.TotalAdditionalCarpark__c == 0)
                    additionalCarPark = 'NIL';
                else
                    additionalCarPark = String.ValueOf(b.Quotation__r.TotalAdditionalCarpark__c);
            }                              
        }
        qId = b.Quotation__r.Id;
        
        listAppDetails = [SELECT Id, Salutation__c, Applicant_Number__c, Name, Mobile_Number__c, Email_Address__c, Nationality__c, Landline_Number__c,
                          Passport_Copy_Details__c, Valid_Until_Passport__c, Mailing_Address__c, Mailing_City__c, Mailing_State__c,
                          Mailing_Country__c, Permanent_Address__c, City__c, State__c, Country__c, Power_of_Attorney_Details__c
                          FROM Applicant_Details__c
                          WHERE Booking__c = :BookingId]; 
        if(listAppDetails.size() > 0 && listAppDetails != null){
           for(Applicant_Details__c a: listAppDetails){
               ADWrapper adw = new ADWrapper(a); 
               adList.add(adw);
           }   
        }
        
// For Payment Plan Milestone
    String queryString = '';
    queryString = 'Unit__r.Id, Unit__r.Project__r.Name, Unit__r.Tower__r.Id';                   
                    
       if (qId != null) {
            queryString = 'Select ' + queryString  +' FROM Quotation__c WHERE Id = \'' + qId + '\'' ;
            qList = Database.Query(queryString);
        }

        projChargeSeq = InventoryCostServices.getProjectChargesSequence(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        integer basicSeq;
        if(!projChargeSeq.isEmpty() && projChargeSeq.size() > 0) {
             basicSeq = projChargeSeq.get('Basic');        
        }
          
        Map<String,ProjectCharges__c> projChargesMap = InventoryCostServices.getProjectChargesMap(qList[0].Unit__r.Project__r.Name, qList[0].Unit__r.Tower__r.Id);
        Map<String,Integer> AVChargesSeqMap = new Map<String, Integer>();
        Integer Seq = 1;
        String chgName = '';
              
        //creating a list of all charges that are part of the agreement value their field location, to identify whether they are stored in Charge1, Charge2, Charge3, etc.,
        for(String chargeName : projChargesMap.keySet()) {
            chgName = projChargesMap.get(chargeName).ChargeBucket__c;                
            if(chgName.equalsIgnoreCase('Agreement Value')) {
                    AVChargesSeqMap.put(chargeName, Seq);                    
            }                              
            Seq++;
        }
        AVChargesSeqMap.put('Interest On Common Area Charges',Seq);

        String queryString1 = '';
        for(Integer i = 1; i<=25; i++) {
            queryString1 += 'Charge' + i + 'Name__c'   + ',';
            queryString1 += 'Charge' + i + 'Percentage__c'  + ',';
            queryString1 += 'C' + i + '_Amount__c' + ','; 
            queryString1 += 'C' + i + '_CGST__c'   + ','; 
            queryString1 += 'C' + i + '_SGST__c'   + ','; 
        }
        
        if (qId != null) {
            queryString1 = 'SELECT ' + queryString1  + ' Id, Name, Milestone_Name__c, Milestone_Due_Date__c, Milestone_Complete_At_Booking__c, Demand_Raised__c, Milestone_Type_edit__c, Is_Combination_Milestone__c, Construction_Stage_Actual_CompletionDate__c FROM Payment_Milestones__c WHERE Quotation__c = \'' + qId + '\' order by Name ASC' ;                                                                     
            pmList = Database.Query(queryString1);
        }
            Decimal srno = 0;
            
        for(Payment_Milestones__c pm: pmList) {
        // check all the values in Agreement value bucket and sum total its amount and taxes
                Decimal totalAmt = 0;
                Decimal totalTax = 0;
                Decimal sizeOfPM = pmList.size();                                        
                srno ++;
                for(Integer i : AVChargesSeqMap.values()) {
                    totalAmt += (Decimal)pm.get('C' +i + '_Amount__c' );
                    totalTax += (Decimal)pm.get('C' + i + '_CGST__c' ) + (Decimal)pm.get('C' + i + '_SGST__c' );                            
                }                 
                if(pm.get('Charge' + basicSeq + 'Percentage__c') != null) {
                    pmWrapper pmw = new pmWrapper(srno, pm.Milestone_Due_Date__c,  pm.Milestone_Name__c, pm.get('Charge' + basicSeq + 'Percentage__c') + '%', totalAmt, pm.Milestone_Complete_At_Booking__c, pm.Milestone_Type_edit__c, sizeOfPM, pm);
                    pmwList.add(pmw);
                }            
        }      
    }
    
     public class ADWrapper{
        public Applicant_Details__c ad {get;set;}
     ///   public String permanentAddress {get;set;}
        public String mailingAddress {get;set;}
        public String validityDate {get;set;}
    
         public ADWrapper(Applicant_Details__c app){
         this.ad = app;
         this.mailingAddress  = '';
       ///  this.permanentAddress = '';
         if(app.Valid_Until_Passport__c != null)
             this.validityDate = app.Valid_Until_Passport__c.format();
    //// For mailing address     
         if(app.Mailing_Address__c != null){
             this.mailingAddress = app.Mailing_Address__c; 
             if(app.Mailing_City__c != null || app.Mailing_State__c != null  || app.Mailing_Country__c != null) {
                 this.mailingAddress += ', '; 
             }
         }
         if(app.Mailing_City__c != null){
           this.mailingAddress += app.Mailing_City__c;
           if(app.Mailing_State__c != null || app.Mailing_Country__c != null) {
               this.mailingAddress += ', '; 
           }          
         }
         if(app.Mailing_State__c != null){      
           this.mailingAddress += app.Mailing_State__c;
           if(app.Mailing_Country__c != null) {
               this.mailingAddress += ', '; 
           }          
         }
         if(app.Mailing_Country__c != null){
           this.mailingAddress += app.Mailing_Country__c;       
         }    
     //// For permanent address     
     /*    if(app.Permanent_Address__c!= null){
             this.permanentAddress = app.Permanent_Address__c; 
             if(app.City__c != null || app.State__c != null || app.Country__c != null) {
                 this.permanentAddress += ', '; 
             }
         }
         if(app.City__c != null){
           this.permanentAddress += app.City__c;
           if(app.State__c != null || app.Country__c != null) {
               this.permanentAddress += ', '; 
           }          
         }
         if(app.State__c != null){      
           this.permanentAddress += app.State__c;
           if(app.Country__c != null) {
               this.permanentAddress += ', '; 
           }          
         }
         if(app.Country__c != null){   
           this.permanentAddress += app.Country__c;                
         }   */    
      }
    }
    
    public class PMWrapper {
        public Decimal count {get;set;}
        public String dueDate {get;set;} 
        public String installment {get;set;}
        public String milestoneName {get;set;}
        public String amount        {get;set;}
        public String pct           {get;set;}
      ///  public String amtPayable    {get;set;}
     //   public String rowStyle      {get;set;}
        public Decimal sizeOfPM;
        
        public PMWrapper(Decimal srno, Date milestoneDueDate, String msName, String pct, Decimal amt, Boolean milestoneAchieved, String milestoneType, Decimal size, Payment_Milestones__c pm) {
            this.count = srno;
            this.installment = '';
            this.milestoneName = msName;
            this.sizeOfPM = size;
            ///// Changed by Neha on 4/6/19 to print milestone due date on Booking PDF
            if(pm.Milestone_Type_edit__c == 'Construction Linked' && pm.Demand_Raised__c == false){
                this.dueDate = '-';
            } else if(pm.Milestone_Type_edit__c == 'Date Linked' && pm.Is_Combination_Milestone__c == true && pm.Demand_Raised__c == false){
                if(pm.Construction_Stage_Actual_CompletionDate__c == null){
                    this.dueDate = '-';    
                }
            }
            else if(milestoneDueDate != null){
                this.dueDate = milestoneDueDate.Format();
            } 
                        
            this.pct           = pct;
            this.amount        = InventoryCostServices.InFormat(amt);
        /*    if (msName == 'Total') {
                this.rowStyle  = 'font-weight:bold';
            }
            if(milestoneAchieved) {
                this.rowStyle  = 'background-color:#D7BF5E';
            }*/
            if(this.milestoneName == 'Token'){
                 this.installment = 'Booking Amount';              
            }
           if(this.count == 2){
                 this.installment = 'First Installment';              
            }
            if(this.count == 3){
                 this.installment = 'Second Installment';              
            }
            if(this.count == 4){
                 this.installment = 'Third Installment';              
            }
            if(this.count == 5){
                 this.installment = 'Fourth Installment';              
            }
            if(this.count == 6){
                 this.installment = 'Fifth Installment';              
            }
            if(this.count == 7){
                 this.installment = 'Sixth Installment';              
            }
            if(this.count == 8){
                 this.installment = 'Seventh Installment';              
            }
            if(this.count == 9){
                 this.installment = 'Eighth Installment';              
            }
            if(this.count == 10){
                 this.installment = 'Ninth Installment';              
            }
            if(this.count == 11){
                 this.installment = 'Tenth Installment';              
            }
            if(this.count == 12){
                 this.installment = 'Eleventh Installment';              
            }
            if(this.count == 13){
                 this.installment = 'Twelfth Installment';              
            }
            if(this.count == 14){
                 this.installment = 'Thirteenth Installment';              
            }
            if(this.count == 15){
                 this.installment = 'Fourteenth Installment';              
            }
            if(this.count == 16){
                 this.installment = 'Fifteenth Installment';              
            }
            if(this.count == 17){
                 this.installment = 'Sixteenth Installment';              
            }
            if(this.count == 18){
                 this.installment = 'Seventeenth Installment';              
            }
            if(this.count == 19){
                 this.installment = 'Eighteenth Installment';              
            }
            if(this.count == 20){
                 this.installment = 'Nineteenth Installment';              
            }
             if(this.count == 21){
                 this.installment = 'Twentieth Installment';              
            }
            if(this.count == 22){
                 this.installment = 'Twenty-First Installment';              
            }
            if(this.count == 23){
                 this.installment = 'Twenty-Second Installment';              
            }
            if(this.count == 24){
                 this.installment = 'Twenty-Third Installment';              
            }
            if(this.count == 25){
                 this.installment = 'Twenty-Fourth Installment';              
            }
            if(this.count == 26){
                 this.installment = 'Twenty-Fifth Installment';              
            }
            if(this.count == 27){
                 this.installment = 'Twenty-Sixth Installment';              
            }
            if(this.count == 28){
                 this.installment = 'Twenty-Seventh Installment';              
            }
            if(this.count == 29){
                 this.installment = 'Twenty-Eighth Installment';              
            }
            if(this.count == 30){
                 this.installment = 'Twenty-Ninth Installment';              
            }
            if(this.count == 31){
                 this.installment = 'Thirtieth Installment';              
            }
            if(this.count == 32){
                 this.installment = 'Thirty-First Installment';              
            }
            if(this.count == 33){
                 this.installment = 'Thirty-Second Installment';              
            }
            if(this.count == 34){
                 this.installment = 'Thirty-Third Installment';              
            }
            if(this.count == 35){
                 this.installment = 'Thirty-Fourth Installment';              
            }
            if(this.count == 36){
                 this.installment = 'Thirty-Fifth Installment';              
            }
            if(this.count == 37){
                 this.installment = 'Thirty-Sixth Installment';              
            }
            if(this.count == 38){
                 this.installment = 'Thirty-Seventh Installment';              
            }
            if(this.count == 39){
                 this.installment = 'Thirty-Eighth Installment';              
            }
            if(this.count == 40){
                 this.installment = 'Thirty-Ninth Installment';              
            }
            if(this.count == 41){
                 this.installment = 'Fortieth Installment';              
            }
            if(this.count == 42){
                 this.installment = 'Forty-First Installment';              
            }
            if(this.count == 43){
                 this.installment = 'Forty-Second Installment';              
            }
            if(this.count == 44){
                 this.installment = 'Forty-Third Installment';              
            }
            if(this.count == 45){
                 this.installment = 'Forty-Fourth Installment';              
            }
            if(this.count == 46){
                 this.installment = 'Forty-Fifth Installment';              
            }
            if(this.count == 47){
                 this.installment = 'Forty-Sixth Installment';              
            }
            if(this.count == 48){
                 this.installment = 'Forty-Seventh Installment';              
            }
            if(this.count == 49){
                 this.installment = 'Forty-Eighth Installment';              
            }
            if(this.count == 50){
                 this.installment = 'Forty-Ninth Installment';              
            }
            if(this.count == 51){
                 this.installment = 'Fiftieth Installment';              
            }    
            if(this.count == this.sizeOfPM && this.milestoneName != 'Token'){
                 this.installment = 'Final Installment';  
            }                      
        }
    }
}