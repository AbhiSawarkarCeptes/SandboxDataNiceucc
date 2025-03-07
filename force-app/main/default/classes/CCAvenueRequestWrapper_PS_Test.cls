@isTest
public class CCAvenueRequestWrapper_PS_Test {
    @isTest
    Public  static void CCAvenueRequestWrapperTest(){
     
        String jsonString = '[{' +
            '"customer_name": "Test",' +
            '"bill_delivery_type": "email",' +
            '"customer_mobile_no": 1234567890,' +
            '"customer_email_id": "test@example.com",' +
            '"customer_email_subject": "Invoice Payment",' +
            '"invoice_description": "Monthly subscription invoice",' +
            '"currency_Z": "USD",' +
            '"valid_for": 30,' +
            '"valid_type": "days",' +
            '"amount": 99.99,' +
            '"merchant_reference_no": 12345,' +
            '"terms_and_conditions": "Standard terms and conditions apply"' +
        '}]';
        
        CCAvenueRequestWrapper_PS wrap = new CCAvenueRequestWrapper_PS(System.JSON.createParser(jsonString));
        CCAvenueRequestWrapper_PS wrap2 = new CCAvenueRequestWrapper_PS();
        CCAvenueRequestWrapper_PS.getencRequest('Test', 'merId', 'email', '1234567890', 'test@example.com', 'USD', 'days' , 30 , 99.99,'12345');
        
        CCAvenueRequestWrapper_PS.CCAvenueStatusRequestWrapper expectedResult = new CCAvenueRequestWrapper_PS.CCAvenueStatusRequestWrapper();
    }
}