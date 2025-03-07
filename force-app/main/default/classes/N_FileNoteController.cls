public class N_FileNoteController{
    
    public Booking__c book;
    File_Note__c fn;
    List<Team__c> t;
    PageReference returnPage;
    
    public N_FileNoteController(){
        Id bId; 
        t = new List<Team__c>();
        returnPage = null;
        if(ApexPages.currentpage().getParameters().get('id') != null)
            bId = ApexPages.currentpage().getParameters().get('id'); 
        if(bId != null)
            book = [SELECT Id, Opportunity__c, Unit__c, Quotation__c, Unit__r.Tower__r.Cluster__c 
                    FROM Booking__c WHERE Id = :bId]; 
    }
    
    public PageReference createFileNote(){        
        if(book.Unit__r.Tower__r.Cluster__c != null){
            t = [SELECT CRM__c, Finance__c, Audit__c, CFO__c 
                 FROM Team__c 
                 WHERE Sub_Project__c = :book.Unit__r.Tower__r.Cluster__c AND Team_Type__c = 'File Note Approver Team']; 
        }
        if(!t.isempty() && t.size() == 1){
            if(book != null){
                fn = new File_Note__c();            
                fn.Booking__c = book.Id;
                fn.Approval_Status__c = 'Not Submitted';
                if(book.Quotation__c != null)
                    fn.Quotation__c = book.Quotation__c;
                if(book.Opportunity__c != null)
                    fn.Opportunity__c = book.Opportunity__c;
                if(book.Unit__c != null)
                    fn.Unit__c = book.Unit__c;
                if(t[0].CRM__c != null)
                    fn.CRM__c = t[0].CRM__c;
                if(t[0].Finance__c != null)
                    fn.Finance__c = t[0].Finance__c;
                if(t[0].Audit__c != null)
                    fn.Audit__c = t[0].Audit__c;            
                if(t[0].CFO__c != null)
                    fn.CFO__c = t[0].CFO__c;
                try{
                    insert fn;
                    returnPage = new PageReference('/'+fn.Id+'/e?retURL=%2F'+fn.Id);
                } catch(Exception e){
                    system.debug('Error occurred while inserting file note::: ' + e);
                    returnPage = null;
                }
            }                
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'File note approver team is not defined for this sub project.'));
            returnPage = null;
        } 
        return returnPage;
    }
}