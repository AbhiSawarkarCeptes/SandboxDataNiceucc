public class CCAvenueRequestWrapper {

	public String customer_name {get;set;} 
	public String bill_delivery_type {get;set;} 
	public Long customer_mobile_no {get;set;} 
	public String customer_email_id {get;set;} 
	public String customer_email_subject {get;set;} 
	public String invoice_description {get;set;} 
	public String currency_Z {get;set;} // in json: currency
	public Integer valid_for {get;set;} 
	public String valid_type {get;set;} 
	public Decimal amount {get;set;} 
	public Integer merchant_reference_no {get;set;} 
	public String  terms_and_conditions  {get;set;} 

    public CCAvenueRequestWrapper() {

    }

	/*public CCAvenueRequestWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'customer_name') {
						customer_name = parser.getText();
					} else if (text == 'bill_delivery_type') {
						bill_delivery_type = parser.getText();
					} else if (text == 'customer_mobile_no') {
						customer_mobile_no = parser.getLongValue();
					} else if (text == 'customer_email_id') {
						customer_email_id = parser.getText();
					} else if (text == 'customer_email_subject') {
						customer_email_subject = parser.getText();
					} else if (text == 'invoice_description') {
						invoice_description = parser.getText();
					} else if (text == 'currency') {
						currency_Z = parser.getText();
					} else if (text == 'valid_for') {
						valid_for = parser.getIntegerValue();
					} else if (text == 'valid_type') {
						valid_type = parser.getText();
					} else if (text == 'amount') {
						amount = parser.getIntegerValue();
					} else if (text == 'merchant_reference_no') {
						merchant_reference_no = parser.getIntegerValue();
					} else if (text == ' terms_and_conditions ') {
						 terms_and_conditions  = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'CCAvenueRequestWrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static CCAvenueRequestWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CCAvenueRequestWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	

    public static string getencRequest(string customer_name
                                       , string merchant_id
                                       , string bill_delivery_type
                                       , string customer_mobile_no
                                       , string customer_email_id
                                       , string currency_Z
                                      , string valid_type
                                      , Integer valid_for
                                      , Decimal amount
                                      , string merchant_reference_no
                                      ){
        String encRequest='';
        String PLAIN_Request ='';
        PLAIN_Request = PLAIN_Request +'&'+  'customer_name=' + customer_name;
        PLAIN_Request = PLAIN_Request +'&'+  'merchant_id=' + merchant_id;
        PLAIN_Request = PLAIN_Request +'&'+  'bill_delivery_type=' + bill_delivery_type;
        PLAIN_Request = PLAIN_Request +'&'+  'customer_mobile_no=' + customer_mobile_no;
        PLAIN_Request = PLAIN_Request +'&'+  'customer_email_id=' + customer_email_id;
        PLAIN_Request = PLAIN_Request +'&'+  'currency_Z=' + currency_Z;
        PLAIN_Request = PLAIN_Request +'&'+  'valid_type=' + valid_type;
        PLAIN_Request = PLAIN_Request +'&'+  'valid_for=' + valid_for;
        PLAIN_Request = PLAIN_Request +'&'+  'amount=' + amount;
        PLAIN_Request = PLAIN_Request +'&'+  'merchant_reference_no=' + merchant_reference_no;
        
        system.debug('PLAIN_Request' + PLAIN_Request);                                  
                                          
        Blob cryptoKey = Blob.valueOf('');
        Blob hash = Crypto.generateDigest('MD5', cryptoKey );
        Blob data = Blob.valueOf(PLAIN_Request);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', hash , data);
        encRequest = EncodingUtil.convertToHex(encryptedData );
                                          
        return encRequest;
    }*/

    public class CCAvenueStatusRequestWrapper {
      //  public String referenceNumber;
        public String reference_no;
		public String order_no;
        
        public CCAvenueStatusRequestWrapper() {
            
        }
    }

}