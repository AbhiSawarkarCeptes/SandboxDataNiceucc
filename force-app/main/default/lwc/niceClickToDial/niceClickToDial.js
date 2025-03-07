import { LightningElement, api, wire } from 'lwc';
import getPhoneFields from '@salesforce/apex/NiceClickToDialController.getPhoneFieldsFromCmdt';
//add the import for the refesh apex method to updated the phone fields value
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class NiceClickToDial extends LightningElement {
    @api recordId;
    phoneFields = [];
    showSpinner = false;
    showClickToDial = false;
    selectedPhoneNumber;
    errorMessage;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        this.showClickToDial = false;
        this.showSpinner = true;
        this.loadPhoneNumbers();
    }

    loadPhoneNumbers() {
        // Refresh the phone fields to get updated values
        refreshApex(this.phoneFields);
        console.log('Loading phone fields for recordId:', this.recordId);
        getPhoneFields({ recordId: this.recordId })
            .then((data) => {
                if (data && data.length > 0) {
                    this.phoneFields = data.map((field, index) => ({
                        id: index,
                        label: field.label,
                        value: field.value,
                        apiName: field.apiName,
                        showIcon: field.value == 'NA' ?  true : false,
                    }));
                } else {
                    this.errorMessage = 'No phone numbers available for this record.';
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                console.error('Error fetching phone fields:', JSON.stringify(error));
                this.errorMessage = error.body.message;
                this.phoneFields.length = 0;
                this.showSpinner = false;
            });
    }

    handleCall(event) {
        if (event.target.dataset.phone) {
            this.showClickToDial = true;
            this.selectedPhoneNumber = event.target.dataset.phone;
            console.log('Initiating call to:', this.selectedPhoneNumber);
            this.showSpinner = true;
        }
    }

    get mobileNumber() {
        console.log('mobileNumber Called');
        return this.selectedPhoneNumber;
    }

    renderedCallback() {
        console.log('Rendered Callback Called');
        if (this.selectedPhoneNumber) {
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            console.log('renderedCallback : ' + this.selectedPhoneNumber);
            clickToDial.click();
            console.log('renderedCallback : ' + this.selectedPhoneNumber);
            this.dispatchEvent(new CloseActionScreenEvent());
        }

    }
}