import { LightningElement, track,wire } from 'lwc';
import BROLER_LEDGER_OBJ from '@salesforce/schema/PropStrength__Broker_Ledger__c';
import statsuOptionval from '@salesforce/schema/PropStrength__Broker_Ledger__c.Status__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import searchPClans from '@salesforce/apex/BrokerPayoutLWCController.accountName';
import getAccountDetails from '@salesforce/apex/BrokerPayoutLWCController.getAccountDetails';
import saveTheLedgers from '@salesforce/apex/BrokerPayoutLWCController.saveTheLedgers';
import searchPLValues from '@salesforce/apex/BrokerPayoutLWCController.searchPLValues';
import { loadStyle } from 'lightning/platformResourceLoader';
import BrokerPayoutCss from '@salesforce/resourceUrl/BrokerPayoutCss';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'Account Name', fieldName: 'Name', cellAttributes: { alignment: 'center' } },
    { label: 'Broker Type', fieldName: 'PropStrength__Broker_Type__c', cellAttributes: { alignment: 'center' }},
    { label: 'Registration/Passport Number', fieldName: 'Registration_Passport_Number__c', cellAttributes: { alignment: 'center' }},
    { label: 'TRN Number', fieldName: 'TRN_Number__c', cellAttributes: { alignment: 'center' }},
];
const brokerColumns = [
    { label: 'Broker Payment ID', fieldName: 'Name', cellAttributes: { alignment: 'center' } },
    { label: 'Broker Payment Milestone', fieldName: 'Milestone__Name', cellAttributes: { alignment: 'center' }},
    { label: 'Booking Name', fieldName: 'App_Booking_Name__c', cellAttributes: { alignment: 'center' }},
    { label: 'Brokerage Type', fieldName: 'PropStrength__Brokerage_Type__c', cellAttributes: { alignment: 'center' }},
    { label: 'Total Brokerage Due', fieldName: 'PropStrength__Total_Brokerage_Due__c', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }  },
    { label: 'Outstanding Balance', fieldName: 'Outstanding_Balance', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }   },
    { label: 'Paid Amount', fieldName: 'PropStrength__Paid_Amount__c', editable: true, type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }   }
]
const brokerColumnsCopy = [
    { label: 'Broker Payment ID', fieldName: 'Name', cellAttributes: { alignment: 'center' } },
    { label: 'Broker Payment Milestone', fieldName: 'Milestone__Name', cellAttributes: { alignment: 'center' }},
    { label: 'Booking Name', fieldName: 'App_Booking_Name__c', cellAttributes: { alignment: 'center' }},
    { label: 'Brokerage Type', fieldName: 'PropStrength__Brokerage_Type__c', cellAttributes: { alignment: 'center' }},
    { label: 'Total Brokerage Due', fieldName: 'PropStrength__Total_Brokerage_Due__c', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }  },
    { label: 'Outstanding Balance', fieldName: 'Outstanding_Balance', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' } , cellAttributes: { alignment: 'center' }  },
    { label: 'Paid Amount', fieldName: 'PropStrength__Paid_Amount__c', editable: true, type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' } , cellAttributes: { alignment: 'center' } }
]
export default class BrokerPayoutLwc extends LightningElement {
    columns = columns;
    brokerColumns = brokerColumns;
    accountData;
    brokeLadgersData;
    areAccountDetailVisible = false;
    arebrokeLadgersVisible = false;
    showResultsPC = false;
    searchResultsPC;
    searchKeyPC = '';
    draftValues = [];
    brokerColumnsCopy = brokerColumnsCopy;
    pickListOptions = [];
    brkAccountId = '';
    selectedPaymentMode = '';
    paidAmount;
    dateFld;
    instrumentNumber;
    remarks;
    totalOutstandingBalance = 0;
    @track showSpinner = true;
    @track disableBulk = true;
    @track openBulkDataModal = false;
    @track disableProceed = true;
    @track disableBulkClass = 'slds-m-left_x-small disabled-bulk-button';
    @track disableProceedClass = 'slds-m-left_x-small disabled-proceed-button';
    @track selectedMilestoneName ='';
    @track selectedMilestoneAmount =0;
    selectedIds =[];
    @track recordTypeId;
    @track pickListStatusOptions;

    @wire(getObjectInfo, { objectApiName: BROLER_LEDGER_OBJ })
    wiredObjectInfo({error, data}) {
        if (error) {
          // handle Error
        } else if (data) {
          const rtis = data.recordTypeInfos;
          this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Brokerage Paid');
        }
    };
    
    @wire(getPicklistValues,{
        recordTypeId: "$recordTypeId", 
        fieldApiName: statsuOptionval
    })wiredOutAmtOptions({error,data}){
        console.log('data128*---',data);
        if(data) {
            this.pickListStatusOptions = data.values;
        } 
    };
    connectedCallback() {
        searchPLValues({}).then(result => {
            console.log(result);
            for (var i = 0; i < result.length; i++) {
                this.pickListOptions.push({ label: result[i], value: result[i] });
            }
        }) .catch(error => {
            console.error(error);
        });
        this.searchPCs();
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, BrokerPayoutCss)
        ]);
    }

    handleResultClickPC(event) {
        this.showResultsPC = false;
        this.searchKeyPC = event.target.dataset.id;
        this.showResultsPC = false;
        this.showSpinner = true;
        this.disableBulk = false;
        this.disableBulkClass = 'slds-m-left_x-small enabled-bulk-button';
        this.brkAccountId = event.target.title;
        console.log(event.target.title);
        if (this.brkAccountId != null || this.brkAccountId != undefined || this.brkAccountId != '') {
            console.log('inn');
            this.handleGetAccDetails();
        }
    }
    handleGetAccDetails() {
        getAccountDetails({accountId : this.brkAccountId})
            .then(result => {
            console.log('getaccDetails----');
            this.columns.forEach(function(col){
                result[col['fieldName']] = result[col['fieldName']] != undefined ? result[col['fieldName']] : '';
            });
            let accountData = [];
            accountData.push(result);
            this.accountData = accountData;
            this.areAccountDetailVisible   = true;
            if(result.PropStrength__Broker_Ledgers__r.length > 0) {
                console.log(result);
                console.log(result.PropStrength__Broker_Ledgers__r);
                let brokeLadgersData = result.PropStrength__Broker_Ledgers__r;
                let brokeLadgersDataToShow = [];
                brokeLadgersData.forEach(function(rec){
                    let map = [];
                    console.log(rec.PropStrength__Broker_Payment_Milestone__r != undefined);
                    map['id'] = rec.Id;
                    map['Name'] = rec.Name != undefined ?rec.Name : ''; 
                    map['Milestone__Name'] =  rec.PropStrength__Broker_Payment_Milestone__r.Name != undefined ? rec.PropStrength__Broker_Payment_Milestone__r.Name : '';
                    map['PropStrength__Brokerage_Type__c'] = rec.PropStrength__Brokerage_Type__c != undefined ?rec.PropStrength__Brokerage_Type__c : ''; 
                    map['PropStrength__Total_Brokerage_Due__c'] = rec.PropStrength__Total_Brokerage_Due__c != undefined ?rec.PropStrength__Total_Brokerage_Due__c : '';
                    map['App_Booking_Name__c'] = rec.PropStrength__Broker_Payment_Milestone__r.App_Booking_Name__c != undefined ? rec.PropStrength__Broker_Payment_Milestone__r.App_Booking_Name__c : ''; 
                    rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c = rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c != null ? rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c : 0;
                    if( rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Due_With_Service_Tax__c >   rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c ) {
                        map['Outstanding_Balance'] = rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Due_With_Service_Tax__c - rec.PropStrength__Broker_Payment_Milestone__r.PropStrength__Brokerage_Paid__c;
                        brokeLadgersDataToShow.push(map);
                    } 
                    map['PropStrength__Paid_Amount__c'] = '';
                });
                this.brokeLadgersData = brokeLadgersDataToShow;
                var tempData = this.brokeLadgersData;
                for (var i = 0; i < tempData.length; i++) {
                    tempData[i].pickListOptions = this.pickListOptions;
                    this.totalOutstandingBalance += tempData[i].Outstanding_Balance;
                }
                console.log(tempData);
                this.brokeLadgersData = tempData;
                this.arebrokeLadgersVisible = true;
                this.handleCancel();
                this.showSpinner = false;
            }
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
        });
    }
    handleSearchKeyChangePC(event) {
        console.log('in handleSearchKeyChangePC');
        this.searchKeyPC = event.target.value;
        this.showResultsPC = true;
        if (this.searchKeyPC.length == 0 || this.searchKeyPC == undefined) {
            this.searchKeyPC = '';
            this.showResultsPC = false;
            this.areAccountDetailVisible = false;
            this.arebrokeLadgersVisible = false;
            this.disableBulk = true;
            this.disableBulkClass = 'slds-m-left_x-small disabled-bulk-button';
        }
        this.searchPCs();
    }
    searchPCs(){
        searchPClans({
            searchKeyWrd: this.searchKeyPC
        }).then(result => {
            console.log(result);
            this.searchResultsPC = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }
    showDialogPC() {
        this.showResultsPC = true;
    }
    handleCellChange(event) {
        console.log('handleCellChange::',event.detail.draftValues);
        var tempDraftValues = event.detail.draftValues;
        var strDev = this.draftValues;
        console.log('strDev::',strDev);
        for (var check = 0; check < tempDraftValues.length; check++) {
            var flg = true;
            for (var check2 = 0; check2 < strDev.length; check2++) {
                if (strDev[check2].id == tempDraftValues[check].id) {
                    if (tempDraftValues[check].hasOwnProperty('PropStrength__Paid_Amount__c')) {
                        strDev[check2].PropStrength__Paid_Amount__c = tempDraftValues[check].PropStrength__Paid_Amount__c;
                    }
                    if (tempDraftValues[check].hasOwnProperty('PropStrength__Date__c')) {
                        strDev[check2].PropStrength__Date__c = tempDraftValues[check].PropStrength__Date__c;
                    }
                    if (tempDraftValues[check].hasOwnProperty('PropStrength__Check_No__c')) {
                        strDev[check2].PropStrength__Check_No__c = tempDraftValues[check].PropStrength__Check_No__c;
                    }
                    if (tempDraftValues[check].hasOwnProperty('PropStrength__Broker_Payment_Mode__c')) {
                        strDev[check2].PropStrength__Broker_Payment_Mode__c = tempDraftValues[check].PropStrength__Broker_Payment_Mode__c;
                    }
                    flg = false;
                }
            }
            if (flg) {
                var tempObj = {id: tempDraftValues[check].id};
                if (tempDraftValues[check].hasOwnProperty('PropStrength__Paid_Amount__c')) {
                    tempObj.PropStrength__Paid_Amount__c = tempDraftValues[check].PropStrength__Paid_Amount__c;
                }
                if (tempDraftValues[check].hasOwnProperty('PropStrength__Date__c')) {
                    tempObj.PropStrength__Date__c = tempDraftValues[check].PropStrength__Date__c;
                }
                if (tempDraftValues[check].hasOwnProperty('PropStrength__Check_No__c')) {
                    tempObj.PropStrength__Check_No__c = tempDraftValues[check].PropStrength__Check_No__c;
                }
                if (tempDraftValues[check].hasOwnProperty('PropStrength__Broker_Payment_Mode__c')) {
                    tempObj.PropStrength__Broker_Payment_Mode__c = tempDraftValues[check].PropStrength__Broker_Payment_Mode__c;
                }
                strDev.push(tempObj);
            }
        }
        this.draftValues = strDev;
        if (this.draftValues.length > 0) {
            var flag = false;
            for (var ch = 0; ch < this.draftValues.length; ch++) {
                if (this.draftValues[ch].hasOwnProperty('PropStrength__Paid_Amount__c') && (this.draftValues[ch].PropStrength__Paid_Amount__c == null || this.draftValues[ch].PropStrength__Paid_Amount__c == 'undefined' || this.draftValues[ch].PropStrength__Paid_Amount__c == '')) {
                    flag = true;
                } else {
                    flag = false;
                    break;
                }
            }
            console.log('this.draftValues****', this.draftValues);
            console.log('this.brokerColumns****', this.brokerColumns);
            console.log('flag2****', flag);
            if (!flag) {
                if (this.draftValues[0].hasOwnProperty('PropStrength__Paid_Amount__c')) {
                    if (this.brokerColumns.length == 7) {
                        this.brokerColumns = [
                            ...this.brokerColumns,
                            { label: 'Date', fieldName: 'PropStrength__Date__c', editable: true, type: 'date', typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit'},cellAttributes: { alignment: 'center', class: {fieldName: 'disableDateField'} } },
                            { label: 'Instrument Number', fieldName: 'PropStrength__Check_No__c', type: 'number', editable: true, cellAttributes: { alignment: 'center', class: {fieldName: 'disableChequeField'} } },
                            { label: 'Payment Mode', fieldName: 'PropStrength__Broker_Payment_Mode__c', editable: true, cellAttributes: { alignment: 'center', class: {fieldName: 'disablePaymentModeField'} } ,type: 'picklistColumn', typeAttributes: {placeholder: 'Select Payment Mode', options: { fieldName: 'pickListOptions' }, value: { fieldName: 'PropStrength__Broker_Payment_Mode__c' }, context: { fieldName: 'id' }} }
                        ];
                    }
                }
                console.log('this.brokerColumns****', this.brokerColumns);
                var tempDraftVal = this.brokeLadgersData;
                var tempDV = this.draftValues;
                for (var n = 0; n < tempDV.length; n++) {
                    for (var z = 0; z < tempDraftVal.length; z++) {
                        if (tempDV[n].id == tempDraftVal[z].id) {
                            tempDraftVal[z].PropStrength__Paid_Amount__c = tempDV[n].PropStrength__Paid_Amount__c;
                        }
                    }
                }
                for (var k = 0; k < tempDraftVal.length; k++) {
                    if (tempDraftVal[k].hasOwnProperty('PropStrength__Paid_Amount__c')) {
                        if (tempDraftVal[k].PropStrength__Paid_Amount__c == '') {
                            tempDraftVal[k].disableDateField = 'disabledCell';
                            tempDraftVal[k].disablePaymentModeField = 'disabledCell';
                            tempDraftVal[k].disableChequeField = 'disabledCell';
                        } else {
                            tempDraftVal[k].disableDateField = '';
                            tempDraftVal[k].disablePaymentModeField = '';
                            tempDraftVal[k].disableChequeField = '';
                        }
                    }
                }
                this.brokeLadgersData = tempDraftVal;
            } else {
                this.brokerColumns = this.brokerColumnsCopy;
                var tempDraftVal = this.brokeLadgersData;
                this.draftValues = [];
                for (var z = 0; z < tempDraftVal.length; z++) {
                    tempDraftVal[z].PropStrength__Paid_Amount__c = '';
                }
                this.brokeLadgersData = tempDraftVal;
            }
        } else {
            this.brokerColumns = this.brokerColumnsCopy;
            this.draftValues = [];
            var tempDraftVal = this.brokeLadgersData;
            for (var z = 0; z < tempDraftVal.length; z++) {
                tempDraftVal[z].PropStrength__Paid_Amount__c = '';
            }
            this.brokeLadgersData = tempDraftVal;
        }
    }
    handleSave() {
        this.showSpinner = true;
        console.log('handleSave::');
        console.log(this.draftValues);
        saveTheLedgers({
            draftValueList: JSON.stringify(this.draftValues)
        }).then(result => {
            console.log(result);
            if (result == 'Success') {
                this.showToast('Success', 'Broker Ledgers (Paid) Created Successfully', 'success');
                this.showSpinner = false;
                this.draftValues = [];
                this.searchKeyPC = '';
                this.showResultsPC = false;
                this.areAccountDetailVisible = false;
                this.arebrokeLadgersVisible = false;
                this.disableBulk = true;
                this.disableBulkClass = 'slds-m-left_x-small disabled-bulk-button';
                this.brokeLadgersData = [];
            } else {
                this.showSpinner = false;
                this.showToast('Error', 'Please check the data', 'error');
            }
        }).catch(error => {
            this.showSpinner = false;
            this.showToast('Error', error, 'error');
        });
    }
    handleCancel() {
        console.log('handleCancel::');
        var tempDraftVal = this.brokeLadgersData;
        if (tempDraftVal.length > 0) {
            for (var z = 0; z < tempDraftVal.length; z++) {
                tempDraftVal[z].PropStrength__Paid_Amount__c = '';
            }
            this.brokerColumns = this.brokerColumnsCopy;
            this.draftValues = [];
            this.brokeLadgersData = tempDraftVal;
        }
    }

    getSelectedRow(event){
        const selectedRows = event.detail.selectedRows; 
        console.log(selectedRows);        
        this.selectedMilestoneName = '';
        this.selectedMilestoneAmount = 0;
        var selId = [];
        console.log("All selected:123 ",this.selectedIds);
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            console.log(selectedRows[i].id);
            let tempId = selectedRows[i].id.toString();            
            selId.push(tempId);
            console.log(selId.includes(tempId));
            this.selectedMilestoneName = this.selectedMilestoneName + ' , ' + selectedRows[i].Milestone__Name;
            this.selectedMilestoneAmount = this.selectedMilestoneAmount + selectedRows[i].Outstanding_Balance;            
        }
        var mileName = '';
        mileName = this.selectedMilestoneName;
        if(mileName.startsWith(" , "))
            this.selectedMilestoneName = mileName.substring(3);
        console.log("All selected: ", selId);
        this.selectedIds = selId;
        console.log("All selected: ",this.selectedIds);
        console.log("All selected: ",this.selectedMilestoneName);
        console.log("All selected: ",this.selectedMilestoneAmount);
    }
    handleBulkLedgerCreation() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows(); 
        console.log('selectedRecords*----'+selectedRecords);
        console.log('selectedRecords*----'+JSON.stringify(this.template.querySelector("lightning-datatable")));
        console.log('selectedRecords*----'+this.template.querySelector('lightning-datatable').getSelectedRows());
        this.selectedPaymentMode = '';
        this.paidAmount=null;
        this.dateFld=null;
        this.instrumentNumber=null;
        this.openBulkDataModal = true;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handleProceedBulkData() {
        this.draftValues = [];
        var tempAmt = this.paidAmount;
        var tempRecords = this.brokeLadgersData;
        var strDev = this.draftValues;   
        console.log('strDev2****', strDev);
        console.log('tempRecords*****', tempRecords);
        console.log('selectedIds*****', this.selectedIds);
        for (var check = 0; check < tempRecords.length; check++) {         
                if(this.selectedIds.length == 0 || ( this.selectedIds.length > 0 && this.selectedIds.includes(tempRecords[check].id.toString())) ){
                    var tempObj = {id: tempRecords[check].id}; 
                    if (tempRecords[check].Outstanding_Balance == tempAmt && tempAmt > 0) {
                        tempObj.PropStrength__Paid_Amount__c = tempAmt.toString();
                        tempObj.PropStrength__Date__c = this.dateFld+'T00:00:00.000Z';
                        tempObj.PropStrength__Check_No__c = this.instrumentNumber;
                        tempObj.Remarks__c = this.remarks;
                        tempObj.Status__c = this.selectedStatus;
                        tempObj.PropStrength__Broker_Payment_Mode__c = this.selectedPaymentMode;
                    } else if (tempRecords[check].Outstanding_Balance > tempAmt && tempAmt > 0) {
                        tempObj.PropStrength__Paid_Amount__c = tempAmt.toString();
                        tempObj.PropStrength__Date__c = this.dateFld+'T00:00:00.000Z';
                        tempObj.PropStrength__Check_No__c = this.instrumentNumber; 
                        tempObj.PropStrength__Broker_Payment_Mode__c = this.selectedPaymentMode;
                        tempObj.Remarks__c = this.remarks;
                        tempObj.Status__c = this.selectedStatus;
                        tempAmt -= tempAmt; 
                    } else if (tempRecords[check].Outstanding_Balance < tempAmt && tempAmt > 0) {
                        tempObj.PropStrength__Paid_Amount__c = tempRecords[check].Outstanding_Balance.toString();
                        tempObj.PropStrength__Date__c = this.dateFld+'T00:00:00.000Z';
                        tempObj.PropStrength__Check_No__c = this.instrumentNumber;
                        tempObj.PropStrength__Broker_Payment_Mode__c = this.selectedPaymentMode;
                        tempObj.Remarks__c = this.remarks;
                        tempObj.Status__c = this.selectedStatus;
                        tempAmt -= tempRecords[check].Outstanding_Balance;
                    }
                    strDev.push(tempObj);
                }                
                
            }
            console.log('/*-----');
            this.draftValues = strDev;
            console.log(strDev);

        if (this.brokerColumns.length == 7) {
            this.brokerColumns = [
                ...this.brokerColumns,
                { label: 'Date', fieldName: 'PropStrength__Date__c', editable: true, type: 'date', typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit'},cellAttributes: { class: {fieldName: 'disableDateField'} } },
                { label: 'Instrument Number', fieldName: 'PropStrength__Check_No__c', type: 'number', editable: true, cellAttributes: { class: {fieldName: 'disableChequeField'} } },
                { label: 'Payment Mode', fieldName: 'PropStrength__Broker_Payment_Mode__c', editable: true, cellAttributes: { class: {fieldName: 'disablePaymentModeField'} } ,type: 'picklistColumn', typeAttributes: {placeholder: 'Select Payment Mode', options: { fieldName: 'pickListOptions' }, value: { fieldName: 'PropStrength__Broker_Payment_Mode__c' }, context: { fieldName: 'id' }} }
            ];
        }

        this.disableProceed = true;
        this.disableProceedClass = 'slds-m-left_x-small disabled-proceed-button';
        this.openBulkDataModal = false;
        this.clearDraft()
    }

    clearDraft(){

        this.brokerColumns = [
            { label: 'Broker Payment ID', fieldName: 'Name', cellAttributes: { alignment: 'center' } },
            { label: 'Broker Payment Milestone', fieldName: 'Milestone__Name', cellAttributes: { alignment: 'center' }},
            { label: 'Booking Name', fieldName: 'App_Booking_Name__c', cellAttributes: { alignment: 'center' }},
            { label: 'Brokerage Type', fieldName: 'PropStrength__Brokerage_Type__c', cellAttributes: { alignment: 'center' }},
            { label: 'Total Brokerage Due', fieldName: 'PropStrength__Total_Brokerage_Due__c', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }  },
            { label: 'Outstanding Balance', fieldName: 'Outstanding_Balance', type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }   },
            { label: 'Paid Amount', fieldName: 'PropStrength__Paid_Amount__c', editable: false, type: 'number', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2, step: 'any', currencyCode: 'USD', style: 'decimal' }, cellAttributes: { alignment: 'center' }   }
        ]
 
     }

    handleCloseModal() {
        this.disableProceed = true;
        this.disableProceedClass = 'slds-m-left_x-small disabled-proceed-button';
        this.openBulkDataModal = false;
    }

    handlePaymentModeChange(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.selectedPaymentMode = event.detail.value;
        }

        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        } 
        
    }

    handlePaidAmount(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.paidAmount = event.detail.value;
            console.log(this.paidAmount);
            console.log(this.totalOutstandingBalance);
            if ( (this.paidAmount > this.totalOutstandingBalance ) || (this.selectedMilestoneAmount != 0 &&  this.paidAmount > this.selectedMilestoneAmount )) {
                this.showToast('Warning', 'Paid Amount must be greater than or equal to Total Outstanding Balance', 'warning');
                this.paidAmount = null;
            }
        }

        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        } 
    }

    handleDateFld(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.dateFld = event.detail.value;
        }

        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        } 
    }

    handleInstNumber(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.instrumentNumber = event.detail.value;
        }

        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        } 
    }

    handleRemarks(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.remarks = event.detail.value;
        } 
        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        }       
    }

    handleStatus(event) {
        if (event.detail.value != null && event.detail.value != undefined && event.detail.value != '') {
            this.selectedStatus = event.detail.value;
        }

        if (this.selectedPaymentMode != '' && this.selectedPaymentMode != undefined && this.selectedPaymentMode != null && this.paidAmount != '' && this.paidAmount != undefined && this.paidAmount != null && this.dateFld != '' && this.dateFld != undefined && this.dateFld != null 
            && this.instrumentNumber != '' && this.instrumentNumber != undefined && this.instrumentNumber != null && this.selectedStatus != '' && this.selectedStatus != undefined && this.selectedStatus != null&& this.remarks != '' && this.remarks != undefined && this.remarks != null) {
            this.disableProceed = false;
            this.disableProceedClass = 'slds-m-left_x-small enabled-proceed-button';
        }       
    }
}