@RestResource(urlMapping='/paymentRequest')
global class Mobile_PaymentRequest {

    @HttpPost
     global static void  createPaymentRequest(Decimal Amount,String Unit,String Mobile_Number,String Email,
                                              String Name,String EmiratesId,String InstrumentNumber,
                                              Date InstrumentDate,Date DateofInitiation,String Pop_Image,
                                              String CountryofInitiation,String Curr,Boolean Is_thirdpartypayment,
                                              String Thirdparty_DeclarationImage,String paymentType,String BookingId, String PopComments){          
         RestResponse res = RestContext.response;
         Savepoint sp = Database.setSavepoint();
         Payment_Request_Wrapper__c prw = null;
         try{
             Payment_Request__c pr = new Payment_Request__c();
             pr.Amount__c = Amount;
             pr.Pop_Amount__c = Amount;
             pr.Unit__c = Unit;
             
             if(!Mobile_Number.startsWith('971')){
                 pr.Mobile_Number__c = '971'+Mobile_Number; // This has to fixed in the Mobile App.
             } else {
                 pr.Mobile_Number__c = Mobile_Number;
             }
             pr.Email__c = Email;
             pr.Name__c = Name;
             pr.Emirates_Id_Passport_Number__c = EmiratesId;
             pr.POP_Comments__c = PopComments;
             if(InstrumentNumber != null){
                 pr.Instrument_Number__c = InstrumentNumber;
             }
             
             pr.Instrument_Date__c = InstrumentDate;
             pr.Date_of_Initiation__c = DateofInitiation;
             pr.Currency__c = curr; 
          //   pr.Amount__c = Pop_Image; 
             pr.Country_of_Initiation__c = CountryofInitiation; 
      //       pr.Amount__c = Is_thirdpartypayemnt;
         //    pr.Amount__c = Thirdparty_DeclarationImage;
             pr.Mode__c = paymentType;
             pr.Booking__c = BookingId; 
             pr.From_Booking__c  = true;
             pr.Mode_Option__c = 'Single Mode';
             
             if(paymentType == 'Website'){
                  prw = websitemode(pr, res);
             }else{
                 prw = otherModes(pr,res);
             }
    
             
  			pr.Amount_Towards__c = 'Unit Price'; // This has to changed from mobile app.
            pr.Towards_Unit_Price_Amount__c = Amount; 
            pr.Payment_Request_Wrapper__c = prw.Id; 
            pr.Payment_public_link__c = prw.Payment_Public_Page_Link__c;
            Insert pr;
             List<String> resbody = new List<String>();
             resbody.add(pr.Id);
             resbody.add(prw.Payment_Public_Page_Link__c);
             if(paymentType != 'Website'){
                 uploadFile(Pop_Image,pr.Id);                
             } 
             if(Is_thirdpartypayment){
                uploadFile(Thirdparty_DeclarationImage,pr.Id);  
             } 
             //resbody.add(paymentRequest.Name);
            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(resbody,'Success','OK',200,true)));
            res.statusCode = 200;
         }catch(Exception e){
            Database.rollBack(sp);
             Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'Mobile_PaymentRequest';
            insert logError;
            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;
        }
     }
    
    public static Payment_Request_Wrapper__c websitemode(Payment_Request__c pr, RestResponse res){
        try{
            Payment_Request_Wrapper__c prw = paymentrequestWrappercreation(pr);
            if(prw != null){
                insert prw;
            }

            Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');
            prw.Payment_Public_Page_Link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
            if(prw != null){
                update prw;
            }
            return prw;
        }catch(Exception e){
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'Mobile_PaymentRequest';
            insert logError;
            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;
            return null;
        }   
    }
    
    public static Payment_Request_Wrapper__c otherModes(Payment_Request__c pr, RestResponse res){
        try{
            Payment_Request_Wrapper__c prw = paymentrequestWrappercreation(pr);
            if(pr.Mode__c == 'CDM Cash' || pr.Mode__c == 'International Wire Transfer' || pr.Mode__c == 'Domestic Wire Transfer' || pr.Mode__c == 'CDM Cheque'){
                if(pr.Mode__c != 'CDM Cheque'){
                    Unit__c u = [select id, name,Tower__r.ESCROW_Account__c,Tower__r.ESCROW_Account__r.Name from unit__c where id =:pr.Unit__c];
                     if(u.Tower__r.ESCROW_Account__c != null){
                         pr.Account_Master__c = u.Tower__r.ESCROW_Account__c;
                     }else{ //TO BE Discussed
                         
                          res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,'ESCROW Account not mapped to the unit, please contact System Admin','Fail',400,false)));
                          res.statusCode = 400;
                     }
                }
                 

                    if(prw != null){
                        insert prw;
                    }
        
                    Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');
                    prw.Payment_Public_Page_Link__c = sobhaDefaultSettings.Payment_Community_Url__c +prw.id;
                    if(prw != null){
                        update prw;
                    }
                    
                 }
            return prw;
        }catch(Exception e){ 
            Error_Log__c logError = new Error_Log__c(Message__c = e.getMessage());
            logError.class__c = 'Mobile_PaymentRequest';
            insert logError;
            res.responseBody =  Blob.valueOf(JSON.serialize(prepareResponse(null,e.getMessage(),'Fail',400,false)));
            res.statusCode = 400;
            return null;
        }
    }
    
    public static void uploadFile( String base64Data, String parentId) {
        
        String[] fileType;
        String filename;
        String fileData;
        
        if(base64Data.contains(',')){
            filetype = base64Data.split(',');
            if(filetype[0].contains('pdf')){
            filename = 'POP.pdf';              
            }
            else{
                 filename = 'POP.jpg';   
            }
            fileData = filetype[1];
        } else {
            filename = 'POP.jpeg';
            fileData = base64Data;
        }
        
        	
            Blob imageBlob = EncodingUtil.base64Decode(fileData);
            ContentVersion cv = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient = filename,
                VersionData = imageBlob, 
                origin = 'H'
            );
            insert cv;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = parentId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
    }
    
    public static Payment_Request_Wrapper__c  paymentrequestWrappercreation(Payment_Request__c pr){
        Payment_Request_Wrapper__c prw = new Payment_Request_Wrapper__c();

                if(pr.Unit__c != null){
                    DateTime dt = System.now().addMinutes(30);
                    prw.Payment_Link_Expiry__c = dt;
                    prw.Customer_Name__c  = pr.Name__c;
                    if(pr.Mode__c != 'International Wire Transfer')
                        prw.Currency__c = 'AED';
                    else if(pr.Currency__c != null)
                        prw.Currency__c = pr.Currency__c; 
                    if(pr.Email__c != null)
                        prw.Email__c = pr.Email__c;
                    if(pr.Mobile_Number__c != null )
                        prw.Mobile_Number__c = pr.Mobile_Number__c;
                    if(pr.Mode__c != null )
                        prw.Mode__c = pr.Mode__c;
                    if(pr.Amount__c != null )
                        prw.Amount__c = Double.valueOf(pr.Amount__c);
                   
                    Unit__c u = [select Id, Name from Unit__c where Id =:pr.Unit__c ];
                    prw.Units__c = u.Name;
                     
                }
        return prw;
    }
    
    public static HttpResponseWrapper prepareResponse(list<string> rBody,string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.body = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    } 
    
    Public class HttpResponseWrapper{
        Public String status;
        Public Integer statusCode;
        Public list<String> body = new list<string>();
        Public boolean success;
        Public String Message;
    } 
}