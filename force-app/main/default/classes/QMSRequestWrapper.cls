public class QMSRequestWrapper {
    public class GetUnitInfoWrapper{
        public String towerId;
        public String unitId;
    }
    
    public class postVisitInfoWrapper{
        Public String email;
        public String mobile;
        public string description;
        public string requestType;
        public string bookingId;
        public string internalDescription;
        public string tokenNumber;
        public string issuedTime;
        public string serviceName;
        public String passport;// Base64 encoded string
       
    }
    
    public class postTokenCalledInfoWrapper{
        public string caseID;
        public string emailId;
    }
    
    public class PostVisitEndInfoWrapper{
        public string caseID;
        public string description;
        public Integer servingTime;
    }
}