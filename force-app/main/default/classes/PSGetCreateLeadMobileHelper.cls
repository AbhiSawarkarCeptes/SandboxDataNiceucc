global class PSGetCreateLeadMobileHelper {
    
    global Static String PSGetCreateLeadMobile(RestRequest request) {
        String responseString = '';
        String statusCode = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {
                    List<Task> taskList = new List<Task>();
                    List<PropStrength__Request__c> upsertList = new List<PropStrength__Request__c>();
                    List<Contact> existingList = new List<Contact>();
                    PSGetCreateLeadMobilePOJO leadWrap = (PSGetCreateLeadMobilePOJO) JSON.deserialize(jsonString, PSGetCreateLeadMobilePOJO.class);
                    system.debug('Email::'+leadWrap.Email);
                    String countryCode='';
                    String formatMobile='';
                    if(leadWrap.countryCode!=null) {
                        if(countryCode.endsWith('0')) {
                            countryCode = countryCode.removeEnd('0');
                        }
                        if(countryCode.startsWith('+')) {
                            countryCode =  countryCode.substringAfter('+');
                        }
                    }
                    if(leadWrap.mobile != null) {
                        formatMobile = leadWrap.mobile;
                        if(formatMobile.startsWith('0')){
                            formatMobile = formatMobile.substringAfter('0'); 
                            formatMobile = countryCode + formatMobile;
                        } else {
                            formatMobile = countryCode + formatMobile;
                        }
                    }
                    system.debug('formatMobile::'+formatMobile);
                    system.debug('leadWrap.Email::'+leadWrap.Email);
                    if(!String.isBlank(formatMobile)) {
                        existingList = [SELECT Id,Name
                                        FROM Contact 
                                        WHERE Phone =: formatMobile OR MobilePhone =: formatMobile];
                    }
                    if(existingList.isEmpty() && existingList.size() == 0) {
                        existingList = [SELECT Id,Name
                                        FROM Contact 
                                        WHERE Email =: leadWrap.Email];
                    }
                    system.debug('existingList::'+existingList);
                    if(!existingList.isEmpty()) {
                        for(Contact con : existingList) {
                            PropStrength__Request__c oneEnquiry = new PropStrength__Request__c();
                            oneEnquiry.PropStrength__First_Name__c = leadWrap.firstName;
                            oneEnquiry.PropStrength__Last_Name__c = leadWrap.lastName;
                            //oneEnquiry.Nationality__c = leadWrap.email;
                            oneEnquiry.PropStrength__Contact_No__c = leadWrap.mobile;
                            oneEnquiry.RDS_Country_Code__c = leadWrap.countryCode;
                            oneEnquiry.PropStrength__Primary_Contact__c = con.Id;
                            oneEnquiry.PropStrength__Enquiry_Type__c = 'Direct';
                            oneEnquiry.PropStrength__Request_Source__c = 'Web';
                            oneEnquiry.Enquiry_Sub_Source__c = 'Mobile App';
                            oneEnquiry.PropStrength__Request_Status__c = 'Open';
                            oneEnquiry.News_Offer_Subscription__c = true;
                            oneEnquiry.nationality__c = leadWrap.nationality;
                            oneEnquiry.Mobile_Country_Code__c = leadWrap.countryCode;
                            if(leadWrap.language == 'en'){
                                oneEnquiry.Language__c = 'English';    
                            }else{
                                oneEnquiry.Language__c = leadWrap.language;    
                            } 
                            oneEnquiry.Route_To_Saturday_Queue1__c = true;
                            //oneEnquiry.ownerId = mapgroupNameToId.get('Saturday Queue For Lead Assignments');
                            oneEnquiry.Client_Comments__c = leadWrap.comments != null ? leadWrap.comments : null;
                            upsertList.add(oneEnquiry);
                        }
                        if(!upsertList.isEmpty()) {
                            List<Database.saveResult> enquirySave = database.insert(upsertList,false);
                            for (Database.SaveResult sr : enquirySave) {
                                if (sr.isSuccess()) {
                                    gen.writeStartObject();     
                                    gen.writeBooleanField('success', true);
                                    gen.writeNumberField('statusCode', 200);
                                    gen.writeStringField('status', 'Success');
                                    gen.writeStringField('Message', 'Operation Successfull');
                                    gen.writeEndObject();
                                    responseString = gen.getAsString();
                                    taskList.add(createEnquiryTask(leadWrap, sr.getId(), 'Re Enquiry Received from: Mobile App')); 
                                    statusCode = '200';
                                } else {
                                    for (Database.Error error : sr.getErrors()) {
                                        gen.writeStartObject(); 
                                        gen.writeBooleanField('success', false);
                                        gen.writeNumberField('statusCode', 400);
                                        gen.writeStringField('status', 'Error');
                                        gen.writeStringField('Message', 'Error==> '+ error.getMessage());
                                        gen.writeEndObject();
                                        responseString = gen.getAsString();
                                        statusCode = '400';
                                    }
                                }
                            }
                        }
                    } 
                    else {
                        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                        Contact newContact = new Contact();
                        newContact.RecordTypeId = RecordTypeIdContact;
                        newContact.FirstName = leadWrap.firstName;
                        newContact.LastName = leadWrap.lastName;
                        newContact.Email = leadWrap.Email;
                        newContact.Phone = formatMobile;
                        newContact.Description = leadWrap.comments;
                        //newContact.AccountId = accId;
                        Database.saveResult insertACC = database.insert(newContact);
                        system.debug('insertACC::'+insertACC);
                        if(insertACC.isSuccess()) {
                            system.debug('getId::'+insertACC.getId());
                            PropStrength__Request__c oneEnquiry = new PropStrength__Request__c();
                            oneEnquiry.PropStrength__Primary_Contact__c = insertACC.getId();
                            oneEnquiry.PropStrength__Enquiry_Type__c = 'Direct';
                            oneEnquiry.PropStrength__Request_Source__c = 'Web';
                            oneEnquiry.Enquiry_Sub_Source__c = 'Mobile App';
                            oneEnquiry.PropStrength__Request_Status__c = 'Open';
                            oneEnquiry.News_Offer_Subscription__c = true;
                            oneEnquiry.nationality__c = leadWrap.nationality;
                            oneEnquiry.Mobile_Country_Code__c = leadWrap.countryCode;
                            if(leadWrap.language == 'en'){
                                oneEnquiry.Language__c = 'English';    
                            }else{
                                oneEnquiry.Language__c = leadWrap.language;    
                            } 
                            oneEnquiry.Route_To_Saturday_Queue1__c = true;
                            //oneEnquiry.ownerId = mapgroupNameToId.get('Saturday Queue For Lead Assignments');
                            oneEnquiry.Client_Comments__c = leadWrap.comments != null ? leadWrap.comments : null;
                            Database.saveResult insertEnq = database.insert(oneEnquiry);
                            system.debug('insertEnq::'+insertEnq);
                            if(insertEnq.isSuccess()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeEndObject();
                                responseString = gen.getAsString();
                                taskList.add(createEnquiryTask(leadWrap, insertEnq.getId(), 'Re Enquiry Received from: Mobile App')); 
                                statusCode = '200';
                            } else {
                                gen.writeStartObject(); 
                                gen.writeBooleanField('success', false);
                                gen.writeNumberField('statusCode', 400);
                                gen.writeStringField('status', 'Error');
                                gen.writeStringField('Message', 'Error==>'+insertEnq.getErrors());
                                gen.writeEndObject();
                                responseString = gen.getAsString();
                                statusCode = '400';
                            }
                        } 
                        else {
                            gen.writeStartObject(); 
                            gen.writeBooleanField('success', false);
                            gen.writeNumberField('statusCode', 400);
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'Error==>'+insertACC.getErrors());
                            gen.writeEndObject();
                            responseString = gen.getAsString();
                            statusCode = '400';
                        }
                    }
                } catch(Exception e) {
                    gen.writeStartObject();  
                    gen.writeBooleanField('success', false);
                    gen.writeNumberField('statusCode', 400);
                    gen.writeStringField('status', 'Error');
                    gen.writeStringField('Message', 'Error==>'+String.valueOf(e.getMessage()));
                    gen.writeEndObject();
                    responseString = gen.getAsString();
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                    statusCode = '400';
                }
                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                logError.Response_Body__c = responseString;
                logError.Class_Name__c = 'PSGetCreateLeadMobileHelper';
                logError.API_Name__c = '/services/apexrest/registeruser/';
                logError.Status__c = statusCode;
                logError.Request_Body__c = JSON.serialize(jsonString);
                insert logError;
            }
        return responseString;
    }
    
    public static Task createEnquiryTask(PSGetCreateLeadMobilePOJO leadWrap, Id l, String subject){
        Task reinquiryTask = new Task();
        reinquiryTask.Subject = subject;
        reinquiryTask.Task_Type__c = 'Enquiry Received';
        reinquiryTask.WhoId = l;
        reinquiryTask.ActivityDate = Date.Today();
        reinquiryTask.Enquiry_Source__c = 'Digital';
        reinquiryTask.Enquiry_Sub_Source__c = 'Mobile App';
        reinquiryTask.Email_Id__c = leadWrap.email;
        reinquiryTask.Email_Id_New__c = leadWrap.email;
        reinquiryTask.dialingCode__c = leadWrap.countryCode;
        reinquiryTask.Mobile_Number_Webform__c = leadWrap.mobile;
        //reinquiryTask.News_Offer_Subscription__c = leadWrap.newsAndOffers;
        //reinquiryTask.Are_you_looking_for__c = leadWrap.comments;//added by Ananth
        return reinquiryTask;
    }
    
    global class PSGetCreateLeadMobilePOJO{
        public String firstName;
        public String lastName;
        public String email;
        public String mobile;
        public String countryCode;
        public String nationality;
        public String language;
        public Boolean newsAndOffers;
        public String modeOfContact;
        public String comments;
        public String unitId;
        public String towerId;
    }
}