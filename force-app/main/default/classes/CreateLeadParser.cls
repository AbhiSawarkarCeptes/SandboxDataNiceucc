public class CreateLeadParser {
 
    public String Name {get;set;}
    public String Lead_Source {get;set;}
    public String Web_Source {get;set;}
    public String Lead_Sub_Source {get;set;}
    public String AD_Group {get;set;}
    public String Keyword {get;set;}
    public String Placement {get;set;}
    public String Channel_Cluster {get;set;}
    public String Goal {get;set;}
    public String Digital_Source {get;set;}
    public String UTM_Source {get;set;}
    public String UTM_Medium {get;set;}
    public String UTM_Campaign {get;set;}
    public String UTM_Content {get;set;}
    public String Last_Mile_Conversion {get;set;}
    public String Bid_Type {get;set;}
    public String Email {get;set;}
    public String Dialing_Country {get;set;}
    public String Country_Code {get;set;}
    public String Mobile_Phone {get;set;}
    public String Phone {get;set;}
    public String Website_Language {get;set;}
    public String Project {get;set;}
    public String Project_Type {get;set;}
    public String Unit_Type {get;set;}
    public String BudgetInAed {get;set;}
    public String BudgetInUsd {get;set;}
    public String BedroomType {get;set;}
    public String Nationality {get;set;}
    public String RDS_Country_Code{get;set;}
    public String Preferre_Method_of_Contact{get;set;}
    public Boolean News_Offers_subscription{get;set;}
    public Boolean Privacy_Policy_Acknowledgement{get;set;}
    public String Project_Name{get;set;}
    public String campaign_Code{get;set;}
    public String Campaign_Name{get;set;}
    public String Ad_set_ID{get;set;}
    public String Time_Spent_before_Form_Submit{get;set;}
    public String IP_Address{get;set;}
    public String Landing_Page_URL{get;set;}
    public String Platform{get;set;}
    public String Browser{get;set;}
    public String network{get;set;}
    public String Resolution{get;set;}
    public String OS{get;set;}
    public String Device{get;set;}
    public String MatchType{get;set;}
    public String AdPosition{get;set;}
    public String utmTerm{get;set;}
    public String webBannerSize{get;set;}
    public String GCLID {get;set;}
    public String leadID {get;set;}
    public String lastName {get;set;}
    public String firstName {get;set;}
    //Added by Mohit as part of SOB - 760
    public String UTM_AdId {get;set;}
    public String UTM_Adset {get;set;}
    public String UTM_AdsetId {get;set;}
    public String UTM_Company {get;set;}
    public String UTM_Country {get;set;}
    public String UTM_Creative {get;set;}
    public String UTM_Language {get;set;}
    public String UTM_CampaignId {get;set;}
    public String uTM_adgroup{get;set;}
    public String areYouLookingFor{get;set;}
    public String Meta_Lead_ID{get;set;}
   
    public CreateLeadParser(JSONParser parser) {
        News_Offers_subscription=false;
        Privacy_Policy_Acknowledgement=false;
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'Name') {
                        Name = parser.getText();
                    } else if (text == 'Lead_Source') {
                        Lead_Source = parser.getText();
                    } else if (text == 'Web_Source') {
                        Web_Source = parser.getText();
                    } else if (text == 'Lead_Sub_Source') {
                        Lead_Sub_Source = parser.getText();
                    } else if (text == 'AD_Group') {
                        AD_Group = parser.getText();
                    } else if (text == 'Keyword') {
                        Keyword = parser.getText();
                    } else if (text == 'Placement') {
                        Placement = parser.getText();
                    } else if (text == 'Channel_Cluster') {
                        Channel_Cluster = parser.getText();
                    } else if (text == 'Goal') {
                        Goal = parser.getText();
                    } else if (text == 'Digital_Source') {
                        Digital_Source = parser.getText();
                    } else if (text == 'UTM_Source') {
                        UTM_Source = parser.getText();
                    } else if (text == 'UTM_Medium') {
                        UTM_Medium = parser.getText();
                    } else if (text == 'UTM_Campaign') {
                        UTM_Campaign = parser.getText();
                    } else if (text == 'UTM_Content') {
                        UTM_Content = parser.getText();
                    } else if (text == 'Last_Mile_Conversion') {
                        Last_Mile_Conversion = parser.getText();
                    } else if (text == 'Bid_Type') {
                        Bid_Type = parser.getText();
                    } else if (text == 'Email') {
                        Email = parser.getText();
                    } else if (text == 'Dialing_Country') {
                        Dialing_Country = parser.getText();
                    } else if (text == 'Country_Code') {
                        Country_Code = parser.getText();
                    } else if (text == 'Mobile_Phone') {
                        Mobile_Phone = parser.getText();
                    } else if (text == 'Phone') {
                        Phone = parser.getText();
                    } else if (text == 'Website_Language') {
                        Website_Language = parser.getText();
                    } else if (text == 'Project') {
                        Project = parser.getText();
                    } else if (text == 'Project_Type__c') {
                        Project_Type = parser.getText();
                    } else if (text == 'Unit_Type') {
                        Unit_Type = parser.getText();
                    }  else if (text == 'BudgetInAed') {
                        BudgetInAed = parser.getText();
                    } else if (text == 'BudgetInUsd') {
                        BudgetInUsd = parser.getText();
                    } else if (text == 'BedroomType') {
                        BedroomType = parser.getText();
                    } else if (text == 'GCLID') {
                        GCLID = parser.getText();
                    }else if(text == 'leadID'){
                        leadID = parser.getText();
                    }else if(text == 'RDS_Country_Code'){
                        RDS_Country_Code = parser.getText();
                    }else if(text == 'Preferre_Method_of_Contact'){
                        Preferre_Method_of_Contact = parser.getText();
                        System.debug('preferr'+parser.getText());
                    }else if(text == 'News_Offers_subscription'){
                        if(parser.getText() == 'Yes'){
                            News_Offers_subscription = true;
                        }else {
                            News_Offers_subscription = false;
                        }
                    }else if(text == 'Privacy_Policy_Acknowledgement'){
                        if(parser.getText() == 'Yes'){
                            Privacy_Policy_Acknowledgement = true;
                        }else {
                            Privacy_Policy_Acknowledgement = false;
                        }
                    }else if(text == 'Project_Name'){
                        Project_Name = parser.getText();
                    }else if(text == 'campaign_Code'){
                        campaign_Code = parser.getText();
                    }else if(text == 'Campaign_Name'){
                        Campaign_Name = parser.getText();
                    }else if(text == 'Ad_set_ID'){
                        Ad_set_ID = parser.getText();
                    }else if(text == 'Time_Spent_before_Form_Submit'){
                        Time_Spent_before_Form_Submit = parser.getText();
                    }else if(text == 'IP_Address'){
                        IP_Address = parser.getText();
                    }else if(text == 'Nationality'){
                        Nationality = parser.getText();
                    }else if(text == 'Landing_Page_URL'){
                        Landing_Page_URL = parser.getText();
                    }else if(text == 'Platform'){
                        Platform = parser.getText();
                    }else if(text == 'Browser'){
                        Browser = parser.getText();
                    }else if(text == 'network'){
                        network = parser.getText();
                    }else if(text == 'Resolution'){
                        Resolution = parser.getText();
                    }else if(text == 'OS'){
                        OS = parser.getText();
                    }else if(text == 'Device'){
                        device = parser.getText();
                    }else if(text == 'MatchType'){
                        matchType = parser.getText();
                    }else if(text == 'AdPosition'){
                        adPosition = parser.getText();
                    }else if(text == 'Web_Banner_Size'){
                        webBannerSize = parser.getText();
                    }else if(text == 'UTM_Term'){
                        utmTerm = parser.getText();
                    }else if(text == 'LastName'){
                        lastName = parser.getText();
                    }else if(text == 'FirstName'){
                        firstName = parser.getText();
                    }else if (text == 'UTM_Medium') {
                        UTM_Medium = parser.getText();
                    }else if (text == 'UTM_AdId') {//Added by Mohit as part of SOB - 760
                        UTM_AdId = parser.getText();
                    }else if (text == 'UTM_Adset') {
                        UTM_Adset = parser.getText();
                    }else if (text == 'UTM_AdsetId') {
                        UTM_AdsetId = parser.getText();
                    }else if (text == 'areYouLookingFor') {
                        areYouLookingFor = parser.getText();
                    }else if (text == 'UTM_Company') {
                        UTM_Company = parser.getText();
                    }else if (text == 'UTM_Country') { UTM_Country = parser.getText(); }
                    else if (text == 'UTM_Creative') { UTM_Creative = parser.getText(); }
                    else if (text == 'UTM_Language') { UTM_Language = parser.getText(); }
                    else if (text == 'UTM_CampaignId') { UTM_CampaignId = parser.getText(); }
                    else if(text == 'UTM_adgroup'){ UTM_adgroup = parser.getText(); }
                    else if(text == 'Meta_Lead_ID'){ Meta_Lead_ID = parser.getText(); }
                    else{
                        System.debug(LoggingLevel.WARN, 'CreateLeadParser consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
   
    public static List<CreateLeadParser> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfCreateLeadParser(parser);
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
   
    private static List<CreateLeadParser> arrayOfCreateLeadParser(System.JSONParser p) {
        List<CreateLeadParser> res = new List<CreateLeadParser>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CreateLeadParser(p));
        }
        return res;
    }
}