public class QMSResponseWrapper {
    
    public class GetUnitInfoWrapper {
        public String id;
        public String ApplicantName;
        public String Applicant_Number;
        public String PassportNo;
        public String Emirates_ID;  
        public String Email;  
        public String MobileNumber; 
        public string BookingId;
        public string BookingNumber;
        public string UnitNumber;
        public Date EidExpiry;
        public Date PassportExpiry;
    }
    
    public class postVisitInfoWrapper {
        public string ApplicantName;
        public string Email;
        public string Mobile;
        public string RMName;
        public string RMEmail;
        public string caseId;
        public String CollectionName;
        public String CollectionEmail;
    }
    
    Public class getUnitHttpResponseWrapper{
        Public String status;
        Public Integer statusCode;
        Public List<GetUnitInfoWrapper> data = new List<GetUnitInfoWrapper>();
        Public boolean success;
        Public String Message;
    }
    
    public class postCaseVisitHttpResponseWrapper{
         Public String status;
        Public Integer statusCode;
       Public postVisitInfoWrapper data = new postVisitInfoWrapper();
        Public boolean success;
        Public String Message;
    }
    public class postCaseTransferResponseWrapper{
         Public String status;
        Public Integer statusCode;
        Public boolean success;
        Public String Message;
    }
}