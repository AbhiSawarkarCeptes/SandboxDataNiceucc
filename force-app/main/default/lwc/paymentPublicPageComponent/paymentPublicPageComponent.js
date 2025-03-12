import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPaymentRequestData from '@salesforce/apex/PaymentPublicPageController.getPaymentRequestData';
import paymentValidation from '@salesforce/apex/PaymentPublicPageController.paymentValidation';
import getCCAvenuePaymentLink from '@salesforce/apex/PaymentPublicPageController.getCCAvenuePaymentLink';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentPublicPageComponent extends NavigationMixin(LightningElement) {

    currentPageReference = null; 
    urlStateParameters = null;

    @track customerName;
    @track customerEmail;
    @track customerPhone;
    @track paymentCurrency;
    @track showExpired;
    @track nounits;
    @track amount;
    @track unitValidationMsg;
    @track showSpinner = false;
    @track paymentComplete = false;
    @track showAPIException = false;
    @track retryPayment = false;

    /* Params from Url */
    paymentRequestWrapperId = null;
    paymentRequestWrapper;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
       this.paymentRequestWrapperId = this.urlStateParameters.prwId || null;
       console.log('Payment request wrapper id :'+this.paymentRequestWrapperId);
    }

    connectedCallback() {
        this.showExpired = false;
        console.log('connected callback');
        console.log('Payment request wrapper id connected callback:'+this.paymentRequestWrapperId);
        getPaymentRequestData({ prwId: this.paymentRequestWrapperId })
            .then(result => {
                this.paymentRequestWrapper = result;
                console.log(this.paymentRequestWrapper);
                this.customerName = result.Customer_Name__c;
                this.customerEmail = result.Email__c;
                this.customerPhone = result.Mobile_Number__c;
                this.paymentCurrency = result.Currency__c;
                this.amount = result.Amount__c;
                console.log('I am here');
                console.log(this.paymentRequestWrapper.Payment_Status__c);
                console.log(this.paymentRequestWrapper);
                if (this.paymentRequestWrapper.Payment_Status__c == undefined) {
                    console.log('payment needs to be done');
                    this.paymentComplete = false;
                } else if(this.paymentRequestWrapper.Payment_Status__c == 'Success') {
                    console.log('Setting payment complete');
                    this.retryPayment = false;
                    this.paymentComplete = true;
                } else {
                    console.log('payment retry');
                    this.paymentComplete = true;
                    this.retryPayment = true;
                }
            })
            .catch(error => {
                console.log('error here');
                console.log(error.getMessage());
                this.paymentRequestWrapper = error;
            });
    }

    checkValidation(event) {
        this.showSpinner = true;
        console.log('Inside payment validation');
        paymentValidation({ prwId: this.paymentRequestWrapperId })
            .then(result => {
                if (result == 'Expired') {
                    console.log('Request expired');
                    this.showExpired = true;
                }
                else if (result == 'pass') {
                    getCCAvenuePaymentLink({ prwId: this.paymentRequestWrapperId })
                        .then(result2 => {
                            result2 = JSON.parse(result2);
                            console.log('result2');
                            console.log(result2);
                            console.log(result2.status);
                            if (result2.status === 'error') {
                                console.log('inside error');
                                const event = new ShowToastEvent({
                                    title: 'Error',
                                    message: result2.error,
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                                this.showSpinner = false;
                                this.showAPIException = true;
                                this.unitValidationMsg = result2.error;
                            } else {
                                console.log('inside success');
                                let paymentUrl = result2.url.trim();
                                paymentUrl = paymentUrl.replace(/ /g, '');
                                console.log('Redirecting');
                                    setTimeout(function() {
                                        this.showSpinner = false;
                                        window.open(paymentUrl, "_self");
                                    }, 8000);
                            }
                            
                        })
                        .catch(error => {
                            console.log('error here');
                            this.paymentRequestWrapper = error;
                        });
                } else {
                    this.nounits = true;
                    this.showSpinner = false;
                    if (result.includes("Error")) {
                        this.unitValidationMsg = result;
                    } else {
                        this.unitValidationMsg = result + ' unit(s) not available. Please contact Sales manager for updated new link.'
                    }
                }
            })
            .catch(error => {
                this.paymentRequestWrapper = error;
            });
    }

}