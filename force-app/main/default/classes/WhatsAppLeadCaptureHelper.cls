global class WhatsAppLeadCaptureHelper {
    global Static String insertContactAndEnquiry(RestRequest request) {
        String responce = '';
        String StatusCode = '';
        String jsonString = '';
        List<Contact> existingContactList = new List<Contact>();
        List<PropStrength__Projects__c> projectList = new List<PropStrength__Projects__c>();
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                jsonString = request.requestBody.toString();
                try {
                    WhatsAppLeadCapturePOJO whatPOJO = (WhatsAppLeadCapturePOJO) JSON.deserialize(jsonString, WhatsAppLeadCapturePOJO.class);
                    if(whatPOJO != null) {
                        if(String.isBlank(whatPOJO.LastName)) {
                            StatusCode = '400';
                            gen.writeStartObject();     
                            gen.writeBooleanField('success', false);
                            gen.writeNumberField('statusCode', 400);
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'Please Enter Last Name.');
                            gen.writeEndObject();
                            responce = gen.getAsString();
                        }
                        if(String.isBlank(whatPOJO.Mobile_Phone)) {
                            StatusCode = '400';
                            gen.writeStartObject();     
                            gen.writeBooleanField('success', false);
                            gen.writeNumberField('statusCode', 400);
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'Please Enter Mobile Phone.');
                            gen.writeEndObject();
                            responce = gen.getAsString();
                        }
                        if(!String.isBlank(whatPOJO.project)) {
                            projectList = [SELECT Id,Name FROM PropStrength__Projects__c WHERE Id =: whatPOJO.project];
                        }
                        if(!String.isBlank(whatPOJO.Mobile_Phone)) {
                            existingContactList = [SELECT Id,mobilePhone
                                                   FROM Contact 
                                                   WHERE mobilePhone =: whatPOJO.Mobile_Phone LIMIT 1];
                        }
                        if(!String.isBlank(whatPOJO.Mobile_Phone) && 
                           !String.isBlank(whatPOJO.LastName)) {
                               if(!existingContactList.isEmpty()) {
                                   PropStrength__Request__c oneEnq = new PropStrength__Request__c();
                                   oneEnq.PropStrength__Primary_Contact__c = existingContactList[0].Id;
                                   oneEnq.Website_Language__c = (!String.isBlank(whatPOJO.Website_Language) ? whatPOJO.Website_Language : '');
                                   //oneEnq.Preferre_Method_of_Contact = (!String.isBlank(whatPOJO.Preferre_Method_of_Contact) ? whatPOJO.Preferre_Method_of_Contact : '');
                                   oneEnq.News_Offer_Subscription__c = (whatPOJO.News_Offers_subscription == 'Yes' ? true : false);
                                   oneEnq.Privacy_Policy_Acknowledgement__c = (whatPOJO.Privacy_Policy_Acknowledgement == 'Yes' ? true : false);
                                   oneEnq.Project_Name__c = (!String.isBlank(whatPOJO.Project_Name) ? whatPOJO.Project_Name : '');
                                   oneEnq.Campaign_Code__c = (!String.isBlank(whatPOJO.campaign_Code) ? whatPOJO.campaign_Code : '');
                                   oneEnq.Campaign_Name__c = (!String.isBlank(whatPOJO.Campaign_Name) ? whatPOJO.Campaign_Name : '');
                                   oneEnq.Ad_Set_Id__c = (!String.isBlank(whatPOJO.Ad_set_ID) ? whatPOJO.Ad_set_ID : '');
                                   oneEnq.Adgroup__c = (!String.isBlank(whatPOJO.Ad_group) ? whatPOJO.Ad_group : '');
                                   oneEnq.Time_Spent_before_Form_Submit__c = (!String.isBlank(whatPOJO.Time_Spent_before_Form_Submit) ? whatPOJO.Time_Spent_before_Form_Submit : '');
                                   //oneEnq.IP_Address = (!String.isBlank(whatPOJO.IP_Address) ? whatPOJO.IP_Address : '');
                                   //oneEnq.Landing_Page_URL = (!String.isBlank(whatPOJO.Landing_Page_URL) ? whatPOJO.Landing_Page_URL : '');
                                   oneEnq.Platform__c = (!String.isBlank(whatPOJO.Platform) ? whatPOJO.Platform : '');
                                   oneEnq.Browser__c = (!String.isBlank(whatPOJO.Browser) ? whatPOJO.Browser : '');
                                   oneEnq.RDS_Country_Code__c = (!String.isBlank(whatPOJO.RDS_Country_Code) ? whatPOJO.RDS_Country_Code : '');
                                   oneEnq.network__c = (!String.isBlank(whatPOJO.network) ? whatPOJO.network : '');
                                   oneEnq.PropStrength__Project__c = (!String.isBlank(whatPOJO.project) ? whatPOJO.project : '');
                                   oneEnq.Resolution__c = (!String.isBlank(whatPOJO.Resolution) ? whatPOJO.Resolution : '');
                                   oneEnq.OS__c = (!String.isBlank(whatPOJO.OS) ? whatPOJO.OS : '');
                                   oneEnq.Device__c = (!String.isBlank(whatPOJO.Device) ? whatPOJO.Device : '');
                                   oneEnq.Matchtype__c = (!String.isBlank(whatPOJO.MatchType) ? whatPOJO.MatchType : '');
                                   oneEnq.Adposition__c = (!String.isBlank(whatPOJO.AdPosition) ? whatPOJO.AdPosition : '');
                                   oneEnq.Web_Banner_Size__c = (!String.isBlank(whatPOJO.Web_Banner_Size) ? whatPOJO.Web_Banner_Size : '');
                                   oneEnq.Digital_Source__c = (!String.isBlank(whatPOJO.Digital_Source) ? whatPOJO.Digital_Source : '');
                                   oneEnq.Lead_Source__c = (!String.isBlank(whatPOJO.Lead_Source) ? whatPOJO.Lead_Source : '');
                                   oneEnq.Goal__c = (!String.isBlank(whatPOJO.Goal) ? whatPOJO.Goal : '');
                                   oneEnq.Channel_Cluster__c = (!String.isBlank(whatPOJO.Channel_Cluster) ? whatPOJO.Channel_Cluster : '');
                                   oneEnq.Last_Mile_Conversion__c = (!String.isBlank(whatPOJO.Last_Mile_Conversion) ? whatPOJO.Last_Mile_Conversion : '');
                                   oneEnq.Bid_Type__c = (!String.isBlank(whatPOJO.Bid_Type) ? whatPOJO.Bid_Type : '');
                                   oneEnq.UTM_Source__c = (!String.isBlank(whatPOJO.UTM_Source) ? whatPOJO.UTM_Source : '');
                                   oneEnq.UTM_Term__c = (!String.isBlank(whatPOJO.UTM_Term) ? whatPOJO.UTM_Term : '');
                                   oneEnq.UTM_Medium__c = (!String.isBlank(whatPOJO.UTM_Medium) ? whatPOJO.UTM_Medium : '');
                                   oneEnq.UTM_Campaign__c = (!String.isBlank(whatPOJO.UTM_Campaign) ? whatPOJO.UTM_Campaign : '');
                                   oneEnq.UTM_Content__c = (!String.isBlank(whatPOJO.UTM_Content) ? whatPOJO.UTM_Content : '');
                                   oneEnq.UTM_Company__c = (!String.isBlank(whatPOJO.utm_company) ? whatPOJO.utm_company : '');
                                   oneEnq.UTM_Adset__c = (!String.isBlank(whatPOJO.utm_adset) ? whatPOJO.utm_adset : '');
                                   oneEnq.UTM_Creative__c = (!String.isBlank(whatPOJO.utm_creative) ? whatPOJO.utm_creative : '');
                                   oneEnq.UTM_Country__c = (!String.isBlank(whatPOJO.utm_country) ? whatPOJO.utm_country : '');
                                   oneEnq.UTM_Language__c = (!String.isBlank(whatPOJO.utm_language) ? whatPOJO.utm_language : '');
                                   oneEnq.UTM_Campaign_id__c = (!String.isBlank(whatPOJO.UTM_CampaignId) ? whatPOJO.UTM_CampaignId : '');
                                   oneEnq.UTM_Adgroup__c = (!String.isBlank(whatPOJO.utm_adgroup) ? whatPOJO.utm_adgroup : '');
                                   oneEnq.GCLID__c = (!String.isBlank(whatPOJO.GCLID) ? whatPOJO.GCLID : '');
                                   oneEnq.Meta_Lead_ID__c = (!String.isBlank(whatPOJO.Meta_Lead_ID) ? whatPOJO.Meta_Lead_ID : '');
                                   oneEnq.Bedroom_Type__c = (!String.isBlank(whatPOJO.BedroomType) ? whatPOJO.BedroomType : '');
                                   oneEnq.Project_Type__c = (!String.isBlank(whatPOJO.Project_Type) ? whatPOJO.Project_Type : '');
                                   //oneEnq.Time_of_Visit__c = (!String.isBlank(whatPOJO.Time_of_Visit) ? whatPOJO.Time_of_Visit : '');
                                   //oneEnq.areYouLookingFor = (!String.isBlank(whatPOJO.areYouLookingFor) ? whatPOJO.areYouLookingFor : '');
                                   //oneEnq.utm_adid = (!String.isBlank(whatPOJO.utm_adid) ? whatPOJO.utm_adid : '');
                                   //oneEnq.utm_adsetid = (!String.isBlank(whatPOJO.utm_adsetid) ? whatPOJO.utm_adsetid : '');
                                   Database.SaveResult insertRequest = Database.insert(oneEnq);
                                   if(insertRequest.isSuccess()) {
                                       StatusCode = '200';
                                       gen.writeStartObject();     
                                       gen.writeBooleanField('success', true);
                                       gen.writeNumberField('statusCode', 200);
                                       gen.writeStringField('status', 'success');
                                       gen.writeStringField('Message', 'Successfully Inserted With RecordId ='+insertRequest.getId());
                                       gen.writeEndObject();
                                       responce = gen.getAsString();
                                   } else {
                                       StatusCode = '400';
                                       gen.writeStartObject();     
                                       gen.writeBooleanField('success', false);
                                       gen.writeNumberField('statusCode', 400);
                                       gen.writeStringField('status', 'Error');
                                       gen.writeStringField('Message', 'Error ==> '+insertRequest.getErrors());
                                       gen.writeEndObject();
                                       responce = gen.getAsString();
                                   }
                               }else {
                                   Contact con = new Contact();
                                   con.FirstName = (!String.isBlank(whatPOJO.FirstName) ? whatPOJO.FirstName : '');
                                   con.LastName = (!String.isBlank(whatPOJO.LastName) ? whatPOJO.LastName : '');
                                   con.PropStrength__Nationality__c = (!String.isBlank(whatPOJO.Nationality) ? whatPOJO.Nationality : '');  
                                   con.Email = (!String.isBlank(whatPOJO.Email) ? whatPOJO.Email : '');
                                   con.mobilePhone = (!String.isBlank(whatPOJO.Mobile_Phone) ? whatPOJO.Mobile_Phone : '');
                                   Database.SaveResult insertContact = Database.insert(con);
                                   if(insertContact.isSuccess()) {
                                       PropStrength__Request__c oneEnq = new PropStrength__Request__c();
                                       oneEnq.RDS_Country_Code__c = (!String.isBlank(whatPOJO.RDS_Country_Code) ? whatPOJO.RDS_Country_Code : '');
                                       oneEnq.PropStrength__Primary_Contact__c = insertContact.getId();
                                       oneEnq.Website_Language__c = (!String.isBlank(whatPOJO.Website_Language) ? whatPOJO.Website_Language : '');
                                       //oneEnq.Preferre_Method_of_Contact = (!String.isBlank(whatPOJO.Preferre_Method_of_Contact) ? whatPOJO.Preferre_Method_of_Contact : '');
                                       oneEnq.News_Offer_Subscription__c = (whatPOJO.News_Offers_subscription == 'Yes' ? true : false);
                                       oneEnq.Privacy_Policy_Acknowledgement__c = (whatPOJO.Privacy_Policy_Acknowledgement == 'Yes' ? true : false);
                                       oneEnq.Project_Name__c = (!String.isBlank(whatPOJO.Project_Name) ? whatPOJO.Project_Name : '');
                                       oneEnq.Campaign_Code__c = (!String.isBlank(whatPOJO.campaign_Code) ? whatPOJO.campaign_Code : '');
                                       oneEnq.Campaign_Name__c = (!String.isBlank(whatPOJO.Campaign_Name) ? whatPOJO.Campaign_Name : '');
                                       oneEnq.Ad_Set_Id__c = (!String.isBlank(whatPOJO.Ad_set_ID) ? whatPOJO.Ad_set_ID : '');
                                       oneEnq.Adgroup__c = (!String.isBlank(whatPOJO.Ad_group) ? whatPOJO.Ad_group : '');
                                       oneEnq.Time_Spent_before_Form_Submit__c = (!String.isBlank(whatPOJO.Time_Spent_before_Form_Submit) ? whatPOJO.Time_Spent_before_Form_Submit : '');
                                       //oneEnq.IP_Address = (!String.isBlank(whatPOJO.IP_Address) ? whatPOJO.IP_Address : '');
                                       //oneEnq.Landing_Page_URL = (!String.isBlank(whatPOJO.Landing_Page_URL) ? whatPOJO.Landing_Page_URL : '');
                                       oneEnq.Platform__c = (!String.isBlank(whatPOJO.Platform) ? whatPOJO.Platform : '');
                                       oneEnq.Browser__c = (!String.isBlank(whatPOJO.Browser) ? whatPOJO.Browser : '');
                                       oneEnq.network__c = (!String.isBlank(whatPOJO.network) ? whatPOJO.network : '');
                                       //oneEnq.PropStrength__Project__c = (!projectList.isEmpty() ? projectList[0].Id : null);
                                       oneEnq.Resolution__c = (!String.isBlank(whatPOJO.Resolution) ? whatPOJO.Resolution : '');
                                       oneEnq.OS__c = (!String.isBlank(whatPOJO.OS) ? whatPOJO.OS : '');
                                       oneEnq.Device__c = (!String.isBlank(whatPOJO.Device) ? whatPOJO.Device : '');
                                       oneEnq.Matchtype__c = (!String.isBlank(whatPOJO.MatchType) ? whatPOJO.MatchType : '');
                                       oneEnq.Adposition__c = (!String.isBlank(whatPOJO.AdPosition) ? whatPOJO.AdPosition : '');
                                       oneEnq.Web_Banner_Size__c = (!String.isBlank(whatPOJO.Web_Banner_Size) ? whatPOJO.Web_Banner_Size : '');
                                       oneEnq.Digital_Source__c = (!String.isBlank(whatPOJO.Digital_Source) ? whatPOJO.Digital_Source : '');
                                       oneEnq.Lead_Source__c = (!String.isBlank(whatPOJO.Lead_Source) ? whatPOJO.Lead_Source : '');
                                       oneEnq.Goal__c = (!String.isBlank(whatPOJO.Goal) ? whatPOJO.Goal : '');
                                       oneEnq.Channel_Cluster__c = (!String.isBlank(whatPOJO.Channel_Cluster) ? whatPOJO.Channel_Cluster : '');
                                       oneEnq.Last_Mile_Conversion__c = (!String.isBlank(whatPOJO.Last_Mile_Conversion) ? whatPOJO.Last_Mile_Conversion : '');
                                       oneEnq.Bid_Type__c = (!String.isBlank(whatPOJO.Bid_Type) ? whatPOJO.Bid_Type : '');
                                       oneEnq.UTM_Source__c = (!String.isBlank(whatPOJO.UTM_Source) ? whatPOJO.UTM_Source : '');
                                       oneEnq.UTM_Term__c = (!String.isBlank(whatPOJO.UTM_Term) ? whatPOJO.UTM_Term : '');
                                       oneEnq.UTM_Medium__c = (!String.isBlank(whatPOJO.UTM_Medium) ? whatPOJO.UTM_Medium : '');
                                       oneEnq.UTM_Campaign__c = (!String.isBlank(whatPOJO.UTM_Campaign) ? whatPOJO.UTM_Campaign : '');
                                       oneEnq.UTM_Content__c = (!String.isBlank(whatPOJO.UTM_Content) ? whatPOJO.UTM_Content : '');
                                       oneEnq.UTM_Company__c = (!String.isBlank(whatPOJO.utm_company) ? whatPOJO.utm_company : '');
                                       oneEnq.UTM_Adset__c = (!String.isBlank(whatPOJO.utm_adset) ? whatPOJO.utm_adset : '');
                                       oneEnq.UTM_Creative__c = (!String.isBlank(whatPOJO.utm_creative) ? whatPOJO.utm_creative : '');
                                       oneEnq.UTM_Country__c = (!String.isBlank(whatPOJO.utm_country) ? whatPOJO.utm_country : '');
                                       oneEnq.UTM_Language__c = (!String.isBlank(whatPOJO.utm_language) ? whatPOJO.utm_language : '');
                                       oneEnq.UTM_Campaign_id__c = (!String.isBlank(whatPOJO.UTM_CampaignId) ? whatPOJO.UTM_CampaignId : '');
                                       oneEnq.UTM_Adgroup__c = (!String.isBlank(whatPOJO.utm_adgroup) ? whatPOJO.utm_adgroup : '');
                                       oneEnq.GCLID__c = (!String.isBlank(whatPOJO.GCLID) ? whatPOJO.GCLID : '');
                                       oneEnq.Meta_Lead_ID__c = (!String.isBlank(whatPOJO.Meta_Lead_ID) ? whatPOJO.Meta_Lead_ID : '');
                                       oneEnq.Bedroom_Type__c = (!String.isBlank(whatPOJO.BedroomType) ? whatPOJO.BedroomType : '');
                                       oneEnq.Project_Type__c = (!String.isBlank(whatPOJO.Project_Type) ? whatPOJO.Project_Type : '');
                                       //oneEnq.Time_of_Visit__c = (!String.isBlank(whatPOJO.Time_of_Visit) ? whatPOJO.Time_of_Visit : '');
                                       //oneEnq.areYouLookingFor = (!String.isBlank(whatPOJO.areYouLookingFor) ? whatPOJO.areYouLookingFor : '');
                                       //oneEnq.utm_adid = (!String.isBlank(whatPOJO.utm_adid) ? whatPOJO.utm_adid : '');
                                       //oneEnq.utm_adsetid = (!String.isBlank(whatPOJO.utm_adsetid) ? whatPOJO.utm_adsetid : '');
                                       Database.SaveResult insertRequest = Database.insert(oneEnq);
                                       if(insertRequest.isSuccess()) {
                                           StatusCode = '200';
                                           gen.writeStartObject();     
                                           gen.writeBooleanField('success', true);
                                           gen.writeNumberField('statusCode', 200);
                                           gen.writeStringField('status', 'success');
                                           gen.writeStringField('Message', 'Successfully inserted.');
                                           gen.writeEndObject();
                                           responce = gen.getAsString();
                                       }
                                   } else {
                                       StatusCode = '400';
                                       gen.writeStartObject();     
                                       gen.writeBooleanField('success', false);
                                       gen.writeNumberField('statusCode', 400);
                                       gen.writeStringField('status', 'Error');
                                       gen.writeStringField('Message', 'Error ==> '+insertContact.getErrors());
                                       gen.writeEndObject();
                                       responce = gen.getAsString();
                                   }
                               }
                           } 
                    }
                } catch(Exception e) {
                    
                }
            }
        Mobile_App_Log__c logError = new Mobile_App_Log__c();
        logError.Response_Body__c = responce;
        logError.Class_Name__c = 'WhatsAppLeadCaptureHelper';
        logError.API_Name__c = '/services/apexrest/WhatsAppLeadCapture/';
        logError.Status__c = StatusCode;
        logError.Request_Body__c = JSON.serialize(jsonString);
        insert logError;
        return responce;
    }
}