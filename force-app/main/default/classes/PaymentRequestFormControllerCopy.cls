public without sharing class PaymentRequestFormControllerCopy {
    public static boolean PaymentRequestTriggerFirstRunFlag = true;
    
    @InvocableMethod (label='Update Unit')
    public static void updateUnit (List<Id> prList){
        Payment_Request__c pr = [select Id, Property__c from Payment_Request__c where Id =: prList[0]];
        list<PropStrength__Property__c> uList = [select Id from PropStrength__Property__c where Id =: pr.Property__c and PropStrength__Unit_Status__c = 'Available'];
        if(uList.size() > 0){
            PropStrength__Property__c u = new PropStrength__Property__c();
            u.Id = pr.Property__c;
            u.PropStrength__Unit_Status__c = 'HOLD';
            update u;   
        }
    }

    @AuraEnabled
    public static UnitDetailsWrapper unitDetails(string unitId){
        UnitDetailsWrapper wrapObj = new UnitDetailsWrapper();
        PropStrength__Property__c u = [select Id, PropStrength__Tower__c, PropStrength__Tower__r.ESCROW_Account__c,PropStrength__Tower__r.ESCROW_Account__r.Name,For_Direct_Sale__c, PropStrength__Tower__r.PropStrength__Tower_Name__c,PropStrength__Project_Name__c,PropStrength__Project_Name__r.Name from PropStrength__Property__c where Id =: unitId];
        if(u.PropStrength__Tower__c!=null && u.PropStrength__Tower__r.ESCROW_Account__c != null){ wrapObj.unitkey = u.PropStrength__Project_Name__r.Name+'-'+u.PropStrength__Tower__r.PropStrength__Tower_Name__c+'@@'+u.PropStrength__Tower__r.ESCROW_Account__r.Name;
        }
        else{
            wrapObj.unitkey = u.PropStrength__Project_Name__r.Name+'-'+u.PropStrength__Tower__r.PropStrength__Tower_Name__c+'@@ESCROW Account not mapped, Please select Corporate Account.';
        }
        wrapObj.onDirectSale = u.For_Direct_Sale__c;
        List<Payment_Request__c> approvedPr = [SELECT ID, Lead_Source_Category__c,Lead_Source_Sub_Category__c FROM Payment_Request__c where status__c = 'Approved' and Property__c =: unitId  order by createddate desc limit 1];
        if(approvedPr.size() > 0)
        wrapObj.approvedPR = approvedPr[0];
        return wrapObj;
    }

    @AuraEnabled
    public static PropStrength__Application_Booking__c getContactRecFromBooking(string bookingIdRec){
        if(bookingIdRec != null 
           && bookingIdRec != '') {
            return [SELECT Id, Name,PropStrength__Property__c,PropStrength__Property__r.PropStrength__Tower__c,PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c,PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__r.Name,DLD_Outstanding__c,Income_Charge_Outstanding_Without_DLD__c,PropStrength__Outstanding_Balance__c, PropStrength__Booking_Request__r.PropStrength__Request_Source__c,PropStrength__Booking_Request__r.Type_of_Enquiry__c, Termination_Process_Status__c, PropStrength__Primary_Customer__c, PropStrength__Primary_Customer__r.MobilePhone, PropStrength__Primary_Customer__r.Name, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.Passport_No__c, PropStrength__Primary_Customer__r.Emirates_ID__c FROM PropStrength__Application_Booking__c WHERE Id = :bookingIdRec];
        }
        return null;
    }

    @AuraEnabled
    public static Decimal getAllowedAmountVal(String othercharge, String bookId, Boolean mode){
        System.debug(othercharge);
        PropStrength__Application_Booking__c booking = [SELECT Id, PropStrength__Project__c, PropStrength__Super_Area__c, 
                                                        (SELECT Id, PropStrength__Balance__c, PropStrength__Payment_Date__c, RecordType.Name, 
                                                        PropStrength__Amount__c, PropStrength__Payment_Type__c FROM PropStrength__Payments_Cheques__r 
                                                        WHERE (RecordType.Name = 'Income Charge Due' OR RecordType.Name = 'Income Charge Received') 
                                                        AND (PropStrength__Amount_Due_Type__c = :othercharge OR Charge_Type__c = :othercharge))
                                                        FROM PropStrength__Application_Booking__c WHERE Id = :bookId];

        PropStrength__Projects__c projectRec = [SELECT Id, 
                                                (SELECT Id, PropStrength__Category__c, PropStrength__Type__c, PropStrength__Amount__c, 
                                                PropStrength__Rate_Per_Unit_Area__c, Max_Cap_AED__c , RecordType.Name 
                                                FROM PropStrength__Income_Charges__r 
                                                WHERE PropStrength__Active__c = TRUE AND PropStrength__Category__c = :othercharge) 
                                                FROM PropStrength__Projects__c WHERE Id = :booking.PropStrength__Project__c];
        
        Decimal allowedAmount = 0;
        Boolean flag = true;

        if(!booking.PropStrength__Payments_Cheques__r.isEmpty()) {
            for(PropStrength__Received_Payment__c payRec : booking.PropStrength__Payments_Cheques__r) {
                if(payRec.RecordType.Name == 'Income Charge Due' && payRec.PropStrength__Balance__c != null) {
                    allowedAmount += payRec.PropStrength__Balance__c;
                    flag = false;
                }
            }
        } 
        if((allowedAmount == 0 || flag) && !projectRec.PropStrength__Income_Charges__r.isEmpty()) {
            PropStrength__Income_Charges__c inc = projectRec.PropStrength__Income_Charges__r[0];
            if(inc.Max_Cap_AED__c != null && inc.Max_Cap_AED__c > 0) {Decimal deductedAmt = 0;
                for(PropStrength__Received_Payment__c payRec : booking.PropStrength__Payments_Cheques__r) { if(payRec.RecordType.Name == 'Income Charge Received' && payRec.PropStrength__Amount__c != null && payRec.PropStrength__Amount__c > 0) { deductedAmt += payRec.PropStrength__Amount__c;
                    }
                }
                allowedAmount += inc.Max_Cap_AED__c;allowedAmount -= deductedAmt;
            } else if(inc.RecordType.Name == 'Fixed' && inc.PropStrength__Amount__c > 0) { allowedAmount += inc.PropStrength__Amount__c; } else if(inc.RecordType.Name == 'Flexible' && inc.PropStrength__Rate_Per_Unit_Area__c > 0) { allowedAmount = allowedAmount +  (inc.PropStrength__Rate_Per_Unit_Area__c * booking.PropStrength__Super_Area__c);
            }
        }

        if(mode) {
            Decimal totalCashAmount = 0;
            System.debug('booking.PropStrength__Payments_Cheques__r****');
            System.debug(booking.PropStrength__Payments_Cheques__r);
            for(PropStrength__Received_Payment__c payRec : booking.PropStrength__Payments_Cheques__r) {
                if(payRec.RecordType.Name == 'Income Charge Received' && payRec.PropStrength__Payment_Type__c.containsIgnoreCase('OTC Deposits(Cash counter)') && payRec.PropStrength__Payment_Date__c == System.Today() && payRec.PropStrength__Amount__c != null && payRec.PropStrength__Amount__c > 0) { totalCashAmount += payRec.PropStrength__Amount__c;
                }
            }

            System.debug('totalCashAmount****');
            System.debug(totalCashAmount);
            
            if(totalCashAmount >= 15000) { allowedAmount = 0;
            } else if((totalCashAmount == 0 && allowedAmount == 0) || allowedAmount > 15000) { allowedAmount = 15000;
            } else if((15000-totalCashAmount) <= allowedAmount || allowedAmount == 0){ allowedAmount = 15000-totalCashAmount;
            }
        }

        if(allowedAmount < 0) { allowedAmount = 0;
        }

        return allowedAmount;
    }

    @AuraEnabled
    public static string checkPrCanCreateOrNot(String recId){
        try {
            System.debug('recId: '+recId);
            if(recId != null 
               && recId != '') {
                List<PropStrength__Property__c> propList = [SELECT Id, 
                                                        (SELECT Id, Status__c, Application_Booking__c FROM Payment_Requests__r) 
                                                        FROM PropStrength__Property__c WHERE Id = :recId];

                if(!propList.isEmpty()) {
                    if(!propList[0].Payment_Requests__r.isEmpty()) {
                        for(Payment_Request__c pr : propList[0].Payment_Requests__r) {
                            if(pr.Status__c != null && pr.Status__c.containsIgnoreCase('Rejected')) { return 'Yes';
                            }
                        }
                    } else { return 'Yes';
                    }
                }
            }
            return 'No';
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PropStrength__Offer__c getContactRecFromOffer(string offerIdrec){
        if(offerIdrec != null 
           && offerIdrec != '') {
            return [SELECT Id, Name, PropStrength__Status__c, PropStrength__Request__c, PropStrength__Property__c, PropStrength__Request__r.PropStrength__Request_Source__c, PropStrength__Request__r.Type_of_Enquiry__c , PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.MobilePhone, PropStrength__Primary_Contact__r.Name, PropStrength__Primary_Contact__r.Email, PropStrength__Primary_Contact__r.Passport_No__c, PropStrength__Primary_Contact__r.Emirates_ID__c FROM PropStrength__Offer__c WHERE Id = :offerIdrec];
        }
        return null;
    }

    @AuraEnabled
    public static String checkEnquiryAvailability(string enquiryId){
        if(enquiryId != null 
           && enquiryId != '') {
            return [select Id, PropStrength__Enquiry_Type__c from PropStrength__Request__c where Id =: enquiryId LIMIT 1].PropStrength__Enquiry_Type__c;
        }
        return null;
    }

    @AuraEnabled
    public static String checkPropertyAvailability(string propertyId){
        if(propertyId != null 
           && propertyId != '') {
            return String.valueOf([select Id, For_Direct_Sale__c from PropStrength__Property__c where Id =: propertyId LIMIT 1].For_Direct_Sale__c);
        }
        return null;
    }
    
    @AuraEnabled
    public static PropStrength__Application_Booking__c getUnitId(string bookingId){
        PropStrength__Application_Booking__c b = [select Id, PropStrength__Property__r.For_Direct_Sale__c, PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c,PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__r.Name, PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__c, PropStrength__Primary_Applicant_Name__c, PropStrength__Primary_Customer__r.Email, PropStrength__Primary_Customer__r.MobilePhone  from PropStrength__Application_Booking__c where Id =: bookingId];
        list<PropStrength__Applicant_Detail__c> adList = [select id, PropStrength__Type__c, PropStrength__Applicant_Acc__r.Passport_No__c, PropStrength__Applicant_Acc__r.Emirates_ID__c from PropStrength__Applicant_Detail__c where PropStrength__Type__c = '1st Applicant' and PropStrength__Application__c =: bookingId];
        if(adList.size()>0)
            b.Primary_Applicant_Passport_Emirates_Id__c = (adList[0].PropStrength__Applicant_Acc__r.Passport_No__c != null)?adList[0].PropStrength__Applicant_Acc__r.Passport_No__c:(adList[0].PropStrength__Applicant_Acc__r.Emirates_ID__c != null)?adList[0].PropStrength__Applicant_Acc__r.Emirates_ID__c:'';
        else
            b.Primary_Applicant_Passport_Emirates_Id__c = '';
        return b;
    }

    @AuraEnabled
    public static void updateUploadedFileName(string fileName, string docId){
        System.debug(fileName+'**---'+docId);
        ContentDocument cd = [select id,title from ContentDocument where Id=:docId];
        cd.Title = fileName;
        update cd;
    }
    
    @AuraEnabled
    public static Payment_Request__c getPaymentRequestDetails(string prId){
        Payment_Request__c pr = [select Id, Offer__c, Enquiry_Source__c,Type_of_Enquiry__c, Passport_No__c, Property__r.PropStrength__Tower__r.ESCROW_Account__c,
        Property__r.PropStrength__Tower__r.ESCROW_Account__r.Name, Lead_Source_Category__c, Lead_Source_Sub_Category__c, Property__r.For_Direct_Sale__c, 
        Account_Type__c, Property__r.PropStrength__Tower__c, Account_Master__c, Mode__c, Name__c, Property__c, Email__c, Emirates_Id_Passport_Number__c, 
        Enquiry__r.PropStrength__Primary_Contact__r.Name, 
        Enquiry__r.PropStrength__Primary_Contact__r.Email, Enquiry__r.PropStrength__Primary_Contact__r.MobilePhone, 
        Enquiry__r.PropStrength__Primary_Contact__r.Emirates_ID__c, Enquiry__r.PropStrength__Primary_Contact__r.Passport_No__c,
        Mobile_Number__c from Payment_Request__c where Id =: prId];
        return pr;
    } 
    
    @AuraEnabled
    public static map<string,decimal> getCurrencyRate(){
        map<string,decimal> currToRate = new map<string,decimal>();
        for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
            currToRate.put(currRate.MasterLabel,currRate.Rate__c);
        }
        return currToRate;
    }
    
    @AuraEnabled
    public static string createPaymentRequest(string name,string email,string mobile,string passportNumber,
    string mode,string curr,string instrumentNumber,string chequeNo,string chequeDate,
    string accountNo,string amount,string dateOfInitiation,string countryOfInitiation,integer uploadedFileLength,
    list<string> units,string bookingId,string modeOption,string secondaryMode,string instrumentDate, 
    string referenceNo, String is3rdParty, string amountTowards, string amountTowardsUnit, 
    string amountTowardsPreReg, string amountTowardsOther, string others, string prId, String popComments, 
    boolean isCorporate,String thirdPartyAndId, string category,
    string mortageValue){
        boolean isThirdParty = false;
        String objectApiName = '';
        String recordId = '';
        String typeOfEnquiry = '';
        String chequeNo1 = '';
        list<string> unitIdsTemp = new list<string>();

        for(string uId : units){
            string untId = uId.split('##')[0];
            unitIdsTemp.add(untId);
        }
        List<String> approvedStatusValues = new List<String>{'Approved','Amount submitted to accounts for confirmation'};
        System.debug('*--'+unitIdsTemp);
        List<Payment_Request__c> prRecForValidation = [SELECT Id from Payment_Request__c WHERE Property__c In :unitIdsTemp AND Status__c IN : approvedStatusValues 
                                                       AND Property__r.PropStrength__Property_on_hold_for_Reallocation__c = true];
        if(prRecForValidation.size() > 0){
            return 'Another PR is already Approved on this Unit';
        }
        if(thirdPartyAndId.contains('##') 
               && thirdPartyAndId.split('##').size() > 1) {            
              objectApiName = thirdPartyAndId.split('##')[1];
            if(String.isNotBlank(thirdPartyAndId.split('##')[0]))
              isThirdParty = boolean.valueof(thirdPartyAndId.split('##')[0]);
            recordId = thirdPartyAndId.split('##')[2];            
        }
     
        if(chequeNo.contains('##') 
             && chequeNo.split('##').size() > 1) {   
            if(String.isNotBlank(chequeNo.split('##')[0]))         
            chequeNo1 = String.valueof(chequeNo.split('##')[0]);
        if(String.isNotBlank(chequeNo.split('##')[1]))
          typeOfEnquiry = String.valueof(chequeNo.split('##')[1]);
    }
    else{
        if(String.isNotBlank(chequeNo)){
            chequeNo1 = chequeNo;
        }
    }
        String accountMaster = '';
        if(String.IsNotBlank(objectApiName)){
            objectApiName = objectApiName.trim();
            recordId = recordId.trim();
            if(objectApiName == 'PropStrength__Application_Booking__c'){
                List<PropStrength__Application_Booking__c> bookRec = [SELECT Id,PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c from PropStrength__Application_Booking__c Where Id = :recordId]; 
                accountMaster = bookRec[0].PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c;
            }
            else if(objectApiName == 'PropStrength__Offer__c'){
                List<PropStrength__Offer__c> offerRec = [SELECT Id,PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c from PropStrength__Offer__c Where Id = :recordId];
                accountMaster = offerRec[0].PropStrength__Property__r.PropStrength__Tower__r.ESCROW_Account__c;
            }
            else if(objectApiName == 'PropStrength__Property__c'){
                List<PropStrength__Property__c> propRec = [SELECT Id, PropStrength__Tower__r.ESCROW_Account__c from PropStrength__Property__c Where Id = :recordId];
                accountMaster = propRec[0].PropStrength__Tower__r.ESCROW_Account__c;
            }
        }
        System.debug(uploadedFileLength+'---bookingId*--'+bookingId);
        if(String.isNotBlank(bookingId)){
            Decimal DLDDue = 0;
            Decimal DLDReceived = 0; 
            List<PropStrength__Application_Booking__c> bookRec = [SELECT Id,DLD_Outstanding__c from PropStrength__Application_Booking__c WHERE Id =: bookingId];
            /*List<PropStrength__Received_Payment__c> payRecList = [SELECT id, recordtype.name, PropStrength__Amount__c from PropStrength__Received_Payment__c WHERE PropStrength__Amount_Due_Type__c = 'DLD Fees' AND PropStrength__Application_Booking__c =:'bookingId'];
            for(PropStrength__Received_Payment__c payRec : payRecList){
                if(payRec.recordtype.name == 'Income Charge Due'){
                    DLDDue += payRec.PropStrength__Amount__c;
                }
                else if(payRec.recordtype.name == 'Income Charge Received'){
                    DLDReceived += payRec.PropStrength__Amount__c;
                }
            }*/
            System.debug(DLDReceived+'-***--'+DLDDue+'----amountTowardsPreReg*----'+amountTowardsPreReg);
            if( amountTowardsPreReg != null && amountTowardsPreReg != 'null' && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && bookRec.size()>0 && Decimal.valueof(amountTowardsPreReg) > bookRec[0].DLD_Outstanding__c){ return 'Towards Pre-Registration Amount value sholud not be greater than the DLD Outstanding amount';
            } 
        }
        
        System.debug(isCorporate);
        String offId;
        if(bookingId.contains('##')) {
        offId = bookingId.split('##')[1];
        bookingId = bookingId.split('##')[0];
        } else if(bookingId.contains('a6')){
            offId = bookingId;
            bookingId = '';
        }

        PropStrength__Application_Booking__c bookingRec = new PropStrength__Application_Booking__c();
        if(bookingId != '' 
           && bookingId != null) {
            bookingRec = [SELECT Id, PropStrength__Project__c, PropStrength__Super_Area__c, 
                                                        (SELECT Id, PropStrength__Balance__c, PropStrength__Payment_Date__c, RecordType.Name, 
                                                        PropStrength__Amount__c, PropStrength__Payment_Type__c FROM PropStrength__Payments_Cheques__r 
                                                        WHERE RecordType.Name = 'Income Charge Due' AND PropStrength__Balance__c > 0 
                                                        AND PropStrength__Amount_Due_Type__c = :others) 
                                                        FROM PropStrength__Application_Booking__c WHERE Id = :bookingId];
        }

        String enqId = '';
        String enqSource = '';
        System.debug('curr');
        System.debug(curr);
        if(curr.contains('##')) {
            List<String> currList = curr.split('##');
            if(currList.size() == 2) { enqSource = currList.get(1); curr = currList.get(0);
            } else if(currList.size() > 2) {
                enqId = currList.get(2);
                enqSource = currList.get(1);
                curr = currList.get(0);
            }
        }

        String passportNo = '';
        System.debug('passportNumber*--'+passportNumber);
        if(passportNumber.contains('##')) {
            if(passportNumber.split('##').size() > 1)
                passportNo = passportNumber.split('##')[1];
            if(passportNumber.split('##').size() > 0)
                passportNumber = passportNumber.split('##')[0];
        }
        PropStrength__Request__c createEnqRecord = new PropStrength__Request__c();
        Contact createCont = new Contact();
        if(enqId == null || enqId == '' || enqId == 'undefined') {
            try {
                List<Contact> contList = [SELECT Id FROM Contact WHERE MobilePhone = :mobile]; 
                
                if(!contList.isEmpty()) { createCont = contList[0];
                } else {
                    createCont = new Contact(LastName=name, Email=email, MobilePhone=mobile, Emirates_ID__c=passportNumber, Passport_No__c=passportNo);
                    insert createCont;
                }

            createEnqRecord = new PropStrength__Request__c(Sales_Manager__c=UserInfo.getUserId(), PropStrength__Primary_Contact__c = createCont.Id, PropStrength__Request_Source__c = enqSource, Type_of_Enquiry__c = typeOfEnquiry );
            insert createEnqRecord;

            enqId = createEnqRecord.Id;
            } catch(Exception e) {
                return e.getMessage();
            }
        }
        
        Payment_Request__c prRec = new Payment_Request__c();
        if(String.isNotBlank(accountMaster)){prRec.Account_Master__c  = accountMaster;}
        if(prId != null 
           && prId != '' 
           && prId != 'undefined') {
            prRec = [SELECT Id, Enquiry__c FROM Payment_Request__c WHERE Id = :prId];
        }

        PropStrength__Request__c enqrec = new PropStrength__Request__c();
        System.debug(enqId);
        if(enqId != null 
           && enqId != 'null' 
           && enqId != '' 
           && enqId != 'undefined') {
            enqrec = [SELECT Id, PropStrength__Project__c, PropStrength__Request_Source__c, Type_of_Enquiry__c FROM PropStrength__Request__c WHERE Id = :enqId];
        }

        Savepoint sp = Database.setSavepoint();

        boolean isFromBooking = (bookingId == 'undefined' || bookingId == null || bookingId == '') ? false:true;
        User currentUser = [select Id, ManagerId, Manager.ManagerId from User where Id =: UserInfo.getUserId()];
        
        map<string,decimal> currToRate = new map<string,decimal>();
        for(Currency_Rate__mdt currRate : [select MasterLabel, Rate__c from Currency_Rate__mdt]){
            currToRate.put(currRate.MasterLabel,currRate.Rate__c);
        }
        
        

         Id userID = userInfo.getUserID();
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name, UserRole.Name, ManagerId, Manager.Name, Manager.UserRoleId, Manager.Manager.Name FROM User WHERE Id =: userID]);
        Map<Id,Unit_Hold__c> mapOfUnitHold = new Map<Id,Unit_Hold__c>();
        List<Unit_Hold__c> unitHoldList = new List<Unit_Hold__c>();
        Set<Id> propIds = new Set<Id>();
        User createdByUser = usersMap.get(userID);
        if(createdByUser != null 
           && (createdByUser.UserRole.Name.containsIgnoreCase('Sales Manager') || createdByUser.UserRole.Name.containsIgnoreCase('Sales Director') )) {    
            
            if(unitIdsTemp.size() > 0){

                unitHoldList = [SELECT Id,Sales_Manager__c,Unit_No__c,Sales_Director__c,Status__c,Unit_Hold_Approval_Status__c FROM Unit_Hold__c WHERE Unit_No__c IN :unitIdsTemp AND Status__c = 'Active' AND Unit_Hold_Approval_Status__c = 'Approved' ];

                if(unitHoldList.size() > 0){
                    for(Unit_Hold__c uh : unitHoldList){
                            if(createdByUser.UserRole.Name.containsIgnoreCase('Sales Manager') && uh.Sales_Manager__c != null && createdByUser.Id != uh.Sales_Manager__c ){
                                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;}
                                if(createCont != null && createCont.Id != null) { delete createCont;} return 'Unit hold request for the selected property is raised by different user';
                            }
                            if(createdByUser.UserRole.Name.containsIgnoreCase('Sales Director') && uh.Sales_Director__c != null && createdByUser.Id != uh.Sales_Director__c){
                                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord; }
                                if(createCont != null && createCont.Id != null) { delete createCont; } return 'Unit hold request for the selected property is raised by different user';
                            }                        
                    }
                }  
            }
        }


        Map<Id, PropStrength__Property__c> propMap = new Map<Id, PropStrength__Property__c>([SELECT Id, PropStrength__Project_Name__c, (SELECT Id FROM PropStrength__Application_Booking__r WHERE PropStrength__Active__c = TRUE LIMIT 1) FROM PropStrength__Property__c WHERE Id IN :unitIdsTemp]);

        for(PropStrength__Property__c prop : propMap.values()) {
            if(enqRec != null && enqrec.PropStrength__Project__c != null && prop.PropStrength__Project_Name__c != null && prop.PropStrength__Project_Name__c != enqrec.PropStrength__Project__c) {
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                }
                if(createCont != null && createCont.Id != null) { delete createCont; }
                return 'Project ID of Enquiry and Property must be equal';
            }
        }
        map<string,string> accountNameToAccountId = new map<string,string>();
        map<string,PropStrength__Property__c> unitIdToUnitObj = new map<string,PropStrength__Property__c>();
        for(PropStrength__Property__c u : [select Id, PropStrength__Tower__r.ESCROW_Account__c, PropStrength__Tower__r.ESCROW_Account__r.Name, PropStrength__Property_Name__c, PropStrength__Rate_per_unit_area__c, PropStrength__Super_Area__c, Requisite_Hold_Payment__c, PropStrength__Tower__c from PropStrength__Property__c where Id IN: unitIdsTemp]){
            unitIdToUnitObj.put(u.Id, u);
            if(u.PropStrength__Tower__c!=null && u.PropStrength__Tower__r.ESCROW_Account__c != null){ accountNameToAccountId.put(u.PropStrength__Tower__r.ESCROW_Account__r.Name,u.PropStrength__Tower__r.ESCROW_Account__c);
            }
        }

        if((others == 'Resale NOC (Title Deed)' || others == 'Resale – NOC (Title Deed)')&& Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Resale_NOC_Title_Deed)){
            if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
            }
            if(createCont != null && createCont.Id != null) { delete createCont;
                                }
            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Resale_NOC_Title_Deed+' for Resale NOC (Title Deed)';}else if(others == 'Title Deed Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.Towards_Deed_Charges)){
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                }
                if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                return 'Amount towards other charges cannot be greater then '+System.Label.Towards_Deed_Charges+' for Title Deed Charges';}else if(others == 'Reissue of Plot NOC (construction)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_construction)){
                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                    }
                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                    return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Reissue_of_Plot_NOC_construction+' for Reissue of Plot NOC (construction)';}else if(others == 'Reissue of Plot NOC (other than construction)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction)){
                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                        }
                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                        return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction+' for Reissue of Plot NOC (other than construction)';}else if(others == 'Construction NOC' && Decimal.valueOf(amountTowardsOther) >   Decimal.valueOf(System.Label.X15k_Construction_NOC)){
                            if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                            }
                            if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                            return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Construction_NOC+' for Construction NOC';}else if(others == 'Detailed design NOC' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Detailed_design_NOC)){
                                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Detailed_design_NOC+' for Detailed design NOC';}else if(others == 'Concept drawing NOC' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Concept_drawing_NOC)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                    }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                    return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Concept_drawing_NOC+' for Concept drawing NOC';}else if(others == 'Pre-registration to pre-title deed (completed projects)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects)){
                                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                    }
                                     if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                    return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects+' for Pre-registration to pre-title deed (completed projects)';}else if(others == 'Pre-registration To Pre-title Deed' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Pre_registration_To_Pre_title_Deed)){
                                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                    }
                                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                    return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Pre_registration_To_Pre_title_Deed+' for Pre-registration To Pre-title Deed';}else if(others == 'Admin Charges (General)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Admin_Charges_General)){
                                        if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                    }
                                        if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Admin_Charges_General+' for Admin Charges (General)';}else if(others == 'Admin Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Admin_Charges)){
                                        if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Admin_Charges+' for Admin Charges';}else if(others == 'DLD Cancellation Charges' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_DLD_Cancellation_Charges)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_DLD_Cancellation_Charges+' for DLD Cancellation Charges';}else if(others == 'Ownership change' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Ownership_changes)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Ownership_changes+' for Ownership changes';}else if(others == 'Name addition/deletion' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Name_addition_deletion)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Name_addition_deletion+' for Name addition/deletion';}else if(others == 'SPA reissuance fees (per book)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_SPA_reissuance_fees_per_book)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_SPA_reissuance_fees_per_book+' for SPA reissuance fees (per book)';}else if(others == 'SPA Reissuance Fees' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_SPA_Reissuance_Fees)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_SPA_Reissuance_Fees+' for SPA Reissuance Fees';}else if(others == 'Title Deed Fees (Plots)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Plots)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Plots+' for Title Deed Fees (Plots)';}else if(others == 'Plot title Deed' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Plot_title_Deed)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Plot_title_Deed+' for Plot title Deed';}else if(others == 'Title Deed Fees (Villas)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Villas)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) {delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Villas+' for Title Deed Fees (Villas)';}else if(others == 'Title Deed Fees (Units)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Units)){
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Title_Deed_Fees_Units+' for Title Deed Fees (Units)';}else if(others == 'Resale NOC (Oqood)' && Decimal.valueOf(amountTowardsOther) > Decimal.valueOf(System.Label.X15k_Resale_NOC_Oqood)){ 
                                    if(createEnqRecord != null && createEnqRecord.Id != null) {delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }return 'Amount towards other charges cannot be greater then '+System.Label.X15k_Resale_NOC_Oqood+' for Resale NOC (Oqood)';} 

        if(isFromBooking && unitIdsTemp.size()>0){
            double allocatedDP = 0;
            double allocatedDLD = 0;
            double allocatedTitleAmount = 0;
            list<string> checkedNSA = new list<string>();
            for(Payment_Request__c pr : [select Id, From_Booking__c, New_Sale_Approval__c, Towards_Pre_Registration_Amount__c, 
                                        Towards_Unit_Price_Amount__c, New_Sale_Approval__r.DP_Amount__c, New_Sale_Approval__r.DP_Amount_2__c, 
                                        New_Sale_Approval__r.DLD_Amount__c, New_Sale_Approval__r.DLD_Amount_2__c ,
                                        Towards_Other_Charges_Amount__c,others__c
                                        from Payment_Request__c where Property__c =: unitIdsTemp[0] and Status__c = 'Approved' and  
                                        ((From_Booking__c = true and Application_Booking__c != null and Application_Booking__r.PropStrength__Status__c != 'Rejected') or (New_Sale_Approval__c != null and New_Sale_Approval__r.Approval_Status__c = 'Approved' and New_Sale_Approval__r.Booking__r.Status__c != 'Cancelled'))]){
                if(pr.From_Booking__c){
                    allocatedDP = (pr.Towards_Unit_Price_Amount__c!=null)?allocatedDP+(double)pr.Towards_Unit_Price_Amount__c:allocatedDP;
                    allocatedDLD = (pr.Towards_Pre_Registration_Amount__c!=null)?allocatedDLD+(double)pr.Towards_Pre_Registration_Amount__c:allocatedDLD;
                    if(pr.others__c == 'Title Deed Charges') {allocatedTitleAmount = (pr.Towards_Other_Charges_Amount__c!=null)?allocatedTitleAmount+(double)pr.Towards_Other_Charges_Amount__c:allocatedTitleAmount;
                    }
                      }
                if(pr.New_Sale_Approval__c!=null && !checkedNSA.contains(pr.New_Sale_Approval__c)){
                    checkedNSA.add(pr.New_Sale_Approval__c);  allocatedDP = (pr.New_Sale_Approval__r.DP_Amount__c!=null)?allocatedDP+(double)pr.New_Sale_Approval__r.DP_Amount__c:allocatedDP;
                    allocatedDP = (pr.New_Sale_Approval__r.DP_Amount_2__c!=null)?allocatedDP+(double)pr.New_Sale_Approval__r.DP_Amount_2__c:allocatedDP;
                    allocatedDLD = (pr.New_Sale_Approval__r.DLD_Amount__c!=null)?allocatedDLD+(double)pr.New_Sale_Approval__r.DLD_Amount__c:allocatedDLD;
                    allocatedDLD = (pr.New_Sale_Approval__r.DLD_Amount_2__c!=null)?allocatedDLD+(double)pr.New_Sale_Approval__r.DLD_Amount_2__c:allocatedDLD;
                }                            
            }

            allocatedDP = (amountTowardsUnit!=null && amountTowardsUnit!='null' && amountTowardsUnit!='' && amountTowardsUnit!='undefined')?Double.valueOf(amountTowardsUnit)+allocatedDP:allocatedDP;
            allocatedDLD = (amountTowardsPreReg!=null && amountTowardsPreReg!='null' && amountTowardsPreReg!='' && amountTowardsPreReg!='undefined')?Double.valueOf(amountTowardsPreReg)+allocatedDLD:allocatedDLD;
            Double purPrice = unitIdToUnitObj.get(unitIdsTemp[0]).PropStrength__Super_Area__c != null && unitIdToUnitObj.get(unitIdsTemp[0]).PropStrength__Rate_per_unit_area__c !=  null ? unitIdToUnitObj.get(unitIdsTemp[0]).PropStrength__Super_Area__c * unitIdToUnitObj.get(unitIdsTemp[0]).PropStrength__Rate_per_unit_area__c : 0.00; 
            double tenPercent = (unitIdToUnitObj.containsKey(unitIdsTemp[0]) && unitIdToUnitObj.get(unitIdsTemp[0])!=null && purPrice!=null)?(double)(purPrice*0.1):0;
            double fourPercent = (unitIdToUnitObj.containsKey(unitIdsTemp[0]) && unitIdToUnitObj.get(unitIdsTemp[0])!=null && purPrice!=null)?(double)(purPrice*0.04):0;
            boolean skipPregistrationValidation = false;
            if(mortageValue != null 
               && mortageValue != 'null'
               && mortageValue != '' 
               && mortageValue != 'undefined'
               && mortageValue != '0'){
                skipPregistrationValidation = true;
            }
            if(amountTowardsOther != null 
               && amountTowardsOther!= ''
               && others == 'Title Deed Charges'){ allocatedDLD += Decimal.valueOf(amountTowardsOther);
                
            }
            System.debug(allocatedDP+'--'+amountTowardsUnit+'--tenPercent***-'+tenPercent);
            if(mode == 'OTC Deposits(Cash counter)' ){
                if(amountTowardsUnit!=null 
                   && amountTowardsUnit!='null' 
                   && amountTowardsUnit!='' 
                   && amountTowardsUnit!='undefined' 
                   && allocatedDP > tenPercent+10 
                   && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())) {
                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                    return 'A maximum of 10% of the unit purchase price has already been allocated towards unit price.';
                }
                decimal dldAmountToCompare = fourPercent+Decimal.valueOf(System.Label.DLD_Charge); 
                if(others == 'Title Deed Charges'){ dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                }
                
                if( (amountTowardsOther!=null 
                     && amountTowardsOther!='null' 
                     && amountTowardsOther!='' 
                     && amountTowardsOther!='undefined') 
                     && others == 'Title Deed Charges' && (allocatedDLD + allocatedTitleAmount) > dldAmountToCompare && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())) {
                    if(amountTowardsOther != null && amountTowardsOther!= '' && others == 'Title Deed Charges'){    
                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;   }
                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' has already been allocated towards pre-registration.';
                    }else{
                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                        return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150'+' has already been allocated towards pre-registration.';
                    }
                }
                if(!skipPregistrationValidation &&( (amountTowardsPreReg!=null && amountTowardsPreReg!='null' && amountTowardsPreReg!='' && amountTowardsPreReg!='undefined') ) && allocatedDLD >  (dldAmountToCompare ) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())) {
                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150'+' has already been allocated towards pre-registration.';} 
            } 
            else{
                decimal dldAmountToCompare = fourPercent+Decimal.valueOf(System.Label.DLD_Charge); 
                if(amountTowardsOther != null 
                   && amountTowardsOther!= ''
                   && others == 'Title Deed Charges') { dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                }
                
                if(!skipPregistrationValidation && amountTowardsPreReg!=null && amountTowardsPreReg!='null' && amountTowardsPreReg!='' && amountTowardsPreReg!='undefined' && allocatedDLD > dldAmountToCompare && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())) {
                    if(amountTowardsOther != null && amountTowardsOther!= '' && others == 'Title Deed Charges') {   
                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' has already been allocated towards pre-registration.';}
                                else{
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'A maximum of 4% of the unit purchase price plus the DLD Admin fee of AED 1150 '+' has already been allocated towards pre-registration.';}
                }
            }
        }
        map<string,decimal> unitIdToMinHoldAmount = new map<string,decimal>();      
        if(modeOption == 'Single Mode') {                                         
            Decimal sumOfUnitSaleValue=0;
            for(PropStrength__Property__c u : [select Id, Requisite_Hold_Payment_Type__c, Requisite_Hold_Payment__c, PropStrength__Rate_per_unit_area__c, PropStrength__Super_Area__c from PropStrength__Property__c where Id IN: unitIdsTemp]){
                Decimal eachUnitHoldValue = 0;
                if(u.Requisite_Hold_Payment_Type__c == '%') { Decimal purPrice = u.PropStrength__Super_Area__c != null && u.PropStrength__Rate_per_unit_area__c !=  null ? u.PropStrength__Super_Area__c * u.PropStrength__Rate_per_unit_area__c : 0.00; 
                    if(u.Requisite_Hold_Payment__c != null){ eachUnitHoldValue = (Decimal)((purPrice * u.Requisite_Hold_Payment__c)/100);
                    }
                    /*else{
                        eachUnitHoldValue = (Decimal)((purPrice * 2)/100);
                    }*/
                } else if(u.Requisite_Hold_Payment_Type__c == 'Amount') {
                    if(u.Requisite_Hold_Payment__c != null){
                        eachUnitHoldValue = (Decimal)u.Requisite_Hold_Payment__c;
                    }
                }
                sumOfUnitSaleValue = sumOfUnitSaleValue + eachUnitHoldValue;
                unitIdToMinHoldAmount.put(u.Id,eachUnitHoldValue);
            }
            
                Double givenAmount=0;
                System.debug('unitIdToMinHoldAmount*******');
                System.debug(unitIdToMinHoldAmount);
                String unitIdWithMinimumAmountError = '';
                for(string uId : units){
                    string unitId = uId.split('##')[0];
                    Double perUnitAmt = Double.valueOf(uId.split('##')[2]);
                    if(uId.split('##')[1] != 'AED') {
                        if(!currToRate.isEmpty() && 
                            currToRate.containsKey(uId.split('##')[1]) && 
                            currToRate.get(uId.split('##')[1]) != null) {
                            if(perUnitAmt != null) {
                                perUnitAmt = (Double)(perUnitAmt * currToRate.get(uId.split('##')[1]));
                            } else {
                                perUnitAmt = (Double)((perUnitAmt != null ? perUnitAmt : 1) * currToRate.get(uId.split('##')[1]));
                            }
                        }
                        //perUnitAmt = (Double)(perUnitAmt * currToRate.get(uId.split('##')[1]));
                        
                    }
                    System.debug('perUnitAmt*******');
                System.debug(perUnitAmt);
                System.debug('unitIdToMinHoldAmount.get(unitId)*******');
                System.debug(unitIdToMinHoldAmount.get(unitId));
                    if(perUnitAmt < unitIdToMinHoldAmount.get(unitId)){ unitIdWithMinimumAmountError += unitIdToUnitObj.get(unitId).PropStrength__Property_Name__c+',';
                    }
                }
                if(unitIdWithMinimumAmountError != ''){unitIdWithMinimumAmountError = unitIdWithMinimumAmountError.substring(0,unitIdWithMinimumAmountError.length()-1);
                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                    return unitIdWithMinimumAmountError+' : Amount should be greater or equal to Unit Hold Min Percentage of Unit purchase price.';}
                                                  
        } 
        Boolean isSecondaryMode = false;
        if(modeOption == 'Multi Mode'){
            if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){ 
                list<Payment_Request__c> prList = [select Id,Amount__c from Payment_Request__c where Id =: prId];
                if(prList.size()>0){
                    isSecondaryMode = true;
                    Double amt = (Double)prList[0].Amount__c;
                    Double perUnitAmt = (Double)(amt/prList.size());
                    Boolean isPrimaryOTC = false;
                    Payment_Request__c parentPR = [select Id,Mode__c,Currency__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(parentPR.Mode__c == 'OTC Deposits(Cash counter)')
                        isPrimaryOTC = true;
                    if(parentPR.Currency__c != 'AED' && !parentPR.Amount_Confirmed_By_Accounts__c)
                        perUnitAmt = (Double)(perUnitAmt*currToRate.get(parentPR.Currency__c));
                    PropStrength__Property__c u = [select Id, Requisite_Hold_Payment_Type__c, Requisite_Hold_Payment__c, PropStrength__Super_Area__c, PropStrength__Rate_per_unit_area__c from PropStrength__Property__c where Id IN: unitIdsTemp LIMIT 1][0];
                    Double unitPp = u.PropStrength__Super_Area__c != null && u.PropStrength__Rate_per_unit_area__c !=  null ? u.PropStrength__Super_Area__c * u.PropStrength__Rate_per_unit_area__c : 0.00;
                    Double twoPercent;
                    if(u.Requisite_Hold_Payment_Type__c == '%') {
                        if(u.Requisite_Hold_Payment__c != null){ twoPercent = (Double)((unitPp*u.Requisite_Hold_Payment__c)/100);
                        }
                    } else if(u.Requisite_Hold_Payment_Type__c == 'Amount') {
                        if(u.Requisite_Hold_Payment__c != null){
                            twoPercent = (Decimal)u.Requisite_Hold_Payment__c;
                        }
                    }
                    
                        Double givenAmount=0;
                        for(string uId : units){
                            if(isSecondaryMode == false){
                                if(uId.split('##')[1] != 'AED'){ Double perUnitAmtTmp = Double.valueOf(uId.split('##')[2]);
                                    perUnitAmtTmp = (Double)(perUnitAmtTmp*currToRate.get(uId.split('##')[1]));
                                    givenAmount+= perUnitAmtTmp;
                                }
                                else{
                                    givenAmount+= Double.valueOf(uId.split('##')[2]);
                                }
                            }else{
                                if(mode == 'IWT(International)' && curr != 'AED'){
                                    givenAmount = Double.valueOf(amount);
                                    givenAmount = (Double)(givenAmount*currToRate.get(curr));
                                }
                                else{
                                    givenAmount = Double.valueOf(amount);
                                } 
                            }
                            
                        }
                        givenAmount = givenAmount + perUnitAmt;
                        if(givenAmount<twoPercent){
                            if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                            if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                            return 'Amount should be greater or equal to Unit Hold Min Percentage of Unit purchase price.';
                        }
                        if(mode == 'OTC Deposits(Cash counter)'){
                   
                            decimal dldAmountToCompare = 0; 
                            dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                            
                            if(isPrimaryOTC && givenAmount > (Double)(((unitPp*Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100)+Decimal.valueOf(System.Label.DLD_Charge)+dldAmountToCompare+10) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())){ System.debug('293');return System.Label.PR_OTC_14_Percent_Validation_Msg;}
                           if(!isPrimaryOTC && (givenAmount) > (Double)(((unitPp*14)/100)+Decimal.valueOf(System.Label.DLD_Charge)+dldAmountToCompare+10) && !System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName())){
                                if(amountTowardsOther != null && amountTowardsOther!= ''
                                && others == 'Title Deed Charges'){   
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                  return 'A maximum of 14% of the unit purchase price plus the DLD Admin fee of AED 1150 and Title Deed fee of AED '+System.label.Towards_Deed_Charges+' can be created for OTC Deposits(Cash counter).';}else{ 
                                    if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                                      if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'A maximum of 14% of the unit purchase price plus the DLD Admin fee of AED 1150'+' can be created for OTC Deposits(Cash counter).';}
                                
                            }
                        }
                }
            }
        }
        
        list<Payment_Request__c> prList = new list<Payment_Request__c>();
        list<PropStrength__Received_Payment__c> paymentList = new list<PropStrength__Received_Payment__c>();
        Id payRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id incChargeRecTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get('Income Charge Received').getRecordTypeId();
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');

        list<Interim_Payments__c> interimPaymentList = new list<Interim_Payments__c>();
        Id intPayRecTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Payment Received').getRecordTypeId();
        Id intPayIncChargeRecTypeId = Schema.SObjectType.Interim_Payments__c.getRecordTypeInfosByName().get('Income Charges Received').getRecordTypeId();
        
        
            DateTime dt;
            if(modeOption == 'Single Mode') {
                dt = System.now().addHours(24);
            } else if(modeOption == 'Multi Mode') {
                dt = System.now().addMinutes(60);
            }
            prw.Payment_Link_Expiry__c = dt;
            prw.Customer_Name__c  = name;
            prw.Mode_Option__c = modeOption;
            if(curr != null && curr != 'undefined')
        prw.Currency__c = curr; 
            else 
                prw.Currency__c = 'AED';         
            if(email != null && email != 'undefined')
                prw.Email__c = email;
            if(mobile != null && mobile != 'undefined')
                prw.Mobile_Number__c = mobile;
            if(mode != null && mode != 'undefined')
                prw.Mode__c = mode;
            if(amount != null && amount != 'undefined')
                prw.Amount__c = Double.valueOf(amount);
            
            list<string> unitIds = new list<string>();
            if(!units.isEmpty()) {
                for(string uId : units){
                    string untId = uId.split('##')[0];
                    unitIds.add(untId);
                }
            }
            
            if(prId != null && prId != '' && prId != 'undefined') {
                prw.Id = [SELECT Id, Payment_Request_Wrapper__c FROM Payment_Request__c WHERE Id =:prId].Payment_Request_Wrapper__c;
            } else {
            string unitNames='';
            if(!unitIds.isEmpty()) {
                for(PropStrength__Property__c u : [select Id, PropStrength__Property_Name__c from PropStrength__Property__c where Id IN : unitIds]){
                    unitNames += u.PropStrength__Property_Name__c+',';
                }
                unitNames = unitNames.removeEnd(',');
                prw.Units__c = unitNames;
            }
            insert prw;
            prw.Payment_Public_Page_Link_Copy__c = sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c +prw.id;
            prw.Payment_Public_Page_Link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
            update prw;
        }
        
        
        if(!isCorporate && (mode == 'IWT(International)' || mode == 'DWT(Domestic)'
        || mode== 'CDM Cash (Cash Deposit in Machine)' )){
            list<string> listOfUnitIds = new list<string>();
            for(string uId : units){
                String accountType;
                 if(uId.split('##').size() > 3) { accountType = uId.split('##')[3];
                }
                if(isFromBooking == false && isSecondaryMode == false &&  (mode == 'IWT(International)' || mode == 'DWT(Domestic)' || mode== 'CDM Cash (Cash Deposit in Machine)')) {
                    accountType = uId.split('##')[3];
                }

                if(accountType == 'ESCROW' || accountType == null) {
                    listOfUnitIds.add(uId.split('##')[0]);
                }
            }

            String msg = '';
            for(PropStrength__Property__c u : [select Id, PropStrength__Tower__r.ESCROW_Account__c, PropStrength__Property_Name__c, PropStrength__Tower__c, PropStrength__Tower__r.PropStrength__Tower_Name__c from PropStrength__Property__c where Id IN: listOfUnitIds and PropStrength__Tower__c != null]){
                if(u.PropStrength__Tower__r.ESCROW_Account__c == null){
                    msg = msg+u.PropStrength__Property_Name__c+', ';
                }
            }
            msg = msg.removeEnd(',');
            if(msg != ''){
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return msg+' : ESCROW Account not mapped, Please select Corporate Account.';}
        }

        string cate='';
        string subcate='';
        if(category!=null && category!='' && category.contains('#')){
            list<string> categoryList = category.split('#');
            if(categoryList.size() == 2){
                cate = (categoryList[0]!='null' && categoryList[0]!='')?categoryList[0]:'';
                subcate = (categoryList[1]!='null' && categoryList[1]!='')?categoryList[1]:'';
            }else if(categoryList.size() == 1){
                cate = (categoryList[0]!='null' && categoryList[0]!='')?categoryList[0]:'';
            }
        }

        if(units.isEmpty()) {
            Payment_Request__c pr = new Payment_Request__c();
              if(String.isNotBlank(accountMaster))
                  pr.Account_Master__c  = accountMaster;
                if(popComments != ''){
                    List<String> popList = popComments.split('######');
                    pr.POP_Comments__c = popList[0];
                    if(popList.size() > 1){
                        pr.POP_Amount__c = Decimal.valueOf(popList[1]);
                        pr.POP_Amount_1__c = Decimal.valueOf(popList[1]);
                    }
                }
                pr.Lead_Source_Category__c = cate;
                pr.Lead_Source_Sub_Category__c = subcate;
                if(name != null && name != 'undefined')
                    pr.Name__c = name;
                if(email != null && email != 'undefined')
                    pr.Email__c = email;
                if(mobile != null && mobile != 'undefined')
                    pr.Mobile_Number__c = mobile;
                if(passportNumber != null && passportNumber != 'undefined')
                    pr.Emirates_Id_Passport_Number__c = passportNumber;
                if(passportNo != null && passportNo != 'undefined')
                    pr.Passport_No__c = passportNo;
                if(enqrec != null && enqrec.PropStrength__Request_Source__c != null) {
                    pr.Enquiry_Source__c = enqrec.PropStrength__Request_Source__c;
                }
                if(enqrec != null && enqrec.Type_of_Enquiry__c != null) {
                    pr.Type_of_Enquiry__c = enqrec.Type_of_Enquiry__c;
                }
                pr.Mode__c = mode;
                pr.Payment_Request_Wrapper__c = prw.Id;
                if(curr != null && curr != 'undefined' && curr != '')
                    pr.Currency__c = curr;
                else
                    pr.Currency__c = 'AED';
                if(instrumentNumber != null && instrumentNumber != 'undefined')
                    pr.Instrument_Number__c = instrumentNumber;
                if(instrumentDate != null && instrumentDate != 'undefined')
                    pr.Instrument_Date__c = Date.valueOf(instrumentDate);
                if(chequeNo1 != null && chequeNo1 != 'undefined')
                    pr.Cheque_No__c = chequeNo1;
                if(chequeDate != null && chequeDate != 'undefined')
                    pr.Cheque_Date__c = Date.valueOf(chequeDate);
                if(accountNo != null && accountNo != 'undefined')
                    pr.Account_Master__c = accountNo;
                if(amount != null && amount != 'undefined' && amount != '')
                    pr.Amount__c = Double.valueOf(amount);
                if(dateOfInitiation != null && dateOfInitiation != 'undefined')
                    pr.Date_of_Initiation__c = Date.valueOf(dateOfInitiation);
                if(referenceNo != null && referenceNo != 'undefined')
                    pr.Reference_Number__c  = referenceNo;
                if(countryOfInitiation != null && countryOfInitiation != 'undefined')
                    pr.Country_of_Initiation__c = countryOfInitiation;
                if(modeOption != null && modeOption != 'undefined' && modeOption != '')
                    pr.Mode_Option__c = modeOption;
                if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){ 
                    pr.Secondary_Mode__c = secondaryMode;
                    list<Payment_Request__c> prToUpdate = [select Id,Currency__c,Amount__c,Status__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(prToUpdate.size()>0){
                        if(prToupdate[0].Currency__c != 'AED' && prToupdate[0].Amount_Confirmed_By_Accounts__c == false && (prToupdate[0].Status__c == 'Partially Approved' || prToupdate[0].Status__c == 'Submitted to Accounts for Amount Confirmation')){
                            if(curr != 'AED'){
                              pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                        }else{
                            if(curr != 'AED'){
                                pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + prToUpdate[0].Amount__c;
                            }
                            else{
                              pr.Total_Amount__c = Double.valueOf(amount) + prToUpdate[0].Amount__c;
                            }
                        }
                    }
                }
                if(isFromBooking){

                    pr.From_Booking__c = true;
                    if (mode == 'Website') {
                        pr.Status__c = 'Payment Link sent to Customer';
                        pr.Payment_public_link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;

                        pr.Payment_Public_Link_Copy__c = sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c +prw.id;

                    }
                    pr.Application_Booking__c = bookingId;
                    if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                      pr.Towards_Unit_Price_Amount__c = Double.valueOf(amountTowardsUnit);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Unit_Price_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }
                    if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                      pr.Towards_Pre_Registration_Amount__c = Double.valueOf(amountTowardsPreReg);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = incChargeRecTypeId, PropStrength__Amount__c = pr.Towards_Pre_Registration_Amount__c, PropStrength__Amount_Due_Type__c = 'DLD'));
                    }
                    if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                      pr.Towards_Other_Charges_Amount__c = Double.valueOf(amountTowardsOther);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Other_Charges_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }

                    /*if(mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card' || mode == 'Website' || mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                        if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                            }
                        }
                        if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                              //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                              //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));
                            }
                        }
                        if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others, Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others));
                            }
                        }
                    }*/
                    
                    /*if(mode == 'Cheque'){                           
                        if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') 
                          //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                        
                        if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') 
                           // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId,Amount_Type__c = pr.others__c , Amount_Interim__c = Double.valueOf(amountTowardsOther)));
                        
                        if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') 
                           // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));                        
                            
                    }*/

                   /* if(mode == 'CDM Cash (Cash Deposit in Machine)' || mode == 'IWT(International)' || mode == 'DWT(Domestic)') {
                        if(!isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {
                                if(mode == 'CDM Cash (Cash Deposit in Machine)'){
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'Installment', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                                } else {
                                  //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'Installment', Instrument_Number__c = instrumentNumber));
                                }
                            }
                        } else if(isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {
                                if(mode == 'CDM Cash (Cash Deposit in Machine)'){
                                   // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'DLD Fees', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                                } else {
                                   // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'DLD Fees', Instrument_Number__c = instrumentNumber));
                                }
                            }
                        }
                    }*/

                    if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null')
                        pr.Amount_Towards__c = amountTowards;
                    if(others != null && others != 'undefined' && others != '' && others != 'null')
                        pr.Others__c  = others;
                    if(mortageValue != null && mortageValue != 'undefined'
                    && mortageValue != '' && mortageValue != 'null') {
                    pr.Mortgage_Value__c = Double.valueOf(mortageValue);
                    }                       
                }
                if(currentUser.ManagerId != null){
                    pr.Submitter_Manager__c = currentUser.ManagerId;
                    pr.Submitter_Manager_s_Manager__c = currentUser.Manager.ManagerId;
                }
                if(prId != '')
                    pr.Payment_Request__c = prId;
                pr.Offer__c = offId;
                if(enqId != '') {
                    pr.Enquiry__c = enqId;
                }

                if(prId != null && prId != '' && prId != 'undefined') {
                    pr.Enquiry__c = prRec.Enquiry__c;
                }

                if(isCorporate) {
                    pr.Account_Type__c = 'Corporate';
                } else {
                    pr.Account_Type__c = 'ESCROW';
                }
                pr.Payment__c = bookingRec != null && !bookingRec.PropStrength__Payments_Cheques__r.isEmpty() ? bookingRec.PropStrength__Payments_Cheques__r[0].Id : null;
                prList.add(pr);
        }
        
        if(mode == 'OTC Deposits(Cash counter)'){
            system.debug('units*--'+units);
            for(string uId : units){
                string untId = uId.split('##')[0];
                if(!isFromBooking && (String.isBlank(secondaryMode) || secondaryMode == '')){
                    curr = uId.split('##')[1];
                    amount = uId.split('##')[2];
                }
                decimal dldAmountToCompare = 0; 
                dldAmountToCompare += Decimal.valueOf(System.label.Towards_Deed_Charges);
                Double purPrice = unitIdToUnitObj.get(untId).PropStrength__Super_Area__c != null && unitIdToUnitObj.get(untId).PropStrength__Rate_per_unit_area__c !=  null ? unitIdToUnitObj.get(untId).PropStrength__Super_Area__c * unitIdToUnitObj.get(untId).PropStrength__Rate_per_unit_area__c : 0.00; 
                curr = 'AED';
                if(!System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()) && curr != 'AED' && purPrice != null && ((Double.valueOf(amount) * currToRate.get(curr))) > (Double)(((purPrice * Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100) + Decimal.valueOf(System.Label.DLD_Charge) + dldAmountToCompare + 10)){System.debug('404');string errorMsg = System.Label.PR_OTC_14_Percent_Validation_Msg;errorMsg = errorMsg.replace('#UNIT#', unitIdToUnitObj.get(untId).PropStrength__Property_Name__c);
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                    if(createCont != null && createCont.Id != null) { delete createCont;
                                }                                                                                                                                                                                                                 
                                                                                                                                                                                                                                     
                return errorMsg;
                }
                if(!System.Label.PR_OTC_Skip_Validation_Usernames.contains(UserInfo.getUserName()) && curr == 'AED' && purPrice != null && (Double.valueOf(amount)) > (Double)(((purPrice * Integer.valueOf(System.Label.PR_OTC_MAX_Amount_Percentage))/100) + Decimal.valueOf(System.Label.DLD_Charge) + dldAmountToCompare + 10)){System.debug('411');string errorMsg = System.Label.PR_OTC_14_Percent_Validation_Msg;errorMsg = errorMsg.replace('#UNIT#', unitIdToUnitObj.get(untId).PropStrength__Property_Name__c);
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                          if(createCont != null && createCont.Id != null) { delete createCont;
                                }                                                                                                                                                                                                                                                                                                          
                                return errorMsg;
                }
                System.debug('amountTowardsOther -->'+amountTowardsOther);
                if(amountTowardsOther != null && amountTowardsOther != '' && amountTowardsOther != 'null'){
                    List<Payment_Request__c> paymentRequests = [SELECT id,Amount__c,Application_Booking__c FROM Payment_Request__c WHERE Application_Booking__c =: bookingId AND Mode__c = 'OTC Deposits(Cash counter)' AND Towards_Other_Charges_Amount__c != null AND CreatedDate >= :DateTime.now().addHours(-24)];
                    Decimal sum = 0;
                    if(paymentRequests != NULL){
                        sum = Decimal.valueOf(amountTowardsOther); 
                        for(Payment_Request__c pr : paymentRequests){ sum += pr.Amount__c != NULL ? pr.Amount__c : sum;
                        }
                    }
                    if(sum > Decimal.valueOf(System.Label.X15k_Limit_for_per_day_transactions)){
                        if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                        if(createCont != null && createCont.Id != null) { delete createCont;
                                }
                                return 'Sum of all OTC Mode Payment Requests created in a day cannot be greater then '+System.Label.X15k_Limit_for_per_day_transactions; } 
                }
                Payment_Request__c pr = new Payment_Request__c();
                if(String.isNotBlank(accountMaster))
                  pr.Account_Master__c  = accountMaster;
                if(propMap.containsKey(untId) && !propMap.get(untId).PropStrength__Application_Booking__r.isEmpty()) {
                    pr.Application_Booking__c = propMap.get(untId).PropStrength__Application_Booking__r[0].Id;
                }
                if(popComments != ''){
                    List<String> popList = popComments.split('######');
                    pr.POP_Comments__c = popList[0];
                    if(popList.size() > 1){
                        pr.POP_Amount__c = Decimal.valueOf(popList[1]);
                        pr.POP_Amount_1__c = Decimal.valueOf(popList[1]);
                    }
                }
                pr.Lead_Source_Category__c = cate;
                pr.Lead_Source_Sub_Category__c = subcate;
                if(name != null && name != 'undefined')
                    pr.Name__c = name;
                if(email != null && email != 'undefined')
                    pr.Email__c = email;
                if(mobile != null && mobile != 'undefined')
                    pr.Mobile_Number__c = mobile;
                if(passportNumber != null && passportNumber != 'undefined')
                    pr.Emirates_Id_Passport_Number__c = passportNumber;
                if(passportNo != null && passportNo != 'undefined')
                    pr.Passport_No__c = passportNo;
                if(enqrec != null && enqrec.PropStrength__Request_Source__c != null) {
                    pr.Enquiry_Source__c = enqrec.PropStrength__Request_Source__c;
                }
                if(enqrec != null && enqrec.Type_of_Enquiry__c != null) {
                    pr.Type_of_Enquiry__c = enqrec.Type_of_Enquiry__c;
                }
                pr.Mode__c = mode;
                pr.Property__c = untId;
                pr.Payment_Request_Wrapper__c = prw.Id;
                if(curr != null && curr != 'undefined' && curr != '')
                    pr.Currency__c = curr;
                else
                    pr.Currency__c = 'AED';
                if(instrumentNumber != null && instrumentNumber != 'undefined')
                    pr.Instrument_Number__c = instrumentNumber;
                if(instrumentDate != null && instrumentDate != 'undefined')
                    pr.Instrument_Date__c = Date.valueOf(instrumentDate);
                if(chequeNo1 != null && chequeNo1 != 'undefined')
                    pr.Cheque_No__c = chequeNo1;
                if(chequeDate != null && chequeDate != 'undefined')
                    pr.Cheque_Date__c = Date.valueOf(chequeDate);
                if(accountNo != null && accountNo != 'undefined')
                    pr.Account_Master__c = accountNo;
                if(amount != null && amount != 'undefined' && amount != '')
                    pr.Amount__c = Double.valueOf(amount);
                if(dateOfInitiation != null && dateOfInitiation != 'undefined')
                    pr.Date_of_Initiation__c = Date.valueOf(dateOfInitiation);
                if(referenceNo != null && referenceNo != 'undefined')
                    pr.Reference_Number__c  = referenceNo;
                if(countryOfInitiation != null && countryOfInitiation != 'undefined')
                    pr.Country_of_Initiation__c = countryOfInitiation;
                if(modeOption != null && modeOption != 'undefined' && modeOption != '')
                    pr.Mode_Option__c = modeOption;
                if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){ 
                    pr.Secondary_Mode__c = secondaryMode;
                    list<Payment_Request__c> prToUpdate = [select Id,Currency__c,Amount__c,Status__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(prToUpdate.size()>0){
                        if(prToupdate[0].Currency__c != 'AED' && prToupdate[0].Amount_Confirmed_By_Accounts__c == false && (prToupdate[0].Status__c == 'Partially Approved' || prToupdate[0].Status__c == 'Submitted to Accounts for Amount Confirmation')){
                            if(curr != 'AED'){ pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                        }else{
                            if(curr != 'AED'){ pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(curr)) + prToUpdate[0].Amount__c;
                            }
                            else{
                              pr.Total_Amount__c = Double.valueOf(amount) + prToUpdate[0].Amount__c;
                            }
                        }
                    }
                }
                if(isFromBooking){

                    pr.From_Booking__c = true;
                    pr.Application_Booking__c = bookingId;
                    if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                      pr.Towards_Unit_Price_Amount__c = Double.valueOf(amountTowardsUnit);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Unit_Price_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }
                    if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                      pr.Towards_Pre_Registration_Amount__c = Double.valueOf(amountTowardsPreReg);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = incChargeRecTypeId, PropStrength__Amount__c = pr.Towards_Pre_Registration_Amount__c, PropStrength__Amount_Due_Type__c = 'DLD'));
                    }
                    if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                      pr.Towards_Other_Charges_Amount__c = Double.valueOf(amountTowardsOther);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Other_Charges_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }

                   /* if(mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card' || mode == 'Website' || mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                        if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                               // interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                            }
                        }
                        if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                              //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                              //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));
                            }
                        }
                        if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others, Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                              //  interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others));
                            }
                        }
                    }*/

                    /*if(mode == 'Cheque'){
                        if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null'){
                            if(amountTowards == 'Unit Price') {
                                if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                                    interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                                }
                            } else if(amountTowards == 'Other Amount') {
                                if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                                    interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther)));
                                }
                            } else if(amountTowards == 'Registration Amount') {
                                if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                                    interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));
                                }
                            }

                        }
                    }*/

                 /*  
                  // if(mode == 'CDM Cash (Cash Deposit in Machine)' || mode == 'IWT(International)' || mode == 'DWT(Domestic)') {
                        if(!isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {
                                if(mode == 'CDM Cash (Cash Deposit in Machine)'){
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'Installment', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                                } else {
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'Installment', Instrument_Number__c = instrumentNumber));
                                }
                            }
                        } else if(isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {
                                if(mode == 'CDM Cash (Cash Deposit in Machine)'){
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'DLD Fees', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                                } else {
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'DLD Fees', Instrument_Number__c = instrumentNumber));
                                }
                            }
                        }
                   // }
                   */

                    if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null')
                        pr.Amount_Towards__c = amountTowards;
                    if(others != null && others != 'undefined' && others != '' && others != 'null')
                        pr.Others__c  = others;
                    if(mortageValue != null && mortageValue != 'undefined'
                    && mortageValue != '' && mortageValue != 'null') {
                    pr.Mortgage_Value__c = Double.valueOf(mortageValue);
                    }                       
                }
                if(currentUser.ManagerId != null){
                    pr.Submitter_Manager__c = currentUser.ManagerId;
                    pr.Submitter_Manager_s_Manager__c = currentUser.Manager.ManagerId;
                }
                if(prId != '')
                    pr.Payment_Request__c = prId;
                pr.Offer__c = offId;
                if(enqId != '') {
                    pr.Enquiry__c = enqId;
                }
                if(prId != null && prId != '' && prId != 'undefined') {
                    pr.Enquiry__c = prRec.Enquiry__c;
                }
                if(isCorporate) {
                    pr.Account_Type__c = 'Corporate';
                } else {
                    pr.Account_Type__c = 'ESCROW';
                }

                pr.Payment__c = bookingRec != null && !bookingRec.PropStrength__Payments_Cheques__r.isEmpty() ? bookingRec.PropStrength__Payments_Cheques__r[0].Id : null;
                prList.add(pr);
            }
        }
        else{
            for(string uId : units){
                string untId = uId.split('##')[0];    
                if(!isFromBooking && secondaryMode == ''){
                    if(uId.split('##').size() > 1){curr = uId.split('##')[1];}  
                        
                    if(uId.split('##').size() > 2){amount = uId.split('##')[2];}  
                        
                }
                System.debug('untId'+untId);
                Payment_Request__c pr = new Payment_Request__c();
                if(String.isNotBlank(accountMaster))
                  pr.Account_Master__c  = accountMaster;
                if(propMap.containsKey(untId) && !propMap.get(untId).PropStrength__Application_Booking__r.isEmpty()) {
                    pr.Application_Booking__c = propMap.get(untId).PropStrength__Application_Booking__r[0].Id;
                }
                if(popComments != ''){
                    List<String> popList = popComments.split('######');
                    pr.POP_Comments__c = popList[0];
                    if(popList.size() > 1){
                        pr.POP_Amount__c = Decimal.valueOf(popList[1]);
                        pr.POP_Amount_1__c = Decimal.valueOf(popList[1]);
                    }
                }
                pr.Lead_Source_Category__c = cate;
                pr.Lead_Source_Sub_Category__c = subcate;
                pr.Third_Party__c = isThirdParty;
                if(name != null && name != 'undefined')
                    pr.Name__c = name;
                if(email != null && email != 'undefined')
                    pr.Email__c = email;
                if(mobile != null && mobile != 'undefined')
                    pr.Mobile_Number__c = mobile;
                if(passportNumber != null && passportNumber != 'undefined')
                    pr.Emirates_Id_Passport_Number__c = passportNumber;
                if(passportNo != null && passportNo != 'undefined')
                    pr.Passport_No__c = passportNo;
                if(enqrec != null && enqrec.PropStrength__Request_Source__c != null) {
                    pr.Enquiry_Source__c = enqrec.PropStrength__Request_Source__c;
                }
                if(enqrec != null && enqrec.Type_of_Enquiry__c != null) {
                    pr.Type_of_Enquiry__c = enqrec.Type_of_Enquiry__c;
                }
                pr.Mode__c = mode;
                pr.Property__c = untId;
                pr.Payment_Request_Wrapper__c = prw.Id;
                if (mode == 'Website') {
                    pr.Status__c = 'Payment Link sent to Customer';
                    pr.Payment_public_link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
                    pr.Payment_Public_Link_Copy__c = sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c +prw.id;
                }
                System.debug(pr.Payment_Public_Link_Copy__c+'*---pr.Payment_Public_Link_Copy__c---'+mode);
                /*if(curr != null && curr != 'undefined' && mode == 'IWT(International)')
                    pr.Currency__c = curr;
                if(mode != 'IWT(International)')*/
                    pr.Currency__c = 'AED';
                if(instrumentNumber != null && instrumentNumber != 'undefined')
                    pr.Instrument_Number__c = instrumentNumber;
                if(instrumentDate != null && instrumentDate != 'undefined')
                    pr.Instrument_Date__c = Date.valueOf(instrumentDate);
                if(chequeNo1 != null && chequeNo1 != 'undefined')
                    pr.Cheque_No__c = chequeNo1;
                if(chequeDate != null && chequeDate != 'undefined')
                    pr.Cheque_Date__c = Date.valueOf(chequeDate);
                /*if(modeOption == 'Multi Mode'){
                    if(accountNo != null && accountNo != 'undefined')
                        pr.Account_Master__c = accountNo;
                }*/
                if(isCorporate && accountNo != null && accountNo != 'undefined' && (mode == 'IWT(International)' || mode == 'DWT(Domestic)'
                || mode == 'CDM Cash (Cash Deposit in Machine)')){
                    pr.Account_Master__c = accountNo;
                    pr.Account_Type__c = 'Corporate';
                }
                
                if(!isCorporate && (mode == 'IWT(International)' || mode == 'DWT(Domestic)')){
                    pr.Account_Type__c = 'ESCROW';
                    List<PropStrength__Property__c> u = [select Id, PropStrength__Tower__r.ESCROW_Account__c, PropStrength__Tower__c from PropStrength__Property__c where Id =: untId LIMIT 1];
                    if(u.size() > 0 && u[0].PropStrength__Tower__c != null && u[0].PropStrength__Tower__r.ESCROW_Account__c != null){
                        pr.Account_Master__c = u[0].PropStrength__Tower__r.ESCROW_Account__c;
                    }
                }
                
                if(isFromBooking == false && isSecondaryMode == false && (mode == 'IWT(International)' || mode == 'DWT(Domestic)')){
                    string accountType = '';

                    if(uId.split('##').size() > 3) { accountType = uId.split('##')[3];

                    }
                    
                    if(accountType == 'Corporate'){
                        pr.Account_Type__c = 'Corporate';
                        if(uId.split('##').size() > 4) { String accountId = uId.split('##')[4];
                            pr.Account_Master__c = accountId;
                        }
                    }
                    if(accountType == 'ESCROW'){
                        pr.Account_Type__c = 'ESCROW';
                        if(uId.split('##').size() > 4) { string accountId = uId.split('##')[4]; 
                            pr.Account_Master__c = (accountNameToAccountId.containsKey(accountId))?accountNameToAccountId.get(accountId):null;
                        }
                    }
                }
                if(amount != null && amount != 'undefined')
                    pr.Amount__c = Double.valueOf(amount);
                if(dateOfInitiation != null && dateOfInitiation != 'undefined')
                    pr.Date_of_Initiation__c = Date.valueOf(dateOfInitiation);
                if(referenceNo != null && referenceNo != 'undefined')
                    pr.Reference_Number__c  = referenceNo;
                if(countryOfInitiation != null && countryOfInitiation != 'undefined')
                    pr.Country_of_Initiation__c = countryOfInitiation;
                if(modeOption != null && modeOption != 'undefined' && modeOption != '')
                    pr.Mode_Option__c = modeOption;
                if(secondaryMode != null && secondaryMode != 'undefined' && secondaryMode != ''){
                    pr.Secondary_Mode__c = secondaryMode;
                    list<Payment_Request__c> prToUpdate = [select Id,Currency__c,Amount__c,Status__c,Amount_Confirmed_By_Accounts__c from Payment_Request__c where Id =: prId];
                    if(prToUpdate.size()>0){
                        if(prToupdate[0].Currency__c != 'AED' && prToupdate[0].Amount_Confirmed_By_Accounts__c == false && (prToupdate[0].Status__c == 'Partially Approved' || prToupdate[0].Status__c == 'Submitted to Accounts for Amount Confirmation')){
                            if(pr.Currency__c != 'AED'){ pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(pr.Currency__c)) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + (Double)(prToupdate[0].Amount__c*currToRate.get(prToupdate[0].Currency__c));
                            }
                        }else{
                            if(pr.Currency__c != 'AED') { pr.Total_Amount__c = (Double)(Double.valueOf(amount)*currToRate.get(pr.Currency__c)) + prToUpdate[0].Amount__c;
                            }
                            else{
                                pr.Total_Amount__c = Double.valueOf(amount) + prToUpdate[0].Amount__c;
                            }
                        }
                    }
                }
                if(isFromBooking){
                    pr.From_Booking__c = true;
                    pr.Application_Booking__c = bookingId;
                    if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                        pr.Towards_Unit_Price_Amount__c = Double.valueOf(amountTowardsUnit);
                     //   paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Unit_Price_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }
                    if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                        pr.Towards_Pre_Registration_Amount__c = Double.valueOf(amountTowardsPreReg);
                     //   paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = incChargeRecTypeId, PropStrength__Amount__c = pr.Towards_Pre_Registration_Amount__c, PropStrength__Amount_Due_Type__c = 'DLD'));
                    }
                    if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                        pr.Towards_Other_Charges_Amount__c = Double.valueOf(amountTowardsOther);
                      //  paymentList.add(new PropStrength__Received_Payment__c(PropStrength__Application_Booking__c = bookingId, RecordTypeId = payRecTypeId, PropStrength__Amount__c = pr.Towards_Other_Charges_Amount__c, PropStrength__Amount_Due_Type__c = 'Installment'));
                    }
                    if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null') {
                        pr.Amount_Towards__c = amountTowards;
                    }

                    /*if(mode == 'OTC Deposits(Cash counter)' || mode == 'Credit Card' || mode == 'Website' || mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                        if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                            }
                        }
                        if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                            //    interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees', Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));
                            }
                        }
                        if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                            if(mode == 'CDM Cheque (Cheque Deposit in Machine)') {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others, Instrument_Date__c = Date.valueOf(instrumentDate), Instrument_Date_Interim__c = Date.valueOf(instrumentDate), Instrument_Number__c = instrumentNumber));
                            } else {
                             //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther), Amount_Type__c = others));
                            }
                        }
                    }

                    if(mode == 'Cheque'){
                        if(amountTowards != null && amountTowards != 'undefined' && amountTowards != '' && amountTowards != 'null'){
                            if(amountTowards == 'Unit Price') {
                                if(amountTowardsUnit != null && amountTowardsUnit != 'undefined' && amountTowardsUnit != '' && amountTowardsUnit != 'null') {
                               //     interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsUnit), Amount_Type__c = 'Installment'));
                                }
                            } else if(amountTowards == 'Other Amount') {
                                if(amountTowardsOther != null && amountTowardsOther != 'undefined' && amountTowardsOther != '' && amountTowardsOther != 'null') {
                                 //   interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsOther)));
                                }
                            } else if(amountTowards == 'Registration Amount') {
                                if(amountTowardsPreReg != null && amountTowardsPreReg != 'undefined' && amountTowardsPreReg != '' && amountTowardsPreReg != 'null') {
                               //     interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Cheque_Demand_Draft_Number_Interim__c = chequeNo, Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amountTowardsPreReg), Amount_Type__c = 'DLD Fees'));
                                }
                            }

                        }
                    }

                    if(mode == 'IWT(International)' || mode == 'DWT(Domestic)') {
                        if(!isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {                               
                            //        interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'Installment', Instrument_Number__c = instrumentNumber));                                
                            }
                        } else if(isCorporate) {
                            if(amount != null && amount != 'undefined' && amount != '' && amount != 'null') {
                             //       interimPaymentList.add(new Interim_Payments__c(Payment_Date_Interim__c = System.Today(), Application_Booking_Interim__c = bookingId, RecordTypeId = intPayIncChargeRecTypeId, Amount_Interim__c = Double.valueOf(amount), Amount_Type__c = 'DLD Fees', Instrument_Number__c = instrumentNumber));                                
                            }
                        }
                    }*/


                    if(others != null && others != 'undefined' && others != '' && others != 'null')
                        pr.Others__c  = others;
                        if(mortageValue != null && mortageValue != 'undefined'
                        && mortageValue != '' && mortageValue != 'null') {
                        pr.Mortgage_Value__c = Double.valueOf(mortageValue);
                        }
                }
                if(currentUser.ManagerId != null){
                    pr.Submitter_Manager__c = currentUser.ManagerId;
                    pr.Submitter_Manager_s_Manager__c = currentUser.Manager.ManagerId;
                }
                
                boolean is3rdPartyCheque = Boolean.ValueOf(is3rdParty.split('###')[0]);
            boolean is3rdpartyIWT = Boolean.valueOf(is3rdParty.split('###')[2]);
            boolean is3rdpartyCDMCheque = Boolean.valueOf(is3rdParty.split('###')[1]);
                boolean is3rdpartyDWT = Boolean.valueOf(is3rdParty.split('###')[3]);
                
                if(is3rdPartyCheque==true)
                    pr.X3rd_Party_Cheque__c = true;
                if(is3rdpartyIWT == true)
                    pr.X3rd_Party_IWT__c = true;
                if(is3rdpartyDWT == true)
                    pr.X3rd_Party_DWT__c = true;
                if(is3rdpartyCDMCheque == true)
                    pr.X3rd_Party_CDM_Cheque__c = true;
                if(prId != '')
                    pr.Payment_Request__c = prId;
                pr.Offer__c = offId;
                if(enqId != '') {
                    pr.Enquiry__c = enqId;
                }
                if(prId != null && prId != '' && prId != 'undefined') {
                    pr.Enquiry__c = prRec.Enquiry__c;
                }
                if(isCorporate) {
                    pr.Account_Type__c = 'Corporate';
                } else {
                    pr.Account_Type__c = 'ESCROW';
                }
                pr.Payment__c = bookingRec != null && !bookingRec.PropStrength__Payments_Cheques__r.isEmpty() ? bookingRec.PropStrength__Payments_Cheques__r[0].Id : null;
                prList.add(pr);
            }
        }
        if(prList.size()>0) {
            try {
                insert prList;
                if(!paymentList.isEmpty()) {
                    //insert paymentList;
                }
                if(!interimPaymentList.isEmpty()) {
                    //insert interimPaymentList;
                }                
            } catch(Exception e) {
                if(createEnqRecord != null && createEnqRecord.Id != null) { delete createEnqRecord;
                                }
                if(createCont != null && createCont.Id != null) {delete createCont;
                                }
                Database.rollBack(sp);
                if(e.getMessage().contains('Payment Request can be created by Allocated SM only')) { return 'Payment Request can be created by Allocated SM only';
                }
                if(e.getMessage().contains(System.label.Payment_Request_Unit_Restriction_Message)){ return System.label.Payment_Request_Unit_Restriction_Message;
                } else {
                    return e.getMessage();
                }
                
            }
           
        }
            
        
        if(uploadedFileLength > 0){
            List<ContentDocument> docList = [select Id from ContentDocument where CreatedById =: Userinfo.getUserId() order by CreatedDate desc limit: uploadedFileLength];
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            for(ContentDocument cd : docList){
                for(Payment_Request__c pr : prList){
                    ContentDocumentLink cdLink = new ContentDocumentLink();
                    cdLink.ContentDocumentId = cd.Id;
                    cdLink.LinkedEntityId = pr.Id;
                    cdLinkList.add(cdLink);
                }
            }
            if(cdLinkList.size()>0){
                insert cdLinkList;
            }
        }        

        if(mode == 'Website' && email != null) {
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setSubject('Payment Request URL');
            mail.setplaintextbody('Dear Customer,\n\nWe trust this message finds you well.\nRequest you to please find below the Payment URL to make the payment.\n\nUrl - '+sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c +prw.id+'\n\n\nBest regards,\nSobha Team');
            mail.setToAddresses(new List<String>{email});
            emailList.add(mail);
            
            System.debug(emailList);
            if(emailList != null && emailList.size()>0 ) {
                System.debug(emailList);
                Messaging.sendEmail(emailList);
                EmailMessage newEmail = new EmailMessage();
                newEmail.ToAddress = email;
                newEmail.Subject = 'Payment Request URL';
                newEmail.TextBody = mail.getPlainTextBody();
                newEmail.RelatedToId = prw.Id;
                newEmail.Status = '3';
                insert newEmail;
            }
        }
        if(prList.size() > 0)
           return 'success&&'+ prList[0].Id;
        return 'success';
    }
    
    public static void rejectWebsiteRequests(list<string> wrapperIds){
        list<Payment_Request__c> prToUpdate = new list<Payment_Request__c>();
        list<Payment_Request__c> prToReject = [select Id from Payment_Request__c where Payment_Request_Wrapper__c IN: wrapperIds];
        for(Payment_Request__c pr : prToReject){
            pr.Status__c = 'Rejected by System';
            prToUpdate.add(pr);
        }
        update prToUpdate;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Payment_Request_Wrapper__c pr : [select Id, CreatedBy.Email, CreatedBy.Name, (select Id, Property__r.PropStrength__Unit_Status__c, Property__r.PropStrength__Property_Name__c from Payment_Requests__r) from Payment_Request_Wrapper__c where Id IN: wrapperIds]){
            string holdUnits = '';
            string allUnits = '';
            for(Payment_Request__c p : pr.Payment_Requests__r){
                if(p.Property__r.PropStrength__Unit_Status__c == 'Hold')
                    holdUnits += p.Property__r.PropStrength__Property_Name__c + '<br/>';
                allUnits += p.Property__r.PropStrength__Property_Name__c + ',';
            }
            allUnits = allUnits.removeEnd(',');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new list<string>{pr.CreatedBy.Email});
            mail.setSubject('Payment Request Rejection Notification');
            String body = 'Dear ' + pr.CreatedBy.Name + ', <br/><br/>';
            body += 'Your payment request for the unit(s) <b>'+ allUnits +'</b> has been rejected, as the following unit(s) is on hold by another request. <br/><br/>' + holdUnits + '<br/>';
            body += 'Please contact your sales manager for any clarifications.<br/><br/>';
            body += 'Regards,<br/>';
            body += 'Sobha Hartland';
            mail.setHtmlBody(body);
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }

    @AuraEnabled
    public static boolean checkifUnitIsBlocked(string unitid){
        /*try {
            String managerId = [SELECT managerId FROM User WHERE ID =: userinfo.getuserId()].managerId;
            List<Unit_hold__c> uhList = [SELECT ID FROM Unit_Hold__C WHERE status__c = 'active' and unit__c =: unitId and (sales_director__c =: managerId Or sales_director__c =: userinfo.getuserId())];
            return uhList.size() > 0 ? true : false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/
        return false;
    }

    @AuraEnabled
    public static PropStrength__Request__c searchPrimaryContact(String enquiryId){
        return [SELECT Id, PropStrength__Request_Source__c,Type_Of_Enquiry__c, PropStrength__Primary_Contact__c, PropStrength__Primary_Contact__r.Name, 
                PropStrength__Primary_Contact__r.Email, PropStrength__Primary_Contact__r.MobilePhone, 
                PropStrength__Primary_Contact__r.Emirates_ID__c, PropStrength__Primary_Contact__r.Passport_No__c FROM PropStrength__Request__c WHERE Id = :enquiryId];
        //return [SELECT Id, Name, Email, MobilePhone, Emirates_ID__c, Passport_No__c FROM Contact WHERE Id = :enqRec.PropStrength__Primary_Contact__c];
    }

    @AuraEnabled
    public static String getContactRecPassport(String contactId){
        List<Attachment> attachmentList = [SELECT Id,Body,ParentId FROM Attachment WHERE ParentId = :contactId AND ContentType = 'application/pdf' AND (Name LIKE '%Passport%' OR Name LIKE '%passport%') LIMIT 1];
        if (!attachmentList.isEmpty() 
            && attachmentList[0].ParentId != null) {
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String attachmentUrl = baseUrl + '/servlet/servlet.FileDownload?file=' + attachmentList[0].Id;
            return attachmentUrl;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getContactRecPassport2(String contactId){
        System.debug('contactId*----'+contactId);
        List<ContentDocumentLink> documentLink = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :contactId AND ContentDocument.FileType = 'PDF' AND (ContentDocument.Title LIKE '%Passport%' OR ContentDocument.Title LIKE '%passport%') LIMIT 1];
        
        if (!documentLink.isEmpty()) {
            ContentVersion contentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId = :documentLink[0].ContentDocumentId AND (Title LIKE '%Passport%' OR Title LIKE '%passport%') LIMIT 1];
            return EncodingUtil.base64Encode(contentVersion.VersionData);
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static String getContactRecPassport3(String contactId){
        List<ContentDocumentLink> documentLink = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :contactId AND (ContentDocument.Title LIKE '%Passport%' OR ContentDocument.Title LIKE '%passport%') LIMIT 1];
        
        if (!documentLink.isEmpty()) {
            ContentVersion contentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId = :documentLink[0].ContentDocumentId AND (Title LIKE '%Passport%' OR Title LIKE '%passport%') LIMIT 1];
            return EncodingUtil.base64Encode(contentVersion.VersionData);
        } else {
            List<Attachment> attachmentList = [SELECT Id,Body,ParentId FROM Attachment WHERE ParentId = :contactId AND (Name LIKE '%Passport%' OR Name LIKE '%passport%') LIMIT 1];
            if (!attachmentList.isEmpty() && attachmentList[0].ParentId != null) {
                return EncodingUtil.base64Encode(attachmentList[0].Body);
            } else {
                return null;
            }
        }
    }

    @AuraEnabled
    public static String getPOPImgFile(String contVersionId){
        ContentVersion contentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE Id = :contVersionId LIMIT 1];
        return EncodingUtil.base64Encode(contentVersion.VersionData);
    }

    @AuraEnabled
    public static String getPOPPdfFile(String contVersionId){
        ContentVersion contentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE Id = :contVersionId LIMIT 1];
        return EncodingUtil.base64Encode(contentVersion.VersionData);
    }
@AuraEnabled
    public static String checkPropertyAvailableForPROrNot(String recId){
        System.debug(recId);
        PropStrength__Property__c prop = [SELECT Id, PropStrength__Property_on_hold_for_Reallocation__c, Hold_Classification__c, PropStrength__Unit_Status__c FROM PropStrength__Property__c WHERE Id = :recId];
        System.debug(prop);
        if(prop.PropStrength__Unit_Status__c != 'Available') {
            return 'No';
        }
        return 'Yes';
    }

    @AuraEnabled
    public static String checkAllocatedSmRec(String recId){
        System.debug(recId);
        PropStrength__Property__c prop = [SELECT Id, Allocated_SM__c FROM PropStrength__Property__c WHERE Id = :recId];
        System.debug(prop);
        /*if(prop.Allocated_SM__c == null) {
            return 'Fill';
        } else*/
        
        if(prop.Allocated_SM__c != null && prop.Allocated_SM__c != UserInfo.getUserId()) {  return 'No';
        }
        return 'Yes';
    }
    public class UnitDetailsWrapper{
        @AuraEnabled 
        public  String unitkey;
        @AuraEnabled 
        public Boolean onDirectSale;
        @AuraEnabled
        public Payment_Request__c approvedPR;
    }
}