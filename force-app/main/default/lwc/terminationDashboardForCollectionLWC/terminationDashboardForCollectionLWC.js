// ************************************************************************************ */
// SR No    Author          Date            Remarks
// V1.1     MMFurkan        17-May-2023     #Enhancement request For collections dashboard, in the tab “submitted by DLD team”, we need an option to “allocate to legal”. In these cases, the termination status should change to “legal termination” 
//
//
//************************************************************************************ */

import { LightningElement,track } from 'lwc';
import bookingListWithOverDue from '@salesforce/apex/TerminationDashboardControllerLWC.bookingListWithOverDue';
import submittedToAccount from '@salesforce/apex/TerminationDashboardControllerLWC.submittedToAccount';
import fusejs from '@salesforce/resourceUrl/fusejs';
import { loadScript } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const columns = [
    { label: 'Booking Id', fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    { label: 'Unit Number', fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Customer Name', fieldName: 'customerName', hideDefaultActions: true,wrapText: true /*, cellAttributes:{
    class:{fieldName:'lineclamp'} } */},
    { label: 'Booking Date', fieldName: 'bookingDate', hideDefaultActions: true },
    { label: 'Pre Registration Status', fieldName: 'registrationStatus', hideDefaultActions: true },
    { label: 'Sale Value', fieldName: 'saleValue', type: 'currency', wrapText: true, hideDefaultActions: true, typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2 } },    
    { label: 'Milestone Due', fieldName: 'milestoneDue', type: 'currency', wrapText: true, hideDefaultActions: true, typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2 } },   
    { label: 'Collected Amount', fieldName: 'collected', type: 'currency', wrapText: true, hideDefaultActions: true, typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2 } },    
    { label: 'Balance', fieldName: 'balance', type: 'currency', wrapText: true, hideDefaultActions: true, typeAttributes: { minimumFractionDigits: 0, maximumFractionDigits: 2 } },
    { label: 'Date Submitted', fieldName: 'submittedToCollectionDate', hideDefaultActions: true },
    { label: 'Age', fieldName: 'age', hideDefaultActions: true },
    { label: 'SOA', fieldName: 'soaLink', type: 'url', target: '_blank', typeAttributes: { label: 'click here' }, hideDefaultActions: true },
    //SOB-525(Aayushi added date field to show on UI)
   
];
export default class TerminationDashboardForCollection extends LightningElement {

    columns = columns;
    backupResult = [];
    data = [];
    searchTerm;
    selectedProjectId;
    terminationStatusForBooking;
    selectedTowerId;
    showSpinner = false;
    createNewCancellationRequest = false;
    resubmittedByAccountTeam = false;
    resubmittedByAuditTeam = false;
    rejectedByAccounts = false;
    rejectedByAudit = false
    terminationStatus = [null];
    submitedToWhom;
    isTowerDisable;
    reasonValue;
    openModal;
    openRemarksModal;
    terminationRemarks;
    isRejectedVisible;
    isResubmitVisible;
    isApproveVisible;
    recIds;
    terminationStatusForRejection;
    termiantionStatusForResubmission;
    reject;
    resubmit;
    allocateToCRM;  // V1.1
    allocateToLegal;  // V1.1
    @track allocateToCRMTeamStatus = 'Re Allocated To CRM By Collection';   // V1.1 
    @track allocateToLegalTeamStatus = 'Legal Termination';   // V1.1 
    submittedbyDLd = false;
    submittedbyCRM = false;
    subscription = {};
    CHANNEL_NAME = '/event/Termination_Dashboard_Sync_Ups__e'; // Platform Event Api Name




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
                        "lineclamp":'slds-line-clamp'
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
        const localResults = fuseResult.search(searchTerm);
        let displayRecords = [];
        if (localResults && localResults.length > 0) {
            localResults.forEach(function (obj) {
                displayRecords.push(obj.item);
            });
        }
        this.data = displayRecords;
    }

    handleRequestForCancellation(event) {
        this.recIds = event.detail.recIds;
        const actionName = event.detail.actionName.toLowerCase();
        this.reject =  actionName.includes('reject') ? true  : false;
        this.resubmit = actionName.includes('resubmit') ? true : false;
        this.allocateToLegal = actionName.includes('allocatetolegal') ? true : false; // V1.1
        this.allocateToCRM = actionName.includes('allocatetocrm') ? true : false; // V1.1
        console.log('actionName : ' + actionName);
        console.log('allocateToLegal : ' + this.allocateToLegal);
        console.log('allocateToCRM : ' + this.allocateToCRM);
        console.log('resubmit : ' + this.resubmit);
        console.log('resubmit : ' + this.checkRequired);
        if(actionName.includes('terminationremarks')){
            this.terminationRemarks = event.detail.terminationRemarks;
            this.openRemarksModal = true;
        }
        else{
            if (this.checkRequired) {
                this.openModal = true;
            } else {
                this.submitToAccount();
            }
        }
    }

    submitToAccount() {
        let isValid = true;
        const allValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {   
        this.showSpinner = true;
        // V1.1
        let terminationStatus =   this.reject ? this.terminationStatusForRejection : this.resubmit ? this.termiantionStatusForResubmission : this.allocateToLegal ? this.allocateToLegalTeamStatus : this.allocateToCRM ? this.allocateToCRMTeamStatus : this.terminationStatusForBooking;
        console.log(' terminationStatus ',terminationStatus);
        console.log(' this.resubmit ',this.resubmit,' this.termiantionStatusForResubmission ',this.termiantionStatusForResubmission,' this.allocatetolegal ',this.allocateToLegal,' this.allocateToLegalTeamStatus ',this.allocateToLegalTeamStatus,' this.allocateToCRM ',this.allocateToCRM,' this.allocateToCRMTeamStatus ',this.allocateToCRMTeamStatus, ' terminationStatusForBooking ',this.terminationStatusForBooking);
        submittedToAccount({ bookingIdList: this.recIds ,terminationStatus : terminationStatus,reasonValue : this.reasonValue,submitedToWhom : this.submitedToWhom,submittedBy : 'Collection'})
        .then(result => {
            this.openModal = false;
            this.getOverDueBookings();
        }).catch(err => {
            this.showSpinner = false;
            this.openModal = false;
            this.showNotification('', reduceErrors(err).toString(), 'error');
        });
    }
    }

    get newCancellationRequestButtonVariant() {
        return this.createNewCancellationRequest ? 'brand' : 'neutral';
    }
    get resubmittedByAccountTeamVariant() {
        return this.resubmittedByAccountTeam ? 'brand' : 'neutral';
    }
    get resubmittedByAuditTeamVariant() {
        return this.resubmittedByAuditTeam ? 'brand' : 'neutral';
    }
    get rejectedByAccountsVariant(){
        return this.rejectedByAccounts ? 'brand' : 'neutral';
    }

    get rejectedByAuditVariant(){
        return this.rejectedByAudit ? 'brand' : 'neutral';
    }
    get submittedByDLdVariant(){
        return this.submittedbyDLd ? 'brand' : 'neutral';
    }
    get submittedByCRMVariant(){
        return this.submittedbyCRM ? 'brand' : 'neutral';
    }

    handleReasonChange(event) {
        this.reasonValue = event.detail.value;
    }
    
    handleResubmittedByAccountTeamClick() {
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = true;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = false;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.submittedbyDLd = false;
        this.submittedbyCRM = false;
        this.termiantionStatusForResubmission = 'Resubmitted to accounts by collections';
        let terminationStatus =['Resubmitted to collections by accounts'];
        this.submitedToWhom = 'Account';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.isResubmitVisible = true;
        this.columns.push (
            {
                label: 'Remarks', type: 'button', typeAttributes: {
                    label: 'Remarks',
                    name: 'terminationRemarks',
                    title: 'Remarks',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Resubmit', type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true /*,cellAttributes:{
            class:{fieldName:'lineclamp'} } */},
            { type: 'button', typeAttributes: {
                label: 'Reject',
                name: 'Reject',
                title: 'Reject',
                variant:'destructive',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }}
        );
        this.data =[];
        this.backupResult = [];
    }

    handleResubmittedByAuditTeamClick() {
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = true;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = false;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.submittedbyDLd = false;
        this.submittedbyCRM = false;
        let terminationStatus =['Resubmitted to collections by audit'];
        this.termiantionStatusForResubmission = 'Resubmitted to audit by collections';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Audit';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.columns.push (
            {
                label: 'Remarks', type: 'button', typeAttributes: {
                    label: 'Remarks',
                    name: 'terminationRemarks',
                    title: 'Remarks',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Resubmit', type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: false /*,cellAttributes:{
            class:{fieldName:'lineclamp'} } */},
            { type: 'button', typeAttributes: {
                label: 'Reject',
                name: 'Reject',
                title: 'Reject',
                variant:'destructive',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }}
        );
        this.data =[];
        this.backupResult = [];
    }

    handleRejectedbyAccountsClick() {
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = true;
        this.rejectedByAudit = false;
        this.selectedProjectId ='';
        this.submittedbyDLd = false;
        this.submittedbyCRM = false;
        this.selectedTowerId='';
        let terminationStatus =['Rejected by accounts'];
        this.termiantionStatusForResubmission = 'Resubmitted to accounts by collections';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Account';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.columns.push (
            {
                label: 'Remarks', type: 'button', typeAttributes: {
                    label: 'Remarks',
                    name: 'terminationRemarks',
                    title: 'Remarks',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Resubmit', type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: false /*,cellAttributes:{
            class:{fieldName:'lineclamp'} } */},
            // { type: 'button', typeAttributes: {
            //     label: 'Reject',
            //     name: 'Reject',
            //     title: 'Reject',
            //     variant:'destructive',
            //     value: '',
            //     iconPosition: 'left',
            //     hideDefaultActions: true
            // }}
        );
        this.data =[];
        this.backupResult = [];
    }

    handleRejectedByAuditTeamClick() {
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = true;
        this.selectedProjectId ='';
        this.submittedbyDLd = false;
        this.submittedbyCRM = false;
        this.selectedTowerId='';
        let terminationStatus =['Rejected by audit'];
        this.termiantionStatusForResubmission = 'Resubmitted to audit by collections';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Audit';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.columns.push (
           
            {
                label: 'Remarks', type: 'button', typeAttributes: {
                    label: 'Remarks',
                    name: 'terminationRemarks',
                    title: 'Remarks',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Resubmit', type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: false /*,cellAttributes:{
            class:{fieldName:'lineclamp'} } */},
            // { type: 'button', typeAttributes: {
            //     label: 'Reject',
            //     name: 'Reject',
            //     title: 'Reject',
            //     variant:'destructive',
            //     value: '',
            //     iconPosition: 'left',
            //     hideDefaultActions: true
            // }}
        );
        this.data =[];
        this.backupResult = [];
    }

    handleNewCancellationRequestClick() {
        this.createNewCancellationRequest = true;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = false;
        this.selectedProjectId ='';
        this.submittedbyDLd = false;
        this.submittedbyCRM = false;
        this.terminationStatusForBooking = 'Submitted to Accounts';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Account';
        this.selectedTowerId='';
        this.columns = [...columns];
        this.isTowerDisable = true;
        this.isRejectedVisible = true;
        this.isResubmitVisible = false;
        this.isApproveVisible = true;
        this.reasonValue = null;
        this.columns.push({
            label: 'Resubmit', type: 'button', typeAttributes: {
                label: 'Submit',
                name: 'Request For Cancellation',
                title: 'Request For Cancellation',
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
        }});
        this.terminationStatus = [null];
        this.data =[];
        this.backupResult = [];
    }

    get getVisibilityOfFilterSelection() {
        return this.createNewCancellationRequest || this.resubmittedByAuditTeam ||   this.resubmittedByAccountTeam || this.rejectedByAccounts || this.rejectedByAudit
        || this.submittedbyDLd || this.submittedbyCRM ;
       }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    hideModalBox() {
        this.openModal = false;
        this.openRemarksModal = false;
    }
    get checkRequired() {
      return  this.reject || this.resubmit;
    }

    handleSubmittedByDLDTeamClick(){
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = false;
        this.submittedbyDLd = true;
        this.submittedbyCRM = false;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        let terminationStatus =['Resubmitted to Collections by DLD', 'Submitted to collections by DLD'];
        this.termiantionStatusForResubmission = 'Resubmitted to audit by collections';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Audit';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.columns.push (
            {
                label: 'Remarks', type: 'button', typeAttributes: {
                    label: 'Remarks',
                    name: 'terminationRemarks',
                    title: 'Remarks',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Resubmit', type: 'button', typeAttributes: {
                    label: 'Resubmit',
                    name: 'Resubmit',
                    title: 'Resubmit',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            {
                label: 'Allocate To Legal', type: 'button', typeAttributes: {
                    label: 'Allocate To Legal',
                    name: 'AllocateToLegal',
                    title: 'Allocate To Legal',
                    value: '',
                    iconPosition: 'left',
                    hideDefaultActions: true
                }
            },
            { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: false},
        );
        this.data =[];
        this.backupResult = [];
      
    }

    handleSubmittedByCRMTeamClick(){
        this.createNewCancellationRequest = false;
        this.resubmittedByAuditTeam = false;
        this.resubmittedByAccountTeam = false;
        this.rejectedByAccounts = false;
        this.rejectedByAudit = false;
        this.submittedbyDLd = false;
        this.submittedbyCRM = true;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        let terminationStatus =['Resubmitted to Collections by CRM'];
        this.termiantionStatusForResubmission = 'Submitted to Accounts';
        this.terminationStatusForRejection = 'Rejected by Collections';
        this.submitedToWhom = 'Account';
        this.terminationStatus = terminationStatus;
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = false;
        this.isTowerDisable = true;
        this.reasonValue = null;
        this.columns.push ({
            label: 'Remarks', type: 'button', typeAttributes: {
                label: 'Remarks',
                name: 'terminationRemarks',
                title: 'Remarks',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }
        },{
            label: 'Resubmit', type: 'button', typeAttributes: {
                label: 'Submit',
                name: 'Resubmit',
                title: 'Submit',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }
        },{
            label: 'Allocate To CRM', type: 'button', typeAttributes: {
                label: 'Allocate To CRM',
                name: 'AllocateToCRM',
                title: 'Allocate To CRM',
                value: '',
                iconPosition: 'left',
                hideDefaultActions: true
            }
        },{ label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: false });
        this.data =[];
        this.backupResult = [];
    }



}