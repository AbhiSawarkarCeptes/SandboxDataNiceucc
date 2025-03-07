public class OneTimeBatchToGenerateBorkerRegWithSCId implements Database.Batchable<sObject>, Database.Stateful {
	
    public List<String> failureList = new List<String>();
    public Set<Id> successIdsSet = new Set<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> scDataToIgnore = new List<String>{'677441','677441','N2499039','N2499039','Z3800312','30191928','72 0440671','72 0440671','EC7962648','S2234740','895992','AG/GJ/AHMEDABAD/AHMADABAD CITY/AUDA/AA00176/270922R1','A06764776','Z3800312','AH859165','AH859165','19A125400','RL 3603893','RL 3603893','A 23412402','A 23412402','U0594757','V720924','137','5952','936555','19A125400','V720924','A10212230','Z4128712','108-17-L032674','U0594757','X176999','936555','Z4128712','108-17-L032674','X176999','B208271','A08966274','EC7962648','5952','5952','T1020182','A08966274','A10212230','30191928','939557','76 4945891','76 4945891','FA6368191'};
        return Database.getQueryLocator('Select Id, Address__c, Nationality__c, City__c, Country__c, Name__c, Contact_Person__c, Telephone_Number__c, Mobile_No__c, Email_Id__c, Registration__c, Channel_Relationship_Manager__c, Channel_Relationship_Manager__r.Email, OwnerId, Channel_Relationship_Head__c, Agent_Category__c, Creation_Date__c, Registration_Date__c, Expiry_Date__c, Renewal_New_Expiry__c, Sales_Manager__c, Sales_Head__c, RERA_Number__c from Sobha_Connect__c where Agent_Category__c!=null AND Registration__c!=null AND Registration__c NOT IN:scDataToIgnore');
    }
    
    public void execute(Database.BatchableContext bc, List<Sobha_Connect__c> scope){
        try{
            if(scope.size()>0){
                Map<Id, Id>brSCMap = new Map<Id, Id>();
                List<Broker_Registration__c> brokerRegToInsert = new List<Broker_Registration__c>();
                List<Broker_Registration__c> brCPList = [Select Id, SCID__c from Broker_Registration__c where SCID__c IN: scope];
                system.debug('~~~BR: '+brCPList);
                if(brCPList.size()>0){
                    for(Broker_Registration__c br: brCPList){
                        brSCMap.put(br.SCID__c, br.Id);
                    }
                }
                
                List<Sobha_Connect__c> sobhaLlist = new List<Sobha_Connect__c>();
                for(Sobha_Connect__c sc: scope){
                    if(!brSCMap.containskey(sc.Id)){
                        sobhaLlist.add(sc);
                        //Create BR of Type New
                        Broker_Registration__c brData = mapBrokerRegFields(sc);
                        
                        
                        system.debug('~~'+brData);
                        if(brData!=null){
                            brokerRegToInsert.add(brData);
                        }
                    }
                }
                
                if(brokerRegToInsert.size()>0){
                    
                   //insert(brokerRegToInsert);
                   Database.SaveResult[] srList = Database.insert(brokerRegToInsert, false);
                   Integer index = 0;
                    for(Database.SaveResult dsr : srList){
                        if(dsr.isSuccess()){
                            successIdsSet.add(dsr.getId());
                        } else {
                            String errMsg = sobhaLlist[index].Id+'--'+dsr.getErrors()[0].getMessage();
                            system.debug('~~~~Errr-'+errMsg);
                             failureList.add(errMsg);
                        }  
                       index++;
                    }
                    /*for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted ID: ' + sr.getId());
                            successIdsSet.add(sr.getId());
                        }
                        else {               
                            for(Database.Error err : sr.getErrors()) {
                                String dd = String.valueOf(err);
                                failureList.add(dd);                 
                                //System.debug(err.getStatusCode() + ': ');
                                System.debug('Account fields that affected this error: ' + dd);
                            }
                        }
                    } //EOF For */
                    
                }
            }
        } catch(Exception ex) {
            String erro = String.valueOf(ex);
            system.debug('~~~~Error'+ex);
            System.debug(ex.getStackTraceString());
            
        }
    }
    
    public void finish(Database.BatchableContext bc){
        try{
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('Sobha Realty One time Batch Result');
        
        mail.setSubject('One Time Batch Result - Sobha Connect');
        String body = 'Hi Team,<br/><br/>Please find the Batch results as below,<br/>';
        
        if(failureList.size()>0){
        	body += 'Failed Record list: ';
           	body +='<table border="1" cellspacing="5" cellpadding="5">';
            for(String fr: failureList){
                body +='<tr><td>'+fr+'</td></tr>';
            }
            body +='</table>';
        }
        
        if(successIdsSet.size()>0){
        	body += 'Success Record list: ';
           	body +='<table border="1" cellspacing="5" cellpadding="5">';
            for(String sc: successIdsSet){
                body +='<tr><td>'+sc+'</td></tr>';
            }
            body +='</table>';
        }
        
        String[] toAddresses = new String[] {'padmesh.rajan.c@sobharealty.com'};
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(body);
        emailMessageList.add(mail);
        Messaging.sendEmail(emailMessageList);
        } catch(Exception e){
            system.debug('~~~Error: '+e.getMessage());
        }
    }
    
    public static Broker_Registration__c mapBrokerRegFields(Sobha_Connect__c sc){
        Broker_Registration__c breg = new Broker_Registration__c();
        breg.Last_Name__c = sc.Name__c;
        breg.Name_as_per_trade_license__c = sc.Name__c;
        breg.Name_as_per_passport__c = sc.Name__c;
        if(sc.Contact_Person__c==null){
        breg.Name_as_per_passport__c = sc.Contact_Person__c;
        }
        breg.Email__c = sc.Email_Id__c;
        breg.Mobile__c = sc.Mobile_No__c;
        breg.OwnerId = sc.OwnerId;
        if(sc.Registration_Date__c!=null){
        breg.Broker_Created_Date__c = sc.Registration_Date__c;
        }
        if(sc.Registration__c!=null){
        breg.Registration_Number__c = sc.Registration__c;
        }
        breg.SCID__c = sc.Id;
        breg.CHRM_Manager__c = sc.Channel_Relationship_Head__c;
        if(sc.RERA_Number__c!=null){
        breg.RERA_Number__c = sc.RERA_Number__c;
        }
        if(sc.Agent_Category__c!=null){
        breg.Broker_Category__c = sc.Agent_Category__c;
        }
        breg.CHRM_Manager_Email__c = sc.Channel_Relationship_Manager__r.Email;
        breg.Sales_Manager__c = sc.Sales_Manager__c;
        breg.Reporting_manager__c = sc.Sales_Head__c;
        breg.Telephone__c = sc.Telephone_Number__c;
        if(sc.Expiry_Date__c!=null){
        	breg.Agreement_Created_Sent_Date__c = sc.Expiry_Date__c.addYears(-1);
        }
        Id brRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        breg.RecordTypeId = brRecordTypeId;
        breg.Is_Batch_Loaded__c = true;
        breg.Skip_Broker_Email_Notification__c = true;
        if(sc.Expiry_Date__c!=null){
        	breg.Status__c = 'Agreement Executed Manually';
        } else {
        	breg.Status__c = 'CHRM Registration Done';
        }
        if(sc.Address__c!=null){
            breg.Villa_Building_name__c = sc.Address__c;
        }
        if(sc.City__c!=null){
            breg.City_Province__c = sc.City__c;
        }
        if(sc.Country__c!=null){
        	breg.Country__c = sc.Country__c;
        }
        if(sc.Nationality__c!=null){
            breg.Nationality__c = sc.Nationality__c;
        }
        return breg;
      }
    
}