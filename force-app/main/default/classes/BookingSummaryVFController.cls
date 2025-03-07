public class BookingSummaryVFController {
    public List<PropStrength__Application_Booking__c> bookingList {get;set;}

    public BookingSummaryVFController() {
        bookingList = [SELECT Id, Name, PropStrength__Booking_Date__c, House_Unit_No__c, PropStrength__Property_Type_Code__c, PropStrength__Primary_Customer__c, 
                        PropStrength__Primary_Customer__r.Name, Booking_Form_Signed_Date__c, Booking_Form_Executed__c, SPA_Executed__c, 
                        MOU_Executed__c, MOU_Execution_Date__c, DSPA_Executed__c, PCC_Status__c, 
                        Pre_Registration_Completed__c, Termination_Process_Status__c, Handover_Completed__c, 
                        PropStrength__Status__c, PropStrength__Super_Area__c, PropStrength__Basic_Sale_Price__c, 
                        PropStrength__Revised_Total_Sales_Consideration__c, PropStrength__Total_Payment_Due__c, 
                        PropStrength__Total_Payment_Received__c 
                        FROM PropStrength__Application_Booking__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<PropStrength__Application_Booking__c> getBookingList() {
        return [SELECT Id, Name, PropStrength__Booking_Date__c, House_Unit_No__c, PropStrength__Property_Type_Code__c, PropStrength__Primary_Customer__c, 
                PropStrength__Primary_Customer__r.Name, Booking_Form_Signed_Date__c, Booking_Form_Executed__c, SPA_Executed__c, 
                MOU_Executed__c, MOU_Execution_Date__c, DSPA_Executed__c, PCC_Status__c, 
                Pre_Registration_Completed__c, Termination_Process_Status__c, Handover_Completed__c, 
                PropStrength__Status__c, PropStrength__Super_Area__c, PropStrength__Total_Payment_Due__c, 
                PropStrength__Total_Payment_Received__c, Oqood_Fees_Received__c, Oqood_Fees_Amount__c, PropStrength__Offer__c, 
                PropStrength__Offer__r.Name, Project_Name__c, PropStrength__Project__c, PropStrength__Tower__c, 
                PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Completion_Certificate_Received__c, 
                PropStrength__Property__c 
                FROM PropStrength__Application_Booking__c WHERE PropStrength__Primary_Customer__c != null AND PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
    }

    @AuraEnabled(cacheable=true)
    public static List<PropStrength__Application_Booking__c> searchBookingAsPerFilter(String bookingName, String unitName, String customerName) {
        Boolean bookingPresent = false;
        Boolean unitPresent = false;
        Boolean customerPresent = false;
        if(bookingName != null && bookingName != 'undefined' && bookingName != '') {
            bookingPresent = true;
            bookingName = '%'+bookingName+'%';
        }
        if(unitName != null && unitName != 'undefined' && unitName != '') {
            unitPresent = true;
            unitName = '%'+unitName+'%';
        }
        if(customerName != null && customerName != 'undefined' && customerName != '') {
            customerPresent = true;
            customerName = '%'+customerName+'%';
        }

        if(bookingPresent) {
            return [SELECT Id, Name, PropStrength__Booking_Date__c, House_Unit_No__c, PropStrength__Property_Type_Code__c, PropStrength__Primary_Customer__c, 
                    PropStrength__Primary_Customer__r.Name, Booking_Form_Signed_Date__c, Booking_Form_Executed__c, SPA_Executed__c, 
                    MOU_Executed__c, MOU_Execution_Date__c, DSPA_Executed__c, PCC_Status__c, 
                    Pre_Registration_Completed__c, Termination_Process_Status__c, Handover_Completed__c, 
                    PropStrength__Status__c, PropStrength__Super_Area__c, PropStrength__Total_Payment_Due__c, 
                    PropStrength__Total_Payment_Received__c, Oqood_Fees_Received__c, Oqood_Fees_Amount__c, PropStrength__Offer__c, 
                    PropStrength__Offer__r.Name, Project_Name__c, PropStrength__Project__c, PropStrength__Tower__c, 
                    PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Completion_Certificate_Received__c, 
                    PropStrength__Property__c  
                FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Primary_Customer__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null AND Name LIKE :bookingName];
        }
        else if(unitPresent) {
            return [SELECT Id, Name, PropStrength__Booking_Date__c, House_Unit_No__c, PropStrength__Property_Type_Code__c, PropStrength__Primary_Customer__c, 
                    PropStrength__Primary_Customer__r.Name, Booking_Form_Signed_Date__c, Booking_Form_Executed__c, SPA_Executed__c, 
                    MOU_Executed__c, MOU_Execution_Date__c, DSPA_Executed__c, PCC_Status__c, 
                    Pre_Registration_Completed__c, Termination_Process_Status__c, Handover_Completed__c, 
                    PropStrength__Status__c, PropStrength__Super_Area__c, PropStrength__Total_Payment_Due__c, 
                    PropStrength__Total_Payment_Received__c, Oqood_Fees_Received__c, Oqood_Fees_Amount__c, PropStrength__Offer__c, 
                    PropStrength__Offer__r.Name, Project_Name__c, PropStrength__Project__c, PropStrength__Tower__c, 
                    PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Completion_Certificate_Received__c, 
                    PropStrength__Property__c  
                FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Primary_Customer__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null AND House_Unit_No__c LIKE :unitName];
        }
        else if(customerPresent) {
            List<PropStrength__Application_Booking__c>  appList = new List<PropStrength__Application_Booking__c>();
            List<PropStrength__Application_Booking__c> bookReturn = new List<PropStrength__Application_Booking__c>();
            appList = [SELECT Id, Name, PropStrength__Booking_Date__c, House_Unit_No__c, PropStrength__Property_Type_Code__c, PropStrength__Primary_Customer__c, 
                    PropStrength__Primary_Customer__r.Name, Booking_Form_Signed_Date__c, Booking_Form_Executed__c, SPA_Executed__c, 
                    MOU_Executed__c, MOU_Execution_Date__c, DSPA_Executed__c, PCC_Status__c, 
                    Pre_Registration_Completed__c, Termination_Process_Status__c, Handover_Completed__c, 
                    PropStrength__Status__c, PropStrength__Super_Area__c, PropStrength__Total_Payment_Due__c, 
                    PropStrength__Total_Payment_Received__c, Oqood_Fees_Received__c, Oqood_Fees_Amount__c, PropStrength__Offer__c, 
                    PropStrength__Offer__r.Name, Project_Name__c, PropStrength__Project__c, PropStrength__Tower__c, 
                    PropStrength__Property__r.PropStrength__Tower__c, PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Completion_Certificate_Received__c, 
                    PropStrength__Property__c, 
                    (SELECT Id, Name, PropStrength__Applicant_Acc__c, PropStrength__Applicant_Acc__r.Name FROM PropStrength__Applicant_Details__r WHERE PropStrength__Application__c != null AND PropStrength__Active__c = true AND PropStrength__Applicant_Acc__r.Name LIKE :customerName) 
                FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Primary_Customer__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
            for(PropStrength__Application_Booking__c app : appList) {
                if(app.PropStrength__Applicant_Details__r.size() > 0) {
                    bookReturn.add(app);
                }
            }    
            return bookReturn;
        }
        else {
            return null;   
        }
    }

    @AuraEnabled
    public static List<PropStrength__Projects__c> searchProjectRecord(String searchKeyWrd, String recId){
        List<PropStrength__Projects__c> projList = new List<PropStrength__Projects__c>();
        List<PropStrength__Projects__c> returnList = new List<PropStrength__Projects__c>();
        
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            projList = [SELECT Id, Name, (SELECT Id FROM PropStrength__Application_Booking__r) FROM PropStrength__Projects__c WHERE Name LIKE :searchKeyWrd];
        } else {
            projList = [SELECT Id, Name, (SELECT Id FROM PropStrength__Application_Booking__r) FROM PropStrength__Projects__c];
        }

        for(PropStrength__Projects__c proj : projList) {
            if(!proj.PropStrength__Application_Booking__r.isEmpty()) {
                returnList.add(proj);
            }
        }

        return returnList;
    }

    @AuraEnabled
    public static List<PropStrength__Tower__c> searchTowersRecord(String searchKeyWrd, String recId){
        List<PropStrength__Tower__c> projList = new List<PropStrength__Tower__c>();
        List<PropStrength__Tower__c> returnList = new List<PropStrength__Tower__c>();
        
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            projList = [SELECT Id, PropStrength__Tower_Name__c, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c WHERE PropStrength__Tower_Name__c LIKE :searchKeyWrd];
        } else {
            projList = [SELECT Id, PropStrength__Tower_Name__c, (SELECT Id FROM PropStrength__Properties__r) FROM PropStrength__Tower__c];
        }

        for(PropStrength__Tower__c proj : projList) {
            if(!proj.PropStrength__Properties__r.isEmpty()) {
                returnList.add(proj);
            }
        }

        return returnList;
    }

    @AuraEnabled
    public static List<PropStrength__Application_Booking__c> searchBookingsRecord(String searchKeyWrd){
        List<PropStrength__Application_Booking__c> projList = new List<PropStrength__Application_Booking__c>();
        
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            return[SELECT Id, Name FROM PropStrength__Application_Booking__c WHERE Name LIKE :searchKeyWrd AND PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
        } else {
            return [SELECT Id, Name FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
        }
    }
    @AuraEnabled
    public static List<String> searchUnitRecord(String searchKeyWrd){
        List<String> unitName = new List<String>();
        List<PropStrength__Application_Booking__c> appList = new List<PropStrength__Application_Booking__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            appList = [SELECT Id, Name, House_Unit_No__c FROM PropStrength__Application_Booking__c WHERE House_Unit_No__c LIKE :searchKeyWrd AND PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
        } else {
            appList = [SELECT Id, Name,House_Unit_No__c FROM PropStrength__Application_Booking__c WHERE PropStrength__Project__c != null AND PropStrength__Property__c != null AND PropStrength__Property__r.PropStrength__Tower__c != null];
        }
        for(PropStrength__Application_Booking__c app : appList) {
            if(!unitName.contains(app.House_Unit_No__c)) {
                unitName.add(app.House_Unit_No__c);
            }
        }
        return unitName;
    }
    @AuraEnabled
    public static List<String> searchCustomerRecord(String searchKeyWrd){
        List<String> customerName = new List<String>();
        List<PropStrength__Applicant_Detail__c> appDetList = new List<PropStrength__Applicant_Detail__c>();
        if(searchKeyWrd != null && searchKeyWrd != '' && searchKeyWrd != 'undefined') {
            searchKeyWrd = '%'+searchKeyWrd+'%';
            appDetList = [SELECT Id, Name,PropStrength__Applicant_Acc__c, PropStrength__Applicant_Acc__r.Name FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Applicant_Acc__r.Name Like :searchKeyWrd AND PropStrength__Application__c != null AND PropStrength__Active__c = true ];
        } else {
            appDetList = [SELECT Id, Name,PropStrength__Applicant_Acc__c, PropStrength__Applicant_Acc__r.Name FROM PropStrength__Applicant_Detail__c WHERE PropStrength__Application__c != null AND PropStrength__Active__c = true ];
        }
        for(PropStrength__Applicant_Detail__c app : appDetList) {
            if(!customerName.contains(app.PropStrength__Applicant_Acc__r.Name)) {
                customerName.add(app.PropStrength__Applicant_Acc__r.Name);
            }
        }
        return customerName;
    }
}