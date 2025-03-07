public class Unit_Holds_For_SM_Cls {
    @AuraEnabled
    public static void saveAccountList(List<Units_Hold_For_SM__c> accList,string filemap, string paymentFileMap, string ChequeCopyMap, string declarationMap, string creditCardMap, string letterMap, string cashMap, string wireTransferMap,string sobhaWebisteMap) 
    {    
        try{
            system.debug('accList1 '+accList);
           
            //system.debug('accList2 '+JSON.stringify(accList));
            system.debug('file map value 1'+filemap);
            system.debug('payment map value -- '+ paymentFileMap);
            system.debug('the lenghth of fist map is --'+ filemap.length());
            
            if(String.isNotBlank(filemap)){
                System.debug('file map is not empty');
            }
            Insert accList;
            /*
            if(filemap.length() > 2){
                List<uploadedDocs> Updocs = new   List<uploadedDocs>();
                if(String.isNotBlank(filemap))
                    Updocs = (List<uploadedDocs>)JSON.deserialize(filemap, List<uploadedDocs>.Class);
                system.debug('Updocs'+Updocs);
                
                Map<Integer, Id> indexVsRec = new Map<Integer, Id>();
                for(Units_Hold_For_SM__c uhfm : accList){
                    if(uhfm.index__c != null){
                        indexVsRec.put(Integer.valueOf(uhfm.index__c), uhfm.Id);
                    }
                }
                system.debug('accList2 '+accList);
                List<attachment> attchList = new List<attachment>();
                for(uploadedDocs upp:Updocs){
                    if(indexVsRec.containsKey(Integer.valueOf(upp.key))){
                        List<Value> valueList = new List<Value>();
                        for(Value  val: valueList){
                         attachment obj = new attachment();
                        String base64Data = val.body;
                        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                        obj.Body = EncodingUtil.base64Decode(base64Data);
                        obj.ParentId = indexVsRec.get(Integer.valueOf(upp.key));
                        obj.Name = val.Name;
                        obj.ContentType = val.ContentType;
                        attchList.add(obj);
                        }
                        //upp.value = new Unit_Holds_For_SM_Cls.Value();
                       
                        
                    }
                }
                if(attchList.size() > 0){
                    insert attchList;
                }
            } */
            if(paymentFileMap.length() > 2){
                /*
                // paymentFileMap = '['+paymentFileMap+']';
                List<uploadedDocs> UpdocsPayment = new List<uploadedDocs>();
                if(String.isNotBlank(paymentFileMap))
                    UpdocsPayment = (List<uploadedDocs>)JSON.deserialize(paymentFileMap, List<uploadedDocs>.Class);
                */
                Map<Integer, Id> indexVsRecPayment = new Map<Integer, Id>();
                for(Units_Hold_For_SM__c uhfm : accList){
                    if(uhfm.index__c != null){
                        indexVsRecPayment.put(Integer.valueOf(uhfm.index__c), uhfm.Id);
                    }
                }
                
                //trying new method for payment files
                Map<String, List<Value>> updatedPaymentMap = (Map<String, List<Value>>) JSON.deserialize(paymentFileMap, Map<String,List<Value>>.class);
                List<attachment> tempAttachList = new List<attachment>();
                System.debug('the updated map value ' + updatedPaymentMap);
                for(String key : updatedPaymentMap.keySet()){
                    List<Value> tempValList = updatedPaymentMap.get(key);
                    for(Value val : tempValList){
                         attachment obj = new attachment();
                        String base64Data = val.body;
                        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                        obj.Body = EncodingUtil.base64Decode(base64Data);
                        obj.ParentId = indexVsRecPayment.get(Integer.valueOf(key));
                        obj.Name = val.Name;
                        obj.ContentType = val.ContentType;
                        tempAttachList.add(obj);
                        }
                    
                }
                if(tempAttachList.size() > 0){
                    insert tempAttachList;
                }
                
                /*
                List<attachment> attchListPayment = new List<attachment>();
                
                
                for(uploadedDocs upp:UpdocsPayment){
                    if(indexVsRecPayment.containsKey(Integer.valueOf(upp.key))){
                        //upp.value = new Unit_Holds_For_SM_Cls.Value();
                        List<Value> valueLsit = upp.value;
                        for(Value val : valueLsit){
                         attachment obj = new attachment();
                        String base64Data = val.body;
                        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                        obj.Body = EncodingUtil.base64Decode(base64Data);
                        obj.ParentId = indexVsRecPayment.get(Integer.valueOf(upp.key));
                        obj.Name = val.Name;
                        obj.ContentType = val.ContentType;
                        attchListPayment.add(obj);
                        }
                        
                    }
                }
                
                if(attchListPayment.size() > 0){
                    insert attchListPayment;
                } */
            } 
            
            /*
               if(ChequeCopyMap.length() > 2){
                List<uploadedDocs> UpdocsChequeCopy = new List<uploadedDocs>();
                if(String.isNotBlank(ChequeCopyMap))
                    UpdocsChequeCopy = (List<uploadedDocs>)JSON.deserialize(ChequeCopyMap, List<uploadedDocs>.Class);
                
                Map<Integer, Id> indexVsRecChequeCopy = new Map<Integer, Id>();
                for(Units_Hold_For_SM__c uhfm : accList){
                    if(uhfm.index__c != null){
                        indexVsRecChequeCopy.put(Integer.valueOf(uhfm.index__c), uhfm.Id);
                    }
                }
                
                List<attachment> attchListChequeCopy = new List<attachment>();
                for(uploadedDocs upp:UpdocsChequeCopy){
                    if(indexVsRecChequeCopy.containsKey(Integer.valueOf(upp.key))){
                        //upp.value = new Unit_Holds_For_SM_Cls.Value();
                        attachment obj = new attachment();
                        String base64Data = upp.value.body;
                        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                        obj.Body = EncodingUtil.base64Decode(base64Data);
                        obj.ParentId = indexVsRecChequeCopy.get(Integer.valueOf(upp.key));
                        obj.Name = upp.value.Name;
                        obj.ContentType = upp.value.ContentType;
                        attchListChequeCopy.add(obj);
                    }
                }
                
                if(attchListChequeCopy.size() > 0){
                    insert attchListChequeCopy;
                }
            }
            *
            /*
            saveAttachement(accList,ChequeCopyMap);
            saveAttachement(accList,declarationMap);
            saveAttachement(accList,creditCardMap);
            saveAttachement(accList,letterMap);
            saveAttachement(accList,cashMap);
            saveAttachement(accList,wireTransferMap);
            saveAttachement(accList,sobhaWebisteMap);* /
            
            
            
            
            
            /*Attachment a = new Attachment();
a.parentId = parentId;
a.Body = EncodingUtil.base64Decode(base64Data);
a.Name = fileName;
a.ContentType = contentType;

insert a;*/
            
		
		            
        }catch (exception e){
            System.debug('===='+e.getMessage());
            system.assert(false,e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    /*
    @AuraEnabled
    public static void saveAttachement(List<Units_Hold_For_SM__c> accList,string mapName){
        try{
           	if(mapName.length() > 2){
                List<uploadedDocs> Updocs = new   List<uploadedDocs>();
                if(String.isNotBlank(mapName))
                    Updocs = (List<uploadedDocs>)JSON.deserialize(mapName, List<uploadedDocs>.Class);
                system.debug('Updocs'+Updocs);
                
                Map<Integer, Id> indexVsRec = new Map<Integer, Id>();
                for(Units_Hold_For_SM__c uhfm : accList){
                    if(uhfm.index__c != null){
                        indexVsRec.put(Integer.valueOf(uhfm.index__c), uhfm.Id);
                    }
                }
                system.debug('accList2 '+accList);
                List<attachment> attchList = new List<attachment>();
                for(uploadedDocs upp:Updocs){
                    if(indexVsRec.containsKey(Integer.valueOf(upp.key))){
                        //upp.value = new Unit_Holds_For_SM_Cls.Value();
                        attachment obj = new attachment();
                        String base64Data = upp.value.body;
                        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
                        obj.Body = EncodingUtil.base64Decode(base64Data);
                        obj.ParentId = indexVsRec.get(Integer.valueOf(upp.key));
                        obj.Name = upp.value.Name;
                        obj.ContentType = upp.value.ContentType;
                        attchList.add(obj);
                        
                    }
                }
                if(attchList.size() > 0){
                    insert attchList;
                } 
            }
            
        } catch (exception e){
            System.debug('===='+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } */
    
    @AuraEnabled 
    public static List<String> getOtherTwoFields (string recId , string objectName){
        List<String> fieldsToUpdate = new List<String>();
        
        if(objectName == 'Channel_Partner__c'){
            Channel_Partner__c cp = [select id , name , Channel_Partner_Id__c from Channel_Partner__c where id =: id.valueOf(recId) limit 1];
            fieldsToUpdate.add(cp.Channel_Partner_Id__c);
            fieldsToUpdate.add(cp.name);
            System.debug('inside  Channel_Partner__c');
        }else if(objectName == 'Sobha_Connect__c'){
            Sobha_Connect__c sC = [select name , name__c from Sobha_Connect__c  where id =: id.valueOf(recId) limit 1];
            fieldsToUpdate.add(sc.name);
            fieldsToUpdate.add(sc.name__c);
            System.debug('inside Sobha_Connect__c');
        } 
        
        else if(objectName=='Unit__c'){
            Unit__c ut =[select id,name,Puchase_Price__c  from  Unit__c  where id=: id.valueOf(recId) limit 1];
            //added to solve the sale value issue
            Integer intPurchasePirce = Integer.valueOf(ut.Puchase_Price__c);
            fieldsToUpdate.add(String.valueOf(intPurchasePirce));
            //fieldsToUpdate.add(ut.name);
            System.debug('inside Unit__c');

        }
           System.debug('fieldsToUpdate='+fieldsToUpdate);
        return fieldsToUpdate;
    }
    public class uploadedDocs{
        @AuraEnabled
        Public String key;
        @AuraEnabled
        Public List<Value> value;
        
    }
    public class Value{
        @AuraEnabled
        Public String Name;
        @AuraEnabled
        Public String ContentType;
        @AuraEnabled
        Public String Body;
        @AuraEnabled
        Public String parentID;
        
    }
    
    //Added by Vivek Kumar (Ceptes)
    @AuraEnabled
    public static List<String> getCurrencyPicklistValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Units_Hold_For_SM__c.Currency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static User getUserRole(){
        return [Select Id, UserRole.Name from User where Id =: UserInfo.getUserId()];
    }
    
    @AuraEnabled
    public static void unlockUnitHold(string recordId){
        try{
            Units_Hold_For_SM__c u = [select Id, Unit__c, Approval_Status__c from Units_Hold_For_SM__c where Id =: recordId];
            Unit__c unit = [select Id,Unit_Status__c from Unit__c where Id =: u.Unit__c];
            unit.Unit_Status__c = 'Available';
            update unit;
            u.Approval_Status__c = 'Pending for Approval';
            update u;
        }
        catch(Exception e){
            system.debug('VVK: '+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateSM(string recordId, string managerId){
        system.debug('VVK: '+recordId + ' hjchjds: '+managerId);
        Units_Hold_For_SM__c u = [select Id, Unit__c, Approval_Status__c from Units_Hold_For_SM__c where Id =: recordId];
        Unit__c unit = [select Id,Unit_Status__c from Unit__c where Id =: u.Unit__c];
        unit.Unit_Status__c = 'Available';
        update unit;
        u.Sales_Manager__c = managerId;
        u.Approval_Status__c = 'Approved';
        update u;
    }
}