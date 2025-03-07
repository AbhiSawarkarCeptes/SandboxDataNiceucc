@isTest
public class InventoryController_Test {
    @isTest
    public static void testGetStateNameViaGeo() {
        InventoryController controller = new InventoryController();

        String longitude = '12.34';
        String latitude = '56.78';

        Test.setMock(HttpCalloutMock.class, new InventoryControllerMock_Test());

        Test.startTest();
        List<String> stateList = InventoryController.getStateNameViaGeo(longitude, latitude);
        Test.stopTest();
        System.assertEquals(2, stateList.size()); 
    }
}