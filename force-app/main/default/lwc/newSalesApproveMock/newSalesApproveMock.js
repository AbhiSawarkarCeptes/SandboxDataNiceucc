import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

export default class NewSalesApproveMock extends NavigationMixin(LightningElement) {

    @track recordId;

    handleSubmit(event) {
        try {
            event.preventDefault();
            console.log("test new Approval");
            console.log(event.detail.fields, "Submitted Approval record details");
            this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'New sales Approval created successfully!',
                    variant: 'success',
                }),
            );
        } catch (error) {
            console.log("handlesubmit---Error", error.message);

        }
    }

    handleSuccess(event) {
        const createdRecordId = event.detail.id;
        console.log('createdRecordId : ' + this.createdRecordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: createdRecordId,
                objectApiName: 'New_Sale_Approval_Mock__c',
                actionName: 'view'
            }
        });

    }

}