public class WhatsAppLeadCapturePOJO {
    public String FirstName {get;set;} 
    public String LastName {get;set;} 
    public String Nationality {get;set;} 
    public String Email {get;set;} 
    public String RDS_Country_Code {get;set;} 
    public String Mobile_Phone {get;set;} 
    public String Website_Language {get;set;} 
    public String Preferre_Method_of_Contact {get;set;} 
    public String News_Offers_subscription {get;set;} 
    public String Privacy_Policy_Acknowledgement {get;set;} 
    public String Project_Name {get;set;} 
    public String campaign_Code {get;set;} 
    public String Campaign_Name {get;set;} 
    public String Ad_set_ID {get;set;} 
    public String Ad_group {get;set;} 
    public String Time_Spent_before_Form_Submit {get;set;} 
    public String IP_Address {get;set;} 
    public String Landing_Page_URL {get;set;} 
    public String Platform {get;set;} 
    public String Browser {get;set;} 
    public String network {get;set;} 
    public String project {get;set;} 
    public String Resolution {get;set;} 
    public String OS {get;set;} 
    public String Device {get;set;} 
    public String MatchType {get;set;} 
    public String AdPosition {get;set;} 
    public String Web_Banner_Size {get;set;} 
    public String Digital_Source {get;set;} 
    public String Lead_Source {get;set;} 
    public String Goal {get;set;} 
    public String Channel_Cluster {get;set;} 
    public String Last_Mile_Conversion {get;set;} 
    public String Bid_Type {get;set;} 
    public String UTM_Source {get;set;} 
    public String UTM_Term {get;set;} 
    public String UTM_Medium {get;set;} 
    public String UTM_Campaign {get;set;} 
    public String UTM_Content {get;set;} 
    public String utm_company {get;set;} 
    public String utm_adset {get;set;} 
    public String utm_creative {get;set;} 
    public String utm_country {get;set;} 
    public String utm_language {get;set;} 
    public String UTM_CampaignId {get;set;} 
    public String utm_adsetid {get;set;} 
    public String utm_adid {get;set;} 
    public String utm_adgroup {get;set;} 
    public String GCLID {get;set;} 
    public String Meta_Lead_ID {get;set;} 
    public String BedroomType {get;set;} 
    public String areYouLookingFor {get;set;} 
    public String Project_Type {get;set;} 
    public String Time_of_Visit {get;set;} 
    
    public WhatsAppLeadCapturePOJO(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'FirstName') {
                        FirstName = parser.getText();
                    } else if (text == 'LastName') {
                        LastName = parser.getText();
                    } else if (text == 'Nationality') {
                        Nationality = parser.getText();
                    } else if (text == 'Email') {
                        Email = parser.getText();
                    } else if (text == 'RDS_Country_Code') {
                        RDS_Country_Code = parser.getText();
                    } else if (text == 'Mobile_Phone') {
                        Mobile_Phone = parser.getText();
                    } else if (text == 'Website_Language') {
                        Website_Language = parser.getText();
                    } else if (text == 'Preferre_Method_of_Contact') {
                        Preferre_Method_of_Contact = parser.getText();
                    } else if (text == 'News_Offers_subscription') {
                        News_Offers_subscription = parser.getText();
                    } else if (text == 'Privacy_Policy_Acknowledgement') {
                        Privacy_Policy_Acknowledgement = parser.getText();
                    } else if (text == 'Project_Name') {
                        Project_Name = parser.getText();
                    } else if (text == 'campaign_Code') {
                        campaign_Code = parser.getText();
                    } else if (text == 'Campaign_Name') {
                        Campaign_Name = parser.getText();
                    } else if (text == 'Ad_set_ID') {
                        Ad_set_ID = parser.getText();
                    } else if (text == 'Ad_group') {
                        Ad_group = parser.getText();
                    } else if (text == 'Time_Spent_before_Form_Submit') {
                        Time_Spent_before_Form_Submit = parser.getText();
                    } else if (text == 'IP_Address') {
                        IP_Address = parser.getText();
                    } else if (text == 'Landing_Page_URL') {
                        Landing_Page_URL = parser.getText();
                    } else if (text == 'Platform') {
                        Platform = parser.getText();
                    } else if (text == 'Browser') {
                        Browser = parser.getText();
                    } else if (text == 'network') {
                        network = parser.getText();
                    } else if (text == 'project') {
                        project = parser.getText();
                    } else if (text == 'Resolution') {
                        Resolution = parser.getText();
                    } else if (text == 'OS') {
                        OS = parser.getText();
                    } else if (text == 'Device') {
                        Device = parser.getText();
                    } else if (text == 'MatchType') {
                        MatchType = parser.getText();
                    } else if (text == 'AdPosition') {
                        AdPosition = parser.getText();
                    } else if (text == 'Web_Banner_Size') {
                        Web_Banner_Size = parser.getText();
                    } else if (text == 'Digital_Source') {
                        Digital_Source = parser.getText();
                    } else if (text == 'Lead_Source') {
                        Lead_Source = parser.getText();
                    } else if (text == 'Goal') {
                        Goal = parser.getText();
                    } else if (text == 'Channel_Cluster') {
                        Channel_Cluster = parser.getText();
                    } else if (text == 'Last_Mile_Conversion') {
                        Last_Mile_Conversion = parser.getText();
                    } else if (text == 'Bid_Type') {
                        Bid_Type = parser.getText();
                    } else if (text == 'UTM_Source') {
                        UTM_Source = parser.getText();
                    } else if (text == 'UTM_Term') {
                        UTM_Term = parser.getText();
                    } else if (text == 'UTM_Medium') {
                        UTM_Medium = parser.getText();
                    } else if (text == 'UTM_Campaign') {
                        UTM_Campaign = parser.getText();
                    } else if (text == 'UTM_Content') {
                        UTM_Content = parser.getText();
                    } else if (text == 'utm_company') {
                        utm_company = parser.getText();
                    } else if (text == 'utm_adset') {
                        utm_adset = parser.getText();
                    } else if (text == 'utm_creative') {
                        utm_creative = parser.getText();
                    } else if (text == 'utm_country') {
                        utm_country = parser.getText();
                    } else if (text == 'utm_language') {
                        utm_language = parser.getText();
                    } else if (text == 'UTM_CampaignId') {
                        UTM_CampaignId = parser.getText();
                    } else if (text == 'utm_adsetid') {
                        utm_adsetid = parser.getText();
                    } else if (text == 'utm_adid') {
                        utm_adid = parser.getText();
                    } else if (text == 'utm_adgroup') {
                        utm_adgroup = parser.getText();
                    } else if (text == 'GCLID') {
                        GCLID = parser.getText();
                    } else if (text == 'Meta_Lead_ID') {
                        Meta_Lead_ID = parser.getText();
                    } else if (text == 'BedroomType') {
                        BedroomType = parser.getText();
                    } else if (text == 'areYouLookingFor') {
                        areYouLookingFor = parser.getText();
                    } else if (text == 'Project_Type') {
                        Project_Type = parser.getText();
                    } else if (text == 'Time_of_Visit') {
                        Time_of_Visit = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static WhatsAppLeadCapturePOJO parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new WhatsAppLeadCapturePOJO(parser);
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
}