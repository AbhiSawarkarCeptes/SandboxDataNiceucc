@RestResource(urlMapping = '/pushVisitorRegistration')
Global Class CreateVisitorRegistration {
    @HttpPost
    Global Static ResponseWrapper doPost() {
        List<ResponseWrapper> rwList = new List<ResponseWrapper>();
        ResponseWrapper rw = new ResponseWrapper();
        Savepoint sp = Database.setSavepoint();
        try {
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            System.debug('========== Request : '+json);
            
            Map<String, String> mobileEmailVisRegMapToInsert = new Map<String, String>();
            
            List<CreateVisitorRegistrationParser> parserList = CreateVisitorRegistrationParser.parse(json);
            
            List<Visitor_Registration__c> vrListToInsert = new List<Visitor_Registration__c>();
            
            string email,phone,project,firstName;
            
            for(CreateVisitorRegistrationParser parser : parserList) {
                /**
                if(parser.First_Name == null || parser.First_Name == '') {
                    rw.success = False;
                    rw.message = 'First Name can not be null';
                    return rw;
                }
                /*if(parser.Last_Name == null || parser.Last_Name == '') {
                    rw.success = False;
                    rw.message = 'Last Name can not be null';
                    return rw;
                }*/
               /** if(parser.Mobile == null || parser.Mobile == '') {
                    rw.success = False;
                    rw.message = 'Mobile can not be null';
                    return rw;
                }
                if(parser.Email == null || parser.Email == '') {
                    rw.success = False;
                    rw.message = 'Email can not be null';
                    return rw;
                }
                **/
                /*for(Visitor_Registration__c visRegRec : [SELECT Id, Mobile__c, Email__c 
                                                         FROM Visitor_Registration__c 
                                                         WHERE Mobile__c = :parser.Mobile OR Email__c = :parser.Email]) 
                {
                    rw.success = False;
                    rw.message = 'Email/Mobile already exists';
                    return rw;
                }*/
                
                Visitor_Registration__c vrRec = new Visitor_Registration__c();
                vrRec.First_Name__c = parser.First_Name;
                firstName = parser.First_Name;
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
                vrRec.Source__c = (parser.Source=='Client with Channel Partner' || parser.Source=='Client with Sobha Connect')?'Channel Partner':parser.Source;
                vrRec.Agent_Name__c = parser.Agent_Name;
                vrRec.Agent_ID__c = parser.Agent_Id;
                vrRec.Company__c = parser.Company;
                vrRec.Sales_Adviser__c = parser.Sales_Advisor;                
                vrRec.Nationality__c = parser.Nationality;
                vrRec.AlternateEmail_Address__c = !String.IsBlank(parser.Alternate_Email) ?parser.Alternate_Email:parser.AlternateEmail;
                vrRec.Alternate_Mobile_Number__c = parser.Alternate_Mobile;
                vrRec.Designation__c = parser.Designation;
                vrRec.Existing_Sobha_Owner__c = parser.Existing_Sobha_Owner;
                vrRec.Occupation__c = parser.Occupation;
                vrRec.Project_Name__c = parser.Project_Name;
                project = parser.Project_Name;
                vrRec.Sub_Project__c = parser.subProject_Name;
                vrRec.Visiting_On_Behalf_Of__c = parser.Visiting_On_Behalf_Of;
                vrRec.Unique_Id__c = parser.uniqueId;
                vrRec.Sobha_Connect_Name__c = parser.Sobha_Connect_name;
                vrRec.Sobha_Connect_Id__c = parser.Sobha_Connect_Id;
                vrRec.Sobha_Connect_Company_Name__c = parser.Sobha_Connect_companyName;
                vrRec.Raw_Request_Body__c = parser.Raw_Request_Body;
                vrRec.Status__c = 'Submitted';
                vrRec.Budget__c = parser.Budget;
                vrRec.Possession_Timeline__c = parser.possession_Timeline;
                vrRec.product_Type__c = parser.product_Type;
                vrRec.Property_Type__c = parser.Interested_In;
                if(parser.Birth_Date!=null && parser.Birth_Date!='')
                	vrRec.Birth_Date__c = Date.parse(parser.Birth_Date);
                vrRec.DocumentId__c = parser.DocumentId;
                vrRec.Scanned_Source__c = parser.ScannedSource;
                
                //vrRec.File_Content__c = parser.FileContent;
                System.debug('Test response VR' +vrRec);
                
                vrListToInsert.add(vrRec);
            }
            
            insert vrListToInsert;
            
            if(parserList[0].FileContent!=null && parserList[0].FileContent!=''){
                VisitorDashboardController.createVisitorsFile(parserList[0].FileContent,vrListToInsert[0].Id,firstName);
            }
            
            
            /*try{
                VisitorDashboardController.submitVisitor(project,email,phone,vrListToInsert[0].Id, parserList[0].FileContent);
            }
            catch(Exception e){
                system.debug('VVK submitVisitor Error: '+e.getMessage());
            }*/
            
            Visitor__e visEvent = new Visitor__e();
            EventBus.publish(visEvent);

            
            rw.success = True;
            rw.message = 'Successfully Processed';
            
        }catch (Exception Ex) {
            //system.assert(false,'VVK: '+Ex.getMessage());
            Database.rollback(sp);
            Error_Log__c logError = new Error_Log__c(Message__c = ex.getMessage());
            logError.class__c = 'CreateVisitorRegistration';
            RestRequest req = RestContext.request;
            String json = req.requestBody.toString();
            //logError.Request__c = json;
            insert logError;
            rw.success = False;
            rw.message = Ex.getMessage();
        } 
        return rw;
    }
    Global Class ResponseWrapper {
        Global Boolean success;
        Global String message;
    }
}