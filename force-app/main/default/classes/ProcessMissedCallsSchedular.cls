Public Class ProcessMissedCallsSchedular implements Schedulable {
    
    Public Void execute(SchedulableContext sc) {
        process();
    }
    
    @Future(callout = true)
    Public Static Void process() {
        
        BitVoice__c bit = BitVoice__c.getValues('Missed Calls');
        String endPoint = bit.URL__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endPoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        System.debug('======= '+response);
        
        List<MissedCallsParser> parserList = MissedCallsParser.parse(response.getBody());
        Set<String> mIds = new Set<String>();
        for(MissedCallsParser mParser : parserList) {
            mIds.add(mParser.mid);
        }
        
        List<MissedCall__c> missedCalls = [SELECT Id, Mid__c FROM MissedCall__c WHERE Mid__c IN: mIds];
        
        List<MissedCall__c> missedCallsToInsert = new List<MissedCall__c>();
        Set<String> phoneNumbers = new Set<String>();
        String missedNumbers = null;
        
        for(MissedCallsParser mParser : parserList) {
            MissedCall__c mc;
            if(missedCalls.size() > 0) {
                for(MissedCall__c m : missedCalls) {
                    if(m.Mid__c != mParser.mid) {
                        mc = createRecord(mParser);
                        phoneNumbers.add(mParser.number_Z);
                        missedNumbers += ','+mParser.number_Z;
                    }
                }
            }else {
                mc = createRecord(mParser);
                phoneNumbers.add(mParser.number_Z);
                missedNumbers += ','+mParser.number_Z;
            }
            missedCallsToInsert.add(mc);
        }
        
        if(missedCallsToInsert.size() > 0) {
            
            Set<String> ids = new Set<String>();
            List<Account> accList = [SELECT Id, Primary_Number_Formula__c, Agent_Extension__c FROM Account WHERE Owner.Profile.Name = 'Presales' AND (Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers)];
            List<Opportunity> oppList = [SELECT Id, Primary_Number_Formula__c, Agent_Extension__c FROM Opportunity WHERE Owner.Profile.Name = 'Presales' AND (Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers)];
            List<Lead> leadList = [SELECT Id, Primary_Number_Formula__c, Agent_Extension__c FROM Lead WHERE Owner.Profile.Name = 'Presales' AND (MobilePhone IN: phoneNumbers OR Primary_Number__c IN: phoneNumbers OR Primary_Number_Formula__c IN: phoneNumbers)];
            for(Account acc : accList) {
                ids.add(acc.Id);
            }
            for(Opportunity opp : oppList) {
                ids.add(opp.Id);
            }
            for(Lead ld : leadList) {
                ids.add(ld.Id);
            }
            
            if(ids.size() > 0) {
                for(String id : ids) {
                    ClickToDial.callById(id);
                }
            }else {
                if(missedNumbers.length() > 2) {
                    missedNumbers = '['+missedNumbers.subString(1, missedNumbers.length())+']';
                    if(!Test.isRunningTest())
                    ClickToDial.pushBulkCalls(missedNumbers);
                }
            }
            
            insert missedCallsToInsert;
        }
    }
   @TestVisible
    Private Static MissedCall__c createRecord(MissedCallsParser mParser) {
        MissedCall__c mc = new MissedCall__c();
        mc.Group__c = mParser.group_Z;
        mc.Inbound_Tries__c = mParser.inbound_tries;
        mc.Mid__c = mParser.mid;
        mc.mTime__c = mParser.mtime;
        mc.Numbers__c = mParser.number_Z;
        mc.Pushed__c = False;
        mc.Status__c = mParser.status;
        mc.Tries__c = mParser.tries;
        return mc;
    }
    
    
    //=============================Automatic Call Back==================================
        //@InvocableMethod(label='ProcessMissedCallsSchedular - callBack' description='Schedule Calls and Auto Dials')
        Public Static Void callBack(Id leadID) {
            
            BitVoice__c bit = BitVoice__c.getValues('Callback');
            
            List<Lead> leadList = [SELECT Id, Primary_Number_Formula__c, Latest_Next_Action_Date__c FROM Lead WHERE Id =: leadID];
            if(leadList.size() > 0) {
                
                User u = [SELECT BitVoice_Agent_Ext__c, UserName__c FROM User WHERE Id =: UserInfo.getUserId()];
                
                for(Lead l : leadList) {
                    
                    String actionDate = l.Latest_Next_Action_Date__c.year()+'-'+l.Latest_Next_Action_Date__c.month()+'-'+l.Latest_Next_Action_Date__c.day()+' '+l.Latest_Next_Action_Date__c.hour()+':'+l.Latest_Next_Action_Date__c.minute()+':'+l.Latest_Next_Action_Date__c.second();
                    String body = '[{"calbacktime":"'+actionDate+'","num":"'+l.Primary_Number_Formula__c+'","agent":"'+u.UserName__c+'"}]';
                    System.debug('********** Schedule Call ********');
                    //PushToBitVoice(bit.URL__c, body);
                    PushToBitVoiceSchedule(bit.URL__c, body, l.Primary_Number_Formula__c);
                }
            }
            
        }
        
        //====================Clear Callback=======================
            Public Static Void clearCallBack(String phoneNumber) {
                BitVoice__c bit = BitVoice__c.getValues('ClearCallback');
                if(bit != Null) {
                    System.debug('********** Clear Callback********');
                    PushToBitVoice(bit.URL__c+phoneNumber, 'Clear Call Back');
                }
            }
        //=========================================================
        
        Public Class CallbackResponseWrapper {
            String status;
            String message;
        }
        
        @Future(callout=true)
        Public Static Void PushToBitVoice(String endPointURL, String body) {
            System.debug('URL ===== '+endPointURL);
            System.debug('Body ===== '+body);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndPoint(endPointURL);
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('POST');
            request.setBody(body);
            HttpResponse response = http.send(request);
            
            CallbackResponseWrapper wrap = (CallbackResponseWrapper)JSON.deserialize(response.getBody(), CallbackResponseWrapper.class);
            System.debug('Response ===== '+wrap);
        }
        
        @Future(callout=true)
        Public Static Void PushToBitVoiceSchedule(String endPointURL, String body, String phoneNumber) {
            System.debug('URL ===== '+endPointURL);
            System.debug('Body ===== '+body);
            //=============Clear Callback=================
                BitVoice__c bit = BitVoice__c.getValues('ClearCallback');
                System.debug('********** Clear Callback********');
                String endPointURL1 = bit.URL__c+phoneNumber;
                String body1 = 'Clear Call Back';
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                request1.setEndPoint(endPointURL1);
                request1.setHeader('Content-Type', 'application/json');
                request1.setMethod('POST');
                request1.setBody(body1);
                HttpResponse response1 = http1.send(request1);
                
                CallbackResponseWrapper wrap1 = (CallbackResponseWrapper)JSON.deserialize(response1.getBody(), CallbackResponseWrapper.class);
                System.debug('Response(Clear Callback) ===== '+wrap1);
            //============================================
            //                  |
            //=============Schedule a Call================
                System.debug('********** Schedule Call********');
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndPoint(endPointURL);
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
                request.setBody(body);
                HttpResponse response = http.send(request);
                
                CallbackResponseWrapper wrap = (CallbackResponseWrapper)JSON.deserialize(response.getBody(), CallbackResponseWrapper.class);
                System.debug('Response(Schedule Call) ===== '+wrap);
            //============================================
        }
    //==================================================================================
}