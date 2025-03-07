global class InventoryController{
    
    public List<String> unitStatusValues    {get; set;}
    public String longitude {get; set;}
    public String latitude {get; set;}
    public Boolean isSale {get; set;}
    
    public InventoryController(){
        
        List<String> profileNameList = new List<String>();

        if(System.Label.Sales_Profiles.contains(',')) {
            profileNameList.addAll(System.Label.Sales_Profiles.split(','));
        } else {
            profileNameList.add(System.Label.Sales_Profiles);
        }

        isSale = false;
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Profile.Name IN :profileNameList]);
        Id currentUserId = UserInfo.getUserId();
        if(userMap.containsKey(currentUserId)) {
            isSale = true;
        }

       unitStatusValues = new List<String>();
       Schema.DescribeFieldResult fieldResult = PropStrength__Property__c.PropStrength__Unit_Status__c.getDescribe();
       List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
       for(Schema.PicklistEntry ple : pleList ){
           if(ple.isActive() == true){
               unitStatusValues.add(ple.getValue());
           }
       }
       System.debug('=== unitStatusValues=== ' +unitStatusValues);
    }
    
    @RemoteAction 
    global static List<String> getStateNameViaGeo(String longitude, String latitude) {
        WrapperClass wrap;
        List<String> stateList = new List<String> ();
        String url = 'https://api.geoapify.com/v1/geocode/reverse?lat=' + latitude + '&lon=' + longitude + '&type=city&apiKey=9955b821f92043a9b3970a4c8e2fa4fc';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('res---'+res.getBody());
        System.debug('res---'+res.getStatusCode());
        System.debug('res---'+res.getStatus());
        if(res.getStatusCode() == 200) {
            wrap = new WrapperClass();
            wrap = (WrapperClass) System.JSON.deserialize(res.getBody(), WrapperClass.class);
            System.debug('wrap---'+wrap);
            System.debug(wrap.features[0].Properties.state); //'\''+ oldString + '\'';
            stateList.add(wrap.features[0].Properties.state);
            stateList.add(wrap.features[0].Properties.city);
            if(wrap.features[0].Properties.city.contains('Jaipur Municipal Corporation')){
                stateList.add('Jaipur');
            }
            System.debug('stateList*---'+stateList);
            return stateList    ;
        }
        return null;
    }
    
    public class WrapperClass{
        public List<features> features {get; set;}
        public WrapperClass() {
            features = new List<features>();
        }     
    }
    
    public class features {
        public Properties properties {get; set;}
    }
    
    public class Properties {
        public String state {get; set;}
        public String city {get; set;}
    }
}