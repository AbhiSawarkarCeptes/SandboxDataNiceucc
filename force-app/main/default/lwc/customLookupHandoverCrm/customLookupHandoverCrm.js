import { LightningElement, api } from 'lwc';
import searchUsers from '@salesforce/apex/CustomLookupAppBookController.searchUsers';
import updateHandoverCrm from '@salesforce/apex/CustomLookupAppBookController.updateHandoverCrm';

export default class CustomLookupsApplicationBooking extends LightningElement {
    @api bookingId;

    searchKeyHandoverCrm = '';
    showResultsHC = false;
    searchResultsHC;
    selectedHandoverCrm;
    showHandoverCrmLookup = true;

    connectedCallback() {
        console.log('bookingId');
        console.log(this.bookingId);
        this.searchUser2();
    }

    handleSearchKeyChangeHC(event) {
        console.log('in handleSearchKeyChangeHC');
        this.searchKeyHandoverCrm = event.target.value;
        this.showResultsHC = true;
        if (this.searchKeyHandoverCrm.length == 0 || this.searchKeyHandoverCrm == undefined) {
            this.searchKeyHandoverCrm = '';
            this.showHandoverCrmLookup = true;
            this.selectedHandoverCrm = '';
            this.showResultsHC = false;
            this.updateRecord();   
        }
        this.searchUser2();
    }

    searchUser2(){
        searchUsers({
            searchKeyWrd: this.searchKeyHandoverCrm
        }).then(result => { 
            console.log(' this.searchResultsHC',  this.searchResultsHC);
            this.searchResultsHC = result;
            this.showHandoverCrmLookup = false;
            console.log(' this.searchResultsHC 1',  this.searchResultsHC);
        })
        .catch(error => {
            console.log(error);
        });
    }

    showDialogHC() {
        this.showResultsHC = true;
    }

    handleResultClickHC(event) {
        console.log('handle result click');
        this.showResultsHC = false;
        this.searchKeyHandoverCrm = event.target.dataset.id;
        console.log('handle result click'+ this.searchKeyHandoverCrm);
        this.selectedHandoverCrm = event.target.title;
        console.log('handle result click' + this.selectedHandoverCrm);
        this.showHandoverCrmLookup = true;
        this.updateRecord();        
    }

    updateRecord() {
        updateHandoverCrm({
            handoverCrm: this.selectedHandoverCrm,
            recId: this.bookingId
        }).then(result => { 
            console.log('Success');
            this.showHandoverCrmLookup = false;
        })
        .catch(error => {
            console.log(error);
        });
    }
}