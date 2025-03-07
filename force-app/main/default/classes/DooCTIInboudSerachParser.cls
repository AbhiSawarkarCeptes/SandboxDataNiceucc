public with sharing class DooCTIInboudSerachParser {
    
    public String caller_id;
    public String phone_number;
    public String Date_And_Time_Of_Call;
    public String extension_no;
    public String uniqueId;
    public String callType;
    public String Queue;
    public boolean Is_Voicemail;
    public String Voicemail_Recording_Link_Url;
    public String did;
    
    public static DooCTIInboudSerachParser parse(String json) {
        return (DooCTIInboudSerachParser) System.JSON.deserialize(json, DooCTIInboudSerachParser.class);
    }
}