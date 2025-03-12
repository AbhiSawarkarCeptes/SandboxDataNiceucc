import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import brokerAccountCSS from '@salesforce/resourceUrl/brokerAccountCSS';
import { DOCS_MAP } from 'c/brokerAccountsConstants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteDocuments from '@salesforce/apex/BrokerRenewFormExternalController.deleteDocuments';
import createAttachment from '@salesforce/apex/BrokerAccountFormExternalController.createAttachment';


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BrokerRegSource from '@salesforce/schema/Broker_Renewal__c.Nationality__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BROKERREG_OBJECT from '@salesforce/schema/Broker_Renewal__c';

import getDocID from '@salesforce/apex/BrokerRenewFormExternalController.getDocID';
const MAX_FILE_SIZE = 5000000;
const defaultFieldApi = ['Id','Broker_Category__c','Account_Owner_Email__c','Broker_Sub_Type__c','Owner_s_Email__c','Broker_Account__r.PropStrength__Broker_Code__c','Nationality__c','Designation__c','RERA_Registration_No__c', 'Name_as_per_passport__c', 'Office_Apartment_number__c','Email_ID_1__c','ZIP_Postal_Code_PO_Box__c', 'Mobile_No__c','Phone__c','Street_name__c','City_Province__c', 'District_Area__c','Country__c','Villa_Building_name__c', 'Name_as_per_trade_license__c','Witness_Email__c','Witness_Name__c','Broker_Created_Date__c','Registration_Number__c','Registration_Link_Expiry_Date_Time__c'];

export default class BrokerRenewIntniIndividual extends LightningElement {
    @track _record = {};
    @track files;
    @api today;
    showHeader = '';
    docToDelete = [];
    formType = 'Renewal';
    showSpinner = false;
    
    
    @api options = {};  nationalityPicklistVal =[];
    
    @api
    get record() {
        return this._record;
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    @wire(getObjectInfo, { objectApiName: BROKERREG_OBJECT })
    brokerRegInfo;
    @wire(getPicklistValues,{recordTypeId: '$brokerRegInfo.data.defaultRecordTypeId',fieldApiName: BrokerRegSource})
    getPicklistValuesForField({ data, error }) {
        console.log(this.nationalityPicklistVal);
        console.log('inn3');
        if (error) {
            console.log('41 error');
            console.error(error);
            this.toast('Error', 'Some error occured'+error, 'error');
        } else if (data) {
            console.log('else if 44');
            this.nationalityPicklistVal = [...data.values]
        }
    }


    set record(data) {
        this._record = JSON.parse(JSON.stringify(data));
    }

    connectedCallback() {
        loadStyle(this, brokerAccountCSS);

        console.log('inn5');
        let subType = this.record.Broker_Sub_Type__c.includes('Broker') ? this.record.Broker_Sub_Type__c : this.record.Broker_Sub_Type__c +' '+ this.record.Broker_Category__c;
        this.showHeader = subType;


        this.files = JSON.parse(JSON.stringify(DOCS_MAP[subType]?.files));
        let tempObj = this.record;
        Object.keys(tempObj).forEach(function(key) {
            if (!defaultFieldApi.includes(key)) {
                delete tempObj[key];
            }
        });
        console.log('~~~~'+JSON.stringify(tempObj));
        this.record = tempObj;
    }

    handleSubmit(event) {
        if( !this.validate() ) {
            return;
        }
        this.showSpinner = true;
        if(this.docToDelete.length > 0){
            deleteDocuments({'DocIds':this.docToDelete}).then(res=>{
              
                const submitEvent = new CustomEvent('submit', {detail: {record: this.record}});
                this.dispatchEvent(submitEvent);
                this.showSpinner = false;
            }).catch(error =>{
                this.toast('Error', 'Some error occured'+error, 'error');
                   
            })
              const submitEvent = new CustomEvent('submit', {detail: {record: this.record}});
                this.dispatchEvent(submitEvent);
                this.showSpinner = false;
        }else{
            const submitEvent = new CustomEvent('submit', {detail: {record: this.record}});
                this.dispatchEvent(submitEvent);
                this.showSpinner = false;
        }
    }

    handleChange(event) {
        this.record[event.target.name] = event.target.value;
    }

    handleUploadFinished(event) {
        const index = event.target.dataset.index;
        const uploadedFiles = event.detail.files;
        const fileName = event.target.dataset.filen;
        var recId = this.record.Id;
        this.files[index].uploaded = true;
        let newFile = {name: fileName};
        
        getDocID({
            recordID:recId,
            title:fileName
        }).then(res =>{
            newFile.documentId  = res;
        });
        
        if( !this.files[index].uploadedFiles ) 
            this.files[index].uploadedFiles = [];
        this.files[index].uploadedFiles.push(newFile);
    }

    validate() {
        let allValid = [...this.template.querySelectorAll('lightning-input'), ...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        allValid &= this.validateFileUploads();
        return allValid;
    }

    validateFileUploads() {
        for(let file of this.files)
            if( file.required && !file.uploaded ) {
                this.toast('Error', 'Please upload all the required documents.', 'error');
                return false;
            }
        return true;
    }

    toast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            }),
        );
    }

    removeReceiptImage(event) {
        console.log(' event.currentTarget.dataset', event.currentTarget.dataset);
        var index = event.currentTarget.dataset.id;
        let fileIndex = event.currentTarget.dataset.fileIndex;
        console.log('this.files11', this.files[index].documentId);
       
        this.docToDelete.push( this.files[index].uploadedFiles[fileIndex].documentId);

        let tempUploadFiles = [...this.files[index].uploadedFiles];
        tempUploadFiles.splice(fileIndex, 1);

        if( !tempUploadFiles.length)
            this.files[index].uploaded = false;

        this.files[index].uploadedFiles = tempUploadFiles;
    }

    get isNationalityRequired() {
        return this.record.Broker_Category__c === 'Individual';
    }

    onKeyUpInputField(event){
        this.record[event.target.name] = event.target.value.toUpperCase();
    }
    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            this.showSpinner = true;
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                let index = event.target.dataset.index;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.Toast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    this.showSpinner = false;
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    console.log('==========>test-->' , inputType);
                    let fileContents = reader.result.split(',')[1];
                    this.createAttachment(inputType, file.name, fileContents, this.record.Id, index);
                };
                reader.readAsDataURL(file);
            }
        }
    } 
    createAttachment(title, fileName, fileContent , parentId, index){
        this.showSpinner = true;
        createAttachment({title : title, fileName: fileName, fileContent : fileContent, parentId :  parentId}).then((res) => {
            console.log('=====>'+res);
            this.files[index].uploaded = true;
            let newFile = {name: title};
            newFile.documentId  = res;
            if( !this.files[index].uploadedFiles ) 
                this.files[index].uploadedFiles = [];
            this.files[index].uploadedFiles.push(newFile);
            this.Toast('info  File Uploaded Successfully.','info');
            this.showSpinner = false;
        }).catch((err) => {
            this.showSpinner = false;
            this.Toast('Info  File Uploading Error '+err,'Error');
        });
    }   
}