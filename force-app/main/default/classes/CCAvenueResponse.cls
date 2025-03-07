public class CCAvenueResponse {

	public String error_desc;
	public String invoice_id;
	public String tiny_url;
	public String qr_code;
	public Integer invoice_status;
	public String error_code;

	public static CCAvenueResponse parse(String json) {
		return (CCAvenueResponse) System.JSON.deserialize(json, CCAvenueResponse.class);
	}

    public class CCAvenueStatusResponse {
        public String error_desc;
        public String error_code;
        public String order_status;
        public String status;
        public String reference_no;
        
    }
}