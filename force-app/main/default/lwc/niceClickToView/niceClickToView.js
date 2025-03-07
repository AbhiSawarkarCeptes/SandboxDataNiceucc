import { LightningElement, api, wire } from 'lwc';
import getPhoneFields from '@salesforce/apex/niceClickToViewController.getPhoneFieldsValueToClickToView';
import { refreshApex } from '@salesforce/apex'; // Import refreshApex
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class NiceClickToView extends LightningElement {
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
        //this.showSpinner = true;
        refreshApex(this.phoneFields); 
        console.log('Loading phone fields for recordId:', this.recordId);
        getPhoneFields({ recordId: this.recordId })
            .then((data) => {
                if (data && data.length > 0) {
                    this.phoneFields = data.map((field) => ({
                        id: field.apiName,
                        label: field.label,
                        value: field.value === 'NA' ? 'Not Available' : field.value,
                        encryptedValue: field.value === 'NA' ? 'Not Available' : field.value,
                        apiName: field.apiName,
                        showIcon: field.value == 'NA' ? true : false,
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


/*import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PRIMARY_MOBILE_FIELD from'@salesforce/schema/Lead.Primary_Mobile_Number__c';
import SECONDARY_MOBILE_FIELD from'@salesforce/schema/Lead.Secondary_Mobile_Number__c';
export default class NiceClickToView extends LightningElement {
    @api recordId;
    primaryMobile;
    secondaryMobile;
    isPrimaryCallDisabled = true;
    isSecondaryCallDisabled = true;
    primaryMobileLabel = 'Primary Mobile Number';
    secondaryMobileLabel = 'Secondary Mobile Number';
    
    @wire (getRecord, {recordId: '$recordId', fields:[PRIMARY_MOBILE_FIELD,SECONDARY_MOBILE_FIELD]})
    getwireLead({error, data}){
        if(data){
            this.primaryMobile = getFieldValue(data,PRIMARY_MOBILE_FIELD); 
            this.secondaryMobile = getFieldValue(data,SECONDARY_MOBILE_FIELD);

            this.isPrimaryCallDisabled = !this.primaryMobile;
            this.isSecondaryCallDisabled = !this.secondaryMobile;
        }
        else if(error){
            console.error('error feteching lead record Phone Number: ',error);
        }
    }
    handleCallPrimary(){
        this.initiateCall(this.primaryMobile);
    }
    handleCallSecondary(){
        this.initiateCall(this.secondaryMobile);
    }
    initiateCall(phoneNumber){
        if(phoneNumber){
            if(window.sforce && window.sforce.opencti){
                window.sforce.opencti.screenPop({
                    type: "phone",
                    params: {phone:phoneNumber}
                });
            }else {
                alert('open CTI is not available. please check your omni-channel setup.');
            }
        }
    }
}*/
}
