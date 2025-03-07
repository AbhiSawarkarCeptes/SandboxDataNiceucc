@RestResource(urlMapping='/V1/PS/createRequest')
global class PSPayRequestMobile {
    
    @HttpPost 
    global static void doCreateCase() {
        RestResponse res = RestContext.response;
        List<ResponseWrapper> resWrap = new List<ResponseWrapper>();
        List<PropStrength__Service_Request__c> casesToInsert = new List<PropStrength__Service_Request__c>();
        RestRequest request = RestContext.request;
        String responseString = '';
        String errorMessage = '';
        RequestWrapper objcase = (RequestWrapper)System.JSON.deserialize(request.requestBody.toString(),RequestWrapper.class);
        try {
            if(objcase != null) {
                if(objcase.bookingId == null && objcase.bookingId == '') {
                    res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'Error','bookingId is Required',400,false,'')));
                    res.statusCode = 400;
                }
                if(objcase.bookingId != null && objcase.bookingId != '') {
                    List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,Name,PropStrength__Primary_Customer__c
                                                                              FROM PropStrength__Application_Booking__c
                                                                              WHERE Id =: objcase.bookingId];
                    if(bookingList.size() > 0) {
                        for(PropStrength__Application_Booking__c app : bookingList) {
                            PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
                            sr.RecordtypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
                            if(objcase.email != null && objcase.email != '' &&
                               objcase.email.trim() != '') {
                                   sr.PropStrength__Contact_Email__c = objcase.email;
                               }
                            if(objcase.mobile != null && objcase.mobile != '' &&
                               objcase.mobile.trim() != '') {
                                   sr.PropStrength__Contact_Phone__c = objcase.mobile;
                               }
                            sr.PropStrength__Priority__c = 'Medium';
                            sr.PropStrength__Request_Origin__c = 'Mobile App';
                            sr.SR_Department__c = 'CRM';
                            sr.SR_Category__c = objcase.requestType;
                            sr.SR_Sub_Category__c = 'Others';
                            sr.PropStrength__Comments__c = 'Updated the details';
                            sr.Contact__c = app.PropStrength__Primary_Customer__c;
                            sr.PropStrength__Application_Booking__c = app.Id;
                            sr.PropStrength__Description__c = objcase.description;
                            casesToInsert.add(sr);
                        }
                        if(casesToInsert.size() > 0){
                            insert casesToInsert;
                            system.debug('casesToInsert::'+casesToInsert);
                            if(!casesToInsert.isEmpty()) {
                                set<Id> srIds = new Set<Id>();
                                for(PropStrength__Service_Request__c sr : casesToInsert) {
                                    srIds.add(sr.Id);
                                }
                                if(!srIds.isEmpty()) {
                                    List<PropStrength__Service_Request__c> srList = [SELECT Id,RecordTypeId,Name,PropStrength__Contact_Email__c,PropStrength__Contact_Phone__c,
                                                                                     PropStrength__Request_Origin__c,SR_Category__c,PropStrength__Application_Booking__c,PropStrength__Description__c,
                                                                                     Contact__c,Additional_Comments__c,PropStrength__Priority__c
                                                                                     FROM PropStrength__Service_Request__c 
                                                                                     WHERE Id IN: srIds];
                                    if(!srList.isEmpty()) {
                                        for(PropStrength__Service_Request__c sr : srList) {
                                            ResponseWrapper rep = new ResponseWrapper();
                                            //rep.caseNumber = sr.Name;
                                            rep.attributes = new Attribute();
                                            rep.attributes.type = 'Case';
                                            rep.attributes.url = '/services/data/v58.0/sobjects/Case/'+sr.Id;
                                            rep.Id = sr.Id;
                                            rep.RecordTypeId = sr.RecordTypeId != null ? sr.RecordTypeId : '';
                                            rep.Department = sr.RecordTypeId != null ? 'CRM' : '';
                                            rep.SuppliedEmail = sr.PropStrength__Contact_Email__c != null ? sr.PropStrength__Contact_Email__c : '';
                                            rep.SuppliedPhone = sr.PropStrength__Contact_Phone__c != null ? sr.PropStrength__Contact_Phone__c : '';
                                            rep.Origin = sr.PropStrength__Request_Origin__c != null ? sr.PropStrength__Request_Origin__c : '';
                                            rep.Category = sr.SR_Category__c != null ? sr.SR_Category__c : '';
                                            rep.Booking = sr.PropStrength__Application_Booking__c != null ? sr.PropStrength__Application_Booking__c : '';
                                            rep.Description = sr.PropStrength__Description__c != null ? sr.PropStrength__Description__c : '';
                                            rep.Contact = sr.Contact__c != null ? sr.Contact__c : '';
                                            rep.Comments = sr.Additional_Comments__c != null ? sr.Additional_Comments__c : '';
                                            rep.Priority = sr.PropStrength__Priority__c != null ? sr.PropStrength__Priority__c : '';
                                            resWrap.add(rep);
                                        }
                                        String str = JSON.serialize(prepareResponse(resWrap,'Operation Successfull','Success',200,true,srList[0].name));
                                        system.debug('str::'+str);
                                        str = str.replace('Department', 'Department__c');
                                        str = str.replace('Category', 'Category__c');
                                        str = str.replace('Booking', 'Booking__c');
                                        system.debug('ptr::'+str);
                                        responseString = (prepareResponse(resWrap,'Operation Successfull','Success',200,true,srList[0].name)).toString().replace('"','');
                                        res.responseBody =  Blob.valueOf(str);
                                        res.statusCode = 200;
                                    }
                                }
                            }
                        }
                    } else {
                        res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'No data found','No Booking Record Found.',400,false,'')));
                        res.statusCode = 400;
                    }
                }
            }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            system.debug('~~Error: '+ex.getMessage()+'__'+ex.getStackTraceString());
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error',errorMessage,400,false,'')));
            res.statusCode = 400;
        } 
    }
    
    public static HttpResponseWrapper prepareResponse(list<ResponseWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess,String rcaseNumber){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.body = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        resWrap.caseNumber = rcaseNumber;
        return resWrap;
    }
    
    public class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public list<ResponseWrapper> body = new list<ResponseWrapper>();
        public boolean success;
        public sObject record;
        public String Message;
        public String caseNumber;
    }
    
    public class RequestWrapper{
        public String email;
        public String mobile;
        public String description;
        public String requestType;
        public String bookingId;
    }
    
    Global class Attribute {
        Global String type;
        Global String url;
    }
    
    Global Class ResponseWrapper {
        Global String caseNumber;
        Global Attribute attributes;
        Global String Id;
        Global String RecordTypeId;
        global string SuppliedEmail;
        global string SuppliedPhone;
        global string Origin;
        global string Department;
        global string Category;
        global string Booking;
        global string Description;
        global string Priority;
        global string Comments;
        global string Contact;
    }
}