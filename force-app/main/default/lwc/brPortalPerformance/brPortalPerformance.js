import {LightningElement, api, track, wire} from 'lwc';
import {loadStyle,loadScript} from 'lightning/platformResourceLoader';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import performanceIcons from '@salesforce/resourceUrl/performanceIcons';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getBookingData from '@salesforce/apex/BRSiteVisitChartController.getBookingData';
import getBookingDataDetails from '@salesforce/apex/BRSiteVisitChartController.getBookingDataDetails';
import getBookingMonthlyData from '@salesforce/apex/BRSiteVisitChartController.getBookingMonthlyData';
import getSitevisitsMonthlyData from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsMonthlyData';
import getBookingFormUrl from '@salesforce/apex/BRSiteVisitChartController.getBookingFormUrl';
import getBookingFormSPAUrl from '@salesforce/apex/BRSiteVisitChartController.getBookingFormSPAUrl';
import getBookingAppartmentsCount from '@salesforce/apex/BRSiteVisitChartController.getBookingAppartmentsCount';
import getBookingVillasCount from '@salesforce/apex/BRSiteVisitChartController.getBookingVillasCount';
import getLoggedInUserContactId from '@salesforce/apex/BRSiteVisitChartController.getLoggedInUserContactId';
import getSitevisits1 from '@salesforce/apex/BRSiteVisitChartController.getSitevisits1';
import getSalesBookings from '@salesforce/apex/BRSiteVisitChartController.getSalesBookings';
import getBookingDataYearly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataYearly';
import getSitevisitsYearly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsYearly';
import getBookingDataQuaterly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataQuaterly';
import getBookingDataHalfYearly from '@salesforce/apex/BRSiteVisitChartController.getBookingDataHalfYearly';
import getSitevisitsQuaterly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsQuaterly';
import getSitevisitsHalfYearly from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsHalfYearly';
import getUpcomingEvents from '@salesforce/apex/BRSiteVisitChartController.getUpcomingEvents';
import getBookingCount from '@salesforce/apex/BRSiteVisitChartController.getBookingCount';
import getSitevisitsCountInCurrentYear from '@salesforce/apex/BRSiteVisitChartController.getSitevisitsCountInCurrentYear';
import SITEVISITE_IMAGE_URL from '@salesforce/resourceUrl/SitevisitIcon';
import SITEVISITE_IMAGE_LEFT_URL from '@salesforce/resourceUrl/sitevisiticonleft';
import SALES_IMAGE_LEFT_URL from '@salesforce/resourceUrl/Salesiconleft';
import Event_Icon_Image_URL from '@salesforce/resourceUrl/EventlocationIcon';
import PerformanceStyleSheet from '@salesforce/resourceUrl/performanceStyleSheet';

import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';
import getBookingsTotalInCurrentYear from '@salesforce/apex/BRSiteVisitChartController.getBookingsTotalInCurrentYear';
import getBookingsInSelectedMonth from '@salesforce/apex/BRSiteVisitChartController.getBookingsInSelectedMonth';

export default class BrPortalPerformance extends LightningElement {
    events = [];
    siteVisitsCount;
    @track isEligible = "main-panel";
    @track booleanEligible = true;
    salesIconleft = SALES_IMAGE_LEFT_URL;
    sitevisitUrl = SITEVISITE_IMAGE_URL;
    siteVisitIconLeft = SITEVISITE_IMAGE_LEFT_URL;
    eventIconImageLeft = Event_Icon_Image_URL;
    monthly = false;
    @track buttonClass1 = '';
    @track buttonClass = '';
    @track buttonClass3 = '';
    @track buttonClass4 = '';
    @api loaderVariant = 'base';
    @api chartConfig;
    @track chartOne = false;
    @track chartTwo = false;
    @track chartThree = false;
    @track chartFour = false;
    @track error;
    @track selectedYear = '';
    @track totalCount = 0;
    @track totalSalesCount = 0;
    @track totalSalesCountQuarter = 0;
    @track totalSalesCountHalfyear = 0;
    @track totalSalesCountyear = 0;
    @track selectedValue = '';
    @track isModalOpen = false;
    villasBookingCount = 0;
    appartmentsBookingCount = 0;
    chart;
    chartData = [];
    chartDataTwo = [];
    chartjsInitialized = false;
    lineChart;
    barChart;
    labels = [];
    lineChartData = [];
    barChartData = [];
    chartDataLine = [];
    chartDataBar = [];
    chartMonthDataLine = [];
    chartMonthDataBar = [];
    bookingData = [];
    newCloneChartLabel = [];
    newCloneDataLine = [];
    sale_icon = portalAssests + '/assets/images/performance-sale-icon-black.svg';
    sale_icon_blue = performanceIcons + '/performanceIcons/saleIconBlue.svg';
    filter_icon_white = performanceIcons + '/performanceIcons/filterIconWhite.svg';
    filter_icon_blue = performanceIcons + '/performanceIcons/filterIconBlue.svg';
    villaIcon = performanceIcons + '/performanceIcons/villa.svg';
    appartmentIcon = performanceIcons + '/performanceIcons/appartment.svg';
    cloneTotalCount = 0;

    yearOptions = [
        { label: '2024', value: '2024' }
    ];

    @wire(getBookingAppartmentsCount)
    wiredBookingAppartmentCount({ error, data }) {
        if (data) {
			this.appartmentsBookingCount = data;
        } else if (error) {
            console.error('Error fetching booking count for appartments:', error);
        }
    }

    @wire(getBookingVillasCount)
    wiredBookingVillasCount({ error, data }) {
        if(data) {
            this.villasBookingCount = data;
        } else if (error) {
            console.error('Error fetching booking count for villas:', error);
        }
    }

    @wire(getLoggedInUserContactId)
    wiredContactId({ error, data }) {
        if (data) {
            console.log('Logged-in user Contact Id:', data);
        } else if (error) {
            console.error('Error fetching user Contact Id:', error);
        }
    }

    @wire(getSitevisitsCountInCurrentYear)
    wiredSiteVisitsCount({ error, data }) {
        if(data) {
            this.siteVisitsCount = data;
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    @wire(isEligibleForAction)
    eligibilityCheck({
        error,
        data
    }) {
        if (data !== undefined) {
            console.log('Eligibility data is  : ' + data);
            if (data == false) {
                this.booleanEligible = false;
                this.isEligible += ' disableAction';
            }
            if (data == true) {
                console.log('this is true block');
                //  this.isEligible += ' disableAction';
                //this.booleanEligible=true;
            }
        } else if (error) {
            // perform your logic related to error 
        }
    };

    connectedCallback() {
        let today = new Date();
        this.showSiteVisitsTemplate = true;
        this.selectedYear = (today.getFullYear());
        this.buttonClass1 = 'graph-tab-link active';
        this.chartOne = true;
        this.loadChartJS();
        this.getData();
        
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, PerformanceStyleSheet)
        ]).then(() => {
            console.log('Files loaded');
        }).catch(error => {
            console.log(error.body.message);
        });
    }

    isChartJsInitialized = false;
    loadChartJS() {
        Promise.all([loadScript(this, chartjs)])
        .then(() => {
            this.chartjsInitialized = true;
            this.fetchData();
        })
        .catch(
            error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading ChartJS',
                        message: error.message,
                        variant: 'error',
                    })
                );
            }
        );
    }
	
	fetchData() {
        // Fetch data for booking chart
        if(this.chartOne) {
			// Fetch data for site visits 
            let monthList = [];
            let yearList = [];
            var list = [];
            if (this.dOEvent && !this.dOEventTo) {
                monthList.push(parseInt(this.dOEvent.split('-')[1]));
                yearList.push(parseInt(this.dOEvent.split('-')[0]));
            }
            if (!this.dOEvent && this.dOEventTo) {
                monthList.push(parseInt(this.dOEventTo.split('-')[1]));
                yearList.push(parseInt(this.dOEventTo.split('-')[0]));
            }
            if (this.dOEvent && this.dOEventTo) {
                monthList = [];
                yearList = [];
                let lowEnd = parseInt(this.dOEvent.split('-')[0]);
                let highEnd = parseInt(this.dOEventTo.split('-')[0]);
                for (var i = lowEnd; i <= highEnd; i++) {
                    yearList.push(i);
                }
                let lowEndM = parseInt(this.dOEvent.split('-')[1]);
                let highEndM = parseInt(this.dOEventTo.split('-')[1]);
                for (var i = lowEndM; i <= highEndM; i++) {
                    monthList.push(i);
                }
            }
            if (yearList.length == 0 && monthList.length == 0) {
                let today = new Date();
                yearList.push(today.getFullYear());
                for (var i = 1; i < 13; i++) {
                    monthList.push(i);
                }
			}
            console.log('===> monthList ' + monthList);
            console.log('===> yearList ' + yearList);
            getSitevisits1({
                years: yearList,
                months: monthList
            })
            .then(result => {
                try {
                    let index = 0;
                    let chartOneLabels = [];
                    let processedData = [];
                    let total = 0;
                    for (let key in result) {
                        chartOneLabels.push(key);
                        // Store the value in processedData array
                        //const value = result[key];
                        let value;
                        if (this.booleanEligible == true) {
                            value = result[key];
                        } else {
                            value = 0
                        }
                        processedData.push(index);
                        //processedData[index] = result[key];
                        if (this.booleanEligible == true) {
                            processedData[index] = result[key];
                        } else {
                            processedData[index] = 0;
                        }
                        index = index + 1;
                        // Accumulate the total count
                        total += value;
                    }
                    this.totalCount = total;
                    console.log("totalCount"+this.totalCount);
                    this.chartTwo = false;
                    this.chartThree = false;
                    this.chartFour = false;
                    this.chartOneLabels = chartOneLabels;
                    this.chartDataLine = processedData;
                    this.renderCombinedChart();
                    if (this.cloneTotalCount == 0) {
                        this.cloneTotalCount = total;
                    }
                } catch (error) {
                    console.log('error ' + error);
                }
            })
            .catch(
                error => {
                    console.log(error);
                }
            );

            getSalesBookings({
                years: yearList,
                months: monthList
            }).then(result => {
                try {
                    let index = 0;
                    let chartOneLabels = [];
                    let processed_Data = [];
                    let total = 0;
                    for (let key in result) {
                        console.log('===> key ' + key);
                        chartOneLabels.push(key);
                        // Store the value in processed_Data array
                        const value = result[key];
                        console.log('===> value ' + value);
                        processed_Data.push(index);
                        processed_Data[index] = result[key];
                        index = index + 1;
                        // Accumulate the total count
                        total += value;
                    }
                    console.log('===> processed_Data ' + processed_Data);
                    console.log('===> chartOneLabels ' + chartOneLabels);
                    this.totalSalesCount = total;
                    this.chartOneLabels = chartOneLabels;
                    this.chartDataBar = processed_Data;
                    if (this.newCloneChartLabel.length == 0 && this.newCloneDataLine.length == 0) {
                        // this.newCloneChartLabel = chartOneLabels;
                        //this.newCloneDataLine = processedData;
                    }
                    this.renderSalesChart();
                } catch (error) {
                    console.log('Sales error ' + error);
                }
            })
            .catch(
                error => {
                    console.log(error);
                }
            );
        } else if (this.chartTwo) {
            // Fetch data for site visits chart
            getSitevisitsQuaterly({ selectedYear: parseInt(this.selectedYear) })
            .then(result => {
                const recordCounts = [0, 0, 0, 0];
                // Loop through the result and populate processedData based on month
                result.forEach(item => {
                    const exprValue = item.expr0; // Assuming expr0 represents the month (1-4)
                    const recordCount = item.recordCount;
                    if (exprValue >= 1 && exprValue <= 4) {
                        recordCounts[exprValue - 1] = recordCount; // Update recordCount for the corresponding month
                    }
                });
                this.chartDataLine = recordCounts;
                this.renderCombinedQuarterlyChart();
                let totalSumVisit = 0;
				for (let i = 0; i < this.chartDataLine.length; i++) {
					totalSumVisit += this.chartDataLine[i];
				}
				//this.totalCount = totalSumVisit;
            })
            .catch(error => {
                console.log(error);
            });
			getBookingDataQuaterly({ selectedYear: parseInt(this.selectedYear) })
			.then(result => {
				let recordCounts = [0, 0, 0, 0];
				// Loop through the result and update the recordCounts array
				result.forEach(item => {
					const exprValue = item.expr0; // Assuming expr0 represents the month (1-4)
					const recordCount = item.recordCount;
					if (exprValue >= 1 && exprValue <= 4) {
						recordCounts[exprValue - 1] = recordCount; // Update recordCount for the corresponding month
					}
				});
				// Set the chartDataBar array based on recordCounts
				this.chartDataBar = recordCounts;
                this.renderSalesQuarterlyChart();
				let totalSumSales = 0;
				for (let i = 0; i < this.chartDataBar.length; i++) {
					totalSumSales += this.chartDataBar[i];
				}
				this.totalSalesCountQuarter = totalSumSales;
			})
			.catch(
				error => {
                    console.log(error);
                }
			);
        } else if (this.chartThree) {
            // Fetch data for site visits chart
            getSitevisitsHalfYearly({ selectedYear: parseInt(this.selectedYear) })
            .then(result => {
                let sumLessThanSix = 0;
                let sumGreaterThanSix = 0;
                // Loop through the result and accumulate recordCount for months < 6
                result.forEach(item => {
                    const month = item.month;
                    const recordCount = item.recordCount;
                    // Check if the month is less than 6 (i.e., months 1 to 5)
                    if (month <= 6) {
                        // Add recordCount to the first element of chartDataLine
                        sumLessThanSix += recordCount;
                    } else if (month > 6) {
                        // Sum recordCount values for months greater than 6
                        sumGreaterThanSix += recordCount;
                    }
                });
                // Create the processeddata array with the computed sums
                let processeddata = [sumLessThanSix, sumGreaterThanSix];
                this.chartDataLine = processeddata;
                this.renderCombinedHalfyearlyChart();
                let totalSumVisit = 0;
				for (let i = 0; i < this.chartDataLine.length; i++) {
					totalSumVisit += this.chartDataLine[i];
				}
				//this.totalCount = totalSumVisit;
            })
            .catch(
                error => {
                    console.log(error);
                }
            );
			getBookingDataHalfYearly({ selectedYear: parseInt(this.selectedYear) })
            .then(result => {
                let sumLessThanSix = 0;
                let sumGreaterThanSix = 0;
                // Loop through the result to calculate sums based on month value
                result.forEach(item => {
                    const recordCount = item.recordCount;
                    const month = item.month;
                    console.log('===> month ' + month);
					if (month <= 6) {
                        // Sum recordCount values for months less than 6
                        sumLessThanSix += recordCount;
                    } else if (month > 6) {
                        // Sum recordCount values for months greater than 6
                        sumGreaterThanSix += recordCount;
                    }
                });
                console.log('===> sumLessThanSix ' + sumLessThanSix);
                console.log('===> sumGreaterThanSix ' + sumGreaterThanSix);
                // Create the processeddata array with the computed sums
                let processeddata = [sumLessThanSix, sumGreaterThanSix];
                console.log('===> processeddata 428 ' + processeddata);
                this.chartDataBar = processeddata;
                this.renderSalesHalfYearlyChart();
                let totalSumHalfyear = 0;
                for (let i = 0; i < this.chartDataBar.length; i++) {
                    totalSumHalfyear += this.chartDataBar[i];
                }
                console.log('===> totalSumHalfyear 435 ' + totalSumHalfyear);
                this.totalSalesCountHalfyear = totalSumHalfyear;
            })
            .catch(
                error => {
                    console.log(error);
                }
			);
        } else if (this.chartFour) {
            // Fetch data for site visits chart
            getSitevisitsYearly({ selectedYear: parseInt(this.selectedYear) })
            .then(result => {
                let processedData = [];
                // const processedLabel = [];
                let resMap = new Map();
                resMap.set(this.selectedYear, 0);
                let processedLabel = new Map();
                result.forEach(item => {
                    let i = 0;
                    processedLabel.set(item.month, item.recordCount);
                    processedData.push(item.recordCount);
                });
                if (result.length == 0) {
                    processedLabel.set(this.selectedYear, 0);
                    processedData.push(0);
                }
                this.processedLabel = processedLabel;
                this.chartDataLine = processedData;
                this.renderCombinedyearlyChart();
                let totalSumVisit = 0;
				for (let i = 0; i < this.chartDataLine.length; i++) {
					totalSumVisit += this.chartDataLine[i];
				}
				//this.totalCount = totalSumVisit;
            })
            .catch(
                error => {
                    console.log(error);
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error In YEARLY fetching data for site visits chart',
                            message: error.message,
                            variant: 'error',
                        })
                    );*/
                }
            );
			getBookingDataYearly({ selectedYear: parseInt(this.selectedYear) })
            .then(result => {
                let chartDataLine = [];
                let resMap = new Map();
                resMap.set(this.selectedYear, 0);
                let processedLabel = resMap;
                let labels = [];
                result.forEach(item => {
                    const recordCount = item.recordCount;
                    const month = item.month;
                    labels.push(month.toString());
                    // Assign month as label (assuming month is a string representation of the year)
                    // Assign recordCount to chartDataLine
                    chartDataLine.push(recordCount);
                });
                if (result.length == 0) {
                    labels.push(this.selectedYear);
                    chartDataLine.push(0);
                }
                this.labels = labels; // Assuming this is where you want to store labels
                this.chartDataBar = chartDataLine;
                this.totalSalesCountyear = this.chartDataBar;
                this.renderSalesYearlyChart();
            })
            .catch(
                error => {
                    console.log(error);
                }
            );
        }
    }

    handleYearChange(event) {
        // Get the selected value from the event
        this.selectedYear = event.detail.value;
        if (this.types.length > 0) {
            this.getBookingsBasedOnSelection();
        } else {
            this.fetchData();
        }
    }

    projOptions = [];
    natOptions = [];
    bedOptions = [];
    saleOptions = [];
    bookOptions = [];
    agenOptions = [];
    projValue = [];
    natValue = [];
    bedValue = [];
    saleValue = [];
    bookValue = [];
    agenValue = [];
    bookIds = [];
    filterMap = new Map();

    handleChange(e) {
        let eleName = e.target.name;
        console.log('===> eleName ' + eleName);
        let eVal = e.detail.value;
        let thisVar = this;
        if (eleName == 'proj') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('projectName', eVal);
            } else {
                if (thisVar.filterMap.has('projectName')) {
                    thisVar.filterMap.delete('projectName');
                }
            }
            this.projValue = eVal;
        } else if (eleName == 'nat') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('natName', eVal);
            } else {
                if (thisVar.filterMap.has('natName')) {
                    thisVar.filterMap.delete('natName');
                }
            }
            this.natValue = eVal;
        } else if (eleName == 'bed') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('bedName', eVal);
            } else {
                if (thisVar.filterMap.has('bedName')) {
                    thisVar.filterMap.delete('bedName');
                }
            }
            this.bedValue = eVal;
        } else if (eleName == 'sale') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('saleName', eVal);
            } else {
                if (thisVar.filterMap.has('saleName')) {
                    thisVar.filterMap.delete('saleName');
                }
            }
            this.saleValue = eVal;
        } else if (eleName == 'book') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('bookName', eVal);
            } else {
                if (thisVar.filterMap.has('bookName')) {
                    thisVar.filterMap.delete('bookName');
                }
            }
            this.bookValue = eVal;
        } else if (eleName == 'agen') {
            if (eVal.length > 0) {
                thisVar.filterMap.set('agentName', eVal);
            } else {
                if (thisVar.filterMap.has('agentName')) {
                    thisVar.filterMap.delete('agentName');
                }
            }
            this.agenValue = eVal;
        }
        if (this.agenValue.length == 0 && this.bookValue.length == 0 && this.saleValue.length == 0 &&
            this.bedValue.length == 0 && this.natValue.length == 0 && this.projValue.length == 0) {
            this.bookIds = [];
            this.bookingData = this.bookingDataCopy;
        } else {
            try {
                let filters = this.filterMap;
                var filterObj = {};
                filters.forEach((v, f) => {
                    filterObj[f] = v;
                });
                let thisVar = this;
                let results = [];
                console.log('===> filterObj ' + filterObj);
                console.log('===> this.bookingDataCopy ' + this.bookingDataCopy.length);
                results = this.bookingDataCopy.filter(x =>
                    Object.keys(filterObj).every(function (f) {
						return filterObj[f].some(function (z) {
							if (typeof x[f] === 'string' || x[f] instanceof String) {
                                return x[f] && z && x[f].toLowerCase() == z.toLowerCase();
                            } else {
                                return z == x[f];
                            }
                        })
                    })
                )
                console.log('===> results ' + results.length);
                this.bookingData = results;
                console.log(this.filterMap, this.mapEntries, "filtermap");
            } catch (error) {
                console.log(error);
            }
        }
    }

    get mapEntries() {
        console.log(Array.from(this.filterMap.entries()), this.filterMap.entries(), "from");
        return Array.from(this.filterMap.entries()).map(([key, value]) => {
            return { key, value };
        });
    }

    handleDelete(event) {
        const key = event.currentTarget.dataset.key;
        console.log('===> key ' + key);
        const value = event.currentTarget.dataset.value;
        console.log('===> value ' + value);
        //filter table data
        const entries = Array.from(this.filterMap.entries());
        const index = entries.findIndex(entry => entry[0] === key && entry[1].includes(value));
        if (index !== -1) {
            entries[index][1] = entries[index][1].filter(item => item !== value);
            if (entries[index][1].length === 0) {
                entries.splice(index, 1);
            }
            this.filterMap = new Map(entries);
        }
        this.handleChange(event);
        //Remove checkmark
        let thisVarable = this;
        console.log('===> key ' + key);
        if(key == 'projectName') {
            if(thisVarable.filterMap.has('projectName')) {
                const arrayWithpro = this.projValue.filter(function (letter) {
                    return letter !== value;
                });
                console.log('===> arrayWithpro ' + arrayWithpro);
                this.projValue = arrayWithpro;
            } else {
                this.projValue = [];
            }
        } else if(key == 'natName') {
            if(thisVarable.filterMap.has('natName')) {
                const arrayWithnat = this.natValue.filter(function (letter) {
                    return letter !== value;
                });
                this.natValue = arrayWithnat;
            } else {
                this.natValue = [];
            }
        } else if(key == 'bedName') {
            if(thisVarable.filterMap.has('bedName')) {
                const arrayWithbed = this.bedValue.filter(function (letter) {
                    return letter !== value;
                });
                this.bedValue = arrayWithbed;
            } else {
                this.bedValue = [];
            }
        } else if(key == 'saleName') {
            if(thisVarable.filterMap.has('saleName')) {
                const arrayWithsale = this.saleValue.filter(function (letter) {
                    return letter !== value;
                });
                this.saleValue = arrayWithsale;
            } else {
                this.saleValue = [];
            }
        } else if(key == 'bookName') {
            if(thisVarable.filterMap.has('bookName')) {
                const arrayWithbook = this.bookValue.filter(function (letter) {
                    return letter !== value;
                });
                this.bookValue = arrayWithbook;
            } else {
                this.bookValue = [];
            }
        } else if(key == 'agentName') {
            if(thisVarable.filterMap.has('agentName')) {
                const arrayWithag = this.agenValue.filter(function (letter) {
                    return letter !== value;
                });
                this.agenValue = arrayWithag;
            } else {
                this.agenValue = [];
            }
        }
    }

    openModal() {
        this.isModalOpen = !this.isModalOpen;
	}

    closeModal() {
        this.isModalOpen = false;
    }

    processedLabel = new Map();

    // Method to group data
    groupMonthData() {
        const groupSize = 3;
        for (let i = 0; i < this.chartDataBar.length; i += groupSize) {
            const group = this.chartDataBar.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataBar.push(sum);
        }
    }

    groupMonthDataline() {
        const groupSize = 3;
        for (let i = 0; i < this.chartDataLine.length; i += groupSize) {
            const group = this.chartDataLine.slice(i, i + groupSize);
            const sum = group.reduce((acc, val) => acc + val, 0);
            this.chartMonthDataLine.push(sum);
        }
    }

    processData(data) {
        const processedData = Array(12).fill(0);
        data.forEach(item => {
            const monthIndex = parseInt(item.month, 10) - 1;
            processedData[monthIndex] = parseInt(item.recordCount, 10);
        });
        return processedData;
    }

    processLineChartData(data) {
        // Process data for bar chart
        return data.map(item => {
            return parseInt(item.recordCount, 10);
        });
    }

    processBarChartData(data) {
        // Process data for line chart
        return data.map(item => {
            return parseInt(item.siteVisitCount, 10);
        });
    }
	
	chartOneLabels = [];
    //render monthly chart for site visit
    renderCombinedChart() {
		const ctx = this.template.querySelector('canvas.combined-monthly').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
		this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: this.chartOneLabels,
                datasets: [{
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(148,220,245)',
                    borderWidth: 2,
                    borderRadius: 30,
                    borderSkipped: false,
				}]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        //display: true,
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

    // Method to render the quarterly combined chart
    renderCombinedQuarterlyChart() {
        var months = ['Q1', 'Q2', 'Q3', 'Q4'];
        const ctx = this.template.querySelector('canvas.combined-quarterchart').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
		let labels = [];
        for (let mon of months) {
            labels.push(mon + '-' + this.selectedYear);
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels : ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                    label: 'Site Visits',
                    data: this.chartDataLine,
					backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
	}

	// Half yearly Site Visit
    renderCombinedHalfyearlyChart() {
        var months = ['B1', 'B2'];
        const ctx = this.template.querySelector('canvas.combined-halfyearlychart').getContext('2d');
		if (this.chart) {
            this.chart.destroy();
        }
		let labels = [];
        for (let mon of months) {
            labels.push(mon + '-' + this.selectedYear);
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['B1', 'B2'],
                datasets: [
                    {
                        label: 'Site Visits',
                        data: this.chartDataLine,
                        backgroundColor: 'rgb(144,218,244)',
                        borderColor: 'rgb(144,218,244)',
                        borderWidth: 0.5,
                        fill: false,
                        type: 'bar',
                        barThickness: 'flex'
                    }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

	// Yearly Site Visit
    renderCombinedyearlyChart() {
        const ctx = this.template.querySelector('canvas.combined-yearlychart').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        labels.push(this.selectedYear);
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                {
                    label: 'Site Visits',
                    data: this.chartDataLine,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }

	//render sales chart for 1 month
    renderSalesChart() {
		const ctx = this.template.querySelector('canvas.combined-chartsales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        console.log('===> this.chartOneLabels ' + this.chartOneLabels);
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: this.chartOneLabels,
                datasets: [{
                    label: 'Sales Booking',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(148,220,245)',
                    borderWidth: 2,
                    borderRadius: 30,
                    borderSkipped: false,
                    type: 'bar'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        //display: true,
                        position: 'top'
                    }
                },
			}
        });
    }

    //render sales chart for Quartely
    renderSalesQuarterlyChart() {
        var months = ['Q1', 'Q2', 'Q3', 'Q4'];
        const ctx = this.template.querySelector('canvas.combined-quarterchartsales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        for (let mon of months) {
            labels.push(mon + '-' + this.selectedYear);
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Q1', 'Q2', 'Q3', 'Q4'],
                datasets: [{
                    label: 'Sales Bookings',
                    data: this.chartDataBar,
					backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
	}

    //render sales booking data for Haly year
    renderSalesHalfYearlyChart() {
        var months = ['B1', 'B2'];
        const ctx = this.template.querySelector('canvas.combined-halfyearlychartsales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        for (let mon of months) {
            labels.push(mon + '-' + this.selectedYear);
        }
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['B1', 'B2'],
                datasets: [{
                    label: 'Sales Bookings',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
	}

    //render Yearly chart data of sales Bookings
    renderSalesYearlyChart() {
		const ctx = this.template.querySelector('canvas.combined-yearlychartsales').getContext('2d');
        if (this.chart) {
            this.chart.destroy();
        }
        let labels = [];
        labels.push(this.selectedYear);
        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Sales Bookings',
                    data: this.chartDataBar,
                    backgroundColor: 'rgb(144,218,244)',
                    borderColor: 'rgb(144,218,244)',
                    borderWidth: 0.5,
                    fill: false,
                    type: 'bar',
                    barThickness: 'flex'
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
	}
    
	handleTabClick(event) {
        const selectedTabId = parseInt(event.currentTarget.dataset.tab, 10);
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        let today = new Date();
        this.selectedYear = today.getFullYear().toString();
        if(selectedTabId == 1) {
            this.buttonClass1 = 'graph-tab-link active';
            this.buttonClass2 = '';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = true;
            this.chartTwo = false;
            this.chartThree = false;
            this.chartFour = false;
            this.loadChartJS();
            if (this.chartjsInitialized) {
                return;
            }
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        } else if(selectedTabId == 2) {
			this.buttonClass1 = '';
            this.buttonClass2 = 'graph-tab-link active';
            this.buttonClass3 = '';
            this.buttonClass4 = '';
            this.chartOne = false;
            this.chartTwo = true;
            this.chartThree = false;
            this.chartFour = false;
            this.loadChartJS();
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
		} else if (selectedTabId == 3) {
			this.buttonClass1 = '';
            this.buttonClass2 = '';
            this.buttonClass3 = 'graph-tab-link active';
            this.buttonClass4 = '';
            this.chartOne = false;
            this.chartTwo = false;
			this.chartThree = true;
            this.chartFour = false;
            this.loadChartJS();
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
		} else if (selectedTabId == 4) {
            this.buttonClass1 = '';
			this.buttonClass2 = '';
            this.buttonClass3 = '';
			this.buttonClass4 = 'graph-tab-link active';
            this.chartOne = false;
            this.chartTwo = false;
            this.chartThree = false;
			this.chartFour = true;
            this.loadChartJS();
            this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
		}
    }

	showSiteVisitsTemplate = false;
    showSalesTemplate = false;
    showBookingsTemplate = false;

    handleSiteVisitsClick(event) {
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        this.isModalOpen = false;
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        let today = new Date();
        this.selectedYear = today.getFullYear().toString();
        this.buttonClass1 = 'graph-tab-link active';
        this.buttonClass2 = '';
        this.buttonClass3 = '';
        this.buttonClass4 = '';
        this.chartOne = true;
		this.chartTwo = false;
		this.chartThree = false;
		this.chartFour = false;
        this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = true;
        this.showSalesTemplate = false;
        this.showBookingsTemplate = false;
        this.fetchData();
    }

    // Event handler for Sales button click
    handleSalesClick(event) {
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        this.isModalOpen = false;
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        let today = new Date();
        this.selectedYear = today.getFullYear().toString();
        this.buttonClass1 = 'graph-tab-link active';
        this.buttonClass2 = '';
        this.buttonClass3 = '';
        this.buttonClass4 = '';
        this.chartOne = true;
		this.chartTwo = false;
		this.chartThree = false;
		this.chartFour = false;
        this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = false;
        this.showSalesTemplate = true;
        this.showBookingsTemplate = false;
        this.fetchData();
    }

    // Event handler for Bookings button click
    handleBookingsClick(event) {
        this.dOEvent = '';
        this.dOEventTo = '';
        this.types = [];
        this.isModalOpen = false;
        this.totalBookingsinYear = this.duplicatetotalBookingsinYear;
        let aCmp = this.template.querySelectorAll(".check-box");
        aCmp.forEach(function (pr) {
            pr.checked = false;
        });
        let today = new Date();
        this.selectedYear = today.getFullYear().toString();
		this.toggleTabe(event.target);
        this.showSiteVisitsTemplate = false;
        this.showSalesTemplate = false;
        this.showBookingsTemplate = true;
    }

	toggleTabe(clickedElement) {
        const listItems = this.template.querySelectorAll('.events-list li');
        listItems.forEach(item => {
            item.classList.remove('active');
        });
        clickedElement.classList.add('active');
    }

    getData() {
        getBookingDataDetails()
		.then(result => {
			const getData = result.map(item => {
				let isProcessed = false,
					isCancelled = false,
					isBooked = false,
					isUnProcessed = false,
					isSpaExecuted = false,
					isDLDPaid = false,
					BFormSigned = false;
				/*if(item.PropStrength__Status__c == 'Approved' || item.PropStrength__Status__c == 'Welcome Letter Dispatched') {
					isProcessed = true;
				} else if(item.PropStrength__Status__c == 'Rejected') {
					isCancelled = true;
                } else if(item.PropStrength__Status__c != null) {
					isUnProcessed = true;
				}*/
                if(item.PropStrength__Total_Paid_Percent__c >= 10) {
                    isUnProcessed = true;
                } else {
                    isCancelled = true;
                }
                if(item.SPA_Executed__c) {
					isSpaExecuted = true;
				}
				if(item.Oqood_Fees_Received_Date__c != null) {
					isDLDPaid = true;
				}
				if(item.Booking_Form_Signed_by_Customer__c) {
					BFormSigned = true;
				}
				return {
					...item,
					isProcessed,
					isCancelled,
					isUnProcessed,
					isBooked,
					isSpaExecuted,
					isDLDPaid,
					BFormSigned,
                    "salesManager": item.Sales_Manager__r 
                    ? (item.Sales_Manager__r.FirstName != null ? item.Sales_Manager__r.FirstName : '') + 
                    ' ' + 
                    (item.Sales_Manager__r.LastName != null ? item.Sales_Manager__r.LastName : '') 
                    : "",
                    "salesDirector": item.Sales_Head__r 
                    ? (item.Sales_Head__r.FirstName != null ? item.Sales_Head__r.FirstName : '') + 
                    ' ' + 
                    (item.Sales_Head__r.LastName != null ? item.Sales_Head__r.LastName : '') 
                    : ""
				}
			})
			this.bookingData = getData;
			let thisVar = this;
			let p = [];
			let n = [];
			let b = [];
			let s = [];
			let bo = [];
			let ag = [];
			this.bookingData.forEach(item => {
                item.showMoreInfo = false;
				if(item.PropStrength__Property__r && item.PropStrength__Property__r.PropStrength__Property_Name__c) {
					item.projectName = item.PropStrength__Property__r.PropStrength__Property_Name__c;
					if(!p.includes(item.PropStrength__Property__r.PropStrength__Property_Name__c)) {
						p.push(item.PropStrength__Property__r.PropStrength__Property_Name__c);
						thisVar.projOptions.push({ label: item.PropStrength__Property__r.PropStrength__Property_Name__c, value: item.PropStrength__Property__r.PropStrength__Property_Name__c });
					}
				} else {
					item.projectName = '';
				}
				if(item.PropStrength__Primary_Customer__r && item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c) {
					item.natName = item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c;
					if (!n.includes(item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c)) {
						n.push(item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c);
						thisVar.natOptions.push({ label: item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c, value: item.PropStrength__Primary_Customer__r.PropStrength__Nationality__c });
					}
				} else {
					item.natName = '';
				}
                if (item.PropStrength__Property__r && item.PropStrength__Property__r.PropStrength__Unit_Type__c) {
					item.bedName = item.PropStrength__Property__r.PropStrength__Unit_Type__c;
					if (!b.includes(item.PropStrength__Property__r.PropStrength__Unit_Type__c)) {
						b.push(item.PropStrength__Property__r.PropStrength__Unit_Type__c);
						thisVar.bedOptions.push({ label: item.PropStrength__Property__r.PropStrength__Unit_Type__c, value: item.PropStrength__Property__r.PropStrength__Unit_Type__c });
					}
				} else {
					item.bedName = '';
				}
				if(item.PropStrength__Property__r && item.PropStrength__Property__r.Super_Area_Sq_Mtr__c) {
					item.saleName = item.PropStrength__Property__r.Super_Area_Sq_Mtr__c;
					if (!s.includes(item.PropStrength__Property__r.Super_Area_Sq_Mtr__c)) {
						s.push(item.PropStrength__Property__r.Super_Area_Sq_Mtr__c);
						thisVar.saleOptions.push({ label: (item.PropStrength__Property__r.Super_Area_Sq_Mtr__c).toString()+' sq. ft', value: (item.PropStrength__Property__r.Super_Area_Sq_Mtr__c).toString() });
					}
				} else {
					item.saleName = '';
				}
                let v = '';
                /*if (item.isProcessed) {
                    v = 'Sold';
                } else if (item.isCancelled) {
                    v = 'Blocked';
                } else if (item.isUnProcessed) {
                    v = 'Qualified';
                } else if (item.isBooked) {
                    v = 'Blocked';
                }*/
                if (item.isUnProcessed) {
                    v = 'Qualified';
                } else if (item.isCancelled) {
                    v = 'Blocked';
                }
                item.bookName = v;
                if (!bo.includes(v)) {
                    bo.push(v);
                    console.log(item, "item.v");
                    thisVar.bookOptions.push({ label: v, value: v });
                }
				/*if(item.PropStrength__Status__c) {
					item.bookName = item.PropStrength__Status__c;
					if (!bo.includes(item.PropStrength__Status__c)) {
                        bo.push(item.PropStrength__Status__c);
                        thisVar.bookOptions.push({ label: item.PropStrength__Status__c, value: item.PropStrength__Status__c });
                    }
				} else {
					item.bookName = '';
				}*/
				if (item.PropStrength__Broker_Contact__r && item.PropStrength__Broker_Contact__r.Name) {
					item.agentName = item.PropStrength__Broker_Contact__r.Name;
					if (!ag.includes(item.PropStrength__Broker_Contact__r.Name)) {
						ag.push(item.PropStrength__Broker_Contact__r.Name);
						thisVar.agenOptions.push({ label: item.PropStrength__Broker_Contact__r.Name, value: item.PropStrength__Broker_Contact__r.Name });
					}
				} else {
					item.agentName = '';
				}	
			})
			this.bookingDataCopy = this.bookingData;
		})
		.catch(
			error => {

			}
		);
    }

    dOEvent;
    dOEventTo;
    bookingDataCopy;
    handleSelectMonth(event) {
        this.dOEvent = event.target.value;
        this.chartOne = true;
        this.chartTwo = false;
        this.chartThree = false;
        this.chartFour = false;
        this.loadChartJS();
        if (this.showSalesTemplate) {
            this.salesData();
        }
    }

    handleSelectMonthTo(event) {
        this.dOEventTo = event.target.value;
        this.chartOne = true;
        this.chartTwo = false;
        this.chartThree = false;
        this.chartFour = false;
        this.loadChartJS();
        if (this.showSalesTemplate) {
            this.salesData();
        }
    }

    downloadFormHandler(event) {
        let targetId = event.target.dataset.targetId;
        let targetName = event.target.dataset.targetName;
        getBookingFormUrl({
            recordId: targetId,
            fileTitle: targetName
		})
		.then(result => {
			if (result != null && result != '') {
				window.open(result);
			} else {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'File is not available',
						message: 'File is not available',
						variant: 'error',
					})
				);
			}
        })
		.catch(
			error => {
				error => {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Please contact sysytem admin.',
							message: error.message,
							variant: 'error',
						})
					);
				}
			}
		);
    }

    getSelectedYear() {
        return this.selectedYear;
    }

    downloadFormSPAHandler(event) {
        let targetId = event.target.dataset.targetId;
        getBookingFormSPAUrl({
            recordId: targetId,
        })
		.then(result => {
			if (result != null && result != '') {
				window.open(result);
			} else {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'File is not available',
						message: 'File is not available',
						variant: 'error',
					})
				);
			}
		})
		.catch(
			error => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Please contact sysytem admin.',
						message: error.message,
						variant: 'error',
					})
				);
			}
		);
    }

	types = [];
    handleCheckboxClick(event) {
		let selectedId = event.currentTarget.name;
        let checked = event.currentTarget.checked;
        if (!checked) {
            if (selectedId == 'villas') {
                let index = this.types.indexOf('Villas');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }
            } else if (selectedId == 'apartment') {
                let index = this.types.indexOf('Apartment');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }
            } else if (selectedId == 'others') {
                let index = this.types.indexOf('Others');
                if (index > -1) { // only splice array when item is found
                    this.types.splice(index, 1); // 2nd parameter means remove one item only
                }
            }
        }
        if (selectedId == 'villas' && checked) {
            this.types.push('Villas');
        } else if (selectedId == 'apartment' && checked) {
            this.types.push('Apartment');
        } else if (selectedId == 'others' && checked) {
            this.types.push('Others');
        }
        console.log('===> this.types ' + this.types);
        if(this.types.length > 0) {
            console.log('===> call here ');
            this.getBookingsBasedOnSelection();
        } else {
            this.fetchData();
        }
        this.salesData();
	}

    getBookingsBasedOnSelection() {
        if(this.chartOne) {
            let monthList = [];
            let yearList = [];
			if (this.dOEvent && !this.dOEventTo) {
                monthList.push(parseInt(this.dOEvent.split('-')[1]));
                yearList.push(parseInt(this.dOEvent.split('-')[0]));
            }
            if (!this.dOEvent && this.dOEventTo) {
                monthList.push(parseInt(this.dOEventTo.split('-')[1]));
                yearList.push(parseInt(this.dOEventTo.split('-')[0]));
            }
            if (this.dOEvent && this.dOEventTo) {
                monthList = [];
                yearList = [];
                let lowEnd = parseInt(this.dOEvent.split('-')[0]);
                let highEnd = parseInt(this.dOEventTo.split('-')[0]);
                for (var i = lowEnd; i <= highEnd; i++) {
                    yearList.push(i);
                }
                let lowEndM = parseInt(this.dOEvent.split('-')[1]);
                let highEndM = parseInt(this.dOEventTo.split('-')[1]);
                for (var i = lowEndM; i <= highEndM; i++) {
                    monthList.push(i);
                }
            }
			if (yearList.length == 0 && monthList.length == 0) {
				let today = new Date();
                yearList.push(today.getFullYear());
                for(var i = 1; i < 13; i++) {
                    monthList.push(i);
                }
            }
			getBookingCount({
                types: this.types,
                frequency: 'month',
                years: yearList,
                months: monthList,
				selectedYear:parseInt(this.selectedYear)
            })
			.then(result => {
				try {
					let index = 0;
					let chartOneLabels = [];
					let processedData = [];
                    let total = 0;
					for (let key in result) {
						chartOneLabels.push(key);
						// Store the value in processedData array
						const value = result[key];
						processedData.push(index);
						processedData[index] = result[key];
						index = index + 1;
                        // Accumulate the total count
                        total += value;
					}
                    this.totalSalesCount = total;
                    this.chartOneLabels = chartOneLabels;
					this.chartDataBar = processedData;
					this.renderSalesChart();
				} catch (error) {
					console.log('error ' + error);
				}
			})
			.catch(
				error => {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error COUNT fetching data for site visits chart',
							message: error.body.message,
							variant: 'error',
						})
					);
				}
			);
		} else {
            let freq = '';
            if (this.chartTwo) {
                freq = 'quarter';
            } else if (this.chartThree) {
                freq = 'biyear';
            } else if (this.chartFour) {
                freq = 'year';
            }
            getBookingCount({
                types: this.types,
                frequency: freq,
                years: [],
                months: [],
                selectedYear: parseInt(this.selectedYear)
            })
			.then(result => {
				try {
					try {
						let index = 0;
						let processedData = [];
						for (let key in result) {
							processedData.push(index);
							processedData[index] = result[key];
							index = index + 1;
						}
						if (this.chartTwo) {
							this.chartDataBar = processedData;
							this.renderSalesQuarterlyChart();
                            let totalSumSales = 0;
                            for (let i = 0; i < this.chartDataBar.length; i++) {
                                totalSumSales += this.chartDataBar[i];
                            }
                            //this.totalSalesCountQuarter = totalSumSales;
						} else if (this.chartThree) {
							this.chartDataBar = processedData;
							this.renderSalesHalfYearlyChart();
                            let totalSumHalfyear = 0;
                            for (let i = 0; i < this.chartDataBar.length; i++) {
                                totalSumHalfyear += this.chartDataBar[i];
                            }
                            console.log('===> totalSumHalfyear 435 ' + totalSumHalfyear);
                            //this.totalSalesCountHalfyear = totalSumHalfyear;
						} else if (this.chartFour) {
							this.chartDataBar = processedData;
							this.renderSalesYearlyChart();
                            //this.totalSalesCountyear = this.chartDataBar;
						}
					}
					catch (error) {
						console.log('error ' + error);
					}
				} catch (error) {
					console.log('error ' + error);
				}
			})
			.catch(
				error => {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error Booking fetching data for site visits chart',
							message: error.body.message,
							variant: 'error',
						})
					);
				}
			);
        }
    }
    
    refreshPage() {
        // Reload the current page
        location.reload();
    }

    handleMoreInfo(event) {
        try {
            const getIndex = event.currentTarget.dataset.index || event.detail.index;
            this.bookingData = this.bookingData.map((item, index) => {
                if (index == getIndex) {
                    item.showMoreInfo = !item.showMoreInfo;
                } else {
                    item.showMoreInfo = false;
                }
                return item;
            });

        } catch (error) {
            console.log("error--handleMoreInfo", error.message);
        }
    }

    totalBookingsinYear = 0;
    duplicatetotalBookingsinYear = 0;

    @wire(getBookingsTotalInCurrentYear)
    wiredBookingsVisitsCount({ error, data }) {
        if(data) {
            console.log('===> data ' + data);
            //console.log("this.totalBookingsinYear" + JSON.stringify(data));
            this.totalBookingsinYear = (data / 1000000).toFixed(2);
            this.duplicatetotalBookingsinYear = (data / 1000000).toFixed(2);
            //console.log("this.totalBookingsinYear" + this.totalBookingsinYear);
        } else if (error) {
            console.error('Error retrieving site visits count:', error);
        }
    }

    salesData() {
        var getmonth = this.dOEvent;
        const d = new Date(getmonth);
        var getmonthTo = this.dOEventTo;
        const dTo = new Date(getmonthTo);
        let monthList = [];
        let yearList = [];
        if (this.dOEvent && !this.dOEventTo) {
            monthList.push(parseInt(this.dOEvent.split('-')[1]));
            yearList.push(parseInt(this.dOEvent.split('-')[0]));
        }
        if (!this.dOEvent && this.dOEventTo) {
            monthList.push(parseInt(this.dOEventTo.split('-')[1]));
            yearList.push(parseInt(this.dOEventTo.split('-')[0]));
        }
        if (this.dOEvent && this.dOEventTo) {
            monthList = [];
            yearList = [];
            let lowEnd = parseInt(this.dOEvent.split('-')[0]);
            let highEnd = parseInt(this.dOEventTo.split('-')[0]);
            for (var i = lowEnd; i <= highEnd; i++) {
                yearList.push(i);
            }
            let lowEndM = parseInt(this.dOEvent.split('-')[1]);
            let highEndM = parseInt(this.dOEventTo.split('-')[1]);
            for (var i = lowEndM; i <= highEndM; i++) {
                monthList.push(i);
            }
        }
        if (yearList.length == 0 && monthList.length == 0) {
            let today = new Date();
            yearList.push(today.getFullYear());
            for(var i = 1; i < 13; i++) {
                monthList.push(i);
            }
        }
        getBookingsInSelectedMonth({
            years: yearList,
            months: monthList,
            TypeValue: this.types
        })
        .then(result => {
            this.totalBookingsinYear = (result / 1000000).toFixed(2);
        })
        .catch(
            error => {
                
            }
        );
    }
}