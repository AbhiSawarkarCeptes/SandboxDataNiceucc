import { LightningElement, api, wire } from 'lwc';
import getNewSaleApproval from '@salesforce/apex/UpdateAmountOnNewSaleApprovalController.getNewSaleApproval'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
export default class UpdateAmountOnNewSaleApproval extends NavigationMixin(LightningElement) {

    @api recordId;
    saleApproval;
    dataLoaded = false;
    showSpinner = true;
    amount;
    saleAmount;
    skip2PercentError;
    existingDpAmount2;
    existingDldAmount2;
    existingDldAmount1;
    currency1;
    currency2;
    currToRate;
    showError = false;
    showMissingNSAError = false;
    showBothDpAndDldField = false;
    showAmountConfirmError = false;
    isPrimaryPR = true;
		dldDisabled = false;
		dldDisabled2 = false;
		
    @wire(getNewSaleApproval, { recordId: '$recordId' })
    wiredResult({ data, error }) {
        if (data) {
            console.log('data-----', data);
            this.saleApproval = data.unithold;
            if (!this.saleApproval) {
                this.showError = true;
                this.showMissingNSAError = true;
            } else {
                this.amount = data.amount;
                this.saleAmount = data.salevalue ? data.salevalue : data.unithold.Sales_Value__c;
                this.skip2PercentError = data.skip2PercentError;
                this.existingDpAmount2 = data.existingDpAmount2;
                this.existingDldAmount2 = data.existingDldAmount2;
                this.existingDldAmount1 = data.existingDldAmount1;
                this.currency1 = data.currency1;
                this.currency2 = data.currency2;
                this.currToRate = data.currToRate;
                this.showBothDpAndDldField = data.showBothDpAndDldField;
            }
            this.dataLoaded = true;
            this.showSpinner = false;
            this.showAmountConfirmError = data.showAmountConfirmError;
						if(data.accountType === 'ESCROW') {
               this.dldDisabled2 = true;
							this.dldDisabled = true;
            }
						if(data.accountTypePrimary === 'ESCROW') {
                this.dldDisabled = true;
             }
            this.isPrimaryPR = data.isPrimaryPR;
            if (this.showAmountConfirmError) {
                this.showError = true;
            }

        }
        if (error) {
            console.log(error);
        }
    }
    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        var sum = 0;
        console.log('sum11', sum);
        if (this.showBothDpAndDldField) {
            sum = (fields.DLD_Amount__c) ? sum + parseFloat(fields.DLD_Amount__c) : sum;
            sum = (fields.DP_Amount__c) ? sum + parseFloat(fields.DP_Amount__c) : sum;
            sum = (fields.DLD_Amount_2__c) ? sum + parseFloat(fields.DLD_Amount_2__c) : sum;
            sum = (fields.DP_Amount_2__c) ? sum + parseFloat(fields.DP_Amount_2__c) : sum;
            console.log('sum22', sum);
        } else {
            if (this.isPrimaryPR) {
                sum = (fields.DLD_Amount__c) ? sum + parseFloat(fields.DLD_Amount__c) : sum;
                sum = (fields.DP_Amount__c) ? sum + parseFloat(fields.DP_Amount__c) : sum;
                console.log('sum33', sum);
            } else {
                sum = (fields.DLD_Amount_2__c) ? sum + parseFloat(fields.DLD_Amount_2__c) : sum;
                sum = (fields.DP_Amount_2__c) ? sum + parseFloat(fields.DP_Amount_2__c) : sum;
                console.log('sum44', sum);

            }

        }
        var minPercentage = this.saleApproval.Payment_Request__r.Unit__r.Unit_Hold_min_percentage__c ? this.saleApproval.Payment_Request__r.Unit__r.Unit_Hold_min_percentage__c : 2;
        var dpAmount = fields.DP_Amount__c ? Number(fields.DP_Amount__c) : Number(fields.DP_Amount_2__c);
        dpAmount = parseFloat(dpAmount);
        var dpAmount2 = Number(this.existingDpAmount2);
        dpAmount2 = parseFloat(dpAmount2);
        var dldAmount = fields.DLD_Amount__c ? Number(fields.DLD_Amount__c) : 0; // added 0 by Vivek
        dldAmount = parseFloat(dldAmount);
        var dldAmount2FromUI = fields.DLD_Amount_2__c ? Number(fields.DLD_Amount_2__c) : 0; // added by Vivek
        dldAmount2FromUI = parseFloat(dldAmount2FromUI); // added by Vivek
        var dldAmount2 = Number(this.existingDldAmount2);
        dldAmount2 = parseFloat(dldAmount2);
        var dldAmount1 = Number(this.existingDldAmount1);
        dldAmount1 = parseFloat(dldAmount1);


        var tempDpAmount = dpAmount;
        var tempDp2Amount = dpAmount2;
        var tempDldAmount = dldAmount;
        var tempDld2Amount = dldAmount2;

        console.log('tempDldAmount1 from UI= ' + tempDldAmount);
        console.log('tempDld2Amount from existing= ' + tempDld2Amount);
        console.log('tempDld1Amount from existing= ' + dldAmount1);
        console.log('dldAmount2FromUI from UI= ' + dldAmount2FromUI);
        console.log('tempDldAmount+tempDld2Amount+dldAmount1+dldAmount2FromUI', tempDldAmount + tempDld2Amount + dldAmount1 + dldAmount2FromUI);
        console.log('this.saleAmount * 0.04', ((this.saleAmount * 0.04) + 1160 + 1410));

        if (tempDldAmount + tempDld2Amount + dldAmount1 + dldAmount2FromUI > ((this.saleAmount * 0.04) + 1160 + 1410)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Amount allocated towards DLD Amount cannot be more than DLD Fee(4% of Purchase Price) + DLD Admin fee(AED 1150) + Title Deed fee (1410).',
                variant: 'error',
                mode: 'error'
            });
            this.dispatchEvent(evt);
            return;
        }
        if (this.skip2PercentError == false && tempDpAmount + tempDp2Amount < (this.saleAmount * minPercentage * 0.01)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'DP Amount should be greater then ' + minPercentage + '% of Sales Value',
                variant: 'error',
                mode: 'error'
            });
            this.dispatchEvent(evt);
            return;
        } else if (sum.toFixed(2) != this.amount.toFixed(2)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Payment Request amount exceeded the amount, Please match the amount with payment request amount and submit the request.',
                variant: 'error',
                mode: 'error'
            });
            this.dispatchEvent(evt);
            return;
        } else {
            var dpAmount = fields.DP_Amount__c ? Number(fields.DP_Amount__c) : Number(fields.DP_Amount_2__c);
            dpAmount = parseFloat(dpAmount);
            var dpAmount2 = Number(this.existingDpAmount2);
            dpAmount2 = parseFloat(dpAmount2);
            fields.Blocking_Amount_Paid__c = dpAmount + dpAmount2;

            fields.Id = this.saleApproval.Id;


            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record updated successfully',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the form
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch(error => {
                    var errorMessageToDisplay = '';
                    if (error.body) {
                        if (Array.isArray(error.body)) {
                            errorMessageToDisplay += error.body.map(e => e.message).join(', ');
                        }

                        else if (typeof error.body.output === 'object') {
                            let fieldErrors = error.body.output.fieldErrors;
                            let pageErrors = error.body.output.pageErrors;
                            let duplicateResults = error.body.output.duplicateResults;

                            if (error && typeof error === 'string') {
                                errorMessageToDisplay += error;
                            }

                            if (fieldErrors) {
                                console.log('fieldErrors---', fieldErrors);
                                for (var fieldName in fieldErrors) {
                                    let errorList = fieldErrors[fieldName];
                                    console.log('errorList---', errorList)
                                    for (var i = 0; i < errorList.length; i++) {
                                        errorMessageToDisplay += errorList[i].errorCode + ' ' + fieldName + ' ' + errorList[i].message + ' ';
                                    }
                                }
                            }

                            if (pageErrors && pageErrors.length > 0) {
                                for (let i = 0; i < pageErrors.length; i++) {
                                    errorMessageToDisplay += pageErrors[i].statusCode + ' ' + pageErrors[i].message;
                                }
                            }

                            if (duplicateResults && duplicateResults.length > 0) {
                                errorMessageToDisplay += 'duplicate result error';
                            }
                            if (typeof error.body.output == 'object') {
                                let errorMsg = error.body.output.errors;
                                if (errorMsg && errorMsg.length > 0) {
                                    for (let i = 0; i < errorMsg.length; i++) {
                                        errorMessageToDisplay += errorMsg[i].errorCode + ' ' + errorMsg[i].message;
                                    }
                                }
                            }
                        }
                    }
                    // handles errors from the lightning record edit form
                    if (error.message) {
                        errorMessageToDisplay += error.message;
                    }
                    if (error.detail) {
                        errorMessageToDisplay += error.detail;
                    }
                    if (typeof error.body === 'object') {
                        errorMessageToDisplay += error.body.message;

                    }
                    console.log('error---', error)
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: errorMessageToDisplay,
                            variant: 'error'
                        })
                    );
                });

            //this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

    }
    handleSuccess(event) {
        /*event.preventDefault(); 
        
        const updatedRecord = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record updated successfully',
            variant: 'success',
            mode: 'success'
        });
        this.dispatchEvent(evt);
        this.dispatchEvent(new CloseActionScreenEvent());
       */
    }
    handleError(event) {
        /*var error = event.error;
        console.log(error);
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Unexpected Error :  '+error
            ,
            variant: 'error',
            mode: 'error'
        });
        this.dispatchEvent(evt);
        return;*/
    }
}