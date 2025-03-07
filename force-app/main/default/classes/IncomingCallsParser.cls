public class IncomingCallsParser {

    public String starttime {get;set;} 
    public String extension {get;set;} 
    public String from_Z {get;set;} // in json: from
    public String DID {get;set;} 
    public String agent {get;set;} 
    public String direction {get;set;}
    public String uid {get; set;}
    public string CountryCode {get;set;}

    public IncomingCallsParser(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'starttime') {
                        starttime = parser.getText();
                    } else if (text == 'extension') {
                        extension = parser.getText();
                    } else if (text == 'from') {
                        from_Z = parser.getText();
                    } else if (text == 'CountryCode') {
                        CountryCode = parser.getText();
                    }else if (text == 'DID') {
                        DID = parser.getText();
                    } else if (text == 'agent') {
                        agent = parser.getText();
                    } else if (text == 'direction') {
                        direction = parser.getText();
                    } else if (text == 'uid') {
                        uid = parser.getText();
                    }else {
                        System.debug(LoggingLevel.WARN, 'IncomingCallsParser consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public static List<IncomingCallsParser> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfIncomingCallsParser(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    private static List<IncomingCallsParser> arrayOfIncomingCallsParser(System.JSONParser p) {
        List<IncomingCallsParser> res = new List<IncomingCallsParser>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new IncomingCallsParser(p));
        }
        return res;
    }
}