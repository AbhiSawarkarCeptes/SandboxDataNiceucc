@isTest 
public class BRCTest {
    static String brcSerialized = '{"Source_Currency_Code__c":"AED","Credit_Amount__c":200000.00000,"PR_Mode__c":"Cheque","Instrument_Number__c":"16","Account_Identifier__c":"1014691785001","Description__c":"OUTWARD CLEARING 24162026024162006272 - DEFAULT - ~1089891976 CHQ. NO: 000016600320180 Value DATE, 11/06/2024 - AE0108030","GL_Date__c":"2024-07-11","Realized_Currency_Code__c":"AED","BRC_Mode__c":"Cheque","Count_of_Allocated_PRs__c":2,"Allocated_Amount__c":160000.00,"Unallocated_Amount__c":40000.00,"CurrencyIsoCode":"AED"}';
    static String amSerialized = '{"Name":"ENBD-CA-AED-SLLC-1014691785001","Account_Number__c":"1014691785001","Type__c":"Others","Is_Foreign_Currency__c":false,"Xpedeon_Account_Number__c":"1014691785001","CurrencyIsoCode":"AED"}';
    static Payment_Request__c pr;
    static Account_Master__c amPR;
    
    static void makeData(){
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        prw.Email__c = 'testclass@gmail.com';
        prw.Is_Make_Payment_Clicked__c = true;
        insert prw;
        
        amPR = (Account_Master__c)JSON.deserialize(amSerialized,Account_Master__c.class); 
        insert amPR;
        //Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();
        //insert prw;
        MagnatiPaymentController.setLinkClicked(prw.Id);
        prw = [SELECT Id, Is_Make_Payment_Clicked__c FROM Payment_Request_Wrapper__c WHERE Id = :prw.Id];
        System.assertEquals(prw.Is_Make_Payment_Clicked__c, true, 'setLinkClicked assert failed');
        
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
            
            
            pr = new Payment_Request__c();
            pr.name__c = 'yamini';
            pr.Booking__c=b.id;
            pr.Email__c = 'yamini.jakka@ceptes.com';
            pr.Mobile_Number__c='9550987889';
            pr.Emirates_Id_Passport_Number__c='12xgy';
            pr.Mode__c = 'Cheque';
            pr.Status__c='Approved';
            pr.Amount__c = 123;
            pr.Unit__c = unitId;
            pr.Approved_Date_and_Time__c=System.today();
            pr.From_Booking__c = true;
        	pr.Account_Master__c = amPR.Id;
            insert pr;
            
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
    
    @isTest static void test1(){
        makeData();
        Bank_Receipt__c brc = (Bank_Receipt__c)JSON.deserialize(brcSerialized,Bank_Receipt__c.class);
        insert brc;
    }
    
    @isTest static void test2(){
        makeData();
        pr.Status__c = 'Approved';
        pr.Account_Master__c = amPR.Id;
        update pr;
        Bank_Receipt__c brc = (Bank_Receipt__c)JSON.deserialize(brcSerialized,Bank_Receipt__c.class);
        insert brc;
     	BRC_PR_Allocation__c bpa = new BRC_PR_Allocation__c(Payment_Request__c = pr.Id,Bank_Receipt__c = brc.Id);  
        insert bpa;
        try{
            update bpa;
        }catch(Exception ex){}
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Transaction":{"ResponseCode":"0","TransactionID":"123","PaymentPortal":"https://example.com","Amount":{"value":""}}}');
            return res;
        }
    }
}