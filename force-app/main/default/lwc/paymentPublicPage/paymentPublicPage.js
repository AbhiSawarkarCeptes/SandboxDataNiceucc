import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getPaymentRequestData from '@salesforce/apex/PaymentPublicPageController.getPaymentRequestData';
import paymentValidation from '@salesforce/apex/PaymentPublicPageController.paymentValidation';
import setLinkClicked from '@salesforce/apex/MagnatiPaymentController.setLinkClicked';
import generateMagnatiTransaction from '@salesforce/apex/MagnatiPaymentController.generateMagnatiTransaction';
import checkTransactionStatus from '@salesforce/apex/MagnatiPaymentController.checkTransactionStatus';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PaymentPublicPage extends NavigationMixin(LightningElement) {

    currentPageReference = null; 
    urlStateParameters = null;

    @track customerName;
    @track customerEmail;
    @track customerPhone;
    @track paymentCurrency;
    @track statusFetched = false;
    @track showExpired;
    @track nounits;
    @track amount;
    @track units;
    @track unitValidationMsg;
    @track showSpinner = false;
    @track paymentComplete = false;
    @track showAPIException = false;
    @track retryPayment = false;
    @api recordId;
    @track orderId;

    /* Params from Url */
    paymentRequestWrapperId = null;
    paymentRequestWrapper = {};

    connectedCallback(){
        this.showSpinner = true;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }

    setParametersBasedOnUrl() {
        this.paymentRequestWrapperId = this.urlStateParameters.prwId || null;
        if(this.urlStateParameters.isPaymentInitiated == 'true'){
            if(!this.statusFetched){
                this.statusFetched = true;
                this.checkTransactionStatus();
            }
        } else {
            this.initialLoad();
        }
    }

    checkTransactionStatus(){
        this.showSpinner = true;
        checkTransactionStatus({prwId: this.paymentRequestWrapperId})
        .then(result => {
            this.initialLoad();
        })
    }

    initialLoad(){
        this.showExpired = false;
        this.showSpinner = true;
        getPaymentRequestData({ prwId: this.paymentRequestWrapperId })
        .then(result => {
            this.showSpinner = false;
            this.paymentRequestWrapper = result;
            this.paymentRequestWrapper.Name = this.paymentRequestWrapper.Name.replace('PRW-', '');
            let orderId = result?.Payment_Requests__r[0]?.Name;
            if(orderId){
                this.orderId = orderId.replace('PR-', '');
            }
            this.units = result.Units__c;
            this.customerName = result.Customer_Name__c;
            this.customerEmail = result.Email__c;
            this.customerPhone = result.Mobile_Number__c;
            this.paymentCurrency = result.Currency__c;
            this.amount = result.Amount__c;
            if (this.paymentRequestWrapper.Payment_Status__c == undefined) {
                this.paymentComplete = false;
            } else if(this.paymentRequestWrapper.Payment_Status__c == 'Success') {
                this.retryPayment = false;
                this.paymentComplete = true;
            } else {
                this.paymentComplete = true;
                this.retryPayment = true;
            }
        })
        .catch(error => {
            this.showSpinner = false;
            this.paymentRequestWrapper = error;
        });
    }

    setLinkClicked(){
        setLinkClicked({ prwId: this.paymentRequestWrapperId })
    }

    checkValidation(event) {
        this.showSpinner = true;
        paymentValidation({ prwId: this.paymentRequestWrapperId })
            .then(result => {
                if (result == 'Expired' || result.includes('Expired')) {
                    this.showExpired = true;
                    this.showSpinner = false;
                }
                else if (result == 'pass') {
                    generateMagnatiTransaction({ prwId: this.paymentRequestWrapperId})
                    .then(res => {
                        this.showSpinner = false;
                        window.open(JSON.parse(res)?.Payment_URL__c, "_self");
                    })
                    .catch((error) => {
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

}