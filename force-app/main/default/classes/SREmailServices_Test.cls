@isTest()
public class SREmailServices_Test{
    
    public static testMethod void ServicesReq1() {
        
        List<string> emailToAddr = new List<string>();
        List<string> emailCcAddr = new List<string>();
        emailToAddr.add('customercaretest11@gmail.com');
        emailCcAddr.add('clubplattest@gmail.com');
        
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment(); 
        
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'), Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        
        Messaging.InboundEmail.TextAttachment[] TextAttachments = new Messaging.InboundEmail.TextAttachment[1];  
        Messaging.InboundEmail.TextAttachment TextAttachment = new Messaging.InboundEmail.TextAttachment(); 
        
        TextAttachment.Filename = 'test.txt';
        TextAttachment.Body = 'Hello user';
        TextAttachments[0] =  TextAttachment ;
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Re:Create123456Contact';
        email.fromAddress = 'someaddress@email.com';
        email.fromName = 'ishan Sharma';
        email.plainTextBody = 'email body\n2225256325\nTitle:\ntest:';
        email.toAddresses = emailToAddr;
        email.ccAddresses = emailCcAddr;
        email.references = new List<String>{'MyForcexApp.'};
            email.binaryAttachments = binaryAttachments;
        email.TextAttachments = TextAttachments;
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.toAddress = 'lead.owner.new@cpeneac.cl.apex.sandbox.salesforce.com';
        envelope.fromAddress = 'user@acme.com';
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='test@test.com',
                          
                          EmailEncodingKey='UTF-8', LastName='Email admin', LanguageLocaleKey='en_US',
                          
                          LocaleSidKey='en_US', ProfileId = p.Id,City = 'Meerut',
                          
                          TimeZoneSidKey='America/Los_Angeles', UserName='gggtestmldl@test.com');
        
        insert u;

        
        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2345t';
        con.Ownerid = u.id;
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;

        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;

        PropStrength__Broker__c brk = new PropStrength__Broker__c();
        brk.PropStrength__Email_Id__c = 'someaddress@email.com';
        
        insert brk;

        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = con.Id;
        insert enq;

        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = con.FirstName;
        enq2.PropStrength__Last_Name__c =con.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Comments_by_Query_Owner__c = 'test';
        enq.PropStrength__Project__c = pro.id;
        insert enq2;

        enq2.PropStrength__Subject__c = email.subject;
        
        update enq2;

        SRemailservices ems = new SRemailservices();
        
        ems.handleInboundEmail(email,envelope);

        email.references = new List<String>{'MyForceApp.'};
            ems.handleInboundEmail(email,envelope);
		Test.startTest();
        email.references = new List<String>{'MyForceApp.'+enq2.Id+'@'};
            ems.handleInboundEmail(email,envelope);

        email.fromName = 'Deepak Chauhan';
        ems.handleInboundEmail(email,envelope);

        
        email.references = null;
        ems.handleInboundEmail(email,envelope);

        list<String> lstr = new list<String>();
        lstr.add('deepak@cloudsteer.com');
        ems.sendEmail(lstr,'Email','dsdsd','deepak@cloudsteer.com');
        

        Test.stopTest();
    } 
    
    public static testMethod void ServicesReq2() {
        
        List<string> emailToAddr = new List<string>();
        List<string> emailCcAddr = new List<string>();
        emailToAddr.add('customercaretest11@gmail.com');
        emailCcAddr.add('clubplattest@gmail.com');
        
        Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment(); 
        
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'), Blob.valueOf('test_key'));
        binaryAttachment.Body = b;
        binaryAttachments[0] =  binaryAttachment ;
        
        Messaging.InboundEmail.TextAttachment[] TextAttachments = new Messaging.InboundEmail.TextAttachment[1];  
        Messaging.InboundEmail.TextAttachment TextAttachment = new Messaging.InboundEmail.TextAttachment(); 
        
        TextAttachment.Filename = 'test.txt';
        TextAttachment.Body = 'Hello user';
        TextAttachments[0] =  TextAttachment ;
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Re:Create123456Contact';
        email.fromAddress = 'someaddress@email.com';
        email.fromName = 'ishan Sharma';
        email.plainTextBody = 'email body\n2225256325\nTitle:\ntest:';
        email.toAddresses = emailToAddr;
        email.ccAddresses = emailCcAddr;
        email.references = new List<String>{'MyForcexApp.'};
            email.binaryAttachments = binaryAttachments;
        email.TextAttachments = TextAttachments;
        
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        envelope.toAddress = 'lead.owner.new@cpeneac.cl.apex.sandbox.salesforce.com';
        envelope.fromAddress = 'user@acme.com';
        Account acc = new Account();
        acc.Name = 'Test';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='test@test.com',
                          
                          EmailEncodingKey='UTF-8', LastName='Email admin', LanguageLocaleKey='en_US',
                          
                          LocaleSidKey='en_US', ProfileId = p.Id,City = 'Meerut',
                          
                          TimeZoneSidKey='America/Los_Angeles', UserName='gggtestmldl@test.com');
        
        insert u;

        Contact con = new Contact();
        con.Accountid = acc.id;
        con.Salutation = 'Mr.';
        con.FirstName = 'ishan';
        con.LastName = 'Sharma';
        con.Email = 'someaddress12@email.com';
        con.PropStrength__Customer_Classification__c = 'Standard/External';
        con.LeadSource = 'Bank Promos';
        con.MailingStreet ='23';
        con.MailingCountry = 'IndiA';
        con.Birthdate=system.today();
        con.MailingState = '20';
        con.MobilePhone = '9978451256';
        con.MailingPostalCode ='122001';
        con.PropStrength__Account_Type__c = 'Organization';
        con.PropStrength__Customer_Code__c = 'text';
        con.PropStrength__Income_Tax_permanent_Account_No__c = 'qteyr2325t';
        con.Ownerid = u.id;
        con.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        insert con;
        PropStrength__Projects__c pro = new PropStrength__Projects__c();
        pro.Name = 'someaddress';
        pro.PropStrength__Active__c = true;
        pro.T_link_Demand_Days__c = 10.00;
        insert pro;
        List<PropStrength__Application_Booking__c> booklst = new List<PropStrength__Application_Booking__c>(); 
        PropStrength__Application_Booking__c booking = new PropStrength__Application_Booking__c();
        booking.PropStrength__Active__c = true;
        booking.PropStrength__Project__c = pro.id;
        booking.PropStrength__Applicant_Mobile__c = '124785496';
        booking.PropStrength__Applicant_Email__c = 'someaddress@email.com';
        booking.PropStrength__Primary_Customer__c = con.id;
        booklst.add(booking); 
        insert booklst;    
        
        PropStrength__Broker__c brk = new PropStrength__Broker__c();
        brk.PropStrength__Email_Id__c = 'someaddress@email.com';
        insert brk;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = con.Id;
        insert enq;
        
        PropStrength__Service_Request__c enq2  = new PropStrength__Service_Request__c();
        enq2.PropStrength__Apply_Assignment_Rule__c = true;
        enq2.PropStrength__First_Name__c = con.FirstName;
        enq2.PropStrength__Last_Name__c =con.LastName;
        enq2.PropStrength__Status__c = 'Closed';
        enq2.PropStrength__Application_Booking__c = booklst[0].id;
        enq2.PropStrength__Comments_by_Query_Owner__c = 'test';
        enq2.PropStrength__Project__c = pro.id;
        insert enq2;
        enq2.PropStrength__Subject__c = email.subject;
        
        update enq2;
        
        PropStrength__Email__c eml = new PropStrength__Email__c();
        eml.PropStrength__Service_Request__c = enq2.id;
        eml.PropStrength__Subject__c ='test email';
        eml.PropStrength__BCC_Address__c = 'test@gmail.com';
        eml.PropStrength__Message_ID__c ='';
        
        insert eml;
        SREmailServices ems = new SREmailServices();
        ems.handleInboundEmail(email,envelope);
        
        Test.startTest();
        email.references = new List<String>{'MyForceApp.'};
            ems.handleInboundEmail(email,envelope);
        email.references = new List<String>{'MyForceApp.'+enq2.Id+'@'};
            ems.handleInboundEmail(email,envelope);
        email.fromName = 'Deepak Chauhan';
        ems.handleInboundEmail(email,envelope);
        email.fromName = 'Ishan Sharma';
        ems.handleInboundEmail(email,envelope);
        
        list<String> lstr = new list<String>();
        lstr.add('deepak@cloudsteer.com');
        
        ems.sendEmail(lstr,'Email','dsdsd','deepak@cloudsteer.com');
        
        
        Test.stopTest();
    }
    
}