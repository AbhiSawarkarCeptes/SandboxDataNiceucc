@RestResource(urlMapping = '/getBookingList')
global class Mobile_getBookingList {

    @HttpPost
    global static void getBookingList(String email) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String responseString = '';
        String errorMessage = '';
        try{
            List<Booking__c> bklst = [select id,name,Status__c,Unit__r.Name,ReSale_Transfer_Type__c,Unit__r.Tower__r.Name,unit__r.Tower__r.Cluster__r.Name,unit__r.Tower__r.Cluster__r.Project__r.Name from Booking__c where Primary_Applicant_Email__c =:email and unit__r.Tower__r.Cluster__r.Project__r.Id != 'a0RTX000008zDTv2AM' ];
            List<Mobile_ApiUtility.responseBodyWrapper> resplst = new List<Mobile_ApiUtility.responseBodyWrapper>();
            if(bklst.size() > 0){
                for(Booking__c bk :bklst){
                    Mobile_ApiUtility.responseBodyWrapper  wrap = new Mobile_ApiUtility.responseBodyWrapper();
                    if(bk.Id != null){                        
                    wrap.bookingID = bk.Id;
                    } else {
                        wrap.bookingID = null;
                    }
                    if(bk.name != null){
                    wrap.bookingName = bk.name ;
                    } 
                    
                    if(bk.ReSale_Transfer_Type__c == 'SMT'){
                        wrap.isresale = true ;
                    }else {
                         wrap.isresale = false ;
                    }
                        
                    if(bk.Status__c != null){
                    wrap.bookingStatus = bk.Status__c;
                    }
                    if(bk.Unit__r.Name != null){
                        wrap.unitName = bk.Unit__r.Name;
                    }
                    if(bk.Unit__r.Tower__r.Name != null){
                    wrap.towerName = bk.Unit__r.Tower__r.Name;  
                    }
                    if(bk.unit__r.Tower__r.Cluster__r.Name != null){
                    wrap.clusterName =  bk.unit__r.Tower__r.Cluster__r.Name;
                    }
                    if(bk.unit__r.Tower__r.Cluster__r.Project__r.Name != null){
                        wrap.projectName = bk.unit__r.Tower__r.Cluster__r.Project__r.Name;
                    }
                    resplst.add(wrap);
                }
                responseString = (Mobile_ApiUtility.prepareResponse(resplst,'Operation Successfull','Success',200,true)).toString().replace('"','');
                res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(resplst,'Operation Successfull','Success',200,true)));
                res.statusCode = 200;
            }
            else{
                res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(resplst,'Operation Successfull','Success',200,true)));
                res.statusCode = 200;
            }
        }
        catch(Exception e){
            errorMessage = e.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(Mobile_ApiUtility.prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('getBookingList','Mobile_getBookingList',email,responseString,errorMessage,res.statusCode);
    }

}