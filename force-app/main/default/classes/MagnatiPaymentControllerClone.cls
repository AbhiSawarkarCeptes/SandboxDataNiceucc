/*********************************************************************
 * Class Name  :   MagnatiPaymentControllerClone
 * Description :   Update CCAveune payment to Magnati Payment - Controller Class
 * Created Date:   17/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 17/01/2024
						Nishank Manwani 27/08/2024
 *********************************************************************/
public without sharing class MagnatiPaymentControllerClone {
    //Added by Nishank Manwani on 17/01/2024 to Generate Magnati Transaction Callout Method
    @AuraEnabled
    public static String generateMagnatiTransaction(String prwId){
        Payment_Request_Wrapper__c paymentInst = [SELECT Id, 
                        Amount__c,
                        Name, 
                        Customer_Name__c, 
                        Currency__c, 
                        Email__c, 
                        Units__c,
                        Mobile_Number__c,
                        (SELECT Id, Name, Payment_Public_Link__c, Payment_Public_Link_Copy__c, OwnerId, Mode_Option__c FROM Payment_Requests__r ORDER By CreatedDate Desc LIMIT 1)
                        FROM Payment_Request_Wrapper__c 
                        WHERE Id =:prwId];
        try {
            Payment_Request__c paymentRequest = [SELECT Id, Application_Booking__c, Payment_Request_Wrapper__c, Property__c, Property__r.PropStrength__Project_Name__c, Property__r.PropStrength__Project_Name__r.Master_Project__r.Siniya_Island_Project__c, Application_Booking__r.PropStrength__Property__c, Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c, Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__r.Master_Project__r.Siniya_Island_Project__c FROM Payment_Request__c WHERE Payment_Request_Wrapper__c = :PRWid LIMIT 1];

            Map<String, String> eInvoiceMap = new Map<String, String>();
            Magnati__mdt magnatimdt = Magnati__mdt.getInstance(System.Label.Magnati_Meta_Data);
            Map<String, RegistrationWrapper> registrationMap = new Map<String, RegistrationWrapper>();
            RegistrationWrapper registInst = new RegistrationWrapper();
            registInst.Currencyy = 'AED';
            String url = '';
            if(paymentInst.Payment_Requests__r[0]?.Payment_Public_Link_Copy__c != null && paymentInst.Payment_Requests__r[0]?.Payment_Public_Link_Copy__c != '') {
                url = paymentInst.Payment_Requests__r[0]?.Payment_Public_Link_Copy__c.substringBeforeLast('/');
            }
            registInst.ReturnPath = url + '?prwId=' + paymentInst.Id + '&isPaymentInitiated=true';
            registInst.TransactionHint = magnatimdt.TransactionHint__c;
            registInst.OrderInfo = paymentInst.Payment_Requests__r[0]?.Name?.replace('PR-', '');
            registInst.OrderID = paymentInst.Name.replace('PRW-', '');
            registInst.Channel = 'Web';
            registInst.Amount = String.valueOf(paymentInst.Amount__c);
            registInst.Customer = magnatimdt.Customer__c;
            registInst.OrderName = paymentInst.Units__c != null ? paymentInst.Units__c : '';
            if(paymentInst.Units__c!= null && paymentInst.Units__c.length() > 25){
                registInst.OrderName = paymentInst.Units__c != null ? paymentInst.Units__c.substring(0, 25) : '';
            }
            System.debug('paymentInst.Units__c*----'+paymentInst.Units__c);
            registInst.UserName = magnatimdt.UserName__c;
            registInst.Password = magnatimdt.Password__c;
            //ExtraDataWrapper extraData = new ExtraDataWrapper('MerchantDescriptor', 'TransactionDescriptor');
            ExtraDataWrapper extraData;
            if (paymentRequest != null && ((paymentRequest.Property__c != null && paymentRequest.Property__r.PropStrength__Project_Name__c != null && paymentRequest.Property__r.PropStrength__Project_Name__r.Master_Project__r.Siniya_Island_Project__c) || (paymentRequest.Application_Booking__c != null && paymentRequest.Application_Booking__r.PropStrength__Property__c != null && paymentRequest.Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__c != null && paymentRequest.Application_Booking__r.PropStrength__Property__r.PropStrength__Project_Name__r.Master_Project__r.Siniya_Island_Project__c))) {
                registInst.Store = magnatimdt.Store__c;
                registInst.Terminal = magnatimdt.Terminal__c;
                extraData = new ExtraDataWrapper(magnatimdt.Siniya_Merchant_Descriptor__c/*,magnatimdt.Siniya_Transaction_Descriptor__c*/);
            }
            
            extraData = extraData == null ? new ExtraDataWrapper(magnatimdt.Merchant_Descriptor__c/*,magnatimdt.Transaction_Descriptor__c*/) : extraData;

            registInst.ExtraData = extraData;
            registrationMap.put('Registration', registInst);
	System.debug(registInst);
            System.debug(registrationMap);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(magnatimdt.End_Point__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setMethod('POST');
            request.setBody(JSON.serialize(registrationMap).replace('Currencyy', 'Currency'));
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            Payment_Request_Wrapper__c prwUpsert = new Payment_Request_Wrapper__c(Id = prwId);
            Magnati_Transaction_History__c historyInst = new Magnati_Transaction_History__c();
            if(response.getStatusCode() == 200) {
                Map<String, TransactionResponseWrapper> responseMap = (Map<String, TransactionResponseWrapper>) JSON.deserialize(response.getBody(), Map<String, TransactionResponseWrapper>.class);
                System.debug('responseMap======>'+ responseMap);
                if(responseMap?.get('Transaction').ResponseCode == '0'){
                    prwUpsert.Payment_Transaction_Tracking_Id__c = responseMap.get('Transaction').TransactionID;
                    Payment_Request__c paymentRequestInst = new Payment_Request__c();
                    paymentRequestInst.Payment_Transaction_Tracking_Id__c = responseMap.get('Transaction').TransactionID;
                    paymentRequestInst.Id = paymentInst.Payment_Requests__r[0]?.Id;
                    paymentRequestInst.Payment_Link_Status__c = 'Active';
                    update paymentRequestInst;

                    historyInst.Payment_Request_JSON__c = JSON.serialize(registrationMap).replace('Currencyy', 'Currency');
                    historyInst.Payment_Request_Wrapper__c = prwId;
                    historyInst.TransactionID__c = responseMap.get('Transaction').TransactionID;
                    historyInst.Payment_Response_JSON__c = JSON.serialize(responseMap);
                    historyInst.PRnumber__c = paymentInst.Payment_Requests__r[0]?.Name.replace('PR-', '');
                    historyInst.Unit__c = paymentInst.Units__c;
                    historyInst.OwnerId = paymentInst.Payment_Requests__r[0]?.OwnerId;
                    historyInst.Payment_URL__c = responseMap.get('Transaction').PaymentPortal;
                    historyInst.Payment_Attempt__c = [SELECT COUNT() FROM Magnati_Transaction_History__c WHERE Payment_Request_Wrapper__c = :prwId] + 1;
                    insert historyInst;
                }
            }
            update prwUpsert;
            return JSON.serialize(historyInst);
        } catch (Exception ex){
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'MagnatiPaymentControllerClone';
            log.Name = 'Error in MagnatiPaymentControllerClone';
            log.Message__c = ex.getMessage();
            insert log;
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //Added by Nishank Manwani on 17/01/2024 to Check Transaction Status Success/Failure
    @AuraEnabled
    public static String checkTransactionStatus(String prwId){
        try {
            List<Magnati_Transaction_History__c> historyList = new List<Magnati_Transaction_History__c>();
            historyList = [SELECT Id, TransactionId__c, Payment_Request_Wrapper__r.Customer_Name__c, Payment_Request_Wrapper__r.Email__c,
                           Payment_Request_Wrapper__r.Mobile_Number__c
                           FROM Magnati_Transaction_History__c
                           WHERE Payment_Request_Wrapper__c = :prwId AND Status_Fetched__c = false
                           ORDER BY CreatedDate DESC
                           LIMIT 1];
            Map<String, TransactionResponseWrapper> responseMap = new Map<String, TransactionResponseWrapper>();
            if(!historyList.isEmpty()){
                Map<String, Map<String, String>> statusBodyMap = new Map<String, Map<String, String>>();
                Map<String, String> detailMap = new Map<String, String>();
                Magnati__mdt magnatimdt = Magnati__mdt.getInstance(System.Label.Magnati_Meta_Data);
                detailMap.put('TransactionID', historyList[0].TransactionId__c);
                detailMap.put('Customer', magnatimdt.Customer__c);
                detailMap.put('UserName', magnatimdt.UserName__c);
                detailMap.put('Password', magnatimdt.Password__c);
                statusBodyMap.put('Finalization', detailMap);
				System.debug(detailMap);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(magnatimdt.End_Point__c);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Accept', 'application/json');
                request.setMethod('POST');
                request.setBody(JSON.serialize(statusBodyMap));
                request.setTimeout(120000);
                HttpResponse response = http.send(request);
                System.debug(response);
                if(response.getStatusCode() == 200) {
                    responseMap = (Map<String, TransactionResponseWrapper>) JSON.deserialize(response.getBody(), Map<String, TransactionResponseWrapper>.class);
                    String paymentStatus = responseMap.get('Transaction').ResponseCode == '0' ? 'Success' : 'Failed';
					System.debug(responseMap);
                    historyList[0].Payment_Finalization_JSON__c = response.getBody();
                    historyList[0].ApprovalCode__c = responseMap.get('Transaction').ApprovalCode;
                    historyList[0].ResponseCode__c = responseMap.get('Transaction').ResponseCode;
                    historyList[0].Account__c = responseMap.get('Transaction').Account;
                    historyList[0].Amount__c = responseMap.get('Transaction').Amount.get('Value');
                    historyList[0].CardToken__c = responseMap.get('Transaction').CardToken;
                    historyList[0].CardMask__c = responseMap.get('Transaction').CardNumber;
                    historyList[0].CardBrand__c = responseMap.get('Transaction').CardBrand;
                    historyList[0].Name__c = historyList[0].Payment_Request_Wrapper__r.Customer_Name__c;
                    historyList[0].Email__c = historyList[0].Payment_Request_Wrapper__r.Email__c;
                    historyList[0].Mobile__c = historyList[0].Payment_Request_Wrapper__r.Mobile_Number__c;
                    historyList[0].ResponseDescription__c = responseMap.get('Transaction').ResponseDescription;
                    historyList[0].IsWalletUsed__c = responseMap.get('Transaction').IsWalletUsed;
                    historyList[0].Payment_Status__c = paymentStatus;
                    historyList[0].CardType__c = responseMap.get('Transaction').CardType;
                    historyList[0].Updated_From__c = 'Finalization API';
                    historyList[0].Status_Fetched__c = true;
                    update historyList;
                    updatePR(prwId, paymentStatus, historyList[0]);
                }
            }
            return JSON.serialize(responseMap);
        } catch (Exception ex) {
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'MagnatiPaymentControllerClone';
            log.Name = 'Check Transaction Status';
            log.Message__c = ex.getMessage();
            insert log;
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //Added by Nishank Manwani on 17/01/2024 to Update PR Based On Status
    public static void updatePR(String prwId, String paymentStatus, Magnati_Transaction_History__c historyInst){
        Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
        wrapperInst.Id = prwId;
        wrapperInst.Payment_Status__c = paymentStatus;
        wrapperInst.Payment_Transaction_Tracking_Id__c = historyInst.TransactionID__c;
        update wrapperInst;

        List<Payment_Request__c> paymentReqs = [SELECT Id,
                                                    Payment_Bank_Reference_No__c,
                                                    Payment_Transaction_Tracking_Id__c,
                                                    Payment_Status__c, Payment_Link_Status__c,
                                                    Status__c,
                                                    Property__c, Property__r.PropStrength__Unit_Status__c,
                                                    From_Booking__c,
                                                    Payment_Request_Wrapper__r.Payment_Link_Expiry__c,
                                                    Payment_Transaction_Number__c,
                                                    OwnerId
                                                From Payment_Request__c
                                                Where Payment_Request_Wrapper__c =:prwId];
        List<String> statusesToConsider = new List<String>();
        statusesToConsider.add('Approved by Accounts');
        statusesToConsider.add('Approved by Sales Ops');
        statusesToConsider.add('Submitted to Accounts for Amount Confirmation');
        statusesToConsider.add('Approved');
        statusesToConsider.add('Partially Approved');

        List<Id> unitIds = new List<Id>();
        Boolean haveApprovedPR = false;
        for (Payment_Request__c pr:paymentReqs) {
            unitIds.add(pr.Property__c);
        }
        List<Payment_Request__c> approvedPRList = [SELECT ID From Payment_Request__c 
                                                    WHERE Property__c IN:unitIds 
                                                        AND Status__c IN:statusesToConsider 
                                                        AND Id not IN : paymentReqs
                                                        AND Property__r.PropStrength__Unit_Status__c != 'Available'
                                                        AND From_Booking__c = false
                                                        ORDER BY CreatedDate DESC];


        if (paymentReqs.size() > 0) {
            for (Payment_Request__c pr:paymentReqs) {
                pr.Reason_for_Payment_Failure__c = '';
                if(paymentStatus != 'Success'){
                    pr.Reason_for_Payment_Failure__c = historyInst.ResponseDescription__c;
                }
                pr.PR_Update_API_status__c = paymentStatus;
                pr.Payment_Transaction_Tracking_Id__c = historyInst.TransactionID__c;
                pr.Payment_Status__c = paymentStatus;
                if(pr.Payment_Link_Status__c == 'Active' && pr.Payment_Request_Wrapper__r.Payment_Link_Expiry__c < System.now()){
                    pr.Payment_Link_Status__c = 'Expired';
                }
                pr.Payment_Link_Status__c = paymentStatus == 'Success' ? 'Payment Completed' : pr.Payment_Link_Status__c;
                if (pr.From_Booking__c) {
                    if (paymentStatus == 'Success') {
                        pr.Status__c = 'Approved';
                    }
                } else if (approvedPRList.size() > 0 && paymentStatus == 'Success') {
                    pr.Status__c = 'Rejected by System';
                    pr.Website_Payment_Unit_Blocking_Status__c = 'Unit blocked by another payment request';
                    pr.Unit_Blocking_Payment_Request__c = approvedPRList[0].Id;
                } else if (approvedPRList.isEmpty() && paymentStatus == 'Success') {
                    pr.Status__c = 'Approved';
                    pr.Website_Payment_Unit_Blocking_Status__c = 'Successfully completed';
                }
            }
            update paymentReqs;
        }
        updatePRW(prwId, historyInst, paymentStatus);
    }

    //Added by Nishank Manwani on 17/01/2024 to Update PRW Based Status
    public static void updatePRW(String prwId, Magnati_Transaction_History__c historyInst, String paymentStatus){
        Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
        wrapperInst.Reason_for_Payment_Failure__c = '';
        if(paymentStatus != 'Success'){
            wrapperInst.Reason_for_Payment_Failure__c = historyInst.ResponseDescription__c;
        }
        wrapperInst.Id = prwId;
        Integer count = [SELECT COUNT() FROM Magnati_Transaction_History__c WHERE Payment_Request_Wrapper__c = :prwId AND Status_Fetched__c = false];
        wrapperInst.Is_Make_Payment_Clicked__c = count > 0 ? true : false;
        update wrapperInst;
    }

    //Added by Nishank Manwani on 17/01/2024 to Update Is Make Payment Clicked for Retry Mechanism
    @AuraEnabled
    public static void setLinkClicked(String prwId){
        try {
            Payment_Request_Wrapper__c wrapperInst = new Payment_Request_Wrapper__c();
            wrapperInst.Id = prwId;
            wrapperInst.Is_Make_Payment_Clicked__c = true;
            update wrapperInst;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    //Added by Nishank Manwani on 17/01/2024 to Update PR Status
    @AuraEnabled
    public static String updatePaymentStatus(String paymentRequestId){
        try {
            Payment_Request__c requestInst = new Payment_Request__c();
            requestInst = [SELECT Id, Payment_Request_Wrapper__c FROM Payment_Request__c WHERE Id = :paymentRequestId];
            MagnatiTransactionStatusUpdateBatchClone batchInst = new MagnatiTransactionStatusUpdateBatchClone();
            batchInst.updatePaymentStatus(requestInst.Payment_Request_Wrapper__c);
            return 'SUCCESS';
        } catch (Exception e) {
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'MagnatiPaymentControllerClone';
            log.Name = 'Error in get payment status';
            log.Message__c = e.getMessage();
            insert log;
            return 'ERROR';
        }
    }

    public class RegistrationWrapper {
        public String Currencyy;
        public String ReturnPath;
        public String TransactionHint;
        public String OrderID;
        public String OrderInfo;
        public String Channel;
        public String Amount;
        public String Customer;
        public String OrderName;
        public String UserName;
        public String Password;
        public String Store;
        public String Terminal;
        public ExtraDataWrapper ExtraData;
    }

    public class ExtraDataWrapper {
        public String MerchantDescriptor;
        //public String TransactionDescriptor;
        public ExtraDataWrapper(String MerchantDescriptor/*, String TransactionDescriptor*/){
            this.MerchantDescriptor = MerchantDescriptor;
            //this.TransactionDescriptor = TransactionDescriptor;
        }
    }

    public class TransactionResponseWrapper{
        public String PaymentPortal;
        public String PaymentPage;
        public String ResponseCode;
        public String TransactionID;
        public String ResponseDescription;
        public String CardType;
        public String IsWalletUsed;
        public String ApprovalCode;
        public String Account;
        public String CardNumber;
        public String CardBrand;
        public String CardToken;
        public Map<String, String> Amount;
    }
}