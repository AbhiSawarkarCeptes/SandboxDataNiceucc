global class PSBookingListMobileHelper {
    global Static String GetBookingMobile(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                try {
                    String jsonString = request.requestBody.toString();
                    RequestWrapper objcase = (RequestWrapper)System.JSON.deserialize(jsonString,RequestWrapper.class);
                    set<Id> bookingIds = new Set<Id>();
                    map<Id,Boolean> trMap = new map<Id,Boolean>();
                    if(objcase.email != null && objcase.email != '') {
                        List<PropStrength__Applicant_Detail__c> applicantList = [SELECT Id,Name,PropStrength__Application__c,PropStrength__Application__r.PropStrength__Property__c,
                                                                                 PropStrength__Application__r.PropStrength__Property__r.PropStrength__Property_Name__c,
                                                                                 PropStrength__Application__r.PropStrength__Project__r.Master_Project__c,PropStrength__Application__r.Id,
                                                                                 PropStrength__Application__r.PropStrength__Property__r.Name,PropStrength__Application__r.Name,
                                                                                 PropStrength__Application__r.PropStrength__Property__r.PropStrength__Tower__c,
                                                                                 PropStrength__Application__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c,
                                                                                 PropStrength__Application__r.PropStrength__Project__c,PropStrength__Application__r.PropStrength__Project__r.Name,
                                                                                 PropStrength__Application__r.PropStrength__Status__c,
                                                                                 PropStrength__Application__r.PropStrength__Project__r.Master_Project__r.Name
                                                                                 FROM PropStrength__Applicant_Detail__c
                                                                                 WHERE PropStrength__Applicant_Email__c =: objcase.email AND
                                                                                 PropStrength__Active__c =: true AND
                                                                                 PropStrength__Application__c != null];
                        if(!applicantList.isEmpty()) {
                            for(PropStrength__Applicant_Detail__c book : applicantList) {
                                bookingIds.add(book.PropStrength__Application__c);
                            }
                            system.debug('bookingIds::'+bookingIds);
                            if(!bookingIds.isEmpty()) {
                                List<PropStrength__Transaction_Requests__c> trList = [SELECT Id,PropStrength__Application_Booking__c,PropStrength__Status__c
                                                                                      FROM PropStrength__Transaction_Requests__c
                                                                                      WHERE PropStrength__Application_Booking__c IN: bookingIds AND
                                                                                      //PropStrength__Status__c =: 'Request Completed' AND
                                                                                      RecordType.Name =: 'Transfer Of Property'];
                                 system.debug('trMap::'+trList);
                                if(!trList.isEmpty()) {
                                    for(PropStrength__Transaction_Requests__c tr : trList) {
                                        if(tr.PropStrength__Status__c == 'Request Completed') {
                                            trMap.put(tr.PropStrength__Application_Booking__c,true);
                                        } else {
                                            trMap.put(tr.PropStrength__Application_Booking__c,false);
                                        }
                                    } 
                                }
                            }
                            system.debug('trMap::'+trMap);
                            gen.writeStartObject();     
                            gen.writeBooleanField('success', true);
                            gen.writeNumberField('statusCode', 200);
                            gen.writeStringField('status', 'Success');
                            gen.writeStringField('Message', 'Operation Successfull');
                            gen.writeFieldName('data');
                            gen.writeStartArray();
                            for(PropStrength__Applicant_Detail__c book : applicantList) {
                                gen.writeStartObject();
                                gen.writeStringField('unitName', (book.PropStrength__Application__r.PropStrength__Property__r.PropStrength__Property_Name__c != null) ? book.PropStrength__Application__r.PropStrength__Property__r.PropStrength__Property_Name__c : '');
                                gen.writeStringField('towerName', book.PropStrength__Application__r.PropStrength__Property__c != null && book.PropStrength__Application__r.PropStrength__Property__r.PropStrength__Tower__c != null ? book.PropStrength__Application__r.PropStrength__Property__r.PropStrength__Tower__r.PropStrength__Tower_Name__c : '');
                                gen.writeStringField('projectName', book.PropStrength__Application__r.PropStrength__Project__c != null ? book.PropStrength__Application__r.PropStrength__Project__r.Name : '');
                                gen.writeStringField('isresale', (trMap.containsKey(book.PropStrength__Application__c) && trMap.get(book.PropStrength__Application__c) == true) ? 'true' : 'false');
                                gen.writeStringField('clusterName', book.PropStrength__Application__r.PropStrength__Project__c != null && book.PropStrength__Application__r.PropStrength__Project__r.Master_Project__c != null ? book.PropStrength__Application__r.PropStrength__Project__r.Master_Project__r.Name : '');
                                gen.writeStringField('bookingStatus', (book.PropStrength__Application__r.PropStrength__Status__c != null && book.PropStrength__Application__r.PropStrength__Status__c != '') ? book.PropStrength__Application__r.PropStrength__Status__c : '');
                                gen.writeStringField('bookingName', book.PropStrength__Application__r.Name);
                                gen.writeStringField('bookingID', book.PropStrength__Application__r.Id);
                                gen.writeEndObject();
                            }
                            gen.writeEndArray();
                            gen.writeEndObject();
                            responce = gen.getAsString();
                        } else {
                            gen.writeStartObject();     
                            gen.writeBooleanField('success', false);
                            gen.writeNumberField('statusCode', 400);
                            gen.writeStringField('status', 'Error');
                            gen.writeStringField('Message', 'No Appliant or No Active Applicant Found.');
                            gen.writeFieldName('data');
                            gen.writeStartArray();
                            gen.writeEndArray();
                            gen.writeEndObject();
                            responce = gen.getAsString();
                        }
                    } else {
                        gen.writeStartObject();     
                        gen.writeBooleanField('success', false);
                        gen.writeNumberField('statusCode', 400);
                        gen.writeStringField('status', 'Error');
                        gen.writeStringField('Message', 'Email is Required.');
                        gen.writeFieldName('data');
                        gen.writeStartArray();
                        gen.writeEndArray();
                        gen.writeEndObject();
                        responce = gen.getAsString();
                    }
                } catch(Exception e) {gen.writeStartObject();gen.writeBooleanField('success', false);
                    gen.writeNumberField('statusCode', 400);gen.writeStringField('status', 'Error');gen.writeStringField('Message', String.valueOf(e.getMessage()));
                    gen.writeFieldName('data');gen.writeStartArray();gen.writeEndArray();gen.writeEndObject();responce = gen.getAsString();
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                }
            }
        return responce;
    }
    
    public class RequestWrapper{
        public String email;
    }
}