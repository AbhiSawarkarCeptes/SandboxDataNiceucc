@RestResource(urlMapping='/filenoteapplicationbookingapi/*')
global with sharing class FileNoteApplicationBookingAPI {
    
    @HttpGet
    global static FileNoteApplicationBookingAPIWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bookingId;
        try{	
            FileNoteApplicationBookingAPIWrapper exposeData = new FileNoteApplicationBookingAPIWrapper();
            List<PropStrength__Application_Booking__c> bookingList;
            if (Test.isRunningTest()) {
                bookingList = [SELECT id,
                                PropStrength__Property__c,Name,
                                PropStrength__Property__r.PropStrength__Property_Name__c,
                                PropStrength__Property__r.Name,
                                PropStrength__Property__r.PropStrength__Unit_Type__c,
                                PropStrength__Property__r.PropStrength__Unit_Status__c,
                                Project_Name__c,PropStrength__Primary_Applicant_Name__c,
                                PropStrength__Booking_Date__c,
                                PropStrength__Revised_Total_Sales_Consideration__c,
                                PropStrength__Total_Paid_Percent__c,
                                SPA_Status__c ,
                                Pre_Registration_Status__c ,
                                Sales_Manager__r.Name, 
                                Sales_Head__r.Name,
                                PropStrength__Broker_Name__c,
                                PropStrength__Total_Payment_Received__c ,
                                PropStrength__Super_Area__c,  
                                Sales_Head__r.Manager.Name,
                                Sales_Head__r.Manager.email,
                                PropStrength__Status__c,PropStrength__Tower__c,
                                (Select Name,
                                Nationality_Doc__c, 
                                PropStrength__Applicant_Email__c 
                                FROM PropStrength__Applicant_Details__r WHERE PropStrength__Type__c = '1st Applicant' limit 1)
                                FROM PropStrength__Application_Booking__c];
            } else {
				bookingId = req.params.get('bookingid');
                if (bookingId == null) {
                    exposeData.success = false;
                    exposeData.statusCode = 400;
                    exposeData.errorMessage = 'No Booking Id';
                    return exposeData;
                }
            
                bookingList = [SELECT id,
                                PropStrength__Property__c,Name,PropStrength__Primary_Applicant_Name__c,
                                PropStrength__Property__r.PropStrength__Property_Name__c,
                                PropStrength__Property__r.Name,
                                PropStrength__Property__r.PropStrength__Unit_Type__c,
                                PropStrength__Property__r.PropStrength__Unit_Status__c,
                                Project_Name__c,
                                PropStrength__Booking_Date__c,
                                PropStrength__Tower__c,
                                PropStrength__Revised_Total_Sales_Consideration__c,
                                PropStrength__Total_Paid_Percent__c ,
                                SPA_Status__c ,
                                Pre_Registration_Status__c ,
                                Sales_Manager__r.Name, 
                                Sales_Head__r.Name,
                                PropStrength__Broker_Name__c,
                                PropStrength__Total_Payment_Received__c ,
                                PropStrength__Super_Area__c,  
                                Sales_Head__r.Manager.Name,
                                Sales_Head__r.Manager.email,
                                PropStrength__Status__c,
                                Booking_Approver_Audit__c,
                                Booking_Form_Verified_by_Audit_Date__c,
                                (Select Name, 
                                Nationality_Doc__c, 
                                PropStrength__Applicant_Email__c
                                FROM PropStrength__Applicant_Details__r WHERE PropStrength__Type__c = '1st Applicant' limit 1)
                                FROM PropStrength__Application_Booking__c WHERE name=:bookingId];
            }
            
            
            if (bookingList.size() == 0) {
                exposeData.success = false;
                exposeData.statusCode = 400;
                exposeData.errorMessage = 'No booking with given booking Id';            
                return exposeData;
            }
            
            Date myDate = bookingList[0].PropStrength__Booking_Date__c;
            Time myTime = Time.newInstance(0, 0, 0, 0); 
            DateTime myDateTime = DateTime.newInstance(myDate, myTime);
            
            BookingDataWrapper wrap = new BookingDataWrapper();
            wrap.Unit_No = bookingList[0].PropStrength__Property__r.Name;
            wrap.Project = bookingList[0].Project_Name__c != null && bookingList[0].PropStrength__Tower__c!= null? bookingList[0].Project_Name__c +'-'+ bookingList[0].PropStrength__Tower__c:bookingList[0].PropStrength__Tower__c;
            wrap.booking_id = bookingList[0].Name;
            wrap.customer_name = bookingList[0].PropStrength__Primary_Applicant_Name__c;
            wrap.nationality = bookingList[0].PropStrength__Applicant_Details__r != null && bookingList[0].PropStrength__Applicant_Details__r.size() > 0 ? bookingList[0].PropStrength__Applicant_Details__r[0].Nationality_Doc__c : null;
            wrap.booking_date = Datetime.newInstance(myDateTime.year(),myDateTime.month(),myDateTime.day(),myDateTime.hour(),myDateTime.minute(),myDateTime.second()).format('dd-MMM-YYYY HH:MM:SS','Asia/Dubai');
            wrap.Saleable_Area = bookingList[0].PropStrength__Super_Area__c != null ?bookingList[0].PropStrength__Super_Area__c.format() + ' SqFt.' : null;
            wrap.Purchased_Price_Aed = bookingList[0].PropStrength__Revised_Total_Sales_Consideration__c != null ? bookingList[0].PropStrength__Revised_Total_Sales_Consideration__c.format(): null;
            wrap.customer_paid_AED = bookingList[0].PropStrength__Total_Payment_Received__c != null ? bookingList[0].PropStrength__Total_Payment_Received__c.format() : null;
            wrap.paid_percentage = bookingList[0].PropStrength__Total_Paid_Percent__c;
            wrap.SPA_status = bookingList[0].SPA_Status__c;
            wrap.Preregistration_Status = bookingList[0].Pre_Registration_Status__c;
            wrap.Sales_Head = bookingList[0].Sales_Head__r.Name;
            wrap.Sales_Manager = bookingList[0].Sales_Manager__r.Name;
            wrap.VP_Name  = bookingList[0].Sales_Head__r.Manager.Name;
            wrap.VP_Email = bookingList[0].Sales_Head__r.Manager.Email;
            wrap.Unit_Status  = bookingList[0].PropStrength__Property__r.PropStrength__Unit_Status__c;
            wrap.Unit_Type = bookingList[0].PropStrength__Property__r.PropStrength__Unit_Type__c;
            wrap.broker_name = bookingList[0].PropStrength__Broker_Name__c;
            wrap.Data_As_On = System.now().format('dd-MMM-YYYY HH:MM:SS','Asia/Dubai');
            wrap.Booking_Form_Status = bookingList[0].PropStrength__Status__c;
            wrap.Url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+bookingList[0].Id;
            wrap.Audit_Status = bookingList[0].Booking_Approver_Audit__c != null ? bookingList[0].Booking_Approver_Audit__c : null;
            wrap.Audit_Approval_Date = bookingList[0].Booking_Form_Verified_by_Audit_Date__c != null ? bookingList[0].Booking_Form_Verified_by_Audit_Date__c : null;
            exposeData.success = true;
            exposeData.statusCode = 200;
            exposeData.bookingData = wrap;

            return exposeData;
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            FileNoteApplicationBookingAPIWrapper exposeData = new FileNoteApplicationBookingAPIWrapper();
            exposeData.success = false; exposeData.statusCode = 400; exposeData.errorMessage = 'Internal server error';  return exposeData;
        }
    }
    
    global with sharing class FileNoteApplicationBookingAPIWrapper{
        Public Boolean success;
        public Integer statusCode;
        public String errorMessage;
        public BookingDataWrapper bookingData;
    }
    
    public class BookingDataWrapper {
        public String VP_Name;
        public String VP_Email;
        public String Sales_Head;
        public String Sales_Manager;
        public String Project;
        public String Saleable_Area;
        public String Unit_No;
        public String Unit_Type;
        public String Unit_Status;
        public String Purchased_Price_AED;
        public Decimal Unallocated_Payment;
        public Decimal Paid_Percentage;
        public String Booking_Form_Status;
        public String Booking_ID;
        public String Booking_Date;
        public String SPA_Status;
        public String Preregistration_Status;
        public String Customer_Name;
        public String Customer_Paid_AED;
        public String Nationality;
        public String Broker_Name;
        public String Data_As_On;
        public String Url;
        public String Audit_Status;
        public Date Audit_Approval_Date;
    }
}