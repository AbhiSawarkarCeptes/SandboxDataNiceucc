/* eslint-disable dot-notation */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import Id from '@salesforce/user/Id';
import { refreshApex } from '@salesforce/apex';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import {
    getRecord
} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import priortiseDialingQueue from '@salesforce/apex/CTIManagementServices.priortiseDialingQueue';
import callById from '@salesforce/apex/CTIManagementServices.callById';
import getUserNamePicklist from '@salesforce/apex/CTIManagementServices.getUserNamePicklist';
import reassignLeads from '@salesforce/apex/CTIManagementServices.reassignLeads';

const COLS = [
    { label: 'Entity Type', fieldName: 'objectType', cellAttributes: { alignment: 'center' } },
    {
        label: 'Priority Bucket',
        fieldName: 'priorityBucket',
        cellAttributes:
        {
            class:
                { fieldName: 'priorityBucket' }
        }
    },
    { label: 'Priority #', fieldName: 'priorityString' },
    { label: 'Unserviced Time', fieldName: 'unservicedDateTimeFormatted' },
    { label: 'Followup Time', fieldName: 'followTimeFormatted' },
    {
        label: 'Customer Name', fieldName: 'URL', type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_self'
        },
    },
    { label: 'Mobile Phone', fieldName: 'mobilePhone' },
    { label: 'Owner', fieldName: 'ownerName' },
    {
        label: 'Make Call', fieldName: 'disableMakeCall', type: 'button', typeAttributes: {
            disabled: { fieldName: 'disableMakeCall' },
            iconName: 'action:call',
            label: '',
            name: 'onCallButtonClick',
            title: 'Call',
            variant: 'Success'

        }
    }
];
export default class callingQueue extends NavigationMixin(LightningElement) {
    @track PresalesUsers;
    @wire(getUserNamePicklist)
    wirePresalesUsers({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('Presales Users:', data);
            this.PresalesUsers = data;
        }
    }
    @api records = [];
    @api errors;
    userId = Id;

    @track error;
    @track userEmail;
    @track userName;
    @track title;
    @track columns = COLS;
    wiredRecords;
    @track hideSelect = false;
    @track allowReassign = false;
    @track selected;
    @track el;
    @track reassignToId;
    @wire(getRecord, {
        recordId: '$userId',
        fields: [NAME_FIELD, EMAIL_FIELD, PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userEmail = data.fields.Email.value;
            this.userName = data.fields.Name.value;
            this.title = 'Prioritised calling list for:' + this.userName;
            this.profile = data.fields.Profile.value.fields.Name.value;
            console.log('profile name', data.fields.Profile.value.fields.Name.value);
            if (this.profile === 'System Administrator') {
                this.hideSelect = false;
                this.allowReassign = true;
                this.title = 'Monitoring Dashboard View for:' + this.userName;
            }
            console.log('Reassign Permission:' + this.allowReassign);
        }
    }

    // we are taking in result and then splitting in to data and error 
    // because for cloning the data taking them directly into error and data wasn't working
    @wire(priortiseDialingQueue, {
        userId: '$userId'
    })
    wirePrioritiseDailingQueue(
        result) {
        this.wiredRecords = result;
        console.log('wired calling queue records:' + this.wiredRecords);
        const { data, error } = result;
        if (typeof result !== "undefined") {
            if (data) {
                // cloning the object returned by wire method as it is immutable
                // if we need to make modifications we need to clone and then change
                // here we are dynamically introducing an URL field into each record
                // which make the name field a clickable link
                // {...data} to clone not working. only the below method workss
                this.records = JSON.parse(JSON.stringify(data));
                this.errors = undefined;
                console.log('records :', this.records);
                console.log()
                Object.values(this.records).forEach(item => {
                    item.URL = '/lightning/r/' + item.objectType + '/' + item.recordId + '/view';
                    console.log('URL:' + URL);
                })
            } else {
                this.errors = error;
                this.records = undefined;
                console.log('error', this.errors);

            }
        }
    }
    connectedCallback() {
        // eslint-disable-next-line no-alert
        let self = this;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.setInterval(
            // eslint-disable-next-line no-alert
            function () {
                // eslint-disable-next-line no-alert
                // eslint-disable-next-line no-undef
                refreshApex(self.wiredRecords);
            }, 60000
        );

    }

    get hasRecords() {
        console.log('records' + this.records);
        if (this.records) {
            return (this.records.length > 0);
        }
        return false;
    }
    // handles the actions defined on the data table rows.
    // each action has name as defined in the column definition of that specific field
    // in this case we have defined an event called onCallButtonClick on the make call field
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        window.console.log('actionName ====> ' + actionName);
        let row = event.detail.row;
        window.console.log('row ====> ' + row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'onCallButtonClick':
                this.makeCall(row);
                break;
        }
    }
    makeCall(currentRow) {
        console.log('current row clicked on make call:', currentRow.recordId);
        const selectedRecId = currentRow.recordId;
        // calling the apex method imperatively on button click
        callById({
            recordID: selectedRecId
        })
            .then(result => {
                console.log('result:', result);
                if (result === 'success') {
                    const toastSuccess = new ShowToastEvent({
                        'title': 'Success',
                        'message': 'Call has been placed',
                        'variant': 'success'
                    });
                    this.dispatchEvent(toastSuccess);
                } else {
                    const toastError = new ShowToastEvent({
                        'title': 'Exception',
                        'message': 'Unable to place a call to due an error:' + result,
                        'variant': 'error'
                    });
                    this.dispatchEvent(toastError);
                }
                this.navigateToRecordDetail(selectedRecId);
                return refreshApex(this.wiredRecords);

            })
            .catch(error => {
                console.log('error:', error);
                const toastError = new ShowToastEvent({
                    'title': 'System Exception',
                    'message': 'An unknown exception occurred while placing the call:' + error,
                    'variant': 'error'
                });
                this.dispatchEvent(toastError);
            })
    }
    // this for handling the action when user clicks on the customer name link on the calling queue list
    navigateToRecordDetail(selectedRecId) {
        console.log('navigation mixin:', selectedRecId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecId,
                actionName: 'view'
            }
        });
    }
    // this is for handling the reassign button
    handleclick() {
        console.log('in handle click of reassign button:');
        this.el = this.template.querySelector('lightning-datatable');
        console.log(this.el);
        this.selected = this.el.getSelectedRows();
        console.log('records:', this.selected);
        this.changeOwner(this.selected, this.reassignToId);
    }
    // this is for handling the picklist selection
    onValueSelection(event) {
        console.log(event.target.value);
        this.reassignToId = event.target.value;
    }
    changeOwner(records, owner) {
        console.log('In change owner method:', records, owner);
        reassignLeads({
            callingList: records,
            newOwner: owner
        })
            .then(result => {
                console.log('result:', result);
                if (result === 'success') {
                    const toastSuccess = new ShowToastEvent({
                        'title': 'Success',
                        'message': 'Selected records have been reassigned',
                        'variant': 'success'
                    });
                    this.dispatchEvent(toastSuccess);
                } else {
                    const toastError = new ShowToastEvent({
                        'title': 'Exception',
                        'message': 'Unable to records due to an error:' + result,
                        'variant': 'error'
                    });
                    this.dispatchEvent(toastError);
                }
                return refreshApex(this.wiredRecords);
            })
            .catch(error => {
                console.log('error:', error);
                const toastError = new ShowToastEvent({
                    'title': 'System Exception',
                    'message': 'An unknown exception occurred while reassigning the records',
                    'variant': 'error'
                });
                this.dispatchEvent(toastError);
            })
    }

    // this is for handling the refresh button
    handleclickRefresh() {
        console.log('in handle click of refresh button:' + this);
        return refreshApex(this.wiredRecords);
    }


}