import { LightningElement } from 'lwc';
import bookingListWithOverDue from '@salesforce/apex/TerminationDashboardController.bookingListWithOverDue';
import submittedToAccount from '@salesforce/apex/TerminationDashboardController.submittedToAccount';
import fusejs from '@salesforce/resourceUrl/fusejs';
import { loadScript } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';


const columns = [
    { label: 'Unit Number', fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Booking Id', fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    { label: 'Unit Number', fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Customer Name', fieldName: 'customerName', hideDefaultActions: true,wrapText: true /*, cellAttributes:{
    class:{fieldName:'lineclamp'} } */},
    { label: 'Booking Date', fieldName: 'bookingDate', hideDefaultActions: true },
    { label: 'Pre Registration Status', fieldName: 'registrationStatus', hideDefaultActions: true },
    { label: 'Sale Value', fieldName: 'saleValue', hideDefaultActions: true },
    { label: 'Demand Raised', fieldName: 'demands', hideDefaultActions: true },
    { label: 'Milestone Due', fieldName: 'milestoneDue', hideDefaultActions: true },
    { label: 'Collected Amount', fieldName: 'collected', hideDefaultActions: true },
    { label: 'Overdue Amount', fieldName: 'due', hideDefaultActions: true },
    { label: 'Balance', fieldName: 'fullDue', hideDefaultActions: true },
    { label: 'Date Submitted', fieldName: 'submittedToAccountDate', hideDefaultActions: true },
    { label: 'Age', fieldName: 'age', hideDefaultActions: true },
    { label: 'SOA', fieldName: 'soaLink', type: 'url', target: '_blank', typeAttributes: { label: 'click here' }, hideDefaultActions: true }
];



export default class TerminationDashboardForAccounts extends LightningElement {
    columns = columns;
    backupResult = [];
    data = [];
    searchTerm;
    selectedProjectId;
    terminationStatusForBooking;
    terminationStatusForRejection;
    selectedTowerId;
    showSpinner = false;
    submittedToAccount = false;
    resubmittedByCollectionTeam = false;
    resubmittedByAuditTeam = false;
    isTowerDisable = true;
    terminationStatus = [null];
    openModal = false;
    reject = false;
    resubmit = false;
    isRejectedVisible = false;
    isResubmitVisible = false;
    isApproveVisible = false;
    rejectedToWhom;
    submitedToWhom;
    subscription = {};
    CHANNEL_NAME = '/event/Termination_Dashboard_Sync_Ups__e'; // Platform Event Api Name
    
    recIds =[];

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
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, () => {
        // console.log('Unsubscribed Channel');
        });
    }

    refreshApex = () => {
        this.getOverDueBookings()
    }

    handleProjectChange(event) {
        this.selectedProjectId = event.detail.projectId;
        this.isTowerDisable = false;
    }

    getBookingDetails(event) {
        this.selectedTowerId = event.detail.towerId;
        this.getOverDueBookings();
    }
    getOverDueBookings() {
        this.showSpinner = true;
        bookingListWithOverDue({ projectId: this.selectedProjectId, towerId: this.selectedTowerId, terminationStatus : this.terminationStatus })
            .then(result => {
                this.data = result.map(item=>{
                    return {...item, 
                        "lineclamp":'datatable-columnheight slds-line-clamp'
                    }
                });
              //  this.data = result;
                this.backupResult = [...this.data];
                this.showSpinner = false;
            }).catch(err => {
                this.showSpinner = false;
                this.showNotification('', reduceErrors(err).toString(), 'error');
            });
    }

    handleRequestForCancellation(event) {
        this.recIds = event.detail.recIds;
        this.openModal = true;
        const actionName = event.detail.actionName.toLowerCase();
        this.reject =  actionName.includes('reject') ? true  : false;
        this.resubmit = actionName.includes('resubmit') ? true : false;
    }

    handleSubmit() {
        let isValid = true;
        const allValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            this.showSpinner = true;
            let terminationStatus =   this.reject ? this.terminationStatusForRejection : this.resubmit ?  this.termiantionStatusForResubmission : this.terminationStatusForBooking;
            let submitedToWhom = this.reject  || this.resubmit ? this.rejectedToWhom : this.submitedToWhom;
            submittedToAccount({ bookingIdList: this.recIds ,terminationStatus : terminationStatus,reasonValue : this.reasonValue,submitedToWhom : submitedToWhom,submittedBy : 'Account'})
                .then(result => {
                    this.openModal = false;
                    this.getOverDueBookings();
                }).catch(err => {
                    this.showSpinner = false;
                    this.showNotification('', reduceErrors(err).toString(), 'error');
                });
        } 
    }
       
    handleSearch(event) {
        this.searchTerm = event.detail.searchTerm;
        if (this.searchTerm.length > 2) {
            this.searchResult(this.searchTerm);
        } else {
            this.data = [... this.backupResult];
        }
    }

    searchResult(searchTerm) {
        const searchConfig = {
            findAllMatches: true,
            minMatchCharLength: searchTerm.length,
            includeScore: true,
            keys: [
                { name: 'bookingName', weight: 1 },
                { name: 'customerName', weight: 1 },
                { name: 'unitName', weight: 1 }
            ]
        };
        const fuseResult = new Fuse(this.backupResult, searchConfig);
        const localResults = fuseResult.search("scheme "+searchTerm);
        let displayRecords = [];
        if (localResults && localResults.length > 0) {
            localResults.forEach(function (obj) {
                displayRecords.push(obj.item);
            });
        }
        this.data = displayRecords;
    }
    get submittedToAccountTeamButtonVariant() {
        return this.submittedToAccount ? 'brand' : 'neutral';
    }
    get resubmittedByCollectionTeamVariant() {
        return this.resubmittedByCollectionTeam ? 'brand' : 'neutral';
    }
    get resubmittedByAuditTeamVariant() {
        return this.resubmittedByAuditTeam ? 'brand' : 'neutral';
    }
    handleResubmittedByCollectionTeamClick() {
        this.submittedToAccount = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByCollectionTeam = true;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.terminationStatusForBooking = 'Resubmitted to audit by accounts';
        let terminationStatus =['Resubmitted to accounts by collections'];
        this.terminationStatus = terminationStatus;
        this.isRejectedVisible = true;
        this.terminationStatusForRejection ='Rejected by accounts';
        this.termiantionStatusForResubmission = 'Resubmitted to collections by accounts';
        this.submitedToWhom ='Audit';
        this.rejectedToWhom = 'Collection';
        this.isApproveVisible = true;
        this.isResubmitVisible = true;
        this.isTowerDisable = true;
        this.columns = [...columns];
        this.columns.push (
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true },
            {
                type: 'button', typeAttributes: {
                    label: 'Approve',
                    name: 'Request For Cancellation',
                    title: 'Request For Cancellation',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { type: 'button', typeAttributes: {
                label: 'Reject',
                name: 'Reject',
                title: 'Reject',
                variant:'destructive',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }},
            { label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true/*,cellAttributes:{
            class:{fieldName:'lineclamp'}}*/},
            { type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    variant:"success",
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
            }}
        );
        this.data =[];
        this.backupResult = [];
    }

    hideModalBox() {
        this.openModal = false;
    }

    handleResubmittedByAuditTeamClick() {
        this.submittedToAccount = false;
        this.resubmittedByAuditTeam = true;
        this.resubmittedByCollectionTeam = false;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.terminationStatus =['Resubmitted by audit to accounts'];
        this.terminationStatusForBooking = 'Resubmitted to audit by accounts';
        this.termiantionStatusForResubmission = 'Resubmitted to audit by accounts';
        this.terminationStatusForRejection ='Rejected by accounts';
        this.rejectedToWhom = 'Audit';
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.submitedToWhom ='Audit';
        this.isTowerDisable = true;
        this.columns.push (
            { label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true/*,cellAttributes:{
            class:{fieldName:'lineclamp'}}*/},
        {
            type: 'button', typeAttributes: {
                label: 'Resubmit',
                name: 'Resubmit',
                title: 'Resubmit',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }
        },{ type: 'button', typeAttributes: {
            label: 'Reject',
            name: 'Reject',
            title: 'Reject',
            variant:'destructive',
            value: '',
            iconPosition: 'left',
            hideDefaultActions: true
        }},
        { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true}
        );
        this.data =[];
        this.backupResult = [];
    }

    handlesubmittedToAccountTeamClick() {
        this.submittedToAccount = true;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByCollectionTeam = false;   
        this.selectedProjectId ='';
        this.terminationStatus = ['Submitted to Accounts'];
        this.terminationStatusForBooking = 'Submitted to audit';
        this.terminationStatusForRejection ='Rejected by accounts';
        this.termiantionStatusForResubmission ='Resubmitted to collections by accounts';
        this.rejectedToWhom = 'Collection';
        this.selectedTowerId='';
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = true;
        this.submitedToWhom ='Audit';
        this.isTowerDisable = true;
        this.columns.push({
            type: 'button', typeAttributes: {
                label: 'Approve',
                name: 'Request For Cancellation',
                title: 'Request For Cancellation',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }
        },
        { type: 'button', typeAttributes: {
            label: 'Reject',
            name: 'Reject',
            title: 'Reject',
            variant:'destructive',
            value: '',
            iconPosition: 'left',
            hideDefaultActions: true
        }},{ type: 'button', typeAttributes: {
            label: 'Resubmit',
            name: 'Resubmit',
            title: 'Resubmit',
            variant:"success",
            value: '',
            iconPosition: 'left',
            hideDefaultActions: true
        }});
        this.data =[];
        this.backupResult = [];
    }

    handleReasonChange(event) {
        this.reasonValue = event.detail.value;
    }

    get getVisibilityOfFilterSelection() {
        return this.submittedToAccount || this.resubmittedByAuditTeam ||   this.resubmittedByCollectionTeam ;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    get checkRequired() {
       return  this.reject || this.resubmit;
    }
}