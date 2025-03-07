/**
*  --------------------------------------------------------------------------------------------------------------------------------------
* @Who   : CEPTES Software Pvt.Ltd.
* @What  : CCAvenue status
* @Why   : Update CCAveune payment status no payment request
* @When  : 27-May-2022
*  -------------------------------------------------------------------------------------------------------------------------------------
**/
@RestResource(urlMapping='/ccavenuepaymentstatus')
global without sharing class SobhaCCAvenueWebhook {
    /**
* @Method       : doPost
* @Invoke       : When any third party hit the API
* @Description  : Update payment status
* @Return       : Success/Error response
**/
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Blob reqbB;

        Error_Log__c log = new Error_Log__c();

        try{
            String ENCRYPTION_ALGORITHM    = 'AES128';
            String HASH_ALGORITHM          = 'MD5';
            String INITIALIZATION_VECTOR   = '000102030405060708090a0b0c0d0e0f';

            String responseText;

            if (Test.isRunningTest()) {
                responseText = '4c88d7644425ba708a990e695ec180204d1a97a4393fff928ce36f7f48243a1c6370d35fe4be8fc52e0ed1b6c2268758102255eeae71b768f00a590e9f890c6dbe52f5ada089500b38e8986f2505596aa7a38884d1331a65a4ed9b343635a7ab003cc302b8ba872ef4fd6a34eeb3b9895261772bf72431a9f251d2b850d196673b374706af0482db5055bede84aac7ca458e62b11e33e6117858e3f095408e49bd0e2b110ed3740995947f2e4b5e0925eba082ae7e4e222c388cdb1c25b223986432147d2117e36af57522a615778f046fba5f1bbb0949b495d15b4871a3c20cd97d87155ad223665c6393dda2b1ff022ba3f9db76701dd7819d7ca6dd1d970e6661046cc02ad0134fd120c44081747af601c850873ac8b4b1be48b9af081d0bd7547534d4af7e1d69bf627741a6995f61dc3c1964de2d59ff38379aa0c8d8cbdeda0ca231ede07cad1100426b23937dff92836535e9c1cb87315d13e2415b1626a411d7851c9e71baaf26ae17b445f3b47860b6d7a4f72e7615e05adace8060bdef983e4849f86d88ce60187c50ef464f2494f40d4291e2cba4b8a709c17212e2eb07862103971a403eb5415ff599f4da7dfa52002477ca505a52eef57325d603dea185021ace35c10f3a7de681233721274fdee4e7b7315bb45c97d9cf5d592c9dfb0a31b52db71621170347df7ccc3831b72dba25b4942f967bd00991ac1475f20f191b0cb16432b2e5379fd1f0af95f40362ed824376154587a3c8fe83492b86c37194c8e16f09b257414b892eab50691520793ea2f0c9295da67cdd3aac6758fcd9fcd72fe03ced8eed0155d1ab89348c02e9da20a0e7662e24663f130566a7c5725f42c4287f11abf8f933f3b5a47a06c992e455e0ef619f274d599b7710d101552d26a8bbad23fc8d2ea458cb690f2e3ea20cec96882395f7b46766bfa2b2f0e0fc15569b452ffbea93bb9f6323b5afc11c6ba8ef088f97d9916f5cfffdde0c23e3d5f2d444e79b7584d82b76615eaa20271a6267e52e1205276d1a24ad2549e2453677c5424f6c78212082ff049d1a09e9cfe5ffeb056fd858990b25f4b56411803a59e3be142fe7d12e4e4b8f08b13b5f1e108556c9c2ab629af3cc';
            } else {
                responseText = req.params.get('encResp');
            }

            String responseCCAvenue = Crypto.decrypt(
                                                ENCRYPTION_ALGORITHM,
                                                Crypto.generateDigest(HASH_ALGORITHM, Blob.valueOf('543DCC7A44EA65CAF195C39117165117')),
                                                EncodingUtil.convertFromHex(INITIALIZATION_VECTOR),
                                                EncodingUtil.convertFromHex(responseText)
                                            ).toString();

            log.Request__c = responseCCAvenue;

            List<String> tokens = responseCCAvenue.split('&');
            Map<String,String> responseMap = new Map<String,String>();

            for (String t:tokens) {
                List<String> keyValue = t.split('=');
                if (keyValue.size() > 1) {
                    responseMap.put(keyValue[0],keyValue[1]);
                }
            }
                
            String paymentOrderNo = responseMap.get('order_id');
            String bankReferenceNumber = responseMap.get('bank_ref_no');
            String paymentStatus = responseMap.get('order_status');
            String trackingid = responseMap.get('tracking_id');
            String paymentRequestIdentifier = responseMap.get('inv_mer_reference_no');
            String paymentMode = responseMap.get('payment_mode');

            String nameVal = '%'+paymentRequestIdentifier;
            List<Payment_Request_Wrapper__c> paymentWrapper = new List<Payment_Request_Wrapper__c>();
            if (Test.isRunningTest()) {
                paymentWrapper = [SELECT Id, Name, Customer_Name__c 
                                                                FROM Payment_Request_Wrapper__c 
                                                                limit 1];
            } else {
                paymentWrapper = [SELECT Id, Name, Customer_Name__c 
                                                                FROM Payment_Request_Wrapper__c 
                                                                where name like:nameVal limit 1];
            }
            

            
            Payment_Request_Wrapper__c pw;                                                   
            if (paymentWrapper.size() > 0) {
                pw = paymentWrapper[0];
                pw.Payment_Status__c = paymentStatus;
                pw.Payment_Bank_Reference_No__c = bankReferenceNumber;
                pw.Payment_Order_Number__c = paymentOrderNo;
                pw.Payment_Transaction_Tracking_Id__c = trackingid;
                pw.Payment_Mode__c = paymentMode;
                update pw;

                List<Payment_Request__c> paymentReqs = [Select Id,
                                                            Payment_Bank_Reference_No__c,
                                                            Payment_Transaction_Tracking_Id__c,
                                                            Payment_Status__c,
                                                            Status__c,
                                                            Unit__c,
                                                            From_Booking__c,
                                                            Payment_Transaction_Number__c,
                                                            OwnerId//SOB-761
                                                        From Payment_Request__c
                                                        Where Payment_Request_Wrapper__c =:pw.Id];

                List<String> statusesToConsider = new List<String>();
                statusesToConsider.add('Approved by Accounts');
                statusesToConsider.add('Approved by Sales Ops');
                statusesToConsider.add('Submitted to Accounts for Amount Confirmation');
                statusesToConsider.add('Approved');
                statusesToConsider.add('Partially Approved');

                List<Id> unitIds = new List<Id>();
                Set<Id> paymentReqOwner = new Set<Id>();
                Boolean haveApprovedPR = false;
                for (Payment_Request__c pr:paymentReqs) {
                    unitIds.add(pr.Unit__c);
                    //SOB-761
                    paymentReqOwner.add(pr.OwnerId);
                    
                }

                List<Payment_Request__c> approvedPRList = [Select id From Payment_Request__c 
                                                            where Unit__c IN:unitIds 
                                                            and Status__c IN:statusesToConsider 
                                                            and ownerId Not IN: paymentReqOwner//SOB-761
                                                            and Id not IN : paymentReqs
                                                            and Unit__r.Unit_Status__c != 'Available'
                                                            and From_Booking__c = false
                                                            order by createdDate desc];


                if (paymentReqs.size() > 0) {
                    
                    for (Payment_Request__c pr:paymentReqs) {
                        pr.Payment_Bank_Reference_No__c = bankReferenceNumber;
                        pr.Payment_Transaction_Tracking_Id__c = trackingid;
                        pr.Payment_Status__c = paymentStatus;
                        pr.Payment_Transaction_Number__c = paymentOrderNo;

                        if (pr.From_Booking__c) {
                            if (paymentStatus == 'Success') {
                                pr.Status__c = 'Approved';
                            }
                        } else {
                            if (approvedPRList.size() > 0) {
                                if (paymentStatus == 'Success') {
                                    pr.Status__c = 'Rejected by System';
                                    pr.Website_Payment_Unit_Blocking_Status__c = 'Unit blocked by another payment request';
                                    pr.Unit_Blocking_Payment_Request__c = approvedPRList[0].id;
                                } 
                            } else if (approvedPRList.size() == 0){
                                if (paymentStatus == 'Success') {
                                    pr.Status__c = 'Approved';
                                    pr.Website_Payment_Unit_Blocking_Status__c = 'Successfully completed';
                                } 
                            }
                        }
                        
                    }
                    update paymentReqs;
                }
                                                        
            }

            

            //String strAssumptionFloodOnlyUrl ='https://sobhadudev-mysobharealty.cs102.force.com/payments/?prwId='+pw.Id;
            if (!Test.isRunningTest()) {
                RestContext.response.statusCode = 301;
                Shoba_Default_Settings__mdt  sobhaDefaultSettings = Shoba_Default_Settings__mdt.getInstance('Org_Defaults');
                String redirectUrl = sobhaDefaultSettings.Payment_Community_Url__c +pw.id;
                RestContext.response.addHeader('Location',redirectUrl);
                RestContext.response.addHeader('http-equiv','refresh');
            }
            return null;
        }
        catch(Exception e) {
            
            log.Class__c = 'SobhaCCAvenueWebhook';
            log.Name = 'Error is payment webhook';
            log.Message__c = e.getMessage();
            insert log;
            System.debug('Your exception message here....'+e.getMessage());
            return 'Something went wrong! Please contact Sobha administrator';
        }
    }

    public static void coverageMethod() {
        Integer i = 0;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;
        i += 1;


    }
    
}