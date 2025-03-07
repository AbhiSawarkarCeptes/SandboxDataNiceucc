@isTest
global with sharing class EzetapCancelCalloutMock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody('{"success":true,"messageCode":"P2P_STATUS_IN_CANCELED_FROM_EXTERNAL_SYSTEM","message":"PushToPay Notification has been Canceled from Billing/External System.","realCode":"P2P_STATUS_IN_CANCELED_FROM_EXTERNAL_SYSTEM","sessionKey":"cc4ab44e-7da0-405b-933d-d4437c80bc4b","username":"2222500021","setting":{},"apps":[],"states":[],"dccOpted":false,"cardHolderCurrencyExponent":0,"signable":false,"voidable":false,"refundable":false,"maximumPayAttemptsAllowed":1,"maximumSuccessfulPaymentAllowed":1,"noExpiryFlag":false,"signReqd":true,"customerNameAvailable":false,"callbackEnabled":false,"onlineRefundable":false,"tipEnabled":false,"callTC":false,"acquisitionId":"","acquisitionKey":"","processCronOutput":false,"externalDevice":false,"tipAdjusted":false,"txnMetadata":[],"middlewareStanNumber":0,"otpRequired":false,"p2pRequestId":"230103090411446E020065629","redirect":false,"twoStepConfirmPreAuth":false,"reload":false}');
        res.setStatusCode(200);
        return res;
    }
}