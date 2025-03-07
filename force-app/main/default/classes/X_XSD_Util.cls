public class X_XSD_Util {
    
    //DISPATCHERs
    public static void processInit(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
        try{
            if(Feature_Flag__mdt.getAll().containsKey('XpedeonSyncDelegateCreation') && Feature_Flag__mdt.getInstance('XpedeonSyncDelegateCreation').Active__c){
                process(oldMap,newMap);
            }
        }catch(Exception ex){
            insert new Error_Log__c(Message__c = 'X_XSD_Util Exception : \n\n ex.getMessage() - '+ex.getMessage()+'\n\n ex.getStackTraceString() - '+ex.getStackTraceString()+'\n\n ex.getTypeName() - '+ex.getTypeName());
        }
    }
    
    public static void forceInit(List<Id> targetRecordIds){
        forceInit(new Set<Id>(targetRecordIds));
    }
    
    public static void forceInit(Set<Id> targetRecordIds){
        if(targetRecordIds == NULL || targetRecordIds.isEmpty()) return;
        
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        
        for(Id targetRecordId : targetRecordIds){
            if(targetRecordId.getSObjectType() == Tower__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Tower__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 1
                    )
                );    
            }
            if(targetRecordId.getSObjectType() == Unit__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Unit__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 2
                    )
                );
            }
            if(targetRecordId.getSObjectType() == Applicant_Details__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Applicant_Details__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 3
                    )
                );
            }
            if(targetRecordId.getSObjectType() == Demand__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Demand__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 4
                    )
                );
            }
            /*
            if(targetRecordId.getSObjectType() == Bank_Receipt__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Bank_Receipt__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 5
                    )
                );
            }
            */
            if(targetRecordId.getSObjectType() == Receipt__c.SObjectType){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Receipt__c = targetRecordId,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 6
                    )
                );
            }
        }
        
        Database.insert(xsds,false);
    }
    
    //HANDLERs
    static void process(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
        if(newMap == NULL || newMap.isEmpty()) return;
        oldMap = oldMap == NULL ? new Map<Id,SObject>() : oldMap;
        
        if(!isAsyncContext()){
            processFuture(JSON.serialize(oldMap),JSON.serialize(newMap));
            return;
        }
        
        States s = new States(oldMap,newMap);
        
        if(s.sObjType == Tower__c.SObjectType){
            towerProcess(s);
        }
        if(s.sObjType == Unit__c.SObjectType){
            unitProcess(s);
        }
        if(s.sObjType == Applicant_Details__c.SObjectType){
            applicantDetailsProcess(s);
        }
        if(s.sObjType == Demand__c.SObjectType){
            demandProcess(s);
        }
        /*if(s.sObjType == Bank_Receipt__c.SObjectType){
            brcProcess(s);
        }*/
        if(s.sObjType == Receipt__c.SObjectType){
            receiptProcess(s);
        }
        
    }
    
    @future
    static void processFuture(String oldMap,String newMap){
        process((Map<Id,SObject>)JSON.deserialize(oldMap,Map<Id,SObject>.class),(Map<Id,SObject>)JSON.deserialize(newMap,Map<Id,SObject>.class));
    }
    
    //WORKERs
    static void towerProcess(States s){
        if(!s.insertOrUpdate) return;
        Map<Id,Tower__c> oldMap = (Map<Id,Tower__c>) s.oldMap;
        Map<Id,Tower__c> newMap = (Map<Id,Tower__c>) s.newMap;
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Tower__c t : newMap.values()){
            //if(t.Project__c == 'a0RTX000008zDTv2AM') continue;//blocking Siniya towers capture
            xsds.add(
                new Xpedeon_Sync_Delegate__c(
                    Tower__c = t.Id,
                    Sync_Status__c = 'Ready',
                    Sequence_Number__c = 1
                )
            );
        }
        Database.insert(xsds,false);
    }
    
    static void unitProcess(States s){
        if(!s.insertOrUpdate) return;
        Map<Id,Unit__c> oldMap = (Map<Id,Unit__c>) s.oldMap;
        Map<Id,Unit__c> newMap = (Map<Id,Unit__c>) s.newMap;
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Unit__c u : newMap.values()){
            //if(u.Project__c == 'a0RTX000008zDTv2AM') continue;//blocking Siniya units capture
            xsds.add(
                new Xpedeon_Sync_Delegate__c(
                    Unit__c = u.Id,
                    Sync_Status__c = 'Ready',
                    Sequence_Number__c = 2
                )
            );
        }
        Database.insert(xsds,false);        
    }
    
    static void applicantDetailsProcess(States s){
        Map<Id,Applicant_Details__c> oldMap = (Map<Id,Applicant_Details__c>) s.oldMap;
        Map<Id,Applicant_Details__c> newMap = (Map<Id,Applicant_Details__c>) s.newMap;
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Applicant_Details__c ad : newMap.values()){
            if(
                (s.insertOrUpdate && ad.Applicant_Number__c == 'Primary Applicant')
                || (!s.insertOrUpdate && ad.Applicant_Number__c == 'Primary Applicant' && oldMap.containsKey(ad.Id) && oldMap.get(ad.Id).Applicant_Number__c != 'Primary Applicant')
            ){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Applicant_Details__c = ad.Id,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 3
                    )
                );
            }
        }
        Database.insert(xsds,false);
    }
    
    static void demandProcess(States s){
        if(!s.insertOrUpdate) return;
        
        Map<Id,Demand__c> oldMap = (Map<Id,Demand__c>) s.oldMap;
        Map<Id,Demand__c> newMap = (Map<Id,Demand__c>) s.newMap;
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Demand__c d : newMap.values()){
            //if(d.Project__c == 'a0RTX000008zDTv2AM' || d.Booking__C == 'a062o00001vPdWiAAK' || d.Booking__C == 'a067S000003KShUQAW') continue;
            if(d.Booking__C == 'a062o00001vPdWiAAK' || d.Booking__C == 'a067S000003KShUQAW') continue;
            if(String.isNotBlank(X_Utility.getDemandType(d))){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Demand__c = d.Id,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 4
                    )
                );
            }
        }
        Database.insert(xsds,false);
    }
    
    /*
    static void brcProcess(States s){
        if(!s.insertOrUpdate) return;
        
        Map<Id,Bank_Receipt__c> oldMap = (Map<Id,Bank_Receipt__c>) s.oldMap;
        Map<Id,Bank_Receipt__c> newMap = (Map<Id,Bank_Receipt__c>) s.newMap;
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Bank_Receipt__c brc : newMap.values()){
            xsds.add(
                new Xpedeon_Sync_Delegate__c(
                    Bank_Receipt__c = brc.Id,
                    Sync_Status__c = 'Ready',
                    Sequence_Number__c = 5
                )
            );
        }
        Database.insert(xsds,false);
    }
    */
    
    static void receiptProcess(States s){
        
        Map<Id,Receipt__c> oldMap = (Map<Id,Receipt__c>) s.oldMap;
        Map<Id,Receipt__c> newMap = (Map<Id,Receipt__c>) s.newMap;
        
        Set<Id> receiptIdsWithExistingXsds = new Set<Id>();
        for(Xpedeon_Sync_Delegate__c existingXsd : [SELECT Receipt__c FROM Xpedeon_Sync_Delegate__c WHERE Receipt__c IN :newMap.keySet()]){
            receiptIdsWithExistingXsds.add(existingXsd.Receipt__c);
        }
        
        List<Xpedeon_Sync_Delegate__c> xsds = new List<Xpedeon_Sync_Delegate__c>();
        for(Receipt__c newR : newMap.values()){
            
            if(receiptIdsWithExistingXsds.contains(newR.Id) || String.isBlank(newR.Payment_Request__c)) continue;
            Boolean isEligible = false;
            
            if(newR.Mode__c == 'Cash' || newR.Mode__c == 'Credit Note'){
                isEligible = false;
            }else if(s.insertOrUpdate){
                isEligible = newR.Receipt_Status__c == 'Cleared';
            }else{
                isEligible = newR.Receipt_Status__c == 'Cleared' && oldMap.containsKey(newR.Id) && oldMap.get(newR.Id).Receipt_Status__c != 'Cleared';
            }
            
            if(isEligible){
                xsds.add(
                    new Xpedeon_Sync_Delegate__c(
                        Receipt__c = newR.Id,
                        Sync_Status__c = 'Ready',
                        Sequence_Number__c = 6
                    )
                );
            }
        }
        Database.insert(xsds,false);
    }
    
    //WRAPPERs
    class States{
        SObjectType sObjType;
        Boolean insertOrUpdate;
        Map<Id,SObject> oldMap;
        Map<Id,Sobject> newMap;
        
        States(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
            this.insertOrUpdate = (oldMap == NULL || oldMap.isEmpty());
            this.sObjType = newMap.values()[0].Id.getSObjectType();
            
            typeCastMaps(oldMap,newMap);
        }
        
        void typeCastMaps(Map<Id,SObject> oldMap,Map<Id,SObject> newMap){
            
            if(this.sObjType == Tower__c.SobjectType){//Tower
                this.oldMap = new Map<Id,Tower__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Tower__c) s);
                this.newMap = new Map<Id,Tower__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Tower__c) s);
            }
            if(this.sObjType == Unit__c.SobjectType){//Unit
                this.oldMap = new Map<Id,Unit__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Unit__c) s);
                this.newMap = new Map<Id,Unit__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Unit__c) s);
            }
            if(this.sObjType == Applicant_Details__c.SobjectType){//Applicant Details
                this.oldMap = new Map<Id,Applicant_Details__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Applicant_Details__c) s);
                this.newMap = new Map<Id,Applicant_Details__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Applicant_Details__c) s);
            }
            if(this.sObjType == Demand__c.SobjectType){//Demand
                this.oldMap = new Map<Id,Demand__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Demand__c) s);
                this.newMap = new Map<Id,Demand__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Demand__c) s);
            }
            /*
            if(this.sObjType == Bank_Receipt__c.SobjectType){//Bank Receipt
                this.oldMap = new Map<Id,Bank_Receipt__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Bank_Receipt__c) s);
                this.newMap = new Map<Id,Bank_Receipt__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Bank_Receipt__c) s);
            }
            */
            if(this.sObjType == Receipt__c.SobjectType){//Receipt
                this.oldMap = new Map<Id,Receipt__c>();
                for(sObject s : oldMap.values()) this.oldMap.put(s.Id,(Receipt__c) s);
                this.newMap = new Map<Id,Receipt__c>();
                for(sObject s : newMap.values()) this.newMap.put(s.Id,(Receipt__c) s);
            }
        }
    }
    
    //HELPERs
    static Boolean isAsyncContext(){
        return System.isFuture() || System.isScheduled() || System.isQueueable() || System.isBatch();
    }
}