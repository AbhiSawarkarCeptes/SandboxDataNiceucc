@isTest
public class Test_Mb_CreateRequest {

    @isTest
    static void testGetBookingListWithRecords() {
        
        Assignment_Group_Name__c assignmentGroupName = new Assignment_Group_Name__c();
        assignmentGroupName.Type__c = 'Cases';
        assignmentGroupNamE.Name = 'Test';
        Insert assignmentGroupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.Active__c = 'True';
        assignmentGroup.Name = 'Test';
        assignmentGroup.Rank__c = 1;
        assignmentGroup.Group_Name__c = assignmentGroupName.Id;
        Insert assignmentGroup;
        
        Case c = new Case();
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedPhone = '98765432';
        c.description = 'description';
        insert c;
        
        /*  List<string> strList = new List<string>();
        strList.add('A');
        strList.add('B');
        List<Mobile_createRequest.CaseRequestWrapper> wrapperList = accountCController.getNameValues(strList); */
        
        Mobile_TestUtil.createBooking();
        List<booking__c> book = [select id, name from booking__c order by createddate asc limit 1];
        
        Mobile_createRequest.CaseRequestWrapper cwrap = new Mobile_createRequest.CaseRequestWrapper();
        cwrap.email = 'test@gmail.com';
        cwrap.mobile = '9876543321';
        cwrap.description = 'description';
        cwrap.requestType = 'SPA';
        cwrap.bookingId = book[0].Id;
        String jsonBody = JSON.serialize(cwrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createRequest'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        	Mobile_createRequest.doCreateCase();
        Test.stopTest();
    }
    
    @isTest
    static void testGetBookingListWithOutRecords() {
        
        Assignment_Group_Name__c assignmentGroupName = new Assignment_Group_Name__c();
        assignmentGroupName.Type__c = 'Cases';
        assignmentGroupNamE.Name = 'Test';
        Insert assignmentGroupName;
        
        Assignment_Groups__c assignmentGroup = new Assignment_Groups__c();
        assignmentGroup.Active__c = 'True';
        assignmentGroup.Name = 'Test';
        assignmentGroup.Rank__c = 1;
        assignmentGroup.Group_Name__c = assignmentGroupName.Id;
        Insert assignmentGroup;
        
        Case c = new Case();
        c.SuppliedEmail = 'test@gmail.com';
        c.SuppliedPhone = '98765432';
        c.description = 'description';
        insert c;
        
        /*  List<string> strList = new List<string>();
        strList.add('A');
        strList.add('B');
        List<Mobile_createRequest.CaseRequestWrapper> wrapperList = accountCController.getNameValues(strList); */
        
        Mobile_TestUtil.createBooking();
        List<booking__c> book = [select id, name from booking__c order by createddate asc limit 1];
        
        Mobile_createRequest.CaseRequestWrapper cwrap = new Mobile_createRequest.CaseRequestWrapper();
        /*cwrap.email = 'test@gmail.com';
        cwrap.mobile = '9876543321';
        cwrap.description = 'description';
        cwrap.requestType = 'SPA';
        cwrap.bookingId = book[0].Id;*/
        String jsonBody = JSON.serialize(cwrap);
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createRequest'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueof(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        	Mobile_createRequest.doCreateCase();
        Test.stopTest();
    }
}