import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRelatedFiles from '@salesforce/apex/FileUploadViewController.getRelatedFiles';
import changeFileTitle from '@salesforce/apex/FileUploadViewController.changeFileTitle';

export default class FileUploadView extends LightningElement{
    @api label;
    @api formats = '.png,.pdf';
    @api recordId;
    @api filename;

    get acceptedFormats() {
        return this.formats.split(',');
    }

    connectedCallback() {
        this.recordId = this.recordId.replace("/",'');
    }

    @wire(getRelatedFiles, { recordId: '$recordId' , filename: '$filename'})
    files;

    handleActionFinished(event) {
        //refresh the list of files
        const uploadedFile = event.detail.files[0];
        var documentId  = uploadedFile.documentId;
        changeFileTitle({ documentId: documentId, filename: this.filename })
            .then(result => {
            })
            .catch(error => {
            });

        console.log('record id here : '+this.recordId);
        refreshApex(this.files);
    }
}