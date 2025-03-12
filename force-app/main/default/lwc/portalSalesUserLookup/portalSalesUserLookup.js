import { LightningElement, track, wire, api } from 'lwc';
import getSalesTeam from '@salesforce/apex/PortalBrokerEventsController.getSalesTeam';

export default class PortalSalesUserLookup extends LightningElement {
    @track searchKey = "";
    objectApiName = 'User';
    recordsList = [];
    message = "";
    error = "";
    selectedRecordId = "";
    selectedValue = "";
    @api fieldapi;

    handleKeyChange(event) {
        this.searchKey = event.target.value;
        this.getLookupResult();
    }

    getLookupResult() {
        getSalesTeam({ searchKey: this.searchKey, objectName: this.objectApiName })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result.map(record => {
                        const firstName = record.FirstName ? record.FirstName : '';
                        const lastName = record.LastName ? record.LastName : '';
                        const completeName = (firstName + ' ' + lastName).trim();

                        return {
                            ...record,
                            FirstName: firstName,
                            LastName: lastName,
                            completeName: completeName
                        };
                    });
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";

        this.dispatchEvent(
            new CustomEvent('select', {
                detail: {
                    fieldName: this.fieldapi,
                    value: this.selectedValue
                }
            })
        );

        // Clear the list after selection
        this.recordsList = [];
    }

    removeRecordOnLookup() {
        this.selectedRecordId = "";
        this.selectedValue = "";
        this.searchKey = "";
        this.recordsList = [];
    }

    get recordPresent() {
        return this.recordsList.length > 0;
    }

    // Modified method to hide dropdown when clicking outside
    onLeave(event) {
        const relatedTarget = event.relatedTarget;
        const lookupDiv = this.template.querySelector('[data-key="dropdownresult"]');
        const inputField = this.template.querySelector('[data-key="searchdiv"]');

        // If the clicked element is outside both the dropdown and input field, hide the list
        if (
            !lookupDiv?.contains(relatedTarget) &&
            !inputField?.contains(relatedTarget)
        ) {
            this.recordsList = [];
             this.searchKey = ""; 
        }
    }

    // Prevent the dropdown from closing when selecting an item
    handleMouseDown(event) {
        event.preventDefault(); // Prevent focusout from triggering when selecting an item
    }
}