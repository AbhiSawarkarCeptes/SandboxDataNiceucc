public class OneTimeBatchToGenerateBorkerRegWithCPId implements Database.Batchable<sObject>, Database.Stateful {
	
    public List<String> failureList = new List<String>();
    public Set<Id> successIdsSet = new Set<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> cpDataToIgnore = new List<String>{'749899','572118','607282','715883','767633','736292','565831','718673','768811','691841','730009','609510','748400','787024','684743','571959','722792','724752','801994','777400','653018','605703','706608','664228','722952','795485','668149','591888','603417','678710','594248','714303','695693','615071','786953','720128','687027','678862','709412','568506','631575','647941','706827','798047','617021','749885','678538','613323','10336844','820559','824150','838184','N0000015121','597065','816312','821075','AG/GJ/AHMEDABAD/AHMADABAD CITY/AUDA/AA00176/270922R1','584276','850596','861348','9537390','868528','S2234740','921499','831075','882249','A06764776','875001','889348','895992','872182','881380','907755','910885','RC 2478071','820864','B208271','930436','07BCFPK2679P1ZX','137','948936','91370203MA3QHD0M4H','878982','T1020182','962113','974836','963853','983041','601403','997927','572695','943585','1008616','1033621','990483','1037634','.','1024552','1033429','924698','FA6368191','1139407','1065587','1082754','939557'};
        return Database.getQueryLocator('Select Id, Name ,Contact_Person__c, Address__c, Channel_Relationship_Manager__r.Email, OwnerId, Phone__c ,Mobile_No__c ,Email_ID_1__c ,Passport_No__c ,Channel_Relationship_Manager__c ,Channel_Relationship_Head__c ,Category__c ,Creation_Date__c ,Registration_Date__c ,Expiry_Date__c ,Renewal_New_Expiry__c ,Sales_Manager__c ,Sales_Manager_s_Line_Manager__c ,RERA_Registration_No__c, City__c, Country__c from Channel_Partner__c where Category__c!=null AND Passport_No__c!=null AND Passport_No__c NOT IN:cpDataToIgnore');
    }
    
    public void execute(Database.BatchableContext bc, List<Channel_Partner__c> scope){
        try{
            if(scope.size()>0){
                Map<Id, Id>brCPMap = new Map<Id, Id>();
                List<Broker_Registration__c> brokerRegToInsert = new List<Broker_Registration__c>();
                List<Broker_Registration__c> brCPList = [Select Id, CPID__c from Broker_Registration__c where CPID__c IN: scope];
                if(brCPList.size()>0){
                    for(Broker_Registration__c br: brCPList){
                        brCPMap.put(br.CPID__c, br.Id);
                    }
                }
                
                List<Channel_Partner__c> Channellist = new List<Channel_Partner__c>();
                for(Channel_Partner__c cp: scope){
                    system.debug('~~Reg: '+cp.Passport_No__c);
                    if(!brCPMap.containskey(cp.Id)){
                        Channellist.add(cp);
                        //Create BR of Type New
                        Broker_Registration__c brData = mapBrokerRegFields(cp);
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
                            system.debug('~~~~Succ: '+dsr.getId());
                            successIdsSet.add(dsr.getId());
                        } else {
                            String errMsg = Channellist[index].Id+'--'+dsr.getErrors()[0].getMessage();
                            system.debug('~~~~Error: '+errMsg);
                            failureList.add(errMsg);
                        }  
                        index++;
                    }
                }
            }
        } catch(Exception ex) {
            String erro = String.valueOf(ex);
            failureList.add(erro);
            system.debug('~~~~Error'+ex);
            System.debug(ex.getStackTraceString());
            
        }
    }
    
    public void finish(Database.BatchableContext bc){
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('Sobha Realty One time Batch Result');
        
        mail.setSubject('One Time Batch Result - Channel Partners');
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
    }
    
    public static Broker_Registration__c mapBrokerRegFields(Channel_Partner__c cpData){
        Broker_Registration__c breg = new Broker_Registration__c();
        breg.Last_Name__c = cpData.Name;
        breg.Name_as_per_trade_license__c = cpData.Name;
        breg.Name_as_per_passport__c = cpData.Name;
        if(cpData.Contact_Person__c!=null){
        	breg.Name_as_per_passport__c = cpData.Contact_Person__c;
        }
        breg.Email__c = cpData.Email_ID_1__c;
        breg.Mobile__c = cpData.Mobile_No__c;
        breg.OwnerId = cpData.OwnerId;
        if(cpData.Registration_Date__c!=null){
            breg.Broker_Created_Date__c = cpData.Registration_Date__c;
        }
        if(cpData.Passport_No__c!=null){
            breg.Registration_Number__c = cpData.Passport_No__c;
        }
        breg.CPID__c = cpData.Id;
        breg.CHRM_Manager__c = cpData.Channel_Relationship_Head__c;
        if(cpData.RERA_Registration_No__c!=null){
            breg.RERA_Number__c = cpData.RERA_Registration_No__c;
        }
        breg.Broker_Category__c = cpData.Category__c;
        breg.CHRM_Manager_Email__c = cpData.Channel_Relationship_Manager__r.Email;
        breg.Sales_Manager__c = cpData.Sales_Manager__c;
        breg.Reporting_manager__c = cpData.Sales_Manager_s_Line_Manager__c;
        breg.Telephone__c = cpData.Phone__c;
        //breg.Agreement_Created_Sent_Date__c = cpData.Creation_Date__c;
        if(cpData.Expiry_Date__c!=null){
            breg.Agreement_Created_Sent_Date__c = cpData.Expiry_Date__c.addYears(-1);
        }
        Id brRecordTypeId = Schema.SObjectType.Broker_Registration__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        breg.RecordTypeId = brRecordTypeId;
        breg.Is_Batch_Loaded__c = true;
        breg.Skip_Broker_Email_Notification__c = true;
        if(cpData.Expiry_Date__c!=null){
        	breg.Status__c = 'Agreement Executed Manually';
        } else {
            breg.Status__c = 'CHRM Registration Done';
        }
        /*if(cpData.Address__c!=null){
            List<String> addList = cpData.Address__c.split(',');
            if(addList.size()>0){
                Integer i=0; 
                List<String> tempVal = new List<String>();
                for(String addr: addList){
                    if(i==0){
                        breg.Office_Apartment_number__c =addr;
                    }
                    if(i==1){
                        breg.Street_name__c =addr;
                    }
                    if(i==2){
                        breg.Villa_Building_name__c =addr;
                    }
                    if(i>2){
                        tempVal.add(addr);
                    }
                   	i++;
                }
                if(tempVal.size()>0){
                    breg.District_Area__c = String.join(tempVal, ',');
                }
            }
        }*/
        if(cpData.Address__c!=null){
        	breg.Villa_Building_name__c = cpData.Address__c;
        }
        if(cpData.City__c!=null){
        	breg.City_Province__c = cpData.City__c;
        }
        if(cpData.Country__c!=null){
        	breg.Country__c = cpData.Country__c;
        }
        /*breg.Office_Apartment_number__c = cpData.;
        breg.Street_name__c = cpData.;
        breg.Villa_Building_name__c = cpData.;
        breg.District_Area__c = cpData.;
        breg.City_Province__c = cpData.;
        breg.Country__c = cpData.;
        breg.ZIP_Postal_Code_PO_Box__c = cpData.; 
		breg.Nationality__c = cpData.;
		breg.Designation__c = cpData.;*/        
        return breg;
    }
    
}