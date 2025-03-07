public class customerregistrationhandler {
    
    public static void beforeInsert(List<Customer_Registration__c> newList) {
        validateMobileNumberSize(newList, null);
    }
    
    public static void beforeUpdate(List<Customer_Registration__c> newList, Map<Id,Customer_Registration__c> oldMap) {
        validateMobileNumberSize(newList, oldMap);
    }
    
    public static void afterinsert(){
        Set<id> Sobha_Connectset = new Set<id>();
        Set<id> Channel_Partnerset = new Set<id>();
        List<Sobha_Connect__c> sclst = new List<Sobha_Connect__c>();
        List<Channel_Partner__c> cplst = new List<Channel_Partner__c>();
        for(Customer_Registration__c cr : (List<Customer_Registration__c>) Trigger.new){
            if(cr.Channel_Partner__c <> null)
                Channel_Partnerset.add(cr.Channel_Partner__c);
            if(cr.Sobha_Connect__c <> null)
                Sobha_Connectset.add(cr.Sobha_Connect__c);
        }
        Integer currentYear = System.Today().year();
        Integer LastYear = currentYear-1;
        List<String> yearlst = new List<String>();
        yearlst.add(String.valueof(currentYear));
        yearlst.add(String.valueOf(LastYear));
        if(!Sobha_Connectset.isEmpty()){
            Map<Id,sitevisits> sobhcntsitemap= new Map<Id,sitevisits>();
            List<Customer_Registration__c> crlst = [SELECT ID,Sobha_Connect__c,Created_Year__c FROM Customer_Registration__c  WHERE Sobha_Connect__c IN :Sobha_Connectset AND Created_Year__c IN :yearlst];
            for(Customer_Registration__c cr : crlst){
                if(!sobhcntsitemap.keySet().contains(cr.Sobha_Connect__c))
                    sobhcntsitemap.put(cr.Sobha_Connect__c, new sitevisits());
                if(cr.Created_Year__c == String.valueof(currentYear)){
                    sobhcntsitemap.get(cr.Sobha_Connect__c).thisyearval++;
                }
                if(cr.Created_Year__c == String.valueof(LastYear)){
                    sobhcntsitemap.get(cr.Sobha_Connect__c).lastyearval++;
                }  
            }
            for(Id i : sobhcntsitemap.keyset()){
                Sobha_Connect__c sc = new Sobha_Connect__c();
                sc.Id = i;
                sc.Number_of_Site_Visits__c = sobhcntsitemap.get(i).thisyearval;
                sc.No_of_Sales_In_Last_Year__c = sobhcntsitemap.get(i).lastyearval;
                sclst.add(sc);
            }
            update sclst;
        }  
        if(!Channel_Partnerset.isEmpty()){
            Map<Id,sitevisits> chanlpartnrsitemap= new Map<Id,sitevisits>();
            List<Customer_Registration__c> crlst = [SELECT Id,Channel_Partner__c,Created_Year__c FROM Customer_Registration__c  WHERE Channel_Partner__c IN :Channel_Partnerset AND Created_Year__c IN :yearlst];
            for(Customer_Registration__c cr : crlst){
                if(!chanlpartnrsitemap.keySet().contains(cr.Channel_Partner__c))
                    chanlpartnrsitemap.put(cr.Channel_Partner__c, new sitevisits());
                if(cr.Created_Year__c == String.valueof(currentYear)){
                    chanlpartnrsitemap.get(cr.Channel_Partner__c).thisyearval++;
                }
                if(cr.Created_Year__c == String.valueof(LastYear)){
                    chanlpartnrsitemap.get(cr.Channel_Partner__c).lastyearval++;
                }  
            }
            for(Id i : chanlpartnrsitemap.keyset()){
                Channel_Partner__c cp = new Channel_Partner__c();
                cp.Id = i;
                cp.No_of_Site_Visits__c = chanlpartnrsitemap.get(i).thisyearval;
                cp.Qualified_Sales_Value_Last_year__c = chanlpartnrsitemap.get(i).lastyearval;
                cplst.add(cp);
            }
            update cplst;
        }    
    }
    public class sitevisits{
        public Decimal thisyearval = 0;
        public Decimal lastyearval = 0;
    }
    
    static void validateMobileNumberSize(List<Customer_Registration__c> newList, Map<Id,Customer_Registration__c> oldMap) {
        Map<String,List<Customer_Registration__c>> countryToSVFs = new Map<String,List<Customer_Registration__c>>();
        Id contRecordTypeId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByDeveloperName().get('CRM_Site_Visit').getRecordTypeId();
        System.debug('contRecordTypeId -> '+contRecordTypeId);
        
        for(Customer_Registration__c svf : newList) {
            Customer_Registration__c oldSvf = oldMap?.get(svf.Id);
            if( oldSvf == null || 
               svf.Dialing_Country__c != oldSvf.Dialing_Country__c ||
               svf.Mobile_Number__c != oldSvf.Mobile_Number__c 
              ) {
                  if( !countryToSVFs.containsKey(svf.Dialing_Country__c) ) {
                      countryToSVFs.put(svf.Dialing_Country__c, new List<Customer_Registration__c>());
                  }
                  countryToSVFs.get(svf.Dialing_Country__c).add(svf);
              }
        }
        System.debug('countryToSVFs -> '+countryToSVFs);
        for(Country_Mobile_Number_Info__mdt mapping : [
            SELECT Label, Mobile_Number_Length__c
            FROM Country_Mobile_Number_Info__mdt
            WHERE Label IN :countryToSVFs.keySet()
        ]) {
            
            for(Customer_Registration__c svf : countryToSVFs.get(mapping.Label)) {
                system.debug('recordtype' +countryToSVFs.get(mapping.Label));
                if( svf.Mobile_Number__c != null && svf.Mobile_Number__c.length() != mapping.Mobile_Number_Length__c  && svf.RecordTypeId != contRecordTypeId) 
                    svf.Mobile_Number__c.addError('Mobile Number must have exactly ' + Integer.valueOf(mapping.Mobile_Number_Length__c) + ' digits, shouldn\'t contain any spaces or starts with 0.');
            }
            countryToSVFs.remove(mapping.Label);
            System.debug('countryToSVFs -> '+countryToSVFs);
        }
        
        for(List<Customer_Registration__c> svfs : countryToSVFs.values()) {
            
            for(Customer_Registration__c svf : svfs){
                System.debug('svf.RecordTypeId -> '+svf.RecordTypeId);
                if(svf.RecordTypeId != contRecordTypeId){
                    
                    //svf.Dialing_Country__c.addError('Selected Dialing Country is not mapped in salesforce. Please contact your administrator to save mobile number related to this country.');
                }
            }
        }
    }

    @future(callOut=true)
    public static void sendToTokenAPI(Id crId){
        string reqBody;
        Customer_Registration__c tw;
        try{
            Id devRecordTypeId = Schema.SObjectType.Customer_Registration__c.getRecordTypeInfosByDeveloperName().get('CRM_Site_Visit').getRecordTypeId();

            tw = [SELECT id,Name,First_Name__c,Last_Name__c,Category__c,Vertical__c,Booking__r.Tower_Name__c,Booking__r.Cluster__c,Purpose_of_visit__c,RecordTypeId,Booking__c,Booking__r.Name,Booking__r.Unit__r.Name,Booking__r.Unit__c,Booking__r.Unit__r.Project__r.Name,Booking__r.Unit__r.Project__c,Booking__r.Unit__r.Tower__c,Booking__r.Unit__r.Tower__r.Name,Booking__r.Unit__r.Sub_project_tower__c,CRM_Executive__c,CRM_Executive__r.Name,CRM_Executive__r.Id,CRM_Executive__r.Manager_Name__c,Mobile_Number__c, Visitor_name__c,Token__c FROM Customer_Registration__c WHERE Id = :crId Limit 1];
            if((tw.Token__c == null || tw.Token__c == '') && tw.RecordTypeId == devRecordTypeId ){
                requestBodyWrapper wrap = new requestBodyWrapper();
                wrap.name = tw.Name;
                wrap.mobileNumber = tw.Mobile_Number__c;
                wrap.Category = tw.Category__c;
                wrap.Vertical = tw.Vertical__c;
                wrap.Booking = tw.Booking__r.Name;
                wrap.Unit = tw.Booking__r.Unit__r.Name;
                wrap.Project = tw.Booking__r.Unit__r.Project__r.Name;
                wrap.Tower = tw.Booking__r.Cluster__c;
                wrap.CRM_Executive = tw.CRM_Executive__r.Name;
                wrap.Tower_Name = tw.Booking__r.Cluster__c;
                wrap.Purpose_of_visit = tw.Purpose_of_visit__c;
                wrap.Manager_Name = tw.CRM_Executive__r.Manager_Name__c;
                wrap.Sub_project_tower = tw.Booking__r.Unit__r.Sub_project_tower__c;
                if(tw.Visitor_name__c != null){
                    wrap.visitorName = tw.Visitor_name__c;
                }else{
                    wrap.visitorName = tw.First_Name__c+' '+tw.Last_Name__c;
                }
                requestBody reWrap = new requestBody();
                if(tw.Vertical__c == 'CRM'){
                    reWrap.service_id = 1;
                }else{
                    reWrap.service_id = 2;
                }
                reWrap.instance = 'SFD';
                rewrap.extras = wrap;
                if(wrap != null){
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    Integration_Info__c myCS1 = Integration_Info__c.getValues('Token API');
                    request.setEndpoint(myCS1.End_Point_URL__c);
                    request.setMethod(myCS1.Method__c);
                    request.setTimeout(120000);
                    Map < String, Object > fullMap = ( Map < String, Object > )JSON.deserializeUntyped( myCS1.Header_JSON__c );
                    for(string header :fullMap.keySet()){
                        request.setHeader(header, (string)fullMap.get(header));
                    }
                    reqBody = JSON.serialize(rewrap);
                    request.setBody(JSON.serialize(rewrap));
                    HttpResponse response = http.send(request);
                    system.debug(response.getBody());
                    system.debug(JSON.deserializeUntyped(response.getBody()));
                    // If the request is successful, parse the JSON response.
                    system.debug('response.getStatusCode() '+response.getStatusCode());
                    if (response.getStatusCode() == 201) {
                        // Deserialize the JSON string into collections of primitive data types.
                        system.debug(JSON.deserializeUntyped(response.getBody()));
                        responseWrapper res = (responseWrapper)JSON.deserialize(response.getBody(), responseWrapper.Class);
                        tw.Token__c = res.token;
                        system.debug('tw.Token__c '+tw.Token__c);
                        update tw;
                    }
                    else{
                        //Handle error
                        ProcessException pe = new ProcessException();
                        pe.AttachedToId = tw.Id;
                        pe.Category = 'Site Visit Token API';
                        pe.Description = 'Status = '+response.getStatus()+'. Status Code = '+response.getStatusCode()+'. Full response = '+response.toString()+ '. Request Body = '+JSON.serialize(rewrap);
                        pe.Message = 'Failed from token system. ';
                        insert pe; 
                    }
                }
            }
                        
        }
        catch(Exception e){
            ProcessException pe = new ProcessException();
            pe.AttachedToId = tw.Id;
            pe.Category = 'Site Visit Token API';
            pe.Description = 'Cause = '+e.getCause()+'. Line Number = '+e.getLineNumber()+'. Error message = '+e.getMessage()+'. Stack Trace = '+e.getStackTraceString()+ '. Request Body = '+reqBody;
            pe.Message = 'Failed in Salesforce. ';
            insert pe; 
        }
        
    }
    @InvocableMethod
  	public static void getToken (List<Id> crIds) {
      for(id crId :crIds){
          sendToTokenAPI(crId);
      }
      
  }
    class requestBody{
        integer service_id;
        string instance;
        requestBodyWrapper extras = new requestBodyWrapper();
    }
    class requestBodyWrapper{
        String name;
        String mobileNumber;
        String visitorName;
        String Category;
        String Vertical;
        String Booking;
        String Tower_Name;
        String Purpose_of_visit;
        String Unit;
        String Project;
        String Tower;
        String CRM_Executive;
        String Manager_Name;
        String Sub_project_tower;
    }
    
    class responseWrapper{
        string token;
    }
}