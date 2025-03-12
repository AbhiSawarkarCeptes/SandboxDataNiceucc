import { LightningElement, api, wire } from 'lwc';
import getPhoneFields from '@salesforce/apex/Nice_ClickToDialUtility.getPhoneFields';
import { createRecord } from "lightning/uiRecordApi";
import userId from '@salesforce/user/Id';
import API_CALLOUTLOG_OBJECT from "@salesforce/schema/API_Callout_Log__c";
import Context_User from "@salesforce/schema/API_Callout_Log__c.Context_User__c";
import Data_Source from "@salesforce/schema/API_Callout_Log__c.Data_Source__c";
import Request_Body from "@salesforce/schema/API_Callout_Log__c.Request_Body__c";
import Response_Body from "@salesforce/schema/API_Callout_Log__c.Response_Body__c";

export default class nice_ClickToDial extends LightningElement {

    @api recordId;
    phoneFields = [];
    showSpinner = false;
    clickToViewAccess = false;
    showPhoneNumbers = false;
    errorMessage;
    togglecount = 0;

    connectedCallback() {
        this.showSpinner = true;
        this.loadPhoneNumbers();
    }

    loadPhoneNumbers() {
        getPhoneFields({ recordId: this.recordId })
            .then((data) => {
                if (data && data.length > 1) {
                    this.clickToViewAccess = data[0].click_To_View == 'Yes' ? true : false;
                    this.phoneFields = data.slice(1).map((field, index) => ({
                        id: index,
                        label: field.label,
                        value: field.value,
                        actual_Phone: field.actual_Phone,
                        apiName: field.apiName,
                        showIcon: field.value == 'NA' ? true : false,
                        ternio: "terniocx://dialer/" + field.value,
                    }));
                } else {
                    this.errorMessage = 'No phone numbers available for this record.';
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.errorMessage = error.body.message;
                this.phoneFields.length = 0;
                this.showSpinner = false;
            });
    }

    toggleActualPhone(event) {
        this.togglecount++;
        this.showPhoneNumbers = event.target.checked;
        if (event.target.checked && this.togglecount == 1) {
            this.handleCreate();
        }
    }

    async handleCreate() {
        const fields = {};
        fields[Context_User.fieldApiName] = userId;
        fields[Data_Source.fieldApiName] = 'LWC - Nice_ClickToDial Mobile';
        fields[Request_Body.fieldApiName] = 'Requesting to view the actual phone numbers from mobile device';
        fields[Response_Body.fieldApiName] = JSON.stringify(this.phoneFields);
        const recordInput = { apiName: API_CALLOUTLOG_OBJECT.objectApiName, fields: fields };

        try {
            const apiLog = await createRecord(recordInput);
        } catch (error) {
            console.error('Error Message:', JSON.stringify(error));

        }

    }

}