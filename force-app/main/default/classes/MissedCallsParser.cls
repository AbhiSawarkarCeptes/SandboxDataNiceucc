Public Class MissedCallsParser {

    Public String mid {get;set;} 
    Public String number_Z {get;set;}
    Public String mtime {get;set;} 
    Public String status {get;set;} 
    Public String group_Z {get;set;}
    Public String tries {get;set;} 
    Public String inbound_tries {get;set;} 

    Public MissedCallsParser(JSONParser parser) {
        while(parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'mid') {
                        mid = parser.getText();
                    } else if (text == 'number') {
                        number_Z = parser.getText();
                    } else if (text == 'mtime') {
                        mtime = parser.getText();
                    } else if (text == 'status') {
                        status = parser.getText();
                    } else if (text == 'group') {
                        group_Z = parser.getText();
                    } else if (text == 'tries') {
                        tries = parser.getText();
                    } else if (text == 'inbound_tries') {
                        inbound_tries = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'MissedCallsParser consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    Public Static List<MissedCallsParser> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfMissedCallsParser(parser);
    }
    
    Public Static Void consumeObject(System.JSONParser parser) {
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
    
    private Static List<MissedCallsParser> arrayOfMissedCallsParser(System.JSONParser p) {
        List<MissedCallsParser> res = new List<MissedCallsParser>();
        if(p.getCurrentToken() == null) p.nextToken();
        while(p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new MissedCallsParser(p));
        }
        return res;
    }
}