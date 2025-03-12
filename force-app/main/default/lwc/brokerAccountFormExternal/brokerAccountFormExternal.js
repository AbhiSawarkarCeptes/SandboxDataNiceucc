import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import brokerAccountCSS from '@salesforce/resourceUrl/brokerAccountCSS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateRecord from '@salesforce/apex/BrokerAccountFormExternalController.updateRecord';
import getRecord from '@salesforce/apex/BrokerAccountFormExternalController.getRecord';

export default class BrokerAccountFormExternal extends LightningElement {
    objectApiName = 'Account';
    brokerCategory = '';
    brokerSubType = '';
    recordId;
    showSpinner;
    showCmp;
    showSuccess = false;
    today;
    @track record = {};
    options = {};
    @track BrokerCreatedDate;
    @track RegistrationNumber;
    @track recordForUI={'Name':undefined,'BrokerCreatedDate':undefined,'RegistrationNumber':undefined,'BrokerCode':undefined};
    connectedCallback() {
        loadStyle(this, brokerAccountCSS);
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.recordId = urlParams.get('id');
        console.log('Account Form JS');
        this.showSpinner = true;

        getRecord({recordId: this.recordId})
            .then(data => {
                console.log(JSON.stringify(data));
                console.log('inn2');
                this.record = data.record;
                console.log('inn3');
                this.today = data.today;
                this.brokerCategory = this.record.Broker_Category__c;
                this.brokerSubType = this.record.Broker_Sub_Type__c;
                // this.options.country = data.countryOptions;
                // this.options.city = data.cityOptions;
                this.showCmp = true;
                this.recordForUI.Name = this.record.Name;
                this.recordForUI.BrokerCreatedDate = this.record.Broker_Created_Date__c;
                this.recordForUI.RegistrationNumber= this.record.Registration_Number__c;
                this.recordForUI.BrokerCode = this.record.PropStrength__Broker_Code__c;
                console.log('inn3');
               
            })
            .catch(error => {
                this.toast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }


    handleSubmit(event) {
        this.record = event.detail.record;
        this.showSpinner = true;
        console.log('record -'+JSON.stringify(this.record));
        updateRecord({record: this.record})
            .then(data => {
                // this.record = data;
                this.recordForUI.Name = data.Name;
                this.recordForUI.BrokerCreatedDate = data.Broker_Created_Date__c;
                this.recordForUI.RegistrationNumber= data.Registration_Number__c;
                this.recordForUI.BrokerCode = data.PropStrength__Broker_Code__c;
                this.toast('Success', 'Registration successful', 'success');
                this.dispatchEvent(event);
                this.showCmp = false;
                this.showSuccess = true;
                //window.open('/s/registration-successful', '_self');
            })
            .catch(error => {
                console.log('~~~Error'+JSON.stringify(error));
                this.toast('Error', error.body.message, 'error');
            })
            .finally(() => this.showSpinner = false);
    }

    handleChange(event) {
        this.record[event.target.name] = event.target.value;
    }

    toast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            }),
        );
    }

    // get showBrokerRera() {
    //     return this.brokerCategory === 'Broker – RERA';
    // }

    get showIntnlCompany() {
        return this.brokerCategory === 'Company';
    }

    get showIntnlIndividual() {
        return this.brokerCategory === 'Individual';
    }
}