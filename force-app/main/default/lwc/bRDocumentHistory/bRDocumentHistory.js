import { LightningElement, wire, api, track } from 'lwc';
import getBRDocumentFileDetails from "@salesforce/apex/BRDocumentHistoryRetriever.getBRDocumentFileDetails";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    {
        label: 'Name',
        fieldName: 'brDocNameUrl',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'brDocName'
            },
            target: '_self' // Open in the same tab
        }
    },
    { label: 'File Name', fieldName: 'fileName', sortable: true },
    { label: 'File Type', fieldName: 'fileType', sortable: true },
    {
        type: 'button',
        label: 'View',
        initialWidth: 100,
        typeAttributes: {
            label: 'View',
            name: 'view',
            title: 'View',
            disabled: false,
            value: 'view',
            iconPosition: 'left',
            iconName: 'utility:preview',
            variant: 'brand'
        }
    }
];

export default class BrFileDownloadAndDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    @track columns = columns;
    @track filesData = [];

    @wire(getBRDocumentFileDetails, { recordId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            console.log('vvk_data');
            console.log(data);
            this.filesData = data.map(item => ({
                ...item,
                id: item.brDocId,
                brDocNameUrl: `/lightning/r/BR_Document_History__c/${item.brDocId}/view`
            }));
        } else if (error) {
             console.log('vvk_error');
             console.log(error);
          //  this.showToast('Error', 'Failed to fetch document file details', 'error');
        }
    } 

    callRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'view') {
            this.handleClick(row.fileIds);
        } else if (actionName === 'open') {
            this.navigateToRecord(row.brDocId);
        }
    }

    @api handleClick(recArray) {
        const fileIds = JSON.parse(recArray);

        fileIds.forEach(item => {
            const config = {
                type: 'standard__webPage',
                attributes: {
                    url: `/sfc/servlet.shepherd/version/download/${item}`
                }
            };
            this[NavigationMixin.Navigate](config);
        });
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'BR_Document_History__c', // Replace with your object API name
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}