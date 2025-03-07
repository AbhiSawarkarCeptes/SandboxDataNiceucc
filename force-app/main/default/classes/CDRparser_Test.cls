@IsTest
public class CDRparser_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '['+
        '    {'+
        '        \"calldate\": \"2019-04-24 19:24:47\",'+
        '        \"src\": \"101\",'+
        '        \"dst\": \"0545549067\",'+
        '        \"duration\": \"15\",'+
        '        \"uniqueid\": \"1556119481.14\",'+
        '        \"recordingfile\": \"20190424-192447-101.wav\",'+
        '        \"xdispo\": \"CANCEL\",'+
        '        \"recordingurl\": \"http://10.150.5.230/recordings/2019/04/24/20190424-192447-101.wav\"'+
        '    }'+
        ']';
        List<CDRparser> r = CDRparser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        CDRparser objCDRparser = new CDRparser(System.JSON.createParser(json));
        System.assert(objCDRparser != null);
        System.assert(objCDRparser.calldate == null);
        System.assert(objCDRparser.src == null);
        System.assert(objCDRparser.dst == null);
        System.assert(objCDRparser.duration == null);
        System.assert(objCDRparser.uniqueid == null);
        System.assert(objCDRparser.recordingfile == null);
        System.assert(objCDRparser.xdispo == null);
        System.assert(objCDRparser.recordingurl == null);
    }
}