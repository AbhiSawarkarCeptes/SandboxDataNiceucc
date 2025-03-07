global class PSGetPaymentReceiptsMobileHelper {
    global Static String GetPaymentReceiptsMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {                    
                    PSGetApplicantDetailMobilePOJO allApplicantDetail = (PSGetApplicantDetailMobilePOJO) JSON.deserialize(jsonString, PSGetApplicantDetailMobilePOJO.class);
                    if(allApplicantDetail != null) {
                        if(!String.isBlank(allApplicantDetail.bookingId)) {
                            List<PropStrength__Received_Payment__c> appList = [SELECT Id,Receipt_Status__c,Name,PropStrength__Amount__c,Receipt_Number__c,PropStrength__Payment_Type__c,
                                                                               createdDate,PropStrength__Application_Booking__r.PropStrength__Project__r.Name,
                                                                               PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c
                                                                               FROM PropStrength__Received_Payment__c
                                                                               WHERE PropStrength__Application_Booking__c =: allApplicantDetail.bookingId
                                                                               AND Recordtype.Name =: 'Payment Received'];
                            List<Payment_Request__c> payRequestList = [SELECT Id,Name,Status__c,Mode__c,Total_Amount__c,Unit__r.Name,createddate,
                                                                       Application_Booking__r.PropStrength__Project__r.Name,Amount__c,Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c
                                                                       FROM Payment_Request__c
                                                                       WHERE Application_Booking__c =: allApplicantDetail.bookingId];
                            List<Interim_Payments__c> interimList = [SELECT Id,Name,createddate,Approval_Status_Interim__c,Payment_Request__r.Name,
                                                                     Application_Booking_Interim__r.PropStrength__Project__r.Name,Payment_Mode_Interim__c,
                                                                     Amount_Interim__c,Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__House_Unit_No__c
                                                                     FROM Interim_Payments__c
                                                                     WHERE Application_Booking_Interim__c =: allApplicantDetail.bookingId];
                            if(!appList.isEmpty()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeFieldName('data');
                                gen.writeStartArray();
                            } else if(appList.isEmpty() && !payRequestList.isEmpty()) {
                                gen.writeStartObject();     
                                gen.writeBooleanField('success', true);
                                gen.writeNumberField('statusCode', 200);
                                gen.writeStringField('status', 'Success');
                                gen.writeStringField('Message', 'Operation Successfull');
                                gen.writeFieldName('data');
                                gen.writeStartArray();
                            }
                            if(!appList.isEmpty()) {
                                for(PropStrength__Received_Payment__c appDetail : appList) {
                                    gen.writeStartObject();
                                    gen.writeStringField('id', appDetail.Id);
                                    gen.writeStringField('name', !String.isBlank(appDetail.Name) ? appDetail.Name : '');
                                    gen.writeStringField('mode', !String.isBlank(appDetail.PropStrength__Payment_Type__c) ? appDetail.PropStrength__Payment_Type__c : '');
                                    gen.writeStringField('receiptNumber', appDetail.Name != null ? appDetail.Name : '');
                                    gen.writeStringField('totalamount', appDetail.PropStrength__Amount__c != null ? String.valueOf(appDetail.PropStrength__Amount__c) : '');
                                    gen.writeStringField('createdDate', String.valueOf(Date.newinstance(appDetail.createddate.year(), appDetail.createddate.month(), appDetail.createddate.day())));
                                    gen.writeStringField('unitName', appDetail.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c != null ? appDetail.PropStrength__Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c : '');
                                    gen.writeStringField('projectName', appDetail.PropStrength__Application_Booking__r.PropStrength__Project__r.Name != null ? appDetail.PropStrength__Application_Booking__r.PropStrength__Project__r.Name : '');
                                    gen.writeStringField('prstatus', 'Completed');
                                    //gen.writeStringField('prstatus', appDetail.Receipt_Status__c != null ? appDetail.Receipt_Status__c : '');
                                    gen.writeEndObject();
                                }
                            }
                            if(!payRequestList.isEmpty()) {
                                for(Payment_Request__c appDetail : payRequestList) {
                                    if (!appDetail.Status__c.contains('Approved')) { // && !appDetail.Status__c.contains('Rejected')
                                        gen.writeStartObject();
                                        gen.writeStringField('id', appDetail.Id);
                                        gen.writeStringField('name', !String.isBlank(appDetail.Name) ? appDetail.Name : '');
                                        gen.writeStringField('mode', !String.isBlank(appDetail.Mode__c) ? appDetail.Mode__c : '');
                                        gen.writeStringField('receiptNumber', appDetail.name != null ? appDetail.name : '');
                                        gen.writeStringField('totalamount', appDetail.Amount__c != null ? String.valueOf(appDetail.Amount__c) : '');
                                        gen.writeStringField('createdDate', String.valueOf(Date.newinstance(appDetail.createddate.year(), appDetail.createddate.month(), appDetail.createddate.day())));
                                        //gen.writeStringField('unitName', appDetail.Unit__r.Name != null ? appDetail.Unit__r.Name : '');
                                        gen.writeStringField('unitName', appDetail.Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c != null ? appDetail.Application_Booking__r.PropStrength__Property__r.PropStrength__House_Unit_No__c : '');
                                        gen.writeStringField('projectName', appDetail.Application_Booking__r.PropStrength__Project__r.Name != null ? appDetail.Application_Booking__r.PropStrength__Project__r.Name : '');
                                        gen.writeStringField('prstatus', 'In Progress');
                                        gen.writeEndObject();
                                    }
                                }
                            }
                            if(!interimList.isEmpty()) {
                                for(Interim_Payments__c appDetail: interimList) {
                                    if (!appDetail.Approval_Status_Interim__c.contains('Approved')) { // && !appDetail.Status__c.contains('Rejected')
                                        gen.writeStartObject();
                                        gen.writeStringField('id', appDetail.Id);
                                        gen.writeStringField('name', !String.isBlank(appDetail.Payment_Request__r.Name) ? appDetail.Payment_Request__r.Name : '');
                                        gen.writeStringField('mode', !String.isBlank(appDetail.Payment_Mode_Interim__c) ? appDetail.Payment_Mode_Interim__c : '');
                                        gen.writeStringField('receiptNumber', appDetail.name != null ? appDetail.name : '');
                                        gen.writeStringField('totalamount', appDetail.Amount_Interim__c != null ? String.valueOf(appDetail.Amount_Interim__c) : '');
                                        gen.writeStringField('createdDate', String.valueOf(Date.newinstance(appDetail.createddate.year(), appDetail.createddate.month(), appDetail.createddate.day())));
                                        //gen.writeStringField('unitName', appDetail.Unit__r.Name != null ? appDetail.Unit__r.Name : '');
                                        gen.writeStringField('unitName', appDetail.Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__House_Unit_No__c != null ? appDetail.Application_Booking_Interim__r.PropStrength__Property__r.PropStrength__House_Unit_No__c : '');
                                        gen.writeStringField('projectName', appDetail.Application_Booking_Interim__r.PropStrength__Project__r.Name != null ? appDetail.Application_Booking_Interim__r.PropStrength__Project__r.Name : '');
                                        gen.writeStringField('prstatus', 'In Progress');
                                        gen.writeEndObject();
                                    }
                                }
                            }
                            gen.writeEndArray();
                            gen.writeEndObject();
                            responce = gen.getAsString();
                            if(!appList.isEmpty() || !payRequestList.isEmpty()) {
                                Mobile_App_Log__c logError = new Mobile_App_Log__c();
                                logError.Response_Body__c = responce;
                                logError.Class_Name__c = 'PSGetPaymentReceiptsMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getPaymentReceipts/';
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
                                logError.Class_Name__c = 'PSGetPaymentReceiptsMobileHelper';
                                logError.API_Name__c = '/services/apexrest/getPaymentReceipts/';
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
                            logError.Class_Name__c = 'PSGetPaymentReceiptsMobileHelper';
                            logError.API_Name__c = '/services/apexrest/getPaymentReceipts/';
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
                    logError.Class_Name__c = 'PSGetPaymentReceiptsMobileHelper';
                    logError.API_Name__c = '/services/apexrest/getPaymentReceipts/';
                    logError.Status__c = '400';
                    logError.Request_Body__c = JSON.serialize(jsonString);
                    insert logError;
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                }
            }
        return responce;
    }
}