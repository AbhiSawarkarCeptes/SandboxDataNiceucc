public class MobileAppUsercreationQueuable implements Queueable, Database.AllowsCallouts{
    public List<Applicant_Details__c> newList;
    public Map<Id,Applicant_Details__c> oldMapData;
    public Boolean isInsert;
    
    public MobileAppUsercreationQueuable(List<Applicant_Details__c> newLists, Map<Id,Applicant_Details__c> oldMapDatas, Boolean isInserts){
        this.newList = newLists;
        this.oldMapData = oldMapDatas;
        this.isInsert = isInserts;
    }
    
    public void execute(QueueableContext context) {
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        String userEndPointURL = endpoint+'/sruser/v1/user';
        string methodType = 'POST';
        List<requestLeadWrapper> reqLeadWrapList = new List<requestLeadWrapper>();
        String userResponse= null;
        String errorMessage = '';
        Integer statusCode;
        String response = '';
        requestLeadWrapper reqLeadWrap;
        try{
            for(Applicant_Details__c bk :newList){
                if(isInsert || (!isInsert && bk.Email_Address__c != oldMapData.get(bk.Id).Email_Address__c)){
                    reqLeadWrap = new requestLeadWrapper();
                    reqLeadWrap = createLeadWrapper(bk);
                    reqLeadWrapList.add(reqLeadWrap);
                }   
            }
            // Updated by Roshan
            if(reqLeadWrap !=null)
            {
                response = MobileIntegrationCallOutsAPI.callMobileApp(userEndPointURL,methodType,JSON.serialize(reqLeadWrap));
            }
            // end of update
            if(response!=null){
                //Id quableId = System.enqueueJob(new MobileAppCreateBookingQueuable(newList, oldMapData, isInsert));
            }
            
            System.debug('callLeadUserCreateAPI payload : '+reqLeadWrapList);
            System.debug('callLeadUserCreateAPI response payload : '+response);
        }catch(Exception e){
            errorMessage = e.getMessage();
            statusCode = 400;
        }
        
        if(reqLeadWrap !=null)
        {
            Mobile_ApiUtility.createMobileAPILogs('callLeadUserCreateAPI','callLeadUserCreateAPI',JSON.serialize(reqLeadWrapList),response,errorMessage,statusCode);
        }
        
        //return response;
    }
    
    public static requestLeadWrapper createLeadWrapper(Applicant_Details__c bk){
        requestLeadWrapper reqLeadWrap = new requestLeadWrapper();
        reqLeadWrap.lastName = bk.Name;
        reqLeadWrap.email = bk.Email_Address__c;
        reqLeadWrap.mobile = bk.Mobile_Number__c;
        reqLeadWrap.source = 'salesForce';
        // reqLeadWrap.firstName = bk.Primary_Applicant_Name__c;
        
        if(bk.Name != null){
            if(bk.Name.contains(' ')) {
                String[] nameBlocks = bk.Name.split(' ');
                Integer middleIndex = Math.ceil(nameBlocks.size() / 2.0).intValue();
                String firstName = ''; String lastName = '';
                
                for(String nameBlock: nameBlocks) {
                    middleIndex--;
                    if(middleIndex > -1) firstName += nameBlock + ' ';
                    else lastName +=nameBlock + ' ';
                }
                reqLeadWrap.firstName = firstName;
                reqLeadWrap.lastName = lastName;
            }
            else {
                reqLeadWrap.firstName = bk.Name;
                reqLeadWrap.lastName = '';
            }
        }  
        
        reqLeadWrap.dialCode = '0';
        
        return reqLeadWrap;
    }
    
    class requestLeadWrapper{
        string lastName;
        string email;
        string mobile;
        string source;
        string firstName;
        String dialCode;
    }
}