@RestResource(urlMapping='/filenotebookingapi/*')
global with sharing class FileNoteBookingAPI {
    
    @HttpGet
    global static FileNoteBookingAPIWrapper doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String bookingId;
        try{	
            FileNoteBookingAPIWrapper exposeData = new FileNoteBookingAPIWrapper();
            List<Booking__c> bookingList;
            if (Test.isRunningTest()) {
                bookingList = [Select id,
                               Unit__c,Name,
                               Unit__r.Unit_Name__c,
                               Unit__r.Name,
                               Unit__r.Project__r.Name,
                               Unit__r.Unit_Type__c,
                               Unit__r.Unit_Status__c,
                               Stage_of_Booking__c,//SOB-405 adding field in query
                               Project__r.Name,Primary_Applicant_Name__c,
                               Opportunity__r.Applicant_Name__c ,
                               Opportunity__r.Other_Applicants_Name__c,
                               Nationality__c ,
                               CreatedDate,
                               Carpet_Area__c,
                               Agreement_Value__c,
                               Agreement_Value_Arabic__c  ,
                               Paid_Percentage__c ,
                               SPA_Executed__c ,
                               Pre_Registration_Status__c ,
                               Sales_Managers__r.Name, 
                               Sales_Head__r.Name,
                               Channel_Partner__r.Name,
                               Total_On_Account_Money__c ,
                               Sobha_Connect__r.Name,
                               Quotation__r.Chargeable_Area__c,  
                               Source_of_Booking__c,
                               Sales_Head__r.Manager.Name,
                               Sales_Head__r.Manager.email,
                               Status__c,cluster__c,tower__c,
                               (Select Name,Nationality__c, Email_Address__c from ApplicantDetails__r where Applicant_Number__c = 'Primary Applicant' limit 1)
                               From Booking__c];
            } else {
				bookingId = req.params.get('bookingid');
                if (bookingId == null) {
                    exposeData.success = false;exposeData.statusCode = 400;exposeData.errorMessage = 'No Booking Id';return exposeData;
                }
            
            	bookingList = [Select id,
                               Unit__c,Name,Primary_Applicant_Name__c,
                               Unit__r.Unit_Name__c,
                               Unit__r.Name,
                               Unit__r.Project__r.Name,
                               Unit__r.Unit_Type__c,
                               Unit__r.Unit_Status__c,
                               Stage_of_Booking__c,//SOB-405 adding field in query
                               Project__r.Name,
                               Opportunity__r.Applicant_Name__c ,
                               Opportunity__r.Other_Applicants_Name__c,
                               Nationality__c ,
                               CreatedDate,
                               Carpet_Area__c,cluster__c,tower__c,
                               Agreement_Value__c,
                               Agreement_Value_Arabic__c  ,
                               Paid_Percentage__c ,
                               SPA_Executed__c ,
                               Pre_Registration_Status__c ,
                               Sales_Managers__r.Name, 
                               Sales_Head__r.Name,
                               Channel_Partner__r.Name,
                               Total_On_Account_Money__c ,
                               Sobha_Connect__r.Name,
                               Quotation__r.Chargeable_Area__c,  
                               Source_of_Booking__c,
                               Sales_Head__r.Manager.Name,
                               Sales_Head__r.Manager.email,
                               Status__c,
                               Booking_Approver_Audit__c,
                               Audit_Approval_Date__c,
                               (Select Name, Email_Address__c,Nationality__c from ApplicantDetails__r where Applicant_Number__c = 'Primary Applicant' limit 1)
                               
                               From Booking__c where name=:bookingId];
            }
            
            
            if (bookingList.size() == 0) {
                exposeData.success = false;
                exposeData.statusCode = 400;
                exposeData.errorMessage = 'No booking with given booking Id';            
                return exposeData;
            }
            
            BookingDataWrapper wrap = new BookingDataWrapper();
            wrap.Unit_No = bookingList[0].Unit__r.Name;
            wrap.Project = bookingList[0].cluster__c != null && bookingList[0].tower__c!= null? bookingList[0].cluster__c +'-'+ bookingList[0].tower__c:bookingList[0].tower__c;
            wrap.booking_id = bookingList[0].Name;
            wrap.customer_name = bookingList[0].Primary_Applicant_Name__c;
            wrap.nationality = bookingList[0].ApplicantDetails__r != null && bookingList[0].ApplicantDetails__r.size() > 0 ? bookingList[0].ApplicantDetails__r[0].Nationality__c : null;
            wrap.booking_date = Datetime.newInstance(bookingList[0].CreatedDate.year(),bookingList[0].CreatedDate.month(),bookingList[0].CreatedDate.day(),bookingList[0].CreatedDate.hour(),bookingList[0].CreatedDate.minute(),bookingList[0].CreatedDate.second()).format('dd-MMM-YYYY HH:MM:SS','Asia/Dubai');
            wrap.Saleable_Area = bookingList[0].Quotation__r.Chargeable_Area__c != null ?bookingList[0].Quotation__r.Chargeable_Area__c.format() + ' SqFt.' : null;
            wrap.Purchased_Price_Aed = bookingList[0].Agreement_Value__c != null ? bookingList[0].Agreement_Value__c.format(): null;
            wrap.customer_paid_AED = bookingList[0].Total_On_Account_Money__c.format() != null ? bookingList[0].Total_On_Account_Money__c.format() : null;
            wrap.paid_percentage = bookingList[0].Paid_Percentage__c;
            wrap.SPA_status = bookingList[0].SPA_Executed__c;
            wrap.Preregistration_Status = bookingList[0].Pre_Registration_Status__c;
            wrap.Sales_Head = bookingList[0].Sales_Head__r.Name;
            wrap.Sales_Manager = bookingList[0].Sales_Managers__r.Name;
            wrap.VP_Name  = bookingList[0].Sales_Head__r.Manager.Name;
            wrap.VP_Email = bookingList[0].Sales_Head__r.Manager.Email;
            wrap.Unit_Status  = bookingList[0].Stage_of_Booking__c;//SOB-405 updted mapping
            wrap.Unit_Type = bookingList[0].Unit__r.Unit_Type__c;
            
            if (bookingList[0].Source_of_Booking__c  == 'Channel Partner') {
                wrap.broker_name = bookingList[0].Channel_Partner__r.Name;
            } else if (bookingList[0].Source_of_Booking__c  == 'Sobha Connect') {
                wrap.broker_name = bookingList[0].Sobha_Connect__r.Name;
            }
            
            wrap.AlSiniya_Island = bookingList[0].Unit__r.Project__r.Name == 'Sobha Siniya Island';
            wrap.Data_As_On = System.now().format('dd-MMM-YYYY HH:MM:SS','Asia/Dubai');
            wrap.Booking_Form_Status = bookingList[0].Status__c;
            wrap.Url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+bookingList[0].Id;
            wrap.Audit_Status = bookingList[0].Booking_Approver_Audit__c != null ? bookingList[0].Booking_Approver_Audit__c : null;
            wrap.Audit_Approval_Date = bookingList[0].Audit_Approval_Date__c != null ? bookingList[0].Audit_Approval_Date__c : null;
            exposeData.success = true;
            exposeData.statusCode = 200;
            exposeData.bookingData = wrap;

            return exposeData;
               
        }catch(Exception e) {
            System.debug('Your exception message here....'+e.getMessage());
            FileNoteBookingAPIWrapper exposeData = new FileNoteBookingAPIWrapper();
            exposeData.success = false; exposeData.statusCode = 400; exposeData.errorMessage = 'Internal server error';  return exposeData;
        }
    }
    
    global with sharing class FileNoteBookingAPIWrapper{
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
        public Decimal Unallocated_Payment;//** */
        public Decimal Paid_Percentage;
        public String Booking_Form_Status;//** */
        public String Booking_ID;
        public String  Booking_Date;
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
        public Boolean AlSiniya_Island;
    }
}