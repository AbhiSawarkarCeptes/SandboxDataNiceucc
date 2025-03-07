public class CreateVisitorRegistrationParser {
	
    public String FileContent {get;set;}
    public String First_Name {get;set;} 
    public String Mobile {get;set;} 
    public String Email {get;set;} 
    public String Address {get;set;} 
    public String City {get;set;} 
    public String Last_Name {get;set;} 
    public String Country {get;set;} 
    public String UAE_Resident {get;set;} 
    public String Interested_In {get;set;} 
    public String Purpose_Of_Purchase {get;set;} 
    public String Remarks {get;set;} 
    public String Source {get;set;} 
    public String Agent_Name {get;set;} 
    public String Agent_Id {get;set;} 
    public String Company {get;set;} 
    public String Sales_Advisor {get;set;} 
    public String Date_Value {get;set;} 
    public String Time_Value {get;set;} 
    public String Nationality {get;set;} 
    
    public String Alternate_Email {get;set;}     
    public String AlternateEmail {get;set;} 
    public String Alternate_Mobile {get;set;} 
    public String Birth_Date {get;set;} 
    public String Designation {get;set;} 
    public String Existing_Sobha_Owner {get;set;} 
    public String Occupation {get;set;}   
    public String Project_Name {get;set;}
    public String Visiting_On_Behalf_Of {get;set;}
    public String Residential_Status {get;set;}
    public String subProject_Name {get;set;}
    public String uniqueId {get;set;}
    public String Sobha_Connect_name {get;set;}
    public String Sobha_Connect_Id {get;set;}
    public String Sobha_Connect_companyName {get;set;}
    public String Raw_Request_Body {get;set;}
    public String DocumentId {get;set;} 
    public String ScannedSource {get;set;}
    
    
    public String product_Type {get;set;}
    public String Budget {get;set;}
    public String possession_Timeline {get;set;}
    
    public CreateVisitorRegistrationParser(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'FileContent') {
                        FileContent = parser.getText();
                    } else if (text == 'First_Name') {
                        First_Name = parser.getText();
                    } else if (text == 'Mobile') {
                        Mobile = parser.getText();
                    } else if (text == 'Email') {
                        Email = parser.getText();
                    } else if (text == 'Address') {
                        Address = parser.getText();
                    } else if (text == 'City') {
                        City = parser.getText();
                    } else if (text == 'Last_Name') {
                        Last_Name = parser.getText();
                    } else if (text == 'Country') {
                        Country = parser.getText();
                    } else if (text == 'UAE_Resident') {
                        UAE_Resident = parser.getText();
                    } else if (text == 'Interested_In') {
                        Interested_In = parser.getText();
                    } else if (text == 'Purpose_Of_Purchase') {
                        Purpose_Of_Purchase = parser.getText();
                    } else if (text == 'Remarks') {
                        Remarks = parser.getText();
                    } else if (text == 'Source') {
                        Source = parser.getText();
                    } else if (text == 'Agent_Name') {
                        Agent_Name = parser.getText();
                    } else if (text == 'Agent_Id') {
                        Agent_Id = parser.getText();
                    } else if (text == 'Company') {
                        Company = parser.getText();
                    } else if (text == 'Sales_Advisor') {
                        Sales_Advisor = parser.getText();
                    } else if (text == 'Date_Value') {
                        Date_Value = parser.getText();
                    } else if (text == 'Time_Value') {
                        Time_Value = parser.getText();
                    } else if (text == 'Nationality') {
                        Nationality = parser.getText();
                    }else if (text == 'Alternate_Email') {
                        Alternate_Email = parser.getText();
                    }else if (text == 'AlternateEmail') {
                        AlternateEmail = parser.getText();
                    }else if (text == 'Alternate_Mobile') {
                        Alternate_Mobile = parser.getText();
                    }else if (text == 'Birth_Date') {
                        Birth_Date = parser.getText();
                    }else if (text == 'Designation') {
                        Designation = parser.getText();
                    }else if (text == 'Existing_Sobha_Owner') {
                        Existing_Sobha_Owner = parser.getText();
                    }else if (text == 'Occupation') {
                        Occupation = parser.getText();
                    }else if (text == 'Project_Name') {
                        Project_Name = parser.getText();
                    }else if (text == 'Visiting_On_Behalf_Of') {
                        Visiting_On_Behalf_Of = parser.getText();
                    }else if (text == 'Residential_Status') {
                        Residential_Status = parser.getText();
                    }else if(text == 'subProject_Name'){
                        subProject_Name = parser.getText();
                    }else if(text == 'uniqueId'){
                        uniqueId = parser.getText();
                    }else if(text == 'Sobha_Connect_name'){
                        Sobha_Connect_name = parser.getText();
                    }else if(text == 'Sobha_Connect_Id'){
                        Sobha_Connect_Id = parser.getText();
                    }else if(text == 'Sobha_Connect_companyName'){
                        Sobha_Connect_companyName = parser.getText();
                    }else if(text == 'Raw_Request_Body'){
                        Raw_Request_Body = parser.getText();
                    }else if(text == 'product_Type'){
                        product_Type = parser.getText();
                    }else if(text == 'Budget'){
                        Budget = parser.getText();
                    }else if(text == 'possession_Timeline'){
                        possession_Timeline = parser.getText();
                    }else if(text == 'DocumentId'){
                        DocumentId = parser.getText();
                    }else if(text == 'ScannedSource'){
                        ScannedSource = parser.getText();
                    }else {
                        System.debug(LoggingLevel.WARN, 'CreateLeadParser consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public static List<CreateVisitorRegistrationParser> parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return arrayOfCreateVRParser(parser);
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
    
    private static List<CreateVisitorRegistrationParser> arrayOfCreateVRParser(System.JSONParser p) {
        List<CreateVisitorRegistrationParser> res = new List<CreateVisitorRegistrationParser>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CreateVisitorRegistrationParser(p));
        }
        return res;
    }
}