import { LightningElement } from 'lwc';
import getUnitDetail from '@salesforce/apex/CustomerDetailUpdateController.getUnitDetail';
import getApplicantDetail from '@salesforce/apex/CustomerDetailUpdateController.getApplicantDetail';
import addApplicantDetail from '@salesforce/apex/CustomerDetailUpdateController.addApplicantDetail';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerDetailUpdate extends LightningElement {
    searchUnitNumber;
    namevalue;
    onNationalityValue;
    addressvalue;
    emailvalue;
    numbervalue;
    unitValue;
    PassportNumber;
    Emiratesvalue;
    checkUnitAvailableorNot = false;
    showSpinner;
    ApplicantValuevalue = false;
    value = 'Corporate Purchaser';
    checkPassportValueIsFill = false;
    MailingCityvalue;
    MailingStatevalue;
    MailingCountryvalue;
    Cityvalue;
    Statevalue;
    Countryvalue;
    PassportexpireDatevalue;
    applicantOptions = [
        { value: 'Corporate Purchaser', label: 'Corporate Purchaser' },
        { value: 'Individual Purchaser', label: 'Individual Purchaser' }
    ];
    handleSearchUnitNumber(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.searchUnitNumber = evt.target.value;
            getUnitDetail({ unitName: this.searchUnitNumber })
                .then(result => {
                    console.log(result);
                    if (result) {
                        console.log('result', result);
                        this.checkUnitAvailableorNot = true;
                        this.unitValue = result[0].Id;
                    }
                    else {
                        this.checkUnitAvailableorNot = false;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'No unit found.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                });
        }
    }

    onApplicantChange(event) {
        this.ApplicantValuevalue = event.target.checked;
        console.log(this.ApplicantValuevalue);
    }
    onNameChange(event) {
        this.namevalue = event.target.value;
    }
    onNationalityChange(event) {
        this.onNationalityValue = event.target.value;
    }
    onMailingCityChange(event) {
        this.MailingCityvalue = event.target.value;
    }
    onMailingStateChange(event) {
        this.MailingStatevalue = event.target.value;
    }
    onMailingCountryChange(event) {
        this.MailingCountryvalue = event.target.value;
    }
    onCityChange(event) {
        this.Cityvalue = event.target.value;
    }
    onStateChange(event) {
        this.Statevalue = event.target.value;
    }
    onCountryChange(event) {
        this.Countryvalue = event.target.value;
    }
    onAddressChange(event) {
        this.addressvalue = event.target.value;
    }
    onEmailChange(event) {
        this.emailvalue = event.target.value;
    }
    onNumberhange(event) {
        this.numbervalue = event.target.value;
    }
    handleChangeApplicant(event) {
        this.value = event.detail.value;
    }
    onPassportNumberChange(event) {
        this.PassportNumber = event.target.value;
        if (this.PassportNumber) {
            this.checkPassportValueIsFill = true;
        }
        else {
            this.checkPassportValueIsFill = false;
        }
    }
    onPassportexpireDateChange(event) {
        this.PassportexpireDatevalue = event.target.value;
    }
    onEmiratesChange(event) {
        this.Emiratesvalue = event.target.value;
    }
    handleClickSaveData(event) {
        this.showSpinner = true;
				let allow = true;
        console.log(this.PassportNumber);
        if ((this.namevalue && this.onNationalityValue && this.MailingCityvalue && this.MailingStatevalue && this.MailingCountryvalue && this.Cityvalue && this.Statevalue && this.Countryvalue && this.addressvalue && this.emailvalue
            && this.numbervalue && ((this.PassportNumber && this.checkPassportValueIsFill && this.PassportexpireDatevalue) || this.Emiratesvalue)) || allow) {
            if (this.ApplicantValuevalue) {
                addApplicantDetail({
                    namevalue: this.namevalue, onNationalityValue : this.onNationalityValue, MailingCityvalue: this.MailingCityvalue, MailingStatevalue: this.MailingStatevalue, MailingCountryvalue: this.MailingCountryvalue,
                    Cityvalue: this.Cityvalue, Statevalue: this.Statevalue, Countryvalue: this.Countryvalue,
                    addressvalue: this.addressvalue, emailvalue: this.emailvalue, numbervalue: this.numbervalue,
                    unitValue: this.unitValue, PassportNumber: this.PassportNumber,PassportexpireDatevalue : this.PassportexpireDatevalue, Emiratesvalue: this.Emiratesvalue,value:this.value
                })
                    .then(result => {
                        this.showSpinner = false;
                        console.log(result);
                        if (result == 'Success') {
                            console.log('result', result);
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Record Updated',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'please contact admin',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                    });
            }
            else {
                getApplicantDetail({
                   namevalue: this.namevalue,onNationalityValue : this.onNationalityValue, MailingCityvalue: this.MailingCityvalue, MailingStatevalue: this.MailingStatevalue, MailingCountryvalue: this.MailingCountryvalue,
                    Cityvalue: this.Cityvalue, Statevalue: this.Statevalue, Countryvalue: this.Countryvalue,
                    addressvalue: this.addressvalue, emailvalue: this.emailvalue, numbervalue: this.numbervalue,
                    unitValue: this.unitValue, PassportNumber: this.PassportNumber,PassportexpireDatevalue : this.PassportexpireDatevalue, Emiratesvalue: this.Emiratesvalue,value:this.value
                })
                    .then(result => {
                        this.showSpinner = false;
                        console.log(result);
                        if (result == 'Success') {
                            console.log('result', result);
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: 'Record Updated',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'please contact admin',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }
                    })
                    .catch(error => {
                        this.showSpinner = false;
                    });
            }

        }
        else {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'please fill all the required fileds',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }
}