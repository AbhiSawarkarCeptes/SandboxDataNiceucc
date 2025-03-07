@isTest
public class SendBirthdayWishBatchTest {
	@testSetup
    public static void dataSetup() {
        Applicant_Details__c a1 = new Applicant_Details__c();
        a1.Name = 'First Man';
        a1.Applicant_Number__c = 'Primary Applicant';
        a1.DOB__c = system.today();
        a1.Permanent_Address__c = 'Pike Street, New World, 45000';
        a1.Country__c = 'India';
        a1.Mobile_Number__c = '909090903';
        a1.Email_Address__c = 'newman@justnow3.com';
        a1.Nationality__c = 'Indian';
        a1.Type_Of_Applicant__c  = 'Individual Buyer';
        a1.Subtype_Of_Applicant__c = 'Indian National';
        a1.Address_Proof__c = true;
        a1.Address_Proof_Document__c = 'xyz';
        a1.Address_Proof_Number__c = 'pqr';
        a1.One_Passport_Size_Color_Photograph__c = true;
      //  a1.Dataload_Identifier__c = 'Test';
        insert a1;
    }
    @isTest public static void test_SendBirthdayWishBatch(){
        SendBirthdayWishBatch ob = new SendBirthdayWishBatch();
        ob.execute(null);
    }
}