import { LightningElement, api, wire } from 'lwc';
import getPhoneFields from '@salesforce/apex/Nice_ClickToDialUtility.getPhoneFields';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class nice_ClickToDial extends LightningElement {

    @api recordId;
    phoneFields = [];
    showSpinner = false;
    showClickToDial = false;
    clickToViewAccess = false;
    showPhoneNumbers = false;
    selectedPhoneNumber;
    errorMessage;

    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //     if (currentPageReference) {
    //         this.recordId = currentPageReference.state.recordId;
    //     }
    // }

    connectedCallback() {
        console.log('recordId -->'+ this.recordId);
        this.showClickToDial = false;
        this.showSpinner = true;
        this.loadPhoneNumbers();
    }

    loadPhoneNumbers() {
        getPhoneFields({ recordId: this.recordId })
            .then((data) => {
                if (data && data.length > 1) {
                    this.clickToViewAccess = data[0].click_To_View == 'Yes' ? true : false; 
                    this.phoneFields = data.slice(1).map((field, index) => ({
                        id: index,
                        label: field.label,
                        value: field.value,
                        actual_Phone: field.actual_Phone,
                        apiName: field.apiName,
                        showIcon: field.value == 'NA' ?  true : false,
                    }));
                } else {
                    this.errorMessage = 'No phone numbers available for this record.';
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.errorMessage = error.body.message;
                this.phoneFields.length = 0;
                this.showSpinner = false;
            });
    }

    handleCall(event) {
        if (event.target.dataset.phone) {
            this.showClickToDial = true;
            this.selectedPhoneNumber = event.target.dataset.phone;
            this.showSpinner = true;
        }

        
    }

    get mobileNumber() {
        return this.selectedPhoneNumber;
    }

    renderedCallback() {
        console.log('renderedCallback Called -- >'+ this.recordId);
        if (this.selectedPhoneNumber) {
            const clickToDial = this.template.querySelector('lightning-click-to-dial');
            clickToDial.click();
            this.dispatchEvent(new CloseActionScreenEvent());
        }

    }

    toggleActualPhone(event) {
        this.showPhoneNumbers = event.target.checked;
    }
}