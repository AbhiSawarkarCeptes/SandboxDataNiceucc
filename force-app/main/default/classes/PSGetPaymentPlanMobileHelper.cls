global class PSGetPaymentPlanMobileHelper {
    global Static String GetPaymentPlanMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {
                    PSGetApplicantDetailMobilePOJO allApplicantDetail = (PSGetApplicantDetailMobilePOJO) JSON.deserialize(jsonString, PSGetApplicantDetailMobilePOJO.class);
                    if(allApplicantDetail != null) {
                        if(!String.isBlank(allApplicantDetail.bookingId)) {
                            List<PropStrength__Payment_Plan_Details__c> ppdList = [SELECT Id,Name,PropStrength__Milestone__r.PropStrength__Milestone_Name__c,PropStrength__Amount_Percent__c,PropStrength__Payment_Due_Date__c,
                                                                                   PropStrength__Total_Amount_Due__c,PropStrength__Milestone__r.PropStrength__Milestone_Code__c,Booking_Status__c,PropStrength__Balance__c
                                                                                   FROM PropStrength__Payment_Plan_Details__c 
                                                                                   WHERE PropStrength__Application_Booking__c =: allApplicantDetail.bookingId];
                            if(!ppdList.isEmpty()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeFieldName('data');
                                gen.writeStartArray();
                                for(PropStrength__Payment_Plan_Details__c appDetail : ppdList) {
                                    gen.writeStartObject();
                                    gen.writeStringField('name', !String.isBlank(appDetail.Name) ? appDetail.Name : '');
                                    gen.writeStringField('installment', !String.isBlank(appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Name__c) ? appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Name__c : '');
                                    gen.writeStringField('amount', appDetail.PropStrength__Total_Amount_Due__c != null ? String.valueOf(appDetail.PropStrength__Total_Amount_Due__c) : '');
                                    gen.writeStringField('description', appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Code__c != null ? appDetail.PropStrength__Milestone__r.PropStrength__Milestone_Code__c : '');
                                    gen.writeStringField('dueDate', String.valueOf(Date.newinstance(appDetail.PropStrength__Payment_Due_Date__c.year(), appDetail.PropStrength__Payment_Due_Date__c.month(), appDetail.PropStrength__Payment_Due_Date__c.day())));
                                    gen.writeStringField('chargePercent', appDetail.PropStrength__Amount_Percent__c != null ? String.valueOf(appDetail.PropStrength__Amount_Percent__c) : '');
                                    if(appDetail.PropStrength__Total_Amount_Due__c == appDetail.PropStrength__Balance__c ||
                                       appDetail.PropStrength__Total_Amount_Due__c > appDetail.PropStrength__Balance__c) {
                                        gen.writeStringField('paymentStatus', 'Unpaid');
                                    } else if(appDetail.PropStrength__Balance__c == 0) {
                                        gen.writeStringField('paymentStatus', 'Paid');
                                    } else {
                                        gen.writeStringField('paymentStatus', 'In Progress');
                                    }
                                    //gen.writeStringField('paymentStatus', (appDetail.Booking_Status__c != null && appDetail.Booking_Status__c != '') ? appDetail.Booking_Status__c : '');
                                    //gen.writeStringField('projectName', appDetail.PropStrength__Application_Booking__r.PropStrength__Project__r.Name != null ? appDetail.PropStrength__Application_Booking__r.PropStrength__Project__r.Name : '');
                                    gen.writeEndObject();
                                }
                                gen.writeEndArray();
                                gen.writeEndObject();
                                responce = gen.getAsString();
                                
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = responce;
                                logError.Class_Name__c = 'PSGetPaymentPlanMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getPaymentPlan/';
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
                                logError.Class_Name__c = 'PSGetPaymentPlanMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getPaymentPlan/';
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
                            logError.Class_Name__c = 'PSGetPaymentPlanMobileHelper';
                            logError.API_Name__c = '/services/apexrest/getPaymentPlan/';
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
                    logError.Class_Name__c = 'PSGetPaymentPlanMobileHelper';
                    logError.API_Name__c = '/services/apexrest/getPaymentPlan/';
                    logError.Status__c = '400';
                    logError.Request_Body__c = JSON.serialize(jsonString);
                    insert logError;
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                }
            }
        return responce;
    }
}