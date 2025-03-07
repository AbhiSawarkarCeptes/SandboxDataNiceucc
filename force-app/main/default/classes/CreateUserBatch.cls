global class CreateUserBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global set<Id> bookIds = new set<Id>();
    
    global CreateUserBatch(set<Id> bookIds) {
        this.bookIds = bookIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,PropStrength__Applicant_Email__c,PropStrength__Applicant_Acc__r.LastName,
                                         PropStrength__Applicant_Acc__r.FirstName,PropStrength__Applicant_Mobile__c,
                                         PropStrength__Applicant_Acc__r.Country_Code__c
                                         FROM PropStrength__Applicant_Detail__c
                                         WHERE PropStrength__Application__c IN: bookIds AND
                                         PropStrength__Type__c =: '1st Applicant']);
    }
    
    global void execute(Database.BatchableContext BC, List<PropStrength__Applicant_Detail__c> appList) {
        if(!appList.isEmpty()) {
            List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
            List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>();
            Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
            String endPointURL = mobile_appmdt.End_Point__c;
            String sftoken = mobile_appmdt.sf_Token__c;
            String Subscription_Key = mobile_appmdt.Subscription_Key__c;
            System.debug('endPointURL : '+endPointURL);
            //String endPointURL = endpoint+'/sruser/v1/user';
            try {
                for(PropStrength__Applicant_Detail__c bk : appList) {
                    requestBodyWrapper reqWrap = new requestBodyWrapper();
                    reqWrap.lastName = (bk.PropStrength__Applicant_Acc__r.LastName != null ? bk.PropStrength__Applicant_Acc__r.LastName : '');
                    reqWrap.email = (bk.PropStrength__Applicant_Email__c != null ? bk.PropStrength__Applicant_Email__c : '');
                    reqWrap.mobile = (bk.PropStrength__Applicant_Mobile__c != null ? bk.PropStrength__Applicant_Mobile__c : '');
                    reqWrap.source = 'salesForce';
                    reqWrap.firstName = (bk.PropStrength__Applicant_Acc__r.firstName != null ? bk.PropStrength__Applicant_Acc__r.firstName : '');
                    reqWrap.dialCode = (bk.PropStrength__Applicant_Acc__r.Country_Code__c != null ? bk.PropStrength__Applicant_Acc__r.Country_Code__c : '0');
                    //reqWrap.password = 'G345345';
                    wraplst.add(reqWrap);
                }
                if(wraplst != null) {
                    system.debug('wraplst::'+wraplst);
                    String serializedJSON = JSON.serialize(wraplst[0]);//JSON.serialize(wraplst);
                    System.debug('serializedJSON::'+serializedJSON);
                    if(!String.isBlank(serializedJSON)) {
                        Http http = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setEndpoint(endPointURL);
                        request.setMethod('POST');
                        request.setHeader('Ocp-Apim-Subscription-Key', Subscription_Key);
                        request.setHeader('Content-Type','application/json');
                        request.setHeader('x-integration-key', 'salesforce');
                        request.setHeader('x-sf-token',sftoken);
                        request.setBody(serializedJSON);
                        HttpResponse response = http.send(request);
                        system.debug('getBody:::'+ response.getBody());
                        if (response.getStatusCode() == 200) {
                            for(PropStrength__Applicant_Detail__c bk : appList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Applicant_Detail__c = bk.Id;
                                appLog.Status__c = '200';
                                appLog.Class_Name__c = 'CreateUserBatch User API';
                                appLog.API_Name__c = endPointURL;
                                appLog.Request_Body__c = serializedJSON;
                                appLog.Response_Body__c = response.getBody();
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        } else {
                            system.debug('Error:::'+response.getBody());
                            for(PropStrength__Applicant_Detail__c bk : appList) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                appLog.Applicant_Detail__c = bk.Id;
                                appLog.Request_Body__c = serializedJSON;
                                appLog.Status__c = '400';
                                appLog.Class_Name__c = 'CreateUserBatch User API';
                                appLog.API_Name__c = endPointURL;
                                appLog.Response_Body__c = response.getBody();
                                insertList.add(appLog);
                            }
                            system.debug('Error:::'+response.getBody());
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                }
            } catch(Exception e) {
                system.debug('~~~~~Error: '+e.getStackTraceString());
                for(PropStrength__Applicant_Detail__c bk : appList) {
                    Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                    appLog.Applicant_Detail__c = bk.Id;
                    appLog.Status__c = '400';
                    appLog.Class_Name__c = 'CreateUserBatch User API';
                    appLog.API_Name__c = endPointURL;
                    appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                    appLog.Response_Body__c = String.valueOf(e.getStackTraceString());
                    insertList.add(appLog);
                }
                if(!insertList.isEmpty()) {
                    insert insertList;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('bookIds::'+bookIds);
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endPointURL = mobile_appmdt.Booking_Endpoint_URL__c;
        //String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/bookings';
        string methodType = 'POST';
        List<Mobile_App_Log__c> insertList = new List<Mobile_App_Log__c>();
        List<requestBodyBookingWrapper> wraplst = new List<requestBodyBookingWrapper>();
        List<PropStrength__Application_Booking__c> newList = [SELECT Id,PropStrength__Property__c,Handover_Date__c,PropStrength__Primary_Applicant_Name__c,
                                                              PropStrength__Applicant_Email__c,PropStrength__Status__c,Name,Unit_Handover_Date__c
                                                              FROM PropStrength__Application_Booking__c
                                                              WHERE Id IN: bookIds];
        if(!newList.isEmpty()) {
            for(PropStrength__Application_Booking__c bk :newList) {
                requestBodyBookingWrapper wrap = new requestBodyBookingWrapper();
                wrap.bookingID = bk.Id;
                wrap.sfUnitId = (bk.PropStrength__Property__c != null ? String.valueOf(bk.PropStrength__Property__c) : '');
                wrap.handoverDate = bk.Handover_Date__c != null ? bk.Handover_Date__c : null;
                wrap.dlpDate = bk.Handover_Date__c != null ? bk.Handover_Date__c : null;
                wrap.customerName = bk.PropStrength__Primary_Applicant_Name__c != null ? bk.PropStrength__Primary_Applicant_Name__c : '';
                wrap.customerEmail = bk.PropStrength__Applicant_Email__c != null ? bk.PropStrength__Applicant_Email__c : '';
                wrap.bookingName = bk.Name;
                wrap.actualHandoverDate = bk.Unit_Handover_Date__c != null ? bk.Unit_Handover_Date__c : null;
                wrap.bookingStatus = bk.PropStrength__Status__c != null ? bk.PropStrength__Status__c : '';
                wraplst.add(wrap);
            }
            if(wraplst != null){
                String response = MobileIntegrationCallOutsAPI_PS.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
                try {
                    if(response != null && response != '') {
                        set<Id> bookingIdSet = new set<Id>();
                        bookingIdSet.add(wraplst[0].bookingID);
                        ID jobID = System.enqueueJob(new MobileAppQueuableNotification(bookingIdSet,'unit_booking_confirmation','alert'));
                        if(!String.isBlank(response)) {
                            for(requestBodyBookingWrapper ut : wraplst) {
                                Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                                if(response.contains('Success')){
                                    appLog.Status__c = '200';
                                }else
                                    appLog.Status__c = '400';
                                appLog.API_Name__c = endPointURL;
                                appLog.Class_Name__c = 'CreateUserBatch Booking API';
                                appLog.Application_Booking__c = ut.bookingID;
                                appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                                appLog.Response_Body__c = response;
                                insertList.add(appLog);
                            }
                            if(!insertList.isEmpty()) {
                                insert insertList;
                            }
                        }
                    }
                } catch(Exception e) { 
                    for(requestBodyBookingWrapper ut : wraplst) {
                        Mobile_App_Log__c appLog = new Mobile_App_Log__c();
                        appLog.Application_Booking__c = ut.bookingID;
                        appLog.Status__c = '400';
                        appLog.Class_Name__c = 'CreateUserBatch Booking API';
                        appLog.API_Name__c = endPointURL;
                        appLog.Request_Body__c = JSON.serialize(wraplst[0]);
                        appLog.Response_Body__c = String.valueOf(e.getMessage());
                        insertList.add(appLog);
                    }
                    if(!insertList.isEmpty()) {
                        insert insertList;
                    }
                    system.debug('getMessage::'+e.getMessage());
                }
            }
        }
    }
    
    public class requestBodyWrapper{
        String firstName;
        String lastName;
        String email;
        String dialCode;
        String mobile;
        String source;
        //String password;
    }
    
    public class requestBodyBookingWrapper{
        String bookingID;
        String bookingStatus;
        String bookingName;
        String customerName;
        String customerEmail;
        DateTime handoverDate;
        Date actualHandoverDate;
        String sfUnitId;
        DateTime dlpDate;
    }
}