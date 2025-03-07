@isTest
public class NumberToWordsConverter_Test {
	@isTest
    static void testNumberToWordsConverter() {
        Test.startTest();
        NumberToWordsConverter.convertToWords(56999.90);
        Test.stopTest();
    }
}