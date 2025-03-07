public with sharing class SocialMediaLeadServices {  
    
    /* Social Media Lead Record & the lead to be inserted will be passed here */  
    public static void processLead(List<Social_Media_Lead__c> smlList,List<Lead> leadList,String formattedPhone){
        
        List < Lead > leadsToBeInserted = new List < Lead > ();
        List<Social_Media_Lead__c> smlUpdateList = new List<Social_Media_Lead__c>(); 
        
        system.debug('Entered SocialMediaLeadServices.processLead()');
        
        for (lead l: leadList) {
            database.DMLOptions dmo = new database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerUserEmail = true;
            l.setOptions(dmo);
            leadsToBeInserted.add(l); 
        }   
        system.debug('processleaddebug' + leadsToBeInserted);
        try {
            
            /* Duplicate check on Leads. If there is duplication, Lead won't be inserted */
            
            List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadsToBeInserted, 'WEB');
            system.debug('SocialMediaLeadServices.processLead() --> Duplicate Leads' + dupList);
            if (dupList.isEmpty()) { /* Non duplicate scenario */
                try {
                    
                    Database.saveResult[] srList = Database.insert(leadsToBeInserted, true);
                    system.debug('srList' + srList);
                    for (Database.SaveResult sr: srList) {
                        if (sr.isSuccess()) {
                           
                            System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                            try {
                                for(Social_Media_Lead__c sml : smlList){
                                    Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                                    sml1.Id = sml.id;/*Oct 16th 2024*/
                                    sml1.lead_id__c = sml.lead_id__c;
                                    sml1.processed__c = true;
                                    sml1.result__c = 'NEW LEAD';
                                    sml1.remarks__c = ' New Lead Created';
                                    sml1.sf_lead__c = sr.getId();
                                    smlUpdateList.add(sml1);
                                }
                                
                                system.debug('upsertdebug' +smlUpdateList );
                                //upsert sml1List lead_id__c ; /*Oct 16th 2024*/
                                update smlUpdateList; /*Oct 16th 2024*/
                                
                                /* Enquiry Creation */
                                Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                enquiryMap.put(sr.getId(), leadsToBeInserted[0]);
                                Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                                system.debug('whoidmap' + whoIdMap );
                                
                                task t = [Select Id, new_lead_created__c from task where id = : whoIDMap.get(sr.getId()).Id];
                                t.new_lead_created__c  = true;
                                upsert t;
                                
                            } catch (GlobalException ex) {
                                System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage()); 
                            }
                        } 
                    }
                } catch (System.DmlException ex) {
                    String msg = null;
                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                        msg = 'Lead Insert Failed :' + ex.getMessage();
                    }
                    System.debug('SocialMediaLeadServices.processLead() --> Lead Insertion Error :' + msg);
                    for(Social_Media_Lead__c sml : smlList){
                        Social_Media_Lead__c sml1 = new Social_Media_Lead__c(Id = sml.id, lead_id__c = sml.lead_id__c, processed__c = true, result__c = 'ERROR', remarks__c = msg );
                        smlUpdateList.add(sml1);
                    }
                    if(!test.isRunningTest()){
                        //upsert sml1List lead_id__c ;
                        update smlUpdateList;/*Oct 16th 2024*/
                    }
                }
            }else { /* Duplicate scenario */
                
                for(Social_Media_Lead__c sml : smlList){
                    Social_Media_Lead__c sml1 = new Social_Media_Lead__c();
                    sml1.Id = sml.id;/*Oct 16th 2024*/
                    sml1.lead_id__c = sml.lead_id__c;
                    sml1.processed__c = true;
                    sml1.result__c = 'EXISTING LEAD';
                    system.debug('enteredexisting');
                    if(dupList[0].duplicateMaster.getSObjectType().getDescribe().getName() == 'Lead') { sml1.remarks__c = 'Existing Lead'; sml1.sf_Lead__c =dupList[0].duplicateMaster; }
                    else { sml1.sf_Account__c =dupList[0].duplicateMaster; sml1.remarks__c = 'Existing Account'; }
                    smlUpdateList.add(sml1);
                }
                if(!test.isRunningTest()) {
                    //upsert sml1List lead_id__c ;
                    update smlUpdateList;/*Oct 16th 2024*/
                }
                
                
            }
        } catch (GlobalException g) {
            for(Social_Media_Lead__c sml : smlList){
                Social_Media_Lead__c sml1 = new Social_Media_Lead__c(Id = sml.id, lead_id__c = sml.lead_id__c, processed__c = true, result__c = 'ERROR', remarks__c = g.getMessage() + g.getClassDetails());
                smlUpdateList.add(sml1);
            }
            if(!test.isRunningTest()) {
                //upsert sml1List lead_id__c ;
                update smlUpdateList;/*Oct 16th 2024*/
            }
        }
    }
   
    /* All the unprocessed Social Media Leads from batch reach here & Lead will be prepared - Batch size 1*/
    public static void PrepareLeadfromSML(List<Social_Media_Lead__c> smList){
        system.debug('enteredmethod' + smList);
        List < Lead > leadList = new List < Lead > ();
        String lastName;
        Map<String,String> projectFormMap = new Map<String,String>();
        List<String> formList = new List<String>();
        for(Social_Media_Lead__c sml : smList){ formList.add(sml.Form_ID__c);
                                              }
        system.debug('enteredmethod1' + formList);
       
        List<Project__c> projId = [SELECT Id FROM Project__c Where Name = 'Sobha Hartland'];
        
        system.debug('enteredmethod2' + projectFormMap);
        for(Social_Media_Lead__c sml : smList){
            Lead leadCreated = new lead();
            leadCreated.WeChat_ID__c = sml.WeChat_ID__c;
            leadCreated.Leadgen_Form_ID__c = sml.Form_ID__c;
            leadCreated.Leadgen_Page_ID__c = sml.Page_ID__c;
            leadCreated.Project__c = projId[0].Id;//projectFormMap.get(sml.Form_ID__c);
            leadCreated.Email     = sml.Email__c;
            leadCreated.Campaign_Code__c=sml.Campaign_Id__c;
            leadCreated.Campaign_Name__c=sml.Campaign_Name__c;
            leadCreated.Lead_Sub_Source__c=sml.Source__c;
            leadCreated.UTM_Campaign__c = sml.Campaign_Name__c;
            leadCreated.UTM_Source__c = sml.Source__c;
            
            // leadCreated.Web_Source__c = sml.Campaign_Name__c;
            system.debug('leaddebug' + sml.Campaign_Name__c + '///' + leadCreated.Web_Source__c);
            //   leadCreated.RDS_Country__c = sml.Country__c;  
            leadCreated.Facebook_Ad_ID__c = sml.Ad_ID__c;
            leadCreated.Facebook_Ad_Name__c = sml.Ad_Name__c;
            leadCreated.UTM_Term__c = sml.Ad_Name__c;
            leadCreated.Facebook_Adset_ID__c = sml.AdSet_Id__c;
            leadCreated.Facebook_Adset_Name__c = sml.AdSet_Name__c;           
            leadCreated.Fb_Lead_Creation_date__c = sml.Lead_Created_Time__c;
            leadCreated.Meta_Lead_ID__c = sml.Lead_ID__c;
            leadCreated.Platform__c = sml.Platform_ig__c;
            leadCreated.Facebook_Page_Name__c = sml.Page_Name__c;
            leadCreated.Facebook_Form_Name__c = sml.Form_Name__c;
            if(sml.Full_Name__c !=null)
                leadCreated.lastName = sml.Full_Name__c;
            else 
                leadCreated.LastName = sml.First_Name__c + sml.Last_Name__c;
            if(sml.Mobile_Number_No_Country_Code__c != null ){
                leadCreated.MobilePhone = sml.Mobile_Number_No_Country_Code__c;
            }else {
                leadCreated.MobilePhone = sml.Mobile_Number__c;
            }
            
            if(sml.Form_Data__c != null){
                leadCreated.Form_Data__c = sml.Form_Data__c;
            }
            if(sml.Phone_Number__c != null){
                leadCreated.Phone = sml.Phone_Number__c;
            }
            
            if(!String.isBlank(sml.Country_Code__c)){//Added by mohit #SOB-490
                leadCreated.RDS_Country_Code__c = sml.Country_Code__c.startsWith('+') ? sml.Country_Code__c : '+' + sml.Country_Code__c;
            }
            if(sml.Recording_URL__c != null){
                leadCreated.Recording_URL__c = sml.Recording_URL__c;
            }
            leadCreated.When_you_re_looking_to_buy__c = sml.When_are_you_looking_to_buy__c;
            leadCreated.Would_you_like_to_invest_in_Dubai_Real_E__c = sml.Would_you_like_to_invest_in_Dubai__c;
            leadCreated.callBackTime__c = sml.Select_call_back_time__c;
            leadCreated.Are_you_looking_for__c = sml.Looking_for__c;
            leadCreated.Budgett__c = sml.Budgett__c;
            leadCreated.Website_Language__c = sml.Language__c;
            LeadUtility.fetchLeadSource(leadCreated,sml);
            LeadUtility.formatPhone2(leadCreated, sml);
            leadCreated.LeadSource = 'Digital';
            leadCreated.Client_Comments__c = sml.Remarks__c;
            leadList.add(leadCreated);
        }
        system.debug('enteredmethod3' + leadList);
        if(leadList.size() > 0 ){ processLead(smList,leadList,null);
                                }
    }
}