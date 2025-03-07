public class LwcApproveRejectBpstepController {

    @AuraEnabled
    Public static string getSteps(string bpsId){
        Business_Process_Step__c bps = [Select id,Business_Process__c,Sequence__c from Business_Process_Step__c where id = :bpsId limit 1];
        List<Business_Process_Step__c> bpsList = [Select id,Business_Process__c,Sequence__c,Step__c,Department__c from Business_Process_Step__c where Business_Process__c = :bps.Business_Process__c AND Sequence__c<:bps.Sequence__c AND Department__c != null AND Step__c != null];
        
        return JSON.serialize(bpsList);
    }
    @AuraEnabled
    Public static string approveStep(string bpsId,string comment, string brNumber){
        system.debug('comment '+comment);
        Business_Process_Step__c bps = new Business_Process_Step__c();
        bps.Approval_Status__c = 'Approved';
        bps.Remarks_Comments__c = comment;
        bps.Bank_Reference_Number__c = brNumber;
        bps.id = bpsId;
        Update bps;
        return ([Select id,Business_Process__c from Business_Process_Step__c where Id = :bpsId limit 1 ]).Business_Process__c;
    }
    @AuraEnabled
    Public static string rejectStep(string bpsId,string comment, string brNumber){
        Business_Process_Step__c bps = new Business_Process_Step__c();
        bps.Approval_Status__c = 'Rejected';
        bps.Remarks_Comments__c = comment;
        bps.Bank_Reference_Number__c = brNumber;
        bps.id = bpsId;
        Update bps;
        return ([Select id,Business_Process__c from Business_Process_Step__c where Id = :bpsId limit 1 ]).Business_Process__c;
    }
    @AuraEnabled
    Public static string requestForMoreInfo(string bpsId,string rejectingToBpsId,string comment, string brNumber){
        Business_Process_Step__c bps = [Select id,Business_Process__c,Sequence__c from Business_Process_Step__c where id = :bpsId limit 1];
        List<Business_Process_Step__c> bpsList = [Select id,Business_Process__c,Original_Queue_Id__c,Sequence__c from Business_Process_Step__c where Business_Process__c = :bps.Business_Process__c Order by Sequence__c ASC];
        boolean makeNotActioned = false;
        string rejectToQueueId;
        List<Business_Process_Step__c> bpsToUpdate = new List<Business_Process_Step__c>();
        for(Business_Process_Step__c b :bpsList){
            if(makeNotActioned){
                b.status__c = 'Not Actioned';
                b.Final_Accepted_Time__c = null;
                b.Final_Completed_Time__c = null;
                b.Aging__c = NULL;
                b.Approval_Status__c = null;
                b.OwnerId = b.Original_Queue_Id__c;
                bpsToUpdate.add(b);
            }
            if(b.Id == rejectingToBpsId){
                makeNotActioned = true;
                rejectToQueueId = b.Original_Queue_Id__c;
            }
            if(b.Id == bpsId){
                b.Remarks_Comments__c = comment;
                b.Bank_Reference_Number__c = brNumber;
                makeNotActioned = false;
                break;
            }
            
        }
        Business_Process_Step__c b = new Business_Process_Step__c();
        b.Id = rejectingToBpsId;
        b.Approval_Status__c = null;
        b.Status__c = 'Open';
        b.OwnerId = rejectToQueueId;
        b.Final_Assigned_Time__c = system.now();
        b.Final_Accepted_Time__c = null;
        b.Final_Completed_Time__c = null;
		bpsToUpdate.add(b);

        WithoutSharingApexUtility.updateRecord(bpsToUpdate);

        return bps.Business_Process__c;
    }
    @AuraEnabled
    Public static boolean validateOnLoad(Id bpsId){
        system.debug('bpsId '+bpsId);
        Business_Process_Step__c bps = [Select id,owner.Type from Business_Process_Step__c Where Id = :bpsId];
        system.debug(bps.owner.type);
        if(bps.owner.type=='Queue') {
            return false;
        }
        else{
            return true;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Business_Process_Step__c getBusinessProcessStepFields(String recordId) {
        return [SELECT Id, Business_Process__r.name, Sequence__c
                FROM Business_Process_Step__c
                WHERE Id = :recordId
                LIMIT 1];
    }
}