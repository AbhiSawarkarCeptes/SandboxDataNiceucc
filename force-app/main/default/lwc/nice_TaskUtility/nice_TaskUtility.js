import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe } from 'lightning/empApi';
import updateTask from '@salesforce/apex/Nice_TaskDispositionHandler.updateTask';
import getDependentPicklistValues from '@salesforce/apex/Nice_TaskDispositionHandler.getDependentPicklistValues';
import getCRMDependentPicklistValues from '@salesforce/apex/Nice_TaskDispositionHandler.getCRMDependentPicklistValues';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import publishEvent from '@salesforce/apex/Nice_TaskDispositionHandler.publishEvent';

const FIELDS = [
    'Task__c.Name',
    'Task__c.Id',
    'Task__c.Campaign__r.Name', 'Task__c.Campaign__r.Id',
    'Task__c.Booking__r.Name', 'Task__c.Booking__r.Id',
    'Task__c.Unit_No__c',
    'Task__c.Customer_Name__c',
    'Task__c.Account__r.Id',
    'Task__c.Account__r.Name',
    'Task__c.Owner.Profile.Name'
];

export default class Nice_TaskUtility extends NavigationMixin(LightningElement) {
    channelName = '/event/Task_NICE_Event__e';
    @api recordId;
    @track taskFields = {};
    @track isSubscribed;
    @track l1Options = [];
    @track l2Options = [];
    @track l3Options = [];

    @track crml1Options = [];
    @track crml2Options = [];
    @track crml3Options = [];

    @track selectedL1Value = '';
    @track selectedL2Value = '';
    @track selectedL3Value = '';

    @track selectedCRML1Value = '';
    @track selectedCRML2Value = '';
    @track selectedCRML3Value = '';

    dependentValuesMap = {};
    crmdependentValuesMap = {};
    @track campaignName;
    @track taskName;
    @track taskComment;
    @track booking;
    @track unit;
    @track customerName;

    @track campaignId;
    @track bookingId;
    @track accountName;
    @track accountId;
    @track taskId;
    @track profileName;
    @track isCRM = false; 
    @track isCollection = false;


    connectedCallback() {
        console.log('Subscribing to open event');
        this.handleSubscribe();
        this.fetchPicklistValues();
    }

    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
            const jsonData = response.data.payload;
            if (jsonData.Event_Type__c === 'Open_Popup') {
                self.recordId = jsonData.Task_Id__c;
            }
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            this.isSubscribed = response;
        }).catch((error) => {
            console.error('Error during subscription:', error);
        });
    }

    // Wire method to fetch task record and campaign name
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    taskRecord({ error, data }) {
        if (data) {
            console.log('Fetched Data:', data);
            this.taskName = data.fields.Name.value;
            this.taskId = this.recordId;
            this.campaignName = data.fields.Campaign__r.displayValue || 'N/A';
            this.campaignId = data.fields.Campaign__r.value?.id || null;
             /* Added by Ashwini form CRM Call disposition */
            this.booking = data.fields.Booking__r.displayValue || 'N/A';
            this.bookingId = data.fields.Booking__r.value?.id || null;
            this.unit = data.fields.Unit_No__c.value;
            this.customerName = data.fields.Customer_Name__c.value;
            this.accountId = data.fields.Account__r.value?.id || null;
            this.accountName = data.fields.Account__r.displayValue || null;
            this.profileName =  data.fields.Owner.value.fields.Profile.displayValue;
            console.log('Profile Name:', this.profileName);
            if(this.profileName == 'CRM'){
                this.isCRM = true;
                this.isCollection = false;
            }else if (this.profileName == 'Collection') {
                this.isCollection = true;
                this.isCRM = false;
            }else{
                console.log('Im in Admin profile');
                this.isCollection = true;
                this.isCRM = true;
            }
             /* Added by Ashwini form CRM Call disposition */
        } else if (error) {
            console.error('Error fetching task and campaign data:', error);
        }
    }

    fetchPicklistValues() {
        getDependentPicklistValues({
            dependentFieldApiNameL2: 'Call_Disposition_L2__c',
            dependentFieldApiNameL3: 'Call_Disposition_L3__c'
        })
            .then((result) => {
                if (result) {
                    this.l1Options = Object.keys(result.L1toL2).map((key) => ({
                        label: key,
                        value: key
                    }));
                    this.dependentValuesMap = result;
                }
            })
            .catch((error) => {
                console.error('Error fetching dependent picklist values:', error);
            });

        /* Added by Ashwini form CRM Call disposition */
            getCRMDependentPicklistValues({
                dependentFieldApiNameL2: 'CRM_Call_Disposition2__c',
                dependentFieldApiNameL3: 'CRM_Call_Disposition3__c'
            })
                .then((result) => {
                    if (result) {
                        this.crml1Options = Object.keys(result.L1toL2).map((key) => ({
                            label: key,
                            value: key
                        }));
                        this.crmdependentValuesMap = result;
                    }
                })
                .catch((error) => {
                    console.error('Error fetching dependent picklist values:', error);
                });
                /* Added by Ashwini form CRM Call disposition */
    }

    handleL1Change(event) {
        this.selectedL1Value = event.target.value;
        const l2Values = this.dependentValuesMap.L1toL2[this.selectedL1Value] || [];
        this.l2Options = l2Values.map((value) => ({
            label: value,
            value: value
        }));
        this.selectedL2Value = ''; // Reset L2 and L3 values
        this.selectedL3Value = '';
        this.l3Options = [];
    }

    handleL2Change(event) {
        this.selectedL2Value = event.target.value;
        const l3Values = this.dependentValuesMap.L2toL3[this.selectedL2Value] || [];
        this.l3Options = l3Values.map((value) => ({
            label: value,
            value: value
        }));
        this.selectedL3Value = ''; // Reset L3 value
    }

    handleL3Change(event) {
        this.selectedL3Value = event.target.value;
    }

/* Added by Ashwini form CRM Call disposition */
    handleCRML1Change(event) {
        this.selectedCRML1Value = event.target.value;
        const l2Values = this.crmdependentValuesMap.L1toL2[this.selectedCRML1Value] || [];
        this.crml2Options = l2Values.map((value) => ({
            label: value,
            value: value
        }));
        this.selectedCRML2Value = ''; // Reset L2 and L3 values
        this.selectedCRML3Value = '';
        this.crml3Options = [];
    }

    handleCRML2Change(event) {
        this.selectedCRML2Value = event.target.value;
        const l3Values = this.crmdependentValuesMap.L2toL3[this.selectedCRML2Value] || [];
        this.crml3Options = l3Values.map((value) => ({
            label: value,
            value: value
        }));
        this.selectedCRML3Value = ''; // Reset L3 value
    }

    handleCRML3Change(event) {
        this.selectedCRML3Value = event.target.value;
    }

    /* Added by Ashwini form CRM Call disposition */


    handleInputChange(event) {
        const field = event.target.name;
        this.taskFields[field] = event.target.value;
    }

     /* Added by Ashwini form CRM Call disposition */
    handleComment( event ) {
        console.log( 'Updated Value is ' + event.detail.value );
        this.taskComment = event.detail.value;
    }
     /* Added by Ashwini form CRM Call disposition */

    handleSave() {
        if (
            (!this.selectedL1Value || !this.selectedL2Value || !this.selectedL3Value) &&
            (!this.selectedCRML1Value || !this.selectedCRML2Value || !this.selectedCRML3Value)
        ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select all Call Disposition values before saving.',
                    variant: 'error',
                })
            );
            return;
        }
        updateTask({
            taskId: this.recordId,
            callDispositionL1: this.selectedL1Value,
            callDispositionL2: this.selectedL2Value,
            callDispositionL3: this.selectedL3Value,
            crmcallDispositionL1: this.selectedCRML1Value,
            crmcallDispositionL2: this.selectedCRML2Value,
            crmcallDispositionL3: this.selectedCRML3Value,
            updatedTaskComment: this.taskComment
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Task updated successfully',
                        variant: 'success',
                    })
                );
                this.publishCustomEvent();
            })
            .catch((error) => {
                console.error(error);
            });
    }


     /* Added by Ashwini form CRM Call disposition */
    handleNavigation(event) {
        const targetRecordId = event.currentTarget.dataset.id;
       
        if (targetRecordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: targetRecordId,
                    actionName: 'view'
                }
            });
        }
    }

    publishCustomEvent() {
        const jsonData = {
            "Event_Type": 'Close_Popup'
        }
        console.log('Event Type=> ', JSON.stringify(jsonData));
        publishEvent({ jsonString: JSON.stringify(jsonData) })
            .catch(error => {
                console.error('Error:', error);
            });
    }
}