@isTest
public class ClickToCallEnquiryControllerTest {
    public static testMethod void clickCalltest() {
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.VCC1__Phone_Encrypted__c = '917799003448';
        con.VCC1__Mobile_Encrypted__c = '917799003448';
        con.VCC1__Calling_Number_Encrypted__c = '917799003448';
        insert con;
        PropStrength__Projects__c proj = new PropStrength__Projects__c(Booking_Form_T_C__c = 'Testing Form', 
                                                                        DLD_Executive__c = UserInfo.getUserId(), 
                                                                        Name = 'Test Project', 
                                                                        PropStrength__Active__c = true, 
                                                                        T_link_Demand_Days__c = 1);
        insert proj;
        PropStrength__Request__c enq  = new PropStrength__Request__c();
        enq.PropStrength__Primary_Contact__c = con.Id;
        enq.PropStrength__Project__c = proj.Id;
        insert enq; 
        ClickToCallEnquiryController.originalPhoneNumber(enq.Id);
        ClickToCallEnquiryController.originalMobileNumber(enq.Id);
        ClickToCallEnquiryController.originalCallingNumber(enq.Id);
    }
}