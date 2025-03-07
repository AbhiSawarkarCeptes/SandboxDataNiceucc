@RestResource(urlMapping='/PSSalesManagers/')
global with sharing class GetPSSalesManagers {
   @HttpGet
    global static List<ResponseWrapper> GetPSSalesManagersData() {
        // String jsonGeneratedString;
        List<ResponseWrapper> resWrap = new List<ResponseWrapper>();
        try {
            RestRequest request = RestContext.request;
            List<User> salesManagerList = [SELECT FirstName,LastName,IsActive,Email,Title,Phone,MobilePhone, ProfileId, UserRoleId
                                           FROM User 
                                           WHERE 
                                           IsActive = TRUE AND 
                                           Profile.Name = 'Sales' AND 
                                           UserRole.Name LIKE 'Sales Manager%'];
            // system.JSONGenerator gen = system.JSON.createGenerator(false);
            // RestResponse res = RestContext.response;
            if(!salesManagerList.isEmpty()) {
                /*gen.writeStartObject();
                gen.writeBooleanField('Sucess',true);
                gen.writeStringField('errorMessage','');
                gen.writeFieldName('Sales Managers');
                gen.writeStartArray();*/
                for(User sr : salesManagerList) {  
                    ResponseWrapper res = new ResponseWrapper();
                    res.attributes = new Attribute();
                    res.attributes.type = 'User';
                    res.attributes.url = '/services/data/v58.0/sobjects/User/'+sr.Id;
                    res.Id = sr.Id;
                    res.FirstName = sr.FirstName != null ? sr.FirstName : '';
                    res.LastName = sr.LastName != null ? sr.LastName : '';
                    res.IsActive = true;
                    res.Email = sr.Email != null ? sr.Email : '';
                    res.MobilePhone = sr.MobilePhone != null ? sr.MobilePhone : '';
                    res.Phone = sr.Phone != null ? sr.Phone : '';
                    res.Title = sr.Title != null ? sr.Title : '';
                    res.ProfileId = sr.ProfileId != null ? sr.ProfileId : '';
                    res.UserRoleId = sr.UserRoleId != null ? sr.UserRoleId : '';
                    resWrap.add(res);

                    
                    /*gen.writeStartObject();
                    gen.writeStringField('First Name', (sr.FirstName != null ? sr.FirstName : ''));
                    gen.writeStringField('Last Name', (sr.LastName != null ? sr.LastName : ''));
                    gen.writeStringField('Title', (sr.Title != null ? sr.Title : ''));
                    gen.writeStringField('Email', (sr.Email != null ? sr.Email : ''));
                    gen.writeStringField('Phone', (sr.Phone != null ? sr.Phone : ''));
                    gen.writeStringField('Mobile Phone', (sr.MobilePhone != null ? sr.MobilePhone : ''));
                    gen.writeEndObject();*/
                }
               /* gen.writeEndArray();
                gen.writeEndObject();
                jsonGeneratedString = gen.getAsString();
                system.debug('jsonGeneratedString::'+jsonGeneratedString);*/
            } else {
                ResponseWrapper res = new ResponseWrapper();
                resWrap.add(res);
                // jsonGeneratedString = '{"Sucess" : false,"errorMessage":"There is no record present."}';
            }
        } catch(Exception e){
            ResponseWrapper res = new ResponseWrapper();
            resWrap.add(res);
            // jsonGeneratedString = '{"Sucess" : false,"errorMessage":"'+e.getMessage()+'"}';
        }
        // return jsonGeneratedString;
        return resWrap;
    }
    Global class Attribute {
        Global String type;
        Global String url;
    }
    Global Class ResponseWrapper {
        Global Attribute attributes;
        Global String Id;
        Global String FirstName;
        Global String LastName;
        Global Boolean IsActive;
        Global String Email;
        Global String MobilePhone;
        Global String Phone;
        Global String ProfileId;
        Global String UserRoleId;
        Global String Title;
    }
}