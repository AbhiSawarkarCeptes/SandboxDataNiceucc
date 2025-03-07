@isTest public class LeadMobilePhoneUpdateControllerTest {
	@isTest public static void testMobileNumberUpdate_Positive() {
        lead l = new lead();
        l.LastName = 'TestRecord';
        l.Email = 'test@test.com';
        l.MobilePhone = '971502083945';
        l.Phone = '971502083945';
        l.Presales_Agent__c = UserInfo.getUserId();
        l.ownerID = UserInfo.getUserId();
        l.RDS_Country_Code__c = '+9710';
        l.MobilePhone = '09999999999';
        insert l;
        Test.startTest();
        LeadMobilePhoneUpdateController.updateLeadMobile(l.Id);
        Test.stopTest();
    }
}