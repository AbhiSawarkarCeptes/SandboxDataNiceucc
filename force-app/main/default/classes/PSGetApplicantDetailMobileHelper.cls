global class PSGetApplicantDetailMobileHelper {
    global Static String GetApplicantDetailMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {
                    
                    PSGetApplicantDetailMobilePOJO allApplicantDetail = (PSGetApplicantDetailMobilePOJO) JSON.deserialize(jsonString, PSGetApplicantDetailMobilePOJO.class);
                    if(allApplicantDetail != null) {
                        if(!String.isBlank(allApplicantDetail.bookingId)) {
                            List<PropStrength__Applicant_Detail__c> appList = [SELECT Id,Name,PropStrength__Applicant_Mobile__c,PropStrength__Applicant_Email__c,
                                                                               PropStrength__Applicant_Acc__r.Name,PropStrength__Applicant_Acc__r.Emirates_ID_Details__c,
                                                                               PropStrength__Applicant_Acc__r.Passport_No__c,PropStrength__Type__c
                                                                               FROM PropStrength__Applicant_Detail__c
                                                                               WHERE PropStrength__Application__c =: allApplicantDetail.bookingId 
                                                                               AND PropStrength__Active__c =: true];
                            if(!appList.isEmpty()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeFieldName('data');
                                gen.writeStartArray();
                                for(PropStrength__Applicant_Detail__c appDetail : appList) {
                                    gen.writeStartObject();
                                     gen.writeStringField('Id',appDetail.Id);
                                    gen.writeStringField('ApplicantName', !String.isBlank(appDetail.PropStrength__Applicant_Acc__r.Name) ? appDetail.PropStrength__Applicant_Acc__r.Name : '');
                                    if(appDetail.PropStrength__Type__c == '1st Applicant') {
                                        gen.writeStringField('Applicant_Number', 'Primary Applicant');
                                    } else if(appDetail.PropStrength__Type__c == '2nd Applicant') {
                                        gen.writeStringField('Applicant_Number', 'Second Applicant');
                                    } else if(appDetail.PropStrength__Type__c == '3rd Applicant') {
                                        gen.writeStringField('Applicant_Number', 'Third Applicant');
                                    } else if(appDetail.PropStrength__Type__c == '4th Applicant') {
                                        gen.writeStringField('Applicant_Number', 'Fourth Applicant');
                                    } else if(appDetail.PropStrength__Type__c == '5th Applicant') {
                                        gen.writeStringField('Applicant_Number', 'Fifth Applicant');
                                    }
                                    gen.writeStringField('PassportNo', appDetail.PropStrength__Applicant_Acc__r.Passport_No__c != null ? appDetail.PropStrength__Applicant_Acc__r.Passport_No__c : '');
                                    gen.writeStringField('Emirates_ID', appDetail.PropStrength__Applicant_Acc__r.Emirates_ID_Details__c != null ? appDetail.PropStrength__Applicant_Acc__r.Emirates_ID_Details__c : '');
                                    gen.writeStringField('Email', appDetail.PropStrength__Applicant_Email__c != null ? appDetail.PropStrength__Applicant_Email__c : '');
                                    gen.writeStringField('MobileNumber', appDetail.PropStrength__Applicant_Mobile__c != null ? appDetail.PropStrength__Applicant_Mobile__c : '');
                                    gen.writeEndObject();
                                }
                                gen.writeEndArray();
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = responce;
                                logError.Class_Name__c = 'PSGetApplicantDetailMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getApplicantDetails/';
                                logError.Status__c = '200';
                                logError.Request_Body__c = JSON.serialize(jsonString);
                                insert logError;
                            } else {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', false);
                                gen.writeNumberField('statusCode', 400);
                                gen.writeStringField('status', 'Error');
                                gen.writeStringField('Message', 'No data found');
                                gen.writeFieldName('data');
                                gen.writeStartArray();
                                gen.writeEndArray();
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = responce;
                                logError.Class_Name__c = 'PSGetApplicantDetailMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getApplicantDetails/';
                                logError.Status__c = '400';
                                logError.Request_Body__c = JSON.serialize(jsonString);
                                insert logError;
                            }
                        } else {
                            gen.writeStartObject();    
                            gen.writeBooleanField('success', false);
                            gen.writeNumberField('statusCode', 400);
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'Bookind Id is Required.');
                            gen.writeFieldName('data');
                            gen.writeStartArray();
                            gen.writeEndArray();
                            gen.writeEndObject();
                            responce = gen.getAsString();
                            Mobile_App_Log__c logError = new Mobile_App_Log__c();
                            logError.Response_Body__c = responce;
                            logError.Class_Name__c = 'PSGetApplicantDetailMobileHelper';
                            logError.API_Name__c = '/services/apexrest/getApplicantDetails/';
                            logError.Status__c = '400';
                            logError.Request_Body__c = JSON.serialize(jsonString);
                            insert logError;
                        }
                    }
                } catch(Exception e) {
                    gen.writeStartObject(); 
                    gen.writeBooleanField('success', false); 
                    gen.writeNumberField('statusCode', 400);
                    gen.writeStringField('status', 'Error');
                    gen.writeStringField('Message', String.valueOf(e.getMessage()));
                    gen.writeFieldName('data');
                    gen.writeStartArray();
                    gen.writeEndArray();
                    gen.writeEndObject();
                    responce = gen.getAsString();
                    Mobile_App_Log__c logError = new Mobile_App_Log__c();
                    logError.Response_Body__c = responce;
                    logError.Class_Name__c = 'PSGetApplicantDetailMobileHelper';
                    logError.API_Name__c = '/services/apexrest/getApplicantDetails/';
                    logError.Status__c = '400';
                    logError.Request_Body__c = JSON.serialize(jsonString);
                    insert logError;
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                }
            }
        return responce;
    }
}