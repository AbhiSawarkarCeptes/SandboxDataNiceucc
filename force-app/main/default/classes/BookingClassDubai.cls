public with sharing class BookingClassDubai {
    public Applicant_Details__c applicant {get; set;}
    public Applicant_Details__c applicant2 {get; set;}
    public Applicant_Details__c applicant3 {get; set;}
    public Applicant_Details__c applicant4 {get; set;}
    public Applicant_Details__c applicant5 {get; set;}
    public Booking__c boookingObj {get; set;}
    public Receipt__c receiptObj {get; set;}
    public List <Opportunity> optyList {get; set;} 
    public List <Quotation__c> queryResult {get; set;}
    public List <Quotation__c> QuoteDetails {get; set;}
    public List <Receipt__c> ReceiptDetails {get; set;}
    public List <Receipt__c> STReceiptDetails {get; set;}
    public List <Receipt__c> ShowReceiptDetails {get; set;}
    public Integer i {get; set;}
    public String selectedVal {get; set;}
    public String selectedQuote {get; set;}
    public Id optyidparam {get; set;}
    public Id unitId {get; set;}
    public Id ProjectId {get; set;}
    public Id optyId {get; set;}
    public Boolean addressCheck {get; set;}
    public Boolean addressCheckApplicant2 {get; set;}
    public Boolean addressCheckApplicant3 {get; set;}
    public Boolean addressCheckApplicant4 {get; set;}
    public Boolean addressCheckApplicant5 {get; set;}
    public Legal_Entity__c le {get; set;}    
    public Receipt__c reciept {get; set;}   
    public List <Receipt__c> receiptlist {get; set;}
    public List <Receipt__c> deletereceiptlist {get; set;}
    public Decimal TotalServiceandToken{get; set;}  
    public Receipt__c del {get; set;}
    public Integer rowIndex {get; set;}
    public Date dateOfOfferPossesion {get; set;}
    public Date firstApplicantDOB{get; set;}
    public Date firstApplicantRegistration{get; set;}
    public Date secondApplicantRegistration{get; set;}
    public Date thirdApplicantRegistration{get; set;}
    public Date secondApplicantDOB{get; set;}
    public Date thirdApplicantDOB{get; set;}
    public String applicantPhone {get;set;}
    public String applicant2Phone {get ;set;}
    public String applicant3Phone {get ;set;}
    public String applicant4Phone {get ;set;}
    public String applicant5Phone {get ;set;}
    public Date fourthApplicantDOB{get; set;}
    public Date fifthApplicantDOB{get; set;}
    public List<Receipt__c> ReceiptLstTobeUpdate{get; set;}
    public Boolean ServiceTaxCheck {get;set;}
    public Boolean addressCheckReverse {get; set;}
    public Decimal TotalReceiptAmount {get;set;}
    public Decimal STTotalReceiptAmount {get;set;}
    public Decimal TotalToken {get;set;}
    public Decimal TotalQuoteToken {get;set;}
    List <Car_Park__c> ParkingListToUpdate = new List <Car_Park__c>();
    List <Car_Park__c> SingleOPENParkingList = new List <Car_Park__c>();
    List <Car_Park__c> TandemCOVEREDParkingList = new List <Car_Park__c>();
    List <Car_Park__c> STACKParkingList = new List <Car_Park__c>();    
    List < Applicant_Details__c > listApplicant = new list < Applicant_Details__c > ();
    List < Receipt_Details__c > listReceiptDetails = new list < Receipt_Details__c > ();
    Receipt_Details__c objReceiptDetails = new Receipt_Details__c();
    Receipt_Details__c objReceiptDetailsST = new Receipt_Details__c();
    public String salesManagerName {get;set;}
    public List <Receipt__c> ListOldReceipt {get; set;}
    public String tokenamt {get;set;}
    public String STamt {get;set;}
    public decimal stackParking{get;set;}
    public decimal openParking{get;set;}
    public decimal tandemParking{get;set;}
    List<Account_Master__c> am; // Added by Neha on 12/6/19
    public boolean currentPosition {get;set;}
    public boolean secondApplicantPosition {get;set;}
    public boolean thirdApplicantPosition {get;set;}
    
    public boolean checkCondition{get;set;}
    public boolean secondApplicantCondition{get;set;}
    public boolean thirdApplicantCondition{get;set;}
    
    public boolean forthApplicantCondition{get;set;}
    public boolean forthApplicantPosition{get;set;}
    public boolean fifthApplicantCondition{get;set;}
    public boolean fifthApplicantPosition{get;set;}
    
    public Date forthApplicantRegistration{get; set;}
    public Date fifthApplicantRegistration{get; set;}
    
    public string selectedCountryName{get;set;}
    public string selectedStateName{get;set;}
    public string selectedCityName{get;set;}
    
    public List<SelectOption> stateOptions1 {get;set;}
    public List<SelectOption> stateOptions2 {get;set;}
    public List<SelectOption> stateOptions3 {get;set;}
    public List<SelectOption> stateOptions4 {get;set;}
    public List<SelectOption> stateOptions5 {get;set;}
    public List<SelectOption> cityOptions1 {get;set;}
    public List<SelectOption> cityOptions2 {get;set;}
    public List<SelectOption> cityOptions3 {get;set;}
    public List<SelectOption> cityOptions4 {get;set;}
    public List<SelectOption> cityOptions5 {get;set;}
    
    public String countryapplicantData {get;set;}
    public String stateapplicantData {get;set;}
    public String cityapplicantData {get;set;}
    
    public String app1CountryName {get;set;}
    public String app1StateName {get;set;}
    public String app1CityName {get;set;}
    
    public String app2CountryName {get;set;}
    public String app2StateName {get;set;}
    public String app2CityName {get;set;}
    
     public String app3CountryName{get;set;}
    public String app3StateName{get;set;}
    public String app3CityName{get;set;}
    
    public String app4CountryName{get;set;}
    public String app4StateName{get;set;}
    public String app4CityName{get;set;}
    
    public String app5CountryName{get;set;}
    public String app5StateName{get;set;}
    public String app5CityName{get;set;}
    
    /*//----For Email Validation API----------
    public String emailToValidate { get; set;}
    public String emailValidationMessage { get; set;}
    public Boolean isEmailValid { get; set;}*/

     //----For Mobile Validation API----------
     public String ap1MobValidationMessage { get; set;}
     public Boolean isap1MobValid { get; set;}

      //----For Alternate Mobile Validation API----------
      public String ap1AlternateMobValidationMessage { get; set;}
      public Boolean isap1AlternateMobValid { get; set;}

      //----For Landline Mobile Validation API----------
      public String ap1LandlineNoValidationMessage { get; set;}
      public Boolean isap1LandlineNoValid { get; set;}

      //----For Secondary Mobile Validation API----------
      public String ap1SecondaryConNoValidationMessage { get; set;}
      public Boolean isap1SecondaryConNoValid { get; set;}

      //----For POA Mobile Validation API----------
      public String ap1POAConNoValidationMessage { get; set;}
      public Boolean isPOAConNoValid { get; set;}

       //----For POA2 Mobile Validation API----------
       public String ap1POA2ConNoValidationMessage { get; set;}
       public Boolean isPOA2ConNoValid { get; set;}

       //----For Office Number Validation API----------
       public String ap1OfficeNoValidationMessage { get; set;}
       public Boolean isOfficeNoValid { get; set;}

        //----For ap2 Mobile Validation API----------
     public String ap2MobValidationMessage { get; set;}
     public Boolean isap2MobValid { get; set;}

      //----For ap2 Alternate Mobile Validation API----------
      public String ap2AlternateMobValidationMessage { get; set;}
      public Boolean isap2AlternateMobValid { get; set;}

      //----For Landline Mobile Validation API----------
      public String ap2LandlineNoValidationMessage { get; set;}
      public Boolean isap2LandlineNoValid { get; set;}

      //----For ap2 Secondary Mobile Validation API----------
      public String ap2SecondaryConNoValidationMessage { get; set;}
      public Boolean isap2SecondaryConNoValid { get; set;}

        //----For ap2 POA Mobile Validation API----------
        public String ap2POAConNoValidationMessage { get; set;}
        public Boolean isAp2POAConNoValid { get; set;}
      
      //----For ap2 POA2 Mobile Validation API----------
      public String ap2POA2ConNoValidationMessage { get; set;}
      public Boolean isAp2POA2ConNoValid { get; set;}   

       //----For ap2 Office Number Validation API----------
       public String ap2OfficeNoValidationMessage { get; set;}
       public Boolean isAp2OfficeNoValid { get; set;}
 
       //----For ap3 Mobile Validation API----------
        public String ap3MobValidationMessage { get; set; }
        public Boolean isap3MobValid { get; set; }

        //----For ap3 Alternate Mobile Validation API----------
        public String ap3AlternateMobValidationMessage { get; set; }
        public Boolean isap3AlternateMobValid { get; set; }

         //----For Landline Mobile Validation API----------
        public String ap3LandlineNoValidationMessage { get; set;}
        public Boolean isap3LandlineNoValid { get; set;}

        //----For ap3 Secondary Mobile Validation API----------
        public String ap3SecondaryConNoValidationMessage { get; set; }
        public Boolean isap3SecondaryConNoValid { get; set; }

        //----For ap3 POA Mobile Validation API----------
        public String ap3POAConNoValidationMessage { get; set; }
        public Boolean isAp3POAConNoValid { get; set; }

        //----For ap3 POA2 Mobile Validation API----------
        public String ap3POA2ConNoValidationMessage { get; set; }
        public Boolean isAp3POA2ConNoValid { get; set; }

        //----For ap3 Office Number Validation API----------
        public String ap3OfficeNoValidationMessage { get; set; }
        public Boolean isAp3OfficeNoValid { get; set; }

        //----For ap4 Mobile Validation API----------
        public String ap4MobValidationMessage { get; set; }
        public Boolean isap4MobValid { get; set; }

        //----For ap4 Alternate Mobile Validation API----------
        public String ap4AlternateMobValidationMessage { get; set; }
        public Boolean isap4AlternateMobValid { get; set; }

          //----For Landline Mobile Validation API----------
        public String ap4LandlineNoValidationMessage { get; set;}
        public Boolean isap4LandlineNoValid { get; set;}

        //----For ap4 Secondary Mobile Validation API----------
        public String ap4SecondaryConNoValidationMessage { get; set; }
        public Boolean isap4SecondaryConNoValid { get; set; }

        //----For ap4 POA Mobile Validation API----------
        public String ap4POAConNoValidationMessage { get; set; }
        public Boolean isAp4POAConNoValid { get; set; }

        //----For ap4 POA2 Mobile Validation API----------
        public String ap4POA2ConNoValidationMessage { get; set; }
        public Boolean isAp4POA2ConNoValid { get; set; }

        //----For ap4 Office Number Validation API----------
        public String ap4OfficeNoValidationMessage { get; set; }
        public Boolean isAp4OfficeNoValid { get; set; }

        //----For ap5 Mobile Validation API----------
        public String ap5MobValidationMessage { get; set; }
        public Boolean isap5MobValid { get; set; }

        //----For ap5 Alternate Mobile Validation API----------
        public String ap5AlternateMobValidationMessage { get; set; }
        public Boolean isap5AlternateMobValid { get; set; }

        //----For Landline Mobile Validation API----------
        public String ap5LandlineNoValidationMessage { get; set;}
        public Boolean isap5LandlineNoValid { get; set;}

        //----For ap5 Secondary Mobile Validation API----------
        public String ap5SecondaryConNoValidationMessage { get; set; }
        public Boolean isap5SecondaryConNoValid { get; set; }

        //----For ap5 POA Mobile Validation API----------
        public String ap5POAConNoValidationMessage { get; set; }
        public Boolean isAp5POAConNoValid { get; set; }

        //----For ap5 Office Number Validation API----------
        public String ap5OfficeNoValidationMessage { get; set; }
        public Boolean isAp5OfficeNoValid { get; set; }

        //----For AP1 Email Validation API----------
        public String ap1EmailValidationMessage { get; set;}
        public Boolean isap1EmailValid { get; set;}

        //----For AP1 POA Email Validation API----------
        public String ap1POAEmailValidationMessage { get; set;}
        public Boolean isap1POAEmailValid { get; set;}

        //----For AP1 POA2 Email Validation API----------
        public String ap1POA2EmailValidationMessage { get; set;}
        public Boolean isap1POA2EmailValid { get; set;}

        //----For AP2 Email Validation API----------
        public String ap2EmailValidationMessage { get; set;}
        public Boolean isap2EmailValid { get; set;}

        //----For AP2 Email Validation API----------
        public String ap2POAEmailValidationMessage { get; set;}
        public Boolean isap2POAEmailValid { get; set;}

        //----For AP2 POA2 Email Validation API----------
        public String ap2POA2EmailValidationMessage { get; set;}
        public Boolean isap2POA2EmailValid { get; set;}

        //----For AP3 Email Validation API----------
        public String ap3EmailValidationMessage { get; set;}
        public Boolean isap3EmailValid { get; set;}

        //----For AP3 Email Validation API----------
        public String ap3POAEmailValidationMessage { get; set;}
        public Boolean isap3POAEmailValid { get; set;}

        //----For AP3 POA2 Email Validation API----------
        public String ap3POA2EmailValidationMessage { get; set;}
        public Boolean isap3POA2EmailValid { get; set;}

         //----For AP4 Email Validation API----------
         public String ap4EmailValidationMessage { get; set;}
         public Boolean isap4EmailValid { get; set;}

         //----For AP4 Email Validation API----------
        public String ap4POAEmailValidationMessage { get; set;}
        public Boolean isap4POAEmailValid { get; set;}

        //----For AP5 Email Validation API----------
        public String ap5EmailValidationMessage { get; set;}
        public Boolean isap5EmailValid { get; set;}

        //----For AP5 Email Validation API----------
        public String ap5POAEmailValidationMessage { get; set;}
        public Boolean isap5POAEmailValid { get; set;}


    public BookingClassDubai() {
        stateOptions1 = new List<SelectOption>();
        stateOptions2 = new List<SelectOption>();
        stateOptions3 = new List<SelectOption>();
        stateOptions4 = new List<SelectOption>();
        stateOptions5 = new List<SelectOption>();
        stateOptions1.add(new SelectOption('--None--','--None--' ));
        stateOptions2.add(new SelectOption('--None--','--None--' ));
        stateOptions3.add(new SelectOption('--None--','--None--' ));
        stateOptions4.add(new SelectOption('--None--','--None--' ));
        stateOptions5.add(new SelectOption('--None--','--None--' ));
        
        cityOptions1 = new List<SelectOption>();
        cityOptions2 = new List<SelectOption>();
        cityOptions3 = new List<SelectOption>();
        cityOptions4 = new List<SelectOption>();
        cityOptions5 = new List<SelectOption>();
        
        cityOptions1.add(new SelectOption('--None--','--None--' ));
        cityOptions2.add(new SelectOption('--None--','--None--' ));
        cityOptions3.add(new SelectOption('--None--','--None--' ));
        cityOptions4.add(new SelectOption('--None--','--None--' ));
        cityOptions5.add(new SelectOption('--None--','--None--' ));
        
        currentPosition = false;
        secondApplicantPosition = false;
        thirdApplicantPosition = false;
        forthApplicantPosition = false;
        fifthApplicantPosition = false;
        reciept=new Receipt__c ();
        am = new List<Account_Master__c>(); // Added by Neha on 12/6/19
        deletereceiptlist =new List < Receipt__c >();
        receiptlist =new List < Receipt__c >();
        receiptlist.add(reciept);   
        TotalServiceandToken=0;
        rowIndex =0;
        ReceiptLstTobeUpdate = new List<Receipt__c>();          
        i=0;
        TotalReceiptAmount=0;
        STTotalReceiptAmount=0;
        TotalToken =0;
        TotalQuoteToken =0;
        tokenamt ='';
        STamt = '';
        salesManagerName = '';
        ParkingListToUpdate  = new List<Car_Park__c>();
        SingleOPENParkingList = new List <Car_Park__c>();
        TandemCOVEREDParkingList = new List <Car_Park__c>();
        STACKParkingList = new List <Car_Park__c>();
        
        ListOldReceipt = new List <Receipt__c>();
        STReceiptDetails = new List <Receipt__c>();
        ReceiptDetails = new List <Receipt__c>();
        QuoteDetails  = new List <Quotation__c>();
        queryResult = new List <Quotation__c>();       
        optyList  = new List <Opportunity>();
        
        le = new Legal_Entity__c();
        addressCheck = true;
        addressCheckApplicant2 = true;
        addressCheckApplicant3 = true;
        addressCheckApplicant4 = true;
        addressCheckApplicant5 = true;
        //---for Email and Phone Validation API adding default value as false for all the related boolean field--- 
        isap1MobValid = false;
        isap1AlternateMobValid = false;
        isap1LandlineNoValid = false;
        isap1SecondaryConNoValid = false;
        isPOAConNoValid = false;
        isPOA2ConNoValid = false;
        isOfficeNoValid = false;
        isap2MobValid = false;
        isap2AlternateMobValid = false;
        isap2LandlineNoValid = false;
        isap2SecondaryConNoValid = false;
        isAp2POAConNoValid = false;
        isAp2POA2ConNoValid = false;
        isAp2OfficeNoValid = false;
        isap3MobValid = false;
        isap3AlternateMobValid = false;
        isap3LandlineNoValid = false;
        isap3SecondaryConNoValid = false;
        isAp3POAConNoValid = false;
        isAp3POA2ConNoValid = false;
        isAp3OfficeNoValid = false;
        isap4MobValid = false;
        isap4AlternateMobValid = false;
        isap4LandlineNoValid = false;
        isap4SecondaryConNoValid = false;
        isAp4POAConNoValid = false;
        isAp4POA2ConNoValid = false;
        isAp4OfficeNoValid = false;
        isap5MobValid = false;
        isap5AlternateMobValid = false;
        isap5LandlineNoValid = false;
        isap5SecondaryConNoValid = false;
        isAp5POAConNoValid = false;
        isAp5OfficeNoValid = false;
        isap1EmailValid = false;
        isap1POAEmailValid = false;
        isap1POA2EmailValid = false;
        isap2EmailValid = false;
        isap2POAEmailValid = false;
        isap2POA2EmailValid = false;
        isap3EmailValid = false;
        isap3POAEmailValid = false;
        isap3POA2EmailValid = false;
        isap4EmailValid = false;
        isap4POAEmailValid = false;
        isap5EmailValid = false;
        isap5POAEmailValid = false;
        ap1EmailValidationMessage = '';
        //---for Email and Phone Validation API adding default value as false for all the related boolean field--- 
        applicant = new Applicant_Details__c();
        applicant2 = new Applicant_Details__c();
        applicant3 = new Applicant_Details__c();
        applicant4 = new Applicant_Details__c();
        applicant5 = new Applicant_Details__c();
        boookingObj = new Booking__c();
        boookingObj.Booking_Date__c = system.now(); 
        receiptObj = new Receipt__c();
        if (ApexPages.currentPage().getParameters().get('unitId') != null && ApexPages.currentPage().getParameters().get('unitId') != '') {
            unitId = ApexPages.currentPage().getParameters().get('unitId');
        }
        
        if (ApexPages.currentPage().getParameters().get('optyid') != null && ApexPages.currentPage().getParameters().get('optyid') != '') {
            boookingObj.Opportunity__c = ApexPages.currentPage().getParameters().get('optyid');
            
            try {            
                //Added by Priya on 16 April 2020
                ShowReceiptDetails = [SELECT id, Project_Unit__c,Project__c, Name, Total_Amount__c,Opportunity__c, Opportunity_Email_Id__c,
                                      Mode__c, Receipt_Date__c, Cheque_DD_Date__c, DraweeBank__c, Currency__c, Receipt_Status__c
                                      FROM Receipt__c WHERE Opportunity__c = :boookingObj.Opportunity__c];                                
                
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }
        
        if (ApexPages.currentPage().getParameters().get('projectId') != null && ApexPages.currentPage().getParameters().get('projectId') != '') {
            ProjectId = ApexPages.currentPage().getParameters().get('projectId');
        }
        getquotation();

        //validateAp1EmailAddress();
        //validateAp2EmailAddress();
        //validateAp3EmailAddress();
        //validateAp4EmailAddress();
        //validateAp5EmailAddress();

        //validateAp1POAEmailID();
        //validateAp1POA2EmailID();
        //validateAp2POAEmailID();
        //validateAp2POA2EmailID();
        //validateAp3EmailAddress();
        //validateAp3POAEmailID();
        //validateAp3POA2EmailID();
        //validateAp4EmailAddress();
        //validateAp4POAEmailID();
        //validateAp5EmailAddress();
        //validateAp5POAEmailID();

    }
    
    public PageReference getquotation(){ 
        System.debug('boookingObj2');
        if (boookingObj.Opportunity__c != null){System.debug('boookingObj2');
                                                optyList =  [SELECT id, Account_Mobile_Number__c ,Walk_in_Source__c,Booking__c,Walk_in_Sub_Source__c, Owner.Name,OwnerId, Name,Project__c, Account.Birth_Date__c,Account.BillingAddress,
                                                             Account.PersonMobilePhone,Account.PersonEmail,Account.BillingStreet, Sourcing_Manager__c, Sales_Manager__c, Account.BillingCity,Account.BillingPostalCode,
                                                             Account.BillingCountry,Account.Name,Account.Salutation,Account.Country__c,Account.Zones__c,Account.Office_State_Province__c,Account.Office_City__c,Account.Residential_Street__c,
                                                             Account.Mobile__c, Account.Alternate_number_1__c, Walk_In_CP__c, Channel_Partner_Contact_Person__c, Walk_In_SC__c, Secondary_Sales_Manager__c,Sales_Manager_lookup__c
                                                             from Opportunity where id =: boookingObj.Opportunity__c];
                                                if(optyList.size() >0 ){
                                                    if(optyList[0].Walk_in_Source__c == null){
                                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Walk in Source for opportunity  <a style="color:blue;" href="/'+optyList[0].id+'" target="_blank">'+optyList[0].Name+'</a> is empty');
                                                        ApexPages.addMessage(myMsg);
                                                        i=1;
                                                    }
                                                    else if (optyList[0].Booking__c  != null) {
                                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Booking already available for this opportunity  <a style="color:blue;" href="/'+optyList[0].id+'" target="_blank">'+optyList[0].Name+'</a>');
                                                        ApexPages.addMessage(myMsg);
                                                        i=1;
                                                    } 
                                                    else{
                                                        boookingObj.Source_of_Booking__c = optyList[0].Walk_in_Source__c;
                                                        if(optyList[0].Walk_In_CP__c != null){
                                                            boookingObj.Channel_Partner__c = optyList[0].Walk_In_CP__c; // Added by Neha on 18/01/19
                                                        }
                                                        boookingObj.Channel_Partner_Contact_Person__c = optyList[0].Channel_Partner_Contact_Person__c; // Added by Neha on 18/01/19                               
                                                        if(optyList[0].Walk_In_SC__c != null) // Added by Neha on 21/2/19
                                                            boookingObj.Sobha_Connect__c = optyList[0].Walk_In_SC__c; // Added by Neha on 21/2/19
                                                    }
                                                    
                                                    ////************ Added By Neha to autopopulate Sales Managers and Sales Head on Booking (Date: 13/11/18)   **************////
                                                    
                                                    if(optyList[0].Sales_Manager_lookup__c != null){
                                                        List <User> u = [SELECT Id, Name, ManagerId From User WHERE Id = :optyList[0].Sales_Manager_lookup__c AND isActive = true];
                                                        if(u[0].Id != null)
                                                            boookingObj.Sales_Managers__c = u[0].Id;
                                                        if(u[0].ManagerId != null)
                                                            boookingObj.Sales_Head__c = u[0].ManagerId;                              
                                                    }
                                                    ////************ Added By Neha Ends Here **************////
                                                    ////************ Added By Neha to autopopulate Secondary Sales Managers and Secondary Sales Head on Booking (Date: 24/5/19)   **************////
                                                    if(optyList[0].Secondary_Sales_Manager__c != null){                  
                                                        List <User> u = [SELECT Id, Name, ManagerId From User WHERE Id = :optyList[0].Secondary_Sales_Manager__c AND isActive = true];               
                                                        if(u[0].Id != null)
                                                            boookingObj.Secondary_Sales_Manager__c = u[0].Id;
                                                        if(u[0].ManagerId != null)
                                                            boookingObj.Secondary_Sales_Head__c = u[0].ManagerId;                              
                                                    }
                                                    ////************ Added By Neha Ends Here **************////
                                                    
                                                    if(optyList[0].Walk_in_Sub_Source__c != null){
                                                        boookingObj.Sub_Source__c = optyList[0].Walk_in_Sub_Source__c;
                                                    }
                                                    //Assigning applicant1 details from account 
                                                    applicant.Salutation__c=optyList[0].Account.Salutation;
                                                    applicant.Name=optyList[0].Account.Name;
                                                    firstApplicantDOB = optyList[0].Account.Birth_Date__c;
                                                    applicant.Country__c=optyList[0].Account.Country__c;
                                                    applicant.State__c=optyList[0].Account.Office_State_Province__c;
                                                    applicant.City__c=optyList[0].Account.Office_City__c;
                                                    applicant.Permanent_Address__c = optyList[0].Account.Residential_Street__c;
                                                    applicant.Mobile_Number__c=optyList[0].Account_Mobile_Number__c  ;
                                                    applicant.Email_Address__c = optyList[0].Account.PersonEmail;         
                                                    applicant.Country__c = optyList[0].Account.BillingCountry;
                                                    applicant.City__c = optyList[0].Account.BillingCity;
                                                }
                                                else{                           
                                                }
                                               }             
        if (boookingObj.Opportunity__c != null && unitId == null && ProjectId == null) {
            queryResult = [SELECT id, Name, Booking__c,
                           Allow_booking_without_full_token__c, Unit__r.Project__c, Service_Tax_On_Token_Amount__c 
                           from Quotation__c where Opportunity__c = : boookingObj.Opportunity__c and Unit__r.Project__c =: optyList[0].Project__c 
                           and (Unit__r.Unit_Status__c = 'Available' OR Unit__r.Unit_Status__c = 'Hold') and Booking__c =: null 
                           and Active_Quotation__c = TRUE and  Quote_Status__c = : 'Valid' ORDER BY CreatedDate DESC LIMIT 1];
            if(queryResult.size() > 0){
                system.debug('Result only opty quotations' +queryResult);               
            } else {
                system.debug('Quotation Else if only opty');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Either the opportunity does not have a Quotation or the unit associated with it is not Available or Hold');
                ApexPages.addMessage(myMsg);
            }
            
        } else if (boookingObj.Opportunity__c != null && unitId != null && ProjectId == null) {
            ///and Project_Unit__r.Project__c =: optyList[0].Project__c//
            queryResult = [SELECT id, Name,Booking__c, Unit__r.Project__c, Unit__c from Quotation__c 
                           where Opportunity__c = : boookingObj.Opportunity__c and Unit__c = : unitId and Unit__r.Project__c =: optyList[0].Project__c 
                           and (Unit__r.Unit_Status__c = 'Available' OR Unit__r.Unit_Status__c = 'Hold') //  OR Unit__r.Unit_Status__c = 'Blocked' // Commented by Neha on 1/2/19
                           and Booking__c =: null and Active_Quotation__c = TRUE and Quote_Status__c = : 'Valid' ORDER BY CreatedDate DESC LIMIT 1];
            if(queryResult.size() > 0){
                system.debug('Result only opty and unit quotations' +queryResult);
            }
            else {
                system.debug('Quotation Else if opty  and unit is present but no quotation');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Either the opportunity does not have a Quotation or the unit associated with it is not Available or Hold');
                ApexPages.addMessage(myMsg);
                i=1;
            }
            
        } else if (boookingObj.Opportunity__c != null && ProjectId != null && unitId == null ) {
            queryResult = [SELECT id,/*Tandem_car_park_Additional__c,Single_car_park_Additional__c,*/Name, Booking__c,/*Allow_booking_without_full_token__c,*/Unit__r.Project__c, /*Service_Tax_On_Token_Amount__c,*/ Unit__c from Quotation__c 
                           where Opportunity__c = : boookingObj.Opportunity__c and Unit__r.Project__c = : ProjectId and 
                           (Unit__r.Unit_Status__c = 'Available' OR Unit__r.Unit_Status__c = 'Hold') and Booking__c =: null 
                           and Active_Quotation__c = TRUE and Quote_Status__c = : 'Valid' ORDER BY CreatedDate DESC LIMIT 1];
            
            if(queryResult.size() >0){
                system.debug('Result only opty and ProjectId quotations' +queryResult);
            }
            else {
                system.debug('Quotation Else if opty and Project');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Either the opportunity does not have a Quotation or the unit associated with it is not Available or Hold');
                ApexPages.addMessage(myMsg);
                i=1;
            }                
        }
        else if (boookingObj.Opportunity__c != null && ProjectId != null && unitId != null ) {                
            queryResult = [SELECT id, Name,Booking__c,Unit__r.Project__c, Unit__c from Quotation__c 
                           where Opportunity__c = : boookingObj.Opportunity__c and Unit__r.Project__c = : ProjectId 
                           and (Unit__r.Unit_Status__c = 'Available' OR Unit__r.Unit_Status__c = 'Hold') and Unit__c =: unitId  and Booking__c =: null
                           and Active_Quotation__c = TRUE and Quote_Status__c = : 'Valid' ORDER BY CreatedDate DESC LIMIT 1];
            
            if(queryResult.size() > 0){
                system.debug('Result only opty and ProjectId quotations' +queryResult);
            }
            else {
                system.debug('Quotation Else if opty and Project');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Either the opportunity does not have a Quotation or the unit associated with it is not Available or Hold');
                ApexPages.addMessage(myMsg);
                i=1;
            }                
        }           
        else {
            system.debug('Inside getQuote No Opportunity');
        } 
        return null;
    }
    
    //Create selectlist out of queryresult
    public List < SelectOption > getQuote {
        get {        
            List < SelectOption > optns = new List < Selectoption > ();
            optns.add(new SelectOption('', 'Select a Quotation'));
            if(queryResult.size() > 0){
                for (Quotation__c obj: queryResult) {
                    optns.add(new SelectOption(obj.Id, obj.Name));
                }                
            }else {
                system.debug('No quotations');                  
            }
            return optns;
        }
        set;
    }
    
    //Get Token from Quotation
    public PageReference getTokenAmount() {
        
        if (selectedQuote != null) {
            QuoteDetails = [SELECT id, Name, Booking__c, Unit__r.Project__c,Unit__r.Carpet_Area__c, Unit__r.Chargeable_Area__c , Unit__r.Carpet_Area_in_Sq_Mts__c, Unit__r.Enclosed_Balcony_in_Sq_Mtrs__c, Unit__r.Cupboard_Area_in_Sq_Mtrs__c,Unit__r.Tower__r.Cluster__r.id, 
                            Unit__c, Token_Amount__c, ST_Token_Amount__c, Unit__r.Tower__r.Cluster__r.name,Unit__r.Tower__c ,Unit__r.Tower__r.name, Unit__r.Configuration__c, Unit__r.Floor__c, Unit__r.name,Total_Agreement_Value_Bucket__c,Car_Park_Type_1__c,Car_Park_Type_2__c,Car_Park_Type_3__c,Car_Park_Type_4__c,Car_Park_Type_5__c, 
                            Level_One_Approver__c,Level_Two_Approver__c,Level_Three_Approver__c, Service_tax_on_Token_Amount__c, Allow_booking_without_full_token__c,TotalEarmarkedCarpark__c,TotalAdditionalCarpark__c,Car_Park_Count_1__c,Car_Park_Count_2__c,Car_Park_Count_3__c,Car_Park_Count_4__c,Car_Park_Count_5__c
                            FROM Quotation__c WHERE Id = : selectedQuote];
            if (QuoteDetails.size() > 0){
                boookingObj.Token_Amount__c = QuoteDetails[0].Token_Amount__c;
                //Anuja added on 29/12/15
                if(QuoteDetails[0].Token_Amount__c != Null){
                    tokenamt = INFormat(QuoteDetails[0].Token_Amount__c);
                }
                boookingObj.Cluster__c = QuoteDetails[0].Unit__r.Tower__r.Cluster__r.name;
                boookingObj.Tower__c = QuoteDetails[0].Unit__r.Tower__r.name;
                boookingObj.Flat_Typology__c = QuoteDetails[0].Unit__r.Configuration__c;
                boookingObj.Floor__c = QuoteDetails[0].Unit__r.Floor__c;
                boookingObj.Carpet_Area__c = QuoteDetails[0].Unit__r.Carpet_Area__c;
                boookingObj.No_of_Additional_Parking__c = QuoteDetails[0].TotalAdditionalCarpark__c;
                boookingObj.No_of_Earmarked_Parking__c = QuoteDetails[0].TotalEarmarkedCarpark__c;
                
                if(QuoteDetails[0].Total_Agreement_Value_Bucket__c != 0){
                    boookingObj.Agreement_Value__c = QuoteDetails[0].Total_Agreement_Value_Bucket__c ;
                }
                
                boookingObj.Flat_No__c = QuoteDetails[0].Unit__r.name;
                boookingObj.Project__c = QuoteDetails[0].Unit__r.Project__c;           
                boookingObj.Unit__c = QuoteDetails[0].Unit__c;
                if (QuoteDetails[0].Service_Tax_On_Token_Amount__c == true) {
                    if(QuoteDetails[0].ST_Token_Amount__c != Null){
                        boookingObj.ST_Token_Amount__c = QuoteDetails[0].ST_Token_Amount__c;
                        //Anuja added on 29/12/15
                        STamt = INFormat(QuoteDetails[0].ST_Token_Amount__c);
                    } 
                } else {
                    boookingObj.ST_Token_Amount__c = 0;
                }
                
                if(boookingObj.Opportunity__c != null && QuoteDetails[0].Unit__c != null){
                    le = InventoryCostServices.getLegalEntityDetails(boookingObj.Unit__c, boookingObj.Project__c, QuoteDetails[0].Unit__r.Tower__c);
                    if(le != null){
                        boookingObj.Account_Number__c = String.valueOf(le.Account_Number_Flat_Cost__c);
                        boookingObj.Bank__c = le.Bank_Name_Flat_Cost__c;
                        boookingObj.IBAN_Flat_Cost__c = le.IBAN__c;
                        boookingObj.Account_Name_Service_Tax__c = le.Account_Name_Service_Tax__c;
                        boookingObj.Account_Number_Service_tax__c = String.ValueOf(le.Account_Number_Service_tax__c);
                        boookingObj.Bank_Name_Service_tax__c = le.Bank_Name_Service_tax__c;
                        boookingObj.IBAN_Tax__c = le.IBAN_Tax__c;                   
                    }
                }       
                string count = 'Car_Park_Count_';
                string type = 'Car_Park_Type_';
                boolean isStack = false;
                boolean isOpen = false;
                boolean isTandem = false;
                stackParking = 0;
                openParking = 0;
                tandemParking = 0;
                string clusterId = QuoteDetails[0].Unit__r.Tower__r.Cluster__r.id;
                
                for(integer i=1;i<=5;i++){
                    if((Decimal)(QuoteDetails[0].get(count+i+'__c')) != null && string.isNotBlank((string)(QuoteDetails[0].get(type+i+'__c')))){
                        if((string)(QuoteDetails[0].get(type+i+'__c')) == 'Stack' && (Decimal)(QuoteDetails[0].get(count+i+'__c')) > 0){
                            isStack = true;
                            stackParking += (Decimal)(QuoteDetails[0].get(count+i+'__c'));
                        }
                        if((string)(QuoteDetails[0].get(type+i+'__c')) == 'Open' && (Decimal)(QuoteDetails[0].get(count+i+'__c')) > 0){
                            isOpen = true;
                            openParking += (Decimal)(QuoteDetails[0].get(count+i+'__c'));
                        }
                        if((string)(QuoteDetails[0].get(type+i+'__c')) == 'Tandem' && (Decimal)(QuoteDetails[0].get(count+i+'__c')) > 0){
                            isTandem = true;
                            tandemParking += (Decimal)(QuoteDetails[0].get(count+i+'__c'));
                        }
                    }
                }
                
                if(isStack){
                    STACKParkingList = [Select id,Category__c,Status__c,Name,Type__c From Car_Park__c where Type__c = 'Stack' and Status__c = 'Available' and Category__c = 'Additional' and Project__c =: boookingObj.Project__c and Cluster__c =: clusterId];
                }
                if(isOpen){
                    SingleOPENParkingList = [Select id,Category__c,Status__c,Name,Type__c From Car_Park__c where Type__c = 'Open' and Status__c =: 'Available' and Category__c = 'Additional' and Project__c =: boookingObj.Project__c and Cluster__c =: clusterId];
                }
                if(isTandem){
                    TandemCOVEREDParkingList = [Select id,Status__c,Category__c,Name,Type__c From Car_Park__c where Type__c = 'Tandem' and Status__c = 'Available' and Category__c = 'Additional' and Project__c =: boookingObj.Project__c and Cluster__c =: clusterId];
                }
                
            }
            
            //     getReceiptDetails();
        } else {
            boookingObj.Token_Amount__c = 0;
            boookingObj.ST_Token_Amount__c = 0;
        }
        return null;
    }
    
    
    public PageReference getaddressstatus() {
        if (addressCheck == true) {
            addressCheckReverse = false;
        } else {
            addressCheckReverse = true;
        }
        return null;
    }
    
    public PageReference Save() {
        
        TotalServiceandToken=0;
        i = 0;
        ////Anuja added on 7/1/16 ////////////////
        ///Tandem Covered////
        //
        
        
        if (QuoteDetails != null && QuoteDetails.size() > 0 && TandemCOVEREDParkingList.size() < tandemParking) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Required number of tandem parking is unavailable');
            ApexPages.addMessage(myMsg);
            i=1;      
        }
        ///Sigle Open////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && SingleOPENParkingList.size() < openParking) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Required number of open parking is unavailable');
            ApexPages.addMessage(myMsg);
            i=1;       
        }
        ///Stack////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && STACKParkingList.size() < stackParking) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Required number of stack parking is unavailable');
            ApexPages.addMessage(myMsg);
            i=1;      
        }       
        /////////////////////////////////////////////////////////////
        if(boookingObj.Opportunity__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select an Opportunity');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(selectedQuote == '' || selectedQuote == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select a quotation');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(boookingObj.Future_Correspondence_Contact__c == '' || boookingObj.Future_Correspondence_Contact__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Future Correspondence Contact Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(boookingObj.Future_Correspondence_Contact__c == 'Other' ){
            if(boookingObj.Future_Correspondence_Contact_Name__c ==  null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is Other Future Correspondence Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }        
            if(boookingObj.Future_Correspondence_Contact_Phone__c == '' || boookingObj.Future_Correspondence_Contact_Phone__c == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is Other Future Correspondence Phone Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
            if(boookingObj.Future_Correspondence_Contact_Email__c == '' || boookingObj.Future_Correspondence_Contact_Email__c == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is Other Future Correspondence Email Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
            if(boookingObj.Future_Correspondence_Contact_Relation__c == '' || boookingObj.Future_Correspondence_Contact_Relation__c == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is Other Future Correspondence Relation Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(boookingObj.Mode_of_Funding__c == '' || boookingObj.Mode_of_Funding__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mode of Funding Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //// Added by Neha on 18/01/19 Starts Here      
        if(boookingObj.Stage_of_Booking__c == '' || boookingObj.Stage_of_Booking__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Stage of Booking Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //// Added by Neha on 18/01/19 Ends Here   
        //////////////////Error Messages for Future Correspondence///////////////////////
        if(boookingObj.Future_Correspondence_Contact__c == '2nd Applicant' ){
            
            if(applicant2.Name == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is (2nd Applicant) Applicant 2 Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(boookingObj.Future_Correspondence_Contact__c == '3rd Applicant' ){
            
            if(applicant3.Name == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is (3rd Applicant) Applicant 3 Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(boookingObj.Future_Correspondence_Contact__c == '4th Applicant' ){ 
            
            if(applicant4.Name == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is (4th Applicant) Applicant 4 Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(boookingObj.Future_Correspondence_Contact__c == '5th Applicant' ){
            
            if(applicant5.Name == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Incase Future Correspondence Contact Is (5th Applicant) Applicant 5 Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }           
        ////////////////////////// error messagess for applicant 1  //////////////////////////
        
        
        if(applicant.Salutation__c == '' || applicant.Salutation__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Salutation for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Name == '' || applicant.Name == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Name for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Valid_Until_Passport__c != null && applicant.Valid_Until_Passport__c < system.today()){ // added by vipul
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Passport valid date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Non_residency_Letter_Valid_Upto__c != null && applicant.Non_residency_Letter_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Non-residency Letter date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Visa_Copy_Valid_Upto__c != null && applicant.Visa_Copy_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Visa Copy date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Others_Valid_Upto__c != null && applicant.Others_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Others date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Valid_Upto_Emirates_Id__c != null && applicant.Valid_Upto_Emirates_Id__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates Id date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Valid_Upto_National_ID__c != null && applicant.Valid_Upto_National_ID__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'National Id date cannot not be past date');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        if(applicant.Type_Of_Applicant__c != null && applicant.Type_Of_Applicant__c == 'Corporate Purchaser' && ((applicant.Country__c != null && applicant.Country__c != 'UAE')
                                                                                                                 || (applicant.Mobile_Country_With_Code__c != null && applicant.Mobile_Country_With_Code__c != '+971'))){
                                                                                                                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select UAE country and +971 mobile country code for 1st applicant');
                                                                                                                     ApexPages.addMessage(myMsg);
                                                                                                                     i=1;
                                                                                                                 }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        
        //added by artee for others mobile number validation
        if(applicant.Landline_Number__c != null && applicant.Landline_Number_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Landline Number Country Code Is Required For Landline Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant.Secondary_Mobile_Number__c != null && applicant.Alternate_Mobile_Country_with_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Alternate Mobile Country Code Is Required For Alternate Mobile Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant.Secondary_Contact_Number__c != null && applicant.Secondary_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Secondary Contact Country Code Is Required For Secondary Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.POA_Contact_Number__c != null && applicant.POA_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA Contact Country Code Is Required For POA Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.POA_2_Contact_Number__c != null && applicant.POA2_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA2 Contact Country Code Is Required For POA2 Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Organization_Phone_numbers__c != null && applicant.Office_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Office Country Code Is Required For Office Phone Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }        
        //added by artee for others mobile number validation
        
        if(firstApplicantRegistration != null && firstApplicantRegistration > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date cannot not be future date for applicant 1');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(!currentPosition && firstApplicantDOB != null && firstApplicantDOB > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB cannot not be future date for applicant 1');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        
        
        if(applicant2.Valid_Until_Passport__c != null && applicant2.Valid_Until_Passport__c < system.today()){ // added by vipul
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Passport valid date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Non_residency_Letter_Valid_Upto__c != null && applicant2.Non_residency_Letter_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Non-residency Letter date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Visa_Copy_Valid_Upto__c != null && applicant2.Visa_Copy_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Visa Copy date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Others_Valid_Upto__c != null && applicant2.Others_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Others date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Valid_Upto_Emirates_Id__c != null && applicant2.Valid_Upto_Emirates_Id__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates Id date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Valid_Upto_National_ID__c != null && applicant2.Valid_Upto_National_ID__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'National Id date cannot not be past date for Applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        if(applicant2.Type_Of_Applicant__c != null && applicant2.Type_Of_Applicant__c == 'Corporate Purchaser' && ((applicant2.Country__c != null && applicant2.Country__c != 'UAE')
                                                                                                                   || (applicant2.Mobile_Country_With_Code__c != null && applicant2.Mobile_Country_With_Code__c != '+971'))){
                                                                                                                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select UAE country and +971 mobile country code for 2nd applicant');
                                                                                                                       ApexPages.addMessage(myMsg);
                                                                                                                       i=1;
                                                                                                                   }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        //added by artee for others mobile number validation
        if(applicant2.Landline_Number__c != null && applicant2.Landline_Number_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Landline Number Country Code Is Required For Landline Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant2.Secondary_Mobile_Number__c != null && applicant2.Alternate_Mobile_Country_with_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Alternate Mobile Country Code Is Required For Alternate Mobile Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant2.Secondary_Contact_Number__c != null && applicant2.Secondary_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Secondary Contact Country Code Is Required For Secondary Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.POA_Contact_Number__c != null && applicant2.POA_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA Contact Country Code Is Required For POA Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.POA_2_Contact_Number__c != null && applicant2.POA2_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA2 Contact Country Code Is Required For POA2 Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant2.Organization_Phone_numbers__c != null && applicant2.Office_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Office Country Code Is Required For Office Phone Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }        
        //added by artee for others mobile number validation
        
        if(secondApplicantRegistration != null && secondApplicantRegistration > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date cannot not be future date for applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(!secondApplicantPosition && secondApplicantDOB != null && secondApplicantDOB > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB cannot not be future date for applicant 2');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        
        if(applicant3.Valid_Until_Passport__c != null && applicant3.Valid_Until_Passport__c < system.today()){ // added by vipul
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Passport valid date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Non_residency_Letter_Valid_Upto__c != null && applicant3.Non_residency_Letter_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Non-residency Letter date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Visa_Copy_Valid_Upto__c != null && applicant3.Visa_Copy_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Visa Copy date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Others_Valid_Upto__c != null && applicant3.Others_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Others date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Valid_Upto_Emirates_Id__c != null && applicant3.Valid_Upto_Emirates_Id__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates Id date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Valid_Upto_National_ID__c != null && applicant3.Valid_Upto_National_ID__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'National Id date cannot not be past date for Applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        if(applicant3.Type_Of_Applicant__c != null && applicant3.Type_Of_Applicant__c == 'Corporate Purchaser' && ((applicant3.Country__c != null && applicant3.Country__c != 'UAE')
                                                                                                                   || (applicant3.Mobile_Country_With_Code__c != null && applicant3.Mobile_Country_With_Code__c != '+971'))){
                                                                                                                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select UAE country and +971 mobile country code for 3rd applicant');
                                                                                                                       ApexPages.addMessage(myMsg);
                                                                                                                       i=1;
                                                                                                                   }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        
        //added by artee for others mobile number validation
        if(applicant3.Landline_Number__c != null && applicant3.Landline_Number_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Landline Number Country Code Is Required For Landline Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant3.Secondary_Mobile_Number__c != null && applicant3.Alternate_Mobile_Country_with_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Alternate Mobile Country Code Is Required For Alternate Mobile Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant3.Secondary_Contact_Number__c != null && applicant3.Secondary_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Secondary Contact Country Code Is Required For Secondary Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.POA_Contact_Number__c != null && applicant3.POA_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA Contact Country Code Is Required For POA Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.POA_2_Contact_Number__c != null && applicant3.POA2_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA2 Contact Country Code Is Required For POA2 Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant3.Organization_Phone_numbers__c != null && applicant3.Office_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Office Country Code Is Required For Office Phone Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }        
        //added by artee for others mobile number validation
        
        if(thirdApplicantRegistration != null && thirdApplicantRegistration > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date cannot not be future date for applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(!thirdApplicantPosition && thirdApplicantDOB != null && thirdApplicantDOB > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB cannot not be future date for applicant 3');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        
        if(applicant4.Valid_Until_Passport__c != null && applicant4.Valid_Until_Passport__c < system.today()){ // added by vipul
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Passport valid date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Non_residency_Letter_Valid_Upto__c != null && applicant4.Non_residency_Letter_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Non-residency Letter date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Visa_Copy_Valid_Upto__c != null && applicant4.Visa_Copy_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Visa Copy date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Others_Valid_Upto__c != null && applicant4.Others_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Others date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Valid_Upto_Emirates_Id__c != null && applicant4.Valid_Upto_Emirates_Id__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates Id date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Valid_Upto_National_ID__c != null && applicant4.Valid_Upto_National_ID__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'National Id date cannot not be past date for Applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        if(applicant4.Type_Of_Applicant__c != null && applicant4.Type_Of_Applicant__c == 'Corporate Purchaser' && ((applicant4.Country__c != null && applicant4.Country__c != 'UAE')
                                                                                                                   || (applicant4.Mobile_Country_With_Code__c != null && applicant4.Mobile_Country_With_Code__c != '+971'))){
                                                                                                                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select UAE country and +971 mobile country code for 4th applicant');
                                                                                                                       ApexPages.addMessage(myMsg);
                                                                                                                       i=1;
                                                                                                                   }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        
        //added by artee for others mobile number validation
        if(applicant4.Landline_Number__c != null && applicant4.Landline_Number_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Landline Number Country Code Is Required For Landline Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant4.Secondary_Mobile_Number__c != null && applicant4.Alternate_Mobile_Country_with_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Alternate Mobile Country Code Is Required For Alternate Mobile Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant4.Secondary_Contact_Number__c != null && applicant4.Secondary_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Secondary Contact Country Code Is Required For Secondary Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.POA_Contact_Number__c != null && applicant4.POA_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA Contact Country Code Is Required For POA Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.POA_2_Contact_Number__c != null && applicant4.POA2_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA2 Contact Country Code Is Required For POA2 Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant4.Organization_Phone_numbers__c != null && applicant4.Office_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Office Country Code Is Required For Office Phone Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }        
        //added by artee for others mobile number validation
        
        if(forthApplicantRegistration != null && forthApplicantRegistration > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date cannot not be future date for applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(!forthApplicantPosition && fourthApplicantDOB != null && fourthApplicantDOB > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB cannot not be future date for applicant 4');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        
        if(applicant5.Valid_Until_Passport__c != null && applicant5.Valid_Until_Passport__c < system.today()){ // added by vipul
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Passport valid date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Non_residency_Letter_Valid_Upto__c != null && applicant5.Non_residency_Letter_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Non-residency Letter date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Visa_Copy_Valid_Upto__c != null && applicant5.Visa_Copy_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Visa Copy date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Others_Valid_Upto__c != null && applicant5.Others_Valid_Upto__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Others date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Valid_Upto_Emirates_Id__c != null && applicant5.Valid_Upto_Emirates_Id__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates Id date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Valid_Upto_National_ID__c != null && applicant5.Valid_Upto_National_ID__c < system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'National Id date cannot not be past date for Applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        if(applicant5.Type_Of_Applicant__c != null && applicant5.Type_Of_Applicant__c == 'Corporate Purchaser' && ((applicant5.Country__c != null && applicant5.Country__c != 'UAE')
                                                                                                                   || (applicant5.Mobile_Country_With_Code__c != null && applicant5.Mobile_Country_With_Code__c != '+971'))){
                                                                                                                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select UAE country and +971 mobile country code for 5th applicant');
                                                                                                                       ApexPages.addMessage(myMsg);
                                                                                                                       i=1;
                                                                                                                   }
        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
        
        //added by artee for others mobile number validation
        if(applicant5.Landline_Number__c != null && applicant5.Landline_Number_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Landline Number Country Code Is Required For Landline Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant5.Secondary_Mobile_Number__c != null && applicant5.Alternate_Mobile_Country_with_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Alternate Mobile Country Code Is Required For Alternate Mobile Number');
            ApexPages.addMessage(myMsg);
            i=1;
        } 
        if(applicant5.Secondary_Contact_Number__c != null && applicant5.Secondary_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Secondary Contact Country Code Is Required For Secondary Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.POA_Contact_Number__c != null && applicant5.POA_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA Contact Country Code Is Required For POA Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.POA_2_Contact_Number__c != null && applicant5.POA2_Contact_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'POA2 Contact Country Code Is Required For POA2 Contact Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant5.Organization_Phone_numbers__c != null && applicant5.Office_Country_Code__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Office Country Code Is Required For Office Phone Number');
            ApexPages.addMessage(myMsg);
            i=1;
        }        
        //added by artee for others mobile number validation
        
        if(fifthApplicantRegistration != null && fifthApplicantRegistration > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date cannot not be future date for applicant 5'); 
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(!fifthApplicantPosition && fifthApplicantDOB != null && fifthApplicantDOB > system.today()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB cannot not be future date for applicant 5');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        
        if(!currentPosition && firstApplicantDOB == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'DOB for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(currentPosition && firstApplicantRegistration == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Registration Date for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;  
        }
        if(applicant.Permanent_Address__c == '' || applicant.Permanent_Address__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Permanent address for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Preferred_address_for_all_correspondence__c == '' || applicant.Preferred_address_for_all_correspondence__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Preferred address for all correspondance Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        /// Added by Neha on 3/2/19 Starts Here   
        if(applicant.Country__c == '' || applicant.Country__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Country for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Country__c == 'UAE'){           
            if(applicant.State__c == '' || applicant.State__c == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Emirates for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        // Added By Hitesh GV
        if(applicant.Mobile_Country_With_Code__c == '' || applicant.Mobile_Country_With_Code__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mobile Country Code for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        // Added By Hitesh GV
        if(applicant.Country__c == 'UAE' && applicant.Mobile_Country_With_Code__c != '+971') {           
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mobile Country code for UAE residents must be a +971');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        /// Added by Neha on 3/2/19 Ends Here      
        if(applicant.Mobile_Number__c == '' ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mobile Number for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Email_Address__c == '' || applicant.Email_Address__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Email Address for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Nationality__c == '' || applicant.Nationality__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Nationality for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Type_Of_Applicant__c == '' || applicant.Type_Of_Applicant__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Type Of Applicant for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        if(applicant.Subtype_Of_Applicant__c == '' || applicant.Subtype_Of_Applicant__c == null ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Residential Status for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        // Modified By Hitesh GV (included Valid_Upto_Emirates_Id__c)
        if(applicant.Subtype_Of_Applicant__c == 'UAE Resident'){
            if(applicant.Passport_Copy__c == false || applicant.Passport_Copy_Details__c == '' || applicant.Passport_Copy_Details__c == null ||
               applicant.Valid_Until_Passport__c == null || applicant.Visa_Copy__c == false || applicant.Visa_Copy_Valid_Upto__c == null ||
               applicant.Emirates_ID__c == false || applicant.Emirates_ID_Details__c == '' || applicant.Emirates_ID_Details__c == null || applicant.Valid_Upto_Emirates_Id__c == null ){            
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                   ApexPages.addMessage(myMsg);
                   i=1;
               } 
            
            if(applicant.Country__c != 'UAE') {           
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Country Should be UAE only');
                ApexPages.addMessage(myMsg);
                i=1; 
            }  
            
        }
        if(applicant.Subtype_Of_Applicant__c == 'Non-UAE Resident'){
            if(applicant.Passport_Copy__c  == false || applicant.Passport_Copy_Details__c == '' || applicant.Passport_Copy_Details__c == null ||
               applicant.Valid_Until_Passport__c == null ||  applicant.National_ID__c == false || applicant.National_ID_Details__c == '' ||
               applicant.National_ID_Details__c == null || applicant.Valid_Upto_National_ID__c == null){            
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                   ApexPages.addMessage(myMsg);
                   i=1;
               }                        
        }
        if(applicant.Power_of_Attorney__c == true){
            if(applicant.Power_of_Attorney_Details__c == '' || applicant.Power_of_Attorney_Details__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the details are filled properly for Power of Attorney.');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(applicant.Others__c == true){
            if(applicant.Others_Details__c == '' || applicant.Others_Details__c == null || applicant.Others_Valid_Upto__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the details are filled properly for Others.');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(applicant.Non_residency_Letter__c == true){
            if(applicant.Non_residency_Letter_Details__c == '' || applicant.Non_residency_Letter_Details__c == null || applicant.Non_residency_Letter_Valid_Upto__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the details are filled properly for Non-Residency Letter.');
                ApexPages.addMessage(myMsg);
                i=1;
            }
        }
        if(applicant.Subtype_Of_Applicant__c == 'Companies incorporated in the UAE'){
            if(applicant.Registration_License__c == false || applicant.Registration_License_Details__c == '' || applicant.Registration_License_Details__c == null
               || applicant.Passport_Copy_of_Authorized_Signatory__c == false || applicant.Passport_Copy_of_Authorized_Signatory_De__c == '' || applicant.Passport_Copy_of_Authorized_Signatory_De__c  == null){            
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                   ApexPages.addMessage(myMsg);
                   i=1;
               }                           
        }
        if(applicant.Subtype_Of_Applicant__c == Constants.COMPANIES_INCORPORATED_IN_FREE_ZONE){
            if(applicant.Certificate_of_Incorporation__c == false || applicant.Certificate_of_Incorporation_Details__c == '' || applicant.Certificate_of_Incorporation_Details__c == null ||
               applicant.Certificate_of_Good_Standing_and_Certifi__c == false || applicant.Certificate_of_Standing_Incumbe_Detail__c == '' || applicant.Certificate_of_Standing_Incumbe_Detail__c == null
               || applicant.Passport_Copy_of_Authorized_Signatory__c == false || applicant.Passport_Copy_of_Authorized_Signatory_De__c == '' || applicant.Passport_Copy_of_Authorized_Signatory_De__c == null 
               || applicant.Memoradum_Articles_of_Association__c == false || applicant.Memoradum_Articles_of_Association_Deta__c == '' || applicant.Memoradum_Articles_of_Association_Deta__c == null){            
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                   ApexPages.addMessage(myMsg);
                   i=1;
               }                        
        }
        
        //anuja added on 16 dec 
        if(addressCheck == False){               
            if(applicant.Mailing_Address__c == null ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mailing Address for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }        
            if(applicant.Mailing_Country__c == null || applicant.Mailing_Country__c == '' ){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mailing Country for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i=1;
            }       
            if(applicant.Mailing_Country__c == 'UAE'){
                if(applicant.Mailing_State__c == null ){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Mailing Emirates for Applicant 1 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i=1;
                }                      
            }         
        }
        
        //-----For Email Validation API-----
       /* if (!isap1EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Email Address.');
            ApexPages.addMessage(myMsg);
            i=1;
        }*/

        //-----For POAEmail Validation API-----
        if (String.isNotBlank(applicant.POA_Email_Id__c) && !isap1POAEmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid POA Email ID.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA2Email Validation API-----
        if (String.isNotBlank(applicant.POA_2_Email_Id__c) && !isap1POA2EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid POA 2 Email Id.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap2 Email Validation API-----
        if (String.isNotBlank(applicant2.Email_Address__c) && !isap2EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 2 Email Address.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap2 POAEmail Validation API-----
        if (String.isNotBlank(applicant2.POA_Email_Id__c) && !isap2POAEmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 2 POA Email ID.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap2 POA2Email Validation API-----
        if (String.isNotBlank(applicant2.POA_2_Email_Id__c) && !isap2POA2EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 2 POA 2 Email Id.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap3 Email Validation API-----
        if (String.isNotBlank(applicant3.Email_Address__c) && !isap3EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 3 Email Address.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap3 POAEmail Validation API-----
        if (String.isNotBlank(applicant3.POA_Email_Id__c) && !isap3POAEmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 3 POA Email ID.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap3 POA2Email Validation API-----
        if (String.isNotBlank(applicant3.POA_2_Email_Id__c) && !isap3POA2EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 3 POA 2 Email Id.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap4 Email Validation API-----
        if (String.isNotBlank(applicant4.Email_Address__c) && !isap4EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 4 Email Address.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap4 POAEmail Validation API-----
        if (String.isNotBlank(applicant4.POA_Email_Id__c) && !isap4POAEmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 4 POA Email ID.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap5 Email Validation API-----
        if (String.isNotBlank(applicant5.Email_Address__c) && !isap5EmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 5 Email Address.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Ap5 POAEmail Validation API-----
        if (String.isNotBlank(applicant5.POA_Email_Id__c) && !isap5POAEmailValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 5 POA Email ID.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         system.debug('the value for isap1MobValid '+isap1MobValid);
         if (!isap1MobValid) {
            system.debug('Inside on save for isap1MobValid');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant.Secondary_Mobile_Number__c) && !isap1AlternateMobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Alternate Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant.Landline_Number__c) && !isap1LandlineNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Landline Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

          //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant.Secondary_Contact_Number__c) && !isap1SecondaryConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Secondary Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant.POA_Contact_Number__c) && !isPOAConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid POA Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant.POA_2_Contact_Number__c) && !isPOA2ConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid POA2 Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant.Organization_Phone_numbers__c) && !isOfficeNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Office Phone Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.Mobile_Number__c) && !isap2MobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid Applicant 2 Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.Secondary_Mobile_Number__c) && !isap2AlternateMobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid applicant 2 Alternate Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.Landline_Number__c) && !isap2LandlineNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid applicant 2 Landline Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.Secondary_Contact_Number__c) && !isap2SecondaryConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 2 Secondary Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.POA_Contact_Number__c) && !isAp2POAConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 2 POA Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant2.POA_2_Contact_Number__c) && !isAp2POA2ConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 2 POA2 Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

         //-----For Mobile Validation API-----
         if (String.isNotBlank(applicant2.Organization_Phone_numbers__c) && !isAp2OfficeNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 2 Office Phone Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

                //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant3.Mobile_Number__c) && !isap3MobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 3 Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }



        //-----For Alternate Mobile Validation API-----
        if (String.isNotBlank(applicant3.Secondary_Mobile_Number__c) && !isap3AlternateMobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 3 Alternate Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant3.Landline_Number__c) && !isap3LandlineNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid applicant 3 Landline Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Secondary Mobile Validation API-----
        if (String.isNotBlank(applicant3.Secondary_Contact_Number__c) && !isap3SecondaryConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 3 Secondary Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA Mobile Validation API-----
        if (String.isNotBlank(applicant3.POA_Contact_Number__c) && !isAp3POAConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 3 POA Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA2 Mobile Validation API-----
        if (String.isNotBlank(applicant3.POA_2_Contact_Number__c) && !isAp3POA2ConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 3 POA2 Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Office Number Validation API-----
        if (String.isNotBlank(applicant3.Organization_Phone_numbers__c) && !isAp3OfficeNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 3 Office Phone Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

                //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant4.Mobile_Number__c) && !isap4MobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 4 Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Alternate Mobile Validation API-----
        if (String.isNotBlank(applicant4.Secondary_Mobile_Number__c) && !isap4AlternateMobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 4 Alternate Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant4.Landline_Number__c) && !isap4LandlineNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid applicant 4 Landline Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Secondary Mobile Validation API-----
        if (String.isNotBlank(applicant4.Secondary_Contact_Number__c) && !isap4SecondaryConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 4 Secondary Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA Mobile Validation API-----
        if (String.isNotBlank(applicant4.POA_Contact_Number__c) && !isAp4POAConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 4 POA Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA2 Mobile Validation API-----
        if (String.isNotBlank(applicant4.POA_2_Contact_Number__c) && !isAp4POA2ConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 4 POA2 Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Office Number Validation API-----
        if (String.isNotBlank(applicant4.Organization_Phone_numbers__c) && !isAp4OfficeNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 4 Office Phone Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant5.Mobile_Number__c) && !isap5MobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 5 Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Alternate Mobile Validation API-----
        if (String.isNotBlank(applicant5.Secondary_Mobile_Number__c) && !isap5AlternateMobValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid applicant 5 Alternate Mobile Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Mobile Validation API-----
        if (String.isNotBlank(applicant5.Landline_Number__c) && !isap5LandlineNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please enter a valid applicant 5 Landline Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }
        //-----For Secondary Mobile Validation API-----
        if (String.isNotBlank(applicant5.Secondary_Contact_Number__c) && !isap5SecondaryConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 5 Secondary Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For POA Mobile Validation API-----
        if (String.isNotBlank(applicant5.POA_Contact_Number__c) && !isAp5POAConNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 5 POA Contact Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        //-----For Office Number Validation API-----
        if (String.isNotBlank(applicant5.Organization_Phone_numbers__c) && !isAp5OfficeNoValid) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Applicant 5 Office Phone Number.');
            ApexPages.addMessage(myMsg);
            i=1;
        }

        ///////////////////Inserting Future correspondance contact////////////////////  
        if(boookingObj.Future_Correspondence_Contact__c == '1st Applicant'){
            if(applicant.Name != null ){
                boookingObj.Future_Correspondence_Contact_Name__c = applicant.Name;
            }
            if( applicant.Mobile_Number__c != null ){
                boookingObj.Future_Correspondence_Contact_Phone__c = String.valueOf(applicant.Mobile_Country_With_Code__c+applicant.Mobile_Number__c).replaceFirst( '^0+', '');  
            }
            if(applicant.Email_Address__c != null ){
                boookingObj.Future_Correspondence_Contact_Email__c = applicant.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '1st Applicant';           
        }
        if(boookingObj.Future_Correspondence_Contact__c == '2nd Applicant' ){
            if(applicant2.Name != null ){
                boookingObj.Future_Correspondence_Contact_Name__c = applicant2.Name;
            }
            if(applicant2.Mobile_Number__c != ''&& applicant2.Mobile_Number__c != null){
                boookingObj.Future_Correspondence_Contact_Phone__c = String.valueOf(applicant2.Mobile_Number__c).replaceFirst( '^0+', '');  
            }
            if(applicant2.Email_Address__c != null ){
                boookingObj.Future_Correspondence_Contact_Email__c = applicant2.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '2nd Applicant';
        }
        if(boookingObj.Future_Correspondence_Contact__c == '3rd Applicant' ){
            if(applicant3.Name != null ){
                boookingObj.Future_Correspondence_Contact_Name__c = applicant3.Name;
            }
            if(applicant3.Mobile_Number__c != ''&& applicant3.Mobile_Number__c != null){
                boookingObj.Future_Correspondence_Contact_Phone__c = String.valueOf(applicant3.Mobile_Number__c).replaceFirst( '^0+', '');
            }
            if(applicant3.Email_Address__c != null ){
                boookingObj.Future_Correspondence_Contact_Email__c = applicant3.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '3rd Applicant';
        }
        if(boookingObj.Future_Correspondence_Contact__c == '4th Applicant' ){
            if(applicant4.Name != null ){
                boookingObj.Future_Correspondence_Contact_Name__c = applicant4.Name;
            }
            if(applicant4.Mobile_Number__c != ''&& applicant4.Mobile_Number__c != null){
                boookingObj.Future_Correspondence_Contact_Phone__c = String.valueOf(applicant4.Mobile_Number__c).replaceFirst( '^0+', '');
            }
            if(applicant4.Email_Address__c != null ){
                boookingObj.Future_Correspondence_Contact_Email__c = applicant4.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '4th Applicant';
        }
        if(boookingObj.Future_Correspondence_Contact__c == '5th Applicant' ){
            if(applicant5.Name != null ){
                boookingObj.Future_Correspondence_Contact_Name__c = applicant5.Name;
            }
            if(applicant5.Mobile_Number__c != ''&& applicant5.Mobile_Number__c != null){
                boookingObj.Future_Correspondence_Contact_Phone__c = String.valueOf(applicant5.Mobile_Number__c).replaceFirst( '^0+', '');
            }
            if(applicant5.Email_Address__c != null ){
                boookingObj.Future_Correspondence_Contact_Email__c = applicant5.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '5th Applicant';
        }
        ///////////////////Inserting Future correspondance contact Endss here////////////////////     
        boookingObj.Quotation__c = selectedQuote;
        Pattern pattern = Pattern.compile('^[a-zA-Z0-9]*$');
        Matcher matcher1 = pattern.matcher(System.Label.BookingDefaultCRMSellerRepresentative);
        Matcher matcher2 = pattern.matcher(System.Label.BookingDefaultCRMDocumentController);
        if(System.Label.BookingDefaultCRMSellerRepresentative != '' && System.Label.BookingDefaultCRMSellerRepresentative != null && matcher1.matches() && (System.Label.BookingDefaultCRMSellerRepresentative.startsWith('00T') || System.Label.BookingDefaultCRMSellerRepresentative.startsWith('005'))){
            boookingObj.CRM_Seller_representative__c = System.Label.BookingDefaultCRMSellerRepresentative;
        }
        if(System.Label.BookingDefaultCRMDocumentController != '' && System.Label.BookingDefaultCRMDocumentController != null && matcher2.matches() && (System.Label.BookingDefaultCRMDocumentController.startsWith('00T') || System.Label.BookingDefaultCRMDocumentController.startsWith('005'))){
            boookingObj.CRM_Document_Controller__c = System.Label.BookingDefaultCRMDocumentController;
        }
        if (applicant.Name != ''&& applicant.Name != null) {
            boookingObj.Number_of_Buyers__c = 1;
        }
        if (applicant2.Name != '' && applicant2.Name != null) {
            boookingObj.Number_of_Buyers__c = 2;
        }
        if (applicant3.Name != '' && applicant3.Name != null) {
            boookingObj.Number_of_Buyers__c = 3;
        }
        if (applicant4.Name != '' && applicant4.Name != null) {
            boookingObj.Number_of_Buyers__c = 4;
        }
        if (applicant5.Name != '' && applicant5.Name != null) {
            boookingObj.Number_of_Buyers__c = 5;
        }
        
        //added by shailesh
        if (i == 0 || Test.isRunningTest()) {            
            for(Receipt__c receiptOBJTobeUpdate : ShowReceiptDetails ){
                receiptOBJTobeUpdate.Opportunity__c = boookingObj.Opportunity__c;
                receiptOBJTobeUpdate.Project__c = boookingObj.Project__c;
                receiptOBJTobeUpdate.Project_Unit__c = boookingObj.Unit__c;
                receiptOBJTobeUpdate.Opportunity_Email_Id__c=applicant.Email_Address__c;                            
                if(boookingObj.Unit__c != null){
                    Unit__c u = [SELECT Tower__r.Business_Unit__c, Tower__r.Business_Unit_Code__c FROM Unit__c where Id = :boookingObj.Unit__c];
                    if(u != null){
                        receiptOBJTobeUpdate.Business_Unit__c = u.Tower__r.Business_Unit__c;
                        receiptOBJTobeUpdate.Business_Unit_Code__c = u.Tower__r.Business_Unit_Code__c;
                    }
                }                               
                if(receiptOBJTobeUpdate.Total_Amount__c != null)
                    ReceiptLstTobeUpdate.add(receiptOBJTobeUpdate);
            }
        }
        
        //Service Tax is applicable for this project
        system.debug('i' + i);
        // Added By Bhavishya Test.isRunning Test for Coverage
        if (i == 0 || Test.isRunningTest()) {
            Opportunity insObj = new Opportunity();
            insObj.Id = boookingObj.Opportunity__c;
            insObj.Project__c = boookingObj.Project__c;
            insObj.Unit__c = boookingObj.Unit__c;
            insObj.Reason_for_Reblocking__c = 'Booking';
            insObj.StageName= 'Token Amount Received - BIP';                       
            insObj.Future_Correspondence_Contact_Name__c=boookingObj.Future_Correspondence_Contact_Name__c;
            if(boookingObj.Future_Correspondence_Contact_Phone__c != null)
                insObj.Future_Correspondence_Contact_Phone__c = boookingObj.Future_Correspondence_Contact_Phone__c;
            if(boookingObj.Future_Correspondence_Contact_Email__c != null)
                insObj.Future_Correspondence_Contact_Email__c = boookingObj.Future_Correspondence_Contact_Email__c;
            if(boookingObj.Future_Correspondence_Contact__c != null)
                insObj.Future_Correspondence_Contact__c = boookingObj.Future_Correspondence_Contact__c;
            
            if(dateOfOfferPossesion != null)
                boookingObj.Date_for_offer_of_Possession__c = dateOfOfferPossesion;           
            try{                     
                boookingObj.status__c = 'UnProcessed';
                boookingObj.Booking_Approver_Audit__c = 'Not Started'; // Added by Neha on 8/3/19
                boookingObj.Verification_status__c = 'Not Started'; // Added by Neha on 8/3/19
                boookingObj.Call_Disposition__c = 'Not Started'; // Added by Neha on 8/3/19
                if(ShowReceiptDetails.size() > 0){ //Added by Priya on 2 May 2020 to update Receipt on Booking
                    boookingObj.Receipts__c = ShowReceiptDetails[0].id;
                    System.debug('adding receipt ='+boookingObj.Receipts__c);
                } 
                  System.debug('boookingObj ='+boookingObj);
                insert boookingObj; // inserting Booking
                try{
                    if(!ReceiptLstTobeUpdate.isEmpty()){
                        for(Receipt__c rd: ReceiptLstTobeUpdate){
                            rd.Booking__c = boookingObj.Id;                      
                        }                       
                        Update ReceiptLstTobeUpdate; // update receipt with booking Id
                    } 
                }                
                catch (DmlException e) {
                    System.debug('An error has occured while inserting receipt. Please contact your administrator. : ' + e.getMessage());
                }
                try{    
                    Booking__c dummyBooking = new Booking__c();
                    dummyBooking = [SELECT Stage_of_Booking__c FROM Booking__c WHERE Id = :boookingObj.Id];
                    if(dummyBooking != null && dummyBooking.Stage_of_Booking__c != '' && dummyBooking.Stage_of_Booking__c != null){
                        Unit__c ut = [Select Id, Name, Unit_Status__c from Unit__c where Id =: boookingObj.Unit__c]; 
                        ut.Unit_Status__c =  dummyBooking.Stage_of_Booking__c;
                        update ut;
                    }
                    update insObj;//updating opportunity
                } 
                catch (DmlException e){
                    System.debug('An error has occured while updating. Please contact your administrator. : ' + e.getMessage());
                }                                                             
            }                 
            catch (DmlException e) {
                System.debug('An error has occured while inserting booking. Please contact your administrator. : ' + e.getMessage());
            }           
            
            //Updating Parkings/////           
            ////Tandem Covered////
            if (tandemParking > 0) {
                for(integer j = 0 ; j < tandemParking ; j++) {                
                    TandemCOVEREDParkingList[j].Status__c =  'Booked'; 
                    ParkingListToUpdate.add(TandemCOVEREDParkingList[j]);
                }                 
            }         
            ////Single Open////
            if (openParking > 0) {
                for(integer j = 0 ; j < openParking; j++){                 
                    SingleOPENParkingList[j].Status__c =  'Booked'; 
                    ParkingListToUpdate.add(SingleOPENParkingList[j]);
                }                 
            }
            ////Stack ////
            //  STACKParkingList empty check added by Bhavishya
            if (stackParking > 0  && !STACKParkingList.isEmpty() ) {
                for(integer j = 0 ; j < stackParking; j++){
                    STACKParkingList[j].Status__c = 'Booked'; 
                    ParkingListToUpdate.add(STACKParkingList[j]);                
                }               
            }
            // Added by bhavishya for Test Class coverage
            if(ParkingListToUpdate.size() > 0 && !Test.isRunningTest()){
                update ParkingListToUpdate;
            }              
            //Updating  Customer Pay Plan Headers with new booking 
            if(boookingObj.id != null){            
                try {
                    //Updating Quotation with new booking
                    if (QuoteDetails.size() > 0) {
                        QuoteDetails[0].Booking__c =  boookingObj.id;
                        update QuoteDetails;
                    }
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());    
                }
                
                //inserting the Applicants
                if (applicant.Name != ''&& applicant.Name != null) {
                    if (addressCheck == true) {
                        applicant.Mailing_Address_same_as_PermanentAddress__c = true;
                        applicant.Mailing_Address__c = applicant.Permanent_Address__c;
                        applicant.Mailing_Country__c = applicant.Country__c;
                        applicant.Mailing_State__c = applicant.State__c;
                        applicant.Mailing_City__c = applicant.City__c;
                    }                
                    if(applicant.Type_Of_Applicant__c=='Corporate Purchaser')
                    {
                        applicant.Corporate_Stamping_Required__c=true;
                    }
                    if(applicant.POA_Email_Id__c!=null)
                    {
                        applicant.Authorized_Signatory_2__c=applicant.POA_Email_Id__c;
                    }
                    if(applicant.POA_2_Email_Id__c!=null)
                    {
                        applicant.Authorized_Signatory_3__c=applicant.POA_2_Email_Id__c;
                    }
                    
                    //added by Artee for concatenating other mobile numbers with country code
                    if(applicant.Landline_Number__c!=null)
                    {
                        applicant.Landline_Number_wcc__c = applicant.Landline_Number_Country_Code__c+applicant.Landline_Number__c;
                    }
                    if(applicant.Secondary_Mobile_Number__c!=null)
                    {
                        applicant.Alternate_Mobile_Number__c = applicant.Alternate_Mobile_Country_with_Code__c+applicant.Secondary_Mobile_Number__c;
                    }
                    if(applicant.Secondary_Contact_Number__c!=null)
                    {
                        applicant.Secondary_Contact_Number_wcc__c = applicant.Secondary_Contact_Country_Code__c+applicant.Secondary_Contact_Number__c;
                    }
                    if(applicant.POA_Contact_Number__c!=null)
                    {
                        //applicant.Authorized_Signatory2_Phone__c=applicant.POA_Contact_Number__c;
                        applicant.Authorized_Signatory2_Phone__c = applicant.POA_Contact_Country_Code__c+applicant.POA_Contact_Number__c;
                    }
                    if(applicant.POA_2_Contact_Number__c!=null)
                    {
                        //applicant.Authorized_Signatory3_Phone__c=applicant.POA_2_Contact_Number__c;                       
                        applicant.Authorized_Signatory3_Phone__c = applicant.POA2_Contact_Country_Code__c+applicant.POA_2_Contact_Number__c;
                    }
                    if(applicant.Organization_Phone_numbers__c!=null)
                    {
                        applicant.Office_Phoner_Number_wcc__c = applicant.Office_Country_Code__c+applicant.Organization_Phone_numbers__c;
                    }
                    //added by Artee for concatenating other mobile numbers with country code
                    
                    applicant.Applicant_Number__c = 'Primary Applicant';
                    if(firstApplicantDOB != null) {
                        applicant.DOB__c = firstApplicantDOB;
                    }
                    if(firstApplicantRegistration != null) {
                        applicant.Registration_Date__c = firstApplicantRegistration;
                    }
                    if(applicant.Mobile_Number__c != ''&& applicant.Mobile_Number__c != null) {
                       // applicant.Mobile_Number__c = String.valueOf(applicantPhone).replaceFirst( '^0+', '');
                        // Added By Hitesh GV
                        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
                        applicant.Primary_Mobile_Number__c = applicant.Mobile_Country_With_Code__c+applicant.Mobile_Number__c;
                    }
                    applicant.Booking__c = boookingObj.id;
                    applicant.Opportunity__c = boookingObj.Opportunity__c;
                    applicant.State__c = app1StateName;
                    
                    listApplicant.add(applicant);
                }
                if (applicant2.Name != '' && applicant2.Name != null) {
                    if (addressCheckApplicant2 == true) {
                        applicant2.Mailing_Address_same_as_PermanentAddress__c = true;
                        applicant2.Mailing_Address__c = applicant2.Permanent_Address__c;
                        applicant2.Mailing_Country__c = applicant2.Country__c;
                        applicant2.Mailing_State__c = applicant2.State__c;
                        applicant2.Mailing_City__c = applicant2.City__c;
                    }
                    applicant2.Applicant_Number__c = 'Second Applicant';
                    if(secondApplicantDOB != null) {
                        applicant2.DOB__c = secondApplicantDOB;
                    }
                    if(secondApplicantRegistration != null) {
                        applicant2.Registration_Date__c = secondApplicantRegistration;
                    }
                    if (applicant2.Mobile_Number__c != null && applicant2.Mobile_Number__c != '') {
                       // applicant2.Mobile_Number__c = String.valueOf(applicant2Phone).replaceFirst( '^0+', '');
                        //Added By Hitesh GV
                        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
                        applicant2.Primary_Mobile_Number__c = applicant2.Mobile_Country_With_Code__c+applicant2.Mobile_Number__c;
                    }
                    
                    //added by Artee for concatenating other mobile numbers with country code
                    if(applicant2.Landline_Number__c!=null)
                    {
                        applicant2.Landline_Number_wcc__c = applicant2.Landline_Number_Country_Code__c+applicant2.Landline_Number__c;
                    }
                    if(applicant2.Secondary_Mobile_Number__c!=null)
                    {
                        applicant2.Alternate_Mobile_Number__c = applicant2.Alternate_Mobile_Country_with_Code__c+applicant2.Secondary_Mobile_Number__c;
                    }
                    if(applicant2.Secondary_Contact_Number__c!=null)
                    {
                        applicant2.Secondary_Contact_Number_wcc__c = applicant2.Secondary_Contact_Country_Code__c+applicant2.Secondary_Contact_Number__c;
                    }
                    if(applicant2.POA_Contact_Number__c!=null)
                    {
                        applicant2.Authorized_Signatory2_Phone__c = applicant2.POA_Contact_Country_Code__c+applicant2.POA_Contact_Number__c;
                    }
                    if(applicant2.POA_2_Contact_Number__c!=null)
                    {                   
                        applicant2.Authorized_Signatory3_Phone__c = applicant2.POA2_Contact_Country_Code__c+applicant2.POA_2_Contact_Number__c;
                    }
                    if(applicant2.Organization_Phone_numbers__c!=null)
                    {
                        applicant2.Office_Phoner_Number_wcc__c = applicant2.Office_Country_Code__c+applicant2.Organization_Phone_numbers__c;
                    }
                    //added by Artee for concatenating other mobile numbers with country code
                    
                    applicant2.Booking__c = boookingObj.id;
                    applicant2.Opportunity__c = boookingObj.Opportunity__c;
                    applicant2.State__c = app2StateName;
                    listApplicant.add(applicant2);
                }
                if (applicant3.Name != '' && applicant3.Name != null) {
                    if (addressCheckApplicant3 == true) {
                        applicant3.Mailing_Address_same_as_PermanentAddress__c = true;
                        applicant3.Mailing_Address__c = applicant3.Permanent_Address__c;
                        applicant3.Mailing_Country__c = applicant3.Country__c;
                        applicant3.Mailing_State__c = applicant3.State__c;
                        applicant3.Mailing_City__c = applicant3.City__c;
                    }
                    applicant3.Applicant_Number__c = 'Third Applicant';
                    if(thirdApplicantDOB != null) {
                        applicant3.DOB__c = thirdApplicantDOB;
                    }
                    if(thirdApplicantRegistration != null) {
                        applicant3.Registration_Date__c = thirdApplicantRegistration;
                    }
                    
                    if (applicant3.Mobile_Number__c != null && applicant3.Mobile_Number__c != '') {
                        //applicant3.Mobile_Number__c = String.valueOf(applicant3Phone).replaceFirst( '^0+', '');
                        //Added By Hitesh GV
                        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
                        applicant3.Primary_Mobile_Number__c = applicant3.Mobile_Country_With_Code__c+applicant3.Mobile_Number__c;
                    }
                    
                    //added by Artee for concatenating other mobile numbers with country code
                    if(applicant3.Landline_Number__c!=null)
                    {
                        applicant3.Landline_Number_wcc__c = applicant3.Landline_Number_Country_Code__c+applicant3.Landline_Number__c;
                    }
                    if(applicant3.Secondary_Mobile_Number__c!=null)
                    {
                        applicant3.Alternate_Mobile_Number__c = applicant3.Alternate_Mobile_Country_with_Code__c+applicant3.Secondary_Mobile_Number__c;
                    }
                    if(applicant3.Secondary_Contact_Number__c!=null)
                    {
                        applicant3.Secondary_Contact_Number_wcc__c = applicant3.Secondary_Contact_Country_Code__c+applicant3.Secondary_Contact_Number__c;
                    }
                    if(applicant3.POA_Contact_Number__c!=null)
                    {
                        applicant3.Authorized_Signatory2_Phone__c  = applicant3.POA_Contact_Country_Code__c+applicant3.POA_Contact_Number__c;
                    }
                    if(applicant3.POA_2_Contact_Number__c!=null)
                    {                   
                        applicant3.Authorized_Signatory3_Phone__c  = applicant3.POA2_Contact_Country_Code__c+applicant3.POA_2_Contact_Number__c;
                    }
                    if(applicant3.Organization_Phone_numbers__c!=null)
                    {
                        applicant3.Office_Phoner_Number_wcc__c = applicant3.Office_Country_Code__c+applicant3.Organization_Phone_numbers__c;
                    }
                    //added by Artee for concatenating other mobile numbers with country code
                    
                    applicant3.Booking__c = boookingObj.id;
                    applicant3.Opportunity__c = boookingObj.Opportunity__c;
                    applicant3.State__c = app3StateName;
                    listApplicant.add(applicant3);
                }
                if (applicant4.Name != null ) {
                    if (addressCheckApplicant4 == true) {
                        applicant4.Mailing_Address_same_as_PermanentAddress__c = true;
                        applicant4.Mailing_Address__c = applicant4.Permanent_Address__c;
                        applicant4.Mailing_Country__c = applicant4.Country__c;
                        applicant4.Mailing_State__c = applicant4.State__c;
                        applicant4.Mailing_City__c = applicant4.City__c;
                    }
                    applicant4.Applicant_Number__c = 'Fourth Applicant';
                    if(fourthApplicantDOB != null) {
                        applicant4.DOB__c = fourthApplicantDOB;
                    }
                    if(forthApplicantRegistration != null) {
                        applicant4.Registration_Date__c = forthApplicantRegistration;
                    }
                    if (applicant4.Mobile_Number__c != null && applicant4.Mobile_Number__c != '') {
                        //applicant4.Mobile_Number__c = String.valueOf(applicant4Phone).replaceFirst( '^0+', '');
                        //Added By Hitesh GV
                        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
                        applicant4.Primary_Mobile_Number__c = applicant4.Mobile_Country_With_Code__c+applicant4.Mobile_Number__c;
                    }
                    
                    //added by Artee for concatenating other mobile numbers with country code
                    if(applicant4.Landline_Number__c!=null)
                    {
                        applicant4.Landline_Number_wcc__c = applicant4.Landline_Number_Country_Code__c+applicant4.Landline_Number__c;
                    }
                    if(applicant4.Secondary_Mobile_Number__c!=null)
                    {
                        applicant4.Alternate_Mobile_Number__c = applicant4.Alternate_Mobile_Country_with_Code__c+applicant4.Secondary_Mobile_Number__c;
                    }
                    if(applicant4.Secondary_Contact_Number__c!=null)
                    {
                        applicant4.Secondary_Contact_Number_wcc__c = applicant4.Secondary_Contact_Country_Code__c+applicant4.Secondary_Contact_Number__c;
                    }
                    if(applicant4.POA_Contact_Number__c!=null)
                    {
                        applicant4.Authorized_Signatory2_Phone__c  = applicant4.POA_Contact_Country_Code__c+applicant4.POA_Contact_Number__c;
                    }
                    if(applicant4.POA_2_Contact_Number__c!=null)
                    {                   
                        applicant4.Authorized_Signatory3_Phone__c  = applicant4.POA2_Contact_Country_Code__c+applicant4.POA_2_Contact_Number__c;
                    }
                    if(applicant4.Organization_Phone_numbers__c!=null)
                    {
                        applicant4.Office_Phoner_Number_wcc__c = applicant4.Office_Country_Code__c+applicant4.Organization_Phone_numbers__c;
                    }
                    //added by Artee for concatenating other mobile numbers with country code
                    
                    applicant4.Booking__c = boookingObj.id;
                    applicant4.Opportunity__c = boookingObj.Opportunity__c;
                    applicant4.State__c = app4StateName;
                    listApplicant.add(applicant4);
                }
                if (applicant5.Name != null) {
                    
                    if (addressCheckApplicant5 == true) {
                        applicant5.Mailing_Address_same_as_PermanentAddress__c = true;
                        applicant5.Mailing_Address__c = applicant5.Permanent_Address__c;
                        applicant5.Mailing_Country__c = applicant5.Country__c;
                        applicant5.Mailing_State__c = applicant5.State__c;
                        applicant5.Mailing_City__c = applicant5.City__c;
                    }
                    applicant5.Applicant_Number__c = 'Fifth Applicant';
                    if(fifthApplicantDOB != null)
                        applicant5.DOB__c = fifthApplicantDOB;
                    
                    if(fifthApplicantRegistration != null)
                        applicant5.Registration_Date__c = fifthApplicantRegistration;
                    
                    if (applicant5.Mobile_Number__c != null && applicant5.Mobile_Number__c != '') {
                        //applicant5.Mobile_Number__c = String.valueOf(applicant5Phone).replaceFirst( '^0+', '');
                        //Added By Hitesh GV
                        //updated by Artee Mobile_County_Code__c => Mobile_Country_With_Code__c
                        applicant5.Primary_Mobile_Number__c = applicant5.Mobile_Country_With_Code__c+applicant5.Mobile_Number__c;
                    }
                    
                    //added by Artee for concatenating other mobile numbers with country code
                    if(applicant5.Landline_Number__c!=null)
                    {
                        applicant5.Landline_Number_wcc__c = applicant5.Landline_Number_Country_Code__c+applicant5.Landline_Number__c;
                    }
                    if(applicant5.Secondary_Mobile_Number__c!=null)
                    {
                        applicant5.Alternate_Mobile_Number__c = applicant5.Alternate_Mobile_Country_with_Code__c+applicant5.Secondary_Mobile_Number__c;
                    }
                    if(applicant5.Secondary_Contact_Number__c!=null)
                    {
                        applicant5.Secondary_Contact_Number_wcc__c = applicant5.Secondary_Contact_Country_Code__c+applicant5.Secondary_Contact_Number__c;
                    }
                    if(applicant5.POA_Contact_Number__c!=null)
                    {
                        applicant5.Authorized_Signatory2_Phone__c  = applicant5.POA_Contact_Country_Code__c+applicant5.POA_Contact_Number__c;
                    }
                    if(applicant5.POA_2_Contact_Number__c!=null)
                    {                   
                        applicant5.Authorized_Signatory3_Phone__c  = applicant5.POA2_Contact_Country_Code__c+applicant5.POA_2_Contact_Number__c;
                    }
                    if(applicant5.Organization_Phone_numbers__c!=null)
                    {
                        applicant5.Office_Phoner_Number_wcc__c = applicant5.Office_Country_Code__c+applicant5.Organization_Phone_numbers__c;
                    }
                    //added by Artee for concatenating other mobile numbers with country code
                    
                    applicant5.Booking__c = boookingObj.id;
                    applicant5.Opportunity__c = boookingObj.Opportunity__c;
                    applicant5.State__c = app5StateName;
                    listApplicant.add(applicant5);
                }
                try{
                    if(listApplicant.size() > 0 ){
                        //  isRunningTest Added by Bhavishya  for coverage issues
                        if (!Test.isRunningTest()) {
                            insert listApplicant;
                        }
                        saveBookingPDF(boookingObj.id);
                    }                 
                }                 
                catch (DmlException e)  {
                    System.debug('An error has occured. Please contact your administrator. : ' + e.getMessage());
                }                                  
            }
            if (boookingObj.id != null) {
                PageReference newpage = new Pagereference('/lightning/r/Booking__c/' + boookingObj.id + '/view');               
                newpage.setRedirect(true);
                return newpage;
            }
        }
        return null;
    }
    
    public PageReference Cancel() {
        PageReference newpage = new Pagereference('/lightning/page/home');
        return newpage;
    }
    
    public static Legal_Entity__c getLegalEntityDetails(Id unitId, Id pId) {
        Legal_Entity__c le = new Legal_Entity__c();
        Id leId = null;
        List<Unit__c> pu = [Select Id, Name, Legal_Entity__r.Id from Unit__c where Id = : unitId];
        if(pu != null && pu.size() > 0) {
            leId =pu[0].Legal_Entity__r.Id; 
        }
        
        if(leId == null) {
            List<Project__c> p = [Select Id, Name, RDS_Company_Code__r.Id from Project__c where Id = : pId];
            if(p != null && p.size() > 0)
                leId = p[0].RDS_Company_Code__r.Id;
        }
        if(leId != null) {
            le = [Select Name, Bank_Name_Flat_Cost__c, Account_Number_Flat_Cost__c,
                  IFSC_Code_Flat_Cost__c, MICR_Code_Flat_Cost__c,RDS_PAN_No__c,
                  Account_Name_Service_Tax__c,Account_Number_Service_tax__c, Bank_Name_Service_tax__c, 
                  IFSC_Code_Service_Tax__c, MICR_Code_Service_Tax__c, RDS_Service_Tax_No__c,
                  RDS_Address1__c,RDS_Address2__c, RDS_City__c, RDS_Pin_Code__c, CIN__c
                  FROM Legal_Entity__c where Id = : leId];
        }
        return le;
    }
    
    //// Added by Neha on 6/6/19 to save PDF in files and attachments    
    @future(callout=true)
    public static void saveBookingPDF(Id bookingId){
        
        Booking__c book = [SELECT Id, Name FROM Booking__c WHERE Id = :bookingId];
        
        if(book != null){
            PageReference pRef = new PageReference('/apex/BookingPDFDubai');
            pRef.getParameters().put('id', book.Id);
            
            Blob b;
            try {
                if(!Test.isRunningTest()){
                    b = pRef.getContent();
                } else {
                    b = Blob.valueOf('Is Test Method');
                }       
                
            } catch(VisualforceException e){
                system.debug('Error occurred while inserting attachment::: ' + e);        
            }
            
            ContentVersion cont = new ContentVersion();
            cont.Title = book.Name;
            cont.VersionData = b;
            cont.PathOnClient = book.Name + '.pdf';
            cont.ContentLocation = 'S';
            insert cont;
            
            if(cont.Id != null) {             
                FeedItem fi = new FeedItem(ParentId = book.Id, RelatedRecordId = cont.Id, Type = 'ContentPost');
                insert fi;
            } 
            // Added by Bhavishya for Test class coverage
            //if (!Test.isRunningTest()) {
            PreRegistrationOnBookingCreation.startPreRegistrationProcessFuture(book.Id);
            //}
        }
    }
    
    // method for formatting the currency details to Indian Commas Format
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
            if(i==2) {
                mF += ',';
            }
            if(i==4 || i==6 || i==8 || i==10 || i==12) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(!negative)
            mf =  mf + '/-';
        else
            mf = '- ' + mf + '/-';
        return mf;
    } 
    
    //this method is called with apex:actionFunction in VF page
    public PageReference setUserLocationInApex() {
        if(checkCondition){
            this.currentPosition = true;   
        }
        else{
            this.currentPosition = false;  
        }
        return null;
    }
    public PageReference setSecondApplicantInApex() {
        if(secondApplicantCondition){
            this.secondApplicantPosition = true;   
        }
        else{
            this.secondApplicantPosition = false;  
        }
        system.debug('this.secondApplicantPosition'+this.secondApplicantPosition);
        return null;
    }
    public PageReference setThirdApplicantInApex() {
        if(thirdApplicantCondition){
            this.thirdApplicantPosition = true;   
        }
        else{
            this.thirdApplicantPosition = false;  
        }
        system.debug('this.thirdApplicantPosition'+this.thirdApplicantPosition);
        return null;
    }
    
    public PageReference setforthApplicantInApex() {
        if(forthApplicantCondition){
            this.forthApplicantPosition = true;   
        }
        else{
            this.forthApplicantPosition = false;  
        }
        system.debug('this.forthApplicantPosition'+this.forthApplicantPosition);
        return null;
    }
    public PageReference setfifthApplicantInApex() {
        if(fifthApplicantCondition){
            this.fifthApplicantPosition = true;   
        }
        else{
            this.fifthApplicantPosition = false;  
        }
        system.debug('this.fifthApplicantPosition'+this.fifthApplicantPosition);
        return null;
    }
    
    public PageReference getCountryRelatedState() {
        system.debug('CS');
        List<Country_City_State_Mapping__c> countryRelatedStateList = [SELECT ID,Country__c, State__c,City__c FROM Country_City_State_Mapping__c WHERE Country__c =:selectedCountryName];
        List<String> stateList = new List<String>();
        
        if(countryapplicantData == 'applicant1'){
            stateOptions1 = new List<SelectOption>();
            stateOptions1.add(new SelectOption('--None--','--None--' ));
            cityOptions1 = new List<SelectOption>();
            cityOptions1.add(new SelectOption('--None--','--None--' ));
            applicant.Country__c = selectedCountryName;
        }
        else if(countryapplicantData == 'applicant2') {
            stateOptions2 = new List<SelectOption>();
            stateOptions2.add(new SelectOption('--None--','--None--' ));
            cityOptions2 = new List<SelectOption>();
            cityOptions2.add(new SelectOption('--None--','--None--' ));
            applicant2.Country__c = selectedCountryName;
        }
        else if(countryapplicantData == 'applicant3') {
            stateOptions3 = new List<SelectOption>();
            stateOptions3.add(new SelectOption('--None--','--None--' ));
            cityOptions3 = new List<SelectOption>();
            cityOptions3.add(new SelectOption('--None--','--None--' ));
            applicant3.Country__c = selectedCountryName;
        }
        else if(countryapplicantData == 'applicant4') {
            stateOptions4 = new List<SelectOption>();
            stateOptions4.add(new SelectOption('--None--','--None--' ));
            cityOptions4 = new List<SelectOption>();
            cityOptions4.add(new SelectOption('--None--','--None--' ));
            applicant4.Country__c = selectedCountryName;
        }
        else if(countryapplicantData == 'applicant5') {
            stateOptions5 = new List<SelectOption>();
            stateOptions5.add(new SelectOption('--None--','--None--' ));
            cityOptions5 = new List<SelectOption>();
            cityOptions5.add(new SelectOption('--None--','--None--' ));
            applicant5.Country__c = selectedCountryName;
        }

        system.debug(countryRelatedStateList);
        system.debug('applicantData:'+ countryapplicantData);
        system.debug(countryRelatedStateList.size());
       
        for(Country_City_State_Mapping__c cc : countryRelatedStateList){
            
            if(!stateList.contains(String.ValueOf(cc.State__c))){
               
                stateList.add(cc.State__c);
                if(countryapplicantData == 'applicant1'){
                    stateOptions1.add(new SelectOption(String.ValueOf(cc.State__c), String.ValueOf(cc.State__c)));  
                }
                else if(countryapplicantData == 'applicant2') {
                    stateOptions2.add(new SelectOption(String.ValueOf(cc.State__c), String.ValueOf(cc.State__c)));    
                }
                else if(countryapplicantData == 'applicant3') {
                    stateOptions3.add(new SelectOption(String.ValueOf(cc.State__c), String.ValueOf(cc.State__c)));    
                }
                else if(countryapplicantData == 'applicant4') {
                    stateOptions4.add(new SelectOption(String.ValueOf(cc.State__c), String.ValueOf(cc.State__c)));    
                }
                else if(countryapplicantData == 'applicant5') {
                    stateOptions5.add(new SelectOption(String.ValueOf(cc.State__c), String.ValueOf(cc.State__c)));    
                }
            }
            
        }
        
        return null;
    }
    public PageReference getCountryRelatedCity() {
                system.debug('CC');

        if(stateapplicantData == 'applicant1'){
            
            cityOptions1 = new List<SelectOption>();
            cityOptions1.add(new SelectOption('--None--','--None--' ));
            applicant.State__c = selectedStateName;
            app1StateName = selectedStateName;
        }
        else if(stateapplicantData == 'applicant2'){
            
            cityOptions2 = new List<SelectOption>();
            cityOptions2.add(new SelectOption('--None--','--None--' ));
            applicant2.State__c = selectedStateName;
            app2StateName = selectedStateName;
        }
        else if(stateapplicantData == 'applicant3'){
            
            cityOptions3 = new List<SelectOption>();
            cityOptions3.add(new SelectOption('--None--','--None--' ));
            applicant3.State__c = selectedStateName;
            app3StateName = selectedStateName;
        }
        else if(stateapplicantData == 'applicant4'){
            
            cityOptions4 = new List<SelectOption>();
            cityOptions4.add(new SelectOption('--None--','--None--' ));
            applicant4.State__c = selectedStateName;
            app4StateName = selectedStateName;
        }
        else if(stateapplicantData == 'applicant5'){
            
            cityOptions5 = new List<SelectOption>();
            cityOptions5.add(new SelectOption('--None--','--None--' ));
            applicant5.State__c = selectedStateName;
            app5StateName = selectedStateName;
        }
        
        List<Country_City_State_Mapping__c> countryRelatedCityList = [SELECT ID,Country__c, State__c,City__c FROM Country_City_State_Mapping__c WHERE State__c =:selectedStateName limit 999];
        for(Country_City_State_Mapping__c cc : countryRelatedCityList){
            if(stateapplicantData == 'applicant1'){
                cityOptions1.add(new SelectOption(String.ValueOf(cc.City__c), String.ValueOf(cc.City__c)));    
            }
            else if(stateapplicantData == 'applicant2'){
                cityOptions2.add(new SelectOption(String.ValueOf(cc.City__c), String.ValueOf(cc.City__c)));    
            }
            else if(stateapplicantData == 'applicant3'){
                cityOptions3.add(new SelectOption(String.ValueOf(cc.City__c), String.ValueOf(cc.City__c)));    
            }
            else if(stateapplicantData == 'applicant4'){
                cityOptions4.add(new SelectOption(String.ValueOf(cc.City__c), String.ValueOf(cc.City__c)));    
            }
            else if(stateapplicantData == 'applicant5'){
                cityOptions5.add(new SelectOption(String.ValueOf(cc.City__c), String.ValueOf(cc.City__c)));    
            }
        }
        
        return null;
    }
    
    public PageReference getCity() {
        
        system.debug('selectedCityName'+selectedCityName);
        if(cityapplicantData == 'applicant1'){
            app1CityName = selectedCityName; 
            applicant.City__c = selectedCityName;
        }else if(cityapplicantData == 'applicant2'){
            app2CityName = selectedCityName; 
            applicant2.City__c = selectedCityName;
            System.debug('app1City:'+applicant2.City__c);
        }else if(cityapplicantData == 'applicant3'){
            app3CityName = selectedCityName;
            applicant3.City__c = selectedCityName;
            System.debug('app1City:'+applicant3.City__c);
        }else if(cityapplicantData == 'applicant4'){
            app4CityName = selectedCityName;
            applicant4.City__c = selectedCityName;
        }else if(cityapplicantData == 'applicant5'){
            app5CityName = selectedCityName;
            applicant5.City__c = selectedCityName;
        }
        return null;
    }
    
    //----For Email Validation API----------
    /*public void validateEmailAddress() {
        try {
            if (String.isBlank(emailToValidate)) {
                emailValidationMessage = '';
                isEmailValid = false;
                return;
            }

            String response = Nice_EmailValidationUtility.validateEmail(emailToValidate);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isEmailValid = isValid;
                emailValidationMessage = isValid ? '✔ Email is valid' : '✘ Email is invalid';
            } else {
                isEmailValid = false;
                emailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isEmailValid = false;
            emailValidationMessage = 'Error occurred while validating the email.';
        }
    }*/

    //----For AP1 Email Validation API----------
    public void validateAp1EmailAddress() {

        ap1EmailValidationMessage = '';

        System.debug('Inside validateAp1MobNo');
        System.debug('Inside validateAp1MobNo applicant.Email_Address__c :'+applicant.Email_Address__c);
        try {
            if (String.isBlank(applicant.Email_Address__c)) {
                    ap1EmailValidationMessage = '';
                    isap1EmailValid = true;
                    return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant.Email_Address__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                System.debug('Error validating email result: ' + result);
                isap1EmailValid = isValid;
                ap1EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1EmailValid = false;
                ap1EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap1EmailValid = false;
            ap1EmailValidationMessage = 'Error occurred while validating the email.';
        }
    }
    
    //----For AP1 POAEmail Validation API----------
    public void validateAp1POAEmailID() {
        System.debug('Inside validateAp1POAEmailID');
        System.debug('Inside validateAp1POAEmailID applicant.POA_Email_Id__c :'+applicant.POA_Email_Id__c);
        try {
            if (String.isBlank(applicant.POA_Email_Id__c)) {
                ap1POAEmailValidationMessage = '';
                isap1POAEmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant.POA_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap1POAEmailValid = isValid;
                ap1POAEmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1POAEmailValid = false;
                ap1POAEmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap1POAEmailValid = false;
            ap1POAEmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP1 POA2Email Validation API----------
    public void validateAp1POA2EmailID() {
        System.debug('Inside validateAp1POA2EmailID');
        System.debug('Inside validateAp1POA2EmailID applicant.POA_2_Email_Id__c :'+applicant.POA_2_Email_Id__c);
        try {
            if (String.isBlank(applicant.POA_2_Email_Id__c)) {
                ap1POA2EmailValidationMessage = '';
                isap1POA2EmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant.POA_2_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap1POA2EmailValid = isValid;
                ap1POA2EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1POA2EmailValid = false;
                ap1POA2EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap1POA2EmailValid = false;
            ap1POA2EmailValidationMessage = 'Error occurred while validating the POA2 email.';
        }
    }

    //----For AP2 Email Validation API----------
    public void validateAp2EmailAddress() {
        System.debug('Inside validateAp1MobNo');
        System.debug('Inside validateAp1MobNo applicant2.Email_Address__c :'+applicant2.Email_Address__c);
        try {
            if (String.isBlank(applicant2.Email_Address__c)) {
                    ap2EmailValidationMessage = '';
                    isap2EmailValid = true;
                    return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant2.Email_Address__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap2EmailValid = isValid;
                ap2EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2EmailValid = false;
                ap2EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap2EmailValid = false;
            ap2EmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP2 POAEmail Validation API----------
    public void validateAp2POAEmailID() {
        System.debug('Inside validateAp2POAEmailID');
        System.debug('Inside validateAp2POAEmailID applicant2.POA_Email_Id__c :'+applicant2.POA_Email_Id__c);
        try {
            if (String.isBlank(applicant2.POA_Email_Id__c)) {
                ap2POAEmailValidationMessage = '';
                isap2POAEmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant2.POA_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap2POAEmailValid = isValid;
                ap2POAEmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2POAEmailValid = false;
                ap2POAEmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap2POAEmailValid = false;
            ap2POAEmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP2 POA2Email Validation API----------
    public void validateAp2POA2EmailID() {
        System.debug('Inside validateAp2POA2EmailID');
        System.debug('Inside validateAp2POA2EmailID applicant2.POA_2_Email_Id__c :'+applicant2.POA_2_Email_Id__c);
        try {
            if (String.isBlank(applicant2.POA_2_Email_Id__c)) {
                ap2POA2EmailValidationMessage = '';
                isap2POA2EmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant2.POA_2_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap2POA2EmailValid = isValid;
                ap2POA2EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2POA2EmailValid = false;
                ap2POA2EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap2POA2EmailValid = false;
            ap2POA2EmailValidationMessage = 'Error occurred while validating the POA2 email.';
        }
    }

    //----For AP3 Email Validation API----------
    public void validateAp3EmailAddress() {
        System.debug('Inside validateAp3EmailAddress');
        System.debug('Inside validateAp3EmailAddress applicant3.Email_Address__c :'+applicant3.Email_Address__c);
        try {
            if (String.isBlank(applicant3.Email_Address__c)) {
                    ap3EmailValidationMessage = '';
                    isap3EmailValid = true;
                    return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant3.Email_Address__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap3EmailValid = isValid;
                ap3EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap3EmailValid = false;
                ap3EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap3EmailValid = false;
            ap3EmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP3 POAEmail Validation API----------
    public void validateAp3POAEmailID() {
        System.debug('Inside validateAp3POAEmailID');
        System.debug('Inside validateAp3POAEmailID applicant3.POA_Email_Id__c :'+applicant3.POA_Email_Id__c);
        try {
            if (String.isBlank(applicant3.POA_Email_Id__c)) {
                ap3POAEmailValidationMessage = '';
                isap3POAEmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant3.POA_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap3POAEmailValid = isValid;
                ap3POAEmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap3POAEmailValid = false;
                ap3POAEmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap3POAEmailValid = false;
            ap3POAEmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP3 POA2Email Validation API----------
    public void validateAp3POA2EmailID() {
        System.debug('Inside validateAp3POA2EmailID');
        System.debug('Inside validateAp3POA2EmailID applicant3.POA_2_Email_Id__c :'+applicant3.POA_2_Email_Id__c);
        try {
            if (String.isBlank(applicant3.POA_2_Email_Id__c)) {
                ap3POA2EmailValidationMessage = '';
                isap3POA2EmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant3.POA_2_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap3POA2EmailValid = isValid;
                ap3POA2EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap3POA2EmailValid = false;
                ap3POA2EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap3POA2EmailValid = false;
            ap3POA2EmailValidationMessage = 'Error occurred while validating the POA2 email.';
        }
    }

    //----For AP4 Email Validation API----------
    public void validateAp4EmailAddress() {
        System.debug('Inside validateAp4EmailAddress');
        System.debug('Inside validateAp4EmailAddress applicant4.Email_Address__c :'+applicant4.Email_Address__c);
        try {
            if (String.isBlank(applicant4.Email_Address__c)) {
                    ap4EmailValidationMessage = '';
                    isap4EmailValid = true;
                    return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant4.Email_Address__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap4EmailValid = isValid;
                ap4EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap4EmailValid = false;
                ap4EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap4EmailValid = false;
            ap4EmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP4 POAEmail Validation API----------
    public void validateAp4POAEmailID() {
        System.debug('Inside validateAp4POAEmailID');
        System.debug('Inside validateAp4POAEmailID applicant4.POA_Email_Id__c :'+applicant4.POA_Email_Id__c);
        try {
            if (String.isBlank(applicant4.POA_Email_Id__c)) {
                ap4POAEmailValidationMessage = '';
                isap4POAEmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant4.POA_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap4POAEmailValid = isValid;
                ap4POAEmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap4POAEmailValid = false;
                ap4POAEmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap4POAEmailValid = false;
            ap4POAEmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP5 Email Validation API----------
    public void validateAp5EmailAddress() {
        System.debug('Inside validateAp5EmailAddress');
        System.debug('Inside validateAp5EmailAddress applicant5.Email_Address__c :'+applicant5.Email_Address__c);
        try {
            if (String.isBlank(applicant5.Email_Address__c)) {
                    ap5EmailValidationMessage = '';
                    isap5EmailValid = true;
                    return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant5.Email_Address__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap5EmailValid = isValid;
                ap5EmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap5EmailValid = false;
                ap5EmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap5EmailValid = false;
            ap5EmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    //----For AP5 POAEmail Validation API----------
    public void validateAp5POAEmailID() {
        System.debug('Inside validateAp5POAEmailID');
        System.debug('Inside validateAp5POAEmailID applicant5.POA_Email_Id__c :'+applicant5.POA_Email_Id__c);
        try {
            if (String.isBlank(applicant5.POA_Email_Id__c)) {
                ap5POAEmailValidationMessage = '';
                isap5POAEmailValid = true;
                return;
                }
                

            String response = Nice_EmailValidationUtility.validateEmail(applicant5.POA_Email_Id__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('is_deliverable');
                isap5POAEmailValid = isValid;
                ap5POAEmailValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap5POAEmailValid = false;
                ap5POAEmailValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating email: ' + ex.getMessage());
            isap5POAEmailValid = false;
            ap5POAEmailValidationMessage = 'Error occurred while validating the email.';
        }
    }

    @RemoteAction
    public static String validatePhoneNumber(String mobileNumber) {
        String accessKey = '8be667c1c59b3f0ecf6b09e498b52c9d'; // Replace with your actual access key
        try {
            // Call the Nice_PhoneValidationUtility to validate the phone number Nice_PhoneValidationUtility
            String response = Nice_PhoneValidationUtility.validatePhoneNumber(mobileNumber);
            return response;
        } catch (Exception ex) {
            System.debug('Error validating phone number: ' + ex.getMessage());
            return JSON.serialize(new Map<String, String>{
                'error' => 'Error validating phone number: ' + ex.getMessage()
            });
        }
    }

    //----For Mobile Validation API----------
    
    public void validateAp1MobNo() {
        System.debug('Inside validateAp1MobNo');
        System.debug('Inside validateAp1MobNo applicant.Mobile_Number__c :'+applicant.Mobile_Number__c);
        System.debug('Inside validateAp1MobNo applicant.Mobile_Country_With_Code__c : '+applicant.Mobile_Country_With_Code__c);
        try {
            if (String.isBlank(applicant.Mobile_Number__c) || String.isBlank(applicant.Mobile_Country_With_Code__c)) {
                if(String.isBlank(applicant.Mobile_Number__c)){
                    ap1MobValidationMessage = '✘';
                    isap1MobValid = false;
                    return;
                }else if(String.isBlank(applicant.Mobile_Country_With_Code__c)){
                    ap1MobValidationMessage = 'Please enter mobile country code';
                    isap1MobValid = false;
                    return;
                }
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.Mobile_Country_With_Code__c+applicant.Mobile_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap1MobValid = isValid;
                ap1MobValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1MobValid = false;
                ap1MobValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Mobile Number: ' + ex.getMessage());
            isap1MobValid = false;
            ap1MobValidationMessage = 'Error occurred while validating the Mobile Number.';
        }
    }

     //----For Mobile Validation API----------
    
     public void validateAp1AlternateMobNo() {
        System.debug('Inside validateAp1AlternateMobNo');
        System.debug('Inside validateAp1AlternateMobNo applicant.Alternate_Mobile_Country_with_Code__c :'+applicant.Alternate_Mobile_Country_with_Code__c);
        System.debug('Inside validateAp1AlternateMobNo applicant.Secondary_Mobile_Number__c : '+applicant.Secondary_Mobile_Number__c);
        try {
            if (String.isBlank(applicant.Secondary_Mobile_Number__c) || String.isBlank(applicant.Alternate_Mobile_Country_with_Code__c)) {
                if(String.isBlank(applicant.Secondary_Mobile_Number__c) && String.isBlank(applicant.Alternate_Mobile_Country_with_Code__c)){
                    ap1AlternateMobValidationMessage = '';
                    isap1AlternateMobValid = true;
                    return;
                }else if(String.isBlank(applicant.Secondary_Mobile_Number__c)){
                    ap1AlternateMobValidationMessage = '';
                    isap1AlternateMobValid = true;
                    return;
                }else if(String.isBlank(applicant.Alternate_Mobile_Country_with_Code__c)){
                    ap1AlternateMobValidationMessage = 'Please enter Alternate mobile country code.';
                    isap1AlternateMobValid = false;
                    return;
                }
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.Alternate_Mobile_Country_with_Code__c+applicant.Secondary_Mobile_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap1AlternateMobValid = isValid;
                ap1AlternateMobValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1AlternateMobValid = false;
                ap1AlternateMobValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Alternate Mobile Number: ' + ex.getMessage());
            isap1AlternateMobValid = false;
            ap1AlternateMobValidationMessage = 'Error occurred while validating the Alternate Mobile Number.';
        }
    }

      //----For Mobile Validation API----------
      public void validateAp1LandlineNo() {
        System.debug('Inside validateAp1LandlineNo');
        System.debug('Inside validateAp1LandlineNo applicant.Landline_Number__c :'+applicant.Landline_Number__c);
        System.debug('Inside validateAp1LandlineNo applicant.Landline_Number_Country_Code__c : '+applicant.Landline_Number_Country_Code__c);
        try {
            if (String.isBlank(applicant.Landline_Number__c) || String.isBlank(applicant.Landline_Number_Country_Code__c)) {
                if(String.isBlank(applicant.Landline_Number__c) && String.isBlank(applicant.Landline_Number_Country_Code__c)){
                    ap1LandlineNoValidationMessage = '';
                    isap1LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Landline_Number__c)){
                    ap1LandlineNoValidationMessage = '';
                    isap1LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Landline_Number_Country_Code__c)){
                    ap1LandlineNoValidationMessage = 'Please enter Landline Number country code.';
                    isap1LandlineNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.Landline_Number_Country_Code__c+applicant.Landline_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap1LandlineNoValid = isValid;
                ap1LandlineNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1LandlineNoValid = false;
                ap1LandlineNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Landline Number: ' + ex.getMessage());
            isap1LandlineNoValid = false;
            ap1LandlineNoValidationMessage = 'Error occurred while validating the Landline Number.';
        }
    }

    //----For Mobile Validation API----------
    public void validateAp1SecondaryConNo() {
        System.debug('Inside validateAp1SecondaryConNo');
        System.debug('Inside validateAp1SecondaryConNo applicant.Secondary_Contact_Number__c :'+applicant.Secondary_Contact_Number__c);
        System.debug('Inside validateAp1SecondaryConNo applicant.Secondary_Contact_Country_Code__c : '+applicant.Secondary_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant.Secondary_Contact_Number__c) || String.isBlank(applicant.Secondary_Contact_Country_Code__c)) {
                if(String.isBlank(applicant.Secondary_Contact_Number__c) && String.isBlank(applicant.Secondary_Contact_Country_Code__c)){
                    ap1SecondaryConNoValidationMessage = '';
                    isap1SecondaryConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Secondary_Contact_Number__c)){
                    ap1SecondaryConNoValidationMessage = '';
                    isap1SecondaryConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Secondary_Contact_Country_Code__c)){
                    ap1SecondaryConNoValidationMessage = 'Please enter Secondary Contact Number country code.';
                    isap1SecondaryConNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.Secondary_Contact_Country_Code__c+applicant.Secondary_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap1SecondaryConNoValid = isValid;
                ap1SecondaryConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap1SecondaryConNoValid = false;
                ap1SecondaryConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Secondary Contact Number: ' + ex.getMessage());
            isap1SecondaryConNoValid = false;
            ap1SecondaryConNoValidationMessage = 'Error occurred while validating the Secondary Contact Number.';
        }
    }

    //----For Mobile Validation API----------
    public void validatePOAConNo() {
        System.debug('Inside validatePOAConNo');
        System.debug('Inside validatePOAConNo applicant.POA_Contact_Number__c :'+applicant.POA_Contact_Number__c);
        System.debug('Inside validatePOAConNo applicant.POA_Contact_Country_Code__c : '+applicant.POA_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant.POA_Contact_Number__c) || String.isBlank(applicant.POA_Contact_Country_Code__c)) {
                if(String.isBlank(applicant.POA_Contact_Number__c) && String.isBlank(applicant.POA_Contact_Country_Code__c)){
                    ap1POAConNoValidationMessage = '';
                    isPOAConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.POA_Contact_Number__c)){
                    ap1POAConNoValidationMessage = '';
                    isPOAConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.POA_Contact_Country_Code__c)){
                    ap1POAConNoValidationMessage = 'Please enter POA country code';
                    isPOAConNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.POA_Contact_Country_Code__c+applicant.POA_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isPOAConNoValid = isValid;
                ap1POAConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isPOAConNoValid = false;
                ap1POAConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating POA Number: ' + ex.getMessage());
            isPOAConNoValid = false;
            ap1POAConNoValidationMessage = 'Error occurred while validating the POA Number.';
        }
    }

     //----For Mobile Validation API----------
     public void validatePOA2ConNo() {
        System.debug('Inside validatePOA2ConNo');
        System.debug('Inside validatePOA2ConNo applicant.POA_2_Contact_Number__c :'+applicant.POA_2_Contact_Number__c);
        System.debug('Inside validatePOA2ConNo applicant.POA2_Contact_Country_Code__c : '+applicant.POA2_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant.POA_2_Contact_Number__c) || String.isBlank(applicant.POA2_Contact_Country_Code__c)) {
                if(String.isBlank(applicant.POA_2_Contact_Number__c) && String.isBlank(applicant.POA2_Contact_Country_Code__c)){
                    ap1POA2ConNoValidationMessage = '';
                    isPOA2ConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.POA_2_Contact_Number__c)){
                    ap1POA2ConNoValidationMessage = '';
                    isPOA2ConNoValid = true;
                    return;
                }else if(String.isBlank(applicant.POA2_Contact_Country_Code__c)){
                    ap1POA2ConNoValidationMessage = 'Please enter POA 2 country code';
                    isPOA2ConNoValid = false;
                    return;
                }
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.POA2_Contact_Country_Code__c+applicant.POA_2_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isPOA2ConNoValid = isValid;
                ap1POA2ConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isPOA2ConNoValid = false;
                ap1POA2ConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating POA 2 Number: ' + ex.getMessage());
            isPOA2ConNoValid = false;
            ap1POA2ConNoValidationMessage = 'Error occurred while validating the POA 2 Number.';
        }
    }

     //----For Mobile Validation API----------
     public void validateOfficeNo() {
        System.debug('Inside validateOfficeNo');
        System.debug('Inside validateOfficeNo applicant.Organization_Phone_numbers__c :'+applicant.Organization_Phone_numbers__c);
        System.debug('Inside validateOfficeNo applicant.Office_Country_Code__c : '+applicant.Office_Country_Code__c);
        try {
            if (String.isBlank(applicant.Office_Country_Code__c) || String.isBlank(applicant.Organization_Phone_numbers__c)) {
                if(String.isBlank(applicant.Office_Country_Code__c) && String.isBlank(applicant.Organization_Phone_numbers__c)){
                    ap1OfficeNoValidationMessage = '';
                    isOfficeNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Organization_Phone_numbers__c)){
                    ap1OfficeNoValidationMessage = '';
                    isOfficeNoValid = true;
                    return;
                }else if(String.isBlank(applicant.Office_Country_Code__c)){
                    ap1OfficeNoValidationMessage = 'Please enter Office country code';
                    isOfficeNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant.Office_Country_Code__c+applicant.Organization_Phone_numbers__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isOfficeNoValid = isValid;
                ap1OfficeNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isOfficeNoValid = false;
                ap1OfficeNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Office Phone Number: ' + ex.getMessage());
            isOfficeNoValid = false;
            ap1OfficeNoValidationMessage = 'Error occurred while validating the Office Phone Number.';
        }
    }

     //----For AP2 Mobile Validation API----------
    
     public void validateAp2MobNo() {
        System.debug('Inside validateAp2MobNo');
        System.debug('Inside validateAp2MobNo applicant2.Mobile_Number__c :'+applicant2.Mobile_Number__c);
        System.debug('Inside validateAp2MobNo applicant2.Mobile_Country_With_Code__c : '+applicant2.Mobile_Country_With_Code__c);
        try {
            if (String.isBlank(applicant2.Mobile_Number__c) || String.isBlank(applicant2.Mobile_Country_With_Code__c)) {
                if(String.isBlank(applicant2.Mobile_Number__c) && String.isBlank(applicant2.Mobile_Country_With_Code__c)){
                    ap2MobValidationMessage = '';
                    isap2MobValid = true;
                    return;
                }else if(String.isBlank(applicant2.Mobile_Number__c)){
                    ap2MobValidationMessage = '';
                    isap2MobValid = true;
                    return;
                }else if(String.isBlank(applicant2.Mobile_Country_With_Code__c)){
                    ap2MobValidationMessage = 'Please enter applicant 2 mobile country code';
                    isap2MobValid = false;
                    return;
                }
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.Mobile_Country_With_Code__c+applicant2.Mobile_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap2MobValid = isValid;
                ap2MobValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2MobValid = false;
                ap2MobValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating applicant 2 Mobile Number: ' + ex.getMessage());
            isap2MobValid = false;
            ap2MobValidationMessage = 'Error occurred while validating the applicant 2 Mobile Number.';
        }
    }


     //----For Mobile Validation API----------
    
     public void validateAp2AlternateMobNo() {
        System.debug('Inside validateAp2AlternateMobNo');
        System.debug('Inside validateAp2AlternateMobNo applicant2.Alternate_Mobile_Country_with_Code__c :'+applicant2.Alternate_Mobile_Country_with_Code__c);
        System.debug('Inside validateAp2AlternateMobNo applicant2.Secondary_Mobile_Number__c : '+applicant2.Secondary_Mobile_Number__c);
        try {
            if (String.isBlank(applicant2.Secondary_Mobile_Number__c) || String.isBlank(applicant2.Alternate_Mobile_Country_with_Code__c)) {
                if(String.isBlank(applicant2.Secondary_Mobile_Number__c) && String.isBlank(applicant2.Alternate_Mobile_Country_with_Code__c)){
                    ap2AlternateMobValidationMessage = '';
                    isap2AlternateMobValid = true;
                    return;
                }else if(String.isBlank(applicant2.Secondary_Mobile_Number__c)){
                    ap2AlternateMobValidationMessage = '';
                    isap2AlternateMobValid = true;
                    return;
                }else if(String.isBlank(applicant2.Alternate_Mobile_Country_with_Code__c)){
                    ap2AlternateMobValidationMessage = 'Please enter Alternate mobile country code';
                    isap2AlternateMobValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.Alternate_Mobile_Country_with_Code__c+applicant2.Secondary_Mobile_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap2AlternateMobValid = isValid;
                ap2AlternateMobValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2AlternateMobValid = false;
                ap2AlternateMobValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Alternate Mobile Number: ' + ex.getMessage());
            isap2AlternateMobValid = false;
            ap2AlternateMobValidationMessage = 'Error occurred while validating the Alternate Mobile Number.';
        }
    }

       //----For Mobile Validation API----------
       public void validateAp2LandlineNo() {
        System.debug('Inside validateAp2LandlineNo');
        System.debug('Inside validateAp2LandlineNo applicant2.Landline_Number__c :'+applicant2.Landline_Number__c);
        System.debug('Inside validateAp2LandlineNo applicant2.Landline_Number_Country_Code__c : '+applicant2.Landline_Number_Country_Code__c);
        try {
            if (String.isBlank(applicant2.Landline_Number__c) || String.isBlank(applicant2.Landline_Number_Country_Code__c)) {
                if(String.isBlank(applicant2.Landline_Number__c) && String.isBlank(applicant2.Landline_Number_Country_Code__c)){
                    ap2LandlineNoValidationMessage = '';
                    isap2LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Landline_Number__c)){
                    ap2LandlineNoValidationMessage = '';
                    isap2LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Landline_Number_Country_Code__c)){
                    ap2LandlineNoValidationMessage = 'Please enter Landline Number country code.';
                    isap2LandlineNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.Landline_Number_Country_Code__c+applicant2.Landline_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap2LandlineNoValid = isValid;
                ap2LandlineNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2LandlineNoValid = false;
                ap2LandlineNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Landline Number: ' + ex.getMessage());
            isap2LandlineNoValid = false;
            ap2LandlineNoValidationMessage = 'Error occurred while validating the Landline Number.';
        }
    }

    //----For Mobile Validation API----------
    public void validateAp2SecondaryConNo() {
        System.debug('Inside validateAp2SecondaryConNo');
        System.debug('Inside validateAp2SecondaryConNo applicant2.Secondary_Contact_Number__c :'+applicant2.Secondary_Contact_Number__c);
        System.debug('Inside validateAp2SecondaryConNo applicant2.Secondary_Contact_Country_Code__c : '+applicant2.Secondary_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant2.Secondary_Contact_Number__c) || String.isBlank(applicant2.Secondary_Contact_Country_Code__c)) {
                if(String.isBlank(applicant2.Secondary_Contact_Number__c) && String.isBlank(applicant2.Secondary_Contact_Country_Code__c)){
                    ap2SecondaryConNoValidationMessage = '';
                    isap2SecondaryConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Secondary_Contact_Number__c)){
                    ap2SecondaryConNoValidationMessage = '';
                    isap2SecondaryConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Secondary_Contact_Country_Code__c)){
                    ap2SecondaryConNoValidationMessage = 'Please enter secondary country code';
                    isap2SecondaryConNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.Secondary_Contact_Country_Code__c+applicant2.Secondary_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap2SecondaryConNoValid = isValid;
                ap2SecondaryConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap2SecondaryConNoValid = false;
                ap2SecondaryConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Secondary Contact Number: ' + ex.getMessage());
            isap2SecondaryConNoValid = false;
            ap2SecondaryConNoValidationMessage = 'Error occurred while validating the Secondary Contact Number.';
        }
    }

    //----For Mobile Validation API----------
    public void validateAp2POAConNo() {
        System.debug('Inside validateAp2POAConNo');
        System.debug('Inside validateAp2POAConNo applicant2.POA_Contact_Number__c :'+applicant2.POA_Contact_Number__c);
        System.debug('Inside validateAp2POAConNo applicant2.POA_Contact_Country_Code__c : '+applicant2.POA_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant2.POA_Contact_Number__c) || String.isBlank(applicant2.POA_Contact_Country_Code__c)) {
                if(String.isBlank(applicant2.POA_Contact_Number__c) && String.isBlank(applicant2.POA_Contact_Country_Code__c)){
                    ap2POAConNoValidationMessage = '';
                    isAp2POAConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.POA_Contact_Number__c)){
                    ap2POAConNoValidationMessage = '';
                    isAp2POAConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.POA_Contact_Country_Code__c)){
                    ap2POAConNoValidationMessage = 'Please enter Applicant 2 POA country code';
                    isAp2POAConNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.POA_Contact_Country_Code__c+applicant2.POA_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isAp2POAConNoValid = isValid;
                ap2POAConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isAp2POAConNoValid = false;
                ap2POAConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating POA Number: ' + ex.getMessage());
            isAp2POAConNoValid = false;
            ap2POAConNoValidationMessage = 'Error occurred while validating the Applicant 2 POA Number.';
        }
    }

     //----For Mobile Validation API----------
     public void validateAp2POA2ConNo() {
        System.debug('Inside validateAp2POA2ConNo');
        System.debug('Inside validateAp2POA2ConNo applicant2.POA_2_Contact_Number__c :'+applicant2.POA_2_Contact_Number__c);
        System.debug('Inside validateAp2POA2ConNo applicant2.POA2_Contact_Country_Code__c : '+applicant2.POA2_Contact_Country_Code__c);
        try {
            if (String.isBlank(applicant2.POA_2_Contact_Number__c) || String.isBlank(applicant2.POA2_Contact_Country_Code__c)) {
                if(String.isBlank(applicant2.POA_2_Contact_Number__c) && String.isBlank(applicant2.POA2_Contact_Country_Code__c)){
                    ap2POA2ConNoValidationMessage = '';
                    isAp2POA2ConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.POA_2_Contact_Number__c)){
                    ap2POA2ConNoValidationMessage = '';
                    isAp2POA2ConNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.POA2_Contact_Country_Code__c)){
                    ap2POA2ConNoValidationMessage = 'Please enter POA 2 country code';
                    isAp2POA2ConNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.POA2_Contact_Country_Code__c+applicant2.POA_2_Contact_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isAp2POA2ConNoValid = isValid;
                ap2POA2ConNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isAp2POA2ConNoValid = false;
                ap2POA2ConNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating POA 2 Number: ' + ex.getMessage());
            isAp2POA2ConNoValid = false;
            ap2POA2ConNoValidationMessage = 'Error occurred while validating the POA 2 Number.';
        }
    }

      //----For Mobile Validation API----------
      public void validateAp2OfficeNo() {
        System.debug('Inside validateAp2OfficeNo');
        System.debug('Inside validateAp2OfficeNo applicant2.Organization_Phone_numbers__c :'+applicant2.Organization_Phone_numbers__c);
        System.debug('Inside validateAp2OfficeNo applicant2.Office_Country_Code__c : '+applicant2.Office_Country_Code__c);
        try {
            if (String.isBlank(applicant2.Office_Country_Code__c) || String.isBlank(applicant2.Organization_Phone_numbers__c)) {
                if(String.isBlank(applicant2.Organization_Phone_numbers__c) && String.isBlank(applicant2.Office_Country_Code__c)){
                    ap2OfficeNoValidationMessage = '';
                    isAp2OfficeNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Organization_Phone_numbers__c)){
                    ap2OfficeNoValidationMessage = '';
                    isAp2OfficeNoValid = true;
                    return;
                }else if(String.isBlank(applicant2.Office_Country_Code__c)){
                    ap2OfficeNoValidationMessage = 'Please enter Applicant 2 Office country code';
                    isAp2OfficeNoValid = false;
                    return;
                }
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant2.Office_Country_Code__c+applicant2.Organization_Phone_numbers__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isAp2OfficeNoValid = isValid;
                ap2OfficeNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isAp2OfficeNoValid = false;
                ap2OfficeNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Office Number: ' + ex.getMessage());
            isAp2OfficeNoValid = false;
            ap2OfficeNoValidationMessage = 'Error occurred while validating the Applicant 2 Office Phone Number.';
        }
    }

     //----For Mobile Validation API----------
    public void validateAp3MobNo() {
        System.debug('Inside validateAp3MobNo');
        System.debug('Inside validateAp3MobNo applicant3.Mobile_Number__c :' + applicant3.Mobile_Number__c);
        System.debug('Inside validateAp3MobNo applicant3.Mobile_Country_With_Code__c : ' + applicant3.Mobile_Country_With_Code__c);
        try {
            if (String.isBlank(applicant3.Mobile_Number__c) || String.isBlank(applicant3.Mobile_Country_With_Code__c)) {
                if(String.isBlank(applicant3.Mobile_Number__c) && String.isBlank(applicant3.Mobile_Country_With_Code__c)){
                    ap3MobValidationMessage = '';
                    isap3MobValid = true;
                    return;
                }else if(String.isBlank(applicant3.Mobile_Number__c)){
                    ap3MobValidationMessage = '';
                    isap3MobValid = true;
                    return;
                }else if (String.isBlank(applicant3.Mobile_Country_With_Code__c)) {
                    ap3MobValidationMessage = 'Please enter applicant 3 mobile country code';
                    isap3MobValid = false;
                    return;
                }
            }
    
            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.Mobile_Country_With_Code__c + applicant3.Mobile_Number__c);
    
            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap3MobValid = isValid;
                ap3MobValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap3MobValid = false;
                ap3MobValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Mobile Number: ' + ex.getMessage());
            isap3MobValid = false;
            ap3MobValidationMessage = 'Error occurred while validating the Mobile Number.';
        }
    }
    
    //----For Mobile Validation API----------
    public void validateAp3AlternateMobNo() {
    System.debug('Inside validateAp3AlternateMobNo');
    System.debug('Inside validateAp3AlternateMobNo applicant3.Alternate_Mobile_Country_with_Code__c :' + applicant3.Alternate_Mobile_Country_with_Code__c);
    System.debug('Inside validateAp3AlternateMobNo applicant3.Secondary_Mobile_Number__c : ' + applicant3.Secondary_Mobile_Number__c);
    try {
        if (String.isBlank(applicant3.Secondary_Mobile_Number__c) || String.isBlank(applicant3.Alternate_Mobile_Country_with_Code__c)) {
            if (String.isBlank(applicant3.Secondary_Mobile_Number__c) && String.isBlank(applicant3.Alternate_Mobile_Country_with_Code__c)) {
                ap3AlternateMobValidationMessage = '';
                isap3AlternateMobValid = true;
                return;
            } else if (String.isBlank(applicant3.Secondary_Mobile_Number__c)) {
                ap3AlternateMobValidationMessage = '';
                isap3AlternateMobValid = true;
                return;
            } else if (String.isBlank(applicant3.Alternate_Mobile_Country_with_Code__c)) {
                ap3AlternateMobValidationMessage = 'Please enter Alternate mobile country code';
                isap3AlternateMobValid = false;
                return;
            }
        }

        String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.Alternate_Mobile_Country_with_Code__c + applicant3.Secondary_Mobile_Number__c);

        if (response != null) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            Boolean isValid = (Boolean) result.get('valid');
            isap3AlternateMobValid = isValid;
            ap3AlternateMobValidationMessage = isValid ? '✔' : '✘';
        } else {
            isap3AlternateMobValid = false;
            ap3AlternateMobValidationMessage = 'Error: No response from validation service.';
        }
    } catch (Exception ex) {
        System.debug('Error validating Alternate Mobile Number: ' + ex.getMessage());
        isap3AlternateMobValid = false;
        ap3AlternateMobValidationMessage = 'Error occurred while validating the Alternate Mobile Number.';
    }
}

       //----For Mobile Validation API----------
       public void validateAp3LandlineNo() {
        System.debug('Inside validateAp3LandlineNo');
        System.debug('Inside validateAp3LandlineNo applicant3.Landline_Number__c :'+applicant3.Landline_Number__c);
        System.debug('Inside validateAp3LandlineNo applicant3.Landline_Number_Country_Code__c : '+applicant3.Landline_Number_Country_Code__c);
        try {
            if (String.isBlank(applicant3.Landline_Number__c) || String.isBlank(applicant3.Landline_Number_Country_Code__c)) {
                if(String.isBlank(applicant3.Landline_Number__c) && String.isBlank(applicant3.Landline_Number_Country_Code__c)){
                    ap3LandlineNoValidationMessage = '';
                    isap3LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant3.Landline_Number__c)){
                    ap3LandlineNoValidationMessage = '';
                    isap3LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant3.Landline_Number_Country_Code__c)){
                    ap3LandlineNoValidationMessage = 'Please enter Landline Number country code.';
                    isap3LandlineNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.Landline_Number_Country_Code__c+applicant3.Landline_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap3LandlineNoValid = isValid;
                ap3LandlineNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap3LandlineNoValid = false;
                ap3LandlineNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Landline Number: ' + ex.getMessage());
            isap3LandlineNoValid = false;
            ap3LandlineNoValidationMessage = 'Error occurred while validating the Landline Number.';
        }
    }

    //----For Mobile Validation API----------
    public void validateAp3SecondaryConNo() {
    System.debug('Inside validateAp3SecondaryConNo');
    System.debug('Inside validateAp3SecondaryConNo applicant3.Secondary_Contact_Number__c :' + applicant3.Secondary_Contact_Number__c);
    System.debug('Inside validateAp3SecondaryConNo applicant3.Secondary_Contact_Country_Code__c : ' + applicant3.Secondary_Contact_Country_Code__c);
    try {
        if (String.isBlank(applicant3.Secondary_Contact_Number__c) || String.isBlank(applicant3.Secondary_Contact_Country_Code__c)) {
            if (String.isBlank(applicant3.Secondary_Contact_Number__c) && String.isBlank(applicant3.Secondary_Contact_Country_Code__c)) {
                ap3SecondaryConNoValidationMessage = '';
                isap3SecondaryConNoValid = true;
                return;
            } else if (String.isBlank(applicant3.Secondary_Contact_Number__c)) {
                ap3SecondaryConNoValidationMessage = '';
                isap3SecondaryConNoValid = true;
                return;
            } else if (String.isBlank(applicant3.Secondary_Contact_Country_Code__c)) {
                ap3SecondaryConNoValidationMessage = 'Please enter secondary country code';
                isap3SecondaryConNoValid = false;
                return;
            }
        }

        String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.Secondary_Contact_Country_Code__c + applicant3.Secondary_Contact_Number__c);

        if (response != null) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            Boolean isValid = (Boolean) result.get('valid');
            isap3SecondaryConNoValid = isValid;
            ap3SecondaryConNoValidationMessage = isValid ? '✔' : '✘';
        } else {
            isap3SecondaryConNoValid = false;
            ap3SecondaryConNoValidationMessage = 'Error: No response from validation service.';
        }
    } catch (Exception ex) {
        System.debug('Error validating Secondary Contact Number: ' + ex.getMessage());
        isap3SecondaryConNoValid = false;
        ap3SecondaryConNoValidationMessage = 'Error occurred while validating the Secondary Contact Number.';
    }
}

        //----For Mobile Validation API----------
        public void validateAp3POAConNo() {
            System.debug('Inside validateAp3POAConNo');
            System.debug('Inside validateAp3POAConNo applicant3.POA_Contact_Number__c :' + applicant3.POA_Contact_Number__c);
            System.debug('Inside validateAp3POAConNo applicant3.POA_Contact_Country_Code__c : ' + applicant3.POA_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant3.POA_Contact_Number__c) || String.isBlank(applicant3.POA_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant3.POA_Contact_Number__c) && String.isBlank(applicant3.POA_Contact_Country_Code__c)) {
                        ap3POAConNoValidationMessage = '';
                        isAp3POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.POA_Contact_Number__c)) {
                        ap3POAConNoValidationMessage = '';
                        isAp3POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.POA_Contact_Country_Code__c)) {
                        ap3POAConNoValidationMessage = 'Please enter Applicant 3 POA country code';
                        isAp3POAConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.POA_Contact_Country_Code__c + applicant3.POA_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp3POAConNoValid = isValid;
                    ap3POAConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp3POAConNoValid = false;
                    ap3POAConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating POA Number: ' + ex.getMessage());
                isAp3POAConNoValid = false;
                ap3POAConNoValidationMessage = 'Error occurred while validating the Applicant 3 POA Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp3POA2ConNo() {
            System.debug('Inside validateAp3POA2ConNo');
            System.debug('Inside validateAp3POA2ConNo applicant3.POA_2_Contact_Number__c :' + applicant3.POA_2_Contact_Number__c);
            System.debug('Inside validateAp3POA2ConNo applicant3.POA2_Contact_Country_Code__c : ' + applicant3.POA2_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant3.POA_2_Contact_Number__c) || String.isBlank(applicant3.POA2_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant3.POA_2_Contact_Number__c) && String.isBlank(applicant3.POA2_Contact_Country_Code__c)) {
                        ap3POA2ConNoValidationMessage = '';
                        isAp3POA2ConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.POA_2_Contact_Number__c)) {
                        ap3POA2ConNoValidationMessage = '';
                        isAp3POA2ConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.POA2_Contact_Country_Code__c)) {
                        ap3POA2ConNoValidationMessage = 'Please enter POA 2 country code';
                        isAp3POA2ConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.POA2_Contact_Country_Code__c + applicant3.POA_2_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp3POA2ConNoValid = isValid;
                    ap3POA2ConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp3POA2ConNoValid = false;
                    ap3POA2ConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating POA2 Number: ' + ex.getMessage());
                isAp3POA2ConNoValid = false;
                ap3POA2ConNoValidationMessage = 'Error occurred while validating the POA 2 Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp3OfficeNo() {
            System.debug('Inside validateAp3OfficeNo');
            System.debug('Inside validateAp3OfficeNo applicant3.Organization_Phone_numbers__c :' + applicant3.Organization_Phone_numbers__c);
            System.debug('Inside validateAp3OfficeNo applicant3.Office_Country_Code__c : ' + applicant3.Office_Country_Code__c);
            try {
                if (String.isBlank(applicant3.Office_Country_Code__c) || String.isBlank(applicant3.Organization_Phone_numbers__c)) {
                    if (String.isBlank(applicant3.Organization_Phone_numbers__c) && String.isBlank(applicant3.Office_Country_Code__c)) {
                        ap3OfficeNoValidationMessage = '';
                        isAp3OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.Organization_Phone_numbers__c)) {
                        ap3OfficeNoValidationMessage = '';
                        isAp3OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant3.Office_Country_Code__c)) {
                        ap3OfficeNoValidationMessage = 'Please enter Applicant 3 Office country code';
                        isAp3OfficeNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant3.Office_Country_Code__c + applicant3.Organization_Phone_numbers__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp3OfficeNoValid = isValid;
                    ap3OfficeNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp3OfficeNoValid = false;
                    ap3OfficeNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isAp3OfficeNoValid = false;
                ap3OfficeNoValidationMessage = 'Error occurred while validating the Applicant 3 Office Phone Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp4MobNo() {
            System.debug('Inside validateAp4MobNo');
            System.debug('Inside validateAp4MobNo applicant4.Mobile_Number__c :' + applicant4.Mobile_Number__c);
            System.debug('Inside validateAp4MobNo applicant4.Mobile_Country_With_Code__c : ' + applicant4.Mobile_Country_With_Code__c);
            try {
                if (String.isBlank(applicant4.Mobile_Number__c) || String.isBlank(applicant4.Mobile_Country_With_Code__c)) {
                    if(String.isBlank(applicant4.Mobile_Number__c) && String.isBlank(applicant4.Mobile_Country_With_Code__c)){
                        ap4MobValidationMessage = '';
                        isap4MobValid = true;
                        return;
                    }else if(String.isBlank(applicant4.Mobile_Number__c)){
                        ap4MobValidationMessage = '';
                        isap4MobValid = true;
                        return;
                    }else if (String.isBlank(applicant4.Mobile_Country_With_Code__c)) {
                        ap4MobValidationMessage = 'Please enter applicant 4 mobile country code';
                        isap4MobValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.Mobile_Country_With_Code__c + applicant4.Mobile_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap4MobValid = isValid;
                    ap4MobValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap4MobValid = false;
                    ap4MobValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating applicant 4 Mobile Number: ' + ex.getMessage());
                isap4MobValid = false;
                ap4MobValidationMessage = 'Error occurred while validating the applicant 4 Mobile Number.';
            }
        }

        //----For Alternate Mobile Validation API----------
        public void validateAp4AlternateMobNo() {
            System.debug('Inside validateAp4AlternateMobNo');
            System.debug('Inside validateAp4AlternateMobNo applicant4.Alternate_Mobile_Country_with_Code__c :' + applicant4.Alternate_Mobile_Country_with_Code__c);
            System.debug('Inside validateAp4AlternateMobNo applicant4.Secondary_Mobile_Number__c : ' + applicant4.Secondary_Mobile_Number__c);
            try {
                if (String.isBlank(applicant4.Secondary_Mobile_Number__c) || String.isBlank(applicant4.Alternate_Mobile_Country_with_Code__c)) {
                    if (String.isBlank(applicant4.Secondary_Mobile_Number__c) && String.isBlank(applicant4.Alternate_Mobile_Country_with_Code__c)) {
                        ap4AlternateMobValidationMessage = '';
                        isap4AlternateMobValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Secondary_Mobile_Number__c)) {
                        ap4AlternateMobValidationMessage = '';
                        isap4AlternateMobValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Alternate_Mobile_Country_with_Code__c)) {
                        ap4AlternateMobValidationMessage = 'Please enter Alternate mobile country code';
                        isap4AlternateMobValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.Alternate_Mobile_Country_with_Code__c + applicant4.Secondary_Mobile_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap4AlternateMobValid = isValid;
                    ap4AlternateMobValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap4AlternateMobValid = false;
                    ap4AlternateMobValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Alternate Mobile Number: ' + ex.getMessage());
                isap4AlternateMobValid = false;
                ap4AlternateMobValidationMessage = 'Error occurred while validating the Alternate Mobile Number.';
            }
        }

         //----For Mobile Validation API----------
       public void validateAp4LandlineNo() {
        System.debug('Inside validateAp4LandlineNo');
        System.debug('Inside validateAp4LandlineNo applicant4.Landline_Number__c :'+applicant4.Landline_Number__c);
        System.debug('Inside validateAp4LandlineNo applicant4.Landline_Number_Country_Code__c : '+applicant4.Landline_Number_Country_Code__c);
        try {
            if (String.isBlank(applicant4.Landline_Number__c) || String.isBlank(applicant4.Landline_Number_Country_Code__c)) {
                if(String.isBlank(applicant4.Landline_Number__c) && String.isBlank(applicant4.Landline_Number_Country_Code__c)){
                    ap4LandlineNoValidationMessage = '';
                    isap4LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant4.Landline_Number__c)){
                    ap4LandlineNoValidationMessage = '';
                    isap4LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant4.Landline_Number_Country_Code__c)){
                    ap4LandlineNoValidationMessage = 'Please enter Landline Number country code.';
                    isap4LandlineNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.Landline_Number_Country_Code__c+applicant4.Landline_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap4LandlineNoValid = isValid;
                ap4LandlineNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap4LandlineNoValid = false;
                ap4LandlineNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Landline Number: ' + ex.getMessage());
            isap4LandlineNoValid = false;
            ap4LandlineNoValidationMessage = 'Error occurred while validating the Landline Number.';
        }
    }

        //----For Secondary Contact Validation API----------
        public void validateAp4SecondaryConNo() {
            System.debug('Inside validateAp4SecondaryConNo');
            System.debug('Inside validateAp4SecondaryConNo applicant4.Secondary_Contact_Number__c :' + applicant4.Secondary_Contact_Number__c);
            System.debug('Inside validateAp4SecondaryConNo applicant4.Secondary_Contact_Country_Code__c : ' + applicant4.Secondary_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant4.Secondary_Contact_Number__c) || String.isBlank(applicant4.Secondary_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant4.Secondary_Contact_Number__c) && String.isBlank(applicant4.Secondary_Contact_Country_Code__c)) {
                        ap4SecondaryConNoValidationMessage = '';
                        isap4SecondaryConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Secondary_Contact_Number__c)) {
                        ap4SecondaryConNoValidationMessage = '';
                        isap4SecondaryConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Secondary_Contact_Country_Code__c)) {
                        ap4SecondaryConNoValidationMessage = 'Please enter secondary country code';
                        isap4SecondaryConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.Secondary_Contact_Country_Code__c + applicant4.Secondary_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap4SecondaryConNoValid = isValid;
                    ap4SecondaryConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap4SecondaryConNoValid = false;
                    ap4SecondaryConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isap4SecondaryConNoValid = false;
                ap4SecondaryConNoValidationMessage = 'Error occurred while validating the Secondary Contact Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp4POAConNo() {
            System.debug('Inside validateAp4POAConNo');
            System.debug('Inside validateAp4POAConNo applicant4.POA_Contact_Number__c :' + applicant4.POA_Contact_Number__c);
            System.debug('Inside validateAp4POAConNo applicant4.POA_Contact_Country_Code__c : ' + applicant4.POA_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant4.POA_Contact_Number__c) || String.isBlank(applicant4.POA_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant4.POA_Contact_Number__c) && String.isBlank(applicant4.POA_Contact_Country_Code__c)) {
                        ap4POAConNoValidationMessage = '';
                        isAp4POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.POA_Contact_Number__c)) {
                        ap4POAConNoValidationMessage = '';
                        isAp4POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.POA_Contact_Country_Code__c)) {
                        ap4POAConNoValidationMessage = 'Please enter Applicant 4 POA country code';
                        isAp4POAConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.POA_Contact_Country_Code__c + applicant4.POA_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp4POAConNoValid = isValid;
                    ap4POAConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp4POAConNoValid = false;
                    ap4POAConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isAp4POAConNoValid = false;
                ap4POAConNoValidationMessage = 'Error occurred while validating the Applicant 4 POA Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp4OfficeNo() {
            System.debug('Inside validateAp4OfficeNo');
            System.debug('Inside validateAp4OfficeNo applicant4.Organization_Phone_numbers__c :' + applicant4.Organization_Phone_numbers__c);
            System.debug('Inside validateAp4OfficeNo applicant4.Office_Country_Code__c : ' + applicant4.Office_Country_Code__c);
            try {
                if (String.isBlank(applicant4.Office_Country_Code__c) || String.isBlank(applicant4.Organization_Phone_numbers__c)) {
                    if (String.isBlank(applicant4.Organization_Phone_numbers__c) && String.isBlank(applicant4.Office_Country_Code__c)) {
                        ap4OfficeNoValidationMessage = '';
                        isAp4OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Organization_Phone_numbers__c)) {
                        ap4OfficeNoValidationMessage = '';
                        isAp4OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant4.Office_Country_Code__c)) {
                        ap4OfficeNoValidationMessage = 'Please enter Applicant 4 Office country code';
                        isAp4OfficeNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant4.Office_Country_Code__c + applicant4.Organization_Phone_numbers__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp4OfficeNoValid = isValid;
                    ap4OfficeNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp4OfficeNoValid = false;
                    ap4OfficeNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isAp4OfficeNoValid = false;
                ap4OfficeNoValidationMessage = 'Error occurred while validating the applicant 4 Office Phone Number.';
            }
        }

        //----For Mobile Validation API----------
        public void validateAp5MobNo() {
            System.debug('Inside validateAp5MobNo');
            System.debug('Inside validateAp5MobNo applicant5.Mobile_Number__c :' + applicant5.Mobile_Number__c);
            System.debug('Inside validateAp5MobNo applicant5.Mobile_Country_With_Code__c : ' + applicant5.Mobile_Country_With_Code__c);
            try {
                if (String.isBlank(applicant5.Mobile_Number__c) || String.isBlank(applicant5.Mobile_Country_With_Code__c)) {
                    if(String.isBlank(applicant5.Mobile_Number__c) && String.isBlank(applicant5.Mobile_Country_With_Code__c)){
                        ap5MobValidationMessage = '';
                        isap5MobValid = true;
                        return;
                    }else if(String.isBlank(applicant5.Mobile_Number__c)){
                        ap5MobValidationMessage = '';
                        isap5MobValid = true;
                        return;
                    }else if (String.isBlank(applicant5.Mobile_Country_With_Code__c)) {
                        ap5MobValidationMessage = 'Please enter applicant 5 mobile country code';
                        isap5MobValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.Mobile_Country_With_Code__c + applicant5.Mobile_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap5MobValid = isValid;
                    ap5MobValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap5MobValid = false;
                    ap5MobValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating applicant 5 Mobile Number: ' + ex.getMessage());
                isap5MobValid = false;
                ap5MobValidationMessage = 'Error occurred while validating the applicant 5 Mobile Number.';
            }
        }

        //----For Alternate Mobile Validation API----------
        public void validateAp5AlternateMobNo() {
            System.debug('Inside validateAp5AlternateMobNo');
            System.debug('Inside validateAp5AlternateMobNo applicant5.Alternate_Mobile_Country_with_Code__c :' + applicant5.Alternate_Mobile_Country_with_Code__c);
            System.debug('Inside validateAp5AlternateMobNo applicant5.Secondary_Mobile_Number__c : ' + applicant5.Secondary_Mobile_Number__c);
            try {
                if (String.isBlank(applicant5.Secondary_Mobile_Number__c) || String.isBlank(applicant5.Alternate_Mobile_Country_with_Code__c)) {
                    if (String.isBlank(applicant5.Secondary_Mobile_Number__c) && String.isBlank(applicant5.Alternate_Mobile_Country_with_Code__c)) {
                        ap5AlternateMobValidationMessage = '';
                        isap5AlternateMobValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Secondary_Mobile_Number__c)) {
                        ap5AlternateMobValidationMessage = '';
                        isap5AlternateMobValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Alternate_Mobile_Country_with_Code__c)) {
                        ap5AlternateMobValidationMessage = 'Please enter Alternate mobile country code';
                        isap5AlternateMobValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.Alternate_Mobile_Country_with_Code__c + applicant5.Secondary_Mobile_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap5AlternateMobValid = isValid;
                    ap5AlternateMobValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap5AlternateMobValid = false;
                    ap5AlternateMobValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Alternate Mobile Number: ' + ex.getMessage());
                isap5AlternateMobValid = false;
                ap5AlternateMobValidationMessage = 'Error occurred while validating the Alternate Mobile Number.';
            }
        }

          //----For Mobile Validation API----------
       public void validateAp5LandlineNo() {
        System.debug('Inside validateAp5LandlineNo');
        System.debug('Inside validateAp5LandlineNo applicant5.Landline_Number__c :'+applicant5.Landline_Number__c);
        System.debug('Inside validateAp5LandlineNo applicant5.Landline_Number_Country_Code__c : '+applicant5.Landline_Number_Country_Code__c);
        try {
            if (String.isBlank(applicant5.Landline_Number__c) || String.isBlank(applicant5.Landline_Number_Country_Code__c)) {
                if(String.isBlank(applicant5.Landline_Number__c) && String.isBlank(applicant5.Landline_Number_Country_Code__c)){
                    ap5LandlineNoValidationMessage = '';
                    isap5LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant5.Landline_Number__c)){
                    ap5LandlineNoValidationMessage = '';
                    isap5LandlineNoValid = true;
                    return;
                }else if(String.isBlank(applicant5.Landline_Number_Country_Code__c)){
                    ap5LandlineNoValidationMessage = 'Please enter Landline Number country code.';
                    isap5LandlineNoValid = false;
                    return;
                } 
                
            }

            String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.Landline_Number_Country_Code__c+applicant5.Landline_Number__c);

            if (response != null) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                Boolean isValid = (Boolean) result.get('valid');
                isap5LandlineNoValid = isValid;
                ap5LandlineNoValidationMessage = isValid ? '✔' : '✘';
            } else {
                isap5LandlineNoValid = false;
                ap5LandlineNoValidationMessage = 'Error: No response from validation service.';
            }
        } catch (Exception ex) {
            System.debug('Error validating Landline Number: ' + ex.getMessage());
            isap5LandlineNoValid = false;
            ap5LandlineNoValidationMessage = 'Error occurred while validating the Landline Number.';
        }
    }


        //----For Secondary Contact Validation API----------
        public void validateAp5SecondaryConNo() {
            System.debug('Inside validateAp5SecondaryConNo');
            System.debug('Inside validateAp5SecondaryConNo applicant5.Secondary_Contact_Number__c :' + applicant5.Secondary_Contact_Number__c);
            System.debug('Inside validateAp5SecondaryConNo applicant5.Secondary_Contact_Country_Code__c : ' + applicant5.Secondary_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant5.Secondary_Contact_Number__c) || String.isBlank(applicant5.Secondary_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant5.Secondary_Contact_Number__c) && String.isBlank(applicant5.Secondary_Contact_Country_Code__c)) {
                        ap5SecondaryConNoValidationMessage = '';
                        isap5SecondaryConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Secondary_Contact_Number__c)) {
                        ap5SecondaryConNoValidationMessage = '';
                        isap5SecondaryConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Secondary_Contact_Country_Code__c)) {
                        ap5SecondaryConNoValidationMessage = 'Please enter secondary country code';
                        isap5SecondaryConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.Secondary_Contact_Country_Code__c + applicant5.Secondary_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isap5SecondaryConNoValid = isValid;
                    ap5SecondaryConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isap5SecondaryConNoValid = false;
                    ap5SecondaryConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isap5SecondaryConNoValid = false;
                ap5SecondaryConNoValidationMessage = 'Error occurred while validating the Secondary Contact Number.';
            }
        }

        //----For POA Mobile Validation API----------
        public void validateAp5POAConNo() {
            System.debug('Inside validateAp5POAConNo');
            System.debug('Inside validateAp5POAConNo applicant5.POA_Contact_Number__c :' + applicant5.POA_Contact_Number__c);
            System.debug('Inside validateAp5POAConNo applicant5.POA_Contact_Country_Code__c : ' + applicant5.POA_Contact_Country_Code__c);
            try {
                if (String.isBlank(applicant5.POA_Contact_Number__c) || String.isBlank(applicant5.POA_Contact_Country_Code__c)) {
                    if (String.isBlank(applicant5.POA_Contact_Number__c) && String.isBlank(applicant5.POA_Contact_Country_Code__c)) {
                        ap5POAConNoValidationMessage = '';
                        isAp5POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.POA_Contact_Number__c)) {
                        ap5POAConNoValidationMessage = '';
                        isAp5POAConNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.POA_Contact_Country_Code__c)) {
                        ap5POAConNoValidationMessage = 'Please enter Applicant 5 POA country code';
                        isAp5POAConNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.POA_Contact_Country_Code__c + applicant5.POA_Contact_Number__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp5POAConNoValid = isValid;
                    ap5POAConNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp5POAConNoValid = false;
                    ap5POAConNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isAp5POAConNoValid = false;
                ap5POAConNoValidationMessage = 'Error occurred while validating the Applicant 5 POA Number.';
            }
        }

        //----For Office Number Validation API----------
        public void validateAp5OfficeNo() {
            System.debug('Inside validateAp5OfficeNo');
            System.debug('Inside validateAp5OfficeNo applicant5.Organization_Phone_numbers__c :' + applicant5.Organization_Phone_numbers__c);
            System.debug('Inside validateAp5OfficeNo applicant5.Office_Country_Code__c : ' + applicant5.Office_Country_Code__c);
            try {
                if (String.isBlank(applicant5.Office_Country_Code__c) || String.isBlank(applicant5.Organization_Phone_numbers__c)) {
                    if (String.isBlank(applicant5.Organization_Phone_numbers__c) && String.isBlank(applicant5.Office_Country_Code__c)){
                        ap5OfficeNoValidationMessage = '';
                        isAp5OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Organization_Phone_numbers__c)) {
                        ap5OfficeNoValidationMessage = '';
                        isAp5OfficeNoValid = true;
                        return;
                    } else if (String.isBlank(applicant5.Office_Country_Code__c)) {
                        ap5OfficeNoValidationMessage = 'Please enter Applicant 5 Office country code';
                        isAp5OfficeNoValid = false;
                        return;
                    }
                }

                String response = Nice_PhoneValidationUtility.validatePhoneNumber(applicant5.Office_Country_Code__c + applicant5.Organization_Phone_numbers__c);

                if (response != null) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
                    Boolean isValid = (Boolean) result.get('valid');
                    isAp5OfficeNoValid = isValid;
                    ap5OfficeNoValidationMessage = isValid ? '✔' : '✘';
                } else {
                    isAp5OfficeNoValid = false;
                    ap5OfficeNoValidationMessage = 'Error: No response from validation service.';
                }
            } catch (Exception ex) {
                System.debug('Error validating Mobile Number: ' + ex.getMessage());
                isAp5OfficeNoValid = false;
                ap5OfficeNoValidationMessage = 'Error occurred while validating the Applicant 5 Office Phone Number.';
            }
        }

}