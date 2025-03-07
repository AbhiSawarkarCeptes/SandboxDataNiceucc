@isTest
public class ContentDocumentTriggerHandlerTest {
    
    @isTest
    public static void brokerTestMethod1(){
        Broker_Registration__c br = new Broker_Registration__c(Broker_Category__c='Broker - RERA', CHRM_Manager_Email__c='testm@test.ae',
                                     Mobile__c='0987654321', Email__c='test@teser.co', Last_Name__c='Testlast');
        insert br;
        
        Sobha_Event__c ev = new Sobha_Event__c();
        ev.Name = 'Test';
        insert ev;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=br.id;
        Id contenId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.contentdocumentid=contenId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentDocumentLink contentlink1=new ContentDocumentLink();
        contentlink1.LinkedEntityId=ev.id;
        Id contenId1 = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink1.contentdocumentid=contenId1;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        
        delete new contentdocument(Id = contenId);
        
    }
    
    @isTest Public static void method1(){
        Map<String, Id> recordMap = TestDataFactory.createMasterProject('Test Project');
        Id oppId  =   recordMap.get('OPPORTUNITY');
        Id unitId = recordMap.get('UNIT');
        Id projectId = recordMap.get('PROJECT');
        Id projCharges = recordMap.get('BASIC');
        
        Quotation__c quote = createQuotation(oppId, recordMap.get('PLAN'), unitId);             
        
        //Payment_Milestones__c pm1 = createPaymentMilestone(quote.Id);
        //pm1.Charge_1_Lookup__c = projCharges;
        //update pm1;     
        Account_Master__c am = new Account_Master__c();
        am.Name = 'TRADE RECEIVABLE';
        am.Account_Number__c = '1234';
        am.Type__c = 'Others';
        insert am;
        Account_Master__c am1 = new Account_Master__c();
        am1.Name = 'MAIN CASH';
        am1.Account_Number__c = '12345';
        am1.Type__c = 'Others';
        insert am1;
        Account_Master__c am2 = new Account_Master__c();
        am2.Name = 'Interest Charges';
        am2.Account_Number__c = '123456';
        am2.Type__c = 'Others';
        insert am2;
        
        Booking__c b = new Booking__c();
        b.Booking_Date__c = system.today();
        b.Project__c = projectId;
        b.Opportunity__c = oppId;
        b.Unit__c = unitId;
        b.status__c = 'Processed';
        b.Quotation__c = quote.Id;
        b.Primary_Applicant_Email__c = 'abc.abc@abc.com';
        b.Future_Correspondence_Contact__c = 'First Applicant';
        b.Agreement_Value__c = 6000000;
        b.Stage_of_Booking__c = 'Booked';
        insert b;
        
        
        Payment_Request__c pr = new Payment_Request__c();
        pr.name__c = 'yamini';
        pr.Booking__c=b.id;
        pr.Email__c = 'yamini.jakka@ceptes.com';
        pr.Mobile_Number__c='9550987889';
        pr.Emirates_Id_Passport_Number__c='12xgy';
        pr.Mode__c = 'OTC Deposits';
        pr.Status__c='Approved';
        pr.Amount__c = 123;
        pr.Unit__c = unitId;
        pr.Approved_Date_and_Time__c=System.today();
        pr.From_Booking__c = true;
        insert pr;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=pr.id;
        Id contenId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.contentdocumentid=contenId;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
        Content_Document_Setting__c settings = Content_Document_Setting__c.getOrgDefaults();
        settings.Allow_Payment_Request_file_deletion__c = true;
        //upsert settings custSettings__c.Id;
        try{
            delete new contentdocument(Id = contenId);
        }
        catch(Exception e){
            
        }
        
    }
    public static Quotation__c createQuotation (Id opp, Id pp, Id ut1){
        
        
        Quotation__c objQuote1 = new Quotation__c();        
        objQuote1.Opportunity__c = opp ;
        objQuote1.Payment_Plan__c = pp ;
        objQuote1.Unit__c = ut1;
        objQuote1.Basic_Original_PSF__c = 12;
        objQuote1.Charge1Bucket__c = 'Agreement Value';
        objQuote1.Charge1Name__c = 'Basic';
        objQuote1.Charge1Value__c = 1123;
        objQuote1.Charge2Bucket__c = 'Agreement Value';
        objQuote1.Charge2Name__c = 'Floor Rise';
        objQuote1.Charge2Value__c = 1123;
        
        objQuote1.Charge3Bucket__c = 'Agreement Value';
        objQuote1.Charge3Name__c = 'PLC';
        objQuote1.Charge3Value__c = 1123;
        
        objQuote1.Charge4Bucket__c = 'Other Charges';
        objQuote1.Charge4Name__c = 'test';
        objQuote1.Charge4Value__c = 1123;
        objQuote1.Final_Approved_Date__c = System.today();
        insert objQuote1;
        return objQuote1;
    }
}