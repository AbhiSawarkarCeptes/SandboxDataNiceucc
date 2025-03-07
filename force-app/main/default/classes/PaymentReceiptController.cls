public class PaymentReceiptController {
    
    // Method to retrieve field configuration from Custom Metadata Type
    @AuraEnabled(cacheable=true)
    public static List<Dashboard_Field_Configuration__mdt> getDashboardFieldConfiguration(String screenType) {
        return [SELECT Field_API_Name__c, Field_Label__c, Order_Of_Column__c FROM Dashboard_Field_Configuration__mdt WHERE Screen__c = :screenType ORDER BY Order_Of_Column__c ];
    }
    
    // Method to fetch receipts with Cleared status and Under Approval
    @AuraEnabled(cacheable=false)
    public static List<SObject> getReceipts(String status) {
        System.debug('status*---'+status);
        List<Dashboard_Field_Configuration__mdt> fieldConfigs = getDashboardFieldConfiguration('Audit');
        String queryFields = generateQueryFields(fieldConfigs);
        queryFields += ',Payment_Request__r.Name ';
        queryFields += ',PropStrength__Application_Booking__r.PropStrength__Property__c';
        queryFields += ',PropStrength__Application_Booking__r.PropStrength__Property_Name__c';
        String query = 'SELECT id, ' + queryFields + ' FROM PropStrength__Received_Payment__c WHERE Audit_Approval_Status__c = :status And Payment_Request__c != null ORDER BY CreatedDate DESC LIMIT 60';// ORDER BY and LIMIT added fir Page-Load issue fix
        System.debug('--------query------'+query);
        // return Database.query(query);
        List<PropStrength__Received_Payment__c> rs = Database.query(query);
        System.debug('--------qwerty------'+rs);
        Map<Id,Id> idFinalIdMap = new Map<Id,Id>();
        if(rs != null && rs.size()>0){
            for(PropStrength__Received_Payment__c r: rs){
                idFinalIdMap.put(r.id,r.Payment_Request__r.Final_Approver__c);
            }
            Map<id,User> userMap = new Map<id,User>();
            if(idFinalIdMap.values() != null && idFinalIdMap.values().size()>0){
                userMap = new Map<Id, User>([Select Name from User where id IN :idFinalIdMap.values()]);                
                for(PropStrength__Received_Payment__c r: rs){
                    if (userMap != null && !userMap.isEmpty() && userMap.containsKey(idFinalIdMap.get(r.id)) && userMap.get(idFinalIdMap.get(r.id)) != null && userMap.get(idFinalIdMap.get(r.id)).Name != null) {                        
                        r.Payment_Request__r.Final_Approver__c = userMap.get(idFinalIdMap.get(r.id)).Name;
                    }
                }
            }
        }
        System.debug('----------'+rs);
        for(PropStrength__Received_Payment__c r : rs){
            System.debug('Deepanshu : '+r.Name+' -> '+r.Payment_Request__r.Final_Approver__c);
        }
        return rs;
    }
    
    // Generate query fields based on field configuration
    private static String generateQueryFields(List<Dashboard_Field_Configuration__mdt> fieldConfigs) {
        List<String> fields = new List<String>();
        for (Dashboard_Field_Configuration__mdt config : fieldConfigs) {
            fields.add(config.Field_API_Name__c);
        }
        return String.join(fields, ', ');
    }
    
    
    @AuraEnabled     
    public static void updatePaymentStatus(String paymentId, String action, String comment) 
    {        
        System.debug('receiptId, action, comment - '+paymentId + ' : '+action+' : '+comment);
        PropStrength__Received_Payment__c receiptToUpdate = [SELECT Id,Audit_History__c, Audit_Approval_Status__c, Audit_Approver_s_Comments__c FROM PropStrength__Received_Payment__c 
                                                             WHERE Id = :paymentId LIMIT 1];                  
        // Check if the receipt is found         
        if (receiptToUpdate != null) 
        {             // Update receipt fields based on action             
            if (action.containsIgnoreCase('Approve')) 
            {                 
                receiptToUpdate.Audit_Approval_Status__c = 'Approved';     
                receiptToUpdate.Audit_Approver_s_Comments__c = comment;
            } 
            else if (action.containsIgnoreCase('Reject')) 
            {                 
                receiptToUpdate.Audit_Approval_Status__c = 'Rejected';                 
                receiptToUpdate.Submission_Resubmission_Date__c = System.today();            // Added By Gourav Gour 27/05/2024
               /* if(receiptToUpdate.Audit_History__c == null)
                     receiptToUpdate.Audit_History__c = userInfo.getFirstName() + ' ' + userInfo.getLastName() + ' changed status from '+
                    							   receiptToUpdate.Audit_Approver_s_Comments__c + ' to ' + comment + ' on ' + System.now();
                else
                	receiptToUpdate.Audit_History__c = receiptToUpdate.Audit_History__c + ' \n ' + userInfo.getFirstName() + ' ' + userInfo.getLastName() + ' changed status from '+
                    							   receiptToUpdate.Audit_Approver_s_Comments__c + ' to ' + comment + ' on ' + System.now();*/
                receiptToUpdate.Audit_Approver_s_Comments__c = comment;                
            }
            else if (action.containsIgnoreCase('Under')) 
            {                 
                receiptToUpdate.Audit_Approval_Status__c = 'Under Approval';     
                receiptToUpdate.Submission_Resubmission_Date__c = System.today();            // Added By Gourav Gour 27/05/2024            
                receiptToUpdate.Audit_Submitter_s_Comments__c = comment;
            }// Perform the update             
            try { 
				System.debug('receiptToUpdate: ' + receiptToUpdate);
                update receiptToUpdate;
           }catch (Exception e) {// Handle update error                 
                System.debug('Error updating receipt: ' + e.getMessage());                 
                throw new AuraHandledException('Error updating receipt: ' + e.getMessage());             
            }
        } 
        else 
        {             // Handle receipt not found error             
            throw new AuraHandledException('Receipt not found with ID: ' + paymentId);        
        }     
    }

}