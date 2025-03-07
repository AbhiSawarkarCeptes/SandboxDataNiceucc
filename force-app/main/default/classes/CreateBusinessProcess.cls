public with sharing class CreateBusinessProcess {
    public CreateBusinessProcess() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Process_Flow__c> getProcessFlows(string recId) {
        Id recordId = recId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Booking__c'){
            return [SELECT Id, Name FROM Process_Flow__c where Active__c = true];
        }
        else if(sObjName == 'Tower__c'){
            return [SELECT Id, Name FROM Process_Flow__c where Active_for_tower__c = true];
        }
        else if(sObjName == 'Unit__c'){
            return [SELECT Id, Name FROM Process_Flow__c where Active_for_unit__c = true];
        }
        else{
            return null;
        }
        
    }
    @AuraEnabled
    public static string createPreRegistration(String bookingId, String processId){
        //System.debug('processName '+processName);
        //processName = 'Pre-Registration - 5 days';
        //processName = 'preregistration';
		Id recordId = bookingId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        List<Business_Process__c> existingBP = new List<Business_Process__c>();
        if(sObjName == 'Booking__c'){
            existingBP = [Select Id,Status__c from Business_Process__c where Status__c !='Rejected' AND Process_Flow__c = :processId AND Booking__c=:bookingId];
        }
        else if(sObjName == 'Tower__c'){
            existingBP = [Select Id,Status__c from Business_Process__c where Status__c !='Rejected' AND Process_Flow__c = :processId AND Tower__c=:bookingId];
        }
        else if(sObjName == 'Unit__c'){
            existingBP = [Select Id,Status__c from Business_Process__c where Status__c !='Rejected' AND Process_Flow__c = :processId AND Unit__c=:bookingId];
        }
        
        if(existingBP!=null && existingBP.size()>0){
            return 'Selected Process Already Created..!';
        }

        Business_Process__c objBP;
        try {
            if(bookingId!=null && processId!=null){
                List<Process_Flow__c> listProcess = [Select Id, Name,Active__c from Process_Flow__c where  Id = :processId limit 1];
                if(listProcess.size()>0){
                    objBP = new Business_Process__c();
                    objBP.Name = listProcess[0].Name;
                    if(sObjName == 'Booking__c'){
                        objBP.Booking__c = bookingId;
                    }
                    else if(sObjName == 'Tower__c'){
                        objBP.Tower__c = bookingId;
                    }
                    else if(sObjName == 'Unit__c'){
                        objBP.Unit__c = bookingId;
                    }
                    
                    objBP.Process_Flow__c = listProcess[0].Id;
                    objBP.Status__c = 'In Progress';
                    objBP.Start_Date__c = System.now();
                    
                    insert objBP;

                    List<Process_Flow_Step__c> listFPS = new List<Process_Flow_Step__c>();
                    listFPS = [Select Id,Active__c, Description__c, Process_Flow__c, Name, Setp_No__c,Department__c, Department_Queue__c, Duration_To_Complete_In_Days__c from Process_Flow_Step__c where Process_Flow__c= : listProcess[0].Id AND Active__c = true];

                    if(listFPS!=null && listFPS.size()>0){
                        List<Business_Process_Step__c> listToCreateBPS = new List<Business_Process_Step__c>();
                        for(Process_Flow_Step__c objFPS : listFPS){
                            Business_Process_Step__c newObj = new Business_Process_Step__c();
                            
                            if((objFPS.Description__c)!=null && (objFPS.Description__c).length()>80){
                                newObj.Name = (objFPS.Description__c).substring(0, 80);
                            }else{
                                newObj.Name = objFPS.Description__c;
                            }
                            newObj.Business_Process_Steps_Name_Custom__c = objFPS.Description__c;
                            newObj.Business_Process__c = objBP.Id;
                            
                            newObj.Sequence__c = objFPS.Setp_No__c;
                            newObj.Step__c = 'Step '+ String.valueOf(objFPS.Setp_No__c) ;
                            if(objFPS.Setp_No__c==1){
                                newObj.Status__c = 'Open';
                                newObj.Assigned_Time__c = System.now();
                                newObj.Final_Assigned_Time__c = System.now();
                            }else{
                                newObj.Status__c = 'Not Actioned';
                            }
                            
                            //newObj.Approval_Status__c = '';

                            newObj.Department__c = objFPS.Department__c;
                            newObj.ownerId = objFPS.Department_Queue__c;
                            newObj.Original_Queue_Id__c = objFPS.Department_Queue__c;
                            newObj.TAT__c = Integer.valueOf(objFPS.Duration_To_Complete_In_Days__c);

                            listToCreateBPS.add(newObj);
                        }
                        insert listToCreateBPS;
                    }
                }
            } 
            return objBP.Id;
            
        } catch (Exception e) {
            System.debug('Exception from CreateBusinessProcess '+e);
            System.debug('Exception from CreateBusinessProcess message '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}