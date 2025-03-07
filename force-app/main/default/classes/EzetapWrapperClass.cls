public class EzetapWrapperClass {
	public class StartRequestWrapper{
        public String appKey;
        public String username;
        public Decimal amount;
        public String externalRefNumber;
        public String externalRefNumber2;
        public PushTo pushTo;
        public String paymentMode;
    }
    
    public class PushTo{
        public String deviceId;
    }
    
    public class StatusRequestWrapper{
        public String password;
        public String appKey;
        public String username;
        public String origP2pRequestId;
    }
    
    public class StartResponseWrapper{
        public Boolean success;
        public String messageCode;
        public String message;
        public String errorCode;
        public String errorMessage;
        public String realCode;
        public String apiMessageTitle;
        public String apiMessage;
        public String apiMessageText;
        public String apiWarning;
        public String p2pRequestId;
    }
    
    public class StatusResponseWrapper{
        public Boolean success;
        public String messageCode;
        public String message;
        public String realCode;
        public String sessionKey;
        public String username;
        public Boolean dccOpted;
        public Integer cardHolderCurrencyExponent;
        public Boolean signable;
        public Boolean voidable;
        public Boolean refundable;
        public Integer maximumPayAttemptsAllowed;
        public Integer maximumSuccessfulPaymentAllowed;
        public Boolean noExpiryFlag;
        public Boolean signReqd;
        public Boolean customerNameAvailable;
        public Boolean callbackEnabled;
        public Boolean onlineRefundable;
        public Boolean tipEnabled;
        public Boolean callTC;
        public Boolean processCronOutput;
        public Boolean externalDevice;
        public Boolean tipAdjusted;
        public String acquisitionId;
        public String acquisitionKey;
        public Integer middlewareStanNumber;
        public Boolean otpRequired;
        public Boolean redirect;
        public Boolean twoStepConfirmPreAuth;
        public Boolean reload;
        public String p2pRequestId;
    }
}