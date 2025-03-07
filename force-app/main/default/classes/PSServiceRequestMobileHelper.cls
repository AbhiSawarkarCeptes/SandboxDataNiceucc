@RestResource(urlMapping='/V1/PS/createCase')
global class PSServiceRequestMobileHelper {
    @HttpPost 
    global static void doCreateCase(){
        RestResponse res = RestContext.response;
        List<PropStrength__Service_Request__c> casesToInsert = new List<PropStrength__Service_Request__c>();
        List<PropStrength__Request__c> enqListToUpdate = new List<PropStrength__Request__c>();
        //List<Contact> conListToUpdate = new List<Contact>();
        String statusCode = '';
        List<ResponseWrapper> resWrap = new List<ResponseWrapper>();
        RestRequest request = RestContext.request;
        String responseString = '';
        String errorMessage = '';
        RequestWrapper objcase = (RequestWrapper)System.JSON.deserialize(request.requestBody.toString(),RequestWrapper.class);
        try {
            if(objcase != null){
                system.debug('~~~~'+objcase);
                if(objcase.email == null && objcase.email == '') {
                    res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'Error','Email is Required',400,false)));
                    res.statusCode = 400;
                }
                if(objcase.email != null && objcase.email != '') {
                    if(String.isBlank(objcase.emailNew) && String.isBlank(objcase.mobileNew)) {
                        res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'Error','New Email Or New Mobile is Required',400,false)));
                        res.statusCode = 400;
                    }
                    if(!String.isBlank(objcase.emailNew) || !String.isBlank(objcase.mobileNew)) {
                        String bookingName = '';
                        for(PropStrength__Applicant_Detail__c app : [SELECT Id, Name,PropStrength__Application__r.Name,
                                                                      PropStrength__Application__c
                                                                      FROM PropStrength__Applicant_Detail__c 
                                                                      WHERE PropStrength__Applicant_Email__c =: objcase.email AND
                                                                      PropStrength__Active__c =: true AND
                                                                      PropStrength__Application__c != null AND
                                                                      PropStrength__Application__r.PropStrength__Active__c =: true]) {
                            bookingName += app.PropStrength__Application__r.Name + '\n';
                        }
                        List<PropStrength__Applicant_Detail__c> aplicantDetailsList = [SELECT Id, PropStrength__Applicant_Acc__c,Name,PropStrength__Application__r.Name,
                                                                                       PropStrength__Application__c,PropStrength__Applicant_Email__c,PropStrength__Applicant_Mobile__c
                                                                                       FROM PropStrength__Applicant_Detail__c 
                                                                                       WHERE PropStrength__Applicant_Email__c =: objcase.email AND
                                                                                       PropStrength__Active__c =: true AND
                                                                                       PropStrength__Application__c != null AND
                                                                                       PropStrength__Application__r.PropStrength__Active__c =: true 
                                                                                       Order BY PropStrength__Application__r.CreatedDate ASC LIMIT 1];
                        if(aplicantDetailsList.size() > 0) {
                            for(PropStrength__Applicant_Detail__c app : aplicantDetailsList) {
                                PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
                                sr.RecordtypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
                                if(objcase.emailNew != null && objcase.emailNew != '' &&
                                   objcase.emailNew.trim() != '') {
                                       sr.PropStrength__Description__c = 'Email update from '+objcase.email + ' to ' + objcase.emailNew + '\r\n\n';
                                       if(objcase.mobileNew != null && objcase.mobileNew != '' &&
                                          objcase.mobileNew != null && objcase.mobileNew.trim() != '') {
                                              sr.PropStrength__Description__c += 'Mobile Number update from '+objcase.mobile + ' to ' + objcase.mobileNew + '\r\n' ;
                                              sr.PropStrength__Description__c += '\n Bookings to be updated : \r\n'; //Booking Name Pass all Active Applicant
                                              if(!String.isBlank(bookingName)) {
                                                  sr.PropStrength__Description__c += bookingName;
                                              }
                                          } else {
                                              sr.PropStrength__Description__c += '\n Bookings to be updated : \r\n'; //Booking Name Pass all Active Applicant
                                              if(!String.isBlank(bookingName)) {
                                                  sr.PropStrength__Description__c += bookingName;
                                              }
                                          }
                                   } else {
                                       if(objcase.mobileNew != null && objcase.mobileNew != '' &&
                                          objcase.mobileNew != null && objcase.mobileNew.trim() != '') {
                                              sr.PropStrength__Description__c = 'Mobile Number update from '+objcase.mobile + ' to ' + objcase.mobileNew + '\r\n' ;
                                              sr.PropStrength__Description__c += '\n Bookings to be updated : \r\n'; //Booking Name Pass all Active Applicant
                                              if(!String.isBlank(bookingName)) {
                                                  sr.PropStrength__Description__c += bookingName;
                                              }
                                          } else {
                                              sr.PropStrength__Description__c = '\n Bookings to be updated : \r\n'; //Booking Name Pass all Active Applicant
                                              if(!String.isBlank(bookingName)) {
                                                  sr.PropStrength__Description__c += bookingName;
                                              }
                                          }
                                   }
                                sr.PropStrength__Priority__c = 'Medium';
                                sr.PropStrength__Request_Origin__c = 'Mobile App';
                                sr.SR_Department__c = 'CRM';
                                sr.SR_Category__c = 'Profile Update';
                                sr.SR_Sub_Category__c = 'Others';
                                sr.PropStrength__Comments__c = 'Updated the details';
                                sr.Additional_Comments__c = objcase.Remarks;
                                sr.PropStrength__Application_Booking__c = app.PropStrength__Application__c;
                                for(PropStrength__Applicant_Detail__c appDetailRec : aplicantDetailsList){
                                    sr.PropStrength__Contact_Email__c = appDetailRec.PropStrength__Applicant_Email__c;
                                    sr.PropStrength__Contact_Phone__c = appDetailRec.PropStrength__Applicant_Mobile__c;
                                    sr.Contact__c = appDetailRec.PropStrength__Applicant_Acc__c;
                                }
                                sr.PropStrength__Status__c = 'New';
                                casesToInsert.add(sr);
                            }
                            if(casesToInsert.size() > 0){
                                insert casesToInsert;
                                system.debug('casesToInsert::'+casesToInsert);
                                for(PropStrength__Service_Request__c sr : casesToInsert) {
                                    ResponseWrapper rep = new ResponseWrapper();
                                    rep.attributes = new Attribute();
                                    rep.attributes.type = 'Case';
                                    rep.attributes.url = '/services/data/v58.0/sobjects/Case/'+sr.Id;
                                    rep.Id = sr.Id;
                                    rep.RecordTypeId = sr.RecordTypeId != null ? sr.RecordTypeId : '';
                                    rep.Department = sr.RecordTypeId != null ? 'CRM' : '';
                                    rep.Origin = sr.PropStrength__Request_Origin__c != null ? sr.PropStrength__Request_Origin__c : '';
                                    rep.Category = sr.SR_Category__c != null ? sr.SR_Category__c : '';
                                    rep.Description = sr.PropStrength__Description__c != null ? sr.PropStrength__Description__c : '';
                                    rep.Comments = sr.PropStrength__Comments__c != null ? sr.PropStrength__Comments__c : '';
                                    rep.Status = sr.PropStrength__Status__c != null ? sr.PropStrength__Status__c : '';
                                    rep.Additional_Comments = sr.Additional_Comments__c != null ? sr.Additional_Comments__c : '';
                                    resWrap.add(rep);
                                }
                                system.debug('resWrap::'+resWrap);
                                System.debug(JSON.serialize(prepareResponse(resWrap,'Operation Successfull','Success',200,true)));
                                String str = JSON.serialize(prepareResponse(resWrap,'Operation Successfull','Success',200,true));
                                system.debug('str::'+str);
                                str = str.replace('Department', 'Department__c');
                                str = str.replace('Category', 'Category__c');
                                str = str.replace('Additional_Comments', 'Additional_Comments__c');
                                system.debug('ptr::'+str);
                                responseString = (prepareResponse(resWrap,'Operation Successfull','Success',200,true)).toString().replace('"','');
                                res.responseBody =  Blob.valueOf(str);
                                res.statusCode = 200;
                                statusCode = '200';
                            }
                        } else {
                            responseString = (prepareResponse(null,'No data found','No Appliant or No Active Applicant Found.',400,false)).toString().replace('"','');
                            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'No data found','No Appliant or No Active Applicant Found.',400,false)));
                            res.statusCode = 400;
                            statusCode = '400';
                        }
                    }
                } 
            }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            responseString = responseString = (prepareResponse(null,'Error',errorMessage,400,false)).toString().replace('"','');
            system.debug('~~Error: '+ex.getMessage()+'__'+ex.getStackTraceString());
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
            statusCode = '400';
        }  
        Mobile_App_Log__c logError = new Mobile_App_Log__c();
        logError.Response_Body__c = responseString;
        logError.Class_Name__c = 'PSServiceRequestMobileHelper';
        logError.API_Name__c = '/services/apexrest/createCase/';
        logError.Status__c = statusCode;
        logError.Request_Body__c = JSON.serialize(request.requestBody.toString());
        insert logError;
    }
    
    public static HttpResponseWrapper prepareResponse(list<ResponseWrapper> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.body = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }
    
    public class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public list<ResponseWrapper> body = new list<ResponseWrapper>();
        public boolean success;
        public sObject record;
        public String Message;
    }
    
    public class RequestWrapper{
        public String email;
        public String emailNew;
        public String mobile;
        public String mobileNew;
        public String Remarks;
    }
    
    Global class Attribute {
        Global String type;
        Global String url;
    }
    
    Global Class ResponseWrapper {
        Global Attribute attributes;
        Global String Id;
        Global String RecordTypeId;
        global string Department;
        global string Description;
        global string Origin;
        global string Category;
        global string Comments;
        global string Status;
        global string Additional_Comments;
    }
}