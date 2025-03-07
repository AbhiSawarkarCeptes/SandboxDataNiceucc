public class CopyAppttoBooking{
    public static void updateBooking(Applicant_Details__c[] lstApp){
        List<Applicant_Details__c> applicantList = new List<Applicant_Details__c>();
        Map<Id, Applicant_Details__c> ApplicantMap = new Map<Id, Applicant_Details__c>();
        List<Applicant_Details__c> AppList;
        
        for(Applicant_Details__c App : lstApp){
             if (App.Booking__c != null){
                  ApplicantMap.put(App.Booking__c,App);
              }
        }
        AppList = [SELECT Id, Booking__c,Applicant_Number__c,Email_Address__c,Mobile_Number__c,Name,Salutation__c 
                   FROM Applicant_Details__c WHERE Booking__c IN: ApplicantMap.keySet()];
        If(AppList.size() > 0){
            if(AppList[0].Applicant_Number__c == 'Primary Applicant'){
                Booking__c objBooking = new Booking__c();
                objBooking.Id = AppList[0].Booking__c;
                objBooking.Primary_Applicant_Email__c = AppList[0].Email_Address__c;
                objBooking.PrimaryMobileNumber__c = AppList[0].Mobile_Number__c;
                if(string.isNotBlank(AppList[0].Salutation__c)){
                    objBooking.Primary_Applicant_Name__c = AppList[0].Salutation__c + '. ';
                }else{
                    objBooking.Primary_Applicant_Name__c = '';
                }    
                objBooking.Primary_Applicant_Name__c = objBooking.Primary_Applicant_Name__c + AppList[0].Name;
                objBooking.Applicant_Details__c = ApplicantMap.get(AppList[0].Booking__c).Id;
                update objBooking;
            }
        }
    }
}