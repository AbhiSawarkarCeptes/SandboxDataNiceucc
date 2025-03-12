import { LightningElement, api, track, wire } from "lwc";
import getDuplicates from "@salesforce/apex/AccountMergeController.getDuplicates";
import mergeRecord from "@salesforce/apex/AccountMergeController.mergeRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

const columns = [
  { label: "Name", fieldName: "Name", type: "text" },
  { label: "Phone", fieldName: "Phone", type: "phone" }
];

export default class AccountMerge extends NavigationMixin(LightningElement) {
  @api recordId;
  excludeColumns = ["IsMaster", "Name", "Id"];
  showMergePopup = false;
  showSpinner = false;
  showCmp = false;
  dupsPage = true;
  mergePage = false;
  columns = columns;
  accounts = [];
  error = null;
  @track selectedData = [];
  tableData = {};
  @track isLoading = false;

  sortColumns = {
    Name: 1,
    Phone: 2
  };

  connectedCallback() {}

  @wire(getDuplicates, { accountId: "$recordId" })
  wiredGetDuplicatesAccounts({ error, data }) {
    if (data) {
      let result = JSON.parse(data);
      console.log("account data->", result);
      if (result.length > 1) {
        let objectKeys = Object.keys(result[0]);
        console.log("objectKeys", objectKeys);
        console.log("columns", this.columns);
        this.columns = [];
        objectKeys.forEach((col) => {
          if (!this.excludeColumns.includes(col)) {
            let colObj = {};
            colObj.label = col;
            colObj.fieldName = col;
            colObj.customIndex = this.sortColumns[col];
            this.columns.push(colObj);
          }
        });
        this.accounts = result;
        this.showCmp = true;
      }
    } else if (error) {
      this.error = error;
      this.accounts = undefined;
      console.error(error);
    }
  }

  handleRowSelection(event) {
    this.selectedData = [...event.detail.selectedRows];
    console.log(
      "selectedRows are ",
      this.selectedData.length,
      JSON.stringify(this.selectedData)
    );
  }

  handleNext() {
    console.log('selected records after next ->',this.selectedData);
    console.log('account data ',this.accounts);
    let isMasterPresent = [];
    isMasterPresent = this.selectedData.filter(acc => acc.IsMaster == 'true');

    if(isMasterPresent.length === 0) {
      let fetchMaster = {};
      fetchMaster = this.accounts.filter(acc => acc.IsMaster == 'true');
      this.selectedData.push(fetchMaster[0]);

      this.selectedData.sort((a, b) => {
        let fa = a.IsMaster.toLowerCase();
        let fb = b.IsMaster.toLowerCase();
        if(fa == 'true'){
          return -1;
        }

        if(fb == 'true'){
          return -1;
        }
        return 0;

    });
    }
    
    console.log('selected records after nextdd ->',this.selectedData);
    this.showMergePopup = true;
    if (this.selectedData && this.selectedData.length) {
      //this.dupsPage = false;
      //this.mergePage = true;
      // this.showSpinner = true;
    }
  }

  handleClose(event) {
    this.showMergePopup = event.detail;
  }

  get showDups() {
    return this.dupsPage && this.accounts && this.accounts.length;
  }

  get disableNext() {
    if (this.dupsPage) return !(this.selectedData && this.selectedData.length);
    else return true;
  }

  get noOfAccounts() {
    return this.tableData?.accountNames?.length;
  }

  handleMergeRecords(event) {
    this.showMergePopup = false;
    let masterDataChange = event.detail;
    this.isLoading = true;
    mergeRecord({
      masterSelectedRecord: JSON.stringify(masterDataChange),
      accountdsNeedToMerge: JSON.stringify(this.selectedData)
    })
      .then((result) => {
        console.log("success message ->", result);
        this.isLoading = false;
        if (result) {
          const evt = new ShowToastEvent({
            title: "Record Merge",
            message: "Recored has been mergeed",
            variant: "success"
          });
          this.dispatchEvent(evt);

          let masterRecordId = this.selectedData.filter(
            (rec) => rec.IsMaster == "true"
          )[0].Id;

          console.log("master record id", masterRecordId);
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: masterRecordId,
              objectApiName: "Account",
              actionName: "view"
            }
          });
          if (this.recordId == masterRecordId) window.location.reload();
        }
      })
      .catch((error) => {
        console.error("error message", error);
        const evt = new ShowToastEvent({
          title: "Error",
          message: error.body.message,
          variant: "error"
        });
        this.dispatchEvent(evt);
        this.isLoading = false;
      });
  }
}