@RestResource(urlMapping = '/PostVisitInfo/*') 
global class QMSPostVisitInfoController {
    @HttpPost
    global static void doPost(){        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        QMSResponseWrapper.postVisitInfoWrapper resWrapper;
        QMSRequestWrapper.postVisitInfoWrapper caseTransferData;
        QMSApiCalloutLogUtil logUtil;
        String data = RestContext.request.requestBody.toString();
        String responseString = '';
        String JSONbody = '';
        Case c;
        User u;
        try{
            caseTransferData =  (QMSRequestWrapper.postVisitInfoWrapper) JSON.deserialize(data, QMSRequestWrapper.postVisitInfoWrapper.class);
            
        }catch(Exception e){
            logUtil = QMSApiCalloutLogUtil.initializeLog('Improper request');
            logUtil.logIt(data, 'Post', req.requestURI);
            logUtil.logIt(e);
            res.responseBody =  BLOB.valueOf('Please send proper request. '+e.getMessage());
            res.statusCode = 400;
            logUtil.logIt('Improper request body',400,'Failure');
            QMSApiCalloutLogUtil.finalizeLogs(logUtil);
            //return 'Improper request body';
        }
        resWrapper = new QMSResponseWrapper.postVisitInfoWrapper();
        logUtil = QMSApiCalloutLogUtil.initializeLog(resWrapper.caseId); 
        logUtil.logIt(data, 'Post', req.requestURI);
        String msg = validateRequestBody(caseTransferData);
        if(msg != ''){
            res.responseBody =  BLOB.valueOf(msg); 
            res.statusCode = 400;
            logUtil.logIt(msg, 400, 'Failure');
            QMSApiCalloutLogUtil.finalizeLogs(logUtil);            
            return;            
        }
        
        try{
            String dateTimeStr = caseTransferData.issuedTime;
            String dateTimePart = dateTimeStr.substring(0, dateTimeStr.indexOf('+'));
            String timeZoneOffset = dateTimeStr.substring(dateTimeStr.indexOf('+'));
            Datetime resultDateTime = Datetime.valueOfGmt(dateTimePart.replace('T', ' '));
            Integer offsetHours = Integer.valueOf(timeZoneOffset.substring(1, 3));
            Integer offsetMinutes = Integer.valueOf(timeZoneOffset.substring(4, 6));
            Integer offsetTotalMinutes = offsetHours * 60 + offsetMinutes;
            resultDateTime = resultDateTime.addMinutes(offsetTotalMinutes);
            System.debug('Converted Datetime: ' + resultDateTime);
            List<Booking__c> bookingList= [SELECT ID,Name,Primary_Applicant_Name__c,
                                           unit__r.Tower__r.Collection_Executive__r.Email,
                                           unit__r.Tower__r.Collection_Executive__r.Name,
                                           Primary_Applicant_Email__c,  PrimaryMobileNumber__c,
                                           CRM_Executive__c, CRM_Executive__r.Name, CRM_Executive__r.Email,
                                           Owner.name, Owner.Email FROM BOOKING__C WHERE Id =: caseTransferData.bookingId];
            if(bookingList.size()==0 || bookingList==NULL)
            {
                res.responseBody =  BLOB.valueOf('No Booking Available');
                res.statusCode = 400;
                logUtil.logIt('No Booking Available', 400, 'Failure');
                
            }
            else
            {
                Booking__c booking = bookingList[0];
                String recordTypeName = QmsServiceUtility.getRecordType(caseTransferData.requestType);
                Id recordTypeId ;
                
                recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId(); 
                
                
                c = new Case();
                c.SuppliedEmail = caseTransferData.email;
                c.SuppliedPhone = caseTransferData.mobile;
                c.Description = caseTransferData.description;
                c.Booking__c = booking.ID;
                c.Comments = caseTransferData.internalDescription;
                c.Additional_Comments__c = caseTransferData.internalDescription;
                c.TokenNumber__c = caseTransferData.tokenNumber;
                c.IssuedTime__c = resultDateTime;
                c.ServiceName__c = caseTransferData.serviceName;
                c.request_Type__c = caseTransferData.requestType;
                c.is_QMS_Case__c = true;
                c.Origin = 'Walk-In';
                if(recordTypeId!=NULL)
                    c.RecordTypeId = recordTypeId;
                insert c;
                
                //Attach image in files
                if (caseTransferData.passport != null && caseTransferData.passport !='') {
                    Blob passportBlob = EncodingUtil.base64Decode(caseTransferData.passport);
                    ContentVersion cv = new ContentVersion();
                    cv.Title = 'Passport';
                    cv.PathOnClient = 'Passport.jpg';
                    cv.VersionData = passportBlob;
                    cv.IsMajorVersion = true;
                    insert cv;
                    
                    // Link the ContentVersion to the Case
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                    cdl.LinkedEntityId = c.Id;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    insert cdl;
                    
                    
                }
                
                resWrapper.caseId = c.id;
                resWrapper.ApplicantName = booking.Primary_Applicant_Name__c;
                resWrapper.Email = booking.Primary_Applicant_Email__c;
                resWrapper.Mobile = booking.PrimaryMobileNumber__c;
                
                resWrapper.RMName = (booking.CRM_Executive__c != null ? booking.CRM_Executive__r.Name : '');
                resWrapper.RMEmail = (booking.CRM_Executive__c != null ? booking.CRM_Executive__r.Email : '');
                
                resWrapper.CollectionName = (booking.unit__r.Tower__r.Collection_Executive__r.Name!= null ? booking.unit__r.Tower__r.Collection_Executive__r.Name : '');
                resWrapper.CollectionEmail = (booking.unit__r.Tower__r.Collection_Executive__r.Email != null ? booking.unit__r.Tower__r.Collection_Executive__r.Email : '');
                
                responseString = (QmsServiceUtility.prepareResponse(resWrapper,'Operation Successful','Success',200,true)).toString().replace('"','');
                res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(resWrapper,'Operation Successful','Success',200,true)));
                res.statusCode = 200;
                JSONbody = JSON.serialize(QmsServiceUtility.prepareResponse(resWrapper,'Operation Successful','Success',200,true));
                logUtil.logIt(data,'Post',req.requestURI);
                logUtil.logIt(JSONbody, 200, 'Success');
                QMSApiCalloutLogUtil.finalizeLogs(logUtil);
            }
            
        }catch(Exception e){
            logUtil.logIt(e);
            res.responseBody =  BLOB.valueOf('Something went wrong.'+e.getMessage());
            res.statusCode = 400;
            logUtil.logIt('Something went wrong.', 400, 'Failure');
            QMSApiCalloutLogUtil.finalizeLogs(logUtil);
        }
        
        
    }
    Public Static String validateRequestBody(QMSRequestWrapper.postVisitInfoWrapper caseTransferData){
        String errorMsg=''; 
        
        If(String.IsBlank(caseTransferData.email))
            errorMsg+='Email missing. ';
        If(String.IsBlank(caseTransferData.bookingId))
            errorMsg+='bookingId missing. ';
        If(String.IsBlank(caseTransferData.tokenNumber))
            errorMsg+='tokenNumber missing. ';
        If(String.IsBlank(caseTransferData.issuedTime))
            errorMsg+='issuedTime missing. ';
        
        return errorMsg;
        
    }
    
}