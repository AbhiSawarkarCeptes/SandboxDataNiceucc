@IsTest
public class CreateLeadParser_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '['+
        '   {'+
        '      \"Name\":\"\",'+
        '      \"Lead_Source\":\"\",'+
        '      \"Web_Source\":\"\",'+
        '      \"Lead_Sub_Source\":\"\",'+
        '      \"AD_Group\":\"\",'+
        '      \"Keyword\":\"\",'+
        '      \"Placement\":\"\",'+
        '      \"Channel_Cluster\":\"\",'+
        '      \"Goal\":\"\",'+
        '      \"Digital_Source\":\"\",'+
        '      \"UTM_Source\":\"\",'+
        '      \"UTM_Medium\":\"\",'+
        '      \"UTM_Campaign\":\"\",'+
        '      \"UTM_Content\":\"\",'+
        '      \"Last_Mile_Conversion\":\"\",'+
        '      \"Bid_Type\":\"\",'+
        '      \"Email\":\"\",'+
        '      \"Dialing_Country\":\"\",'+
        '      \"Country_Code\":\"\",'+
        '      \"Mobile_Phone\":\"\",'+
        '      \"Phone\":\"\",'+
        '      \"Website_Language\":\"\",'+
        '      \"Project\":\"\",'+
        '      \"Project_Type__c\":\"\",'+
        '      \"Unit_Type\":\"\",'+
            '      \"BudgetInAed\":\"\",'+
            '      \"BudgetInUsd\":\"\",'+
            '      \"BedroomType\":\"\",'+
            '      \"GCLID\":\"\",'+
            '      \"leadID\":\"\",'+
            '      \"Nationality\":\"\",'+
            '      \"Preferre_Method_of_Contact\":\"\",'+
            '      \"News_Offers_subscription\":\"\",'+
            '      \"Privacy_Policy_Acknowledgement\":\"\",'+
            '      \"Project_Name\":\"\",'+
            '      \"campaign_Code\":\"\"'+
        '   }'+
        ']';
        List<CreateLeadParser> r = CreateLeadParser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        CreateLeadParser objCreateLeadParser = new CreateLeadParser(System.JSON.createParser(json));
        System.assert(objCreateLeadParser != null);
        System.assert(objCreateLeadParser.Name == null);
        System.assert(objCreateLeadParser.Lead_Source == null);
        System.assert(objCreateLeadParser.Web_Source == null);
        System.assert(objCreateLeadParser.Lead_Sub_Source == null);
        System.assert(objCreateLeadParser.AD_Group == null);
        System.assert(objCreateLeadParser.Keyword == null);
        System.assert(objCreateLeadParser.Placement == null);
        System.assert(objCreateLeadParser.Channel_Cluster == null);
        System.assert(objCreateLeadParser.Goal == null);
        System.assert(objCreateLeadParser.Digital_Source == null);
        System.assert(objCreateLeadParser.UTM_Source == null);
        System.assert(objCreateLeadParser.UTM_Medium == null);
        System.assert(objCreateLeadParser.UTM_Campaign == null);
        System.assert(objCreateLeadParser.UTM_Content == null);
        System.assert(objCreateLeadParser.Last_Mile_Conversion == null);
        System.assert(objCreateLeadParser.Bid_Type == null);
        System.assert(objCreateLeadParser.Email == null);
        System.assert(objCreateLeadParser.Dialing_Country == null);
        System.assert(objCreateLeadParser.Country_Code == null);
        System.assert(objCreateLeadParser.Mobile_Phone == null);
        System.assert(objCreateLeadParser.Phone == null);
        System.assert(objCreateLeadParser.Website_Language == null);
        System.assert(objCreateLeadParser.Project == null);
        System.assert(objCreateLeadParser.Project_Type == null);
        System.assert(objCreateLeadParser.Unit_Type == null);
    }
}