import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjects from '@salesforce/apex/GrossAllController.getProjects'
import getBookings from '@salesforce/apex/GrossAllController.getBookings'
import updateLastActionOnBooking from '@salesforce/apex/GrossAllController.updateLastActionOnBooking'
import createTaskOnCall from '@salesforce/apex/GrossAllController.createTaskOnCall'
import sendEmail from '@salesforce/apex/GrossAllController.sendEmail'
import getBookingsByBucket from '@salesforce/apex/GrossAllController.getBookingsByBucket';
import sendBankEmail from '@salesforce/apex/GrossAllController.sendBankDetailsEmail';
import getTargetData from '@salesforce/apex/GrossAllController.getTargetData';
import getCategoryData from '@salesforce/apex/GrossAllController.getCategoryData';
import getTowerData from '@salesforce/apex/GrossAllController.getTowerData';
import getAgeingData from '@salesforce/apex/GrossAllController.getAgeingData';
import getMonthList from '@salesforce/apex/GrossAllController.getMonthList';
import ppdSubmitted from '@salesforce/apex/GrossAllController.ppdSubmitted';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class GrossAll extends NavigationMixin(LightningElement) {

    value = '';
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

    @track selectedBookingIds = [];
    @track towerValue = '';
    @track isFollowUp = false;
    @track isDue = false;
    @track isAdvance = false;
    @track isCategories = false;
    @track isExecutive = false;
    @track isGrossAll = false;

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

    @track makeAmountReq = false;
    @track makeFollowUpDateReq = false;
    @track makeBankNameReq = false;
    @track makeValueationReq = false;

    @track selectedBookingId = '';
    @track selectedBookingSaleValue;
    @track selectedDueOrAdvanceAmount = 0;
    @track discountPercentage;

    @track recordsToDisplay = [];
    @track rowNumberOffset

    @track totalUnits = 0.00;
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
    @track totalBalanceDueAdvance = 0.0;

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
    @track domain = window.location.origin;

    @track isCallModalOpen = false;

    connectedCallback() {
        var today = new Date().toLocaleString("en-US");
        today = today.split(',')[0];
        this.todayDate = today;
        this.loadProjects();
        let allTaskCategories = [
            { label: 'All', value: 'All' },
            { label: 'PTP', value: 'PTP' },
            { label: 'No Contact / Unable to Reach', value: 'No Contact / Unable to Reach' },
            { label: 'Raise for Cancellation', value: 'Raise for Cancellation' },
            { label: 'Adjustment Pending / Rebate Pending', value: 'Adjustment Pending / Rebate Pending' },
            { label: 'Paid But Not Realized', value: 'Paid But Not Realized' },
            { label: 'Regular Follow Up', value: 'Regular Follow Up' },
            { label: 'Mortgage', value: 'Mortgage' },
            { label: 'Unable to Pay', value: 'Unable to Pay' },
            { label: 'SPA / DLD Not Done', value: 'SPA / DLD Not Done' },
            { label: 'Swap / Upgrade', value: 'Swap / Upgrade' },
            { label: 'Not Pitched', value: 'Not Pitched' },
            { label: 'Customer Interested', value: 'Customer Interested' },
            { label: 'Unable to contact / Customer not responding', value: 'Unable to contact / Customer not responding' },
        ];
        this.taskcategoryoptions = allTaskCategories;
        this.categoryoptions = this.taskcategoryoptions;
        var dueCategories = [];
        var advanceCategories = [];
        for (var i = 0; i < allTaskCategories.length; i++) {
            if ((allTaskCategories[i].value == 'Not Pitched' || allTaskCategories[i].value == 'Customer Interested' || allTaskCategories[i].value == 'No Contact / Unable to Reach') && allTaskCategories[i].value != 'All'){
                advanceCategories.push(allTaskCategories[i]);
            }
            if (allTaskCategories[i].value != 'Not Pitched' && allTaskCategories[i].value != 'Customer Interested' && allTaskCategories[i].value != 'All'){
                dueCategories.push(allTaskCategories[i]);
            }
        }

        this.dueCategoryOptions = dueCategories;
        this.advanceCategoryOptions = advanceCategories;
        this.handleTypeChange();
    }

    setLastContactedDate(event) {
        this.lastContactedDate = event.detail.value;
    }

    loadProjects() {
        getProjects()
            .then(result => {
                this.projectData = result;
                let projects = [];
                let towers = [];
                let obj = { label: 'All', value: 'All' };
                towers.push(obj);
                for (var i = 0; i < result.length; i++) {
                    let projectObj = { label: result[i].Name, value: result[i].Id };
                    projects.push(projectObj);
                    let towerData = result[i].PropStrength__Towers__r;
                    if (towerData != null && towerData != undefined) {
                        for (var j = 0; j < towerData.length; j++) {
                            let towerObj = { label: towerData[j].PropStrength__Tower_Name__c, value: towerData[j].Id };
                            towers.push(towerObj);
                        }
                    }
                }
                this.allTowers = towers;
                this.projectoptions = projects;
            })
            .catch(error => {
            });
    }

    loadTowers(projId) {
        let projectData = this.projectData;
        for (var i = 0; i < projectData.length; i++) {
            if (projectData[i].Id == projId) {
                let towerData = projectData[i].PropStrength__Towers__r;
                let towers = [{ label: 'All', value: 'All' }];
                if (towerData != null && towerData != undefined) {
                    for (var i = 0; i < towerData.length; i++) {
                        let towerObj = { label: towerData[i].PropStrength__Tower_Name__c, value: towerData[i].Id };
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
        getBookings({ projectId: projId, towerId: towerId})
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
                    if(result[i].PropStrength__Outstanding_Balance__c > 0){
                        this.totalUnitsDue += 1;
                        this.totalSalValueDue += result[i].PropStrength__Revised_Total_Sales_Consideration__c;
                        this.totalDemandRaisedDue += result[i].PropStrength__Outstanding_Balance__c;
                        this.totalMilestoneDueDue += result[i].PropStrength__Total_Payment_Due__c;
                        this.totalCollectionAmountDue += result[i].PropStrength__Total_Payment_Received__c;
                        this.totalOverdueAmountDue += this.totalDemandRaisedDue
                        this.totalBalanceDue += this.totalDemandRaisedDue;
                    }else {
                        this.totalUnitsAdvance += 1;
                        this.totalSalValueAdvance += result[i].PropStrength__Revised_Total_Sales_Consideration__c;
                        this.totalDemandRaisedAdvance += result[i].PropStrength__Outstanding_Balance__c;
                        this.totalMilestoneDueAdvance += result[i].PropStrength__Total_Payment_Due__c;
                        this.totalCollectionAmountAdvance += result[i].PropStrength__Total_Payment_Received__c;
                        this.totalOverdueAmountAdvance += this.totalDemandRaisedAdvance;
                        this.totalBalanceAdvance += this.totalMilestoneDueAdvance
                    }


                    this.totalUnits += 1;
                    this.totalSalValue += result[i].PropStrength__Revised_Total_Sales_Consideration__c;
                    this.totalDemandRaised += result[i].PropStrength__Outstanding_Balance__c;
                    this.totalMilestoneDue += result[i].PropStrength__Total_Payment_Due__c;
                    this.totalCollectionAmount += result[i].PropStrength__Total_Payment_Received__c;
                    this.totalOverdueAmount += result[i].PropStrength__Outstanding_Balance__c;
                    this.totalBalance += (result[i].PropStrength__Outstanding_Balance__c != null && result[i].PropStrength__Outstanding_Balance__c > 0) ? result[i].PropStrength__Outstanding_Balance__c : 0 ;
                    
                    result[i].soalink = this.domain+'/apex/SOALetterHTML?id='+result[i].Id;
                    result[i].unitLink = '/'+result[i].PropStrength__Property__c;
                    result[i].bookingLink = '/'+result[i].Id;
                    // result[i].rowNumber = ''+(i+1);
                    // result[i].oppLink = '/'+result[i].Id;

                    result[i].PropStrength__Revised_Total_Sales_Consideration__c = nfObject.format(result[i].PropStrength__Revised_Total_Sales_Consideration__c);
                    result[i].PropStrength__Outstanding_Balance__c = nfObject.format(result[i].PropStrength__Outstanding_Balance__c);
                    result[i].PropStrength__Total_Payment_Due__c = nfObject.format(result[i].PropStrength__Total_Payment_Due__c);
                    result[i].PropStrength__Total_Payment_Received__c = nfObject.format(result[i].PropStrength__Total_Payment_Received__c);
                    result[i].due = nfObject.format(result[i].PropStrength__Outstanding_Balance__c);
                    result[i].fullDue = nfObject.format(result[i].PropStrength__Total_Payment_Due__c);
                    console.log('Booking ', result[i].Name,' - ',result[i]);
                    if(result[i].PropStrength__Payment_Plan_Details__r != undefined && result[i].PropStrength__Payment_Plan_Details__r != null && result[i].PropStrength__Payment_Plan_Details__r.length > 0){
                        let milestoneDueDate = new Date(result[i].PropStrength__Payment_Plan_Details__r[result[i].PropStrength__Payment_Plan_Details__r.length - 1].PropStrength__Payment_Due_Date__c);
                        console.log('milestoneDueDate -> ',milestoneDueDate);
                        let today = new Date();
                        let timeDifference = today - milestoneDueDate;
                        console.log('timeDifference -> ',timeDifference);
                        result[i].age = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
                        console.log('timeDifference -> ',result[i].age);
                    }else{
                        result[i].age = 0;
                    }
                    // if (result[i].age <= 30) {
                    //     result[i].bucketColor = "background-color:#FFBF00";
                    // }
                    // else if (result[i].age > 30 && result[i].age >= 60) {
                    //     result[i].bucketColor = "background-color:green; color:white;";
                    // }
                    // else if (result[i].age > 60 && result[i].age >= 90) {
                    //     result[i].bucketColor = "background-color:red; color:white;";
                    // }
                    // else if(result[i].age > 90){
                    //     result[i].bucketColor = "background-color:#FF6F59; color:white";
                    // }else{
                    //     result[i].bucketColor = "background-color: white; color:#000";
                    // }

                    if (result[i].category == 'Due Payments') {
                        dueFollowUp.push(result[i]);
                    }
                    else if (result[i].category == 'Advance Payments') {
                        advanceFollowUp.push(result[i]);
                    }
                }
                this.bookingData = result;
                this.totalSalValue = nfObject.format(this.totalSalValue);
                this.totalDemandRaised = nfObject.format(this.totalDemandRaised);
                this.totalMilestoneDue = nfObject.format(this.totalMilestoneDue);
                console.log(this.totalCollectionAmount);
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

    sendEmailToPrimaryApplicant(bookingId) {
        sendEmail({ bookingId: bookingId })
            .then(result => {

            })
            .catch(error => {

            });
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
        this.loadTowers(event.detail.value);
    }

    handleTowerChange(event) {
        this.bookingData = [];
        this.tempBookingData = [];
        this.tempDueFollowUpBookingData = [];
        this.tempAdvanceFollowUpBookingData = [];
        this.dueFollowUpBookingData = [];
        this.advanceFollowUpBookingData = [];
        this.selectedTower = event.detail.value;
        if(event.detail.value == 'All') {
            this.loadBookings(this.selectedProject, null, this.selectedTaskCategory);
        }else{
            this.loadBookings(this.selectedProject, event.detail.value, this.selectedTaskCategory);
        }
    }

    handleTypeChange() {
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

        let type = 'Gross All';
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

        this.isFollowUp = (type == 'Follow-Ups' || type == 'Categories') ? true : false;
        this.isDue = (type == 'Due Payments') ? true : false;
        this.isAdvance = (type == 'Advance Payments') ? true : false;
        this.isCategories = (type == 'Categories') ? true : false;
        this.isExecutive = (type == 'Executive Dashboard') ? true : false;
        this.isGrossAll = (type == 'Gross All') ? true : false;

        if (this.isFollowUp || this.isDue || this.isAdvance || this.isCategories || this.isGrossAll) {
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
        }
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

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
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

    createTask(event) {
        this.selectedDueOrAdvanceAmount = event.currentTarget.type;
        this.categoryOfSelectedRow = '';
        let category = event.currentTarget.title;
        this.categoryOfSelectedRow = category;
        this.hideAllFields();
        let bId = event.currentTarget.id;
        bId = bId.split('-')[0];
        bId = bId.split('/')[1];
        this.selectedBookingId = bId;
        this.selectedBookingSaleValue = event.currentTarget.name;
        this.selectedCategory = '';
        this.categoryoptions = this.taskcategoryoptions;
        // if (category == 'Due Payments'){
        //     this.categoryoptions = this.dueCategoryOptions;
        // }
        // if (category == 'Advance Payments'){
        //     this.categoryoptions = this.advanceCategoryOptions;
        // }
        this.isModalOpen = true;
    }

    CallOption(event) {
        this.isCallModalOpen = false;
        let bId = event.currentTarget.id;
        let phoneNum = event.currentTarget.type;
        bId = bId.split('-')[0];
        // bId = bId.split('/')[1];
        this.selectedBookingId = bId;
        var className = "." + bId;
        console.log("className :: " + className);
        if(phoneNum != undefined && phoneNum != null && phoneNum != '') {
            this.isCallModalOpen = false;
            const childNodes = this.template.querySelector(className).childNodes;
            console.log("childNodes: " + childNodes);
            this.createNewTask(bId);
            for(const node of childNodes) {
                if(node.nodeName == 'LIGHTNING-CLICK-TO-DIAL') {
                    setTimeout(() => {
                        node.click()
                    })
                }
            }
            const evet = new ShowToastEvent({
                title: 'Call connecting...',
                message: '',
                variant: 'success',
            });
            this.dispatchEvent(evet);
        } else {
            //this.isCallModalOpen = true;
        }
    }

    closeCallModal() {
        this.isCallModalOpen = false;
    }

    createNewTask(bookingId) {
        createTaskOnCall({ bookingId: bookingId })
            .then(result => {
                this.newTaskId = result;
                this.isModalOpenCallLog = true;
            })
            .catch(error => {
            });
    }

    closeModal() {
        this.isModalOpen = false;
        this.isModalOpenCallLog = false;
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
                    this.totalBalance += result[i].balance;
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

    handleCheckboxChange(event) {
        var selectedBookingId = event.target.dataset.id; // Get the ppdId from the data-id attribute
        var isChecked = event.target.checked; // Get the checkbox state (checked or unchecked)
        selectedBookingId = selectedBookingId.replace('/', '');
        console.log(selectedBookingId);
        console.log(isChecked);
        let listSelBooking = this.selectedBookingIds;
        if (isChecked) {
            if (!listSelBooking.includes(selectedBookingId)) {
                listSelBooking.push(selectedBookingId);
            }
        } else {
            if (listSelBooking.includes(selectedBookingId)) {
                listSelBooking.splice(listSelBooking.indexOf(selectedBookingId),1);
            }
        }
        console.log(listSelBooking);

        this.selectedBookingIds = listSelBooking;

        var masterCheckbox = this.template.querySelector('input[type="checkbox"][data-master-checkbox="true"]');
        var rowCheckboxes = this.template.querySelectorAll('input[type="checkbox"][data-id]');
        var flag = true;
        for (let i = 0; i < rowCheckboxes.length; i++) {
            var checkbox = rowCheckboxes[i];
            if (!checkbox.checked) {
                flag = false;
                break;
            }
        }
        if (flag) {
            masterCheckbox.checked = true;
        } else {
            masterCheckbox.checked = false;
        }
    }

    handleMasterCheckboxChange(event) {
        var rowCheckboxes = this.template.querySelectorAll('input[type="checkbox"][data-id]');

        rowCheckboxes.forEach(checkbox => {
            checkbox.checked = event.target.checked;
        });

        if (event.target.checked) {
            let bookData = this.bookingData;
            let selId = this.selectedBookingIds;
            for (let i = 0; i < bookData.length; i++) {
                let ppdIdVal = bookData[i].bookingId;
                ppdIdVal = ppdIdVal.replace('/', '');
                if (!selId.includes(ppdIdVal)) {
                    selId.push(ppdIdVal);
                }
            }
            this.selectedBookingIds = selId;
        } else {
            this.selectedBookingIds = [];
        }
    }

    handleSubmit() {
        console.log(this.selectedBookingIds.length);
        if (this.selectedBookingIds.length > 0) {
            ppdSubmitted({ selectedBooking: this.selectedBookingIds })
                .then(result => {
                    console.log(result);
                    if (result == 'success') {
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: 'Successfully Submitted.',
                        });
                        this.dispatchEvent(evt);
                    } else if (result == 'failure') {
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: 'The Booking is not eligible for Termination.',
                        });
                        this.dispatchEvent(evt);
                    }
                    this.loadBookings(this.selectedProject, this.selectedTower, this.selectedType);
                })
                .catch(error => {
                    console.log('error:', error);
                });
        } else {
            console.log('innn');
            const evt = new ShowToastEvent({
                            variant: 'warning',
                            message: 'Please Select Milestone',
            });
            this.dispatchEvent(evt);
        }
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

    showTasks(event) {
        let bId = event.currentTarget.id;
        bId = bId.split('-')[0];
        bId = bId.split('/')[1];

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/' + bId + '/related/Tasks__r/view'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
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
}