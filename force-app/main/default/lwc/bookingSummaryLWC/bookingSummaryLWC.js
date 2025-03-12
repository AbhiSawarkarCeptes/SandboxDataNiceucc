import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchBookingAsPerFilter from '@salesforce/apex/BookingSummaryVFController.searchBookingAsPerFilter';
import searchBookingsRecord from '@salesforce/apex/BookingSummaryVFController.searchBookingsRecord';
import searchUnitRecord from '@salesforce/apex/BookingSummaryVFController.searchUnitRecord';
import searchCustomerRecord from '@salesforce/apex/BookingSummaryVFController.searchCustomerRecord';
const columns = [
    { label: 'Booking', fieldName: 'Name', type: 'text'},
    { label: 'Booking Date', fieldName: 'PropStrength__Booking_Date__c', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: '2-digit' }},
    { label: 'Unit No.', fieldName: 'House_Unit_No__c', type: 'text'},
    { label: 'Primary Customer', fieldName: 'PrimaryCustomerName'},
    {
        type: 'button',
        
        typeAttributes: {
            label: 'View Details',
            name: 'viewDetail',
            title: 'View Details',
            disabled: false,
            value: 'viewDetail',
            iconPosition: 'center'
        }
    }
];
/*
const columns = [
    { label: 'Project', fieldName: 'PropStrength__Project__c', type: 'url', typeAttributes: { label: { fieldName: 'Project_Name__c' }, target: '_blank' }, initialWidth: 150},
    { label: 'Tower', fieldName: 'TowerName', type: 'url', typeAttributes: { label: { fieldName: 'PropStrength__Tower__c' }, target: '_blank' }, initialWidth: 150},
    { label: 'Completion Certificate Received', fieldName: 'CompletionCertificateReceived', type: 'boolean', initialWidth: 150},
    { label: 'Offer', fieldName: 'PropStrength__Offer__c', type: 'url', typeAttributes: { label: { fieldName: 'OfferName' }, target: '_blank' }, initialWidth: 150 },
    { label: 'Booking', fieldName: 'Id', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, initialWidth: 150 },
    { label: 'Booking Date', fieldName: 'PropStrength__Booking_Date__c', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: '2-digit' }, initialWidth: 150 },
    { label: 'Unit No.', fieldName: 'House_Unit_No__c', type: 'text', initialWidth: 150 },
    { label: 'Property type', fieldName: 'PropStrength__Property_Type_Code__c', type: 'text', initialWidth: 150 },
    { label: 'Primary Customer', fieldName: 'PropStrength__Primary_Customer__c', type: 'url', typeAttributes: { label: { fieldName: 'PrimaryCustomerName' }, target: '_blank' }, initialWidth: 150 },
    { label: 'Status', fieldName: 'PropStrength__Status__c', type: 'text', initialWidth: 150 },
    { label: 'Total Area', fieldName: 'PropStrength__Super_Area__c', type: 'text', initialWidth: 150 },
    { label: 'Total Payment Due', fieldName: 'PropStrength__Total_Payment_Due__c',  type: 'text', cellAttributes: { alignment: 'left' }, initialWidth: 150 },
    { label: 'Total Payment Received', fieldName: 'PropStrength__Total_Payment_Received__c', type: 'text', cellAttributes: { alignment: 'left' }, initialWidth: 150 },
    { label: 'Oqood Fees Received', fieldName: 'Oqood_Fees_Received__c', type: 'boolean', initialWidth: 150},
    { label: 'Oqood Fees Amount', fieldName: 'Oqood_Fees_Amount__c', type: 'text', cellAttributes: { alignment: 'left' }, initialWidth: 150 },
    { label: 'Booking Form Signed Date', fieldName: 'Booking_Form_Signed_Date__c', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: '2-digit' }, initialWidth: 150},
    { label: 'Booking Form Executed', fieldName: 'Booking_Form_Executed__c', type: 'boolean', initialWidth: 150},
    { label: 'SPA Executed', fieldName: 'SPA_Executed__c', type: 'boolean', initialWidth: 150},
    { label: 'MOU Executed', fieldName: 'MOU_Executed__c', type: 'boolean', initialWidth: 150},
    { label: 'MOU Execution Date', fieldName: 'MOU_Execution_Date__c', type: 'date', typeAttributes: { year: 'numeric', month: 'short', day: '2-digit' }, initialWidth: 150 },
    { label: 'DSPA Executed', fieldName: 'DSPA_Executed__c', type: 'boolean', initialWidth: 150},
    { label: 'PCC Status', fieldName: 'PCC_Status__c', type: 'text', initialWidth: 150},
    { label: 'Pre-Registration Completed', fieldName: 'Pre_Registration_Completed__c', type: 'boolean', initialWidth: 150},
    { label: 'Termination Process Status', fieldName: 'Termination_Process_Status__c', type: 'text', initialWidth: 150 },
    { label: 'Handover Completed', fieldName: 'Handover_Completed__c', type: 'boolean', initialWidth: 150},
];
*/

export default class BookingSummaryLWC extends LightningElement {
    @track bookingList = [];
    columns = columns;
    @track searchKeyBooking = '';
    @track searchKeyUnit = '';
    @track searchKeyCustomer = '';
    @track searchResultsBooking = [];
    @track searchResultsUnit = [];
    @track showResultsBooking = false;
    @track showResultsUnit = false;
    @track showResultsCustomer = false;
    @track showRecordDetail = false;
    @track showDataTable = false;
    @track showSpinner = false;
    @track searchBook = '';
    @track searchUnit = '';
    @track searchCustomer = '';
    @track bookingRec;
    bookingMap = new Map();
    bookingId = '';

    @wire(searchBookingAsPerFilter)
    wiredBookingList({ error, data }) {
        if (data) {
            console.log(data);
            this.bookingList = data.map(booking => {
                const mappedBooking = {
                    ...booking,
                    Id: booking.Id,
                    PrimaryCustomerName: booking.PropStrength__Primary_Customer__r.Name,
                    PropStrength__Primary_Customer__c: booking.PropStrength__Primary_Customer__c,
                };
                return mappedBooking;
            });
            data.forEach((element) => {
                console.log('----->',element);
            });
            this.searchCustomerRec();
            this.searchUnitRec();
            this.searchBookingsRec();
            this.showDataTable = true;
        } else if (error) {
            this.showToast('Error', 'An error occurred while fetching data', 'error');
        }
    }

    formatCurrency(value) {
        if (typeof value === 'number') {
            return value.toLocaleString('en-US', { minimumFractionDigits: 2 });
        }
        return value;
    }

    searchBookings() {
        this.showSpinner = true;
        searchBookingAsPerFilter({
                bookingName: this.searchBook,
                unitName : this.searchUnit,
                customerName : this.searchCustomer
            }).then(result => {
                if (result) {
                    console.log('in search bookings');
                    console.log(result);
                    this.bookingList = result.map(booking => {
                        const mappedBooking = {
                            ...booking,
                            Id: booking.Id,
                            PrimaryCustomerName: booking.PropStrength__Primary_Customer__r.Name,
                            PropStrength__Primary_Customer__c: booking.PropStrength__Primary_Customer__c
                        };
                        return mappedBooking;
                    });
                    result.forEach((element) => {
                        this.bookingMap.set(element.Id, element);
                        console.log('----->',element);
                    });
                    console.log('----->',this.bookingMap);
                    this.showDataTable = true;
                }
                this.showSpinner = false;
            })
                .catch(error => {
                    this.showToast('Error', 'An error occurred while fetching data', 'error');
                    this.showSpinner = false;
                });
    }


    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handleSearchKeyChangeBooking(event) {
        this.searchKeyBooking = event.target.value;
        this.showResultsBooking = true;
        if (this.searchKeyBooking.length == 0 || this.searchKeyBooking == undefined) {
            this.searchKeyBooking = '';
            this.searchBook = '';
            this.showResultsBooking = false;
            console.log('OnChange smthod callled');
            this.showDataTable = false;
           this.searchBookings();
        } else {
            this.searchBookingsRec();
        }
    }

    searchBookingsRec() {
        this.showSpinner = true;
        searchBookingsRecord({
            searchKeyWrd: this.searchKeyBooking
        }).then(result => {
            this.searchResultsBooking = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }

    handleResultClickBooking(event) {
        this.searchBook = event.target.dataset.id;
        this.searchKeyBooking = event.target.dataset.id;
        this.showResultsBooking = false;
        console.log(this.searchBook);
        this.searchBookings();
    }

    showDialogBooking() {
        this.showResultsBooking = true;
        this.searchBookingsRec();
    }
    handleBookingClose() {
        this.showResultsBooking = false;
    }
    handleSearchKeyChangeUnit(event) {
        this.searchKeyUnit = event.target.value;
        this.showResultsUnit = true;
        if (this.searchKeyUnit.length == 0 || this.searchKeyUnit == undefined) {
            this.searchKeyUnit = '';
            this.searchUnit = '';
            this.showResultsUnit = false;
            this.showDataTable = false;
            console.log('OnChange smthod callled');
           this.searchBookings();
        } else {
            this.searchUnitRec();
        }
    }

    showDialogUnit() {
        this.showResultsUnit = true;
        this.searchUnitRec();
    }
    handleUnitClose() {
        this.showResultsUnit = false;
    }
    handleResultClickUnit(event) {
        this.searchUnit = event.target.dataset.id;
        this.searchKeyUnit = event.target.dataset.id;
        this.showResultsUnit = false;
        console.log(this.searchUnit);
        this.searchBookings();
    }
    searchUnitRec() {
        this.showSpinner = true;
        searchUnitRecord({
            searchKeyWrd: this.searchKeyUnit
        }).then(result => {
            this.searchResultsUnit = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }
    handleSearchKeyChangeCustomer(event) {
        this.searchKeyCustomer = event.target.value;
        this.showResultsCustomer = true;
        if (this.searchKeyCustomer.length == 0 || this.searchKeyCustomer == undefined) {
            this.searchKeyCustomer = '';
            this.searchCustomer = '';
            this.showResultsCustomer = false;
            this.showDataTable = false;
           this.searchBookings();
        } else {
            this.searchCustomerRec();
        }
    }
    showDialogCustomer() {
        this.showResultsCustomer = true;
        this.searchCustomerRec();
    }
    handleCustomerClose() {
        this.showResultsCustomer = false;
    }
    handleResultClickCustomer(event) {
        this.searchCustomer = event.target.dataset.id;
        this.searchKeyCustomer = event.target.dataset.id;
        this.showResultsCustomer = false;
        this.searchBookings();
    }
    searchCustomerRec() {
        this.showSpinner = true;
        searchCustomerRecord({
            searchKeyWrd: this.searchKeyCustomer
        }).then(result => {
            this.searchResultsCustomer = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        this.showSpinner = true;
        switch (action.name) {
            case 'viewDetail':
                this.handleEdit(row);
                break;
            // Add more cases for other actions if needed
            default:
                break;
        }
    }

    handleEdit(row) {
        this.bookingId = row.Id;
        console.log('Edit clicked for: ', this.bookingMap.get(this.bookingId));
        this.showRecordDetail = true;
        this.bookingRec = this.bookingMap.get(this.bookingId);
    }
    hideModalBox() {
        this.showRecordDetail = false;
    }
    handleLoad(){
        this.showSpinner = false;
        console.log('---->Loading complete');
    }
}