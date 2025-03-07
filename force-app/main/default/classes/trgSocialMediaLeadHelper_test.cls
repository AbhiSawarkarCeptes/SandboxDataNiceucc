@isTest
public class trgSocialMediaLeadHelper_test {
    
    @TestSetup
    static void testPrepareLeadfromSML() {
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        User u = TestDataFactorySobha.createUser(null);
        insert u;
        Contact cont = TestDataFactorySobha.createContact(null);
        cont.email = 'test1@gmail.com';
        insert cont;
        List<Social_media_lead__c> smlList = new list<Social_media_lead__c>();
        Social_media_lead__c sml = new Social_media_lead__c();
        sml.Form_ID__c  = '123046341703539';
        sml.Page_ID__c  = '4534623232322';
        sml.AdSet_Id__c ='3253242432423';
        sml.Lead_ID__c  = '4523188';
        sml.Source__c   = 'Facebook';
        sml.Email__c    = 'test1@gmail.com';
        sml.Full_Name__c = 'tesstfb';
        sml.processed__c = false;
        sml.Country__c = 'AE';
        sml.Ad_ID__c = '111111';
        sml.Ad_Name__c = 'FaceBookAd';
        sml.AdSet_Name__c = 'FaceBookAddSet';
        sml.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml.Platform_ig__c = 'Platform';
        sml.Page_Name__c = 'pageName';
        sml.Form_Name__c = 'newForm';
        sml.Full_Name__c = 'Full Name';
        sml.Phone_Number__c = '12345678';
        sml.Mobile_Number__c = '330613272013';
        sml.Mobile_Number_No_Country_Code__c = '0613272013';
        sml.Recording_URL__c = 'URL';
        insert sml;   
        trgSocialMediaLeadHelper.PrepareLeadfromSML(new list<Social_media_lead__c>{sml}, null);
        List<Social_media_lead__c> sml1List = new list<Social_media_lead__c>();
        Social_media_lead__c sml1 = new Social_media_lead__c();
        sml1.Form_ID__c  = '123046341703539';
        sml1.Page_ID__c  = '4534623232322';
        sml1.AdSet_Id__c ='3253242432423';
        sml1.Lead_ID__c  = '4523188';
        sml1.Source__c   = 'Facebook';
        sml1.Email__c    = 'test@gmail.com';
        sml1.Full_Name__c = 'tesstfb';
        sml1.processed__c = false;
        sml1.Country__c = 'AE';
        sml1.Ad_ID__c = '111111';
        sml1.Ad_Name__c = 'FaceBookAd';
        sml1.AdSet_Name__c = 'FaceBookAddSet';
        sml1.Lead_Created_Time__c = datetime.newInstance(2023, 3, 15, 12, 30, 0);
        sml1.Platform_ig__c = 'Platform';
        sml1.Page_Name__c = 'pageName';
        sml1.Form_Name__c = 'newForm';
        sml1.Full_Name__c = 'Full Name';
        sml1.Phone_Number__c = '12345678';
        sml1.Mobile_Number__c = '330613272013';
        sml1.Mobile_Number_No_Country_Code__c = '0613272013';
        sml1.Recording_URL__c = 'URL';
        insert sml1; 
        trgSocialMediaLeadHelper.PrepareLeadfromSML(new list<Social_media_lead__c>{sml1}, null);
    }
    
    @isTest
    public static void testMethod1(){
        
    }
}