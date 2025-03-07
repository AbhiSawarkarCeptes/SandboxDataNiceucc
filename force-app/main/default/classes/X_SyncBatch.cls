public class X_SyncBatch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    
    static final List<String> STATUS_FOR_SYNC_FILTER = new List<String>{'Ready','Failed','Sync in Progress'};
    
    List<Id> xsdIds;
    Set<Integer> sequenceNumbers;
    
    public X_SyncBatch(){}
    
    public X_SyncBatch(List<Integer> sequenceNumbers){
        this.sequenceNumbers = new Set<Integer>(sequenceNumbers);
    }
    
    public X_SyncBatch(Set<Integer> sequenceNumbers){
        this.sequenceNumbers = sequenceNumbers;
    }
    
    public X_SyncBatch(Set<Id> xsdIds){
        this.xsdIds = new List<Id>(xsdIds);
    }
    
    public X_SyncBatch(List<Id> xsdIds){
        this.xsdIds = xsdIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext dBC){
        if(this.xsdIds != NULL){
            return Database.getQueryLocator([SELECT id,Name,Sync_Status__c,Sequence_Number__c,Tower__c,Unit__c,Applicant_Details__c,Demand__c,Payment_Request__c,Receipt__c FROM Xpedeon_Sync_Delegate__c WHERE Id IN :this.xsdIds AND Sync_Status__c IN :STATUS_FOR_SYNC_FILTER ORDER BY CreatedDate ASC,Sequence_Number__c ASC]);
        }else if(this.sequenceNumbers != NULL){
            return Database.getQueryLocator([SELECT id,Name,Sync_Status__c,Sequence_Number__c,Tower__c,Unit__c,Applicant_Details__c,Demand__c,Payment_Request__c,Receipt__c FROM Xpedeon_Sync_Delegate__c WHERE Sequence_Number__c IN :this.sequenceNumbers AND  Sync_Status__c IN :STATUS_FOR_SYNC_FILTER ORDER BY CreatedDate ASC,Sequence_Number__c ASC]);
        }else{
        	return Database.getQueryLocator([SELECT id,Name,Sync_Status__c,Sequence_Number__c,Tower__c,Unit__c,Applicant_Details__c,Demand__c,Payment_Request__c,Receipt__c FROM Xpedeon_Sync_Delegate__c WHERE  Sync_Status__c IN :STATUS_FOR_SYNC_FILTER ORDER BY CreatedDate ASC,Sequence_Number__c ASC]);
        }
    }
    
    public void execute(Database.BatchableContext dBC,List<Xpedeon_Sync_Delegate__c> xsds){
        for(Xpedeon_Sync_Delegate__c xsd : xsds){
            
            
            //Id sourceRecordId = String.isNotBlank(xsd.Tower__c) ? xsd.Tower__c : String.isNotBlank(xsd.Unit__c) ? xsd.Unit__c : String.isNotBlank(xsd.Applicant_Details__c) ? xsd.Applicant_Details__c : String.isNotBlank(xsd.Demand__c) ? xsd.Demand__c : String.isNotBlank(xsd.Payment_Request__c) ? xsd.Payment_Request__c : String.isNotBlank(xsd.Receipt__c) ? xsd.Receipt__c : NULL;
            Id sourceRecordId;
            if(String.isNotBlank(xsd.Tower__c)){
                sourceRecordId = xsd.Tower__c;
            }else if(String.isNotBlank(xsd.Unit__c)){
                sourceRecordId = xsd.Unit__c;
            }else if(String.isNotBlank(xsd.Applicant_Details__c)){
                sourceRecordId = xsd.Applicant_Details__c;
            }else if(String.isNotBlank(xsd.Demand__c)){
                sourceRecordId = xsd.Demand__c;
            }else if(String.isNotBlank(xsd.Payment_Request__c)){
                sourceRecordId = xsd.Payment_Request__c;
            }else if(String.isNotBlank(xsd.Receipt__c)){
                sourceRecordId = xsd.Receipt__c;
            }
            
            if(String.isBlank(sourceRecordId)) continue;
            X_Service service = new X_Service(new X_Service.X_APIData(sourceRecordId,'POST',xsd.Id)); 
            X_Service.SyncResult sr = service.sync();
            xsd.Sync_Status__c = sr.success != NULL && sr.success ? 'Synced' : 'Failed';
            if(xsd.Sync_Status__c == 'Failed'){
                xsd.Remarks__c = truncateToFieldSize(xsd.Sync_Status__c+' : '+sr.httpResponseBody,Xpedeon_Sync_Delegate__c.fields.Remarks__c.getDescribe().getLength());
            }
            
        }
        update xsds;
    }
    
    public void finish(Database.BatchableContext dBC){
        
    }

    //UTILITIES
    static String truncateToFieldSize(String str,Integer lengthLimit){
        return String.isNotBlank(str) && str.length() > lengthLimit ? str.substring(0,lengthLimit) : str;
    }
}