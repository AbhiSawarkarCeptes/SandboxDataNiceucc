import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe } from 'lightning/empApi';
import updateTask from '@salesforce/apex/TaskUtilityStandardJSONHandler.updateTask';
import getDependentPicklistValues from '@salesforce/apex/TaskUtilityStandardJSONHandler.getDependentPicklistValues';
import { getRecord } from 'lightning/uiRecordApi';
import publishEvent from '@salesforce/apex/TaskUtilityStandardJSONHandler.publishEvent';

const FIELDS = ['Task.WhoId', 'Task.Who.Name', 'Task.Call_Attempt_Status__c', 'Task.Sub_Dispositions__c', 'Task.Subject'];

export default class taskUtilityStandard extends LightningElement {
    channelName = '/event/Task_NICE_Event__e';
    @api recordId;
    @track taskFields = {};
    @track isSubscribed;
    @track l1Options = [];
    @track l2Options = [];
    
    @track selectedL1Value = '';
    @track selectedL2Value = '';

    dependentValuesMap = {};
    @track taskName;

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

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    taskRecord({ error, data }) {
        if (data) {
            this.taskName = data.fields.Who?.displayValue || 'N/A';
            this.selectedL1Value = data.fields.Call_Attempt_Status__c.value;
            this.selectedL2Value = data.fields.Sub_Dispositions__c.value;
            
            if (this.selectedL1Value) {
                const l2Values = this.dependentValuesMap.L1toL2[this.selectedL1Value] || [];
                this.l2Options = l2Values.map((value) => ({
                    label: value,
                    value: value
                }));
            }
        } else if (error) {
            console.error('Error fetching task and campaign data:', error);
        }
    }

    fetchPicklistValues() {
        getDependentPicklistValues({
            dependentFieldApiNameL1: 'Call_Attempt_Status__c',
            dependentFieldApiNameL2: 'Sub_Dispositions__c'
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
    }

    handleL1Change(event) {
        this.selectedL1Value = event.target.value;
        const l2Values = this.dependentValuesMap.L1toL2[this.selectedL1Value] || [];
        this.l2Options = l2Values.map((value) => ({
            label: value,
            value: value
        }));
        this.selectedL2Value = '';
    }

    handleL2Change(event) {
        this.selectedL2Value = event.target.value;
    }

    handleSave() {
        if (!this.selectedL1Value || !this.selectedL2Value) {
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
            callDispositionL2: this.selectedL2Value
        })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Task Record is Updated',
                        variant: 'success',
                    })
                );
                this.publishCustomEvent('Close_Popup');
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    publishCustomEvent(eventType = 'Close_Popup') {
        const jsonData = {
            "Event_Type": eventType,
            "Task_Id": this.recordId
        };
        publishEvent({ jsonString: JSON.stringify(jsonData) })
            .catch(error => {
                console.error('Error:', error);
            });
    }
}
