import { LightningElement, wire, track } from 'lwc';
import getCDRLeadRecords from '@salesforce/apex/leadCDRReportController.getCDRLeadRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class LeadCDRReportDashboard extends LightningElement {
    _wiredData; wireInterval; columns = []; isLoading = true; isInitialized = false;

    pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
    totalRecords = 0; pageSize; totalPages; pageNumber = 1; 
    @track records=[];
    teleSaleEnglish=[]; teleSaleArabic=[];

    connectedCallback() {
        this.columns = [
            { label: 'Agents', fieldName: 'preSaleAgentName', iconName: 'utility:advertising'},
            { label: 'Assigned Leads', fieldName: 'totalLeads', iconName: 'utility:trending'},
             // { label: 'Daily Meetings', fieldName: 'duration', iconName: 'utility:workforce_engagement'},
            { label: 'Converted Opportunity', fieldName: 'convertedOpportunity', iconName: 'utility:priority'},
            { label: 'Team', fieldName: 'team', iconName: 'utility:trailblazer_ext'}
        ];
        this.init();
    }

    disconnectedCallback() {
        //clearInterval(this.wireInterval);
    }

    async init() {
        try {
            let value = await getCDRLeadRecords({});
            this.records = JSON.parse(value);
            let tempEng = []; let tempArb = [];
            //console.log('~~~+++'+JSON.stringify(this.records));
            this.records.forEach(function(item){
                if(item.teleSaleTeam==='English'){
                    tempEng.push(item);
                } else {
                    tempArb.push(item);
                }
                // if(item.teleSaleTeam='English'){
                //     this.teleSaleEnglish.push(item);
                // } else {
                //     this.teleSaleArabic.push(item);
                // }
            });
            this.teleSaleEnglish = tempEng;
            this.teleSaleArabic = tempArb;
            //console.log('~~Final: '+JSON.stringify(this.teleSaleArabic));
            
            if(!this.isInitialized){
                //this.wireInterval = setInterval(this.init, 5 * 1000);
                this.isInitialized = true;
            }
        } catch (error) {
            this.isLoading = false;
            //clearInterval(this.wireInterval);
            //this.showToastMessage('Error!', error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // @wire(getCDRLeadRecords)
    // wiredCDRData(result) {
    //     //const { data, error } = result;
    //     this._wiredData = result;
    //     this.isLoading = true;
    //     if(result.data){
    //         this.isLoading = false;
    //         this.recordsToDisplay = result.data;
    //         if(!this.isInitialized){
    //             this.wireInterval = setInterval(this.doRefresh, 5 * 1000);
    //             this.isInitialized = true;
    //         }
    //     } else {
    //         this.isLoading = false;
    //         this.showToastMessage('Error!', result.error, 'error');
    //     }

    //     // if (this.wiredData.data) {
    //     //     this.totalRecords = this.wiredData.data.length;
    //     //     this.records = this.wiredData.data;
    //     //     if(this.totalRecords>0){
    //     //         // this.pageSize = this.pageSizeOptions[0];
    //     //         // this.paginationHelper();
    //     //         this.recordsToDisplay = this.wiredData.data;
    //     //         this.wireInterval = setInterval(this.doRefresh, 5 * 1000);
    //     //     } else {
    //     //         this.showToastMessage('No records to display', ' ', 'warning');
    //     //     }
    //     //     this.isLoading = false;
    //     // } else if (this.wiredData.error) {
    //     //     this.isLoading = false;
    //     //     this.showToastMessage('Error!', result.error, 'error');
    //     // }
    // }

    doRefresh() {
        return refreshApex(this._wiredData);
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    paginationHelper() {
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
    }

    showToastMessage(title, message, variant) {
        this.dispatchEvent( new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        }));
    }
}