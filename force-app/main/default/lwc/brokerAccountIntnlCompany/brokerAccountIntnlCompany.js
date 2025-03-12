import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import brokerAccountCSS from '@salesforce/resourceUrl/brokerAccountCSS';
import { DOCS_MAP } from 'c/brokerAccountsConstants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteDocuments from '@salesforce/apex/BrokerAccountFormExternalController.deleteDocuments';
import createAttachment from '@salesforce/apex/BrokerAccountFormExternalController.createAttachment';

//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import PICKLIST_FIELD_FIELD from '@salesforce/schema/Account.Nationality__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BrokerRegSource from '@salesforce/schema/Account.Nationality__c';
import BrokerRegSources from '@salesforce/schema/Account.Company_Registered_In__c';
import BrokerRegSources1 from '@salesforce/schema/Account.VAT_Registration_Status__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import BROKERREG_OBJECT from '@salesforce/schema/Account';

import getDocID from '@salesforce/apex/BrokerAccountFormExternalController.getDocID';
const MAX_FILE_SIZE = 5000000;
const defaultFieldApi = ['Id','Account_Owner_Email__c','Broker_Category__c','Broker_Sub_Type__c','Nationality__c','PropStrength__Broker_Code__c','Email_ID_2__c','Street_name__c', 'Designation1__c','Name_as_per_passport__c', 'Office_Apartment_number__c','Email_ID_1__c','BillingPostalCode', 'Mobile_No__c','Phone','BillingStreet','BillingCity', 'BillingState','BillingCountry','Villa_Building_name__c', 'Name_as_per_trade_license__c','Witness_Email__c','Witness_Name__c','Mobile__c','Status__c ','Name','Broker_Created_Date__c','Registration_Number__c','Registration_Link_Expiry_Date_Time__c', 'Renewal_Status__c','Broker_Category_Type_Doc__c','PropStrength__Broker_Type__c'];
export default class BrokerAccountIntnlCompany extends LightningElement {
    @track _record = {};
    @track files;
    @api today;
    @api options = {};
    docToDelete = [];
    showHeader = '';
    showSpinner = false; nationalityPicklistVal =[]; companyRegPicklistVal=[]; vatRegistrationPickVal = [];
    makeReraNumberReadonly = false; formType = 'Registration';

    makeReadonly = true;
   
    @api
    get record() {
        return this._record;
    }

    get acceptedFormats() {
       return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    @wire(getObjectInfo, { objectApiName: BROKERREG_OBJECT })
    brokerRegInfo;
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
    @wire(getPicklistValues,{recordTypeId: '$brokerRegInfo.data.defaultRecordTypeId',fieldApiName: BrokerRegSource})
    getPicklistValuesForField({ data, error }) {
        if (error) {
            console.log('nationality if');
            console.error('error',error);
            this.toast('Error', 'Some error occured'+error, 'error');
        } else if (data) {
            console.log('get picklist');
            this.nationalityPicklistVal = [...data.values];
            console.log('get picklist', this.nationalityPicklistVal);
        }
    }
    @wire(getPicklistValues,{recordTypeId: '$brokerRegInfo.data.defaultRecordTypeId',fieldApiName: BrokerRegSources1})
    getPickValuesForFields1({ data, error }) {
        if (error) {
            console.log('vat registration  if');
            console.error(error);
            this.toast('Error', 'Error occured'+error, 'error');
        } else if (data) {
            console.log('vat registration  else');
            this.vatRegistrationPickVal = [...data.values];
        }
    }

  

    /*@wire(getPicklistValues, { recordTypeId: '012000000000000AAA',fieldApiName: PICKLIST_FIELD_FIELD })
    getPicklistValuesForField({ data, error }) {
        if (error) {
            console.error(error);
            this.toast('Error', 'Some error occured'+error, 'error');
        } else if (data) {
            this.nationalityPicklistVal = [...data.values]
        }
    }*/


    set record(data) {
        this._record = JSON.parse(JSON.stringify(data));
    }

    connectedCallback() {
        console.log('hello');
        console.log('Intn Company - record -'+ this.record.Broker_Category__c);
        loadStyle(this, brokerAccountCSS);
        console.log('test Gourav');
        console.log(this.record.Broker_Sub_Type__c.includes('Broker'));

        let subType = this.record.Broker_Sub_Type__c.includes('Broker') ? this.record.Broker_Sub_Type__c : this.record.Broker_Sub_Type__c +' '+ this.record.Broker_Category__c;
        this.showHeader = subType;

        console.log('~~~~~~~Files'+ subType);
        this.files = JSON.parse(JSON.stringify(DOCS_MAP[subType]?.files));
        console.log('~~~~~~~Files'+ this.files);
        console.log(JSON.stringify(this.files, null, 2));

        console.log('~~~~~~~~Res: '+JSON.stringify(this.record));
        console.log('!!! '+this.record.RecordType.Name);
        if(this.record.RecordType.Name!='Renewal'){
            
            let tempObj = this.record;
            Object.keys(tempObj).forEach(function(key) {
                if (!defaultFieldApi.includes(key)) {
                    delete tempObj[key];
                }
            });
            console.log('~~~~~~~~Aft: '+JSON.stringify(tempObj));
            this.record = tempObj;
        } else {
            this.formType = 'Renewal';
        }
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

 /*   handleUploadFinished(event) {
        let fileNameParts = event.detail.files[0].name.split('.');
        let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();
        console.log('~~~~'+extension);

        const index = event.target.dataset.index;
        const uploadedFiles = event.detail.files;
        var recId = this.record.Id;
        this.files[index].uploaded = true;
        let newFile = {name: uploadedFiles[0].name};
        
        getDocID({recordID:recId}).then(res =>{
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
       
        this.docToDelete.push( this.files[index].uploadedFiles[fileIndex].documentId);

        let tempUploadFiles = [...this.files[index].uploadedFiles];
        tempUploadFiles.splice(fileIndex, 1);

        if( !tempUploadFiles.length)
            this.files[index].uploaded = false;

        this.files[index].uploadedFiles = tempUploadFiles;
        // console.log('this.files', this.files);
       
        // var tempFiles = this.files;
        // this.files = [];
        // this.files = [...tempFiles];
    }

    reraInprogressChange(event){
        console.log('~~~~'+event.currentTarget.dataset.id+'___'+event.target.checked+'__'+event.target.value);
        this.makeReraNumberReadonly = event.target.checked;
        this.record[event.currentTarget.dataset.id] = '';
        if(event.target.checked){
            this.record[event.currentTarget.dataset.id] = 'Under Process';
        }
    }
    
    get isBrokerRera() {
        return this.record.Broker_Sub_Type__c === 'Broker RERA';
    }

    get isNotInternational() {
        let brType = this.record.PropStrength__Broker_Type__c;
        let brCategory = this.record.Broker_Category__c;
        let brSubType = this.record.Broker_Sub_Type__c;
        console.log('===> brType ' + brType);
        console.log('===> brCategory ' + brCategory);
        console.log('===> brSubType ' + brSubType);
        /*if(categorydoc != null && categorydoc.includes('International')){
            return false;
        }*/
        if(brType != undefined && brType != null && brType != '' && brType == 'Standard') {
            if(brCategory != undefined && brCategory != null && brCategory != '' && brCategory == 'Individual' && brSubType != undefined && brSubType != null && (brSubType == 'Broker International' || brSubType == 'Broker RERA' || brSubType == 'Broker UAE')) {
                return false;
            } else if(brCategory != undefined && brCategory != null && brCategory != '' && brCategory == 'Company' && brSubType != undefined && brSubType != null && brSubType == 'Broker International') {
                return false;
            }
        } else if(brType != undefined && brType != null && brType != '' && brType == 'Sobha Connect') {
            if(brCategory != undefined && brCategory != null && brCategory != '' && brCategory == 'Individual' && brSubType != undefined && brSubType != null && (brSubType == 'Sobha Connect International' || brSubType == 'Sobha Connect UAE')) {
                return false;
            } else if(brCategory != undefined && brCategory != null && brCategory != '' && brCategory == 'Company' && brSubType != undefined && brSubType != null && brSubType != '' && brSubType == 'Sobha Connect International') {
                return false;
            }
        }
        return true;
    }

    get isBuildingRequired(){
        return this.record.Broker_Sub_Type__c === 'Broker RERA' || this.record.Broker_Sub_Type__c === 'Broker UAE' || this.record.Broker_Sub_Type__c === 'Broker International' || (this.record.Broker_Sub_Type__c === 'Sobha Connect International' && this.record.Broker_Category__c === 'Company') || (this.record.Broker_Sub_Type__c === 'Sobha Connect UAE' && this.record.Broker_Category__c === 'Company');
    }

    get isNoBrokerReraUAE(){
        return this.record.Broker_Sub_Type__c != 'Broker RERA' && this.record.Broker_Sub_Type__c != 'Broker UAE';
    }

    get isCompanyRegVisible(){
        return this.record.Broker_Sub_Type__c === 'Broker UAE' || (this.record.Broker_Sub_Type__c === 'Sobha Connect UAE' && this.record.Broker_Category__c === 'Company');
    }

    onKeyUpInputField(event){
        this.record[event.target.name] = event.target.value.toUpperCase();
    }

    enableEdit(){
        this.makeReadonly = false;
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