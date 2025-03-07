public class GenerateReceiptController {
    static String logs;
    
    @InvocableMethod(label='Generate Booking/Unit Receipt' )
    public static void generateReceiptFor(List<String> recIds){
        try{
            if(recIds == null || recIds.isEmpty()) return;
            Set<Id> prIds = new Set<Id>();
            writeLog('recIds - '+recIds);
            for(String recId : recIds){
                if(Id.valueOf(recId).getSObjectType() == Payment_Request__c.sObjectType){
                    prIds.add(recId);
                }
            }
            writeLog('prIds - '+prIds);
            
            if(prIds.isEmpty()) return;
            Set<String> bookingPrNames = new Set<String>();
            Set<String> unitNsaNames = new Set<String>();
            for(Payment_Request__c pr : [SELECT id,Name,From_Booking__c,Payment_Request__c,Secondary_Mode__c,Mode_Option__c,New_Sale_Approval__c,New_Sale_Approval__r.Name,Payment_Request__r.New_Sale_Approval__c,Payment_Request__r.New_Sale_Approval__r.Name FROM Payment_Request__c WHERE id IN :prIds]){
                if(pr.From_Booking__c){
                    bookingPrNames.add(pr.Name);
                }else{
                    if(pr.Payment_Request__c == NULL && String.isNotBlank(pr.New_Sale_Approval__r?.Name)){//single mode with NSa attached
                        unitNsaNames.add(pr.New_Sale_Approval__r.Name);
                    }else{//multimode
                        if(String.isNotBlank(pr.Payment_Request__r?.New_Sale_Approval__r?.Name)){
                            unitNsaNames.add(pr.New_Sale_Approval__r.Name);    
                        }
                    }
                }
            }
            writeLog('bookingPrNames - '+bookingPrNames);
            writeLog('unitNsaNames - '+unitNsaNames);
            
            if(!unitNsaNames.isEmpty()) generateUnitReceipt(unitNsaNames);
            if(!bookingPrNames.isEmpty()) generateBookingReceipt(bookingPrNames);
        }catch(Exception ex){
            writeLog('\nException Occurred in GenerateReceiptController - '+'\n Exception Type - '+ex.getTypeName()+'\n Cause - '+ex.getMessage()+'\n @ '+ex.getStackTraceString()+'\n Exception instance - '+ex);
        }
        
        finalizeLog();
        
    }
    
    @future
    static void generateUnitReceipt(Set<String> bookingPrNames){
        if(bookingPrNames == null || bookingPrNames.isEmpty()) return;
        ReceiptUtil.createReceiptUnitLevel(new List<String>(bookingPrNames));
    }
    
    @future
    static void generateBookingReceipt(Set<String> unitNsaNames){
        if(unitNsaNames == null || unitNsaNames.isEmpty()) return;
        ReceiptUtil.createReceiptBookingLevel(new List<String>(unitNsaNames));
    }
    
    @TestVisible static void writeLog(String log){
        if(String.isBlank(log)) return;
        logs = logs == NULL ? log : logs+'\n'+log;
    }
    
    @TestVisible static void finalizeLog(){
        if(logs == null || String.isBlank(logs)) return;
        
        insert new Error_Log__c(
        	Name = 'GenerateReceiptController',
            Message__c = logs
        );
    }
}