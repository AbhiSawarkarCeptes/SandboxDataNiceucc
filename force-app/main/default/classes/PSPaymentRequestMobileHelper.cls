global class PSPaymentRequestMobileHelper {
    global Static String GetPaymentRequestMobile(RestRequest request) {
        String responce = '';
        String statusCode = '';
        String jsonString = '';
        if (request != null && 
            request.requestBody != null) {
                JSONGenerator gen = JSON.createGenerator(true);
                try {
                    jsonString = request.requestBody.toString();
                    System.debug('jsonString*---'+jsonString);
                    boolean popImage = false;
                    boolean thirdpartypayment = false;
                    Id prWrapper;
                    RequestWrapper objcase = (RequestWrapper)System.JSON.deserialize(jsonString,RequestWrapper.class);
                     System.debug('objcase*---'+objcase);
                    if(objcase != null) {
                        set<String> propertyIds = new set<String>();
                        map<String,PropStrength__Application_Booking__c> bookingMap = new map<String,PropStrength__Application_Booking__c>();
                        if(objcase.Amount == null || 
                           objcase.Unit == null ||
                           String.isBlank(objcase.Email) ||
                           //String.isBlank(objcase.Mobile_Number) ||
                           String.isBlank(objcase.Name) ||
                           String.isBlank(objcase.EmiratesId)) {
                               statusCode = '400';
                               gen.writeStartObject();     
                               gen.writeBooleanField('success', false);
                               gen.writeNumberField('statusCode', 400);
                               gen.writeStringField('status', 'Error');
                               gen.writeStringField('Message', 'Amount OR Unit  OR Email OR Name OR Emirates Id  is Required.');
                               gen.writeFieldName('body');
                               gen.writeStartArray();
                               gen.writeEndArray();
                               gen.writeEndObject();
                               responce = gen.getAsString();
                           } 
                        else {
                               if(objcase.BookingId != null) {
                                   propertyIds.add(objcase.BookingId);
                               }
                               system.debug('propertyIds::'+propertyIds);
                               if(!propertyIds.isEmpty()) {
                                   List<PropStrength__Application_Booking__c> bookingList = [SELECT Id,Name,PropStrength__Property__c,PropStrength__Active__c,PropStrength__Primary_Customer__c
                                                                                              FROM PropStrength__Application_Booking__c 
                                                                                              WHERE Id IN: propertyIds AND
                                                                                              PropStrength__Active__c =: true];
                                   if(!bookingList.isEmpty()) {
                                       for(PropStrength__Application_Booking__c book : bookingList) {
                                           if(book.Id != null) {
                                               String id18 = book.Id;
                                               String id15 = id18.substring(0, 15);
                                               bookingMap.put(id18,book);
                                               //bookingMap.put(id15,book);
                                           }
                                       }
                                   }
                               }
                               Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');
                               system.debug('bookingMap::'+bookingMap);
                               system.debug('objcase.BookingId::'+objcase.BookingId);
                               system.debug('bookingMap.ContainsKey::'+bookingMap.ContainsKey(objcase.BookingId));
                               if(bookingMap.ContainsKey(objcase.BookingId)) {
                                   if(!String.isBlank(objcase.paymentType)) { //
                                       Payment_Request_Wrapper__c wrap = new Payment_Request_Wrapper__c();
                                       wrap.Email__c = objcase.Email != null ? objcase.Email : null;
                                       wrap.Mobile_Number__c = objcase.Mobile_Number != null ? objcase.Mobile_Number : null;
                                       wrap.Currency__c = objcase.Curr != null ? objcase.Curr : null;
                                       wrap.Customer_Name__c = objcase.Name != null ? objcase.Name : null;
                                       wrap.Amount__c = objcase.Amount != null ? Decimal.valueOf(objcase.Amount) : null;
                                       wrap.Mobile_Mode_App__c = (objcase.paymentType == 'CDM Cash' ? 'CDM Cash (Cash Deposit in Machine)' : 
                                                                  objcase.paymentType == 'CDM Cheque' ? 'CDM Cheque (Cheque Deposit in Machine)' :
                                                                  objcase.paymentType == 'International Wire Transfer' ? 'IWT(International)' :
                                                                  objcase.paymentType == 'Domestic Wire Transfer' ? 'DWT(Domestic)' : objcase.paymentType);
                                       system.debug('wrap.Mobile_Mode_App__c::'+wrap.Mobile_Mode_App__c);
                                       wrap.Units__c = objcase.Unit != null ? objcase.Unit : null;                                       
                                       Database.SaveResult saveResult = Database.insert(wrap, false);
                                       if(saveResult.isSuccess()) {
                                           prWrapper = saveResult.getId();
                                       }
                                   }
                                   system.debug('prWrapper::'+prWrapper);
                                   Payment_Request_Wrapper__c payWrap = new Payment_Request_Wrapper__c();
                                   payWrap.id = prWrapper ;
                                   payWrap.Payment_Public_Page_Link_Copy__c = sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c + prWrapper;
                                   try{
                                       update payWrap;
                                   }
                                   catch(exception e){
                                       
                                   }
                                   Payment_Request__c payRequest = new Payment_Request__c();
                                   //payRequest.Property__c = objcase.Unit != null ? objcase.Unit : null;
                                   payRequest.Towards_Unit_Price_Amount__c = objcase.Amount != null ? Decimal.valueOf(objcase.Amount) : null;
                                   payRequest.Amount__c = objcase.Amount != null ? Decimal.valueOf(objcase.Amount) : null;
                                   payRequest.Mobile_Number__c = objcase.Mobile_Number != null ? objcase.Mobile_Number : null;
                                   payRequest.Email__c = objcase.Email != null ? objcase.Email : null;
                                   payRequest.Name__c = objcase.Name != null ? objcase.Name : null;
                                   payRequest.Emirates_Id_Passport_Number__c = objcase.EmiratesId != null ? objcase.EmiratesId : null;
                                   payRequest.Instrument_Number__c = objcase.InstrumentNumber != null ? objcase.InstrumentNumber : null;
                                   payRequest.Instrument_Date__c = objcase.InstrumentDate != null ? Date.valueOf(objcase.InstrumentDate) : null;
                                   payRequest.Date_of_Initiation__c = objcase.DateofInitiation != null ? Date.valueOf(objcase.DateofInitiation) : null;
                                   payRequest.Country_of_Initiation__c = objcase.CountryofInitiation != null ? objcase.CountryofInitiation : null;
                                   payRequest.Currency__c = objcase.Curr != null ? objcase.Curr : null;
                                   //payRequest.Property__c = objcase.Unit != null ? objcase.Unit : null;
                                   payRequest.Third_Party__c = objcase.Is_thirdpartypayment != null ? objcase.Is_thirdpartypayment : null;
                                   if(prWrapper != null) {
                                       payRequest.Payment_Request_Wrapper__c = prWrapper;
                                   }
                                   payRequest.From_Booking__c = true;
                                   payRequest.Mobile_Mode_App__c = (objcase.paymentType == 'CDM Cash' ? 'CDM Cash (Cash Deposit in Machine)' : 
                                                                    objcase.paymentType == 'CDM Cheque' ? 'CDM Cheque (Cheque Deposit in Machine)' :
                                                                    objcase.paymentType == 'International Wire Transfer' ? 'IWT(International)' :
                                                                    objcase.paymentType == 'Domestic Wire Transfer' ? 'DWT(Domestic)' : objcase.paymentType);
                                   system.debug('payRequest.Mobile_Mode_App__c::'+payRequest.Mobile_Mode_App__c);
                                   payRequest.Application_Booking__c = bookingMap.get(objcase.BookingId).Id == objcase.BookingId && 
                                                                       objcase.BookingId != null ? objcase.BookingId : null;
                                   payRequest.POP_Comments__c = objcase.PopComments != null ? objcase.PopComments : null;
                                   Database.SaveResult saveResult = Database.insert(payRequest, false);
                                   if(saveResult.isSuccess()) {
                                       PropStrength__Service_Request__c sr = new PropStrength__Service_Request__c();
                                       sr.RecordtypeId = Schema.SObjectType.PropStrength__Service_Request__c.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
                                       sr.Contact__c = bookingMap.get(objcase.BookingId).Id == objcase.BookingId && 
                                                       objcase.BookingId != null ? bookingMap.get(objcase.BookingId).PropStrength__Primary_Customer__c : null;
                                       sr.PropStrength__Request_Origin__c = 'Mobile App';
                                       sr.SR_Department__c = 'CRM';
                                       sr.SR_Category__c = 'Payment Request Created';
                                       sr.SR_Sub_Category__c = 'Others';
                                       sr.PropStrength__Priority__c = 'Medium';
                                       sr.PropStrength__Application_Booking__c = bookingMap.get(objcase.BookingId).Id == objcase.BookingId && 
                                                                                 objcase.BookingId != null ? objcase.BookingId : null;
                                       sr.PropStrength__Status__c = 'New';
                                       sr.Payment_Request__c = saveResult.getId();
                                       insert sr;
                                       if(objcase.Pop_Image != null &&
                                          objcase.Pop_Image != '') {
                                           String msg = PSPaymentRequestMobileHelper.createAttachment(EncodingUtil.base64Decode(objcase.Pop_Image),
                                                                                                     'Pop_Image',saveResult.getId());
                                           if(msg != 'Success') {
                                               popImage = false;statusCode = '400';gen.writeStartObject();gen.writeBooleanField('success', false);gen.writeNumberField('statusCode', 400);gen.writeStringField('status', 'Error');gen.writeStringField('Message', msg);gen.writeFieldName('body');gen.writeStartArray();gen.writeEndArray();gen.writeEndObject();responce = gen.getAsString();
                                           } else {
                                               popImage = true;
                                           }
                                       }
                                       if(objcase.Thirdparty_DeclarationImage != null &&
                                          objcase.Thirdparty_DeclarationImage != '') {
                                           String msg = PSPaymentRequestMobileHelper.createAttachment(EncodingUtil.base64Decode(objcase.Thirdparty_DeclarationImage),
                                                                                                     'Thirdparty_DeclarationImage',saveResult.getId());
                                           if(msg != 'Success') {
                                               statusCode = '400';thirdpartypayment = false;gen.writeStartObject();gen.writeBooleanField('success', false);gen.writeNumberField('statusCode', 400);gen.writeStringField('status', 'Error');gen.writeStringField('Message', msg);gen.writeFieldName('body');gen.writeStartArray();gen.writeEndArray();gen.writeEndObject();responce = gen.getAsString();
                                           } else {
                                               thirdpartypayment = true;
                                           }
                                       }
                                       if((!String.isBlank(objcase.Pop_Image) && popImage &&
                                           thirdpartypayment &&
                                           !String.isBlank(objcase.Thirdparty_DeclarationImage)) || (!String.isBlank(objcase.Pop_Image) && popImage && String.isBlank(objcase.Thirdparty_DeclarationImage)) || (String.isBlank(objcase.Pop_Image) && !String.isBlank(objcase.Thirdparty_DeclarationImage) && thirdpartypayment) || (String.isBlank(objcase.Pop_Image) && popImage == false && thirdpartypayment == false && String.isBlank(objcase.Thirdparty_DeclarationImage))) {
                                               statusCode = '200';
                                               gen.writeStartObject();     
                                               gen.writeBooleanField('success', true);
                                               gen.writeNumberField('statusCode', 200);
                                               gen.writeStringField('status', 'OK');
                                               gen.writeStringField('Message', 'Success');
                                               gen.writeFieldName('body');
                                               gen.writeStartArray();
                                               gen.writeString(saveResult.getId());
                                               System.debug('payWrap/*----'+payWrap);
                                               System.debug('payWrap/*----'+payWrap.Payment_Public_Page_Link_Copy__c);
                                               //if(payWrap != null && payWrap.Payment_Public_Page_Link_Copy__c != null)
                                                    gen.writeString(sobhaDefaultSettings.Payment_Public_Page_URL_Copy__c +prWrapper);
                                               gen.writeEndArray();
                                               gen.writeEndObject();
                                               responce = gen.getAsString();
                                       }
                                   } else {
                                       statusCode = '400';
                                       gen.writeStartObject();     
                                       gen.writeBooleanField('success', false);
                                       gen.writeNumberField('statusCode', 400);
                                       gen.writeStringField('status', 'Error');
                                       gen.writeStringField('Message', String.valueOf(saveResult.getErrors()));
                                       gen.writeFieldName('body');
                                       gen.writeStartArray();
                                       gen.writeEndArray();
                                       gen.writeEndObject();
                                       responce = gen.getAsString();
                                   }
                               } else {
                                   statusCode = '400';
                                   gen.writeStartObject();     
                                   gen.writeBooleanField('success', false);
                                   gen.writeNumberField('statusCode', 400);
                                   gen.writeStringField('status', 'Error');
                                   gen.writeStringField('Message', 'No Record Found!!!');
                                   gen.writeFieldName('body');
                                   gen.writeStartArray();
                                   gen.writeEndArray();
                                   gen.writeEndObject();
                                   responce = gen.getAsString();
                               }
                           }
                    } 
                } catch(Exception e) {
                    statusCode = '400';
                    gen.writeStartObject();     
                    gen.writeBooleanField('success', false);
                    gen.writeNumberField('statusCode', 400);
                    gen.writeStringField('status', 'Error');
                    gen.writeStringField('Message', String.valueOf(e.getMessage()));
                    gen.writeFieldName('body');
                    gen.writeStartArray();
                    gen.writeEndArray();
                    gen.writeEndObject();
                    responce = gen.getAsString();
                    System.debug('Catch:-'+ e.getMessage() + 'Line Num:- '+e.getLineNumber());
                }
            }
        Mobile_App_Log__c logError = new Mobile_App_Log__c();
        logError.Response_Body__c = responce;
        logError.Class_Name__c = 'PSPaymentRequestMobileHelper';
        logError.API_Name__c = '/services/apexrest/paymentRequest_Dummy/';
        logError.Status__c = statusCode;
        logError.Request_Body__c = JSON.serialize(jsonString);
        insert logError;
        return responce;
    }
    
    public static String createAttachment(Blob imageBlob,String fileName,Id parentId) {
        String msg = '';
        ContentVersion cv = new ContentVersion();
        cv.Origin = 'H';
        cv.VersionData = imageBlob;
        cv.PathOnClient = fileName;
        cv.title = fileName;
        Database.SaveResult saveContentVersion = Database.insert(cv);
        if(saveContentVersion.isSuccess()) {
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :saveContentVersion.getId() LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = parentId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            Database.SaveResult saveContent = Database.insert(contentlink);
            if(saveContent.isSuccess()) {
                msg = 'Success';
            } else {
                msg = String.valueOf(saveContent.getErrors());
            }
        } else {
            msg = String.valueOf(saveContentVersion.getErrors());
        }
        return msg;
    }
    
    public class RequestWrapper{
        public String Amount; 
        public String Unit; 
        public String Mobile_Number;
        public String Email;
        public String Name;
        public String EmiratesId; 
        public String InstrumentNumber; 
        public String InstrumentDate; 
        public String DateofInitiation;
        public String Pop_Image;
        public String CountryofInitiation;
        public String Curr;
        public boolean Is_thirdpartypayment;
        public String Thirdparty_DeclarationImage;
        public String paymentType;
        public String BookingId; 
        public String PopComments;
    }
}