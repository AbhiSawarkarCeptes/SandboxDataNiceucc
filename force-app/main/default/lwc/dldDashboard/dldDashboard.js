import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjects from '@salesforce/apex/DLDDashboardController.getProjects'
import getBookings from '@salesforce/apex/DLDDashboardController.getBookings';
import updateAllocation from '@salesforce/apex/DLDDashboardController.updateAllocation';
import updateBookingRow from '@salesforce/apex/DLDDashboardController.updateBookingRow';
import returnToCollections from '@salesforce/apex/DLDDashboardController.returnToCollections';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import approveFinalNotice from '@salesforce/apex/DLDDashboardController.approveEslamFinalNotice';
import validateEslamFinalNotice from '@salesforce/apex/DLDDashboardController.validateEslamFinalNotice';
import sendEslamFinalNotice from '@salesforce/apex/DLDDashboardController.sendEslamFinalNotice';
import isDLDProfile from '@salesforce/apex/DLDDashboardController.isDLDProfile';

import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

const actions1 = [
    { label: 'Save', name: 'save' }
];

const columns1 = [
    { label: 'Project', initialWidth: 110, fieldName: 'projectName', type: 'text' },
    { label: 'Unit Number', initialWidth: 100, fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Booking Id', initialWidth: 100, fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },

    {
        label: 'Customer Name', initialWidth: 180, fieldName: 'customerName', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    { label: 'Sale Value', initialWidth: 110, fieldName: 'saleValue', type: 'text' },
    { label: 'Collected Amount', initialWidth: 110, fieldName: 'collected', type: 'text' },
    { label: 'Collected %', initialWidth: 100, fieldName: 'collectedpercentage', type: 'percentage' },
    { label: 'Due Amount', initialWidth: 110, fieldName: 'fullDue', type: 'text' },
    { label: 'Due %', initialWidth: 100, fieldName: 'duepercentage', type: 'percentage' },
    { label: 'SPA Status', initialWidth: 150, fieldName: 'spaexecuted', type: 'text' },
    { label: 'Audit Approved Date', initialWidth: 180, fieldName: 'auditapproveddate', type: 'date' },

    {
        label: 'Allocation', initialWidth: 200, editable: true, fieldName: 'cancellationAllocation', type: 'picklist',
        typeAttributes: {
            label: 'cancellationAllocation',
            placeholder: 'Allocation', options: [
                { label: 'Allocate to CRM Team', value: 'Allocate to CRM Team' },
                { label: 'Allocate to DLD Team', value: 'Allocate to DLD Team' },
                { label: 'Allocate to Collection Team', value: 'Allocate to Collection Team' },
            ] // list of all picklist options
            , value: { fieldName: 'cancellationAllocation' } // default value for picklist
            , context: { fieldName: 'bookingId' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Cancel the process', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Cancel the process',
            name: 'Cancel the process',
            title: 'Cancel the process',
            value: '',
            iconPosition: 'left',
            variant: 'destructive',
            hideDefaultActions: true
        }
    },
    { label: 'Comments/Remarks', initialWidth: 180, fieldName: 'commentsremarks', type: 'text',wrapText: true, editable: true },
    { label: 'Allow PR', initialWidth: 100, fieldName: 'allowPR', type: 'boolean', editable: true },
    { label: 'Termination Remarks', initialWidth: 180, fieldName: 'terminationremarks', type: 'text', wrapText: true,editable: true },
    { label: 'Termination Process Status', initialWidth: 220, fieldName: 'terminationProcessStatus', type: 'text', editable: false },
];


const columns2 = [
    { label: 'Project', initialWidth: 110, fieldName: 'projectName', type: 'text' },
    { label: 'Unit Number', initialWidth: 100, fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Booking Id', initialWidth: 100, fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    {
        label: 'Customer Name(اسم الزبون)', editable: true, initialWidth: 180, fieldName: 'customerNameArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    {
        label: 'Customer Address (تبوك)', editable: true, initialWidth: 220, fieldName: 'customerAddressArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    { label: 'Project Completion % (Arabic)', editable: true, initialWidth: 220, fieldName: 'projectCompletionPercentageArabic', type: 'text' },
    { label: 'Sale Value', initialWidth: 150, fieldName: 'saleValue', type: 'text' },
    { label: 'Collected Amount', initialWidth: 150, fieldName: 'collected', type: 'text' },
    { label: 'Collected %', initialWidth: 150, fieldName: 'collectedpercentage', type: 'text' },
    { label: 'Due Amount', initialWidth: 150, fieldName: 'fullDue', type: 'text' },
    { label: 'Due %', initialWidth: 150, fieldName: 'duepercentage', type: 'text' },
    { label: 'SPA Status', initialWidth: 150, fieldName: 'spaexecuted', type: 'text' },
    { label: 'Audit Approved Date', initialWidth: 150, fieldName: 'auditapproveddate', type: 'date' },
    { label: 'Comments/Remarks', editable: true, initialWidth: 180, fieldName: 'commentsremarks', type: 'text',wrapText: true, },
    { label: 'Allow PR', initialWidth: 100, fieldName: 'allowPR', type: 'boolean', editable: true },
    { label: 'Termination Remarks', initialWidth: 180, fieldName: 'terminationremarks', type: 'text', wrapText: true,editable: true },
    // { label: 'Allocation', initialWidth: 180, fieldName: 'cancellationAllocation', type: 'text' },
    {
        label: 'Allocation', initialWidth: 200, editable: true, fieldName: 'cancellationAllocation', type: 'picklist',
        typeAttributes: {
            label: 'cancellationAllocation',
            placeholder: 'Allocation', options: [
                { label: 'Allocate to CRM Team', value: 'Allocate to CRM Team' },
                { label: 'Allocate to Collection Team', value: 'Allocate to Collection Team' },
            ] // list of all picklist options
            , value: { fieldName: 'cancellationAllocation' } // default value for picklist
            , context: { fieldName: 'bookingId' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Approve Final Notice', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Approve Final Notice',
            name: 'Approve Final Notice',
            title: 'Approve Final Notice',
            value: '',
            iconPosition: 'left',

            hideDefaultActions: true
        }
    },
    {
        label: 'Final Notice Document', initialWidth: 250, fieldName: 'dldfile', type: 'fileupload',
        typeAttributes: {
            filename: 'Final Notice',
            formats: ".pdf,.png",
            recordId: { fieldName: 'bookingId' }, //pass Id of current record
        }
    },
    {
        label: 'Send Final Notice', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Send Final Notice',
            name: 'Send Final Notice',
            title: 'Send Final Notice',
            value: '',
            iconPosition: 'left',
            variant: 'brand',
            hideDefaultActions: true
        }
    },
    {
        label: 'Cancel the process', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Cancel the process',
            name: 'Cancel the process',
            title: 'Cancel the process',
            value: '',
            iconPosition: 'left',
            variant: 'destructive',
            hideDefaultActions: true
        }
    },
    { label: 'Termination Process Status', initialWidth: 220, fieldName: 'terminationProcessStatus', type: 'text', editable: false },
];

const dldColumns2 = [
    { label: 'Project', initialWidth: 110, fieldName: 'projectName', type: 'text' },
    { label: 'Unit Number', initialWidth: 100, fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Booking Id', initialWidth: 100, fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    {
        label: 'Customer Name(اسم الزبون)', editable: true, initialWidth: 180, fieldName: 'customerNameArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    {
        label: 'Customer Address (تبوك)', editable: true, initialWidth: 220, fieldName: 'customerAddressArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    { label: 'Project Completion % (Arabic)', editable: true, initialWidth: 220, fieldName: 'projectCompletionPercentageArabic', type: 'text' },
    { label: 'Sale Value', initialWidth: 150, fieldName: 'saleValue', type: 'text' },
    { label: 'Collected Amount', initialWidth: 150, fieldName: 'collected', type: 'text' },
    { label: 'Collected %', initialWidth: 150, fieldName: 'collectedpercentage', type: 'text' },
    { label: 'Due Amount', initialWidth: 150, fieldName: 'fullDue', type: 'text' },
    { label: 'Due %', initialWidth: 150, fieldName: 'duepercentage', type: 'text' },
    { label: 'SPA Status', initialWidth: 150, fieldName: 'spaexecuted', type: 'text' },
    { label: 'Audit Approved Date', initialWidth: 150, fieldName: 'auditapproveddate', type: 'date' },
    { label: 'Comments/Remarks', editable: true, initialWidth: 180, fieldName: 'commentsremarks', wrapText: true, type: 'text' },
    { label: 'Allow PR', initialWidth: 100, fieldName: 'allowPR', type: 'boolean', editable: true },
    { label: 'Termination Remarks', initialWidth: 180, fieldName: 'terminationremarks', type: 'text', wrapText: true,editable: true },
    {
        label: 'Allocation', initialWidth: 200, editable: true, fieldName: 'cancellationAllocation', type: 'picklist',
        typeAttributes: {
            label: 'cancellationAllocation',
            placeholder: 'Allocation', options: [
                { label: 'Allocate to CRM Team', value: 'Allocate to CRM Team' },
                { label: 'Allocate to Collection Team', value: 'Allocate to Collection Team' },
            ] // list of all picklist options
            , value: { fieldName: 'cancellationAllocation' } // default value for picklist
            , context: { fieldName: 'bookingId' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Final Notice Document', initialWidth: 250, fieldName: 'dldfile', type: 'fileupload',
        typeAttributes: {
            filename: 'Final Notice',
            formats: ".pdf,.png",
            recordId: { fieldName: 'bookingId' }, //pass Id of current record
        }
    },
    {
        label: 'Send Final Notice', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Send Final Notice',
            name: 'Send Final Notice',
            title: 'Send Final Notice',
            value: '',
            iconPosition: 'left',
            variant: 'brand',
            hideDefaultActions: true
        }
    },
    {
        label: 'Cancel the process', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Cancel the process',
            name: 'Cancel the process',
            title: 'Cancel the process',
            value: '',
            iconPosition: 'left',
            variant: 'destructive',
            hideDefaultActions: true
        }
    },
    { label: 'Termination Process Status', initialWidth: 220, fieldName: 'terminationProcessStatus', type: 'text', editable: false },
];

const columns3 = [
    { label: 'Project', initialWidth: 110, fieldName: 'projectName', type: 'text' },
    { label: 'Unit Number', initialWidth: 100, fieldName: 'unitId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'unitName' } }, hideDefaultActions: true },
    { label: 'Booking Id', initialWidth: 100, fieldName: 'bookingId', type: 'url', target: '_blank', typeAttributes: { label: { fieldName: 'bookingName' } }, hideDefaultActions: true },
    {
        label: 'Customer Name', initialWidth: 180, fieldName: 'customerName', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    {
        label: 'Customer Name(اسم الزبون)', initialWidth: 180, fieldName: 'customerNameArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    {
        label: 'Customer Address (تبوك)', initialWidth: 220, fieldName: 'customerAddressArabic', hideDefaultActions: true, wrapText: true, cellAttributes: {
            class: { fieldName: 'lineclamp' }
        }
    },
    { label: 'Project Completion % (Arabic)', initialWidth: 220, fieldName: 'projectCompletionPercentageArabic', type: 'text' },
    { label: 'Sale Value', initialWidth: 110, fieldName: 'saleValue', type: 'text' },
    { label: 'Collected Amount', initialWidth: 110, fieldName: 'collected', type: 'text' },
    { label: 'Collected %', initialWidth: 100, fieldName: 'collectedpercentage', type: 'percentage' },
    { label: 'Due Amount', initialWidth: 110, fieldName: 'fullDue', type: 'text' },
    { label: 'Due %', initialWidth: 100, fieldName: 'duepercentage', type: 'percentage' },
    { label: 'SPA Status', initialWidth: 150, fieldName: 'spaexecuted', type: 'text' },
    { label: 'Audit Approved Date', initialWidth: 180, fieldName: 'auditapproveddate', type: 'date' },
    { label: 'Allow PR', initialWidth: 100, fieldName: 'allowPR', type: 'boolean', editable: true },
    { label: 'Developer Final Notice Sent Date', initialWidth: 180, fieldName: 'finalNoticeSentDate', type: 'Date' },
    { label: 'Developer Final Notice Sent Date (Courier)', initialWidth: 180, fieldName: 'developerFinalNoticeSentDateCourier', type: 'date', editable: true },
    {
        label: 'Developer Final Notice Status', initialWidth: 180, fieldName: 'developerFinalNoticeStatus', type: 'picklist', editable: true,
        typeAttributes: {
            label: 'developerFinalNoticeStatus',
            placeholder: 'Select Status', options: [
                { label: 'Received', value: 'Received' },
                { label: 'Not Received', value: 'Not Received' },
            ]
            , value: { fieldName: 'developerFinalNoticeStatus' }
            , context: { fieldName: 'bookingId' }
        }
    },
    { label: 'Developer Final Notice Receive Date (Courier)', initialWidth: 180, fieldName: 'finalNoticeReceivedDate', type: 'date', editable: true },
    {
        label: 'Upload DLD Notice', initialWidth: 250, fieldName: 'dldfile', type: 'fileupload',
        typeAttributes: {
            filename: 'DLD Notice',
            formats: ".pdf,.png",
            recordId: { fieldName: 'bookingId' }, //pass Id of current record
        }
    },
    {
        label: 'Send DLD Notice', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Send DLD Notice',
            name: 'Send DLD Notice',
            title: 'Send DLD Notice',
            value: '',
            iconPosition: 'left',

            hideDefaultActions: true
        }
    },
    { label: 'DLD Notice Sent Date', initialWidth: 180, fieldName: 'forfeitureNoticeSentDate', type: 'date' },
    {
        label: 'DLD Notice Status', initialWidth: 180, fieldName: 'dldNoticeStatus', type: 'picklist', editable: true,
        typeAttributes: {
            label: 'dldNoticeStatus',
            placeholder: 'Select Status', options: [
                { label: 'Received', value: 'Received' },
                { label: 'Not Received', value: 'Not Received' },
            ]
            , value: { fieldName: 'dldNoticeStatus' }
            , context: { fieldName: 'bookingId' }
        }
    },
    {
        label: 'DLD Notice Status Category', initialWidth: 180, fieldName: 'dldNoticeStatusCategory', type: 'picklist', editable: true, typeAttributes: {
            label: 'dldNoticeStatusCategory',
            placeholder: 'Select Status', options: [
                { label: 'Customer Objected ', value: 'Customer Objected ' },
                { label: 'Customer Paid/Settled', value: 'Customer Paid/Settled' },
                { label: 'Approved by DLD ', value: 'Approved by DLD ' },
                { label: 'Procedure Cancelled by DLD', value: 'Procedure Cancelled by DLD' },
                { label: 'Public Announcement', value: 'Public Announcement' },
            ] // list of all picklist options
            , value: { fieldName: 'dldNoticeStatusCategory' } // default value for picklist
            , context: { fieldName: 'bookingId' } // binding account Id with context variable to be returned back
        }
    },
    //{ label: 'DLD Audit Completion Date', initialWidth: 180, fieldName: 'finalNoticeSentDate', type: 'Datetime' },

    { label: 'Forfeited Amount (if unit terminated)', initialWidth: 180, fieldName: 'forfeitedAmount', type: 'number', editable: true },
    { label: 'Amount paid by Customer', initialWidth: 180, fieldName: 'forfeitedAmount', type: 'number', editable: true },

    {
        label: 'Final DLD Audited Document', initialWidth: 230, fieldName: 'fdldAdocfile', type: 'fileupload',
        typeAttributes: {
            filename: 'DLD Audited Document',
            formats: ".pdf,.png",
            recordId: { fieldName: 'bookingId' }, //pass Id of current record
        }
    },
    { label: 'Remarks', initialWidth: 180, fieldName: 'commentsremarks', type: 'text', editable: true },
    { label: 'Allow PR', initialWidth: 100, fieldName: 'allowPR', type: 'boolean', editable: true },
    {
        label: 'Cancel the process', initialWidth: 180, type: 'button', typeAttributes: {
            label: 'Cancel the process',
            name: 'Cancel the process',
            title: 'Cancel the process',
            value: '',
            iconPosition: 'left',
            variant: 'destructive',
            hideDefaultActions: true
        }
    },

    { label: 'Termination Process Status', initialWidth: 220, fieldName: 'terminationProcessStatus', type: 'text', editable: false },
    { label: 'Process Completion Date', initialWidth: 180, fieldName: 'terminationCompletionDate', type: 'date' },

];

export default class dldDashboard extends NavigationMixin(LightningElement) {

    value = '';
    filtervalue = 'All';
    showSection = false;
    selectedProject = '';
    @track selectedTower = '';
    selectedType = '';
    selectedCategory = '';
    selectedTaskCategory = 'All';
    showSpinner = false;
    projectoptions = [];
    toweroptions = [];
    categoryoptions = [];
    taskcategoryoptions = [];
    dueCategoryOptions = [];
    advanceCategoryOptions = [];
    projectData = [];
    categoryOfSelectedRow = '';
    userTimeZone = TIME_ZONE;
    currentTime;
    @track isEmailModalOpen = false;
    @track isCancelTheProcessOpen = false;

    @track towerValue = '';
    @track isFollowUp = false;
    @track isDue = false;
    @track isAdvance = false;
    @track isCategories = false;
    @track isExecutive = false;
    @track isGrossAll = false;

    @track isDashboard1 = false;
    @track isDashboard2 = false;
    @track isDashboard3 = false;

    @track bookingData = [];
    tempBookingData = [];
    @track dueFollowUpBookingData = [];
    tempDueFollowUpBookingData = [];
    @track advanceFollowUpBookingData = [];
    tempAdvanceFollowUpBookingData = [];
    @track isModalOpen = false;
    @track isModalOpenCallLog = false;

    @track showAmount = false;
    @track showAmountToBePaidInAdv = false;
    @track showBankName = false;
    @track showDiscountOnSale = false;
    @track showDiscountAmount = false;
    @track showExpectedDateOfReceivingCheque = false;
    @track showExpectedDateOfPayment = false;
    @track showFollowUpDate = false;
    @track showMortgageOfferLetter = false;
    @track showPTPDate = false;
    @track showReasonForUnableToPay = false;
    @track showValuation = false;
    @track showCustomerInterested = false;
    @track showLastContactedDate = false;

    /*@track makeAmountReq = false;
    @track makeFollowUpDateReq = false;
    @track makeBankNameReq = false;
    @track makeValueationReq = false;

    @track selectedBookingId = '';
    @track selectedBookingSaleValue;
    @track selectedDueOrAdvanceAmount = 0;
    @track discountPercentage;*/

    /*@track totalUnits = 0.00;
    @track totalSalValue = 0.00;
    @track totalDemandRaised = 0.00;
    @track totalMilestoneDue = 0.00;
    @track totalCollectionAmount = 0.00;
    @track totalOverdueAmount = 0.00;
    @track totalBalance = 0.0;

    @track totalUnitsDue = 0.00;
    @track totalSalValueDue = 0.00;
    @track totalDemandRaisedDue = 0.00;
    @track totalMilestoneDueDue = 0.00;
    @track totalCollectionAmountDue = 0.00;
    @track totalOverdueAmountDue = 0.00;
    @track totalBalanceDue = 0.0;

    @track totalUnitsDueAdvance = 0.00;
    @track totalSalValueDueAdvance = 0.00;
    @track totalDemandRaisedDueAdvance = 0.00;
    @track totalMilestoneDueDueAdvance = 0.00;
    @track totalCollectionAmountDueAdvance = 0.00;
    @track totalOverdueAmountDueAdvance = 0.00;
    @track totalBalanceDueAdvance = 0.0;*/

    @track newTaskId = '';

    @track todayDate;
    @track lastContactedDate;
    @track showSearch = false;

    @track target;
    @track acheived;
    @track acheivedPercentage;
    @track targetTabData = [];
    @track categoryData = [];
    @track ageingData = [];
    @track executiveTowerData = [];
    allTowers = [];
    @track selectedTowerInExecutive = 'All';
    @track showCategoryTable = false;
    @track showAgeingTable = false;
    @track showTowerTable = false;
    @track futureMilestoneMonths = [];

    @track dashboardTypeValue;
    @track tempRow;

    @track emailValues;
    @track cancelComments = '';

    columns1 = columns1;
    columns2;
    columns3 = columns3;

    valuedropdown = 'NoSelection';

    draftValues = [];

    validationForRemark = [];

    //filters
    @api fromAuditApprovedDate;
    @api toAuditApprovedDate;

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            alert('You selected: ' + selectedRows[i].opportunityName);
        }
    }

    get optionsdropdown() {
        return [
            { label: 'Internal Cancellation', value: 'Internal Cancellation' },
            { label: 'Send it to Legal team', value: 'Send it to Legal team' }
        ];
    }

    handleSave(event) {
        console.log('Updated items', event.detail.draftValues);
        event.detail.draftValues.forEach(each => {
            let pushTo = false;
            Object.keys(each).forEach(function(k){
                console.log(k + ' - ' + each[k]);
                if(k == 'terminationremarks'){
                    pushTo = true;
                }
            });
            if(pushTo == true){
                console.log('Pushto is false', pushTo);
                this.validationForRemark.push(each);
            }else{
                console.log('Pushto is false', pushTo);
            }
        })
        console.log(JSON.stringify(event.detail.draftValues));
        let updatedRowData = JSON.stringify(event.detail.draftValues);
        updateBookingRow({ row: updatedRowData }).then(result => {
            console.log(result);
            if (result) {
                const evt = new ShowToastEvent({
                    variant: 'success',
                    message: 'Updated successfully!',
                });
                this.dispatchEvent(evt);
            }
        }).then(() => {
            console.log('loading bookings again');
            getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue }).then(result => {
                console.log(result);
                if (result) {
                    this.bookingData = result;
                    this.draftValues = [];
                }
            }).catch(error => { });
        }).catch(error => { });
    }

    handleAllocation(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { bookingId: dataRecieved.context, cancellationAllocation: dataRecieved.value };
        console.log(updatedItem);
        //console.log('Updated items', event.detail.draftValues);
        //console.log(JSON.stringify(event.detail.draftValues));
        //let updatedRowData = JSON.stringify(event.detail.draftValues);

        let rows = [];
        rows.push(updatedItem);
        updateBookingRow({ row: JSON.stringify(rows), canceltheprocess: false })
            .then(result => {
                console.log(result);
                if (result) {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Allocated successfully!',
                    });
                    this.dispatchEvent(evt);
                }
            })
            .then(() => {

                console.log('loading bookings again');
                getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue })
                    .then(result => {
                        console.log(result);
                        if (result) {
                            this.bookingData = result;
                            //this.draftValues = [];
                        }
                    })
                    .catch(error => {
                    });
            })
            .catch(error => {
            });
    }

    connectedCallback() {
        var today = new Date().toLocaleString("en-US");
        today = today.split(',')[0];
        this.todayDate = today;
        console.log('connected callac');
        isDLDProfile()
            .then(result => {
                console.log('resutl : ' + result);
                if (result) {
                    this.columns2 = dldColumns2;
                } else {
                    this.columns2 = columns2;
                }
            })
            .catch(err => {
                console.log('err : ' + JSON.stringify(err));
            })

        this.loadProjects();

        /*var dueCategories = [];
        var advanceCategories = [];
        for (var i = 0; i < allTaskCategories.length; i++) {
            if ((allTaskCategories[i].value == 'Not Pitched' || allTaskCategories[i].value == 'Customer Interested' || allTaskCategories[i].value == 'No Contact / Unable to Reach') && allTaskCategories[i].value != 'All')
                advanceCategories.push(allTaskCategories[i]);
            if (allTaskCategories[i].value != 'Not Pitched' && allTaskCategories[i].value != 'Customer Interested' && allTaskCategories[i].value != 'All')
                dueCategories.push(allTaskCategories[i]);
        }

        this.dueCategoryOptions = dueCategories;
        this.advanceCategoryOptions = advanceCategories;*/

        //data = data;
        /*if (this.isDashboard1)
            this.columns = columns1;
        if (this.isDashboard2)
            this.columns = columns2;
        if (this.isDashboard3)
            this.columns = columns3;*/
    }

    handleRowAction(event) {
        console.log('handling row action');
        const action = event.detail.action;
        console.log(JSON.stringify(action));
        const row = event.detail.row;
        console.log(row);
        console.log(JSON.stringify(row));
        let rowData = JSON.stringify(row);
        console.log(action.name);
        switch (action.name) {
            case 'save':
                updateBookingRow({ row: rowData, canceltheprocess: false })
                    .then(result => {
                        console.log();
                        if (result) {
                            const evt = new ShowToastEvent({
                                variant: 'success',
                                message: 'Updated successfully!',
                            });
                            this.dispatchEvent(evt);
                        }

                        this.draftValues = [];
                    })
                    .catch(error => {
                    });
                break;
            case 'Cancel the process':
                console.log('Cancel the process clicked');
                this.isCancelTheProcessOpen = true;
                this.tempRow = rowData;
                break;
            case 'Approve Final Notice':
                console.log('Approve Final Notice clicked');
                approveFinalNotice({ row: rowData })
                    .then(result => {
                        console.log(result);
                        if (result == 'Unauthorized') {
                            const evt = new ShowToastEvent({
                                variant: 'error',
                                message: 'You are not authorized to approve!',
                            });
                            this.dispatchEvent(evt);
                        }
                        if (result == 'Already Approved') {
                            const evt = new ShowToastEvent({
                                variant: 'warning',
                                message: 'Final Notice is already approved!',
                            });
                            this.dispatchEvent(evt);
                        }
                        if (result == 'Approved') {
                            const evt = new ShowToastEvent({
                                variant: 'success',
                                message: 'Successfully approved!',
                            });
                            this.dispatchEvent(evt);
                        }
                        this.draftValues = [];
                    })
                    .catch(error => {
                    });
                break;
            case 'Send Final Notice':
                console.log('Send Final Notic');
                console.log('rowDate');
                console.log(rowData);
                this.tempRow = rowData;
                validateEslamFinalNotice({ row: rowData })
                    .then(result => {
                        console.log(result);
                        if (result == 'Unauthorized') {
                            const evt = new ShowToastEvent({
                                variant: 'error',
                                message: 'You are not authorized to approve!',
                            });
                            this.dispatchEvent(evt);
                        }
                        if (result == 'Unapproved') {
                            const evt = new ShowToastEvent({
                                variant: 'warning',
                                message: 'Final Notice is not approved!',
                            });
                            this.dispatchEvent(evt);
                        }
                        if (result == 'Success') {
                            this.isEmailModalOpen = true;
                        }
                        this.draftValues = [];
                    })
                    .catch(error => {
                    });
                break;

        }
    }

    handleEmailChange(event) {
        this.emailValues = event.target.value;
    }

    handleCancelCommentsChange(event) {
        this.cancelComments = event.target.value;
    }

    sendFinalNotice() {

        //var emailsValue = '';
        //emailsValue = this.template.querySelector(".finalnoticeemails");
        //console.log(JSON.stringify(JSON.parse(emailsValue)));

        console.log('Send sendFinalNotice : ' + this.emailValues);
        this.isEmailModalOpen = false;

        sendEslamFinalNotice({ row: this.tempRow, emails: this.emailValues })
            .then(result => {
                console.log('Sending final notice....');
                console.log(result);
                if (result == 'Success') {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Final Notice Sent successfully!',
                    });
                    this.dispatchEvent(evt);
                } else {
                    console.log('Sending final notice....');
                    console.log(result);
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: 'Error sending the Final Notice!',
                    });
                    this.dispatchEvent(evt);
                }

                this.draftValues = [];
            })
            .then(() => {
                this.tempRow = '';
                console.log('loading bookings again');
                getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue })
                    .then(result => {
                        console.log(result);
                        if (result) {
                            this.bookingData = result;
                            //this.draftValues = [];
                        }
                    })
                    .catch(error => {
                    });
            })
            .catch(error => {
            });

    }

    handleCancellationAfterComments(event) {
        var inputValue = this.template.querySelector(".cancelcomments");

        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            console.log('Comments are provided!');
            this.canceltheprocess();
        } else {
            const evt = new ShowToastEvent({
                variant: 'error',
                message: 'Cancellation comments are mandatory!',
            });
            this.dispatchEvent(evt);
        }
    }

    canceltheprocess() {
        updateBookingRow({ row: this.tempRow, canceltheprocess: true, cancelComments: this.cancelComments })
            .then(result => {
                console.log(result);
                if (result) {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: 'Cancelled the termination process!',
                    });
                    this.dispatchEvent(evt);
                }

                this.draftValues = [];
                this.isCancelTheProcessOpen = false;
            })
            .then(() => {
                this.tempRow = '';
                console.log('loading bookings again');
                getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue })
                    .then(result => {
                        console.log(result);
                        if (result) {
                            this.bookingData = result;
                            //this.draftValues = [];
                        }
                    })
                    .catch(error => {
                    });
            })
            .catch(error => {
            });
    }

    openModal() {
        this.isEmailModalOpen = true;
    }

    closeModal() {
        console.log('Close modal');
        this.isEmailModalOpen = false;
    }

    closeEmailIdsModel() {
        this.isEmailModalOpen = false;
    }

    closeCancelTheProcessPopup() {
        this.isCancelTheProcessOpen = false;
    }

    setLastContactedDate(event) {
        this.lastContactedDate = event.detail.value;
    }

    loadProjects() {
        getProjects()
            .then(result => {
                console.log('Get projects');
                console.log(result);
                this.projectData = result;
                let projects = [];
                let towers = [];
                let obj = { label: 'All', value: 'All' };
                towers.push(obj);
                for (var i = 0; i < result.length; i++) {
                    let projectObj = { label: result[i].Name, value: result[i].Id };
                    projects.push(projectObj);
                    let towerData = result[i].Towers__r;
                    if (towerData != null && towerData != undefined) {
                        for (var j = 0; j < towerData.length; j++) {
                            let towerObj = { label: towerData[j].Name, value: towerData[j].Id };
                            towers.push(towerObj);
                        }
                    }
                }
                this.allTowers = towers;
                projects.unshift({ label: 'All', value: 'All' });
                this.projectoptions = projects;
            })
            .catch(error => {
            });
    }

    loadTowers(projId) {
        let projectData = this.projectData;
        for (var i = 0; i < projectData.length; i++) {
            if (projectData[i].Id == projId) {
                let towerData = projectData[i].Towers__r;
                let towers = [];
                let obj = { label: 'All', value: 'All' };
                towers.push(obj);
                if (towerData != null && towerData != undefined) {
                    for (var i = 0; i < towerData.length; i++) {
                        let towerObj = { label: towerData[i].Name, value: towerData[i].Id };
                        towers.push(towerObj);
                    }
                }
                this.toweroptions = towers;
                break;
            }
        }
    }

    loadMonthList() {
        this.showSpinner = true;
        getMonthList()
            .then(result => {
                this.futureMilestoneMonths = result;
                this.loadExecutiveTowerData(this.selectedTowerInExecutive);
            })
            .catch(error => {
            });
    }

    onTowerChange(event) {
        this.categoryData = [];
        this.ageingData = [];
        this.executiveTowerData = [];
        this.showCategoryTable = false;
        this.showAgeingTable = false;
        this.showTowerTable = false;
        this.selectedTowerInExecutive = event.detail.value;
        var targetTabData = this.targetTabData;
        for (var i = 0; i < targetTabData.length; i++) {
            if (targetTabData[i].towerId == event.detail.value) {
                this.target = targetTabData[i].target;
                this.acheived = targetTabData[i].achieved;
                this.acheivedPercentage = targetTabData[i].achievedPercentage;
                break;
            }
            else {
                this.target = '';
                this.acheived = '';
                this.acheivedPercentage = '';
            }
        }
        this.loadExecutiveTowerData(this.selectedTowerInExecutive);
    }

    loadCategoryData(towerId) {
        this.showSpinner = true;
        getCategoryData({ towerId: towerId })
            .then(result => {
                let nfObject = new Intl.NumberFormat('en-US');
                for (var i = 0; i < result.length; i++) {
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    result[i].collected = nfObject.format(result[i].collected);
                    result[i].due = nfObject.format(result[i].due);
                }
                this.categoryData = result;
                this.showCategoryTable = true;
                this.loadAgeingData(towerId);
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadExecutiveTowerData(towerId) {
        this.showSpinner = true;
        getTowerData({ towerId: towerId })
            .then(result => {
                let nfObject = new Intl.NumberFormat('en-US');
                for (var i = 0; i < result.length; i++) {
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    result[i].collected = nfObject.format(result[i].collected);
                    result[i].due = nfObject.format(result[i].due);
                    for (var j = 0; j < result[i].futureMonthlyDues.length; j++) {
                        result[i].futureMonthlyDues[j] = nfObject.format(result[i].futureMonthlyDues[j]);
                    }
                }
                this.executiveTowerData = result;
                this.showTowerTable = true;
                this.loadCategoryData(towerId);
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadAgeingData(towerId) {
        this.showSpinner = true;
        getAgeingData({ towerId: towerId })
            .then(result => {
                let nfObject = new Intl.NumberFormat('en-US');
                for (var i = 0; i < result.length; i++) {
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    result[i].collected = nfObject.format(result[i].collected);
                    result[i].due = nfObject.format(result[i].due);
                }
                this.ageingData = result;
                this.showAgeingTable = true;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadTargetData() {
        this.showSpinner = true;
        getTargetData()
            .then(result => {
                let nfObject = new Intl.NumberFormat('en-US');
                for (var i = 0; i < result.length; i++) {
                    result[i].target = nfObject.format(result[i].target);
                    result[i].achieved = nfObject.format(result[i].achieved);
                    if (result[i].towerId == 'All') {
                        this.target = result[i].target;
                        this.acheived = result[i].achieved;
                        this.acheivedPercentage = result[i].achievedPercentage;
                    }
                }
                this.targetTabData = result;
                this.loadMonthList();
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    loadBookings(projId, towerId, selectedType) {
        this.showSpinner = true;
        getBookings({ projectId: projId, towerId: towerId, selectedType: selectedType, fromAuditApprovedDate: this.fromAuditApprovedDate, toAuditApprovedDate: this.toAuditApprovedDate })
            .then(result => {
                this.totalUnits = 0.00;
                this.totalSalValue = 0.00;
                this.totalDemandRaised = 0.00;
                this.totalMilestoneDue = 0.00;
                this.totalCollectionAmount = 0.00;
                this.totalOverdueAmount = 0.00;
                this.totalBalance = 0.0;


                //Due follow up
                this.totalUnitsDue = 0;
                this.totalSalValueDue = 0.00;
                this.totalDemandRaisedDue = 0.00;
                this.totalMilestoneDueDue = 0.00;
                this.totalCollectionAmountDue = 0.00;
                this.totalOverdueAmountDue = 0.00;
                this.totalBalanceDue = 0.0;

                //Advance follow up 
                this.totalUnitsAdvance = 0.00;
                this.totalSalValueAdvance = 0.00;
                this.totalDemandRaisedAdvance = 0.00;
                this.totalMilestoneDueAdvance = 0.00;
                this.totalCollectionAmountAdvance = 0.00;
                this.totalOverdueAmountAdvance = 0.00;
                this.totalBalanceAdvance = 0.0;


                let nfObject = new Intl.NumberFormat('en-US');
                let dueFollowUp = [];
                let advanceFollowUp = [];
                for (var i = 0; i < result.length; i++) {


                    if (result[i].category == 'Due Payments') {
                        this.totalUnitsDue += 1;
                        this.totalSalValueDue += result[i].saleValue;
                        this.totalDemandRaisedDue += result[i].demands;
                        this.totalMilestoneDueDue += result[i].milestoneDue;
                        this.totalCollectionAmountDue += result[i].collected;
                        this.totalOverdueAmountDue += result[i].due;
                        this.totalBalanceDue += result[i].fullDue;
                    }
                    else if (result[i].category == 'Advance Payments') {
                        this.totalUnitsAdvance += 1;
                        this.totalSalValueAdvance += result[i].saleValue;
                        this.totalDemandRaisedAdvance += result[i].demands;
                        this.totalMilestoneDueAdvance += result[i].milestoneDue;
                        this.totalCollectionAmountAdvance += result[i].collected;
                        this.totalOverdueAmountAdvance += result[i].due;
                        this.totalBalanceAdvance += result[i].fullDue;
                    }


                    this.totalUnits += 1;
                    this.totalSalValue += result[i].saleValue;
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    this.totalDemandRaised += result[i].demands;
                    result[i].demands = nfObject.format(result[i].demands);
                    this.totalMilestoneDue += result[i].milestoneDue;
                    result[i].milestoneDue = nfObject.format(result[i].milestoneDue);
                    this.totalCollectionAmount += result[i].collected;
                    result[i].collected = nfObject.format(result[i].collected);
                    this.totalOverdueAmount += result[i].due;
                    result[i].due = nfObject.format(result[i].due);
                    this.totalBalance += result[i].fullDue;
                    result[i].fullDue = nfObject.format(result[i].fullDue);
                    if (result[i].bucketColor == 'Amber') {
                        result[i].bucketColor = "background-color:#FFBF00";
                    }
                    else if (result[i].bucketColor == 'Green') {
                        result[i].bucketColor = "background-color:green; color:white;";
                    }
                    else if (result[i].bucketColor == 'Red') {
                        result[i].bucketColor = "background-color:red; color:white;";
                    }
                    else {
                        result[i].bucketColor = "background-color:" + result[i].bucketColor;
                    }

                    if (result[i].category == 'Due Payments') {
                        dueFollowUp.push(result[i]);
                    }
                    else if (result[i].category == 'Advance Payments') {
                        advanceFollowUp.push(result[i]);
                    }
                }
                this.totalSalValue = nfObject.format(this.totalSalValue);
                this.totalDemandRaised = nfObject.format(this.totalDemandRaised);
                this.totalMilestoneDue = nfObject.format(this.totalMilestoneDue);
                this.totalCollectionAmount = nfObject.format(this.totalCollectionAmount);
                this.totalOverdueAmount = nfObject.format(this.totalOverdueAmount);
                this.totalBalance = nfObject.format(this.totalBalance);

                this.totalSalValueDue = nfObject.format(this.totalSalValueDue);
                this.totalDemandRaisedDue = nfObject.format(this.totalDemandRaisedDue);
                this.totalMilestoneDueDue = nfObject.format(this.totalMilestoneDueDue);
                this.totalCollectionAmountDue = nfObject.format(this.totalCollectionAmountDue);
                this.totalOverdueAmountDue = nfObject.format(this.totalOverdueAmountDue);
                this.totalBalanceDue = nfObject.format(this.totalBalanceDue);

                this.totalSalValueAdvance = nfObject.format(this.totalSalValueAdvance);
                this.totalDemandRaisedAdvance = nfObject.format(this.totalDemandRaisedAdvance);
                this.totalMilestoneDueAdvance = nfObject.format(this.totalMilestoneDueAdvance);
                this.totalCollectionAmountAdvance = nfObject.format(this.totalCollectionAmountAdvance);
                this.totalOverdueAmountAdvance = nfObject.format(this.totalOverdueAmountAdvance);
                this.totalBalanceAdvance = nfObject.format(this.totalBalanceAdvance);

                this.bookingData = result;
                this.tempBookingData = result;
                this.dueFollowUpBookingData = dueFollowUp;
                this.tempDueFollowUpBookingData = dueFollowUp;
                this.advanceFollowUpBookingData = advanceFollowUp;
                this.tempAdvanceFollowUpBookingData = advanceFollowUp;
                this.validationForRemark = [];
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    updateBooking(category, bookingId, taskId, dueOrAdvanceAmount) {
        updateLastActionOnBooking({ category: category, bookingId: bookingId, taskId: taskId, dueOrAdvanceAmount: String(dueOrAdvanceAmount) })
            .then(result => {
                if (this.isCategories) {
                    if (this.selectedTaskCategory != '')
                        this.loadBookings(this.selectedProject, this.selectedTower, this.selectedTaskCategory);
                }
                else {
                    this.loadBookings(this.selectedProject, this.selectedTower, this.selectedType);
                }
                this.sendEmailToPrimaryApplicant(bookingId);
            })
            .catch(error => {
            });
    }

    get options() {
        return [

            { label: 'DLD Dashboard 1', value: 'Dashboard1' },
            { label: 'DLD Dashboard 2', value: 'Dashboard2' },
            { label: 'DLD Dashboard 3', value: 'Dashboard3' },
        ];
    }

    get tablefilteroptions() {
        return [

            { label: 'All', value: 'All' },
            { label: 'Final Notice Received(35 days after received)', value: '35days' },
            { label: 'Final Notice Not Received(30 days after sent) ', value: '30days' },
        ];
    }

    handleProjectChange(event) {
        this.selectedTower = '';
        this.bookingData = [];
        this.tempBookingData = [];
        this.tempDueFollowUpBookingData = [];
        this.tempAdvanceFollowUpBookingData = [];
        this.dueFollowUpBookingData = [];
        this.advanceFollowUpBookingData = [];
        this.toweroptions = [];
        this.selectedProject = event.detail.value;
        if(event.detail.value == 'All'){
            this.loadBookings(event.detail.value, null, this.selectedType);
        }else{
            this.loadTowers(event.detail.value);
        }
    }

    handleTowerChange(event) {
        this.bookingData = [];
        this.tempBookingData = [];
        this.tempDueFollowUpBookingData = [];
        this.tempAdvanceFollowUpBookingData = [];
        this.dueFollowUpBookingData = [];
        this.advanceFollowUpBookingData = [];
        this.selectedTower = event.detail.value;
        if (this.isCategories) {
            if (this.selectedTaskCategory != '')
                this.loadBookings(this.selectedProject, event.detail.value, this.selectedTaskCategory);
        }
        else {
            this.loadBookings(this.selectedProject, event.detail.value, this.selectedType);
        }
    }

    handleTypeChange(event) {
        this.totalUnits = 0.00;
        this.totalSalValue = 0.00;
        this.totalDemandRaised = 0.00;
        this.totalMilestoneDue = 0.00;
        this.totalCollectionAmount = 0.00;
        this.totalOverdueAmount = 0.00;
        this.totalBalance = 0.0;


        //Due follow up
        this.totalUnitsDue = 0;
        this.totalSalValueDue = 0.00;
        this.totalDemandRaisedDue = 0.00;
        this.totalMilestoneDueDue = 0.00;
        this.totalCollectionAmountDue = 0.00;
        this.totalOverdueAmountDue = 0.00;
        this.totalBalanceDue = 0.0;

        //Advance follow up 
        this.totalUnitsAdvance = 0.00;
        this.totalSalValueAdvance = 0.00;
        this.totalDemandRaisedAdvance = 0.00;
        this.totalMilestoneDueAdvance = 0.00;
        this.totalCollectionAmountAdvance = 0.00;
        this.totalOverdueAmountAdvance = 0.00;
        this.totalBalanceAdvance = 0.0;

        let type = event.detail.value;
        this.dashboardTypeValue = type;
        //alert(type);
        this.showSection = false;
        this.bookingData = [];
        this.tempBookingData = [];
        this.tempDueFollowUpBookingData = [];
        this.tempAdvanceFollowUpBookingData = [];
        this.dueFollowUpBookingData = [];
        this.advanceFollowUpBookingData = [];
        this.selectedType = type;
        this.selectedTaskCategory = 'All';
        this.categoryData = [];
        this.ageingData = [];
        this.targetTabData = [];

        this.isDashboard1 = (type == 'Dashboard1') ? true : false;
        this.isDashboard2 = (type == 'Dashboard2') ? true : false;
        this.isDashboard3 = (type == 'Dashboard3') ? true : false;

        this.showSection = true;
        this.loadBookings(this.selectedProject, this.selectedTower, type);
        this.showSearch = true;

        if (this.isDashboard2 || this.isDashboard3) {
            this.fromAuditApprovedDate = null;
            this.toAuditApprovedDate = null;
        }

        /*if (this.isFollowUp || this.isDue || this.isAdvance || this.isCategories || this.isGrossAll) {
            if (this.selectedProject != '' && this.selectedTower != '') {
                if (this.isCategories)
                    this.loadBookings(this.selectedProject, this.selectedTower, this.selectedTaskCategory);
                else
                    this.loadBookings(this.selectedProject, this.selectedTower, this.selectedType);
            }
            this.showSection = true;
            this.showSearch = true;
        }
        else if (this.isExecutive) {
            this.showSection = false;
            this.showSearch = false;
            this.target = null;
            this.acheived = null;
            this.acheivedPercentage = null;
            this.categoryData = [];
            this.ageingData = [];
            this.executiveTowerData = [];
            this.showCategoryTable = false;
            this.showAgeingTable = false;
            this.showTowerTable = false;
            this.selectedTowerInExecutive = 'All';
            this.loadTargetData();
        }
        else {
            this.showSection = false;
            this.showSearch = false;
        }*/
    }

    handleTaskCategoryChange(event) {
        this.selectedTaskCategory = event.detail.value;
        if (this.selectedProject != '' && this.selectedTower != '') {
            this.loadBookings(this.selectedProject, this.selectedTower, event.detail.value);
        }
    }

    handleCategoryChange(event) {
        this.hideAllFields();
        let category = event.detail.value;
        this.selectedCategory = category;
        if (category == 'PTP') {
            this.showPTPDate = true;
            this.showAmount = true;
            this.showFollowUpDate = true;
        }
        else if (category == 'Regular Follow Up') {
            this.makeFollowUpDateReq = true;
            this.showFollowUpDate = true;
        }
        else if (category == 'Mortgage') {
            this.makeAmountReq = true;
            this.makeBankNameReq = true;
            this.makeValueationReq = true;
            this.showAmount = true;
            this.showBankName = true;
            this.showValuation = true;
        }
        else if (category == 'Unable to Pay') {
            this.showReasonForUnableToPay = true;
        }
        else if (category == 'Customer Interested') {
            this.showCustomerInterested = true;
        }
        else if (category == 'Unable to contact / Customer not responding') {
            this.showLastContactedDate = true;
        }
    }

    onDiscountAmountChange(event) {
        let discountAmount = event.detail.value;
        let saleValue = this.selectedBookingSaleValue;
        saleValue = saleValue.replace(/,/g, '');
        saleValue = parseInt(saleValue);
        this.discountPercentage = (discountAmount / saleValue);
    }

    onCustomerInterestedChange(event) {
        if (event.detail.value == 'Yes') {
            this.showAmountToBePaidInAdv = true;
            this.showDiscountAmount = true;
            this.showDiscountOnSale = true;
            this.showExpectedDateOfPayment = true;
            this.discountPercentage = null;
        }
        else {
            this.showAmountToBePaidInAdv = false;
            this.showDiscountAmount = false;
            this.showDiscountOnSale = false;
            this.showExpectedDateOfPayment = false;
        }
    }

    onValuationChange(event) {
        if (event.detail.value == 'Yes') {
            this.showMortgageOfferLetter = true;
        }
        else {
            this.showMortgageOfferLetter = false;
            this.showExpectedDateOfReceivingCheque = false;
        }
    }

    onMortgageOfferLetterChange(event) {
        if (event.detail.value == 'Yes') {
            this.showExpectedDateOfReceivingCheque = true;
        }
        else {
            this.showExpectedDateOfReceivingCheque = false;
        }
    }

    hideAllFields() {
        this.showAmount = false;
        this.showAmountToBePaidInAdv = false;
        this.showBankName = false;
        this.showDiscountOnSale = false;
        this.showDiscountAmount = false;
        this.showExpectedDateOfReceivingCheque = false;
        this.showExpectedDateOfPayment = false;
        this.showFollowUpDate = false;
        this.showMortgageOfferLetter = false;
        this.showPTPDate = false;
        this.showReasonForUnableToPay = false;
        this.showValuation = false;
        this.showCustomerInterested = false;
        this.makeAmountReq = false;
        this.makeFollowUpDateReq = false;
        this.makeBankNameReq = false;
        this.makeValueationReq = false;
        this.showLastContactedDate = false;
    }

    closeModal() {
        this.isModalOpen = false;
        this.isModalOpenCallLog = false;
    }

    closeCancelProcessModal() {
        this.isCancelTheProcessOpen = false;
    }


    handleSubmit(event) {
        event.preventDefault();
        if (this.selectedCategory != '') {
            const fields = event.detail.fields;
            var today = new Date();
            var lastContactedDate = new Date(this.lastContactedDate);
            if (lastContactedDate > today) {
                return;
            }
            else {
                fields.Last_Contacted_Date__c = this.lastContactedDate;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.isModalOpen = false;
            this.isModalOpenCallLog = false;
        }
        else {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please select Category.',
            });
            this.dispatchEvent(evt);
        }
    }

    onPTPDateChange(event) {
        let ptpDate = event.detail.value;
        if (ptpDate) {
            this.makeAmountReq = true;
            this.makeFollowUpDateReq = true;
        } else {
            this.makeAmountReq = false;
            this.makeFollowUpDateReq = false;
        }
    }

    handleSuccess(event) {
        const taskId = event.detail.id;
        const evt = new ShowToastEvent({
            variant: 'success',
            message: 'Task created successfully!',
        });
        this.dispatchEvent(evt);
        this.updateBooking(this.categoryOfSelectedRow, this.selectedBookingId, taskId, this.selectedDueOrAdvanceAmount);
    }

    callFilteredBookings(color) {
        this.showSpinner = true;
        this.bookingData = [];
        getBookingsByBucket({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.selectedType, bucketColor: color })
            .then(result => {
                this.totalUnits = 0.00;
                this.totalSalValue = 0.00;
                this.totalDemandRaised = 0.00;
                this.totalMilestoneDue = 0.00;
                this.totalCollectionAmount = 0.00;
                this.totalOverdueAmount = 0.00;
                this.totalBalance = 0.0;
                let nfObject = new Intl.NumberFormat('en-US');
                let dueFollowUp = [];
                let advanceFollowUp = [];
                for (var i = 0; i < result.length; i++) {
                    this.totalUnits += 1;
                    this.totalSalValue += result[i].saleValue;
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    this.totalDemandRaised += result[i].demands;
                    result[i].demands = nfObject.format(result[i].demands);
                    this.totalMilestoneDue += result[i].milestoneDue;
                    result[i].milestoneDue = nfObject.format(result[i].milestoneDue);
                    this.totalCollectionAmount += result[i].collected;
                    result[i].collected = nfObject.format(result[i].collected);
                    this.totalOverdueAmount += result[i].due;
                    result[i].due = nfObject.format(result[i].due);
                    this.totalBalance += result[i].fullDue;
                    result[i].fullDue = nfObject.format(result[i].fullDue);
                    if (result[i].bucketColor == 'Amber') {
                        result[i].bucketColor = "background-color:#FFBF00";
                    }
                    else if (result[i].bucketColor == 'Green') {
                        result[i].bucketColor = "background-color:green; color:white;";
                    }
                    else if (result[i].bucketColor == 'Red') {
                        result[i].bucketColor = "background-color:red; color:white;";
                    }
                    else {
                        result[i].bucketColor = "background-color:" + result[i].bucketColor;
                    }
                    if (result[i].category == 'Due Payments') {
                        dueFollowUp.push(result[i]);
                    }
                    else if (result[i].category == 'Advance Payments') {
                        advanceFollowUp.push(result[i]);
                    }
                }
                this.totalSalValue = nfObject.format(this.totalSalValue);
                this.totalDemandRaised = nfObject.format(this.totalDemandRaised);
                this.totalMilestoneDue = nfObject.format(this.totalMilestoneDue);
                this.totalCollectionAmount = nfObject.format(this.totalCollectionAmount);
                this.totalOverdueAmount = nfObject.format(this.totalOverdueAmount);
                this.totalBalance = nfObject.format(this.totalBalance);
                this.bookingData = result;
                this.tempBookingData = result;
                this.dueFollowUpBookingData = dueFollowUp;
                this.tempDueFollowUpBookingData = dueFollowUp;
                this.advanceFollowUpBookingData = advanceFollowUp;
                this.tempAdvanceFollowUpBookingData = advanceFollowUp;
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('error:', error);
            });
    }

    handleGreenBucket() {
        this.callFilteredBookings('Green');
    }
    handleYellowBucket() {
        this.callFilteredBookings('Yellow');
    }
    handleAmberBucket() {
        this.callFilteredBookings('Amber');
    }
    handleRedBucket() {
        this.callFilteredBookings('Red');
    }
    handleWhiteBucket() {
        this.callFilteredBookings('White');
    }

    handleAllBucket() {
        console.log(this.selectedProject);
        console.log(this.selectedTower);
        console.log(this.selectedTaskCategory);
        this.loadBookings(this.selectedProject, this.selectedTower, this.selectedType);
    }

    search(event) {
        var searchText = event.detail.value;
        if (this.isDue || this.isAdvance || this.isGrossAll) {
            var bookingData = this.tempBookingData;
            var filteredBooking = [];
            if (searchText != '') {
                searchText = searchText.toLowerCase();
                for (var i = 0; i < bookingData.length; i++) {
                    var unit = bookingData[i].unitName;
                    unit = (unit != null && unit != undefined) ? unit.toLowerCase() : '';
                    var bookingId = bookingData[i].bookingName;
                    bookingId = (bookingId != null && bookingId != undefined) ? bookingId.toLowerCase() : '';
                    var customerName = bookingData[i].customerName;
                    customerName = (customerName != null && customerName != undefined) ? customerName.toLowerCase() : '';
                    if ((unit != null && unit.includes(searchText)) || (bookingId != null && bookingId.includes(searchText)) || (customerName != null && customerName.includes(searchText))) {
                        filteredBooking.push(bookingData[i]);
                    }
                }
                this.bookingData = filteredBooking;
            }
            else {
                this.bookingData = this.tempBookingData;
            }
        }
        else if (this.isFollowUp || this.isCategories) {
            var dueFollowUpBookingData = this.tempDueFollowUpBookingData;
            var dueFilteredBooking = [];
            if (searchText != '') {
                searchText = searchText.toLowerCase();
                for (var i = 0; i < dueFollowUpBookingData.length; i++) {
                    var unit = dueFollowUpBookingData[i].unitName;
                    unit = (unit != null && unit != undefined) ? unit.toLowerCase() : '';
                    var bookingId = dueFollowUpBookingData[i].bookingName;
                    bookingId = (bookingId != null && bookingId != undefined) ? bookingId.toLowerCase() : '';
                    var customerName = dueFollowUpBookingData[i].customerName;
                    customerName = (customerName != null && customerName != undefined) ? customerName.toLowerCase() : '';
                    if ((unit != null && unit.includes(searchText)) || (bookingId != null && bookingId.includes(searchText)) || (customerName != null && customerName.includes(searchText))) {
                        dueFilteredBooking.push(dueFollowUpBookingData[i]);
                    }
                }
                this.dueFollowUpBookingData = dueFilteredBooking;
            }
            else {
                this.dueFollowUpBookingData = this.tempDueFollowUpBookingData;
            }

            var advanceFollowUpBookingData = this.tempAdvanceFollowUpBookingData;
            var advanceFilteredBooking = [];
            if (searchText != '') {
                searchText = searchText.toLowerCase();
                for (var i = 0; i < advanceFollowUpBookingData.length; i++) {
                    var unit = advanceFollowUpBookingData[i].unitName;
                    unit = (unit != null && unit != undefined) ? unit.toLowerCase() : '';
                    var bookingId = advanceFollowUpBookingData[i].bookingName;
                    bookingId = (bookingId != null && bookingId != undefined) ? bookingId.toLowerCase() : '';
                    var customerName = advanceFollowUpBookingData[i].customerName;
                    customerName = (customerName != null && customerName != undefined) ? customerName.toLowerCase() : '';
                    if ((unit != null && unit.includes(searchText)) || (bookingId != null && bookingId.includes(searchText)) || (customerName != null && customerName.includes(searchText))) {
                        advanceFilteredBooking.push(advanceFollowUpBookingData[i]);
                    }
                }
                this.advanceFollowUpBookingData = advanceFilteredBooking;
            }
            else {
                this.advanceFollowUpBookingData = this.tempAdvanceFollowUpBookingData;
            }
        }
    }

    handleAllocationChange(event) {
        let allocationValue = event.detail.value;
        let bId = event.currentTarget.id;
        bId = bId.split('-')[0];
        bId = bId.split('/')[1];
        updateAllocation({ bookingId: bId, allocation: allocationValue })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Update notification',
                    message: 'Allocation updated successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Allocation notification',
                    message: 'Error updating allocation',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });

    }

    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log(dataRecieved.label);
        let updatedItem = { bookingId: dataRecieved.context, value: dataRecieved.value, label: dataRecieved.label };
        console.log(updatedItem);

        let rows = [];
        rows.push(updatedItem);
        if (dataRecieved.value == 'Allocate to Collection Team') {
            this.showSpinner = true;
            console.log('Return to collection');
            let isCommentChange = false;
            this.validationForRemark.forEach(each => {
                if (each.bookingId == updatedItem.bookingId) {
                    console.log('Matched done');
                    isCommentChange = true;
                    return true;
                }
            });
            if (isCommentChange == true) {
                returnToCollections({ bookingId: dataRecieved.context }).then(result => {
                    console.log(result);
                    if (result == true) {
                        this.showSpinner = false;
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: 'Returned to collection successfully',
                        });
                        this.dispatchEvent(evt);
                        this.draftValues = [];
                        getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue }).then(result => {
                            console.log(result);
                            this.showSpinner = false;
                            if (result) {
                                this.bookingData = result;
                                this.draftValues = [];
                            }
                        }).catch(error => {this.showSpinner = false;});
                        return;
                    }

                }).catch(error => {
                    console.log('error==', error);
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: 'Some error occured, please try again.',
                    });
                    this.dispatchEvent(evt);
                    this.draftValues = [];
                    this.showSpinner = false;
                    return;

                });
            }else{
                console.log('Matched Else');
                const evt = new ShowToastEvent({
                    variant: 'error',
                    title: 'Please add some remark before Allocate to Collection Team',
                    message: 'cannot action without remarks. Please add remarks in termination remark section!',
                });
                this.dispatchEvent(evt);
                console.log('loading bookings again');
                this.bookingData = [];
                getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue }).then(result => {
                    if (result) {
                        this.bookingData = result;
                        this.draftValues = [];
                    }
                    this.showSpinner = false;
                }).catch(error => { this.showSpinner = false; });
            }

        } else {
            updateBookingRow({ row: JSON.stringify(rows), canceltheprocess: false, ispicklist: true })
                .then(result => {
                    console.log(result);
                    if (result) {
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: 'Updated successfully!',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .then(() => {

                    console.log('loading bookings again');
                    getBookings({ projectId: this.selectedProject, towerId: this.selectedTower, selectedType: this.dashboardTypeValue })
                        .then(result => {
                            console.log(result);
                            if (result) {
                                this.bookingData = result;
                                this.draftValues = [];
                            }
                        })
                        .catch(error => {
                        });
                })
                .catch(error => {
                });
        }
    }

    sendBankDetailsEmail(event) {
        let uId = event.currentTarget.id;
        uId = uId.split('-')[0];
        uId = uId.split('/')[1];
        //alert(uId);

        sendBankEmail({ unitId: uId })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Bank details notification',
                    message: 'Bank details mail sent successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Bank details notification',
                    message: 'Error sending Bank details mail',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });


    }

    handleFilterChange(event) {
        console.log('event detail: ' + JSON.stringify(event.detail));
        console.log('event target : ' + JSON.stringify(event.target.name));
        if (event.target.name == 'toAuditApprovedDate') {
            this.toAuditApprovedDate = event.detail.value;
        } else if (event.target.name == 'fromAuditApprovedDate') {
            this.fromAuditApprovedDate = event.detail.value;
        }
        if (this.toAuditApprovedDate && this.fromAuditApprovedDate) {
            this.bookingData = [];
            this.tempBookingData = [];
            this.tempDueFollowUpBookingData = [];
            this.tempAdvanceFollowUpBookingData = [];
            this.dueFollowUpBookingData = [];
            this.advanceFollowUpBookingData = [];
            if (this.isCategories) {
                if (this.selectedTaskCategory != '')
                    this.loadBookings(this.selectedProject, this.selectedTower, this.selectedTaskCategory);
            }
            else {
                this.loadBookings(this.selectedProject, this.selectedTower, this.selectedType);
            }
        }
    }

}