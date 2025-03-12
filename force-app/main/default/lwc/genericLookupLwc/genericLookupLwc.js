import { LightningElement,api,wire,track } from 'lwc';
import fetchRecords from '@salesforce/apex/LookupController.lookUpSearch';

export default class GenericLookupLwc extends LightningElement {
    @api objname;
    @api iconname;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api selectedName;
    @track records;
    @api isValueSelected = false;
    @track blurTimeout;
    message;
    searchTerm;

    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    /* @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            console.log('data',JSON.stringify(data));
            this.error = undefined;
            this.records = data;
        } else if (error) {
            console.log('error : ',JSON.stringify(error));
            this.error = error;
            this.records = undefined;
        }
    } */

    fetchData() {
        console.log('fetchData : ',this.objname);
        fetchRecords({
            searchTerm : this.searchTerm,
            myObject : this.objname,
            filter : this.filter
        })
        .then(result => {
            if(result && result.length > 0) {
                console.log('result : ',result);           
                    this.records = result;
            } else {
                this.message = "No Records Found for '" + this.searchTerm + "'";
            }
        }).catch(error => {
            this.message = error.message;
        })
    }

    handleClick() {
        console.log('enteredhandleclick');
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    
    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        console.log('selectedId : ',selectedId);
        this.bookingIdVar = selectedId;
        console.log('bookingid' + this.bookingIdVar);
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        /* if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        } */
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() { 
        this.isValueSelected = false;
        var valueUnselected  = true;
        this.searchTerm = '';
        const clearEvent = new CustomEvent('clearlookup', {detail:  valueUnselected });
        this.dispatchEvent(clearEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        console.log('search Term : ',this.searchTerm);
        if(this.searchTerm){
            this.fetchData();
        }
    }

}