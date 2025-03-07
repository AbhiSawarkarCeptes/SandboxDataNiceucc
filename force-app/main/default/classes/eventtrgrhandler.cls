public without sharing class eventtrgrhandler {

    public static boolean stopSaleSiteCalculation = false;
      
       

    public static void beforeinsert(List<Events__c> newList, Map<ID,Events__c> oldMap){
        
        Id BrokerEvent = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Event').getRecordTypeId();
        Id BrokersTraining = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Training').getRecordTypeId();
        Id OpenHouses = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();
        Id RoadShows = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();
        Id BusinessTrip = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Business Trip').getRecordTypeId();
        Id videoShoot = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
        
       map<Id,string> recTypeIdToName = new map<Id,string>();
    
        recTypeIdToName.put(BrokerEvent,'Brokers Event');
        recTypeIdToName.put(BrokersTraining,'Brokers Training');
        recTypeIdToName.put(OpenHouses,'Open Houses');
        recTypeIdToName.put(RoadShows,'Road Shows');
        recTypeIdToName.put(BusinessTrip,'Business Trip');
        recTypeIdToName.put(videoShoot,'Video Shoot');

        Set<id> channelparnersetId = new  Set<id>();

        Set<id> sobhaConnectId = new  Set<id>();

        //String cpProfile = [select id from profile where name = 'CP Profile'].ID;
        
        User currentUser = [select id,managerID,userrole.name from user where id =: userinfo.getUserID()];

        String currentUserManagerId  = currentUser.managerID;

        String currentUserRoleName = currentUser.userrole.name;

        Set<id> salesManagerID = new  Set<id>();



        for(Events__c e : newList){

            channelparnersetId.add(e.Channel_Partner__c);

           

            if(oldMap == null ){
				
                List<String> cpProfileName = new List<String>{'CP Profile', 'CP Manager'};
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                
                if(cpProfileName.contains(profileName)){    
                //if(UserInfo.getProfileId() == cpProfile){

                    e.Is_Created_By_CHRM_Manager__c = true;

                    e.Channel_Relationship_Head__c = currentUserManagerId;

                }

                if(e.Is_Created_By_CHRM_Manager__c == false && currentUserRoleName != null && currentUserRoleName.contains('Sales Manager')){

                    e.Sales_Manager__c = UserInfo.getUserId();

                }

              

            }

           

            if(oldMap == null && e.Sales_Manager__c != null){

                salesManagerID.add(e.Sales_Manager__c);

 

            }

            if( e.Channel_Partner__c <> null && (oldMap == null || e.Channel_Partner__c !=oldMap.get(e.Id).Channel_Partner__c)){

                channelparnersetId.add(e.Channel_Partner__c);

            }

            if( e.Sobha_Connect__c <> null && (oldMap == null || e.Sobha_Connect__c !=oldMap.get(e.Id).Sobha_Connect__c)){

                sobhaConnectId.add(e.Sobha_Connect__c);

            }

            if(oldMap == null || ( oldMap != null && e.date_of_event__c != oldMap.get(newList[0].id).date_of_event__c

            )){

                Integer d = e.date_of_event__c.day();

                Integer mo = e.date_of_event__c.month();

                Integer yr = e.date_of_event__c.year();

 

                DateTime DT = DateTime.newInstance(yr, mo, d, 00, 00, 00);

                e.Escalation_Email_CHRM_Campaign_leads__c =DT;

            }

           

           

        }

        if(oldMap == null || newList[0].date_of_event__c != oldMap.get(newList[0].id).date_of_event__c || newList[0].end_date_of_event__c != oldMap.get(newList[0].id).end_date_of_event__c

        || newList[0].start_time_of_the_event__C != oldMap.get(newList[0].id).start_time_of_the_event__C

        || newList[0].end_time_of_the_event__C != oldMap.get(newList[0].id).end_time_of_the_event__C){

            validateEventInsert(newList);

        }

        if(!salesManagerID.isEmpty()){

            Map<id,User> userUpdateFields = new Map<id,User>([SELECT ID,ManagerId,Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE ID IN :salesManagerID ]);

             for(Events__c e : (List<Events__c>) Trigger.new){

                if(e.Sales_Manager__c != null && userUpdateFields.containsKey(e.Sales_Manager__c)){

                    e.Sales_Director__c = userUpdateFields.get(e.Sales_Manager__c).ManagerId;

                   e.Sales_Head__c = userUpdateFields.get(e.Sales_Manager__c).ManagerId;

                   e.sales_vp__c = userUpdateFields.get(e.Sales_Manager__c).Manager.ManagerId;
                    
                    e.Sales_SVP__c = userUpdateFields.get(e.Sales_Manager__c).Manager.Manager.ManagerId;

                }

            }

           

        }
        
        Map<id,Channel_Partner__c> chanlmapToUpdateFields = new Map<id,Channel_Partner__c>();
        Map<id,Sobha_Connect__c> sobhaConnectMapToUpdateFields = new Map<id,Sobha_Connect__c>();

        if(!channelparnersetId.isEmpty()){

            chanlmapToUpdateFields = new Map<id,Channel_Partner__c>([SELECT ID,Name,Channel_Relationship_Head__c,Channel_Relationship_Manager__c

             FROM Channel_Partner__c WHERE ID IN :channelparnersetId ]);

            for(Events__c e : (List<Events__c>) Trigger.new){

                if(e.Channel_Partner__c != null && chanlmapToUpdateFields.containsKey(e.Channel_Partner__c)){

                    e.Channel_Relationship_Head__c = chanlmapToUpdateFields.get(e.Channel_Partner__c).Channel_Relationship_Head__c;

                    e.Channel_Relationship_Manager__c = chanlmapToUpdateFields.get(e.Channel_Partner__c).Channel_Relationship_Manager__c;

                }

            }

        }

        if(!sobhaConnectId.isEmpty()){

            sobhaConnectMapToUpdateFields = new Map<id,Sobha_Connect__c>([SELECT ID,Name,Channel_Relationship_Head__c,Channel_Relationship_Manager__c

             FROM Sobha_Connect__c WHERE ID IN :sobhaConnectId ]);

            for(Events__c e : (List<Events__c>) Trigger.new){

                if(e.Sobha_Connect__c != null && sobhaConnectMapToUpdateFields.containsKey(e.Sobha_Connect__c)){

                    e.Channel_Relationship_Head__c = sobhaConnectMapToUpdateFields.get(e.Sobha_Connect__c).Channel_Relationship_Head__c;

                    e.Channel_Relationship_Manager__c = sobhaConnectMapToUpdateFields.get(e.Sobha_Connect__c).Channel_Relationship_Manager__c;

                }

            }

        }

        for(Events__c e : (List<Events__c>) Trigger.new){
            if(oldMap == null || e.City_Country__c != oldMap.get(e.id).City_Country__c 
            || e.Sobha_Connect__c != oldMap.get(e.id).Sobha_Connect__c
            || e.Channel_Partner__c != oldMap.get(e.id).Channel_Partner__c){
    
            
                string brokerName = '';
                String cityName='';
                if(e.City_Country__c != null){
                    cityName = ' - ' + e.City_Country__c;
                }
                if(e.Sobha_Connect__c != null && sobhaConnectMapToUpdateFields.containsKey(e.Sobha_Connect__c))
                    brokerName = sobhaConnectMapToUpdateFields.get(e.Sobha_Connect__c).Name;
                if(e.Channel_Partner__c != null && chanlmapToUpdateFields.containsKey(e.Channel_Partner__c))
                    brokerName = chanlmapToUpdateFields.get(e.Channel_Partner__c).Name;
                string eventName = recTypeIdToName.get(e.RecordTypeId) + ' - ' + brokerName + cityName;
                if(eventName.length() > 80){
                    if(brokerName!=null)
                        eventName = recTypeIdToName.get(e.RecordTypeId) + ' - ' + brokerName.left(40) + cityName;
                }
                e.Name = eventName;
                    } 
        }

    }

    public static void afterinsert(){

        Set<id> sobhaconnectsetId = new  Set<id>();

        Set<id> channelparnersetId = new  Set<id>();

        for(Events__c e : (List<Events__c>) Trigger.new){

            if(e.Channel_Partner__c <> null)channelparnersetId.add(e.Channel_Partner__c);

            if(e.Sobha_Connect__c <> null)sobhaconnectsetId.add(e.Sobha_Connect__c);

        }

       

        if(!channelparnersetId.isEmpty()){

            Map<id,Channel_Partner__c> chanlmap = new Map<id,Channel_Partner__c>();

            List<Aggregateresult> agrrslt1 = [SELECT COUNT(RecordTypeId) cnt,Channel_Partner__c cp,RecordType.Name nm FROM Events__c WHERE Channel_Partner__c in :channelparnersetId AND Event_Approved_status__c = 'The event has been approved by CSO' group by Channel_Partner__c,RecordType.Name];

            for(Aggregateresult ag: agrrslt1){

                if(!chanlmap.keyset().contains((Id)ag.get('cp')))chanlmap.put((Id)ag.get('cp'),new Channel_Partner__c(Id= (Id)ag.get('cp')));

                if((string) ag.get('nm') == 'Road Shows')chanlmap.get((Id)ag.get('cp')).put('No_of_Road_Events__c',(Decimal) ag.get('cnt'));

                if((string) ag.get('nm') == 'Brokers Training') chanlmap.get((Id)ag.get('cp')).put('No_of_Broker_Trainings__c',(Decimal) ag.get('cnt'));

                if((string) ag.get('nm') == 'Open Houses') chanlmap.get((Id)ag.get('cp')).put('No_of_Open_Houses__c',(Decimal) ag.get('cnt'));

            }

            if(!chanlmap.values().isempty())

            update chanlmap.values();

           

        }

        if(!sobhaconnectsetId.isEmpty()){

            Map<id,Sobha_Connect__c> sobhaconnectmap = new Map<id,Sobha_Connect__c>();

            List<Aggregateresult> agrrslt2 = [SELECT COUNT(RecordTypeId) cnt,Sobha_Connect__c sc,RecordType.Name nm FROM Events__c WHERE Sobha_Connect__c in :sobhaconnectsetId AND Event_Approved_status__c = 'The event has been approved by CSO' group by Sobha_Connect__c,RecordType.Name];

            for(Aggregateresult ag: agrrslt2){

                if(!sobhaconnectmap.keyset().contains((Id)ag.get('sc'))) sobhaconnectmap.put((Id)ag.get('sc'),new Sobha_Connect__c(Id= (Id)ag.get('sc')));

                if((string) ag.get('nm') == 'Road Shows')sobhaconnectmap.get((Id)ag.get('sc')).put('No_of_Road_Shows__c',(Decimal) ag.get('cnt'));

                if((string) ag.get('nm') == 'Brokers Training')sobhaconnectmap.get((Id)ag.get('sc')).put('No_of_Broker_Trainings__c',(Decimal) ag.get('cnt'));

                if((string) ag.get('nm') == 'Open Houses') sobhaconnectmap.get((Id)ag.get('sc')).put('No_of_Open_Houses__c',(Decimal) ag.get('cnt'));

            }

            if(!sobhaconnectmap.values().isempty()) update sobhaconnectmap.values();

        }

    }

    public static void eventApprovalValidation(List<Events__c> eventList , Map<Id,Events__c> oldMap){

        for(Events__c evt : eventList){

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c && evt.Event_Approved_status__c == 'The event has been approved by GM Hospitality' && evt.invoice_uploaded__c == false){

                evt.addError('Please upload invoice before approving event');

            }

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c

            && evt.Event_Approved_status__c != Null

            && evt.Event_Approved_status__c.containsignorecase('Rejected')

            && evt.Rejection_Comments__c == null){

                evt.addError('Please update rejection comments on event record before and try again');

            }

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c

            && evt.Event_Approved_status__c != Null

            && !evt.Event_Approved_status__c.containsignorecase('Rejected')

            && evt.Rejection_Comments__c != null){

                evt.Rejection_Comments__c = null;

            }

           

        }

 

    }

    public static void validateEventInsert(List<Events__c> eventList){

        Set<String> RecordTypeDevId = new Set<String>();

        Id BrokerEvent = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Event').getRecordTypeId();

        Id BrokersTraining = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Brokers Training').getRecordTypeId();

        Id OpenHouses = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Open Houses').getRecordTypeId();

        Id RoadShows = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Road Shows').getRecordTypeId();

        for(Events__c evt : eventList){

            if(evt.RecordTypeId == BrokerEvent || evt.RecordTypeId == RoadShows){

                RecordTypeDevId.add(BrokerEvent);

                RecordTypeDevId.add(RoadShows);

            }else if(evt.RecordTypeId == BrokersTraining ){

                RecordTypeDevId.add(BrokersTraining); 

            }else if(evt.RecordTypeId == OpenHouses ){

                RecordTypeDevId.add(OpenHouses);

            }

        }

       for(Events__c evt : [SELECT ID,Event_Approved_status__c,Name,channel_partner__c,

        Start_Time_of_the_Event__c,End_Time_of_the_Event__c,date_of_event__c,

        end_date_of_event__c,RecordType.name ,Bypass_Validation_Rule__c  FROM Events__c WHERE 

        City_Country__c =: eventList[0].City_Country__c

        AND date_of_event__c != null and City_Country__c != null

        AND date_of_event__c >= today AND (NOT Event_Approved_status__c LIKE '%rejected%')

        and Event_Approved_status__c != 'Cancelled'

        AND RecordTypeID IN : RecordTypeDevId and id not in: eventList]){

           

            Date startDateExisting = evt.date_of_event__c;

            Date EndDateExisting = evt.end_date_of_event__c;

            Date startDateNew = eventList[0].date_of_event__c;

            Date endDateNew = eventList[0].end_date_of_event__c;

            Time startTimeExisting = evt.Start_Time_of_the_Event__c;

            Time EndTimeExisting = evt.End_Time_of_the_Event__c;

            Time startTimeNew = eventList[0].Start_Time_of_the_Event__c;

            Time endTimeNew = eventList[0].End_Time_of_the_Event__c;
            
            Integer minDaysGap = Integer.valueOf(Label.Min_Days_Gap);
            
            String errorMsg = Label.Event_Validation_Error;
            
            // Validate Roadshows date gap
            if (evt.RecordTypeId == roadShows) {
                
                Integer daysDifference = Math.abs(Date.valueOf(startDateNew).daysBetween(Date.valueOf(startDateExisting)));
                
                if (daysDifference < minDaysGap && eventList[0].Bypass_Validation_Rule__c == false) {
                    
                    eventList[0].addError(errorMsg);
                    break;
                }
            }
            
            

             if (((evt.RecordType.name =='Road Shows') ||(evt.RecordType.name =='Brokers Event'))

            && EndDateExisting != null &&

            ((startDateExisting <= startDateNew && EndDateNew <= EndDateExisting) ||

            (startDateExisting <= startDateNew && startDateNew <= EndDateExisting) ||

            (EndDateNew >=  startDateExisting && EndDateNew <= EndDateExisting))
                 
                && eventList[0].Bypass_Validation_Rule__c == false){

                eventList[0].addError('There is already an event booked with same city and same dates ');

                break;

               

            }else

            if(eventList[0].RecordTypeId == evt.RecordTypeId &&

            (eventList[0].date_of_event__c == evt.date_of_event__c  )

            && ((startTimeExisting <= startTimeNew && EndTimeNew <= EndTimeExisting) ||

            (startTimeExisting <= startTimeNew && startTimeNew <= EndTimeExisting) ||

            (EndTimeNew >=  startTimeExisting && EndTimeNew <= EndTimeExisting))
               
              && eventList[0].Bypass_Validation_Rule__c == false){

                eventList[0].addError('There is already an event booked with same city and same dates or at the same time ' );

                break;

            }

        } 

    }

    public static void sendEmailForDigitalShow(List<Events__c> eventList, Map<Id,Events__c> oldMap){

        Id eventToSendEmail ;

        for(Events__c evt : eventList){

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c && evt.type_of_road_Show__c == 'Digital Roadshow'

               && evt.Event_Approved_status__c == 'Invoice Under Review' && evt.invoice_uploaded__c == true){

                eventToSendEmail = evt.id;

            }

        }

        if(eventToSendEmail != null){
			EmailTemplate et = [select id from EmailTemplate Where DeveloperName ='CP_Head_is_approved_the_Below_event'];
            //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.id, UserInfo.getUserId(), eventToSendEmail);

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();

            

            List<ContentDocumentLink> cdl = [Select Id, ContentDocument.LatestPublishedVersion.VersionData,contentdocument.FileExtension from ContentDocumentLink where LinkedEntityId =: eventToSendEmail AND ContentDocument.Title = 'Invoice Uploaded By GM Hospitality'];           

            if(cdl.size() > 0){

            Blob b = cdl[0].ContentDocument.LatestPublishedVersion.VersionData;

            attach.setFileName('Invoice.'+cdl[0].contentdocument.FileExtension);

            attach.setBody(b);

            email.setTargetObjectId(UserInfo.getUserId());

            List<String> toAddRess = System.label.Event_Invoice_Approval_Email.split(';');

            email.setTemplateId(et.id);//Replace TEMPLATEID with salesforce email template id

            email.setToAddresses(toAddRess);

            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});

            email.saveAsActivity = false;

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

            }

        }

    }

    public static void eventStatusUpdate(List<Events__c> eventList, Map<Id,Events__c> oldMap){

 
        Id BusinessTrip = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Business Trip').getRecordTypeId();
       
        for(Events__c evt : eventList){

            if(oldMap != null && evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c ){

                if(evt.Event_Approved_status__c == 'Pending With Sales Director') {

                    evt.Next_Approver__c = evt.Sales_Director__c;

                    evt.approval_request_submitted_time__c = system.now();

                    evt.Escalation_Email_Switch__c = true;

                    evt.Email_Last_Triggered_Time__c = system.now();

                    

                }

                if(evt.Event_Approved_status__c == 'The event has been approved by Sales Director'){

                     evt.Event_Approved_status__c = 'Pending With VP'; 

                     evt.Next_Approver__c = evt.Sales_VP__c;     

                     evt.approval_request_submitted_time__c = system.now();

                     evt.Escalation_Email_Switch__c = true;

                     evt.Email_Last_Triggered_Time__c = system.now();

                }      

                If(evt.type_of_road_Show__c == 'Digital Roadshow'){

                    if(evt.Event_Approved_status__c == 'The event has been approved by VP'){

                        evt.Event_Approved_status__c = 'Pending With Avin Anil';

                        evt.Next_Approver__c = System.label.Avin_Anil_UserID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                    }

                    else If(evt.Event_Approved_status__c == 'The event has been approved by Avin Anil'){

                        evt.Event_Approved_status__c = 'Pending With Ashish Parakh';

                        evt.Next_Approver__c = System.label.Ashish_Parakh_User_Id;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

               /*     else if(evt.Event_Approved_status__c == 'The event has been approved by Ashish Parakh'){

                        evt.Event_Approved_status__c = 'Pending With Manish Goenka';

                        evt.Next_Approver__c = System.label.Manish_Goyanka_UserId;

                        evt.approval_request_submitted_time__c = system.now(); 

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    } */

                    else if(evt.Event_Approved_status__c == 'The event has been approved by CSO'){

                        evt.Event_Approved_status__c = 'Pending With Khodr El Masri/Invoice submitted by Khodr El Masri';

                        evt.Next_Approver__c = System.label.Gm_Hospitality_User_ID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

                    else if(evt.Event_Approved_status__c == 'The event has been approved by GM Hospitality'){

                        evt.Event_Approved_status__c = 'Invoice Under Review';

                        evt.Next_Approver__c = System.label.Avin_Anil_UserID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

                   

                } else{

                    if(evt.Event_Approved_status__c == 'The event has been approved by VP'){

                        evt.Event_Approved_status__c = 'Pending With CHRM manager';

                        evt.Next_Approver__c = evt.Channel_Relationship_Manager__c;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                        if(evt.Type_Of_Open_House__c == 'Direct Open House'){

                            evt.Event_Approved_status__c = 'Pending With Avin Anil';

                            evt.Next_Approver__c = System.label.Avin_Anil_UserID;

                        }

                    }

                    else if(evt.Event_Approved_status__c == 'The event has been approved by Channel Relationship Manager'){

                        evt.Event_Approved_status__c = 'Pending With CHRM manager TL';

                        evt.Next_Approver__c = evt.Channel_Relationship_Head__c;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();}

                    else if(evt.Event_Approved_status__c == 'The event has been approved by Channel Relationship Head'){

                        evt.Event_Approved_status__c = 'Pending With Avin Anil';

                        evt.Next_Approver__c = System.label.Avin_Anil_UserID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

                    else if(evt.Event_Approved_status__c == 'The event has been approved by Avin Anil') {

                        evt.Event_Approved_status__c = 'Pending With Ashish Parakh';

                        evt.Next_Approver__c = System.label.Ashish_Parakh_User_Id;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

                    else if(evt.Event_Approved_status__c == 'The event has been approved by Ashish Parakh'
                    && evt.recordTypeID != BusinessTrip){

                        evt.Event_Approved_status__c = 'Pending With Khodr El Masri/Invoice submitted by Khodr El Masri';

                        evt.Next_Approver__c = System.label.Gm_Hospitality_User_ID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }           

                    else if(evt.Event_Approved_status__c == 'The event has been approved by GM Hospitality'){

                        evt.Event_Approved_status__c = 'Invoice Under Review';

                        evt.Next_Approver__c = System.label.Avin_Anil_UserID;

                        evt.approval_request_submitted_time__c = system.now();

                        evt.Escalation_Email_Switch__c = true;

                        evt.Email_Last_Triggered_Time__c = system.now();

                    }

                }

                evt.Old_Status_Use_only_for_flow__c = evt.Event_Approved_status__c;

              

            }

        }

    }

 

    public static void eventEndDateValidation(List<Events__c> eventList, Map<Id,Events__c> oldMap){

        for(Events__c evt : eventList){

            if((oldMap == null || (oldMap.get(evt.id).End_Time_of_the_Event__c != evt.End_Time_of_the_Event__c

            || oldMap.get(evt.id).Start_Time_of_the_Event__c != evt.Start_Time_of_the_Event__c))

            && evt.End_Time_of_the_Event__c <= evt.Start_Time_of_the_Event__c && evt.Date_Of_Event__c==evt.End_Date_Of_Event__c){

                evt.addError('End Time should be greater then start time');

            }

        }

    }

    public static void shareEventOnApproval(List<Events__c> eventList, Map<Id,Events__c> oldMap){

        List<Events__c> nondigitalEvtToShare = new List<Events__c>();

        List<Events__c> digitalEvtToShare = new List<Events__c>();

        List<Events__share> evtShareToInsert = new List<Events__share>();

        for(Events__c evt : eventList){

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c ){

                if(evt.type_of_road_Show__c == 'Digital Roadshow'){

                    digitalEvtToShare.add(evt);

                }else{

                    nondigitalEvtToShare.add(evt);

                }

            }

        }

        if(digitalEvtToShare.size() > 0){

            for(Events__c evt :digitalEvtToShare){

                if(evt.Event_Approved_status__c == 'Pending With Sales Director' &&evt.Sales_Director__c != null  && evt.OwnerId != evt.Sales_Director__c){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_Director__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With VP' && evt.Sales_VP__c != null && evt.OwnerId != evt.Sales_VP__c){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_VP__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With Avin Anil' ){

                    String ownerId = (String)evt.ownerId;

                  

                    if(ownerId != system.label.Avin_Anil_UserID && ownerId.substring(0,15) != system.label.Avin_Anil_UserID && evt.OwnerId !=System.label.Avin_Anil_UserID ){
                    Events__share jobShr= createShareRecord(evt.id,System.label.Avin_Anil_UserID);

                    evtShareToInsert.add(jobShr);

                    }

                }

                else if(evt.Event_Approved_status__c == 'Pending With Ashish Parakh'  && evt.OwnerId !=System.label.Ashish_Parakh_User_Id ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Ashish_Parakh_User_Id);

                    evtShareToInsert.add(jobShr);

                }

             /*   else if(evt.Event_Approved_status__c == 'Pending With Manish Goenka' && evt.OwnerId != System.label.Manish_Goyanka_UserId ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Manish_Goyanka_UserId);

                    evtShareToInsert.add(jobShr);

                } */

                else if(evt.Event_Approved_status__c == 'Pending With Khodr El Masri/Invoice submitted by Khodr El Masri' && evt.OwnerId != System.label.Gm_Hospitality_User_ID ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Gm_Hospitality_User_ID);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With SVP' && evt.OwnerId != evt.Sales_SVP__c ){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_SVP__c);

                    evtShareToInsert.add(jobShr);

                }
                else if(evt.Event_Approved_status__c == 'Pending With AVP' && evt.OwnerId != System.label.Event_AVP ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Event_AVP);

                    evtShareToInsert.add(jobShr);

                }


 

            }

       

        }

        if(nondigitalEvtToShare.size() > 0){

           for(Events__c evt : nondigitalEvtToShare){

              

                if(evt.Event_Approved_status__c == 'Pending With Sales Director' &&evt.Sales_Director__c != null && evt.OwnerId !=evt.Sales_Director__c ){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_Director__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With VP' && evt.Sales_VP__c != null && evt.OwnerId != evt.Sales_VP__c){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_VP__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With CHRM manager' && evt.Channel_Relationship_Manager__c != null && evt.OwnerId != evt.Channel_Relationship_Manager__c){

                    Events__share jobShr= createShareRecord(evt.id,evt.Channel_Relationship_Manager__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With CHRM manager TL' && evt.Channel_Relationship_Head__c != null && evt.OwnerId != evt.Channel_Relationship_Head__c){

                    Events__share jobShr= createShareRecord(evt.id,evt.Channel_Relationship_Head__c);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With Avin Anil' ){

                    String ownerId = (String)evt.ownerId;

                    if(ownerId != system.label.Avin_Anil_UserID && ownerId.substring(0,15) != system.label.Avin_Anil_UserID){

                        Events__share jobShr= createShareRecord(evt.id,system.label.Avin_Anil_UserID);

                         evtShareToInsert.add(jobShr);

                    }

                   

                }

                else if(evt.Event_Approved_status__c == 'Pending With Ashish Parakh'  && evt.OwnerId !=system.label.Ashish_Parakh_User_Id ){

                    Events__share jobShr= createShareRecord(evt.id,system.label.Ashish_Parakh_User_Id);

                    evtShareToInsert.add(jobShr);

                }

                else if(evt.Event_Approved_status__c == 'Pending With Khodr El Masri/Invoice submitted by Khodr El Masri' && evt.OwnerId != system.label.Gm_Hospitality_User_ID ){

                    Events__share jobShr= createShareRecord(evt.id,system.label.Gm_Hospitality_User_ID);

                    evtShareToInsert.add(jobShr);

                }

             /*   else if(evt.Event_Approved_status__c == 'Venue Cost Pending Approval - CSO'  && evt.OwnerId !=System.label.Manish_Goyanka_UserId ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Manish_Goyanka_UserId);

                    evtShareToInsert.add(jobShr);

                } */
                else if(evt.Event_Approved_status__c == 'Pending With SVP' && evt.OwnerId != evt.Sales_SVP__c ){

                    Events__share jobShr= createShareRecord(evt.id,evt.Sales_SVP__c);

                    evtShareToInsert.add(jobShr);

                }
                else if(evt.Event_Approved_status__c == 'Pending with AVP'  && evt.OwnerId !=System.label.Event_AVP ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Event_AVP);

                    evtShareToInsert.add(jobShr);

                }
                else if(evt.Event_Approved_status__c == 'Pending with Anuj' && evt.OwnerId != System.label.Anuj_User_Id ){

                    Events__share jobShr= createShareRecord(evt.id,System.label.Anuj_User_Id);

                    evtShareToInsert.add(jobShr);

                }
               

            }

        }

        if(evtShareToInsert.size() > 0 && !Test.isRunningTest()){

            insert evtShareToInsert;

        }

    }

    private static Events__share createShareRecord(String eventId , string userID){

        if(userID == null ) return null;

        String profileName = [SELECT Profile.name from user where id = : userID].profile.name;

        // Create new sharing object for the custom object Job.

        Events__share jobShr  = new Events__share();

               

        // Set the ID of record being shared.

        jobShr.ParentId = eventId;

           

        // Set the ID of user or group being granted access.

        jobShr.UserOrGroupId = userID;

        //SOb-1481 updated beloew code to share record with edit access always

        // Set the access level.

        //jobShr.AccessLevel = 'Read';

        //if(profileName == 'CP Manager' || profileName == 'CP Profile'){

         jobShr.AccessLevel = 'Edit';

        //}

        //jobShr.RowCause = reason;

        return jobShr;

    }

    /**

     * @createddate : 18 Aug : 2023

     * @purpose : SOB-1266 (To calculate sales for current and last year)

     * @created by : Aayushi

     */

    public static void calculateSalesForCurrentAndLastYear(List<Events__c> evtList, Map<Id,Events__c> oldMap){

        if(stopSaleSiteCalculation == true){

            return;

        }

        List<Events__c> evtCalculatedSales = new List<Events__c>();

        List<Id> channelPartnerList = new List<Id>();

        List<Id> sobhaConnectList = new List<Id>();

        //get the event record where cp or sc id is not null or have been changed

        for(Events__c evt : evtList){

            if(evt.channel_partner__c == null && evt.Sobha_Connect__c == null){

                evt.No_Of_Sale_Last_Year_Calculated__c = 0;

                evt.No_of_Sale_This_Year_Calculated__c = 0;

            }

            if((evt.channel_partner__c != null || evt.Sobha_Connect__c != null)

              && (oldMap == null ||

              (oldMap.get(evt.Id).channel_partner__c != evt.channel_partner__c

              || oldMap.get(evt.Id).Sobha_Connect__c != evt.Sobha_Connect__c

              || (oldMap.get(evt.Id).Event_Approved_status__c != evt.Event_Approved_status__c

              && evt.Event_Approved_status__c == 'Pending With Ashish Parakh')))){

                evtCalculatedSales.add(evt);

                if(evt.channel_partner__c != null) channelPartnerList.add(evt.channel_partner__c);

                if(evt.Sobha_Connect__c != null)sobhaConnectList.add(evt.Sobha_Connect__c);

              }

        }

        //if no event record found then return from here

        if(evtCalculatedSales.isEmpty()){

            return;

        }

        Map<Id,Decimal> mapOfThisYearAgreementValue = new Map<Id,Decimal>();

        Map<Id,Decimal> mapOfLastYearAgreementValue = new Map<Id,Decimal>();

        Integer currentYear = System.Today().year();

        //query on booking record to agrregate values for last year and current year

        for(Booking__c booking : [Select Id,createdDate,Sobha_Connect__c,channel_partner__c, Agreement_Value__c from Booking__c WHERE

                                    (Sobha_Connect__c IN: sobhaConnectList

                                    OR channel_partner__c IN : channelPartnerList)

                                    AND (createdDate = Last_Year OR createdDate = THIS_YEAR)

                                    AND status__c in ('Processed','UnProcessed','Booking In Process')]){

            //sum values for booking record from current year

            if(booking.createdDate.year() == currentYear){

                if(booking.channel_partner__c != null){

                    if(!mapOfThisYearAgreementValue.containsKey(booking.channel_partner__c)){

                            mapOfThisYearAgreementValue.put(booking.channel_partner__c,0);

                    }

                    mapOfThisYearAgreementValue.put(booking.channel_partner__c, mapOfThisYearAgreementValue.get(booking.channel_partner__c)+booking.Agreement_Value__c);

                }

                if(booking.Sobha_Connect__c != null){

                    if(!mapOfThisYearAgreementValue.containsKey(booking.Sobha_Connect__c)){

                        mapOfThisYearAgreementValue.put(booking.Sobha_Connect__c,0);

                    }

                    mapOfThisYearAgreementValue.put(booking.Sobha_Connect__c, mapOfThisYearAgreementValue.get(booking.Sobha_Connect__c)+booking.Agreement_Value__c);

                }

            }

             //sum values for booking record from last year

            else if(booking.createdDate.year() == (currentYear - 1)){

                if(booking.channel_partner__c != null){

                    if(!mapOfLastYearAgreementValue.containsKey(booking.channel_partner__c)){

                        mapOfLastYearAgreementValue.put(booking.channel_partner__c,0);

                    }

                    mapOfLastYearAgreementValue.put(booking.channel_partner__c, mapOfLastYearAgreementValue.get(booking.channel_partner__c)+booking.Agreement_Value__c);

                }

                if(booking.Sobha_Connect__c != null){

                    if(!mapOfLastYearAgreementValue.containsKey(booking.Sobha_Connect__c)){

                        mapOfLastYearAgreementValue.put(booking.Sobha_Connect__c,0);

                    }

                    mapOfLastYearAgreementValue.put(booking.Sobha_Connect__c, mapOfLastYearAgreementValue.get(booking.Sobha_Connect__c)+booking.Agreement_Value__c);

                }

            }

        }

        //populated sales calculated in previous step on event records

        for(Events__c evt : evtCalculatedSales){

            if(evt.channel_Partner__c != null && mapOfThisYearAgreementValue.containsKey(evt.channel_Partner__c)){

                evt.No_of_Sale_This_Year_Calculated__c = mapOfThisYearAgreementValue.get(evt.channel_Partner__c)/1000000;

            }

            else if(evt.Sobha_Connect__c != null && mapOfThisYearAgreementValue.containsKey(evt.Sobha_Connect__c)){

               evt.No_of_Sale_This_Year_Calculated__c = mapOfThisYearAgreementValue.get(evt.Sobha_Connect__c)/1000000;

            }

            if(evt.channel_Partner__c != null && mapOfLastYearAgreementValue.containsKey(evt.channel_Partner__c)){

                evt.No_Of_Sale_Last_Year_Calculated__c = mapOfLastYearAgreementValue.get(evt.channel_Partner__c)/1000000;

            }

            else if(evt.Sobha_Connect__c != null && mapOfLastYearAgreementValue.containsKey(evt.Sobha_Connect__c)){

                evt.No_Of_Sale_Last_Year_Calculated__c = mapOfLastYearAgreementValue.get(evt.Sobha_Connect__c)/1000000;

 

            }

        }

    }//end of the method calculateSalesForCurrentAndLastYear

      /**

     * @createddate : 18 Aug : 2023

     * @purpose : SOB-1266 (To calculate no. of sites for current and last year)

     * @created by : Aayushi

     */

    public static void calculateNoOfSites(List<Events__c> evtList, Map<Id,Events__c> oldMap){

        if(stopSaleSiteCalculation == true){

            return;

        }

        List<Events__c> evtCalculatedSales = new List<Events__c>();

        List<Id> channelPartnerList = new List<Id>();

        List<Id> sobhaConnectList = new List<Id>();

        //get the event record where cp or sc id is not null or have been changed

        for(Events__c evt : evtList){

            if(evt.channel_partner__c == null && evt.Sobha_Connect__c == null){

                evt.No_of_Site_VIsits_In_Last_Year_Calculate__c = 0;

                evt.No_of_Site_VIsits_This_Year_calculat__c = 0;

            }

            if((evt.channel_partner__c != null || evt.Sobha_Connect__c != null)

              && (oldMap == null ||

              (oldMap.get(evt.Id).channel_partner__c != evt.channel_partner__c

              || oldMap.get(evt.Id).Sobha_Connect__c != evt.Sobha_Connect__c

              || (oldMap.get(evt.Id).Event_Approved_status__c != evt.Event_Approved_status__c

              && evt.Event_Approved_status__c == 'Pending With Ashish Parakh')))){

                evtCalculatedSales.add(evt);

                if(evt.channel_partner__c != null) channelPartnerList.add(evt.channel_partner__c);

                if(evt.Sobha_Connect__c != null)sobhaConnectList.add(evt.Sobha_Connect__c);

              }

        }

        //if no event record found then return from here

        if(evtCalculatedSales.isEmpty()){

            return;

        }

        Map<Id,Decimal> mapOfThisYearNoOfSales = new Map<Id,Decimal>();

        Map<Id,Decimal> mapOfLastYearNoOfSales = new Map<Id,Decimal>();

        Integer currentYear = System.Today().year();

        //query on booking record to agrregate values for last year and current year

        for(Opportunity  opp : [Select Id,Date_Of_Site_Visit__c,createdDate,Walk_In_SC__c, Walk_In_CP__c from Opportunity WHERE

                                    (Walk_In_SC__c IN: sobhaConnectList

                                    OR Walk_In_CP__c  IN : channelPartnerList)

                                    AND (Date_Of_Site_Visit__c = Last_Year OR Date_Of_Site_Visit__c = THIS_YEAR)

                                    AND (NOT Name  Like '%Test%')

                                    AND (NOT Name  Like '%test%')

                                    AND (NOT Name  Like '%Final%')

                                    AND (NOT Name  Like '%New%')

                                    AND Walk_In_source__c IN ('Channel Partner', 'Sobha Connect')]){

            //sum values for booking record from current year

            if(opp.Date_Of_Site_Visit__c.year() == currentYear){

                if(opp.Walk_In_CP__c != null){

                    if(!mapOfThisYearNoOfSales.containsKey(opp.Walk_In_CP__c)){

                        mapOfThisYearNoOfSales.put(opp.Walk_In_CP__c,0);

                    }

                    mapOfThisYearNoOfSales.put(opp.Walk_In_CP__c, mapOfThisYearNoOfSales.get(opp.Walk_In_CP__c)+1);

                }

                if(opp.Walk_In_SC__c != null){

                    if(!mapOfThisYearNoOfSales.containsKey(opp.Walk_In_SC__c)){

                        mapOfThisYearNoOfSales.put(opp.Walk_In_SC__c,0);

                    }

                    mapOfThisYearNoOfSales.put(opp.Walk_In_SC__c, mapOfThisYearNoOfSales.get(opp.Walk_In_SC__c)+1);

                }

            }

             //sum values for booking record from last year

            else if(opp.Date_Of_Site_Visit__c.year() == (currentYear - 1)){

                if(opp.Walk_In_CP__c != null){

                    if(!mapOfLastYearNoOfSales.containsKey(opp.Walk_In_CP__c)){

                        mapOfLastYearNoOfSales.put(opp.Walk_In_CP__c,0);

                    }

                    mapOfLastYearNoOfSales.put(opp.Walk_In_CP__c, mapOfLastYearNoOfSales.get(opp.Walk_In_CP__c)+1);

                }

                if(opp.Walk_In_SC__c != null){

                    if(!mapOfLastYearNoOfSales.containsKey(opp.Walk_In_SC__c)){

                        mapOfLastYearNoOfSales.put(opp.Walk_In_SC__c,0);

                    }

                    mapOfLastYearNoOfSales.put(opp.Walk_In_SC__c, mapOfLastYearNoOfSales.get(opp.Walk_In_SC__c)+1);

                }

            }

        }

        //populated sales calculated in previous step on event records

        for(Events__c evt : evtCalculatedSales){

            if(evt.channel_Partner__c != null && mapOfThisYearNoOfSales.containsKey(evt.channel_Partner__c)){

                evt.No_of_Site_VIsits_This_Year_calculat__c = mapOfThisYearNoOfSales.get(evt.channel_Partner__c);

            }

            else if(evt.Sobha_Connect__c != null && mapOfThisYearNoOfSales.containsKey(evt.Sobha_Connect__c)){

               evt.No_of_Site_VIsits_This_Year_calculat__c = mapOfThisYearNoOfSales.get(evt.Sobha_Connect__c);

            }

            if(evt.channel_Partner__c != null && mapOfLastYearNoOfSales.containsKey(evt.channel_Partner__c)){

                evt.No_of_Site_VIsits_In_Last_Year_Calculate__c = mapOfLastYearNoOfSales.get(evt.channel_Partner__c);

            }

            else if(evt.Sobha_Connect__c != null && mapOfLastYearNoOfSales.containsKey(evt.Sobha_Connect__c)){

                evt.No_of_Site_VIsits_In_Last_Year_Calculate__c = mapOfLastYearNoOfSales.get(evt.Sobha_Connect__c);

 

            }

        }

      

    }//end of the method calculateSalesForCurrentAndLastYear

    public static void updateOldDateValues(List<Events__c> eventList, Map<Id,Events__c> oldMap){

 

        for(Events__c evt : eventList){

            Events__c oldEvent = oldMap.get(evt.id);

            if(evt.date_of_event__c != oldEvent.date_of_event__c){

                evt.Old_Start_Date__c = oldEvent.date_of_event__c;

            }

            if(evt.end_date_of_event__c != oldEvent.end_date_of_event__c){

                evt.Old_End_Date__c = oldEvent.end_date_of_event__c;

            }

            if(evt.start_time_of_the_event__C != oldEvent.start_time_of_the_event__C){

                evt.Old_Start_Time_Of_Event__c           = oldEvent.start_time_of_the_event__C;

            }

            if(evt.end_time_of_the_event__C != oldEvent.end_time_of_the_event__C){

                evt.Old_End_Time_Of_Event__c = oldEvent.end_time_of_the_event__C;

            }

        }

    }

    public static void sendEmailToDevelopmentTeamForVideoShoot(List<Events__c> eventList, Map<Id,Events__c> oldMap){

        Id eventToSendEmail ;

        for(Events__c evt : eventList){

            if(evt.Event_Approved_status__c != oldMap.get(evt.id).Event_Approved_status__c && 
            evt.Event_Approved_status__c == 'Approved by CMO'){

                eventToSendEmail = evt.id;

            }

        }

        if(eventToSendEmail != null){

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

           
            EmailTemplate et = [select id from EmailTemplate Where DeveloperName ='Video_Shoot_Approved_ByAnuj'];

            List<ContentDocumentLink> cdl = [Select Id,ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData,contentdocument.FileExtension from ContentDocumentLink where LinkedEntityId =: eventToSendEmail ];           
            List<Messaging.EmailFileAttachment> attachList = new List<Messaging.EmailFileAttachment>();
               
            if(cdl.size() > 0){
                for(ContentDocumentLink cdlObj : cdl){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();

                    Blob b = cdlObj.ContentDocument.LatestPublishedVersion.VersionData;

                    attach.setFileName('Invoice'+cdlObj.ContentDocument.Title);

                    attach.setBody(b);
                    attachList.add(attach);
                }
                
            }

                email.setTargetObjectId(UserInfo.getUserId());
                email.setTreatTargetObjectAsRecipient(False);
                email.setWhatId(eventToSendEmail);
                Events__c evtObj = [SELECT ID,Channel_Relationship_Head__r.email,Channel_Relationship_Manager__r.email FROM Events__c WHERE ID =: eventToSendEmail];
                List<String> toAddRess = System.label.Video_Shoot_Development_Team_Email.split(';');
                if(evtObj.Channel_Relationship_Head__r.email!= null)
                toAddRess.add(evtObj.Channel_Relationship_Head__r.email);
                if(evtObj.Channel_Relationship_Manager__r.email!= null)
                toAddRess.add(evtObj.Channel_Relationship_Manager__r.email);
                email.setTemplateId(et.id);//Replace TEMPLATEID with salesforce email template id

                email.setToAddresses(toAddRess);
                if(cdl.size() > 0){
                    email.setFileAttachments(attachList);

                }
               
                email.saveAsActivity = false;

                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

            

        }

    }

    public static void validateVideoShootAttachments(List<Events__c> newList, Map<Id,Events__c> oldMap){
        Id videoShoot = Schema.SObjectType.Events__c.getRecordTypeInfosByName().get('Video Shoot').getRecordTypeId();
      
        List<Events__c> eventListToValidate = new List<Events__c>();
        for(Events__c evt : newList){
            if(evt.recordTypeID == videoShoot
             && evt.No_Of_Pax_Attending__c != Null
             && (evt.Event_Approved_status__c != oldMap.get(evt.Id).Event_Approved_status__c)
             && evt.Event_Approved_status__c == 'Pending With CHRM manager TL'){
                eventListToValidate.add(evt);
            }
        }
        if(!eventListToValidate.isEmpty()){
            List<ContentDocumentLink> cdlList = [Select Id, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: eventListToValidate[0].id ];           
            Map<Id,Integer> mapOfEventToNumberOfDocs = new Map<Id,Integer>();
            for(ContentDocumentLink cdl : cdlList){
                if(!mapOfEventToNumberOfDocs.containsKey(cdl.LinkedEntityId)){
                    mapOfEventToNumberOfDocs.put(cdl.LinkedEntityId,0);
                }
                mapOfEventToNumberOfDocs.put(cdl.LinkedEntityId,mapOfEventToNumberOfDocs.get(cdl.LinkedEntityId)+1);
            }
            for(Events__c evt : eventListToValidate){
                if(!mapOfEventToNumberOfDocs.containsKey(evt.Id) || mapOfEventToNumberOfDocs.get(evt.Id) < evt.No_Of_Pax_Attending__c){
                    evt.addError('Please attach documents equal to number of person attending event & retry submit for approval');
                }
            }    
            
           
        }
    }
}