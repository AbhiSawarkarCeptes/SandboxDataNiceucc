@isTest
public class HandoverNoticePageControllerTest {    
    @isTest
    static void testControllerWithoutParameters() {
        ApexPages.currentPage().getParameters().clear();
        HandoverNoticePageController controller = new HandoverNoticePageController();
        System.assertEquals(null, controller.booking.Id, 'The booking Id should be null when no parameter is provided.');
    }
}