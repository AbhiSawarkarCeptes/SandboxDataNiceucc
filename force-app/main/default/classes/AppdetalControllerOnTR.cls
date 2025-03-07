global with sharing class AppdetalControllerOnTR {
    public PropStrength__Applicant_Detail__c appDetail           {get;set;}
    public PropStrength__Applicant_Detail__c appDetailSec         {get;set;}
    public PropStrength__Applicant_Detail__c appDetailThir         {get;set;}
    public PropStrength__Applicant_Detail__c appDetailForth       {get;set;}
    public PropStrength__Applicant_Detail__c appDetailFifth       {get;set;}
    public PropStrength__Applicant_Detail__c appDetailsix         {get;set;}
    public PropStrength__Applicant_Detail__c Detailer          {get;set;}
    public PropStrength__Applicant_Detail__c Detail            {get;set;}
    public List<PropStrength__Transaction_Requests__c> Lstbook      {get;set;}
    public PropStrength__Transaction_Requests__c transn          {get;set;}
    
    //  global string transectionId {get;set;}
    
    public string transectionId {get;
                                 set{
                                     transectionId = value;
                                     if(transectionId != null)
                                         componentmoethod();
                                     system.debug('transectionId -------'+transectionId );
                                 }
                                }
    
    public AppdetalControllerOnTR (){
        system.debug('&&&&&&&&transectionId1&&&&&&&&&&&&&'+transectionId);
        transectionId = Apexpages.currentPage().getparameters().get('id');
        system.debug('&&&&&&&&transectionId1&&&&&&&&&&&&&'+transectionId);
        componentmoethod();
        
    }
    public void componentmoethod(){
        
        if(String.isNotBlank(transectionId )){
            set<id> bookid = new set<id>();
            Lstbook =[Select id,Name,PropStrength__Application_Booking__c From PropStrength__Transaction_Requests__c where Id =:transectionId ];
            
            if(Lstbook != null && Lstbook.Size() >0){
                transn = Lstbook[0];
                bookid.add(Lstbook[0].PropStrength__Application_Booking__c);
            }
            
            List<PropStrength__Applicant_Detail__c>  DetailLst = [Select id, Name ,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Salutation,PropStrength__Applicant_Acc__r.Name
                                                                  From PropStrength__Applicant_Detail__c Where PropStrength__Application__c =: bookid AND PropStrength__Active__c=true];
            
            if(DetailLst != null && DetailLst.size()>0){
                Detail= DetailLst[0];
                for(PropStrength__Applicant_Detail__c app : DetailLst){
                    if(app.PropStrength__Type__c == '1st Applicant'){
                        appDetail = app;
                    }
                    if(app.PropStrength__Type__c == '2nd Applicant'){
                        appDetailSec = app;
                    }                
                    if(app.PropStrength__Type__c == '3rd Applicant'){
                        appDetailThir = app;
                    }
                    if(app.PropStrength__Type__c == '4th Applicant'){
                        appDetailForth = app;
                    }
                    if(app.PropStrength__Type__c == '5th Applicant'){
                        appDetailFifth = app;
                    }
                    if(app.PropStrength__Type__c == '6th Applicant'){
                        appDetailsix = app;
                    }
                }
            }
        }                     
    }
}