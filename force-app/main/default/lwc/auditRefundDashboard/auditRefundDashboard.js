import { LightningElement } from 'lwc';
import transactionRequestRecord from '@salesforce/apex/AuditRefundDBController.transactionRequestRecord';
import submittedToAccount from '@salesforce/apex/AuditRefundDBController.submittedToAccount';
import fusejs from '@salesforce/resourceUrl/fusejs';
import { loadScript } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const columns = [
    { label: 'Transaction Request', fieldName: 'transactionRequestId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'trName' } }, hideDefaultActions: true, initialWidth: 100 },
    { label: 'Unit Number', fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true, initialWidth: 100 },
    { label: 'Booking Id', fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true, initialWidth: 100 },
    { label: 'Customer Name', fieldName: 'customerName', hideDefaultActions: true,wrapText: true, initialWidth: 100 },
    { label: 'Booking Date', fieldName: 'bookingDate', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Refund Initiated By', fieldName: 'refundInitiatedBy', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Refund Amount', fieldName: 'refundAmount', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Payment Mode', fieldName: 'paymentMode', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Type of Termination', fieldName: 'typeOfTermination', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Termination Refund Status', fieldName: 'terminationRefundStatus', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Total Agreement Amount', fieldName: 'totalAgreementAmount', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Total Amount Paid', fieldName: 'totalAmountPaid', hideDefaultActions: true, initialWidth: 100 },
    { label: 'Total LP Incurred', fieldName: 'totalLpIncurred', hideDefaultActions: true, initialWidth: 100 }
];

export default class AuditRefundDashboard extends LightningElement {
    columns = columns;
    backupResult = [];
    data = [];
    searchTerm;
    selectedProjectId;
    selectedTowerId;
    showSpinner = false;
    isTowerDisable = true;
    refundStatus = [null];
    reject = false;
    resubmit = false;
    rejectedToWhom;
    submitedToWhom;
    resubmittedTo = [];
    approveValue = [];
    subscription = {};
    CHANNEL_NAME = '/event/Termination_Dashboard_Sync_Ups__e'; // Platform Event Api Name
    
    recIds = [];

    connectedCallback() {
        loadScript(this, fusejs)
            .then(() => {
            }).catch(err => {
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
            subscribe(this.CHANNEL_NAME, -1, this.refreshApex).then(response => {
                this.subscription = response;
            });
            onError(error => {
                console.error('Server Error--->'+JSON.stringify(error));
            });
        
        this.handleInitialization();
    }

    handleResubmittedChange(event) {
        console.log(event.detail.value);
        if (event.detail.value.length > 1) {
            const index = event.detail.value.indexOf(this.resubmittedTo[0]);
            if (index > -1) {
                event.detail.value.splice(index, 1);
                this.resubmittedTo = event.detail.value;
            }
        } else {
            this.resubmittedTo = event.detail.value;
        }
        console.log('this.resubmittedTo****');
        console.log(this.resubmittedTo);
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, () => {});
    }

    refreshApex = () => {
        this.getTransactionRequestRecs()
    }

    handleProjectChange(event) {
        this.selectedProjectId = event.detail.projectId;
        this.isTowerDisable = false;
    }

    getTransactionRequestDetails(event) {
        this.selectedTowerId = event.detail.towerId;
        this.getTransactionRequestRecs();
    }

    getTransactionRequestRecs() {
        this.showSpinner = true;
        transactionRequestRecord({ projectId: this.selectedProjectId, towerId: this.selectedTowerId, refundStatus : this.refundStatus })
            .then(result => {
                this.data = result.map(item=>{
                    return {...item, 
                        "lineclamp":'datatable-columnheight slds-line-clamp'
                    }
                });
                this.backupResult = [...this.data];
                this.showSpinner = false;
            }).catch(err => {
                this.showSpinner = false;
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
    }

    handleRefundDashboard(event) {
        const actionName = event.detail.actionName.toLowerCase();
        this.recIds = event.detail.recIds;
        
        submittedToAccount({ trIdList: this.recIds ,refundStatus : actionName})
        .then(result => {
            this.getTransactionRequestRecs();
        }).catch(err => {
            this.showSpinner = false;
            this.showNotification('', reduceErrors(err).toString(), 'error');
        });
    }

    handleInitialization() {
        this.selectedProjectId ='';
        this.refundStatus = ['Resubmit to Audit Review'];
        this.rejectedToWhom = 'Collection';
        this.selectedTowerId='';
        this.columns = [...columns];
        this.submitedToWhom ='Audit';
        this.isTowerDisable = true;
        this.columns.push(
        {
        label: 'Resubmit to Account Executive', type: 'button', typeAttributes: {
                label: 'Resubmit to Account Executive',
                name: 'Resubmit to Account Executive',
                title: 'Resubmit to Account Executive',
                variant: 'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }, initialWidth: 250
        },
        { label: 'Resubmit to Respective department team member', type: 'button', typeAttributes: {
                label: 'Resubmit to Respective department team member',
                name: 'Resubmit to Respective department team member',
                title: 'Resubmit to Respective department team member',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }  , initialWidth: 350
        },
        { label: 'Audit Review Completed', type: 'button', typeAttributes: {
                label: 'Audit Review Completed',
                name: 'Audit Review Completed',
                title: 'Audit Review Completed',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }  , initialWidth: 250
        });
        this.data =[];
        this.backupResult = [];
    }

    get getVisibilityOfFilterSelection() {
        return true;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}