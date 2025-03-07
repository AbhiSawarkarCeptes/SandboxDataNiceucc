import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe } from 'lightning/empApi';
import updateTask from '@salesforce/apex/TaskUtilityJSONHandler.updateTask';
import getDependentPicklistValues from '@salesforce/apex/TaskUtilityJSONHandler.getDependentPicklistValues';
import getCRMDependentPicklistValues from '@salesforce/apex/TaskUtilityJSONHandler.getCRMDependentPicklistValues';
import { getRecord } from 'lightning/uiRecordApi';
import publishEvent from '@salesforce/apex/TaskUtilityJSONHandler.publishEvent';

const FIELDS = ['Task__c.Name', 'Task__c.Campaign__r.Name'];

export default class TaskUtility extends LightningElement {
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

    connectedCallback() {
        console.log('Subscribing to open event');
        this.handleSubscribe();
        this.fetchPicklistValues();
    }

    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
            //console.log('received json data=>', response);
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
            //console.log('Fetched Data:', data);
            this.taskName = data.fields.Name.value;
            this.campaignName = data.fields.Campaign__r.displayValue || 'N/A';
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


    handleInputChange(event) {
        const field = event.target.name;
        this.taskFields[field] = event.target.value;
    }

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
            crmcallDispositionL3: this.selectedCRML3Value

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
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Error',
                //         message: 'Error updating Task: ' + error.body.message,
                //         variant: 'error',
                //     })
                // );
                console.error(error);
            });
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