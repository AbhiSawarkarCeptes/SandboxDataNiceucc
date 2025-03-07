@isTest
public class Utilities_Test {
    @isTest
    static void testutilities(){
        Account acc = TestDataFactorySobha.createAccount(null);
        insert acc;
        Test.startTest();
        String s = Utilities.changeToWords('21',true);
        String s33 = Utilities.translateWholeNumber('21');
        String s34 = Utilities.translateWholeNumber('211');
        String s35 = Utilities.translateWholeNumber('2111');
        String s36 = Utilities.translateWholeNumber('21111');
        String s37 = Utilities.translateWholeNumber('211111');
        String s6 = Utilities.translateWholeNumber('2111111');
        String s7 = Utilities.tens('11');
        String s10 = Utilities.tens('12');
        String s11 = Utilities.tens('13');
        String s12 = Utilities.tens('14');
        String s13 = Utilities.tens('15');
        String s14 = Utilities.tens('16');
        String s15 = Utilities.tens('17');
        String s16 = Utilities.tens('18');
        String s17 = Utilities.tens('19');
        String s18 = Utilities.tens('30');
        String s19 = Utilities.tens('40');
        String s20 = Utilities.tens('50');
        String s21 = Utilities.tens('60');
        String s22 = Utilities.tens('70');
        String s23 = Utilities.tens('80');
        String s24 = Utilities.tens('90');
        String s8 = Utilities.ones('1');
        String s25 = Utilities.ones('2');
        String s26 = Utilities.ones('3');
        String s27 = Utilities.ones('4');
        String s28 = Utilities.ones('5');
        String s29 = Utilities.ones('6');
        String s30 = Utilities.ones('7');
        String s31 = Utilities.ones('8');
        String s32 = Utilities.ones('9');
        String s9 = Utilities.translateCents('100');
        //List<Schema.FieldSetMember> fld = Utilities.readFieldSet('Name','Account');
        List<String> stringList = new List<String>{'Apple', 'Banana', 'Orange'};
        Utilities util = new Utilities();
        String s1 = util.line(stringList);
        String s2 = util.format(System.today());
        String s3 = util.format('Hello');
        String s4 = util.format(2.3);
        String s5 = util.format(2.55, 1);
        
        Attachment attachment = new Attachment();
        attachment.ParentId = acc.Id;
        attachment.Name = 'Test.pdf';
        attachment.Body = Blob.valueOf('Test Data');  
        insert attachment;
        Utilities.doSavePDFAttachment(acc.Id, 'SRCustomer_Copy', 'Test');
        
        Attachment attachment2 = new Attachment();
        attachment2.ParentId = acc.Id;
        attachment2.Name = 'Test.html';
        attachment2.Body = Blob.valueOf('Test Data');  
        insert attachment2;
        Utilities.doSavePDFAttachment(acc.Id, 'SRCustomer_Copy', 'Test');
        Test.stopTest();

    }
}