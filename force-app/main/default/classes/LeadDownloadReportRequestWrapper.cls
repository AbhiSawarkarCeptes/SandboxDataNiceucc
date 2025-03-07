public class LeadDownloadReportRequestWrapper {
    public String first_name;
    public String last_name;
    public String organization_name;
    public String email;
    public String country_code;
    public String phone;
    public String preferred_mode_of_contact;
    public String privacy_policy;
    public String news_offers;
    
    public static LeadDownloadReportRequestWrapper parse(String json) {
        return (LeadDownloadReportRequestWrapper) System.JSON.deserialize(json, LeadDownloadReportRequestWrapper.class);
    }
}