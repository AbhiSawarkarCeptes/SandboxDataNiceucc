@RestResource(urlMapping='/sobhagetsalesmanagers/')
global with sharing class SobhaGetSalesManagersAPI {
    @HttpGet
    global static List<User> getSalesManagers(){
        RestRequest request = RestContext.request;
        List<User> salesManagers = [SELECT FirstName,LastName,IsActive,Email,Title,Phone,MobilePhone 
                                    FROM User 
                                    WHERE 
                                    IsActive = TRUE AND 
                                    Profile.Name = 'Sales' AND 
                                    (UserRole.Name LIKE 'Sales Manager%' OR UserRole.Name LIKE 'Sales Head%')];
        for(User u : salesManagers){
            u.FirstName = (u.FirstName == null)?'':u.FirstName;
            u.LastName = (u.LastName == null)?'':u.LastName;
            u.Title = (u.Title == null)?'':u.Title;
            u.Email = (u.Email == null)?'':u.Email;
            u.Phone = (u.Phone == null)?'':u.Phone;
            u.MobilePhone = (u.MobilePhone == null)?'':u.MobilePhone;
        }
        return salesManagers;
    }
}