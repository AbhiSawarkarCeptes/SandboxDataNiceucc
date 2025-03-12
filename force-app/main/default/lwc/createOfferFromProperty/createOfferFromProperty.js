import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import searchPPlans from '@salesforce/apex/CreateOfferFromPropertyController.searchPPlans';
import updateOffer from '@salesforce/apex/CreateOfferFromPropertyController.updateOffer';

export default class CreateOfferFromProperty extends NavigationMixin(LightningElement) {
    @track recordId;
    @api propertyId;
    @api propertyTypeId;
    @api projectId;
    @track PropStrength__Offer__c = {
        PropStrength__Project__c: null,
        PropStrength__Property_Type__c: null,
        PropStrength__Property__c: null
    };
    @track searchKey = '';
    @track searchResults = [];
    @track showResults = false;
    @track showSpinner = false;
    @track ppIdRec;

    connectedCallback() {
        console.log(this.propertyId);
        console.log(this.propertyTypeId);
        console.log(this.projectId);
        this.showSpinner = true;
        this.PropStrength__Offer__c.PropStrength__Project__c = this.projectId;
        this.PropStrength__Offer__c.PropStrength__Property_Type__c = this.propertyTypeId;
        this.PropStrength__Offer__c.PropStrength__Property__c = this.propertyId;
        this.searchAccounts();
    }

    handleError(event) { 
        alert('Offer not Created!!');
    }

    handleSuccess(event) {
        this.recordId = event.detail.id;
        console.log(this.recordId);
        updateOffer({
            ppIdRecord: this.ppIdRec,
            recId: this.recordId
        }).then(result => {
            console.log(result);
            if (result == 'Success') {
                window.open('/lightning/r/PropStrength__Offer__c/'+this.recordId+'/view', '_self');
            } else {
                alert(result);
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            alert(JSON.stringify(error));
        });
    }

    handleShowSpinner() {
        this.showSpinner = true;
    }

    handleCancel() {
        window.open('/lightning/r/PropStrength__Property__c/'+this.propertyId+'/view', '_self');
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.showResults = true;
        this.searchAccounts();
    }

    searchAccounts() {
        console.log(this.PropStrength__Offer__c.PropStrength__Project__c);
        searchPPlans({
            searchKeyWrd: this.searchKey,
            recId: this.PropStrength__Offer__c.PropStrength__Project__c
        }).then(result => {
            console.log(result);
            this.showSpinner = false;
            this.searchResults = result;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            alert(JSON.stringify(error));
        });
    }

    handleResultClick(event) {
        this.ppIdRec = event.target.title;
        this.searchKey = event.target.dataset.id;
        this.showResults = false;
    }

    showDialog() {
        this.showResults = true;
    }
}