/*********************************************************************
 * Class Name  :   MagnatiTransactionStatusUpdQueuableCopy
 * Description :   Update CCAveune payment to Magnati Payment - Queueable class for get values from Magnati
 * Created Date:   17/01/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 17/01/2024
 *********************************************************************/
public with sharing class MagnatiTransactionStatusUpdQueuableCopy implements Queueable, Database.AllowsCallouts{
    public Integer index;
    public String prwId;
    public String updatedFrom;
    public List<Magnati_Transaction_History__c> historyList;

    //Added by Nishank Manwani on 17/01/2024 to Constructor for set variable values
    public MagnatiTransactionStatusUpdQueuableCopy(Integer index, String prwId, List<Magnati_Transaction_History__c> historyList, String updatedFrom){
        this.index = index;
        this.prwId = prwId;
        this.historyList = historyList;
        this.updatedFrom = updatedFrom;
    }

    public void execute(QueueableContext context) {
        try{
            getPaymentStatus();
        } catch(Exception ex){
            Error_Log__c log = new Error_Log__c();
            log.Class__c = 'MagnatiTransactionStatusUpdQueuableCopy';
            log.Name = 'Error is get payment status batch';
            log.Message__c = ex.getMessage();
            insert log;
        }
    }
    
    //Added by Nishank Manwani on 17/01/2024 to Get Transaction history values from Magnati Gateway
    public void getPaymentStatus(){
        if(index < this.historyList.size()){
            Magnati_Transaction_History__c historyInst = new Magnati_Transaction_History__c();
            Map<String, Map<String, String>> statusBodyMap = new Map<String, Map<String, String>>();
            Map<String, String> detailMap = new Map<String, String>();
            Magnati__mdt magnatimdt = Magnati__mdt.getInstance(System.Label.Magnati_Meta_Data);
            detailMap.put('TransactionID', this.historyList[index].TransactionId__c);
            detailMap.put('Customer', magnatimdt.Customer__c);
            detailMap.put('UserName', magnatimdt.UserName__c);
            detailMap.put('Password', magnatimdt.Password__c);
            statusBodyMap.put('Finalization', detailMap);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(magnatimdt.End_Point__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setMethod('POST');
            request.setBody(JSON.serialize(statusBodyMap));
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            Map<String, MagnatiPaymentControllerClone.TransactionResponseWrapper> responseMap = new Map<String, MagnatiPaymentControllerClone.TransactionResponseWrapper>();
            if(response.getStatusCode() == 200) {
                responseMap = (Map<String, MagnatiPaymentControllerClone.TransactionResponseWrapper>) JSON.deserialize(response.getBody(), Map<String, MagnatiPaymentControllerClone.TransactionResponseWrapper>.class);
                String paymentStatus = responseMap.get('Transaction').ResponseCode == '0' ? 'Success' : 'Failed';
                historyInst = this.historyList[index];
                historyInst.Payment_Finalization_JSON__c = response.getBody();
                historyInst.ApprovalCode__c = responseMap.get('Transaction').ApprovalCode;
                historyInst.ResponseCode__c = responseMap.get('Transaction').ResponseCode;
                historyInst.Account__c = responseMap.get('Transaction').Account;
                historyInst.Amount__c = responseMap.get('Transaction').Amount.get('Value');
                historyInst.CardToken__c = responseMap.get('Transaction').CardToken;
                historyInst.CardMask__c = responseMap.get('Transaction').CardNumber;
                historyInst.CardBrand__c = responseMap.get('Transaction').CardBrand;
                historyInst.CardType__c = responseMap.get('Transaction').CardType;
                historyInst.Name__c = historyInst.Payment_Request_Wrapper__r.Customer_Name__c;
                historyInst.Email__c = historyInst.Payment_Request_Wrapper__r.Email__c;
                historyInst.Mobile__c = historyInst.Payment_Request_Wrapper__r.Mobile_Number__c;
                historyInst.ResponseDescription__c = responseMap.get('Transaction').ResponseDescription;
                historyInst.IsWalletUsed__c = responseMap.get('Transaction').IsWalletUsed;
                historyInst.Payment_Status__c = paymentStatus;
                historyInst.Updated_From__c = this.updatedFrom;
                historyInst.Status_Fetched__c = true;
                update historyInst;
            }
            this.historyList[index] = historyInst;
            MagnatiTransactionStatusUpdQueuableCopy queueableInstance = new MagnatiTransactionStatusUpdQueuableCopy(this.index + 1, this.prwId, this.historyList, this.updatedFrom);
            System.enqueueJob(queueableInstance);
        } else {
            String status = 'Failed';
            this.historyList = [SELECT Id, TransactionID__c, Payment_Status__c, Payment_Request_Wrapper__r.Email__c, ResponseDescription__c,
                          Payment_Request_Wrapper__r.Customer_Name__c, Payment_Request_Wrapper__r.Mobile_Number__c
                   FROM Magnati_Transaction_History__c
                   WHERE Payment_Request_Wrapper__c = :this.prwId ORDER BY CreatedDate ASC];

            Magnati_Transaction_History__c historyInst = new Magnati_Transaction_History__c();
            historyInst = this.historyList[0];
            for(Magnati_Transaction_History__c histInst :this.historyList){
                if(histInst.Payment_Status__c == 'Success'){
                    status = 'Success';
                    historyInst = histInst;
                }
            }
            MagnatiPaymentControllerClone.updatePR(this.prwId, status, historyInst);
        }
    }
}