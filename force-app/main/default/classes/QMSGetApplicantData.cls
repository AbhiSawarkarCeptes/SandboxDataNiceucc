@RestResource(urlMapping = '/GetUnitInfo/*')
global class QMSGetApplicantData {
    
    @HttpGet
    global static void doGet() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        // Extract query parameters
        String towerId = req.params.get('towerId');
        String unitId = req.params.get('unitId');
        
        
        QMSApiCalloutLogUtil logUtil;
        String unitName;
        String responseString = '';
        String errorMessage = '';
        List<QMSResponseWrapper.GetUnitInfoWrapper> appDetailsList = new List<QMSResponseWrapper.GetUnitInfoWrapper>();
        
        
        if(String.IsBlank(unitId)){
            res.responseBody =  BLOB.valueOf('unitId missing');
            res.statusCode = 400;
            
            logUtil = QMSApiCalloutLogUtil.initializeLog('No source');
            logUtil.logIt('unitId missing', 400, 'Failure');
            
            QMSApiCalloutLogUtil.finalizeLogs(logUtil);
            return;
        }
        unitName = (towerId !=null) ? towerId + unitId : unitId;
        logUtil = QMSApiCalloutLogUtil.initializeLog(unitName);
        
        try{
            List<Unit__c> unit = [SELECT ID,booking__c,booking__r.name,booking__r.status__c FROM UNIT__C WHERE NAME =: unitName];
            if(unit.size()== 0 || unit == NULL)
            {
                
                res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(appDetailsList,'No Unit Available with this towerID and unitId','Failure',400,false)));
                res.statusCode = 400;
                responseString ='No Unit Available with this towerID and unitId';
                logUtil.logIt(responseString,res.statusCode,'Failure');
                QMSApiCalloutLogUtil.finalizeLogs(logUtil);
                return;
                
            }
            if(unit[0].booking__c==NULL){
                res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(appDetailsList,'No Booking linked to unit','Failure',400,false)));
                res.statusCode = 400;
                responseString = 'No Booking linked to unit';
                logUtil.logIt(responseString,res.statusCode,'Failure');
                QMSApiCalloutLogUtil.finalizeLogs(logUtil);
                return;
            }
            
            List<Applicant_Details__c> appDetails = [SELECT ID,Name,Booking__c,Booking__r.Name,Applicant_Number__c, 
                                                     Passport_Copy_Details__c, Emirates_ID_Details__c, Mobile_Number__c,
                                                     Email_Address__c,Valid_Upto_Emirates_Id__c,Valid_Until_Passport__c 
                                                     FROM Applicant_Details__c WHERE BOOKING__C =: unit[0].booking__c];
            
            List<Booking__c> bklst = null;
            if(appDetails != null && appDetails.size() > 0){
                for(Applicant_Details__c app :appDetails){
                    QMSResponseWrapper.GetUnitInfoWrapper wrap = new QMSResponseWrapper.GetUnitInfoWrapper();
                    wrap.id = app.id;
                    wrap.ApplicantName = app.Name;
                    wrap.Applicant_Number = app.Applicant_Number__c;
                    wrap.PassportNo = app.Passport_Copy_Details__c;
                    wrap.Emirates_ID = app.Emirates_ID_Details__c;
                    wrap.Email = app.Email_Address__c;
                    wrap.MobileNumber = app.Mobile_Number__c;
                    wrap.BookingId = app.Booking__c;
                    wrap.BookingNumber = app.Booking__r.Name;
                    wrap.UnitNumber = unitName;
                    wrap.EidExpiry = app.Valid_Upto_Emirates_Id__c;
                    wrap.PassportExpiry = app.Valid_Until_Passport__c;  
                    appDetailsList.add(wrap);
                }
                responseString = (QmsServiceUtility.prepareResponse(appDetailsList,'Operation Successful','Success',200,true)).toString().replace('"','');
                res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(appDetailsList,'Operation Successful','Success',200,true)));
                res.statusCode = 200;
            }
            else{
                res.responseBody = BLOB.valueOf(JSON.serialize(QmsServiceUtility.prepareResponse(appDetailsList,'No Applicants Found','Success',200,true)));
                res.statusCode = 200;
            }
            logUtil.logIt('','Get',req.requestURI);
            logUtil.logIt(responseString, 200, 'Success');
        }
        catch(Exception e){
            errorMessage = e.getMessage();
            res.responseBody = BLOB.valueOf('No Unit Available'+errorMessage);
            res.statusCode = 400;
            logUtil.logIt(e);
            logUtil.logIt(responseString,res.statusCode,'Failure');
        } 
        QMSApiCalloutLogUtil.finalizeLogs(logUtil);
    }
    
    
}