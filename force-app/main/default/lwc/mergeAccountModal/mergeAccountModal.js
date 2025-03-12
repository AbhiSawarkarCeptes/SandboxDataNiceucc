import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MergeAccountModal extends LightningElement {
  @api show = false;
  @api selectedData;
  @track transposObject;
  @track namesOfAccount = [];
  @track masterDataSelection = {};
  @track accountData = [];
  @track userSelectedInfo = false;

  connectedCallback() {
    console.log("selected Data in child ->", this.selectedData);
    this.accountData = JSON.parse(JSON.stringify(this.selectedData));
    this.accountData.forEach((accRecord) => {
      accRecord.Name =
        accRecord.IsMaster == "true"
          ? `${accRecord.Name} (Master)`
          : accRecord.Name;
    });

    console.log("selected Data after name change ->", this.accountData);
    // Transpose the array
    const transposedArray = this.accountData.reduce((acc, obj) => {
      Object.keys(obj).forEach((key) => {
        acc[key] = acc[key] || [];
        acc[key].push(obj[key]);
      });
      return acc;
    }, {});

    // // Move the "Name" property to index 0
    // const nameIndex = Object.keys(transposedArray).indexOf("Name");
    // if (nameIndex !== -1) {
    //     const nameProperty = Object.keys(transposedArray)[nameIndex];
    //     const [removed] = transposedArray[nameProperty].splice(nameIndex, 1);
    //     transposedArray[nameProperty].unshift(removed);
    // }

    // Convert the transposed data into an array of objects
    const resultArray = Object.keys(transposedArray).map((key) => ({
      [key]: transposedArray[key]
    }));

    console.log("result of transpose 2222=>", JSON.stringify(resultArray));

    let tabeleData = [];
    resultArray.forEach((acc) => {
      // acc['isChecked'] = false;
      let rowData = {};
      for (const key in acc) {
        console.log("key:" + key);

        if (key == "Name") {
          for (const idValue of acc[key]) {
            this.namesOfAccount.push(idValue);
          }
        }

        if (key == "Id" || key == "Name") continue;

        rowData["fieldName"] = key;
        rowData["isDisplayFieldName"] = true;
        let lstrecordDetails = [];
        for (const idValue of acc[key]) {
          lstrecordDetails.push(idValue);
        }

        rowData["lstrecordDetails"] = lstrecordDetails;
        rowData["isSelected"] = false;
        // rowData['displayfield'] = false;
        //if (resultArray.hasOwnProperty(acc) && Array.isArray(resultArray[acc]))
        {
          console.log(`Array ${key}:`);
        }
      }

      if (
        rowData["fieldName"] != "IsMaster" &&
        rowData.hasOwnProperty("fieldName")
      )
        tabeleData.push(rowData);

      console.log("result of tabeleData final=>", JSON.stringify(tabeleData));
      //this.namesOfAccount.push(acc.Name);
    });
    this.tablewrp = tabeleData;
    console.log(
      "result of this.tablewrp 2222=>",
      JSON.stringify(this.tablewrp)
    );
    console.log("names of accounts ->", this.namesOfAccount);
  }
  handleSingleCheckboxSelect(event) {
    console.log(event.target.checked);
    let index = event.target.dataset.index;
    //take label for the data
    //for field name   this.tablewrp[index]['fieldName']
    if (index) {
      this.masterDataSelection[event.target.dataset.field] =
        event.target.dataset.label;
        this.userSelectedInfo = true;
    }

    console.log("my selection of data->", this.masterDataSelection);

    if (index) {
      this.tablewrp[index]["isSelected"] = event.target.checked;
    }
  }
  checkvalue() {
    console.log(
      "result of this.tablewrp 2222=>",
      JSON.stringify(this.tablewrp)
    );
    alert("result of this.tablewrp 2222=>" + JSON.stringify(this.tablewrp));
  }
  tablewrp = [];

  showModalBox() {
    this.show = true;
  }

  hideModalBox() {
    console.log("hiding modal");
    this.show = false;
    const customCloseEvent = new CustomEvent("modalclose", { detail: false });
    this.dispatchEvent(customCloseEvent);
  }

  handleMerge() {
    if (!this.userSelectedInfo) {
      const evt = new ShowToastEvent({
        title: "Information",
        message: "You have not selected any Information to be merged. Please select Information.",
        variant: "info"
      });
      this.dispatchEvent(evt);
      return;
    }
    const selectedRecordEvent = new CustomEvent("recordselected", {
      detail: this.masterDataSelection
    });
    this.dispatchEvent(selectedRecordEvent);
    this.show = false;
  }
}