Public Class CustomerDocumentsControllerDubai{

public string optyId{get;set;}
public List<opportunity> optyList {get;set;}
public List<Booking__c> bookList{get;set;}
public List<Applicant_Details__c> applicantList{get;set;}
public List<attachment> attachmentList{get;set;}
public map <id,list<string>> documentMap{get;set;}
public List<MainWrapper> mainWrapperListforApp1{get;set;}
public List<MainWrapper> mainWrapperListforApp2{get;set;}
public List<MainWrapper> mainWrapperListforApp3{get;set;}
public List<MainWrapper> mainWrapperListforApp4{get;set;}
public List<MainWrapper> mainWrapperListforApp5{get;set;}
Public String style{get;set;}
Public String style2{get;set;}
Public String selectedApplicant{get;set;}
public List < SelectOption > optns{get;set;}
Public String typeOfApplicant2 {get;set;}
Public String residentialStatus2 {get;set;}
public List<string> documentListForUpload {get;set;}
public List < SelectOption > optnsDocName{get;set;}
Public String selectedDocument{get;set;}
public transient Blob blobFile{get;set;}
public String contentType {get; set;}
public CustomerDocumentsControllerDubai(){

  typeOfApplicant2 = '';
  residentialStatus2 = '';
  style = 'display:none;';
  style2 = 'display:inline;';
  optyList = new list<opportunity>();
  bookList = new list<Booking__c>();          
    
  if (ApexPages.currentPage().getParameters().containsKey('optyId') != null) {
        optyId = ApexPages.currentPage().getParameters().get('optyId');
  }  
       
  if(!String.isBlank(optyId)){  
          optyList = [select id,name from opportunity where id =: optyId];
  }
  if(optyList.size() > 0){
       bookList = [select id,name,Booking_Date__c,Project__c,Unit__c,Opportunity__c from Booking__c where Opportunity__c =: optyList[0].id];
  }
  if(bookList.size() > 0){       
            getDetails();      
  }  
  else{      
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'No Booking available for this Customer');
         ApexPages.addMessage(myMsg);           
   }         
}

public void getDetails(){
      applicantList = new list<Applicant_Details__c>();
      attachmentList = new list<attachment>();
      mainWrapperListforApp1 = new List<MainWrapper>();
      mainWrapperListforApp2 = new List<MainWrapper>();
      mainWrapperListforApp3 = new List<MainWrapper>();
      mainWrapperListforApp4 = new List<MainWrapper>();
      mainWrapperListforApp5 = new List<MainWrapper>();
      documentListForUpload = new list<string>();
      
       applicantList = [SELECT id, name, Opportunity__c, Salutation__c, Booking__c, Type_Of_Applicant__c, Applicant_Number__c, Subtype_Of_Applicant__c,
                        Emirates_ID__c, National_ID__c, Passport_Copy__c, Power_of_Attorney__c, Non_residency_Letter__c, Visa_Copy__c,
                        Memoradum_Articles_of_Association__c, Registration_License__c, Certificate_of_Incorporation__c, Others__c,
                        Certificate_of_Good_Standing_and_Certifi__c, Passport_Copy_of_Authorized_Signatory__c 
                        FROM Applicant_Details__c where Booking__c =: bookList[0].id];
        
          map <id,Applicant_Details__c> appMap = new map<id,Applicant_Details__c>();
          documentMap = new map <id,list<string>>();
          Map <id,list<string>> allDocumentMap = new map <id,list<string>>();
          List<string> documentList = new list<string>();
          
          if(applicantList.size() > 0){
            set<id> applicantIds = new set<id>();
                for(Applicant_Details__c a : applicantList){
                List<string> documentName = new List<string>();
                   appMap.put(a.id,a);
                   applicantIds.add(a.id);
                   if(a.Passport_Copy__c)
                       documentName.add('Passport Copy');
                   if(a.Emirates_ID__c)
                       documentName.add('Emirates Id');
                   if(a.Power_of_Attorney__c)
                       documentName.add('Power of Attorney');
                   if(a.National_ID__c)
                       documentName.add('National ID');     
                   if(a.Non_residency_Letter__c)
                       documentName.add('Non-residency Letter');
                   if(a.Visa_Copy__c)
                       documentName.add('Visa Copy');
                   if(a.Memoradum_Articles_of_Association__c)
                       documentName.add('Memoradum & Articles of Association');        
                   if(a.Registration_License__c)
                       documentName.add('Registration License');   
                   if(a.Certificate_of_Incorporation__c)
                       documentName.add('Certificate of Incorporation');
                   if(a.Certificate_of_Good_Standing_and_Certifi__c)
                       documentName.add('Certificate of Good Standing and Certificate of Incumbency');
                   if(a.Passport_Copy_of_Authorized_Signatory__c)
                       documentName.add('Passport Copy of Authorized Signatory');    
                   if(a.Others__c)
                       documentName.add('Others');    
                               
                   if(documentName.size() > 0)
                       allDocumentMap.put(a.id,documentName);    
                }                   
                attachmentList = [select id,name,parentId,ContentType,body from attachment where parentId IN: applicantIds];
          }
          if(appMap.size() > 0 && attachmentList.size() > 0){               
               for(id key : appMap.keyset()){
                   for(attachment a: attachmentList){
                       string dName;
                       if(key == a.parentId){
                           if(!String.isBlank(a.name)){
                              dName = a.name;
                           }
                           if(!String.isBlank(dName))
                           documentList.add(dName);
                       }
                   } 
                    documentMap.put(key,documentList);
               }
          }
          
               if(applicantList.size() > 0){
                     for(Applicant_Details__c a : applicantList){                       
                          MainWrapper mw = new MainWrapper();
                          mw.applicantName = a.Salutation__c +' '+a.Name;
                          mw.applicantType = a.Applicant_Number__c;
                          mw.typeOfApplicant = a.Type_Of_Applicant__c;
                          mw.residentialStatus = a.Subtype_Of_Applicant__c;
                          mw.applicantId = a.id;
                          if(documentMap.size() > 0){
                             if(documentMap.containsKey(a.id)){
                                mw.documentList = documentMap.get(a.id);
                             }
                          }   
                          if(allDocumentMap.size() > 0){
                             if(allDocumentMap.containsKey(a.id))
                               mw.allDocumentList = allDocumentMap.get(a.id);
                          }                      
                          if(mw.allDocumentList.size() > 0){ 
                             for(string ms : mw.allDocumentList){
                              if(mw.documentList.size() > 0){
                                  for(string s : mw.documentList){  
                                        if(ms.contains(s)){   
                                            mw.allDocumentMapNew.put(ms,true);
                                        }
                                        else{
                                             if(mw.allDocumentMapNew.size() > 0){
                                                if(!mw.allDocumentMapNew.containskey(ms)){
                                                    mw.allDocumentMapNew.put(ms,false);
                                                  }                                                  
                                             }
                                             else{
                                                  mw.allDocumentMapNew.put(ms,false);
                                             }                                             
                                        }                                       
                                  }
                                }  
                                  else{
                                        mw.allDocumentMapNew.put(ms,false);
                                  }
                              }                             
                          }    
                          
                          if(mw.allDocumentMapNew.size() > 0){
                               for(string str : mw.allDocumentMapNew.keySet()){
                                   if(mw.allDocumentMapNew.get(str) == false){
                                       mw.noDocumentsUploadList.add(str);
                                   }                                   
                               }                           
                          }                       
                          if(a.Applicant_Number__c == 'Primary Applicant'){
                              mainWrapperListforApp1.add(mw);
                          }
                          if(a.Applicant_Number__c == 'Second Applicant'){
                              mainWrapperListforApp2.add(mw);
                          }
                          if(a.Applicant_Number__c == 'Third Applicant'){
                              mainWrapperListforApp3.add(mw);
                          }
                          if(a.Applicant_Number__c == 'Fourth Applicant'){
                              mainWrapperListforApp4.add(mw);
                          }
                          if(a.Applicant_Number__c == 'Fifth Applicant'){
                              mainWrapperListforApp5.add(mw);
                          }       
                     }                          
                }
}

public PageReference Cancel(){
   system.debug('inside cancel method::: ');
   string urlId;   
   if(optyList.size() > 0)
     urlId = optyList[0].id;
    PageReference newpage = new Pagereference('/'+urlId);
    return newpage;
}

public PageReference displayHideMethod(){
   style = 'display:inline;';
   style2 = 'display:none;';  
   return null;
}

public PageReference showMethod(){

       if(!string.isBlank(typeOfApplicant2)){
          typeOfApplicant2 = '';
       }
       if(!string.isBlank(residentialStatus2)){
          residentialStatus2 = '';
       }
       if(documentListForUpload.size() > 0){
          documentListForUpload.clear();
          optnsDocName.clear();
       }
        style = 'display:inline;';
        style2 = 'display:none;';
        optns = new List < Selectoption > ();
        optns.add(new SelectOption('', 'Select an Applicant'));
         if(applicantList.size() >0){
                for (Applicant_Details__c obj: applicantList) {
                    optns.add(new SelectOption(obj.id, obj.Applicant_Number__c));
                }            
            }else {
                system.debug('No quotations');               
            }
          if(!String.isBlank(selectedApplicant)){
              if(applicantList.size() >0){ 
                  for(Applicant_Details__c obj: applicantList){
                       if(selectedApplicant == obj.id){
                          typeOfApplicant2 = obj.Type_Of_Applicant__c;
                          residentialStatus2 = obj.Subtype_Of_Applicant__c;                      
                       }
                  }
              }                          
                 if(mainWrapperListforApp1.size() > 0){
                     for(MainWrapper mp : mainWrapperListforApp1){
                       if(mp.applicantId == selectedApplicant){
                         if(mp.noDocumentsUploadList.size() > 0){
                            for(String name : mp.noDocumentsUploadList){                           
                               documentListForUpload.add(name);                                                      
                            }
                         }
                       }  
                     }
                 }                
                  if(mainWrapperListforApp2.size() > 0){
                     for(MainWrapper mp : mainWrapperListforApp2){
                       if(mp.applicantId == selectedApplicant){
                         if(mp.noDocumentsUploadList.size() > 0){
                            for(String name : mp.noDocumentsUploadList){                           
                               documentListForUpload.add(name);                                                      
                            }
                         }
                       }  
                     }
                 }                 
                  if(mainWrapperListforApp3.size() > 0){
                     for(MainWrapper mp : mainWrapperListforApp3){
                       if(mp.applicantId == selectedApplicant){
                         if(mp.noDocumentsUploadList.size() > 0){
                            for(String name : mp.noDocumentsUploadList){                           
                               documentListForUpload.add(name);                                                      
                            }
                         }
                       }  
                     }
                 }                 
                  if(mainWrapperListforApp4.size() > 0){
                     for(MainWrapper mp : mainWrapperListforApp4){
                       if(mp.applicantId == selectedApplicant){
                         if(mp.noDocumentsUploadList.size() > 0){
                            for(String name : mp.noDocumentsUploadList){                           
                               documentListForUpload.add(name);                                                     
                            }
                         }
                       }  
                     }
                 }                 
                  if(mainWrapperListforApp5.size() > 0){
                     for(MainWrapper mp : mainWrapperListforApp5){
                       if(mp.applicantId == selectedApplicant){
                         if(mp.noDocumentsUploadList.size() > 0){
                            for(String name : mp.noDocumentsUploadList){                           
                               documentListForUpload.add(name);                                                      
                            }
                         }
                       }  
                     }
                 }             
              if(documentListForUpload.size() > 0){
                   optnsDocName = new List < Selectoption > ();
                   optnsDocName.add(new SelectOption('', 'Select Document Type'));
                   for(string dlp : documentListForUpload){
                       optnsDocName.add(new SelectOption(dlp, dlp));
                   }    
              }             
          } 
          
   return null;
}

public PageReference uploadFile(){
      system.debug('inside uploadfile method:::::::::::');
      if(!string.isBlank(selectedApplicant) && !string.isBlank(selectedDocument) && blobfile != null){
           Attachment ac = new Attachment();
           ac.Name = selectedDocument;
           ac.body = blobFile;
           ac.parentId = selectedApplicant;
           ac.ContentType=contentType;
           ac.ownerId = UserInfo.getUserId();
           try{
               insert ac;
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Document Uploaded successfully.');
               ApexPages.addMessage(myMsg);
               if(!String.isBlank(selectedApplicant)){
                    selectedApplicant = '';
               }
                if(!String.isBlank(selectedDocument)){
                    selectedDocument = '';
               }
               getdetails();
               showMethod();
           }
           catch(Exception e) {
               system.debug('Exception when attachment insert:: '+e);
           }
      }
      else{
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select Applicant , Document Type');
           ApexPages.addMessage(myMsg);
           return null;
      }
      
  return null;
}

public PageReference refreshMethod(){
               system.debug('refresh page method');
               PageReference pageRef;              
               pageRef = new PageReference('apex/CustomerDocumentPage?leadId='+optyList[0].id);               
               pageRef.setRedirect(true);
               style = 'display:none;';
               style2 = 'display:inline;';
               selectedApplicant = '';               
               return null;
}

public class MainWrapper{
  public string applicantName{get;set;}
  public string applicantId{get;set;}
  public string applicantType{get;set;}
  public string typeOfApplicant{get;set;}
  public string residentialStatus{get;set;}
  public list<string> documentList{get;set;}
  public list<string> allDocumentList{get;set;}
  public map<string,boolean> allDocumentMapNew{get;set;}
  public list<string> noDocumentsUploadList{get;set;}
  
  public MainWrapper(){
        allDocumentMapNew = new map<string,boolean>();
        noDocumentsUploadList = new list<string>();
        allDocumentList = new list<string>();
        documentList = new list<string>();
  }
}
}