import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getMetadataConfig from '@salesforce/apex/BrokerRegFieldUpdateReqController.getCustomeMetadatConfigAcc';
import getAccountId from '@salesforce/apex/BrokerRegFieldUpdateReqController.getAccountId';
import insertRequestData from '@salesforce/apex/BrokerRegFieldUpdateReqController.insertRequestData';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import myStaticStyles from '@salesforce/resourceUrl/myStaticStyles'

export default class BrokerRegFieldUpdateRequestClone extends LightningElement {
    @api recordId; showSpinner = false; accId;
    objectApiName ='Account'; dummyRecord;
    record={}; dataList=[]; insertList=[]; isFieldTypeVisible = true; fieldUpdateType;

    connectedCallback() {
        loadStyle(this, myStaticStyles); 
    }

    goBacktoFieldUpdate() {
        this.isFieldTypeVisible = true;
    }

    closePopup(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleFieldChange(event){
        this.record[event.target.name] = event.target.value;
    }

    onFieldTypeChange(event){
        if (event.target.value != null) {
            getAccountId({recId: this.recordId}).then(data => {
            this.accId = data;
            }).catch(error => {
                this.showToast('Error', error.body.message, 'error');
            })
            
            this.showSpinner = true;
            this.fieldUpdateType = event.target.value;
            this.getFieldsFromMetadata();
            this.isFieldTypeVisible = false;
        }
    }

    getFieldsFromMetadata(){
        getMetadataConfig({fieldUpdateType: this.fieldUpdateType}).then(data => {
            console.log(JSON.stringify(data));
            this.dataList = data;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.showToast('Error', error.body.message, 'error');
        }).finally(() => this.showSpinner = false);
    }

    onSubmit(){
        if(this.fieldUpdateType!=null){
            if(this.checkObjEmpty()){
                this.generateRequestData();
            } else {
                this.showToast('Error', 'Please fill any new field values', 'error');
            }
        } else {
            this.showToast('Error', 'Please choose the Field Update Type', 'error');
        }
    }

    checkObjEmpty() {
        let value = this.record;
        if(Object.keys(value).length>0){
            let datal = null;
            for (let prop in value) {
                if(value[prop]!='' && value[prop]!=null) { datal=value[prop]; }
            }
            if (datal != null) { return true; } else { return false; }
        } else {
            return false;
        }
    }

    generateRequestData(){
        const inputFields = this.template.querySelectorAll('.oldRecordForm lightning-input-field');
        
        if (inputFields) {
            this.insertList=[];
            inputFields.forEach(field => {
                if(this.record[field.name]!='' && this.record[field.name]!=null){
                    let obj={};
                    obj.API_Name__c = field.name;
                    obj.Old_Value__c = field.value;
                    obj.New_Value__c = this.record[field.name];
                    obj.Label__c = field.dataset.id;
                    obj.Broker_Registration__c = this.recordId;
                    obj.Field_Update_Type__c = this.fieldUpdateType;
                    this.insertList.push(obj);
                }
            });
            if(this.insertList.length>0){
                this.saveRequestData();
            } else {
                this.showToast('Error', 'Error occured during generating the Request Data', 'error');
            }
            console.log('~~~List: '+JSON.stringify(this.insertList));
        }
        
    }

    saveRequestData(){
        this.showSpinner = true;
        try{
        insertRequestData({insertList: this.insertList}).then(data => {
            console.log('~~Result: '+JSON.stringify(data));
            this.showToast('Success', 'Request has been raised Successfully', 'success');
            this.closePopup();
            this.refreshCurrentPage();
        }).catch(error => {
            this.showToast('Error', error.body.message, 'error');
        }).finally(() => this.showSpinner = false);
        } catch(err) {
            console.log('~~Error: '+err);
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'dismissable'
            }),
        );
    }

    refreshCurrentPage(){
        setTimeout(function(){
        window.location.reload();
        }, 1000);
    }
}