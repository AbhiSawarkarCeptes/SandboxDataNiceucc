@isTest
public class LeadDownloadReportAPITest {
	@isTest public static void testLeadDownloadReportAPI_Positive() {
        Test.setMock(HttpCalloutMock.class, new LeadDownloadReportAPIMock());  
        LeadDownloadReportAPI.DownloadReportResponseWrapper strResp = LeadDownloadReportAPI.doPost();
        LeadDownloadReportAPI.insertErrorLog('Test','Test');
    }
}