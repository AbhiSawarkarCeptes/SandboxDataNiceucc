import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPaymentRequestData from '@salesforce/apex/PaymentPublicPageControllerCopy.getPaymentRequestData';
import paymentValidation from '@salesforce/apex/PaymentPublicPageControllerCopy.paymentValidation';
import getCCAvenuePaymentLink from '@salesforce/apex/PaymentPublicPageControllerCopy.getCCAvenuePaymentLink';
import setLinkClicked from '@salesforce/apex/MagnatiPaymentControllerClone.setLinkClicked';
import generateMagnatiTransaction from '@salesforce/apex/MagnatiPaymentControllerClone.generateMagnatiTransaction';
import checkTransactionStatusPS from '@salesforce/apex/MagnatiPaymentControllerClone.checkTransactionStatus';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentPublicPageComponentCopy extends NavigationMixin(LightningElement) {

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
    @track unitsPRW;
    @track statusFetched = false;

    /* Params from Url */
    paymentRequestWrapperId = null;
    paymentRequestWrapper;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('==> this.urlStateParameters' + currentPageReference);
        if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          console.log('==> this.urlStateParameters' + this.urlStateParameters);
          this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.paymentRequestWrapperId = this.urlStateParameters.prwId || null;
        //this.paymentRequestWrapperId = 'a273N000001hoycQAA';
       console.log('Payment request wrapper id :'+this.paymentRequestWrapperId);
       console.log('Check transaction Status50');
       if(this.urlStateParameters.isPaymentInitiated == 'true'){
        console.log('Check transaction Status51');
            if(!this.statusFetched){
                this.statusFetched = true;
                console.log('Check transaction Status54');
                this.checkTransactionStatus();
            }
        } else {
            this.connectedCallback();
        }
    }

    checkTransactionStatus(){
        console.log('Check transaction Status64');
        this.showSpinner = true;
        console.log('Check transaction Status66');
        checkTransactionStatusPS({prwId: this.paymentRequestWrapperId})
        .then(result => {
            console.log('Check transaction Status68');
            console.log('Check transaction Status69');
            console.log(result);
            this.connectedCallback();
        })
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
                this.unitsPRW = result.Units__c;
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
                console.log(error);
                this.paymentRequestWrapper = error;
            });
    }

    checkValidation(event) {
        this.showSpinner = true;
        console.log('Inside payment validation');
        paymentValidation({ prwId: this.paymentRequestWrapperId })
            .then(result => {
                console.log(result);
                if (result == 'Expired') {
                    console.log('Request expired');
                    this.showSpinner = false;
                    this.showExpired = true;
                    this.paymentComplete = false;
                    this.retryPayment = false;
                }
                else if (result == 'pass') {   
                    console.log(' innn generateMagnatiTransaction');
                    console.log(' innn generateMagnatiTransaction', this.paymentRequestWrapperId);
                    generateMagnatiTransaction({ prwId: this.paymentRequestWrapperId})
                    .then(res => {
                        console.log('Result----->+', res);
                        this.showSpinner = false;
                        window.open(JSON.parse(res)?.Payment_URL__c, "_self");
                    })
                    .catch((error) => {
                        console.log('Result-----> error+', error);
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Error while getting link from Magnati.',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    })
                    this.setLinkClicked();
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

    setLinkClicked(){
        setLinkClicked({ prwId: this.paymentRequestWrapperId })
    }

}