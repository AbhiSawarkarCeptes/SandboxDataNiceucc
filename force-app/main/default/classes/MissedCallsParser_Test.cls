@IsTest
Public Class MissedCallsParser_Test {
    
    Static testMethod void testParse() {
        String json = '[{\"mid\":\"100\",\"number\":\"042924333\",\"mtime\":\"1557313211\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"},{\"mid\":\"101\",\"number\":\"043555582\",\"mtime\":\"1557641699\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"1\"},{\"mid\":\"102\",\"number\":\"0564017612\",\"mtime\":\"1558000832\",\"status\":\"0\",\"group\":\"8\",\"tries\":\"0\",\"inbound_tries\":\"2\"}]';
        List<MissedCallsParser> r = MissedCallsParser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        MissedCallsParser objMissedCallsParser = new MissedCallsParser(System.JSON.createParser(json));
        System.assert(objMissedCallsParser != null);
        System.assert(objMissedCallsParser.mid == null);
        System.assert(objMissedCallsParser.number_Z == null);
        System.assert(objMissedCallsParser.mtime == null);
        System.assert(objMissedCallsParser.status == null);
        System.assert(objMissedCallsParser.group_Z == null);
        System.assert(objMissedCallsParser.tries == null);
        System.assert(objMissedCallsParser.inbound_tries == null);
    }
}