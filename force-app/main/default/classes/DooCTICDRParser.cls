public class DooCTICDRParser {

	public String caller_id;
	public String extension_no;
	public String uniqueid;
	public String Call_Status;
	public Integer Talk_Time_Duration;
	public Integer After_Call_Work_Duration;
	public Integer Queue_Duration;
	public Integer Hold_Duration;
	public String Date_And_Time_Of_Call;
	public String Call_Recording_Link_Url;
	public String Queue;
	public String phone_number;
    public String callType;
    public String did;
    public String recordId;
	
	public static DooCTICDRParser parse(String json) {
		return (DooCTICDRParser) System.JSON.deserialize(json, DooCTICDRParser.class);
	}
}