import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBookings from '@salesforce/apex/LatePenaltyController.getBookings';
import getProjects from '@salesforce/apex/CollectionDashboardController.getProjects';
import calculateLatePayment from '@salesforce/apex/LatePenaltyController.calculateLatePayment';
import raiseDemand from '@salesforce/apex/LatePenaltyController.raiseDemand';

export default class LatePenalty extends NavigationMixin(LightningElement) {
    @track bookings = [];
    @track isDataLoaded = false;
    showSpinner = false;
    @track selectedTower = 'All';
    allTowers = [];
    bookingIdToName;

    connectedCallback() {
        this.loadTowers();
        this.loadBooking(this.selectedTower);
    }

    onSelectChange(event) {
        var bookings = this.bookings;
        for (var i = 0; i < bookings.length; i++) {
            if (event.currentTarget.value == bookings[i].bookingId) {
                bookings[i].checked = event.detail.checked;
            }
        }
        this.bookings = bookings;
    }

    handleSelectAll(event) {
        var bookings = this.bookings;
        for (var i = 0; i < bookings.length; i++) {
            bookings[i].checked = event.detail.checked;
        }
        this.bookings = bookings;
    }

    onTowerChange(event) {
        this.selectedTower = event.detail.value;
        this.loadBooking(this.selectedTower);
    }

    handleCalculate(event) {
        var bookingId = event.currentTarget.id;
        bookingId = bookingId.split('-')[0];
        var bookingIds = [];
        bookingIds.push(bookingId);
        this.doCalculateLPC(bookingIds);
    }

    handleRaise(event) {
        var bookingId = event.currentTarget.id;
        bookingId = bookingId.split('-')[0];
        var bookingIds = [];
        bookingIds.push(bookingId);
        this.doRaiseLPD(bookingIds);
    }

    handleCalculateSelected(event) {
        var bookings = this.bookings;
        var bookingIds = [];
        for (var i = 0; i < bookings.length; i++) {
            if (bookings[i].checked) {
                bookingIds.push(bookings[i].bookingId);
            }
        }
        if (bookingIds.length > 0) {
            this.doCalculateLPC(bookingIds);
        }
        else {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please select a booking.',
            });
            this.dispatchEvent(evt);
        }
    }

    handleRaiseSelected(event) {
        var bookings = this.bookings;
        var bookingIds = [];
        for (var i = 0; i < bookings.length; i++) {
            if (bookings[i].checked) {
                bookingIds.push(bookings[i].bookingId);
            }
        }
        if (bookingIds.length > 0) {
            this.doRaiseLPD(bookingIds);
        }
        else {
            const evt = new ShowToastEvent({
                variant: 'warning',
                message: 'Please select a booking.',
            });
            this.dispatchEvent(evt);
        }
    }

    doCalculateLPC(bookingIds) {
        this.showSpinner = true;
        var bookingIdToNameMap = this.bookingIdToName;
        if (bookingIds.length > 0) {
            var bookingId = bookingIds[0];
            bookingIds.shift();
            calculateLatePayment({ bookingId: bookingId })
                .then(result => {
                    const evt = new ShowToastEvent({
                        variant: 'success',
                        message: bookingIdToNameMap.get(bookingId) + ' : The Late Payment Charge is Calculated Successfully.',
                    });
                    this.dispatchEvent(evt);
                    this.doCalculateLPC(bookingIds);
                })
                .catch(error => {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: bookingIdToNameMap.get(bookingId) + ' : Error Occured.',
                    });
                    this.dispatchEvent(evt);
                    this.doCalculateLPC(bookingIds);
                });
        }
        else {
            this.loadBooking(this.selectedTower);
            this.showSpinner = false;
        }
    }

    doRaiseLPD(bookingIds) {
        this.showSpinner = true;
        var bookingIdToNameMap = this.bookingIdToName;
        if (bookingIds.length > 0) {
            var bookingId = bookingIds[0];
            bookingIds.shift();
            raiseDemand({ bookingId: bookingId })
                .then(result => {
                    if (result != null) {
                        if (result.includes('Successfully')) {
                            const evt = new ShowToastEvent({
                                variant: 'success',
                                message: bookingIdToNameMap.get(bookingId) + ' : ' + result,
                            });
                            this.dispatchEvent(evt);
                        }
                        else {
                            const evt = new ShowToastEvent({
                                variant: 'warning',
                                message: bookingIdToNameMap.get(bookingId) + ' : ' + result,
                            });
                            this.dispatchEvent(evt);
                        }
                    }
                    this.doRaiseLPD(bookingIds);
                })
                .catch(error => {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        message: bookingIdToNameMap.get(bookingId) + ' : Error Occured.',
                    });
                    this.dispatchEvent(evt);
                    this.doRaiseLPD(bookingIds);
                });
        }
        else {
            this.loadBooking(this.selectedTower);
            this.showSpinner = false;
        }
    }

    loadTowers() {
        getProjects()
            .then(result => {
                let towers = [];
                let obj = { label: 'All', value: 'All' };
                towers.push(obj);
                for (var i = 0; i < result.length; i++) {
                    let towerData = result[i].Towers__r;
                    if (towerData != null && towerData != undefined) {
                        for (var j = 0; j < towerData.length; j++) {
                            let towerObj = { label: towerData[j].Name, value: towerData[j].Id };
                            towers.push(towerObj);
                        }
                    }
                }
                this.allTowers = towers;
            })
            .catch(error => {
            });
    }

    loadBooking(towerId) {
        this.showSpinner = true;
        this.isDataLoaded = false;
        getBookings({ towerId: towerId })
            .then(result => {
                let nfObject = new Intl.NumberFormat('en-US');
                var bookingIdToNameMap = new Map();
                for (var i = 0; i < result.length; i++) {
                    result[i].milestoneDueTillDate = (result[i].milestoneDueTillDate != null) ? nfObject.format(result[i].milestoneDueTillDate) : 0;
                    result[i].collectedAmount = (result[i].collectedAmount != null) ? nfObject.format(result[i].collectedAmount) : 0;
                    result[i].dueAmount = (result[i].dueAmount != null) ? nfObject.format(result[i].dueAmount) : 0;
                    result[i].totalInterestTillDate = (result[i].totalInterestTillDate != null) ? nfObject.format(result[i].totalInterestTillDate) : 0;
                    bookingIdToNameMap.set(result[i].bookingId, result[i].bookingName);
                }
                this.bookings = result;
                this.bookingIdToName = bookingIdToNameMap;
                this.isDataLoaded = true;
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

}