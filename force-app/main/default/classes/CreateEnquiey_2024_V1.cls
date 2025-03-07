@RestResource(urlMapping = '/pushEnuiry/2024/v1/*')
Global Class CreateEnquiey_2024_V1 {
    @HttpPost
    Global Static List<ResponseWrapper> doPost() {
        List<ResponseWrapper> rwList = new List<ResponseWrapper>();
        Savepoint sp = Database.setSavepoint();
        try {
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            System.debug('json*---+'+json); 
            List<CreateLeadParser> parserList = CreateLeadParser.parse(json);
            Set<String> emails = new Set<String>();
            Set<String> phones = new Set<String>();
            
            Set<String> emailsV2 = new Set<String>();
            Set<String> phonesV2 = new Set<String>();

           Set<String> projectName = new Set<String>(); 
            for(CreateLeadParser parser : parserList) {
                if(parser.Email != null) {
                    emails.add(parser.Email);
                }
                if(parser.Mobile_Phone != null) {
                    phones.add(parser.Mobile_Phone);
                }
                if(parser.Phone != null) {
                    phones.add(parser.Phone);
                }
                if(parser.Project != null) {
                    projectName.add(parser.Project);
                }
            }
            Map<String, Id> projectNameIdMap = new Map<String, Id>();
            Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Contact> conLists = [SELECT Id,LastName, FirstName, MobilePhone, Phone, Email, RecordTypeId, owner.isActive, ownerID FROM Contact WHERE Email IN :emails OR MobilePhone IN :phones];
            List<PropStrength__Request__c> transReqToInsert = new List<PropStrength__Request__c>(); 
            for(PropStrength__Projects__c proj : [SELECT Id, Name FROM PropStrength__Projects__c WHERE Name IN :projectName]) {
                projectNameIdMap.put(proj.Name, proj.Id);
            }
            if(conLists.size() > 0) {
                for(Contact c : conLists) {
                    for(CreateLeadParser parser : parserList) {
                        if((parser.Email == c.Email) || (parser.Mobile_Phone == c.MobilePhone) || (parser.Phone == c.Phone )) {
                            PropStrength__Request__c reqRec = new PropStrength__Request__c(); 
                            reqRec.PropStrength__Primary_Contact__c = c.Id;
                            reqRec.PropStrength__First_Name__c = parser.firstName != null? parser.firstName : null;
                            reqRec.PropStrength__Last_Name__c = parser.lastName != null? parser.lastName : parser.Name != null? parser.Name : null;
                            reqRec.PropStrength__Email_Address__c = parser.Email;
                            reqRec.PropStrength__Request_Status__c = 'Open';
                            reqRec.Phone__c = parser.Phone;
                            reqRec.PropStrength__Contact_No__c = parser.Mobile_Phone;
                            reqRec.PropStrength__Request_Source__c = parser.Lead_Source;
                            reqRec.Enquiry_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source )? parser.Lead_Sub_Source : parser.Web_Source;
                            reqRec.Web_Source__c = parser.Web_Source;
                            reqRec.Adgroup__c = parser.AD_Group;
                            reqRec.Keyword__c = parser.Keyword;
                            reqRec.Placement__c = parser.Placement;
                            reqRec.Channel_Cluster__c = parser.Channel_Cluster;
                            reqRec.Goal__c = parser.Goal;
                            reqRec.Digital_Source__c = parser.Digital_Source;
                            reqRec.UTM_Source__c = parser.UTM_Source;
                            reqRec.UTM_Campaign__c = parser.UTM_Campaign;
                            reqRec.UTM_Medium__c = parser.UTM_Medium;
                            reqRec.UTM_Content__c = parser.UTM_Content;
                            reqRec.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                            reqRec.Bid_Type__c = parser.Bid_Type;
                            reqRec.PropStrength__Country__c = parser.Dialing_Country;
                            reqRec.Website_Language__c = parser.Website_Language;
                            reqRec.Prefered_LAnguage__c = parser.Website_Language;
                            reqRec.RDS_Country_Code__c = parser.RDS_Country_Code.startsWith('+') ? parser.RDS_Country_Code : '+' + parser.RDS_Country_Code;
                            reqRec.Project_Type__c = parser.Project_Type;
                            reqRec.RDS_Unit_type_configuration__c = parser.Unit_Type;
                            reqRec.Budget_In_Aed__c = parser.BudgetInAed;
                            reqRec.Budget_In_USD__c = parser.BudgetInUsd;
                            reqRec.Bedroom_Type__c = parser.BedroomType;
                            reqRec.Preferred_Method_of_Contact__c = parser.Preferre_Method_of_Contact;
                            reqRec.News_Offer_Subscription__c = parser.News_Offers_subscription;
                            reqRec.Privacy_Policy_Acknowledgement__c = parser.Privacy_Policy_Acknowledgement;
                            reqRec.Project_Name__c = parser.Project_Name;
                            reqRec.Campaign_Code__c = parser.campaign_Code;
                            reqRec.Campaign_Name__c = parser.Campaign_Name;
                            reqRec.Ad_Set_Id__c = parser.Ad_set_ID;
                            reqRec.Time_Spent_before_Form_Submit__c = parser.Time_Spent_before_Form_Submit;
                            reqRec.IP_Address__c = parser.IP_Address;
                            reqRec.Landing_Page_URL__c = parser.Landing_Page_URL;
                            reqRec.Platform__c = parser.Platform;
                            reqRec.Browser__c = parser.Browser;
                            reqRec.network__c = parser.network;
                            reqRec.OS__c = parser.OS;
                            reqRec.Device__c = parser.Device;
                            reqRec.Matchtype__c = parser.Matchtype;
                            reqRec.Adposition__c = parser.Adposition;
                            reqRec.UTM_Term__c = parser.utmTerm;
                            reqRec.UTM_Company__c = parser.UTM_Company;
                            reqRec.UTM_Adset__c = parser.UTM_Adset;
                            reqRec.UTM_Country__c = parser.UTM_Country;
                            reqRec.UTM_Campaign_id__c = parser.UTM_CampaignId;
                            reqRec.UTM_Adset_id__c = parser.UTM_AdsetId;
                            reqRec.UTM_Ad_id__c = parser.UTM_AdId;
                            reqRec.UTM_Adgroup__c = parser.UTM_adgroup;
                            reqRec.UTM_Creative__c = parser.UTM_Creative;
                            reqRec.Meta_Lead_ID__c = parser.Meta_Lead_ID;
                            reqRec.ownerId = c.owner.isActive?c.ownerId:UserInfo.getUserId() ;
                            reqRec.PropStrength__Project__c = projectNameIdMap.keySet().contains(parser.Project) ? projectNameIdMap.get(parser.Project) :  null;
                            transReqToInsert.add(reqRec);
                        }
                    
                        emails.remove(c.Email);
                        phones.remove(c.MobilePhone);
                        phones.remove(c.Phone);
                        
                        emailsV2.add(c.Email);
                        phonesV2.add(c.MobilePhone);
                        phonesV2.add(c.Phone);
                    }
                }
            }
            Map<String, PropStrength__Request__c> emailToRequestMap = new Map<String, PropStrength__Request__c>();
                List<Contact> conList = new List<Contact>();
                for(CreateLeadParser parser : parserList) {
                    if(!emailsV2.contains(parser.Email) && !phonesV2.contains(parser.Mobile_Phone) && !phonesV2.contains(parser.Phone)) {
                       	String numbercode = parser.RDS_Country_Code.startsWith('+') ? parser.RDS_Country_Code.substring(1, parser.RDS_Country_Code.length()) : parser.RDS_Country_Code;
                        Contact con = new Contact();
                        con.FirstName = parser.firstName != null? parser.firstName : null;
                        con.LastName  = parser.lastName != null? parser.lastName : parser.Name != null? parser.Name : null;
                        con.RecordTypeId = RecordTypeIdContact;
                        con.Email = parser.Email;
                        con.MobilePhone = parser.Mobile_Phone != null ? numbercode+parser.Mobile_Phone : parser.Mobile_Phone;
                        con.Phone = parser.Phone != null ? numbercode+parser.Phone : parser.Phone;
                        con.PropStrength__Nationality__c = parser.Nationality;
                        con.Country_Code__c = parser.RDS_Country_Code.startsWith('+') ? parser.RDS_Country_Code : '+' + parser.RDS_Country_Code;
                        con.Country__c = parser.Dialing_Country;
                        conList.add(con);

                        PropStrength__Request__c reqRec = new PropStrength__Request__c();
                        reqRec.PropStrength__First_Name__c = parser.firstName != null? parser.firstName : null;
                        reqRec.PropStrength__Last_Name__c = parser.lastName != null? parser.lastName : parser.Name != null? parser.Name : null;
                        reqRec.PropStrength__Email_Address__c = parser.Email;
                        reqRec.PropStrength__Request_Status__c = 'Open';
                        reqRec.Phone__c = parser.Phone;
                        reqRec.Project_Type__c = parser.Project_Type;
                        reqRec.RDS_Country_Code__c = parser.RDS_Country_Code.startsWith('+') ? parser.RDS_Country_Code : '+' + parser.RDS_Country_Code;
                        reqRec.RDS_Country_Code__c = parser.RDS_Country_Code;
                        reqRec.PropStrength__Contact_No__c = parser.Mobile_Phone;
                        reqRec.PropStrength__Request_Source__c = parser.Lead_Source;
                        reqRec.Enquiry_Sub_Source__c = !string.isblank(parser.Lead_Sub_Source )? parser.Lead_Sub_Source : parser.Web_Source;
                        reqRec.Web_Source__c = parser.Web_Source;
                        reqRec.Adgroup__c = parser.AD_Group;
                        reqRec.Keyword__c = parser.Keyword;
                        reqRec.Placement__c = parser.Placement;
                        reqRec.Channel_Cluster__c = parser.Channel_Cluster;
                        reqRec.Goal__c = parser.Goal;
                        reqRec.Digital_Source__c = parser.Digital_Source;
                        reqRec.UTM_Source__c = parser.UTM_Source;
                        reqRec.UTM_Campaign__c = parser.UTM_Campaign;
                        reqRec.UTM_Medium__c = parser.UTM_Medium;
                        reqRec.UTM_Content__c = parser.UTM_Content;
                        reqRec.Last_Mile_Conversion__c = parser.Last_Mile_Conversion;
                        reqRec.Bid_Type__c = parser.Bid_Type;
                        reqRec.PropStrength__Country__c = parser.Dialing_Country;
                        reqRec.Website_Language__c = parser.Website_Language;
                        reqRec.Prefered_LAnguage__c = parser.Website_Language;
                        reqRec.PropStrength__Project__c = projectNameIdMap.keySet().contains(parser.Project) ? projectNameIdMap.get(parser.Project) :  null;
                        reqRec.RDS_Unit_type_configuration__c = parser.Unit_Type;
                        reqRec.Budget_In_Aed__c = parser.BudgetInAed;
                        reqRec.Budget_In_USD__c = parser.BudgetInUsd;
                        reqRec.Bedroom_Type__c = parser.BedroomType;
                        reqRec.Preferred_Method_of_Contact__c = parser.Preferre_Method_of_Contact;
                        reqRec.News_Offer_Subscription__c = parser.News_Offers_subscription;
                        reqRec.Privacy_Policy_Acknowledgement__c = parser.Privacy_Policy_Acknowledgement;
                        reqRec.Project_Name__c = parser.Project_Name;
                        reqRec.Campaign_Code__c = parser.campaign_Code;
                        reqRec.Campaign_Name__c = parser.Campaign_Name;
                        reqRec.Ad_Set_Id__c = parser.Ad_set_ID;
                        reqRec.IP_Address__c = parser.IP_Address;
                        reqRec.Landing_Page_URL__c = parser.Landing_Page_URL;
                        reqRec.Platform__c = parser.Platform;
                        reqRec.Browser__c = parser.Browser;
                        reqRec.network__c = parser.network;
                        reqRec.OS__c = parser.OS;
                        reqRec.Device__c = parser.Device;
                        reqRec.Matchtype__c = parser.Matchtype;
                        reqRec.Adposition__c = parser.Adposition;
                        reqRec.UTM_Term__c = parser.utmTerm;
                        reqRec.UTM_Company__c = parser.UTM_Company;
                        reqRec.UTM_Adset__c = parser.UTM_Adset;
                        reqRec.UTM_Country__c = parser.UTM_Country;
                        reqRec.UTM_Campaign_id__c = parser.UTM_CampaignId;
                        reqRec.UTM_Adset_id__c = parser.UTM_AdsetId;
                        reqRec.UTM_Ad_id__c = parser.UTM_AdId;
                        reqRec.UTM_Creative__c = parser.UTM_Creative;
                        reqRec.UTM_Adgroup__c = parser.UTM_adgroup;
                        reqRec.Meta_Lead_ID__c = parser.Meta_Lead_ID;
                        reqRec.Time_Spent_before_Form_Submit__c = parser.Time_Spent_before_Form_Submit;
                        emailToRequestMap.put(con.Email, reqRec);
                    }
                }

                if(!conList.isEmpty()) {
                    insert conList;
                }
                Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id, Email, Owner.isActive, ownerID FROM Contact WHERE Id IN :conList]);
                for(Contact con : conList) {
                    PropStrength__Request__c transReq = emailToRequestMap.get(con.Email);
                    transReq.ownerId = con.owner.isActive?con.ownerId:UserInfo.getUserId();
                    transReq.PropStrength__Primary_Contact__c = con.Id;
                    transReqToInsert.add(transReq);

                }

                if(!transReqToInsert.isEmpty()) {
                    insert transReqToInsert;
                }

            ResponseWrapper rw = new ResponseWrapper();
            rw.success = True;
            rw.message = 'Successfully Processed';
            rwList.add(rw);
            
        }
        catch (Exception Ex) {
            Database.rollback(sp);
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'CreateEnquiry_2024_v1';
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            logError.Request__c = json;
            insert logError;
            ResponseWrapper rw = new ResponseWrapper();
            rw.success = False;
            rw.message = Ex.getMessage();
            rwList.add(rw);
        }
        return rwList;
    }
    Global Class ResponseWrapper {
        Global Boolean success;
        Global String message;
    }
}