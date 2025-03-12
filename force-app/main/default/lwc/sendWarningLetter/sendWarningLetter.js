import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBookings from '@salesforce/apex/SendWarningLetterController.getBookings'
import getTowers from '@salesforce/apex/SendWarningLetterController.getTowers'
import sendWarningLetter from '@salesforce/apex/SendWarningLetterController.sendWarningLetter'

export default class SendWarningLetter extends NavigationMixin(LightningElement) {
    @track bookingData = [];
    @track selectedTower = 'All';
    showSpinner = false;
    allTowers = [];
    bookingIdToName;

    connectedCallback() {
        this.loadTowers();
        this.loadBookings(this.selectedTower);
    }

    onTowerChange(event) {
        this.selectedTower = event.target.value;
        this.loadBookings(this.selectedTower);
    }

    handleSelectAll(event) {
        var bookings = this.bookingData;
        for (var i = 0; i < bookings.length; i++) {
            bookings[i].checked = event.detail.checked;
        }
        this.bookingData = bookings;
    }

    onSelectChange(event) {
        var bookings = this.bookingData;
        for (var i = 0; i < bookings.length; i++) {
            if (event.currentTarget.value == bookings[i].bookingId) {
                bookings[i].checked = event.detail.checked;
            }
        }
        this.bookingData = bookings;
    }

    handleSelectedBooking(event) {
        var bookings = this.bookingData;
        var bookingIds = [];
        for (var i = 0; i < bookings.length; i++) {
            if (bookings[i].checked) {
                bookingIds.push(bookings[i].bookingId);
            }
        }
        if (bookingIds.length > 0) {
            this.doSendWarning(bookingIds);
        }
        else {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please select a booking.',
            });
            this.dispatchEvent(evt);
        }
    }

    loadTowers() {
        getTowers()
            .then(result => {
                let towers = [];
                towers.push({ label: 'All', value: 'All' });
                for (var i = 0; i < result.length; i++) {
                    var towerObj = { label: result[i].Name, value: result[i].Id };
                    towers.push(towerObj);
                }
                this.allTowers = towers;
            })
            .catch(error => {
            });
    }

    loadBookings(towerId) {
        this.showSpinner = true;
        this.bookingData = [];
        getBookings({ towerId: towerId })
            .then(result => {
                this.showSpinner = false;
                let nfObject = new Intl.NumberFormat('en-US');
                var bookingIdToNameMap = new Map();
                for (var i = 0; i < result.length; i++) {
                    result[i].saleValue = nfObject.format(result[i].saleValue);
                    result[i].overdue = nfObject.format(result[i].overdue);
                    bookingIdToNameMap.set(result[i].bookingId, result[i].bookingName);
                }
                this.bookingData = result;
                this.bookingIdToName = bookingIdToNameMap;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    doSendWarning(bookingIds) {
        this.showSpinner = true;
        var bookingIdToNameMap = this.bookingIdToName;
        if (bookingIds.length > 0) {
            var bookingId = bookingIds[0];
            bookingIds.shift();
            sendWarningLetter({ bookingId: bookingId })
                .then(result => {
                    if (result == 'SUCCESS') {
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: bookingIdToNameMap.get(bookingId) + ' : Warning Letter has been sent successfully!',
                        });
                        this.dispatchEvent(evt);
                        this.doSendWarning(bookingIds);
                    }
                    else {
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: bookingIdToNameMap.get(bookingId) + ' : ' + result,
                        });
                        this.dispatchEvent(evt);
                        this.doSendWarning(bookingIds);
                    }
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: bookingIdToNameMap.get(bookingId) + ' : Error Occured.',
                    });
                    this.dispatchEvent(evt);
                    this.doSendWarning(bookingIds);
                });
        }
        else {
            this.loadBookings(this.selectedTower);
            this.showSpinner = false;
        }
    }

    sendWarning(event) {
        var bookingId = event.target.id;
        bookingId = bookingId.split('-')[0];
        var bookingIds = [];
        bookingIds.push(bookingId);
        this.doSendWarning(bookingIds);
    }
}