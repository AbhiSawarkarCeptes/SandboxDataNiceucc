public class PSUploadDocumentMobilePOJO {

	public String base64Data {get;set;} 
	public String parentId {get;set;} 
	public String fileName {get;set;} 
	public String isthirdpartydoc {get;set;} 

	public PSUploadDocumentMobilePOJO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'base64Data') {
						base64Data = parser.getText();
					} else if (text == 'parentId') {
						parentId = parser.getText();
					} else if (text == 'fileName') {
						fileName = parser.getText();
					} else if (text == 'isthirdpartydoc') {
						isthirdpartydoc = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static PSUploadDocumentMobilePOJO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new PSUploadDocumentMobilePOJO(parser);
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
}