public class N_ScreenPopController{
    
    public static Boolean skipDuplicateCheck = false;
    public string mobilePhone {get;set;}
    public string did {get;set;}
    public string countrycode{get;set;}
        
    public N_ScreenPopController(){
        
      //  Map<String,String> allPageParams = ApexPages.currentPage().getParameters();
      // for(string st : allPageParams.keySet()){ 
      // }
        
        if(ApexPages.currentPage().getParameters().containsKey('phone'))  {     
            mobilePhone = ApexPages.currentPage().getParameters().get('phone'); 
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('countrycode'))  {     
            countrycode = ApexPages.currentPage().getParameters().get('countrycode'); 
            system.debug('countrycode >>>>>>>>> '+countrycode);
        }
        
        if(ApexPages.currentPage().getParameters().get('did') != null)  {     
            did = ApexPages.currentPage().getParameters().get('did'); 
            system.debug('did'+did);
        }      
    }
    
    public pageReference openScreen(){
        
        PageReference pageRef;
        List <Lead> leadList;
        List <Account> accList;
      //  List <Opportunity> optyList;
     //   List <Case> caseList;
     //   string countryCode;
        string country;
        string formattedphone;
        system.debug('mobilePhone'+mobilePhone);
        if(mobilePhone.startsWith('0')){
            mobilePhone = mobilePhone.substringAfter('0'); 
        }
        if(String.isNotBlank(mobilePhone) && mobilePhone != null) {
            formattedphone = mobilePhone;
            // for india, usa, uk the number of digits in phone # is 10. So if the length is greater than 10
            // then take the last 10 as mobile and whatever is remaining in the first digits after stripping off
            // the 10 digits are taken as countryCode. Then we compare them with potential country code formats that we know of
            // for US, UK,  India and then set the country accordingly.
            
            Map<String,String> cDetails = new Map<String,String>();
            if(String.isNotBlank(mobilePhone ) && String.isNotBlank(mobilePhone )){
                system.debug('inside mobile is not blank');
                if(countryCode != null){
                cDetails = FormatMobileNumber.getCountryByCountryCode(countryCode );}
                else{
                  countryCode = '+971';                      
                }
                if(cDetails.size() > 0 && cDetails != null){
                       country = cDetails.get('country');
                        system.debug('country >>>>>>>>>>'+country);
                       system.debug('countryCode>>>>>>>>>>'+countryCode);
                }
            } 
                   
            string mobilePhoneQueryVar = '%'+mobilePhone+'%';
            leadList = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, Project__c, 
                        RDS_Country__c , RDS_Country_Code__c FROM Lead WHERE 
                        (MobilePhone LIKE :mobilePhoneQueryVar OR Phone LIKE :mobilePhoneQueryVar) AND isConverted= false];
            
            accList = [SELECT Id, Name, Country__c, Country_Code__c, PersonMobilePhone 
                       FROM Account WHERE (PersonMobilePhone LIKE :mobilePhoneQueryVar OR Phone LIKE :mobilePhoneQueryVar) 
                       AND isPersonAccount = true];
            
            ///////////// For Lead    
            if(leadList != null && leadList.size() == 1 && !leadList.isEmpty()) {                  
                pageRef = new PageReference('/' + leadList[0].Id);                           
            } 
            /////////// For Account 
            else if (accList != null && accList.size() == 1){
                pageRef = new PageReference('/' + accList[0].Id);
            } 
            else {
                string campaignId;
                String LeadSource, LeadSubSource, PrimaryCampaignCode, CampaignName, Project;
                List<Campaign> CampaignList = new List<Campaign>();
               // List<Project__c> project1List = new List<Project__c>();
                if(did != null){
                    CampaignList = [SELECT Id, Name, Type, Sub_Source__c, Primary_Project__c, 
                                    Digital_Maketing_Campaign_Code__c from Campaign where 
                                    Digital_Maketing_Campaign_Code__c = :did and IsActive = true];
                    system.debug('CampaignList'+CampaignList);
                }
                if (CampaignList.size() > 0){      
                    LeadSource = CampaignList[0].Type;       
                    LeadSubSource = CampaignList[0].Sub_Source__c;
                    CampaignName = CampaignList[0].Id;
                    PrimaryCampaignCode = CampaignList[0].Digital_Maketing_Campaign_Code__c;
                    if(CampaignList[0].Primary_Project__c != null){
                        Project = CampaignList[0].Primary_Project__c;
                    }
                }
                
                Lead l = new Lead(LastName = 'CTI Lead', MobilePhone = mobilePhone , 
                                  RDS_Country__c = Country, 
                                  Presales_Agent__c	= UserInfo.getUserId(),
                                  RDS_Country_Code__c = countryCode,
                                  LeadSource = LeadSource,      
                                  Lead_Sub_Source__c = LeadSubSource,
                                  Lead_Source__c = LeadSource,                                 
                                  Project__c = Project,
                               //   Is_CTI_Lead__c = True,
                                  Campaign_Code__c = PrimaryCampaignCode,
                                 // Primary_Campaign_Code__c = PrimaryCampaignCode,
                                  Is_serviced__c = true
                                 );     
                try {
                    skipDuplicateCheck = (MobilePhone == Label.Waybeo_Mobile) ? TRUE : FALSE ;
                    insert l;
                    skipDuplicateCheck = FALSE;
                    pageRef = new PageReference('/' + l.Id);
                } 
                catch(Exception ex){
                    Error_Log__c trackErrorRec = new Error_Log__c(Class__c = 'N_ScreenPopController--Error',Message__c = ex.getmessage() + '--' + JSON.Serialize(l));
                    database.insert(trackErrorRec, false);
                }                     
            }
        }  
        return pageRef;      
    }   
}