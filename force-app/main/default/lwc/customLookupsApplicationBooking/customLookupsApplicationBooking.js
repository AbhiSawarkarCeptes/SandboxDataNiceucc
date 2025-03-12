import { LightningElement, api } from 'lwc';
import searchUsers from '@salesforce/apex/CustomLookupAppBookController.searchUsers';
import updateHomeOrientation from '@salesforce/apex/CustomLookupAppBookController.updateHomeOrientation';

export default class CustomLookupsApplicationBooking extends LightningElement {
    @api bookingId;
    searchKeyHomeOrientation = '';
    showResultsHO = false;
    searchResultsHO;
    selectedHomeOrientation;
    showHomeOrientationLookup = true;

    connectedCallback() {
        console.log('bookingId');
        console.log(this.bookingId);
        this.searchUser();
    }

    handleSearchKeyChangeHO(event) {
        console.log('in handleSearchKeyChangeHO');
        this.searchKeyHomeOrientation = event.target.value;
        this.showResultsHO = true;
        if (this.searchKeyHomeOrientation.length == 0 || this.searchKeyHomeOrientation == undefined) {
            this.searchKeyHomeOrientation = '';
            this.showResultsHO = false;
            this.showHomeOrientationLookup = true;
            this.selectedHomeOrientation = '';
            this.updateRecord();   
        }
        this.searchUser();
    }

    searchUser(){
        searchUsers({
            searchKeyWrd: this.searchKeyHomeOrientation
        }).then(result => { 
            console.log(' this.searchResultsHO',  this.searchResultsHO);
            this.searchResultsHO = result;
            this.showHomeOrientationLookup = false;
            console.log(' this.searchResultsHO 1',  this.searchResultsHO);
        })
        .catch(error => {
            console.log(error);
        });
    }

    showDialogHO() {
        this.showResultsHO = true;
    }

    handleResultClickHO(event) {
        console.log('handle result click');
        this.showResultsHO = false;
        this.searchKeyHomeOrientation = event.target.dataset.id;
        console.log('handle result click'+ this.searchKeyHomeOrientation);
        this.selectedHomeOrientation = event.target.title;
        console.log('handle result click' + this.selectedHomeOrientation);
        this.showHomeOrientationLookup = true;
        this.updateRecord();        
    }

    updateRecord() {
        updateHomeOrientation({
            homeOrientation: this.selectedHomeOrientation,
            recId: this.bookingId
        }).then(result => { 
            console.log('Success');
            this.showHomeOrientationLookup = false;
        })
        .catch(error => {
            console.log(error);
        });
    }
}