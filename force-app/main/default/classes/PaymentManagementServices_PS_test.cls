@isTest
public class PaymentManagementServices_PS_test {
	@isTest
    static void testGetCustomerDetails() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        PaymentManagementServices_PS.getCustomerOutstandingChargeWise(acc.Id);        
        PaymentManagementServices_PS.demandFieldLocationWrapper testWrap=new PaymentManagementServices_PS.demandFieldLocationWrapper(null,'','',1); 
         PaymentManagementServices_PS.demandFieldLocationWrapper testWrap1=new PaymentManagementServices_PS.demandFieldLocationWrapper(null,'','','','','','','','','','','','','','','',1); 
    }
}