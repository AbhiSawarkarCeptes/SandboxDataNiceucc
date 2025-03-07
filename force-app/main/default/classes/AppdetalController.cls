global with sharing class AppdetalController {
    public PropStrength__Applicant_Detail__c appDetail                  {get;set;}
    public PropStrength__Applicant_Detail__c appDetailSec               {get;set;}
    public PropStrength__Applicant_Detail__c appDetailThir              {get;set;}
    public PropStrength__Applicant_Detail__c appDetailForth             {get;set;}
    public PropStrength__Applicant_Detail__c appDetailFifth             {get;set;}
    public PropStrength__Applicant_Detail__c appDetailsix               {get;set;}
    public PropStrength__Applicant_Detail__c Detailer                   {get;set;}
    public PropStrength__Applicant_Detail__c Detail                     {get;set;}
    public List<PropStrength__Application_Booking__c> Lstbook           {get;set;}
    public PropStrength__Application_Booking__c appBook                 {get;set;}
    public Bank_GL__c Bank                                              {get;set;}
    public string BankId                                                {get;set;}
    
    public string transectionId {get;
                                 set{
                                     transectionId = value;
                                     if(transectionId != null)
                                         componentmoethod();
                                 }
                                }
                            
    
    public AppdetalController(){
        transectionId = Apexpages.currentPage().getparameters().get('id');
        Bank = new Bank_GL__c();
        BankId = '';
        componentmoethod();
        
    }
    public void componentmoethod(){
        
        if(String.isNotBlank(transectionId )){
            set<id> proId = new set<id>();
            list<Bank_GL__c> BankGLlist = new list<Bank_GL__c>();
            Lstbook =[Select id,Name,PropStrength__Project__c From PropStrength__Application_Booking__c where Id =:transectionId ];
            
            if(Lstbook != null && Lstbook.Size() >0){
                appBook = Lstbook[0];
                proId.add(Lstbook[0].PropStrength__Project__c);
            }
            if(!proId.isEmpty()){
                BankGLlist = [SELECT id,Name,Project__c,Account_Number__c,IBAN__c,Bank_Account_Type__c,RDS_Address1__c,
                             Branch__c,Swift_Code__c,Favouring__c,Beneficiary__c,Bank_Name__c
                             FROM Bank_GL__c WHERE Project__c =: proId];
                if(!BankGLlist.isEmpty()){
                    for(Bank_GL__c Bankvar: BankGLlist){
                        if(Bankvar.Bank_Account_Type__c == 'Escrow Account'){
                            BankId = Bankvar.id;
                            Bank = Bankvar;
                        }
                    }
                }             
            }
            List<PropStrength__Applicant_Detail__c>  DetailLst = [Select id, Name ,PropStrength__Type__c,PropStrength__Applicant_Acc__r.Salutation,PropStrength__Applicant_Acc__r.Name
                                                                  From PropStrength__Applicant_Detail__c Where PropStrength__Application__c =: transectionId AND PropStrength__Active__c=true];
            
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
    
    public void Bankcomponentmoethod(){
        if(String.isNotBlank(BankId)){
            Lstbook =[Select id,Name From PropStrength__Application_Booking__c where Id =:BankId];
        }
    }
}