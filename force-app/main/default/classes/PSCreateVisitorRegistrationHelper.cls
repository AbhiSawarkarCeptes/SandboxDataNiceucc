global class PSCreateVisitorRegistrationHelper {
    global Static String createVisitorRegistration(RestRequest request) {
        String responce = '';
        if (request != null && 
            request.requestBody != null) {
                String jsonString = request.requestBody.toString();
                string email,phone,project;
                try {
                    Map<String, String> fileContentMap =  new Map<String, String>();
                    List<Visitor_Registration__c> insertList = new List<Visitor_Registration__c>();
                    List<PSCreateVisitorRegistrationPOJO> visitorList = (List<PSCreateVisitorRegistrationPOJO>) JSON.deserialize(jsonString, List<PSCreateVisitorRegistrationPOJO>.class);
                    if(!visitorList.isEmpty()) {
                        Set<String> projectNames = new Set<String>();
                        Set<String> accNames = new Set<String>();
                        Set<String> contNames = new Set<String>();

                        for(PSCreateVisitorRegistrationPOJO parser : visitorList) {
                            if(parser.Project_Name != null) {
                                projectNames.add(parser.Project_Name);
                            }
                            if(parser.Sobha_Connect_name != null) {
                                accNames.add(parser.Sobha_Connect_name);
                            }
                            if(parser.Agent_Name != null) {
                                contNames.add(parser.Agent_Name);
                            }
                        }

                        List<PropStrength__Projects__c> projectList = [SELECT Id, Name FROM PropStrength__Projects__c WHERE Name IN :projectNames];
                        List<Account> accList = [SELECT Id, Name FROM Account WHERE Name IN :accNames AND RecordType.Name = 'Broker'];

                        Map<String, Id> projNameMap = new Map<String, Id>();

                        for(PropStrength__Projects__c proj : projectList) {
                            projNameMap.put(proj.Name, proj.Id);
                        }

                        Map<String, Id> accNameMap = new Map<String, Id>();

                        for(Account acc : accList) {
                            accNameMap.put(acc.Name, acc.Id);
                        }

                        List<Contact> contList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :accNameMap.values() AND RecordType.Name = 'Broker'];

                        Map<Id, Contact> contRecMap = new Map<Id, Contact>();  // AccountID and Contact Map

                        for(Contact cont : contList) {
                            contRecMap.put(cont.AccountId, cont);
                        }

                        for(PSCreateVisitorRegistrationPOJO parser : visitorList) {
                            if(String.isBlank(parser.First_Name)) {
                                responce = '{"Sucess" : false,"errorMessage":"First Name can not be null.","Message":""}';
                            }
                            if(String.isBlank(parser.Mobile)) {
                                responce = '{"Sucess" : false,"errorMessage":"Mobile can not be null.","Message":""}';
                            }
                            if(String.isBlank(parser.Email)) {
                               responce = '{"Sucess" : false,"errorMessage":"Email can not be null.","Message":""}';
                            }
                            if(!String.isBlank(parser.First_Name) &&
                               !String.isBlank(parser.Email) &&
                               !String.isBlank(parser.Mobile)) {
                                   Visitor_Registration__c vrRec = new Visitor_Registration__c();
                                   vrRec.First_Name__c = parser.First_Name;
                                   vrRec.Last_Name__c = parser.Last_Name;
                                   vrRec.Mobile__c = parser.Mobile;
                                   phone = parser.Mobile;
                                   vrRec.Email__c = parser.Email;
                                   email = parser.Email;
                                   vrRec.Permanent_Address__c = parser.Address;
                                   vrRec.City__c = parser.City;
                                   vrRec.Country__c = parser.Country;
                                   vrRec.UAE_Resident__c = Boolean.valueOf(parser.UAE_Resident);
                                   vrRec.Interested_in__c = parser.Interested_In;
                                   vrRec.Purpose_of_Purchase__c = parser.Purpose_Of_Purchase;
                                   vrRec.Remarks_if_any__c = parser.Remarks;
                                   vrRec.Source__c = parser.Source;
                                   vrRec.Agent_Name__c = parser.Agent_Name;
                                   vrRec.Agent_ID__c = parser.Agent_Id;
                                   vrRec.Company__c = parser.Company;
                                   vrRec.Sales_Adviser__c = parser.Sales_Advisor;
                                   vrRec.Nationality__c = parser.Nationality;
                                   vrRec.Alternate_Email_Id__c = parser.Alternate_Email;
                                   vrRec.Alternate_Mobile_Number__c = parser.Alternate_Mobile;
                                   vrRec.Designation__c = parser.Designation;
                                   vrRec.Existing_Sobha_Owner__c = parser.Existing_Sobha_Owner;
                                   vrRec.Possession_Timeline__c = parser.possession_Timeline;
                                   vrRec.Budget__c = parser.Budget;
                                   vrRec.product_Type__c = parser.product_Type;
                                   vrRec.Occupation__c = parser.Occupation;
                                   vrRec.Project_Name__c = parser.Project_Name;
                                   //vrRec.Project_Name__c = 'Sobha Hartland';
                                   if(parser.Project_Name != null && projNameMap.containsKey(parser.Project_Name)) {
                                    vrRec.Project1__c = projNameMap.get(parser.Project_Name);
                                   }

                                   if(parser.Sobha_Connect_name != null && accNameMap.containsKey(parser.Sobha_Connect_name)) {
                                    vrRec.Broker_Account__c = accNameMap.get(parser.Sobha_Connect_name);
                                   }

                                   if(vrRec.Broker_Account__c != null &&  accNameMap.containsKey(parser.Sobha_Connect_name) && contRecMap.containsKey(accNameMap.get(parser.Sobha_Connect_name)) && contRecMap.get(accNameMap.get(parser.Sobha_Connect_name)).AccountId == vrRec.Broker_Account__c) {
                                    vrRec.Broker_Contact__c = contRecMap.get(accNameMap.get(parser.Sobha_Connect_name)).Id;
                                   }
                                   project = parser.Project_Name;
                                   vrRec.Sub_Project__c = parser.subProject_Name;
                                   vrRec.Visiting_On_Behalf_Of__c = parser.Visiting_On_Behalf_Of;
                                   vrRec.Unique_Id__c = parser.uniqueId;
                                   vrRec.Sobha_Connect_Name__c = parser.Sobha_Connect_name;
                                   vrRec.Sobha_Connect_Id__c = parser.Sobha_Connect_Id;
                                   vrRec.Sobha_Connect_Company_Name__c = parser.Sobha_Connect_companyName;
                                   vrRec.ScannedSource__c = parser.ScannedSource;
                                   vrRec.Raw_Request_Body__c = parser.Raw_Request_Body;
                                   vrRec.DocumentId__c = parser.DocumentId;
                                   vrRec.Status__c = 'Submitted';
                                   if(parser.FileContent != null && parser.FileContent != '') {
                                        fileContentMap.put(parser.First_Name+'-'+parser.Email, parser.FileContent);
                                    }
                                   insertList.add(vrRec);
                               }
                        }
                        if(!insertList.isEmpty()) {
                            List<Database.SaveResult> contactList = Database.insert(insertList);
                            for(Integer i=0;i<contactList.size();i++) {
                                if (contactList.get(i).isSuccess()){
                                    responce = '{"Sucess" : true,"errorMessage":"","Message":"Successfully Processed"}';
                                } else if (!contactList.get(i).isSuccess()) {
                                    Database.Error error = contactList.get(i).getErrors().get(0);
                                    system.debug('Failed ID::'+error.getMessage());
                                    responce = '{"Sucess" : false,"errorMessage":"'+error.getMessage()+'","Message":""}';
                                }
                            }
                            Map<Id, String> vrIdFileContentMap = new Map<Id, String>();
                            for(Visitor_Registration__c vr: insertList) {
                                if(fileContentMap.containsKey(vr.First_Name__c+'-'+vr.Email__c)) {
                                    vrIdFileContentMap.put(vr.Id, fileContentMap.get(vr.First_Name__c+'-'+vr.Email__c));
                                }
                            }
                            if(!vrIdFileContentMap.keySet().isEmpty()){
                                PSCreateVisitorRegistrationHelper.createFile(vrIdFileContentMap);
                            }
                        }
                    }
                } catch(Exception e) {
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                    responce = '{"Sucess" : false,"errorMessage":"'+e.getMessage()+'","Message":""}';
                }
            }
        return responce;
    }
    public static void createFile(Map<Id, String> fileContentMap) {
        System.debug('------------>'+ fileContentMap);
        Map<Id, Visitor_Registration__c> vrMap = new Map<Id, Visitor_Registration__c>([SELECT Id, First_Name__c FROM Visitor_Registration__c WHERE ID IN :fileContentMap.keySet()]);
        Map<String, Id> fileNameToParentId = new Map<String, Id>();
        List<ContentVersion> conVerList = new List<ContentVersion>();
        for(Visitor_Registration__c vr: vrMap.values()) {
            System.debug('------------>'+ vr.First_Name__c);
            System.debug('------------>'+ fileContentMap.values());
            System.debug('------------>'+ fileContentMap.get(vr.Id));
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = vr.First_Name__c+'.png';//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.Title = vr.First_Name__c;//Name of the file
            //cVersion.VersionData = Blob.valueof(fileContent);//File content
            cVersion.VersionData = EncodingUtil.base64Decode(fileContentMap.get(vr.Id));//File content
            conVerList.add(cVersion);
            System.debug('------------>'+ conVerList);
            fileNameToParentId.put(vr.First_Name__c, vr.Id);
        }
        if(!conVerList.isEmpty()) {
            insert conVerList;
            List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
            Map<String, Id> contentVersionIds = new Map<String, Id>();
            for(ContentVersion cv : conVerList) {
                contentVersionIds.put(cv.Title, cv.Id);
            }
            Map<Id, ContentVersion> contDocMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN :conVerList]);
            for(Visitor_Registration__c vr: vrMap.values()) {
                // Create a new ContentDocumentLink record
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = contDocMap.get(contentVersionIds.get(vr.First_Name__c)).ContentDocumentId;
                contentDocumentLink.LinkedEntityId = vr.Id; // Link to the parent record (e.g., Opportunity, Case, etc.)
                contentDocumentLink.Visibility = 'AllUsers'; // Set the visibility as needed
                contentDocumentLinksToInsert.add(contentDocumentLink);
            }

            // Insert the ContentDocumentLink records
            if (!contentDocumentLinksToInsert.isEmpty()) {
                insert contentDocumentLinksToInsert;
            }
        }
    }
}