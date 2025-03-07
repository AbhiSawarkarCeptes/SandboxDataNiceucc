@RestResource(urlMapping='/createCase')
global class Mobile_Case{
    @HttpPost 
    global static void doCreateCase(){
        String crmRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRM').getRecordTypeId();

        RestResponse res = RestContext.response;
        List<Applicant_Details__c> appDetailsToUpdate = new List<Applicant_Details__c>();
        List<Case> casesToInsert = new List<Case>();
        List<Lead> leadListToUpdate = new List<Lead>();
        List<Account> accListToUpdate = new List<Account>();
        RestRequest request = RestContext.request;
        String responseString = '';
        String errorMessage = '';
        RequestWrapper objcase = (RequestWrapper)System.JSON.deserialize(request.requestBody.toString(),RequestWrapper.class);
        try {
            if(objcase != null){
                system.debug('~~~~'+objcase);
                if(objcase.emailNew != null || objcase.mobileNew != null){
                    List<Applicant_Details__c> aplicantDetailsList = checkForExistingBookings(objcase.email);
                    if(aplicantDetailsList.size() > 0){
                        Case newCase = new Case();
                        newCase.recordTypeId = crmRecordTypeID;
                        newCase.description = '';
                        if(objcase.emailNew != null && objcase.emailNew.trim() != '')
                                newCase.description = 'Email update from '+objcase.email + ' to ' + objcase.emailNew + '\r\n\n';
                        if(objcase.mobileNew != null && objcase.mobileNew.trim() != '')
                            newCase.description += 'Mobile Number update from '+objcase.mobile + ' to ' + objcase.mobileNew + '\r\n' ;
                        newCase.Department__c = 'CRM';
                        newCase.Origin = 'Mobile App';
                        newCase.Category__c = 'Other';
                        newCase.Comments = 'Updated the details';
                        newCase.Additional_Comments__c = objcase.Remarks;
                        
                        newCase.description += '\n Bookings to be updated : \r\n'; //Temporary code
                        for(Applicant_Details__c appDetailRec : aplicantDetailsList){
                            /*if(appDetailRec.Booking__r.Handover_Date__c != null){ //appDetailRec.Booking__r.Handover_Completed_del__c && 
                                newCase.description += appDetailRec.Booking__r.Name+' Updated \r\n';
                                if(objcase.emailNew != null)
                                    appDetailRec.Email_Address__c = objcase.emailNew;
                                if(objcase.mobileNew != null)
                                    appDetailRec.Mobile_Number__c = objcase.mobileNew;
                                appDetailsToUpdate.add(appDetailRec);
                            } 
                            else{*/ /* Commented out temporarily till functionality is fixed */
                                newCase.description += appDetailRec.Booking__r.Name+' \r\n';
                            //}
                        }
                        newCase.Status = newCase.Description.contains('to be') ? 'Open' : 'Closed';
                        casesToInsert.add(newCase);
                    }
                    else{
                        List<Account> accList = checkExistingAccount(objcase.email, objcase.mobile);
                        if(accList.size() > 0){
                            for(Account accRec : accList){
                                if(objcase.emailNew != null)
                                    accRec.PersonEmail = objcase.emailNew;
                                if(objcase.mobileNew != null)
                                    accRec.PersonMobilePhone = objcase.mobileNew;
                                accListToUpdate.add(accRec);
                            }
                        }
                        else{
                            List<Lead> leadList = checkExistingLeads(objcase.email, objcase.mobile);
                            if(leadList.size() > 0){
                               for(Lead leadRec : leadList){
                                if(objcase.emailNew != null)
                                    leadRec.Email = objcase.emailNew;
                                if(objcase.mobileNew != null)
                                    leadRec.MobilePhone = objcase.mobileNew;
                                leadListToUpdate.add(leadRec);
                            } 
                            }
                            else{
                                res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'No data found','No data found',400,false)));
                                res.statusCode = 400;
                            }
                        }
                    }
                }
    
                if(appDetailsToUpdate.size() > 0){
                    update appDetailsToUpdate;
                }
    
                if(casesToInsert.size() > 0){
                    insert casesToInsert;
                    responseString = (prepareResponse(casesToInsert,'Operation Successfull','Success',200,true)).toString().replace('"','');
                    res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(casesToInsert,'Operation Successfull','Success',200,true)));
                    res.statusCode = 200;
                }
                if(accListToUpdate.size() > 0){
                    update accListToUpdate;
                    res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'Data Updated in Account','Success',200,true)));
                    res.statusCode = 200;
                }
                if(leadListToUpdate.size() > 0){
                    update leadListToUpdate;
                    res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'Data Updated in Lead','Success',200,true)));
                    res.statusCode = 200;
                }
            }
            else{
                res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'No data found','No data found',400,false)));
                res.statusCode = 400;
            }
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
            system.debug('~~Error: '+ex.getMessage()+'__'+ex.getStackTraceString());
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('createCase','Mobile_Case',request.requestBody.toString(),responseString,errorMessage,res.statusCode);        
    }

    public static List<Applicant_Details__c> checkForExistingBookings(String email){
        List<Applicant_Details__c> applicantDetailsList = [Select Id, Booking__r.Name, Booking__c,  Booking__r.Handover_Date__c, Name, Mobile_Number__c  from Applicant_Details__c where Email_Address__c = :email]; //Booking__r.Handover_Completed_del__c,

        return applicantDetailsList;
    }

    public static List<Lead> checkExistingLeads(String email, String mobile){
        List<Lead> leadList = [Select Id from Lead where Email = :email OR MobilePhone = :mobile];
        return leadList;
    }
   
    public static List<Account> checkExistingAccount(String email, String mobile){
        List<Account> accList = [Select Id, PersonEmail, PersonMobilePhone, Name  from Account where PersonEmail = :email OR PersonMobilePhone = :mobile];
        return accList;
    }
    
    public static HttpResponseWrapper prepareResponse(list<Case> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
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
        public list<Case> body = new list<Case>();
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
}