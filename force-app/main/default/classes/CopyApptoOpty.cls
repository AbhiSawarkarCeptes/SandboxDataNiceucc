public class CopyApptoOpty{
  
   public static void updateOPTY(Applicant_Details__c[] lstApp){
        set<id> Bookids = new set<id>();
        
        for(Applicant_Details__c App : lstApp){
            Bookids.add(App.Booking__c);
        }
        List <Opportunity> OppList = new List<Opportunity>();
        List <Applicant_Details__c> ListApp = [Select id,Salutation__c,Name,Applicant_Number__c,Email_Address__c,Mailing_Address__c,
                                               Permanent_Address__c,Pincode__c,City__c,Country__c,Mailing_Country__c,Mailing_City__c,
                                               Mailing_State__c,Mailing_Pincode__c, Booking__r.OwnerId,
                                               State__c,PancardNo__c,Booking__c,Booking__r.Opportunity__c, Mobile_Number__c 
                                               from Applicant_Details__c Where Booking__c In : Bookids order by createdDate desc];
        
        Map<Id,List<Applicant_Details__c>> MapListApp = new Map<Id,List<Applicant_Details__c>>();
        
        for(Applicant_Details__c  App: ListApp){
           if(MapListApp.containsKey(App.Booking__c)) {
               if(App.Booking__c != null){
                    MapListApp.get(App.Booking__c).add(App);
               }
            } else {
                List<Applicant_Details__c> tempAppList = new List<Applicant_Details__c>();
                tempAppList.add(App);
                if(App.Booking__c != null){
                    MapListApp.put(App.Booking__c, tempAppList);
                }
            }
        }
        System.debug('MapListApp' +MapListApp);
        for(List<Applicant_Details__c> Ap : MapListApp.values()){
            //String FlatApplicants = '';
            String AppName = '';
            String AppNames= '' ;
            String PrimaryPancard ='';
            String OthersPancard ='';
            String AppEmail = '';
            String AppOthersEmails ='' ;
            String PermanentAddress ='';
            String MailingAddress ='';
            String MobileNumber='';
            string AppOtherMobile ='';
            
            Opportunity  OptyObj = new Opportunity ();
            for(Applicant_Details__c A : Ap){
                if(A.Applicant_Number__c == 'Primary Applicant'){
                    System.debug('Primary Applicant' +A.Name);
                    AppName = A.Salutation__c + '. ' + A.Name ;
                    system.debug('PrimaryAppName : '+ AppName);
                    PrimaryPancard  = A.PancardNo__c;
                    AppEmail = A.Email_Address__c;
                    MobileNumber = A.Mobile_Number__c;
             //// Added by Neha on 26/3/19 to concatenate Permanent Address and Mailing Address     
                    if(A.Permanent_Address__c != null && String.isNotBlank(A.Permanent_Address__c)){
                        PermanentAddress += A.Permanent_Address__c;
                        if((A.City__c != null && String.isNotBlank(A.City__c)) || (A.State__c != null && String.isNotBlank(A.State__c)) || (A.Country__c != null && String.isNotBlank(A.Country__c))) {
                            PermanentAddress += ', ';
                        }
                        else{
                            
                        }
                    }
                    if(A.City__c != null && String.isNotBlank(A.City__c)){
                        PermanentAddress += A.City__c;
                        if(A.State__c != null && String.isNotBlank(A.State__c) || (A.Country__c != null && String.isNotBlank(A.Country__c))){
                            PermanentAddress += ', ';
                        }
                            else{
                            
                        }
                    }
                    if(A.State__c != null && String.isNotBlank(A.State__c)){
                        PermanentAddress += A.State__c;
                        if(A.Country__c != null && String.isNotBlank(A.Country__c)){
                            PermanentAddress += ', ';
                        }
                            else{
                            
                        }
                    }
                    if(A.Country__c != null && String.isNotBlank(A.Country__c)){
                        PermanentAddress += A.Country__c;
                        if(A.Pincode__c != null){
                            PermanentAddress += ' - ' + A.Pincode__c;
                        }
                            else{
                            
                        }
                    }
                     
                    if(A.Mailing_Address__c != null && String.isNotBlank(A.Mailing_Address__c)){
                        MailingAddress += A.Mailing_Address__c;
                        if((A.Mailing_City__c != null && String.isNotBlank(A.Mailing_City__c)) || (A.Mailing_State__c != null && String.isNotBlank(A.Mailing_State__c)) || (A.Mailing_Country__c != null && String.isNotBlank(A.Mailing_Country__c))) {
                            MailingAddress += ', ';
                        }
                            else{
                            
                        }
                    }
                    if(A.Mailing_City__c != null && String.isNotBlank(A.Mailing_City__c)){
                        MailingAddress += A.Mailing_City__c;
                        if(A.Mailing_State__c != null && String.isNotBlank(A.Mailing_State__c) || (A.Mailing_Country__c != null && String.isNotBlank(A.Mailing_Country__c))){
                            MailingAddress += ', ';
                        } 
                            else{
                            
                        }
                    }
                    if(A.Mailing_State__c != null && String.isNotBlank(A.Mailing_State__c)){
                        MailingAddress += A.Mailing_State__c;
                        if(A.Mailing_Country__c != null && String.isNotBlank(A.Mailing_Country__c)){
                            MailingAddress += ', ';
                        } 
                            else{
                            
                        }
                    }
                    if(A.Mailing_Country__c != null && String.isNotBlank(A.Mailing_Country__c)){
                        MailingAddress += A.Mailing_Country__c;
                        if(A.Mailing_Pincode__c != null){
                            MailingAddress += ' - ' + A.Mailing_Pincode__c;
                        }   
                            else{
                            
                        }
                    }                    
                }
                else{
                     System.debug('Other Applicants : ' + A.Name);
                     AppNames = A.Salutation__c + '. '+ A.Name +' &'+' '+ AppNames ;
                     system.debug('Other AppNames : '+ AppName);
                     OthersPancard = A.PancardNo__c +','+ OthersPancard;
                     AppOthersEmails = A.Email_Address__c + ','+ AppOthersEmails ;
                     AppOtherMobile = A.Mobile_Number__c +','+AppOtherMobile ;
               }
               if(A.Booking__r.Opportunity__c != null){
                   OptyObj.id = A.Booking__r.Opportunity__c; 
                   System.debug('OptyObj id' +OptyObj.id);                  
               }
               if(A.Booking__c != null){
               // Putting the booking id on opty.
               OptyObj.Booking__c = A.Booking__c;
               //OptyObj.Relationship_Manager__c = A.Booking__r.OwnerId;
              } 
            }
           System.debug('AppName ' +AppName);
           System.debug('AppNamessss ' +AppNames ); 
           // remove the last character only if its a comma.
            if(AppNames.length() > 0 && AppNames.substring(AppNames.length() -3).equals(' & '))
            AppNames = AppNames.substring(0,AppNames.length() -3);

            if(OthersPancard.length() > 0 && OthersPancard.substring(OthersPancard.length() -1).equals(','))
            OthersPancard = OthersPancard.substring(0,OthersPancard.length() -1);
            
            if(AppOthersEmails.length() > 0 && AppOthersEmails.substring(AppOthersEmails.length() -1).equals(','))
            AppOthersEmails = AppOthersEmails.substring(0,AppOthersEmails.length() -1);
            
            if(AppOtherMobile .length() > 0 && AppOtherMobile .substring(AppOtherMobile.length() -1).equals(','))
            AppOtherMobile  = AppOtherMobile.substring(0,AppOtherMobile.length() -1);
            
           OptyObj.Primary_Name__c = AppName ;
           OptyObj.Other_Applicants_Name__c = AppNames ;
           if(String.isNotBlank(PrimaryPancard))
            OptyObj.Primary_pancard__c = PrimaryPancard ;
           if(String.isNotBlank(OthersPancard))
            OptyObj.Other_Applicants_Pancard__c = OthersPancard ;
           OptyObj.Primary_Email__c = AppEmail;
           OptyObj.Other_Applicants_Email__c = AppOthersEmails ;
           OptyObj.Permanent_Address__c = PermanentAddress  ;
           OptyObj.Mailing_Address__c = MailingAddress  ;
           OptyObj.Primary_Phone__c = MobileNumber; 
           optyObj.Other_Applicant_Mobile_Number__c = AppOtherMobile ;                     
           OppList.add(OptyObj);
          }
         
            if(OppList.size() >0) {
                update OppList;
            }
        }   
}