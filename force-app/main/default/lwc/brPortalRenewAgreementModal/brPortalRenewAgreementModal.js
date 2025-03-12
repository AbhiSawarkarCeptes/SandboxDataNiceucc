import { LightningElement,wire,api,track } from 'lwc';
import renewAgreement from '@salesforce/apex/BRPortalBrokerEventsController.renewAgreement';
import getProfileDetails from '@salesforce/apex/BRPortalBrokerEventsController.getProfileDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class BrPortalRenewAgreementModal extends LightningElement {
    profileInfo
    isExecuted_Or_New;

    handleClick() {
        const customEvent = new CustomEvent('modal', {
            detail: { flag: false }
        });
        this.dispatchEvent(customEvent);
    }

    wiredData;
    @wire(getProfileDetails)
    getProfileInfo(result) {
        this.wiredData = result;
        let { error, data } = result;
        if (data) {
            console.log("Data portion is ", JSON.stringify(data));
            this.profileInfo = data;
            if(!data.BR_status_Executed_or_New) {
                this.isExecuted_Or_New = false;
            } else {
                this.isExecuted_Or_New = true;
            }
        }
        else if (error) {
            console.log("Error is ", error);
            this.isExecuted_Or_New = false;
        }
    }

    get isUnderRenewal() {
        return this.profileInfo ? this.profileInfo.Renewal_status : '';
    }

    /*get isExecuted_Or_New() {
        return this.profileInfo ? this.profileInfo.BR_status_Executed_or_New : '';
    }*/

    renewalButtonHandler() {
        renewAgreement()
        .then(result => {
            if (result) {
                // Record created successfully
                console.log('Renewal record created: ' + result);
                refreshApex(this.wiredData);
                this.showToast('Success', 'Renewal record created successfully.', 'success');

            } else {
                // Handle error
                console.error('Failed to create renewal record.');
                this.showToast('Error', 'Failed to create renewal record.', 'error');
            }
        })
        .catch(error => {
            // Handle error
            console.error('Error creating renewal record: ' + error.message);
            this.showToast('Error', 'Error creating renewal record.', 'error');
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}