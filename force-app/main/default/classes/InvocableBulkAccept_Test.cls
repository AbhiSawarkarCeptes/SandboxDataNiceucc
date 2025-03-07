@isTest
public class InvocableBulkAccept_Test {

    
    @testSetup
    static void setupTestData() {
        Contact con= new Contact();
        con.FirstName='For';
        con.LastName='TAT Emails';
        insert con;
        
        Process_Flow__c pF= new Process_Flow__c();
        pF.Name='Test PF';
        pF.Process_Flow_Unique_Name__c='testPF';
        insert pF;
        
        Process_Flow_Step__c pFS= new Process_Flow_Step__c();
        pFS.Process_Flow__c=pF.Id;
        insert pFS;
        
        Business_Process__c bP= new Business_Process__c();
        bP.Name='Test business process';
        bp.Process_Flow__c=pF.Id;
        insert bP;
        
        Business_Process_Step__c bPS= new Business_Process_Step__c();
        bPS.Name='test Name 1';
        bPS.Business_Process__c=bP.Id;
        bPS.Business_Process_Steps_Name_Custom__c='Test business step process full name';
        bPS.Status__c='Open';
        bPS.Sequence__c=1;
        insert bPS;
        
        Business_Process_Step__c bPS1= new Business_Process_Step__c();
		bPS1.Name='test Name 2';
        bPS1.Business_Process__c=bP.Id;
        bPS1.Business_Process_Steps_Name_Custom__c='Test business step process full name 2';
        bPS1.Status__c='Not Actioned';
        bPS1.Sequence__c=1;
        insert bPS1;
        
        
        
    }

   
    @isTest
    static void testBulkAcceptFunctionality() {
        
       // List<Business_Process_Step__c> bps1= new List<Business_Process_Step__c>();
        //bps1=[SELECT Id,Name from Business_Process_Step__c WHERE Status__c='Open'];
        List<Id> idees= new List<Id>();
        for(Business_Process_Step__c bps1 : [SELECT Id,Name from Business_Process_Step__c WHERE Status__c='Open'])
        {
            idees.add(bps1.Id);
        }
        
        InvocableBulkAccept.InputValues iV1= new InvocableBulkAccept.InputValues();
        iV1.actionName='Accept';
        iV1.ids=idees;
        
        List<InvocableBulkAccept.InputValues> listIv1=new List<InvocableBulkAccept.InputValues>();
        listIv1.add(iV1);
        InvocableBulkAccept.BulkUpdateRecordList(listIv1);

        InvocableBulkAccept.InputValues iV2= new InvocableBulkAccept.InputValues();
        iV2.actionName='Approve';
        iV2.ids=idees;
        
        List<InvocableBulkAccept.InputValues> listIv2=new List<InvocableBulkAccept.InputValues>();
        listIv2.add(iV2);
        InvocableBulkAccept.BulkUpdateRecordList(listIv2);
        
        InvocableBulkAccept.InputValues iV3= new InvocableBulkAccept.InputValues();
        iV3.actionName='Reject';
        iV3.ids=idees;
        
        List<InvocableBulkAccept.InputValues> listIv3=new List<InvocableBulkAccept.InputValues>();
        listIv3.add(iV3);
        InvocableBulkAccept.BulkUpdateRecordList(listIv3);
    }

  
    
}