import { LightningElement, api, track } from 'lwc';
import createOfferRecord from '@salesforce/apex/CreateOfferFromPRController.createOfferRecord';
import checkOfferIsCreatedOrNot from '@salesforce/apex/CreateOfferFromPRController.checkOfferIsCreatedOrNot';
import searchPPlans from '@salesforce/apex/CreateOfferFromPRController.searchPPlans';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateOfferFromPR extends NavigationMixin(LightningElement) {
    @api recordId;
    ppIdRec;
    @track showSpinner = false;
    @api frmClsic = false;
    
    @track searchKey = '';
    @track searchResults = [];
    @track showResults = false;


    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.showResults = true;
        this.searchAccounts();
    }

    searchAccounts() {
        console.log(this.recordId);
        searchPPlans({
            searchKeyWrd: this.searchKey,
            recId: this.recordId
        }).then(result => {
            console.log(result);
            this.showSpinner = false;
            this.searchResults = result;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    handleResultClick(event) {
        console.log('handleResultClick****');
        console.log(event.target.title);
        console.log(event.target.dataset.id);
        this.ppIdRec = event.target.title;
        this.searchKey = event.target.dataset.id;
        this.showResults = false;
    }

    showDialog() {
        this.showResults = true;
    }

    connectedCallback() {
        this.showSpinner = true;
        const urlParams = new URLSearchParams(window.location.search);
        console.log(urlParams.get('recordId'));
        checkOfferIsCreatedOrNot({
            recId: urlParams.get('recordId'),
            fromClassic: this.frmClsic
        }).then(result => {
            console.log(result);
                if (result == 'created') {
                    this.showSpinner = false;
                    alert('Offer is already created.');
                    this.handleCancel();
                } else if (result == 'created fromClassic') {
                    this.showSpinner = false;
                    window.open('/'+this.recordId, '_self');
                } else {
                    this.showSpinner = false;
                    this.searchAccounts();
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('rooro -> ',JSON.stringify(error));
                const evt = new ShowToastEvent({
                    label: 'Warning',
                    title: 'Warning',
                    variant: 'warning',
                    message: JSON.stringify(error)
                });
                this.dispatchEvent(evt);
            });
    }
    
    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner = true;
        createOfferRecord({
            ppId: this.ppIdRec,
            recId: this.recordId,
            fromClassic: this.frmClsic
        }).then(result => {
            console.log(result);
                if (result.includes('/a5l')) {
                    this.showSpinner = false;
                    window.open(result, '_self');
                } else {
                    this.showSpinner = false;
                    console.log(result);
                    const evt = new ShowToastEvent({
                        label: 'Warning',
                        title: 'Warning',
                        variant: 'warning',
                        message: result
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('rooro -> ',JSON.stringify(error));
                const evt = new ShowToastEvent({
                    label: 'Warning',
                    title: 'Warning',
                    variant: 'warning',
                    message: JSON.stringify(error)
                });
                this.dispatchEvent(evt);
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}