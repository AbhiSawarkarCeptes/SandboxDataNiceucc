import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import brokerAccountCSS from '@salesforce/resourceUrl/brokerAccountCSS';
import { DOCS_MAP } from 'c/brokerAccountsConstants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteDocuments from '@salesforce/apex/BrokerAccountFormExternalController.deleteDocuments';
import createAttachment from '@salesforce/apex/BrokerAccountFormExternalController.createAttachment';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BrokerRegSource from '@salesforce/schema/Account.Nationality__c';
import BrokerRegSources from '@salesforce/schema/Account.Company_Registered_In__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BROKERREG_OBJECT from '@salesforce/schema/Account';
import getDocID from '@salesforce/apex/BrokerAccountFormExternalController.getDocID';
const MAX_FILE_SIZE = 5000000;
const defaultFieldApi = ['Id','Account_Owner_Email__c','Broker_Category__c','Broker_Sub_Type__c','Nationality__c','PropStrength__Broker_Code__c','Email_ID_2__c','Street_name__c', 'Designation1__c','Name_as_per_passport__c', 'Office_Apartment_number__c','Email_ID_1__c','BillingPostalCode', 'Mobile_No__c','Phone','BillingStreet','BillingCity', 'BillingState','BillingCountry','Villa_Building_name__c', 'Name_as_per_trade_license__c','Witness_Email__c','Witness_Name__c','Mobile__c','Status__c ','Name','Broker_Created_Date__c','Registration_Number__c','Registration_Link_Expiry_Date_Time__c', 'Renewal_Status__c'];

export default class BrokerAccountIntnlIndividual extends LightningElement {
    @track _record = {};
    @track files;
    @api today;
    showHeader = '';
    docToDelete = [];
    showSpinner = false;
    formType = 'Registration';
    companyRegPicklistVal=[];
    
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

    @wire(getPicklistValues,{recordTypeId: '$brokerRegInfo.data.defaultRecordTypeId',fieldApiName: BrokerRegSources})
    getPickValuesForFields({ data, error }) {
        if (error) {
            console.log('comapnypickval if');
            console.error(error);
            this.toast('Error', 'Error occured'+error, 'error');
        } else if (data) {
            console.log('comapnypickval else');
            this.companyRegPicklistVal = [...data.values];
        }
    }

    connectedCallback() {
        loadStyle(this, brokerAccountCSS);

        console.log('inn5');
        let subType = this.record.Broker_Sub_Type__c.includes('Broker') ? this.record.Broker_Sub_Type__c : this.record.Broker_Sub_Type__c +' '+ this.record.Broker_Category__c;
        this.showHeader = subType;


        this.files = JSON.parse(JSON.stringify(DOCS_MAP[subType]?.files));

        //console.log(JSON.stringify(this.files, null, 2));

        if(this.record.RecordType.Name!='Renewal'){
            let tempName = this.record.Name;
            let tempObj = this.record;
            Object.keys(tempObj).forEach(function(key) {
                if (!defaultFieldApi.includes(key)) {
                    delete tempObj[key];
                }
            });
            tempObj.Name_as_per_trade_license__c =tempName;
            console.log('~~~~'+JSON.stringify(tempObj));
            
            this.record = tempObj;
        } else {
            this.formType = 'Renewal';
        }

    }

    handleSubmit(event) {
        if( !this.validate() ) {
            return;
        }
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

 /*   handleUploadFinished(event) {
        console.log('inside handleuploadfinished');
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
*/
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
        console.log('this.files12', event.currentTarget.dataset.id);
        console.log('this.files13', event.currentTarget.dataset.fileIndex);
    

        if (this.files[index].uploadedFiles[fileIndex].documentId.includes(',')) {
            this.docToDelete.push(this.files[index].uploadedFiles[fileIndex].documentId.split(',')[0]);
            this.docToDelete.push(this.files[index].uploadedFiles[fileIndex].documentId.split(',')[1]);
        } else {
            this.docToDelete.push(this.files[index].uploadedFiles[fileIndex].documentId);
        }
        
        console.log('this.files14', this.docToDelete);

        let tempUploadFiles = [...this.files[index].uploadedFiles];
        tempUploadFiles.splice(fileIndex, 1);

        console.log('this.files15', this.tempUploadFiles);

        if( !tempUploadFiles.length)
            this.files[index].uploaded = false;

        this.files[index].uploadedFiles = tempUploadFiles;

        console.log('this.files16', this.files[index].uploadedFiles);
        // console.log('this.files', this.files);
    
        // var tempFiles = this.files;
        // this.files = [];
        // this.files = [...tempFiles];
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