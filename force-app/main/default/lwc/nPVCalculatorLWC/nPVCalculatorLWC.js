import { LightningElement, api, track } from 'lwc';
import getPPDRecs from '@salesforce/apex/NPVCalculatorLWCController.ppdRecords';
import getPaymentRecs from '@salesforce/apex/NPVCalculatorLWCController.paymentRecords';
import getNpvSlabsRecs from '@salesforce/apex/NPVCalculatorLWCController.npvSlabsRecords';
import createTransReq from '@salesforce/apex/NPVCalculatorLWCController.createTransationRequest';

const columns = [
    { label: 'Percentage', fieldName: 'Percentage', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Name', fieldName: 'MilestoneName', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Due Date', fieldName: 'MilestoneDueDate', cellAttributes: { alignment: 'left' }, type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric"}},
    { label: 'Total Installment', fieldName: 'TotalInstallment', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Status', fieldName: 'MilestoneStatus', cellAttributes: { alignment: 'left', class:{fieldName:'amountColor'} }},
    { label: 'Balance', fieldName: 'Balance', cellAttributes: { alignment: 'left' }},
    { label: 'Amount Adjustment', fieldName: 'AmountAdjustment', cellAttributes: { alignment: 'left' }},
    { label: 'Rebate Amount', fieldName: 'RebateAmount', cellAttributes: { alignment: 'left' }}
];

const columnsTab2 = [
    { label: 'Percentage', fieldName: 'Percentage', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Name', fieldName: 'MilestoneName', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Due Date', fieldName: 'MilestoneDueDate', cellAttributes: { alignment: 'left' }, type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric"}},
    { label: 'Total Installment', fieldName: 'TotalInstallment', cellAttributes: { alignment: 'left' }},
    { label: 'Milestone Status', fieldName: 'MilestoneStatus', cellAttributes: { alignment: 'left', class:{fieldName:'amountColor'} }},
    { label: 'Balance', fieldName: 'Balance', cellAttributes: { alignment: 'left' }},
    { label: 'Amount Adjustment', fieldName: 'AmountAdjustment', cellAttributes: { alignment: 'left' }}
];

const columnsPayment = [
    { label: 'Payment Name', fieldName: 'Name', cellAttributes: { alignment: 'left' }},
    { label: 'Amount', fieldName: 'Amount', cellAttributes: { alignment: 'left' }},
    { label: 'Payment Date', fieldName: 'PaymentDate', cellAttributes: { alignment: 'left' }, type: "date", typeAttributes: { day: "numeric", month: "numeric", year: "numeric"}},
    { label: 'Amount Type', fieldName: 'AmountType', cellAttributes: { alignment: 'left' }}
];

export default class NPVCalculatorLWC extends LightningElement {
    @api bookingId;
    @track unitName;
    @track projectName;
    @track applicantName;
    @track tower;
    @track bookingStatus;
    @track data;
    @track columns = columns;
    @track advanceAmount;
    @track tentativePaymentDate;
    @track totalPaidPercent;
    @track slabs;
    @track totalEligibleDiscount;
    @track totalBalance;
    @track dataTab2;
    @track columnsTab2 = columnsTab2;
    @track dataPayment;
    @track columnsPayment = columnsPayment;
    @track selectedRecords;
    @track totalBalanceTab2;
    @track paymentRecordsGetFromMethod;
    @track totalRebateAmountTab2 = 0.00;
    @track totalPaymentAmount = 0.00;
    @track selectedRowsId = [];
    @track finalTotalRebateAmountTab2;

    connectedCallback() {
        this.getNPVSlabRecords();
        this.getPaymentRecords();
        this.getPaymentPlanRecords();
    }

    getPaymentPlanRecords() {
        let advAmt = this.advanceAmount;
        let tentativeDt = this.tentativePaymentDate
        getPPDRecs({bookId: this.bookingId})
            .then(result => {
                console.log('getPPDRecs****');
                console.log(result);
                if (result != null && result != undefined && result.length > 0) {
                    this.unitName = result[0].PropStrength__Property_Name__c;
                    this.projectName = result[0].Project_Name__c;
                    this.applicantName = result[0].PropStrength__Primary_Applicant_Name__c;
                    this.tower = result[0].PropStrength__Property__r['PropStrength__Tower__r']['PropStrength__Tower_Code__c'];
                    this.bookingStatus = result[0].PropStrength__Status__c;
                    this.totalPaidPercent = result[0].PropStrength__Total_Paid_Percent__c+'%';

                    let tempStoreData = [];
                    let tempStoreDataTab2 = [];
                    let totalRebateAmt = 0.00;
                    let totBal = 0.00;
                    let totBal2 = 0.00;
                    for(let st=0; st < result[0].PropStrength__Payment_Plan_Details__r.length; st++) {
                        let recId = result[0].PropStrength__Payment_Plan_Details__r[st]['Id'];
                        let perc = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Percent__c']?result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Percent__c']+'%':'0%';
                        let mileDueDate = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Payment_Due_Date__c']?result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Payment_Due_Date__c']:'';
                        let mileName = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Milestone_Name__c']?result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Milestone_Name__c']:'';
                        let totInst = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Due_Plus_Tax__c']?result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Due_Plus_Tax__c']:'0';
                        let milStatus = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] == '0'?'Paid':result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] == result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Due_Plus_Tax__c']?'PTP':result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] < result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Due_Plus_Tax__c']?'Partially Paid':'';
                        let milStatusTab2 = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] == '0'?'Paid':result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] < result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Amount_Due_Plus_Tax__c']?'Partially Paid':'';
                        let bal = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] != '0' ? result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] : '';
                        let balTab2 = ''
                        if(milStatusTab2 != '') {
                            balTab2 = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] != '0' ? result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] : '';
                        }
                        let amtAdjust = '';
                        let colorMileStatus = milStatus == 'Paid' ? "slds-text-color_success slds-text-title_bold" : '';
                        let partsOfDate =mileDueDate.split('-');
                        let mileDate = new Date(partsOfDate[0], partsOfDate[1] - 1, partsOfDate[2]);
                        let tentDate = '';

                        if(tentativeDt != '' && tentativeDt != null && tentativeDt != 'undefined') {
                            let partsOfTentDate =tentativeDt.split('-');
                            tentDate = new Date(partsOfTentDate[0], partsOfTentDate[1] - 1, partsOfTentDate[2]);
                        }

                        let milestDays;
                        let milestDaysPerc;
                        let slabPerc;

                        if(tentDate != '' && mileDate !=  '') {
                            let Difference_In_Time = mileDate.getTime() - tentDate.getTime();
                            milestDays = Difference_In_Time / (1000 * 3600 * 24);
                            milestDays = milestDays > 0 ? milestDays : 0;
                            if(milestDays > 0) {
                                milestDaysPerc = milestDays / 365;
                            }
                            let slabPercentages = this.slabs;
                            if(slabPercentages.length > 0) {
                                for(let i=0; i<slabPercentages.length; i++) {
                                    if(milestDays >= slabPercentages[i]['DaysFrom'] && milestDays <= slabPercentages[i]['DaysTo']) {
                                        slabPerc = slabPercentages[i]['Rebate'];
                                    }
                                }
                            }
                        }

                        if(result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] != '0' && result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] <= advAmt && tentDate < mileDate && advAmt > 0 && tentDate != '' && mileDate !=  '') {
                            advAmt -= result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'];
                            amtAdjust = result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'];
                        } else if(result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] != '0' && result[0].PropStrength__Payment_Plan_Details__r[st]['PropStrength__Balance__c'] > advAmt && tentDate < mileDate && advAmt > 0 && tentDate != '' && mileDate !=  '') {
                            amtAdjust = advAmt;
                            advAmt = 0;
                        }

                        let rebateAmt = '';

                        if(parseFloat(amtAdjust) > 0 && milestDaysPerc > 0 && parseFloat(slabPerc) > 0) {
                            let rebAmt = this.fvCalculation(parseFloat(amtAdjust), parseFloat(slabPerc), milestDaysPerc);
                            totalRebateAmt += parseFloat(rebAmt);
                            rebateAmt = rebAmt > 0 ? String(rebAmt) : '';
                        }

                        if(bal != '' && bal != '0') {
                            totBal += parseFloat(bal);
                        }

                        if(balTab2 != '' && balTab2 != '0') {
                            totBal2 += parseFloat(balTab2);
                        }
                        
                        tempStoreData.push({Id: recId, Percentage: perc, MilestoneName: mileName, MilestoneDueDate: mileDate, TotalInstallment: totInst, MilestoneStatus: milStatus, amountColor: colorMileStatus, Balance: bal, AmountAdjustment: String(amtAdjust), RebateAmount: rebateAmt});
                        tempStoreDataTab2.push({Id: recId, Percentage: perc, MilestoneName: mileName, MilestoneDueDate: mileDate, TotalInstallment: totInst, MilestoneStatus: milStatusTab2, amountColor: colorMileStatus, Balance: balTab2});
                    }
                    this.data = tempStoreData;
                    this.dataTab2 = tempStoreDataTab2;
                    this.totalEligibleDiscount = totalRebateAmt.toFixed(2);
                    this.totalBalance = totBal.toFixed(2);
                    this.totalBalanceTab2 = totBal2.toFixed(2);
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    getPaymentRecords() {
        getPaymentRecs({bookId: this.bookingId})
            .then(result => {
                if (result != null && result != undefined && result.length > 0) {
                    this.paymentRecordsGetFromMethod = result;

                    let tempStorePaymentRec = [];
                    for(let st=0; st < result.length; st++) {
                        let recordId = result[st]['Id'];
                        let paymentName = result[st]['Name'];
                        let paymentAmount = result[st]['PropStrength__Amount__c'];
                        let paymentDate = result[st]['PropStrength__Payment_Date__c'];
                        let amtType = result[st]['PropStrength__Amount_Due_Type__c'];
                        tempStorePaymentRec.push({Id: recordId, Name: paymentName, PaymentDate: paymentDate, Amount: paymentAmount, AmountType: amtType});
                    }

                    if(tempStorePaymentRec.length > 0) {
                        this.dataPayment = tempStorePaymentRec;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    getNPVSlabRecords() {
        getNpvSlabsRecs()
            .then(result => {
                console.log('getNpvSlabsRecs****');
                console.log(result);
                if (result != null && result != undefined && result.length > 0) {
                    let recArr = result.split(' ');
                    let objArr = [];
                    console.log('recArr****');
                    console.log(recArr);
                    for(let i=0; i<recArr.length; i++) {
                        let obj = JSON.parse(recArr[i]);
                        objArr.push(obj);
                    }

                    console.log('objArr****');
                    console.log(objArr);

                    if(objArr.length > 0) {
                        this.slabs = objArr;
                    }
                }
            })
            .catch(error => {
                console.log(error);
            });
    }

    renderedCallback() {
        if (this.isRendered) {
            return; 
        }
        this.isRendered = true;

        let style = document.createElement('style');
        style.innerText = '.slds-th__action{background-color: #3258a8 !important; color: white !important;} .slds-th__action:hover{background-color: white !important; color: #3258a8 !important;}';
        this.template.querySelector('lightning-datatable').appendChild(style);

        let styleTab = document.createElement('style');
        styleTab.innerText = '.slds-is-active{background-color: #3258a8 !important; color: white !important; font-size : 1.1rem !important;} .slds-tabs_default__item{font-size : 1.1rem !important;}';
        this.template.querySelector('lightning-tab').appendChild(styleTab);
    }

    handleAmountChange(event) {
        this.advanceAmount = event.detail.value;
        this.getPaymentPlanRecords();
    }
    
    handleDateChange(event) {
        this.tentativePaymentDate = event.detail.value;
        this.getPaymentPlanRecords();
    }

    fvCalculation(amt,interestRate,time){
        let x=(1+interestRate/100);
        let FV=amt*(Math.pow(x,time));
        return (FV-amt).toFixed(2);
    }

    totalEligCSS() {
        let style = document.createElement('style');
        style.innerText = '.changeColor:hover{background-color: white !important; color: #3258a8 !important;}';
        this.template.querySelector('[data-id="highlightBox"]').appendChild(style);
    }

    checkBoxSelection(event) {
        let ppdTableData = this.dataTab2;
        let paymentData = this.paymentRecordsGetFromMethod;
        let recId = event.detail.selectedRows;
        let indexStore = [];
        let ppdMap = new Map();
        let totRebateAmt = 0;
        let totPayAmt = 0;
        let selRowsId = [];

        if (recId.length > 0) {
            for (let i = 0; i < recId.length; i++) {
                selRowsId.push(recId[i]['Id']);
                for(let j =0; j < paymentData.length; j++) {
                    if(paymentData[j]['Id'] == recId[i]['Id']) {
                        let ppdArr = paymentData[j]['PropStrength__Other_Charge_Due_Partitions__r'];
                        for(let k=0; k < ppdTableData.length; k++) {
                            for(let m=0; m < ppdArr.length; m++) {
                                if(ppdArr[m]['PropStrength__Payment_Plan_Detail__c'] == ppdTableData[k]['Id']) {
                                    let tentativeDt = paymentData[j]['PropStrength__Payment_Date__c'];
                                    let tentDate = '';
                                    if(tentativeDt != '' && tentativeDt != null && tentativeDt != 'undefined') {
                                        let partsOfTentDate =tentativeDt.split('-');
                                        tentDate = new Date(partsOfTentDate[0], partsOfTentDate[1] - 1, partsOfTentDate[2]);
                                    }
                                    let mileDate = ppdTableData[k]['MilestoneDueDate'];
                                    let milestDays;
                                    let milestDaysPerc;
                                    let slabPerc;
                                    if(tentDate != '' && mileDate !=  '' && mileDate.getTime() > tentDate.getTime()) {
                                        let Difference_In_Time = mileDate.getTime() - tentDate.getTime();
                                        milestDays = Difference_In_Time / (1000 * 3600 * 24);
                                        milestDays = milestDays > 0 ? milestDays : 0;
                                        if(milestDays > 0) {
                                            milestDaysPerc = milestDays / 365;
                                        }
                                        let slabPercentages = this.slabs;
                                        if(slabPercentages.length > 0) {
                                            for(let i=0; i<slabPercentages.length; i++) {
                                                if(milestDays >= slabPercentages[i]['DaysFrom'] && milestDays <= slabPercentages[i]['DaysTo']) {
                                                    slabPerc = slabPercentages[i]['Rebate'];
                                                }
                                            }
                                        }
                                    }
                                    let rebateAmt = '';
                                    if(parseFloat(ppdArr[m]['PropStrength__Milestone_Payment_Recieved_cur__c']) > 0 && milestDaysPerc > 0 && parseFloat(slabPerc) > 0) {
                                        let rebAmt = parseFloat(this.fvCalculation(parseFloat(ppdArr[m]['PropStrength__Milestone_Payment_Recieved_cur__c']), parseFloat(slabPerc), milestDaysPerc));
                                        let valToMinus = 0;
                                        if(ppdMap.has(k) && ppdTableData[k]['AmountAdjustment'] != '' && ppdTableData[k]['AmountAdjustment'] != undefined && ppdTableData[k]['AmountAdjustment'] != null) {
                                            valToMinus = parseFloat(ppdTableData[k]['AmountAdjustment']);
                                            rebAmt += parseFloat(ppdTableData[k]['AmountAdjustment']);
                                        }
                                        totRebateAmt += parseFloat(rebAmt);
                                        if(valToMinus > 0) {
                                            totRebateAmt -= valToMinus;
                                        }
                                        totPayAmt += parseFloat(ppdArr[m]['PropStrength__Milestone_Payment_Recieved_cur__c']);
                                        rebateAmt = rebAmt > 0 ? String(rebAmt.toFixed(2)) : '';
                                    }
                                    if(rebateAmt != '') {
                                        ppdTableData[k]['AmountAdjustment'] = rebateAmt;
                                        if(ppdMap.has(k)) {
                                            let arr = ppdMap.get(k);
                                            arr.push(rebateAmt);
                                            ppdMap.set(k, arr);
                                        } else {
                                            let arr = [];
                                            arr.push(rebateAmt);
                                            ppdMap.set(k, arr);
                                        }
                                        indexStore.push(k);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if(indexStore.length > 0) {
            for(let i =0; i <ppdTableData.length; i++) {
                if(!indexStore.includes(i)) {
                    ppdTableData[i]['AmountAdjustment'] = '';
                }
            }
        } else {
            for(let i =0; i <ppdTableData.length; i++) {
                ppdTableData[i]['AmountAdjustment'] = '';
            }
        }

        this.dataTab2 = ppdTableData;
        this.dataTab2 = [...this.dataTab2];
        this.totalRebateAmountTab2 = totRebateAmt.toFixed(2);
        this.finalTotalRebateAmountTab2 = this.totalRebateAmountTab2;
        this.totalPaymentAmount = totPayAmt.toFixed(2);
        this.selectedRowsId = selRowsId;
    }

    updateFinalTotalRebateAmt2(event) {
        this.finalTotalRebateAmountTab2 = event.detail.value;
    }

    submitTransaction() {
        if (this.totalPaymentAmount != '' && this.totalPaymentAmount != '0' && this.totalPaymentAmount != null && this.totalPaymentAmount != undefined && this.totalRebateAmountTab2 != '' && this.totalRebateAmountTab2 != null && this.totalRebateAmountTab2 != undefined && this.finalTotalRebateAmountTab2 != '' && this.finalTotalRebateAmountTab2 != null && this.finalTotalRebateAmountTab2 != undefined) {
            if (this.finalTotalRebateAmountTab2 <= this.totalRebateAmountTab2) {
                createTransReq({ totalPaymentAmt: this.totalPaymentAmount, totalRebateAmt: this.finalTotalRebateAmountTab2, differentialRebateAmt: (this.totalRebateAmountTab2 - this.finalTotalRebateAmountTab2),bookId: this.bookingId, selPaymentId: String(this.selectedRowsId) })
                    .then(result => {
                        if (result != null && result != undefined && result.length > 0) {
                            alert('Success! Transaction Request Record is Created Successfully');
                        } else {
                            alert('Transaction Request is already present');
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    });
            } else {
                alert('Total Rebate amount must not exceed the - ' + this.totalRebateAmountTab2);
            }
        }
    }
}