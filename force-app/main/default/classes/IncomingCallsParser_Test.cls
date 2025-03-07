@IsTest
public class IncomingCallsParser_Test {
    
    static testMethod void testParse() {
        String json = '['+
        '   {'+
        '       \"starttime\":\"2019-02-13 12:52:46\",'+
        '       \"extension\":\"231\",'+
        '       \"from\":\"9447111230\",'+
        '       \"DID\":\"231\",'+
        '       \"agent\":\"anil\",'+
        '       \"callType\":\"Incoming\"'+
        '   }'+
        ']';
        List<IncomingCallsParser> r = IncomingCallsParser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        IncomingCallsParser objIncomingCallsParser = new IncomingCallsParser(System.JSON.createParser(json));
        System.assert(objIncomingCallsParser != null);
        System.assert(objIncomingCallsParser.starttime == null);
        System.assert(objIncomingCallsParser.extension == null);
        System.assert(objIncomingCallsParser.from_Z == null);
        System.assert(objIncomingCallsParser.DID == null);
        System.assert(objIncomingCallsParser.agent == null);
        //System.assert(objIncomingCallsParser.callType == null);
    }
}