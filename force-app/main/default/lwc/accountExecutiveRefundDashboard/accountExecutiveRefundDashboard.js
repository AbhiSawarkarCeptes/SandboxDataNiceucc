import { LightningElement } from 'lwc';
import transactionRequestRecord from '@salesforce/apex/AccountExecutiveRefundDBController.transactionRequestRecord';
import submittedToAccount from '@salesforce/apex/AccountExecutiveRefundDBController.submittedToAccount';
import sendMailToFirst from '@salesforce/apex/AccountExecutiveRefundDBController.sendMailToFirst';
import sendMailToSecond from '@salesforce/apex/AccountExecutiveRefundDBController.sendMailToSecond';
import checkFirstReleaseApproval from '@salesforce/apex/AccountExecutiveRefundDBController.checkFirstReleaseApproval';
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

export default class AccountExecutiveRefundDashboard extends LightningElement {
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
    openModal = false;
    openFirstModal = false;
    firstEmail;
    secondEmail;
    
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

        if (actionName != 'release approval') {
            submittedToAccount({ trIdList: this.recIds, refundStatus: actionName })
                .then(result => {
                    this.getTransactionRequestRecs();
                }).catch(err => {
                    this.showSpinner = false;
                    this.showNotification('', reduceErrors(err).toString(), 'error');
                });
        } else if (actionName == 'release approval') {
            checkFirstReleaseApproval({ trId: this.recIds[0]})
                .then(result => {
                    this.openModal = true;
                    this.openFirstModal = !result;
                }).catch(err => {
                    this.showSpinner = false;
                    this.showNotification('', reduceErrors(err).toString(), 'error');
                });
        }
    }

    hideModalBox() {
        this.openModal = false;
        this.openFirstModal = false;
    }

    handleFirstEmailSend() {
        sendMailToFirst({ trId: this.recIds[0], emailAdd: this.firstEmail })
            .then(result => {
                this.openFirstModal = false;
            }).catch(err => {
                this.showSpinner = false;
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
    }

    handleSecondEmailSend() {
        sendMailToSecond({ trId: this.recIds[0], emailAdd: this.secondEmail })
            .then(result => {
                this.openModal = false;
                this.getTransactionRequestRecs();
            }).catch(err => {
                this.showSpinner = false;
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
    }

    handleFirstEmail(event) {
        this.firstEmail = event.detail.value;
    }

    handleSecondEmail(event) {
        this.secondEmail = event.detail.value;
    }

    handleInitialization() {
        this.selectedProjectId ='';
        this.refundStatus = ['Resubmit to Account Executive', 'Resubmitted by Treasury', 'Approved by Treasury'];
        this.rejectedToWhom = 'Collection';
        this.selectedTowerId='';
        this.columns = [...columns];
        this.submitedToWhom ='Audit';
        this.isTowerDisable = true;
        this.columns.push(
        {
        label: 'Resubmit to Audit review', type: 'button', typeAttributes: {
                label: 'Resubmit to Audit review',
                name: 'Resubmit to Audit review',
                title: 'Resubmit to Audit review',
                variant: 'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }, initialWidth: 250
        },
        { label: 'Resubmit to Account Manager review', type: 'button', typeAttributes: {
                label: 'Resubmit to Account Manager review',
                name: 'Resubmit to Account Manager review',
                title: 'Resubmit to Account Manager review',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }  , initialWidth: 300
        },
        {
            label: 'Resubmit to Respective department team member', type: 'button', typeAttributes: {
                label: 'Resubmit to Respective department team member',
                name: 'Resubmit to Respective department team member',
                title: 'Resubmit to Respective department team member',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }, initialWidth: 380
        },
        {
            label: 'Resubmit to Treasury review', type: 'button', typeAttributes: {
                label: 'Resubmit to Treasury review',
                name: 'Resubmit to Treasury review',
                title: 'Resubmit to Treasury review',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true,
                disabled: { fieldName: 'isTreasuryDisabled' } 
            }, initialWidth: 250
        },
        {
            label: 'Release Approval', type: 'button', typeAttributes: {
                label: 'Release Approval',
                name: 'Release Approval',
                title: 'Release Approval',
                variant:'brand',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true,
                disabled: { fieldName: 'isApprovalDisabled' } 
            }, initialWidth: 200
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