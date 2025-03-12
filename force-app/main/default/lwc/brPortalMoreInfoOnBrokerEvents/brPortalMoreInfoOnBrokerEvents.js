import { LightningElement, api, wire } from 'lwc';
import getCollataralFiles from '@salesforce/apex/BRPortalBrokerEventsController.getCollataralFiles';
import AllIcons from '@salesforce/resourceUrl/CollateralIcons';
import updateEventsRecord from '@salesforce/apex/BRPortalBrokerEventsController.updateEventsRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class BrPortalMoreInfoOnBrokerEvents extends LightningElement {
    @api eventId;
    @api eventInfo;
    @api
    messageFromParent
    parsedMessage
    showModal = false;
    recId;
    collateralList;
    pdfIcon = AllIcons + '/collateralIcons/pdfFile.svg';
    pngIcon = AllIcons + '/collateralIcons/pngFile.svg';
    jpgIcon = AllIcons + '/collateralIcons/jpgFile.svg';
    editIcon = AllIcons + '/collateralIcons/collateralEdit.svg';
    isDataAvailable;
    isEditMode = false;
    fieldsToUpdate = {};
    isPageBusinessTrip = false
    wiredActivities = {}

    @wire(getCollataralFiles, { linkedRecord: '$recId' })
    collateralFiles(value) {
        {
            this.wiredActivities = value;
            const { data, error } = value;
            if (data && this.parsedMessage) {
                console.log('The data is ', JSON.stringify(data));
                this.collateralList = data.map(content => {
                    let modifiedData;
                    if (content.ContentVersion.FileType == "PDF") {
                        modifiedData = { ...content.ContentVersion, isPdf: true };
                    } else if (content.ContentVersion.FileType == "PNG") {
                        modifiedData = { ...content.ContentVersion, isPng: true };
                    } else {
                        modifiedData = { ...content.ContentVersion, isJpg: true };
                    }
                    modifiedData = { ...modifiedData, downloadURL: `${content.ContentDownloadUrl}` };
                    return modifiedData;
                });
                this.isDataAvailable = this.collateralList.length;
            }
            console.log('The  this.collateralList is ', this.collateralList);
        }
    }

    connectedCallback() {
        this.parsedMessage = JSON.parse(this.messageFromParent);
        console.log('base URLin child is ' + this.parsedMessage.baseUrl);
        this.recId = this.parsedMessage.recId;
    }

    renderedCallback() {
        let htmlContent = '';
        if (this.parsedMessage.pageName != "Business Trip" && this.parsedMessage.pageName != "Open Houses") {
            this.isPageBusinessTrip = false;
            htmlContent = '<div class="slds-grid slds-wrap slds-p-bottom_large"> <div class="slds-col slds-size_6-of-12 display-flex"> <span class="title-one">Campaign Leads</span> <span class="title-two">15 Days Before Event</span> <span class="title-value-text">' + this.campaignLead15Days + '</span> </div> <div class="slds-col slds-size_6-of-12 display-flex"> <span class="title-one">Campaign Leads</span> <span class="title-two">7 Days Before Event</span> <span class="title-value-text">' + this.campaignLead7Days + '</span> </div> </div> <div class="slds-grid slds-wrap"> <div class="slds-col slds-size_6-of-12 display-flex"> <span class="title-one">Walk-ins</span> <span class="title-value-text">' + this.walkins + '</span> </div> <div class="slds-col slds-size_6-of-12 display-flex"> <span class="title-one">Confirmed Meetings</span> <span class="title-value-text">' + this.confirmedMeetingCount + '</span> </div> </div> </div>';
        }
        else {
            this.isPageBusinessTrip = true;
            htmlContent = '<div class="slds-grid slds-wrap slds-p-bottom_large"> <div class="slds-col slds-size_6-of-12 display-flex"> <span class="title-two">Walk-ins</span> <span class="title-value-text">' + this.walkins + '</span> </div> </div>';
        }
        this.template.querySelector('.nonEditHTML').innerHTML = htmlContent;
    }

    get walkins() {
        return this.parsedMessage.walkins ? this.parsedMessage.walkins : "0";
    }

    get confirmedMeetingCount() {
        return this.parsedMessage.confirmedMeetingNo ? this.parsedMessage.confirmedMeetingNo : "0";
    }

    get salesManager() {
        return this.parsedMessage.salesManager ? this.parsedMessage.salesManager : "";
    }

    get salesDirector() {
        return this.parsedMessage.salesDirector ? this.parsedMessage.salesDirector : "";
    }

    get campaignLead15Days() {
        return this.parsedMessage.campaignLead15Days ? this.parsedMessage.campaignLead15Days : "0";
    }

    get campaignLead7Days() {
        return this.parsedMessage.campaignLead7Days ? this.parsedMessage.campaignLead7Days : "0";
    }

    showMoreInfoChildHandler() {
        this.dispatchEvent(new CustomEvent('makeitfalse', {
            detail: {
                makeFalse: false
            }
        }));
    }

    showModalHandler() {
        refreshApex(this.wiredActivities);
        this.showModal = !this.showModal;
    }

    editIconClickHandler() {
        this.isEditMode = !this.isEditMode;
    }

    handleFieldChange(event) {
        console.log('we are in handle field change');
        let field = event.target;// Assuming each input field has a unique id
        let fieldId = field.id
        if (fieldId.includes("-")) {
            fieldId = fieldId.split('-')[0];
        }
        console.log('fieldId', fieldId);
        const fieldValue = field.value;
        const Fieldtype = field.type;
        this.fieldsToUpdate[fieldId] = fieldValue;
        console.log('field is ' + fieldId + 'The value is ' + fieldValue, ' the field type is' + Fieldtype);
        console.log('fieldset for update is ', JSON.stringify(this.fieldsToUpdate));
    }

    saveButtonClickHandler(event) {
        this.fieldsToUpdate["Id"] = this.recId
        console.log('fieldset for update is ' + JSON.stringify(this.fieldsToUpdate));
        updateEventsRecord({ updateData: this.fieldsToUpdate })
        .then(result => {
            if (result) {
                // Record created successfully
                console.log('Event updated : ' + result);
                this.showToast('Success', 'Event record updated successfully.', 'success');
                this.dispatchEvent(new CustomEvent('refreshchilddata', {
                    detail: {
                        message: true
                    }
                }));

            } else {
                // Handle error
                console.error('Failed to create event record.');
                this.showToast('Error', 'Failed to create event record.', 'error');
            }
        })
        .catch(error => {
            // Handle error
            console.error('Error creating event record: ' + error.message);
            this.showToast('Error', 'Error creating event record.', 'error');
        });
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleClose(event) {
        this.dispatchEvent(new CustomEvent('closemoreinfo', {
            detail: {
                id: this.eventId,
                info: this.eventInfo
            }
        }));
    }
}