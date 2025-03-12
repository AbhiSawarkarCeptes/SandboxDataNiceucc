import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class ReceiptMock extends NavigationMixin(LightningElement) {
    handleSubmit(event) {
        try {
            this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Receipt created successfully!',
                    variant: 'success',
                }),
            );
            console.log(event.detail.fields, "handle");
        } catch (error) {
            console.log("error--handleReceipt", error.message);
        }
    }

    handleSuccess(event) {
        const createdRecordId = event.detail.id;
        console.log('createdRecordId : ' + this.createdRecordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: createdRecordId,
                objectApiName: 'Receipt_Downtime_Record__c',
                actionName: 'view'
            }
        });

    }
}