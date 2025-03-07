global class PSGetStatementOfAccountMobileHelper {
    global Static String GetStatementOfAccountMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                String jsonString = request.requestBody.toString();
                try {
                    PSGetApplicantDetailMobilePOJO allBookingDetail = (PSGetApplicantDetailMobilePOJO) JSON.deserialize(jsonString, PSGetApplicantDetailMobilePOJO.class);
                    if(allBookingDetail != null) {
                        List<PropStrength__Application_Booking__c> appList = [SELECT Id,Name,PropStrength__Booking_Amount_Received__c,PropStrength__Total_Basic_Sales_Price__c,
                                                                              PropStrength__Booking_Amount__c,
                                                                              (SELECT Id,Recordtype.Name,Name,PropStrength__Payment_Date__c,Demand_Status__c,
                                                                               PropStrength__Actual_Payment_Date__c,PropStrength__Amount__c,PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c
                                                                               FROM PropStrength__Payments_Cheques__r)
                                                                              FROM PropStrength__Application_Booking__c
                                                                              WHERE Id =: allBookingDetail.bookingId];
                        if(!appList.isEmpty()) {
                            gen.writeStartObject();     
                            gen.writeBooleanField('success', true);
                            gen.writeNumberField('statusCode', 200);
                            gen.writeStringField('status', 'Success');
                            gen.writeStringField('Message', 'Operation Successfull');
                            gen.writeFieldName('data');
                            gen.writeStartArray();
                            for(PropStrength__Application_Booking__c oneBook : appList) {
                                gen.writeStartObject(); 
                                gen.writeStringField('purchasePrice', oneBook.PropStrength__Total_Basic_Sales_Price__c != null ? String.valueOf(oneBook.PropStrength__Total_Basic_Sales_Price__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                gen.writeStringField('regAmountPaid', oneBook.PropStrength__Booking_Amount__c != null ? String.valueOf(oneBook.PropStrength__Booking_Amount__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                gen.writeStringField('totalAmount', oneBook.PropStrength__Booking_Amount_Received__c != null ? String.valueOf(oneBook.PropStrength__Booking_Amount_Received__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                gen.writeStringField('paidAmount', oneBook.PropStrength__Booking_Amount_Received__c != null ? String.valueOf(oneBook.PropStrength__Booking_Amount_Received__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                if(oneBook.PropStrength__Payments_Cheques__r != null) {
                                    gen.writeFieldName('demandList');
                                    gen.writeStartArray();
                                    for(PropStrength__Received_Payment__c onePay : oneBook.PropStrength__Payments_Cheques__r) {
                                        if(onePay.Recordtype.Name == 'Payment Due') {
                                            gen.writeStartObject();
                                            gen.writeStringField('name', !String.isBlank(onePay.Name) ? onePay.Name : '');
                                            gen.writeStringField('createdDate', onePay.PropStrength__Payment_Date__c != null ? String.valueOf(onePay.PropStrength__Payment_Date__c) : '');
                                            gen.writeStringField('dueDate', onePay.PropStrength__Actual_Payment_Date__c != null ? String.valueOf(onePay.PropStrength__Actual_Payment_Date__c) : '');
                                            gen.writeStringField('isReversed', !String.isBlank(onePay.Demand_Status__c) ? onePay.Demand_Status__c : '');
                                            gen.writeStringField('amount', onePay.PropStrength__Amount__c != null ? String.valueOf(onePay.PropStrength__Amount__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                            gen.writeStringField('installment', !String.isBlank(onePay.Name) ? onePay.Name : '');
                                            gen.writeStringField('milesstoneName', !String.isBlank(onePay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c) ? onePay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c : '');
                                            gen.writeStringField('debitType', 'Debit');
                                            gen.writeEndObject();
                                        }
                                    }
                                    gen.writeEndArray();
                                    gen.writeFieldName('receiptList');
                                    gen.writeStartArray();
                                    for(PropStrength__Received_Payment__c onePay : oneBook.PropStrength__Payments_Cheques__r) {
                                        if(onePay.Recordtype.Name == 'Payment Received') {
                                            gen.writeStartObject();
                                            gen.writeStringField('name', !String.isBlank(onePay.Name) ? onePay.Name : '');
                                            gen.writeStringField('createdDate', onePay.PropStrength__Payment_Date__c != null ? String.valueOf(onePay.PropStrength__Payment_Date__c) : '');
                                            gen.writeStringField('dueDate', onePay.PropStrength__Actual_Payment_Date__c != null ? String.valueOf(onePay.PropStrength__Actual_Payment_Date__c) : '');
                                            gen.writeStringField('isReversed', !String.isBlank(onePay.Demand_Status__c) ? onePay.Demand_Status__c : '');
                                            gen.writeStringField('amount', onePay.PropStrength__Amount__c != null ? String.valueOf(onePay.PropStrength__Amount__c.setScale(2, RoundingMode.HALF_UP)) : '0');
                                            gen.writeStringField('installment', !String.isBlank(onePay.Name) ? onePay.Name : '');
                                            gen.writeStringField('milesstoneName', !String.isBlank(onePay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c) ? onePay.PropStrength__Payment_Plan_Detail__r.PropStrength__Milestone_Name__c : '');
                                            gen.writeStringField('debitType', 'Credit');
                                            gen.writeEndObject();
                                        }
                                    }
                                    gen.writeEndArray();
                                }
                                gen.writeEndObject();
                            }
                            gen.writeEndArray();
                            gen.writeEndObject();
                            responce = gen.getAsString();
                            
                            Mobile_App_Log__c logError = new Mobile_App_Log__c();
                            logError.Response_Body__c = responce;
                            logError.Class_Name__c = 'PSGetStatementOfAccountMobileHelper';
                            logError.API_Name__c = '/services/apexrest/getStatementOfAccount/';
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
                            logError.Class_Name__c = 'PSGetStatementOfAccountMobileHelper';
                            logError.API_Name__c = '/services/apexrest/getStatementOfAccount/';
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
                        logError.Class_Name__c = 'PSGetStatementOfAccountMobileHelper';
                        logError.API_Name__c = '/services/apexrest/getStatementOfAccount/';
                        logError.Status__c = '400';
                        logError.Request_Body__c = JSON.serialize(jsonString);
                        insert logError;
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
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                    Mobile_App_Log__c logError = new Mobile_App_Log__c();
                    logError.Response_Body__c = responce;
                    logError.Class_Name__c = 'PSGetStatementOfAccountMobileHelper';
                    logError.API_Name__c = '/services/apexrest/getStatementOfAccount/';
                    logError.Status__c = '400';
                    logError.Request_Body__c = JSON.serialize(jsonString);
                    insert logError;
                }
            }
        return responce;
    }
}