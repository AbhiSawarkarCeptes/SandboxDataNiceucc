import { LightningElement } from 'lwc';
import bookingListWithOverDue from '@salesforce/apex/TerminationDashboardController.bookingListWithOverDue';
import submittedToAccount from '@salesforce/apex/TerminationDashboardController.submittedToAccount';
import fusejs from '@salesforce/resourceUrl/fusejs';
import { loadScript } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/lwcUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const columns = [
    { label: 'Booking Id', fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    { label: 'Unit Number', fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Customer Name', fieldName: 'customerName', hideDefaultActions: true,wrapText: true },
    { label: 'Purchase Price', fieldName: 'purchasePrice', hideDefaultActions: true },
     { label: 'Milestone Due', fieldName: 'milestoneDue', hideDefaultActions: true },
    { label: 'Demand Raised towards purchase price (A)', fieldName: 'demands', hideDefaultActions: true },
    { label: 'Amount Collected against purchase price (B)',     fieldName: 'collected', hideDefaultActions: true },
    { label: 'Outstanding amount (A-B)', fieldName: 'due', hideDefaultActions: true },
    { label: 'Date Submitted', fieldName: 'submittedToAuditDate', hideDefaultActions: true },
    { label: 'SOA', fieldName: 'soaLink', type: 'url', target: '_blank', typeAttributes: { label: 'click here' }, hideDefaultActions: true },
    { label: 'Termination Notice', fieldName: 'terminationNotice', hideDefaultActions: true },
    { label: 'Collection Comments', fieldName: 'collectionResubmissionComment', hideDefaultActions: true },
    { label: 'Accounts Comments', fieldName: 'accountResubmissionComment', hideDefaultActions: true },
    { label: 'Audit Comments', fieldName: 'auditResubmissionComment', hideDefaultActions: true },
    { label: 'Due % Against Purchase price', fieldName: 'duePercentage', hideDefaultActions: true},
    { label: 'SPA Executed Date', fieldName: 'spaExecuteDate', hideDefaultActions: true},
    { label: 'Registration amount received', fieldName: 'registrationAmountReceived', hideDefaultActions: true},
    { label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true}

];




export default class UnitTerminationAuditDashboard extends LightningElement {
    columns = columns;
    backupResult = [];
    data = [];
    searchTerm;
    selectedProjectId;
    terminationStatusForBooking;
    terminationStatusForRejection;
    selectedTowerId;
    showSpinner = false;
    submittedToAudit = false;
    resubmittedByCollectionTeam = false;
    resubmittedByAccountTeam = false;
    terminationStatus = [null];
    openModal = false;
    reject = false;
    isRejectedVisible = false;
    rejectedToWhom;
    submitedToWhom ='DLD';
    isResubmitVisible = false;
    isApproveVisible = false;
    resubmit;
    isTowerDisable = true;
    termiantionStatusForResubmission;
    recIds =[];
    subscription = {};
    CHANNEL_NAME = '/event/Termination_Dashboard_Sync_Ups__e'; // Platform Event Api Name

    connectedCallback() {
        loadScript(this, fusejs)
            .then(() => {
            }).catch(err => {
             this.showNotification('', reduceErrors(err).toString(), 'error');
            });
            subscribe(this.CHANNEL_NAME, -1,this.refreshApex ).then(response => {
                this.subscription = response;
            });
            onError(error => {
                 console.error('Server Error--->'+JSON.stringify(error));
            });
    }

    refreshApex = () => {
        this.getOverDueBookings()
    }


    disconnectedCallback() {
        unsubscribe(this.subscription, () => {
        // console.log('Unsubscribed Channel');
        });
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
                console.log('~~~~Result: '+JSON.stringify(this.data));
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
        const allValidRadio = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        if (allValid && allValidRadio) {
            this.showSpinner = true;
            let terminationStatus =   this.reject ? this.terminationStatusForRejection : this.resubmit ? this.termiantionStatusForResubmission : this.terminationStatusForBooking;
            let submitedToWhom = this.reject  || this.resubmit ? this.rejectedToWhom : this.submitedToWhom;
            submittedToAccount({ bookingIdList: this.recIds ,terminationStatus : terminationStatus,reasonValue : this.reasonValue,submitedToWhom : submitedToWhom,submittedBy :'Audit'})
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
        const localResults = fuseResult.search(searchTerm);
        let displayRecords = [];
        if (localResults && localResults.length > 0) {
            localResults.forEach(function (obj) {
                displayRecords.push(obj.item);
            });
        }
        this.data = displayRecords;
    }
    get submittedToAuditTeamButtonVariant() {
        return this.submittedToAudit ? 'brand' : 'neutral';
    }
    get resubmittedByCollectionTeamVariant() {
        return this.resubmittedByCollectionTeam ? 'brand' : 'neutral';
    }
    get resubmittedByAccountTeamVariant() {
        return this.resubmittedByAccountTeam ? 'brand' : 'neutral';
    }
    handleResubmittedByCollectionTeamClick() {
        this.submittedToAudit = false;
        this.resubmittedByAccountTeam = false;
        this.resubmittedByCollectionTeam = true;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.terminationStatusForBooking = 'Raised to DLD Team';
        this.terminationStatus =['Resubmitted to audit by collections'];
        this.terminationStatusForRejection = 'Rejected by audit';
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = true;
        this.columns = [...columns];
        this.isTowerDisable = true;
        this.columns.push (
          /*  { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true ,cellAttributes:{
            class:{fieldName:'lineclamp'} }}, */
            {
                type: 'button', typeAttributes: {
                    label: 'Approve',
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
            }},
           /* { label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true/*,cellAttributes:{
            class:{fieldName:'lineclamp'}}}, */
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

    handleResubmittedByAccountTeamClick() {
        this.submittedToAudit = false;
        this.resubmittedByAccountTeam = true;
        this.resubmittedByCollectionTeam = false;
        this.selectedProjectId ='';
        this.selectedTowerId='';
        this.terminationStatus =['Resubmitted to audit by accounts'];
        this.terminationStatusForBooking = 'Raised to DLD Team';
        this.terminationStatusForRejection = 'Rejected by audit';
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = true;
        this.columns = [...columns];
        this.isTowerDisable = true;
        this.columns.push (
       /* { label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true /*,cellAttributes:{
        class:{fieldName:'lineclamp'} }},*/
        {
            type: 'button', typeAttributes: {
                label: 'Approve',
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
        }},
           /* { label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true/*,cellAttributes:{
            class:{fieldName:'lineclamp'}} }, */
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

    handlesubmittedToAuditTeamClick() {
        this.submittedToAudit = true;
        this.resubmittedByAccountTeam = false;
        this.resubmittedByCollectionTeam = false;
        this.selectedProjectId ='';
        this.terminationStatus = ['Submitted to audit'];
        this.terminationStatusForBooking = 'Raised to DLD Team';
        this.rejectedToWhom = 'Account';
        this.terminationStatusForRejection = 'Rejected by audit';
        this.selectedTowerId='';
        this.columns = [...columns];
        this.isRejectedVisible = true;
        this.isResubmitVisible = true;
        this.isApproveVisible = true;
        this.isTowerDisable = true;
        this.columns.push(
            /*{ label: 'Status', fieldName: 'terminationStatus', hideDefaultActions: true,wrapText: true /*,cellAttributes:{
            class:{fieldName:'lineclamp'} }}, */
            {
            type: 'button', typeAttributes: {
                label: 'Approve',
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
        }},/*{ label: 'Remarks', fieldName: 'terminationRemarks', hideDefaultActions: true,wrapText: true},*/
        { type: 'button', typeAttributes: {
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
    handleRadioChange(event) {
        this.rejectedToWhom = event.detail.value;
        if (this.rejectedToWhom == 'Account') {
            this.termiantionStatusForResubmission = 'Resubmitted by audit to accounts';
        } else if (this.rejectedToWhom == 'Collection') {
            this.termiantionStatusForResubmission = 'Resubmitted to collections by audit'; 
        } else {
            this.termiantionStatusForResubmission = 'Resubmitted to Collection and Accounts by audit'; 
        }
    }

    get getVisibilityOfFilterSelection() {
        return this.submittedToAudit || this.resubmittedByAccountTeam ||   this.resubmittedByCollectionTeam ;
    }

    get checkSubmitToWhom() {
        return this.resubmit || this.reject;
    }

    get options() {
        if (this.reject) {
            return [
                { label: 'Account', value: 'Account' },
                { label: 'Collection', value: 'Collection'}
            ];
        } else {
            return [
                { label: 'Account', value: 'Account' },
                { label: 'Collection', value: 'Collection'},
                {label : 'Collection and Account' , value : 'Collection and Account'}
            ];
        }
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