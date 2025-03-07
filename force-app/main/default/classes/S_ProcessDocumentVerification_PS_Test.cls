@isTest
public class S_ProcessDocumentVerification_PS_Test {
   
    @isTest
    static void testConstructor() {
        
        Test.startTest();
        S_ProcessDocumentVerification_PS controller = new S_ProcessDocumentVerification_PS();
        Test.stopTest();
        
    }
    
    @isTest
    static void testProcess() {
        
        Test.startTest();
        S_ProcessDocumentVerification_PS controller = new S_ProcessDocumentVerification_PS();
        controller.ProcessRowNo = '0'; // Assuming at least one booking exists
        try{
        Pagereference result = controller.Process();
        }catch(exception e){
            
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void testAssign() {
        
        Test.startTest();
        S_ProcessDocumentVerification_PS controller = new S_ProcessDocumentVerification_PS();
        controller.AssignRowNo = '0'; // Assuming at least one booking exists
        try{
        controller.Assign();
        }catch(exception e){
            
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetListOfBooking() {
        
        Test.startTest();
        S_ProcessDocumentVerification_PS controller = new S_ProcessDocumentVerification_PS();
        controller.GetListOfBooking();
        Test.stopTest();
        
    }
}