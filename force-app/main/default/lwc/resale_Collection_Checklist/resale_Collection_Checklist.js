import { LightningElement,api,track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIntrimPaymentCount from '@salesforce/apex/ResaleProcessAppBookingLWCController.getIntrimPaymentCounts';
import createAttachment from '@salesforce/apex/ResaleProcessAppBookingLWCController.createAttachment';  
import updateTransaction from '@salesforce/apex/ResaleProcessAppBookingLWCController.updateTransactionRec';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import transaction__OBJECT from '@salesforce/schema/PropStrength__Transaction_Requests__c';
import Outstand_Amt_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.Outstand_Amt_40_purchase_price_IOM__c';
import PDC_Current_buyer_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.PDC_s_of_the_current_buyer__c';
import buyer_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.New_Buyer_PDC_required__c';
import buyer_LOU_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.New_Buyer__c';
import POP_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.POP_confirmation_Approval__c';
import Bank_Name_FIELD from '@salesforce/schema/PropStrength__Transaction_Requests__c.PropStrength__Bank_NamePick__c';

const MAX_FILE_SIZE = 5000000;
export default class Resale_Collection_Checklist extends NavigationMixin(LightningElement)  {
    @track transactionInformation = {
       Id : '',
       X40_purchase_price_cur_due_instal_paid__c : null,
        Outstand_Amt_40_purchase_price_IOM__c : '',
        PDC_s_of_the_current_buyer__c : '',
        New_Buyer__c :'',
        New_Buyer_PDC_required__c : '',
        POP_confirmation_Approval__c : '',
        PDC_to_be_collected_from_buyer__c : null,
        Amount_of_PDC__c : '',
        PropStrength__Bank_NamePick__c : '',
        Cheque_Amount__c : '',
        PropStrength__Cheque_Date__c : ''
    }
    @track filesData = []; 
    @api recordId;
    @track recordTypeId;
    @track OutstandAmtpriceOption;
    @track PDC_Current_buyerOption;
    @track New_buyerLOUOption;
    @track New_buyerOption;
    @track BankNameOption;
    @track POPConfirmOption;
    @track sellerInformation;
    @track BCCComplete;
    @track handoverStatus;
    @track paymentDue;
    @track paymentRec;
    @track chequecopy;
    @track pdc;
    @track totalpaidPer;
    @track checklistFlag = false;
    @track showSpinner= false;

    @wire(getObjectInfo, { objectApiName: transaction__OBJECT })
    wiredObjectInfo({error, data}) {
        if (error) {
          // handle Error
        } else if (data) {
          const rtis = data.recordTypeInfos;
          this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Transfer Of Property');
        }
    };

    @wire(getIntrimPaymentCount, {transactionid:'$recordId'})
    wiredApplicantList({error,data}) {
        if (data) {
            console.log(data);
            this.bookingrecord = data;
            for(var key in this.bookingrecord)
            {
                console.log('*----',key);
                if(key=='BccComplete')
                {
                    this.BCCComplete = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='PDCCount')
                {
                    this.sellerInformation = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='handoverStatus')
                {
                    this.handoverStatus = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='totalPaymentDue')
                {
                    this.paymentDue = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='totalPaymentReceive')
                {
                    this.paymentRec = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='totalPaidPer')
                {
                    this.totalpaidPer = this.bookingrecord[key];
                    this.checklistFlag = true;
                }
                if(key=='checkListCompleted' && this.bookingrecord[key] != null)
                {
                    this.checklistFlag = false;
                    this.showToast('Error','CheckList alredy generated','Error'); 
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
                
            }
           //this.sellerInformation = data;
        }
        if(error){
            console.log('wiredApplicantList -> ',JSON.parse(JSON.stringify(error)));
            this.showToast('Success',error,'Error');
        }
    }

    

    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: PDC_Current_buyer_FIELD
    })wiredPDCBuyerOptions1({error,data}){
        if(data) {
            this.PDC_Current_buyerOption = data.values;
        } 
    };

    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: buyer_LOU_FIELD
    })wiredPDCBuyerOptions2({error,data}){
        if(data) {
            this.New_buyerLOUOption = data.values;
        } 
    };

    @wire(getPicklistValues,{
      recordTypeId: "$recordTypeId", 
      fieldApiName: POP_FIELD
  })wiredPDCBuyerOptions({error,data}){
      if(data) {
          this.POPConfirmOption = data.values;
      } 
  };

    @wire(getPicklistValues,{
      recordTypeId: "$recordTypeId",  
      fieldApiName: Bank_Name_FIELD
    })wiredBankNameOptions({error,data}){
        if(data) {
            this.BankNameOption = data.values;
        } 
    };


    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId",  
        fieldApiName: buyer_FIELD
    })wiredNewBuyerOptions({error,data}){
        if(data) {
            this.New_buyerOption = data.values;
        } 
    };

    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: Outstand_Amt_FIELD
    })wiredOutAmtOptions({error,data}){
        console.log('data128*---',data);
        if(data) {
            this.OutstandAmtpriceOption = data.values;
        } 
    };

    handlePicklistFieldChange1(event) {    
        this.transactionInformation[event.currentTarget.dataset.fieldname] = event.detail.value;        
    }

    handleFieldChange1(event){
        if(event.currentTarget.dataset.fieldname=='X40_purchase_price_cur_due_instal_paid__c' || event.currentTarget.dataset.fieldname=='PDC_to_be_collected_from_buyer__c'){
            console.log(event.target.checked);
            console.log('test');
            this.transactionInformation[event.target.dataset.fieldname] = event.target.checked;
        }
        else 
            this.transactionInformation[event.target.dataset.fieldname] = event.target.value;
    }

    async submitForm(event){
      this.showSpinner = true;
      console.log(this.recordId);
      console.log(JSON.stringify(this.transactionInformation));
      let createResalePromise = updateTransaction({transactionRec : JSON.stringify(this.transactionInformation), transactionId : this.recordId }).then((res) => {
            return new Promise(resolve => {
            console.log(res);
                if(res.includes('Success')){
                console.log('test');
                    resolve(res);
                    // this.showToast('Success ','Success','Success');
                    // this.showSpinner = false;
                    // this.navigateToRecordPage(this.recordId);
                }else{
                    resolve(null);
                    console.log('119--',res);
                    this.showSpinner = false;
                    this.showToast('Error',res,'Error'); 
                }
            })
        }).catch((error) => {
            return new Promise(resolve => {
                this.showSpinner = false;
                console.log('126--',error);
                resolve(null);
                this.showToast('Error',error,'Error');
            })
        })
        createResalePromise.then((resu) => { 
            console.log('rsu',resu); 
            if(resu!= null && resu.includes('Success')){
                this.showSpinner = true;
                var temp = resu.split(',');

                const asynccreateAttachment = this.filesData.map(item => this.createAttachment(item,temp[1]));
                Promise.all(asynccreateAttachment).then(results => {
                    console.log('All attachments created successfully:', results);
                    this.showToast('Success','Record has been created','Success');
                    this.showSpinner = false;
                    setTimeout(() => {
                        this.navigateToRecordPage(temp[1]);
                    }, 300);
                }).catch(error => {
                    this.showSpinner = false;
                    this.showToast('Success','Resale Data has been save please upload document if it not uploaded','success');
                    this.navigateToRecordPage(temp[1]);
                    console.error('An error occurred:', error);
                });
            }else{
                this.showSpinner = false;
            }
        })
    }
    async createAttachment(item,parentId){
        return new Promise(resolve => {
            createAttachment({filedata : JSON.stringify(item),parentId}).then((res) => {
                if(res == 'Success'){
                    this.showToast('info ',item.fileName+ ' File Uploaded Successfully please wait dont leave the screen ','info');
                    resolve('Success');
                }else{
                    this.showToast('Info ',item.fileName+ ' File Uploading Error But Record is Save You can Upload File Later in Record  wait dont leave the screen','Error');
                    resolve('Success');
                }
            }).catch((err) => {
                this.showToast('Info ',item.fileName+ ' File Uploading Error But Record is Save You can Upload File Later in Record wait dont leave the screen '+err,'Error');
                resolve('Success');
            });
        });        
    }
    chequecopyUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'ChequeCopy_'+file.name, 'fileContent':fileContents});
                };
                if(inputType == 'chequecopy'){
                    this.chequecopy = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }
    pdcUploaded(event){
        
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                let inputType = event.target.name;
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!','File size exceeded the upload size limit.', 'error');
                    event.currentTarget.reportValidity();
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':'PDC_'+file.name, 'fileContent':fileContents});
                };
                if(inputType == 'pdc'){
                    this.pdc = file.name;
                }
                reader.readAsDataURL(file);
            }
        }
    }
    showToast(title,msg,type){
      const toastEvent = new ShowToastEvent({
          title: title,
          message: msg,
          variant: type,
          mode: 'dismissable'
      });
      this.dispatchEvent(toastEvent); 
    }


    navigateToRecordPage(recordPageId) {
      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: recordPageId,
              objectApiName: 'PropStrength__Transaction_Requests__c',
              actionName: 'view'
          }
      });
  }

}