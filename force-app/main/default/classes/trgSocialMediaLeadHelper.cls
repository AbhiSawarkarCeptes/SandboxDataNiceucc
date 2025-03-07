public with sharing class trgSocialMediaLeadHelper {
    public static void PrepareLeadfromSML(List<Social_Media_Lead__c> smList, Map<Id, Social_Media_Lead__c> oldSmlMap) {
        List<Social_Media_Lead__c> smlListToProcess = new List<Social_Media_Lead__c>();
        if(oldSmlMap == null) {
            smlListToProcess.addAll(smList);
        }
        else {
            for(Social_Media_Lead__c sm : smList) {
                if(sm.Re_Process__c && !oldSmlMap.get(sm.Id).Re_Process__c && sm.SF_Enquiry__c == null) {
                    smlListToProcess.add(sm);
                }
            }
        }

        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        
        Set<String> emailsV2 = new Set<String>();
        Set<String> phonesV2 = new Set<String>();

        for(Social_Media_Lead__c sml : smlListToProcess) {
            if(sml.Email__c != null) {
                emails.add(sml.Email__c);
            }
            if(sml.Mobile_Number__c != null) {
                phones.add(sml.Mobile_Number__c);
            }
        }

        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Contact> conLists = [SELECT Id,LastName, FirstName, MobilePhone, Phone, Email, RecordTypeId, owner.isActive, ownerID FROM Contact WHERE Email IN :emails OR MobilePhone IN :phones];
        List<PropStrength__Request__c> transReqToInsert = new List<PropStrength__Request__c>(); 
        List<PropStrength__Projects__c> projId = [SELECT Id FROM PropStrength__Projects__c WHERE Name = '%Project%'];

        if(conLists.size() > 0) {
            for(Contact c : conLists) {
                for(Social_Media_Lead__c sml : smlListToProcess) {
                    if((sml.Email__c == c.Email) || (sml.Mobile_Number__c == c.MobilePhone) || (sml.Mobile_Number__c == c.Phone )) {
                        PropStrength__Request__c enqCreated = new PropStrength__Request__c();
                        enqCreated.PropStrength__Primary_Contact__c = c.Id;
                        enqCreated.PropStrength__Email_Address__c = sml.Email__c;
                        if(sml.Full_Name__c !=null)
                            enqCreated.Last_Name__c = sml.Full_Name__c;
                        else 
                            enqCreated.Last_Name__c = sml.First_Name__c + sml.Last_Name__c;
                        enqCreated.WeChat_ID__c = sml.WeChat_ID__c;
                        enqCreated.Leadgen_Form_ID__c = sml.Form_ID__c;
                        enqCreated.Leadgen_Page_ID__c = sml.Page_ID__c;
                        enqCreated.PropStrength__Project__c = (projId != null && projId.size() > 0) ? projId[0].Id : null;
                        enqCreated.Campaign_Code__c = sml.Campaign_Id__c;
                        enqCreated.Campaign_Name__c = sml.Campaign_Name__c;
                        enqCreated.PropStrength__Request_Source__c = sml.Source__c;
                        enqCreated.UTM_Campaign__c = sml.Campaign_Name__c;
                        enqCreated.UTM_Source__c = sml.Source__c;
                        enqCreated.RDS_Country__c = sml.Country__c;  
                        enqCreated.Facebook_Ad_ID__c = sml.Ad_ID__c;
                        enqCreated.Facebook_Ad_Name__c = sml.Ad_Name__c;
                        enqCreated.UTM_Term__c = sml.Ad_Name__c;
                        enqCreated.Facebook_Adset_ID__c = sml.AdSet_Id__c;
                        enqCreated.Facebook_Adset_Name__c = sml.AdSet_Name__c;           
                        enqCreated.Fb_Lead_Creation_date__c = sml.Lead_Created_Time__c;
                        enqCreated.Meta_Lead_ID__c = sml.Lead_ID__c;
                        enqCreated.GCLID__c = sml.GCLID__c;               
                        enqCreated.Platform__c = sml.Platform_ig__c;
                        enqCreated.Facebook_Page_Name__c = sml.Page_Name__c;
                        enqCreated.Facebook_Form_Name__c = sml.Form_Name__c;
                        if(sml.Full_Name__c !=null)
                            enqCreated.Last_Name__c = sml.Full_Name__c;
                        else 
                            enqCreated.Last_Name__c = sml.First_Name__c + sml.Last_Name__c;
                        if(sml.Mobile_Number_No_Country_Code__c != null ){
                            enqCreated.PropStrength__Contact_No__c = sml.Mobile_Number_No_Country_Code__c;
                        }else {
                            enqCreated.PropStrength__Contact_No__c = sml.Mobile_Number__c;
                        }
                        
                        if(sml.Form_Data__c != null){
                        enqCreated.Form_Data__c = sml.Form_Data__c;
                        }
                        if(sml.Phone_Number__c != null){
                        enqCreated.Phone__c = sml.Phone_Number__c;
                        }
                        
                        if(!String.isBlank(sml.Country_Code__c)) {
                            enqCreated.RDS_Country_Code__c = sml.Country_Code__c.startsWith('+') ? sml.Country_Code__c : '+' + sml.Country_Code__c;
                        }
                        if(sml.Recording_URL__c != null){
                            enqCreated.Recording_URL__c = sml.Recording_URL__c;
                        }
                        enqCreated.When_you_re_looking_to_buy__c = sml.When_are_you_looking_to_buy__c;
                        enqCreated.Would_you_like_to_invest_in_Dubai_Real_E__c = sml.Would_you_like_to_invest_in_Dubai__c;
                        enqCreated.callBackTime__c = sml.Select_call_back_time__c;
                        enqCreated.Are_you_looking_for__c = sml.Looking_for__c;
                        enqCreated.Budgett__c = sml.Budgett__c;
                        enqCreated.Website_Language__c = sml.Language__c;
                        enqCreated.Client_Comments__c = sml.Remarks__c;
                        transReqToInsert.add(enqCreated);
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
        for(Social_Media_Lead__c sml : smlListToProcess) {
            if(!emailsV2.contains(sml.Email__c) && !phonesV2.contains(sml.Mobile_Number__c)) {
                Contact con = new Contact();
                if(sml.Full_Name__c !=null)
                    con.LastName = sml.Full_Name__c;
                else 
                    con.LastName = sml.First_Name__c + sml.Last_Name__c;
                con.RecordTypeId = RecordTypeIdContact;
                con.Email = sml.Email__c;
                con.MobilePhone = sml.Mobile_Number__c;
                con.Country__c = sml.Country__c;
                conList.add(con);

                PropStrength__Request__c enqCreated = new PropStrength__Request__c();
                enqCreated.WeChat_ID__c = sml.WeChat_ID__c;
                enqCreated.Leadgen_Form_ID__c = sml.Form_ID__c;
                enqCreated.Leadgen_Page_ID__c = sml.Page_ID__c;
                enqCreated.PropStrength__Project__c = (projId != null && projId.size() > 0) ? projId[0].Id : null;
                enqCreated.PropStrength__Email_Address__c = sml.Email__c;
                enqCreated.Campaign_Code__c = sml.Campaign_Id__c;
                enqCreated.Campaign_Name__c = sml.Campaign_Name__c;
                enqCreated.PropStrength__Request_Source__c = sml.Source__c;
                enqCreated.UTM_Campaign__c = sml.Campaign_Name__c;
                enqCreated.UTM_Source__c = sml.Source__c;
                enqCreated.RDS_Country__c = sml.Country__c;  
                enqCreated.Facebook_Ad_ID__c = sml.Ad_ID__c;
                enqCreated.Facebook_Ad_Name__c = sml.Ad_Name__c;
                enqCreated.UTM_Term__c = sml.Ad_Name__c;
                enqCreated.Facebook_Adset_ID__c = sml.AdSet_Id__c;
                enqCreated.Facebook_Adset_Name__c = sml.AdSet_Name__c;           
                enqCreated.Fb_Lead_Creation_date__c = sml.Lead_Created_Time__c;
                enqCreated.GCLID__c = sml.GCLID__c;
                enqCreated.Meta_Lead_ID__c = sml.Lead_ID__c;
                enqCreated.Platform__c = sml.Platform_ig__c;
                enqCreated.Facebook_Page_Name__c = sml.Page_Name__c;
                enqCreated.Facebook_Form_Name__c = sml.Form_Name__c;
                if(sml.Full_Name__c !=null)
                    enqCreated.Last_Name__c = sml.Full_Name__c;
                else 
                    enqCreated.Last_Name__c = sml.First_Name__c + sml.Last_Name__c;
                if(sml.Mobile_Number_No_Country_Code__c != null ){
                    enqCreated.PropStrength__Contact_No__c = sml.Mobile_Number_No_Country_Code__c;
                }else {
                    enqCreated.PropStrength__Contact_No__c = sml.Mobile_Number__c;
                }
                
                if(sml.Form_Data__c != null){
                enqCreated.Form_Data__c = sml.Form_Data__c;
                }
                if(sml.Phone_Number__c != null){
                enqCreated.Phone__c = sml.Phone_Number__c;
                }
                
                if(!String.isBlank(sml.Country_Code__c)){//Added by mohit #SOB-490
                    enqCreated.RDS_Country_Code__c = sml.Country_Code__c.startsWith('+') ? sml.Country_Code__c : '+' + sml.Country_Code__c;
                }
                if(sml.Recording_URL__c != null){
                    enqCreated.Recording_URL__c = sml.Recording_URL__c;
                }
                enqCreated.When_you_re_looking_to_buy__c = sml.When_are_you_looking_to_buy__c;
                enqCreated.Would_you_like_to_invest_in_Dubai_Real_E__c = sml.Would_you_like_to_invest_in_Dubai__c;
                enqCreated.callBackTime__c = sml.Select_call_back_time__c;
                enqCreated.Are_you_looking_for__c = sml.Looking_for__c;
                enqCreated.Budgett__c = sml.Budgett__c;
                enqCreated.Website_Language__c = sml.Language__c;
                enqCreated.Client_Comments__c = sml.Remarks__c;
                emailToRequestMap.put(con.Email, enqCreated);
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

        try{
            if(!transReqToInsert.isEmpty()) {
                insert transReqToInsert;
            }
            System.debug('transReqToInsert****');
            System.debug(transReqToInsert);
            transReqToInsert = [SELECT Id, PropStrength__Email_Address__c FROM PropStrength__Request__c WHERE Id IN :transReqToInsert];
            List<Social_Media_Lead__c> smlUpdate = new List<Social_Media_Lead__c>();

            for(PropStrength__Request__c rec : transReqToInsert) {
                for(Social_Media_Lead__c sm : smlListToProcess) {
                    if(sm.Email__c == rec.PropStrength__Email_Address__c) {
                        smlUpdate.add(new Social_Media_Lead__c(Id=sm.Id, SF_Enquiry__c = rec.Id, processed__c = true, result__c = 'New LEAD', remarks__c = 'new Lead'));
                    }
                }
            }

            if(!smlUpdate.isEmpty()) {
                update smlUpdate;
            }
        }catch (System.DmlException ex) {
            String msg = null;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                msg = 'Lead Insert Failed :' + ex.getMessage();
            }
            System.debug('Error:' + msg);
            for(Social_Media_Lead__c sml : smlListToProcess){
                sml.processed__c = true;
                sml.result__c = 'ERROR';
                sml.remarks__c = msg;
            }
        }
    }
}