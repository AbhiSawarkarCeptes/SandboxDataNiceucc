/*********************************************************************
* Class Name  :   EnquiryCreationOnEmail_Test
* Description :   Test Class for the EnquiryCreationOnEmail Class
* Created Date:   01/06/2023
* Authored By :   CloudSteer Technology Pte Ltd
* -------------------------------------------------------------------
* Version History : 
Created By       :   Deepak Sharma
Last Modified By :   Deepak Sharma 01/06/2023
*********************************************************************/
@istest
public class EnquiryCreationOnEmail_Test 
{
    static testMethod void myUnitTest() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Test Job Applicant';
        email.fromname = 'FirstName LastName';
        email.fromAddress = 'grg1@gmail.com';
        email.plainTextBody = 'Test';
        env.fromAddress = 'grg1@gmail.com';
        env.toAddress = 'grg2@yopmail.com';
        
        Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        email1.subject = 'Test Job Applicant';
        email1.fromname = 'FirstName LastName';
        email1.fromAddress = 'grg2@gmail.com';
        email1.plainTextBody = 'Test';
        env1.fromAddress = 'grg1@gmail.com';
        env1.toAddress = 'grg2@yopmail.com';
        
        Test.startTest();
            EnquiryCreationOnEmail emailProcess = new EnquiryCreationOnEmail ();
            emailProcess.handleInboundEmail(email, env);
            Contact cont = new Contact(LastName = 'grg1', Email = 'grg2@gmail.com');
            insert cont;
            emailProcess.handleInboundEmail(email1, env1);
        Test.stopTest();
    }
}