@isTest
public class MobileAppUsercreationQueuableTest {
         @testSetup
    static void setupTestData() {
        Mobile_TestUtil.createBooking();
    }
    
	@isTest
    static void testMethod1() {
         List<Applicant_Details__c> appDList = new List<Applicant_Details__c>();
        for(Integer i=0; i<5; i++){
            Applicant_Details__c app = new Applicant_Details__c(Name = 'Test Name'+i, Mobile_Number__c='34343434'+i, Email_Address__c='testno'+i+'@test.com');
            appDList.add(app);
        }
        test.startTest();
        insert appDList;
        test.stopTest();
    }
    

}