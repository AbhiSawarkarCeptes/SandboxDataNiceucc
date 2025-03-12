import { LightningElement, api, track } from 'lwc';
import checkBookingIsAvailable from '@salesforce/apex/ResaleprocessFromAppBookingController.checkBookingIsAvailable';
import retrieveSellerInfo from '@salesforce/apex/ResaleprocessFromAppBookingController.retrieveSellerInfo';
import getPicklistValuesResaleType from '@salesforce/apex/ResaleprocessFromAppBookingController.getPicklistValuesResaleType';

export default class ResaleprocessFromAppBooking extends LightningElement {
    @api recordId;
    @track showSpinner;
    @track showForm = false;
    @track activeSections = ['ResaleProcess', 'SellerInformation', 'BuyerInformation'];
    sellerName = '';
    sellerEmail = ''
    sellerPhone = '';
    sellerNationality = '';
    sellerPassportNo = '';
    sellerAddress = '';
    @track selectedResaleType = '';
    resaleTypeOptions = [];

    connectedCallback() {
        console.log('connectedCallback:', this.recordId);
        this.showSpinner = true;
        this.checkBooking();
    }

    checkBooking() {
        console.log('checkBooking:', this.recordId);
        checkBookingIsAvailable({
            recId: this.recordId
        }).then(result => {
            if (result == 'Yes') {
                this.retreiveSellerInformation();
                this.getResalesTypePLValues();
            } else {
                this.showSpinner = false;
                alert(result);
                window.open('/lightning/r/PropStrength__Application_Booking__c/'+this.recordId+'/view','_self');
            }
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            alert(JSON.stringify(error));
            window.open('/lightning/r/PropStrength__Application_Booking__c/'+this.recordId+'/view','_self');
        });
    }

    handleToggleSection(event) {
        console.log('handleToggleSection::', event.detail.openSections);
    }

    retreiveSellerInformation() {
        console.log('retrieveSellerInfo:', this.recordId);
        retrieveSellerInfo({
            recId: this.recordId
        }).then(result => {
            if (result != undefined && result != null) {
                this.sellerName = result.PropStrength__Applicant_Details__r[0].PropStrength__Customer_Name__c;
                this.sellerEmail = result.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Email__c;
                this.sellerPhone = result.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Mobile__c;
                this.sellerNationality = result.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Acc__r.PropStrength__Nationality__c;
                this.sellerPassportNo = result.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Acc__r.Passport_No__c;
                this.sellerAddress = result.PropStrength__Applicant_Details__r[0].PropStrength__Applicant_Address__c;
            } else {
                alert('Record Id Is Missing.');
            }
            
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            alert(JSON.stringify(error));
        });
    }

    getResalesTypePLValues() {
        console.log('getPicklistValuesResaleType:');
        getPicklistValuesResaleType({}).then(result => {
            this.showSpinner = false;
            if (result != undefined && result != null && result.length > 0) {
                var plList = [];
                for (var i = 0; i < result.length; i++) {
                    plList.push({label: result[i], value: result[i]});
                }
                this.resaleTypeOptions = plList;
                this.showForm = true;
            } else {
                alert('No Picklist values found for Resale Type Field.');
            }
            
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            alert(JSON.stringify(error));
        });
    }

    handleResaleTypeChange(event) {
        console.log('handleResaleTypeChange:', event.detail.value);
        this.selectedResaleType = event.detail.value;
    }
}