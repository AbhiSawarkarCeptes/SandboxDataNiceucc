import { LightningElement, wire, track } from 'lwc';
import getReceiptsWithStatus from '@salesforce/apex/ReceiptController.getReceipts';
import getDashboardFieldConfiguration from '@salesforce/apex/ReceiptController.getDashboardFieldConfiguration';
import updateReceiptStatusCtrl from '@salesforce/apex/ReceiptController.updateReceiptStatus';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReceiptDashboard extends LightningElement {
    @track columns = [];
    @track receipts = [];
    @track isSaveProgress = false;
    actions = [{ label: 'Approve' }, { label: 'Reject' }];

    //Pagination
    pageSizeOptions = [5, 10, 15, 20, 25, 50, 75, 100];
    totalRecords = 0; pageSize; totalPages; pageNumber = 1; recordsToDisplay = [];
    //BOD Pagination
    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.receipts[i]);
        }
    }
    //EOF Pagination

    @wire(getDashboardFieldConfiguration,{ screenType: "Audit" })
    wiredConfig({ error, data }) {
        if (data) {
            this.columns = this.extractColumns(data);
        } else if (error) {
            console.error('Error fetching field configuration:', error);
        }
    }

    extractColumns(fieldConfigs) {
        return fieldConfigs.map(config => ({
            label: config.Field_Label__c,
            fieldName: config.Field_API_Name__c,
            isUrl: config.Field_API_Name__c === 'Name' || config.Field_API_Name__c === 'Payment_Request__c',
            editable: config.Field_API_Name__c === 'Audit_Approver_s_Comments__c',
            isName: config.Field_API_Name__c === 'Name'
        }));
    }

    connectedCallback() {
        this.isSaveProgress = true;
        this.getReceipts();
        
    }
    getReceipts(){
        getReceiptsWithStatus({status:'Under Approval'})
        .then((result) => {
            let index=0;
            this.receipts = result.map(row => ({
...row,
NameUrl: '/' + row.Id,
PaymentRequestUrl: row.Payment_Request__c ? '/' + row.Payment_Request__c : null,
Index: index++
}));
            console.log('------this.receipts------'+JSON.stringify(this.receipts));
            this.isSaveProgress = false;
            
            //Pagination
            this.totalRecords = this.receipts.length;
            this.pageSize = this.pageSizeOptions[3];
            this.paginationHelper();
        })
        .catch((error) => {
            console.error('Error fetching receipts:', error);
        });
    }
    handleCommentChange(event) {
        const value = event.target.value;
        const idx = event.target.dataset.idx;
        console.log(idx+'-----------comment '+value);
        if(this.receipts.length > 0){
            this.receipts[idx].Audit_Approver_s_Comments__c = value;
        }
    }
    handleAction(event) {
        this.isSaveProgress = true;
        const actionSelected = event.target.label;
        const correspondingIndex = event.currentTarget.dataset.idx;
        const receiptId = this.receipts[correspondingIndex].Id;
        const comment = this.receipts[correspondingIndex].Audit_Approver_s_Comments__c;
        console.log('-----------Action '+actionSelected);
        console.log('-----------correspondingIndex '+correspondingIndex);
        console.log('-----------correspondingComment '+this.receipts[correspondingIndex].Audit_Approver_s_Comments__c);
        if(actionSelected == 'Reject') {
            if(!this.receipts[correspondingIndex].Audit_Approver_s_Comments__c || !this.receipts[correspondingIndex].Audit_Approver_s_Comments__c.trim()) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please provide comments before rejecting the receipt.',
                        variant: 'error'
                    })
                );
                this.isSaveProgress = false;
                return;
            }
            
        }
        //this.updateReceiptStatus(receiptId, actionSelected, comment);
        this.updateReceiptStatusImperative(receiptId, actionSelected, comment);
    }
    get hasReceiptsForApproval() {
        return this.receipts && this.receipts.length > 0;
    }

    updateReceiptStatusImperative(receiptId, action, comment){
        const status = action === 'Approve' ? 'Approved' : 'Rejected';
        console.log('{receiptId : receiptId, action : status,comment : comment} - '+'receiptId : '+receiptId+',action : '+status+',comment : '+comment)
        updateReceiptStatusCtrl({receiptId : receiptId, action : status,comment : comment}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Receipt ${status} successfully.`,
                    variant: 'success'
                })
            );
            this.refreshData();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Error updating receipt: ${error.body.message}`,
                    variant: 'error'
                })
            );
        });
    }

    updateReceiptStatus(receiptId, action, comment) {
        const status = action === 'Approve' ? 'Approved' : 'Rejected';
        const fields = { Id: receiptId, Audit_Approval_Status__c: status, Audit_Approver_s_Comments__c: comment };
        const recordInput = { fields };
        console.log('---recordInput---'+JSON.stringify(recordInput));
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `Receipt ${status} successfully.`,
                        variant: 'success'
                    })
                );
                this.refreshData();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `Error updating receipt: ${error.body.message}`,
                        variant: 'error'
                    })
                );
            });
    }
    refreshData() { 
        console.log('---refresh Apex---');
        this.getReceipts();
    }
}