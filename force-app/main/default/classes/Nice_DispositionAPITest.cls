/******************************************************
    Class : Nice_DispositionAPI
    Test Class : Nice_DispositionAPITest 96%
    Purpose : NICE - This Apex class updates the disposition of a NICE contact by making a callout to the NICE API, attaching a specified tag to a given calling session using an authorization token.
    Author : Artee Varma
 *******************************************************/

@isTest
public class Nice_DispositionAPITest {
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        public MockHttpResponseGenerator(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            if (statusCode == 200) {
                response.setBody('{"access_token":"testAccessToken123"}');
            } else {
                response.setBody('{"error":"Internal Server Error"}');
            }
            return response;
        }
    }

    @isTest
    static void testPostToUpdateDisposition_with200StatusCode() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200));
        String taskId = 'testTaskId';
        String callingId = 'testCallingId';
        String tagId = '12345';
        Test.startTest();
        Nice_DispositionAPI.postToUpdateDisposition(taskId, callingId, tagId);
        Test.stopTest();
    }

    @isTest
    static void testPostToUpdateDisposition_withNon200StatusCode() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500));
        String taskId = 'testTaskId';
        String callingId = 'testCallingId';
        String tagId = '12345';
        Test.startTest();
        try {
            Nice_DispositionAPI.postToUpdateDisposition(taskId, callingId, tagId);
        } catch (Exception e) {
            System.assertEquals('Internal Server Error', e.getMessage());
        }
        Test.stopTest();
    }
}