import { LightningElement, wire, api, track } from "lwc";
import getDocumentValidatorData from "@salesforce/apex/BrokerPortalDocumentApprovalController.getDocumentValidatorData";
import getViewLink from "@salesforce/apex/BrokerPortalDocumentApprovalController.getViewLink";
import processApproveClick from "@salesforce/apex/BrokerPortalDocumentApprovalController.processApproveClick";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class BrokerPortalDocumentApprovalDashboard extends LightningElement {
  @track filteredValidatorData;
  dataLoaded = false;
  @track brokerOptions = [];
  @api brId = null;
  @track selectedBroker = "";
  selectedCheckboxIds = new Set(); // Use Set for easier add/remove operations

  allBrokers = [];

  connectedCallback() {
    this.loadAllBrokers();
  }

  loadAllBrokers() {
    // Fetch the complete broker data list once
    getDocumentValidatorData()
      .then((data) => {
        if (data) {
          // Store all brokers for initial options
          const brokerMap = new Map();
          data.forEach((row) => {
            const brokerName =
              row.Broker_Registration__r?.Name_as_per_trade_license__c;
            const brokerId = row.Broker_Registration__c;
            if (brokerName && brokerId && !brokerMap.has(brokerId)) {
              brokerMap.set(brokerId, { label: brokerName, value: brokerId });
            }
          });
          this.brokerOptions = [
            { label: "All", value: "All" },
            ...Array.from(brokerMap.values())
          ];
          this.allBrokers = this.brokerOptions.slice(1); // Keep a backup of all brokers excluding "All" option
          this.dataLoaded = true;
        }
      })
      .catch((error) => {
        console.error("Error loading brokers:", error);
      });
  }
  @wire(getDocumentValidatorData, { brId: "$brId" })
  getDocValData({ data, error }) {
    if (data) {
      this.filteredValidatorData = data.map((row) => ({
        ...row,
        brokerName: row.Broker_Registration__r?.Name_as_per_trade_license__c,
        CreatedDate: row.CreatedDate ? row.CreatedDate.split("T")[0] : "",
        comment: "", // Initialize comment property
        errorMessage: "" // Initialize error message
      }));

      this.dataLoaded = true;
    } else if (error) {
      console.error(error);
    }
  }

  handleBrokerChange(event) {
    this.brId = event.detail.value === "All" ? null : event.detail.value; // Set brId to null if "All" is selected
    this.selectedCheckboxIds.clear(); // Clear selected checkboxes on change

    // Clear previous checkboxes selection
    this.template.querySelectorAll(".checkbox-class").forEach((checkbox) => {
      checkbox.checked = false;
    });

    // Update filteredValidatorData to include all brokers' data if "All" is selected
    if (this.brId === null) {
      this.filteredValidatorData = [...this.allBrokers];
    }
  }

  handleRowSelection(event) {
    const recordId = event.currentTarget.dataset.id;
    if (event.target.checked) {
      this.selectedCheckboxIds.add(recordId);
    } else {
      this.selectedCheckboxIds.delete(recordId);
    }
    console.log(this.selectedCheckboxIds);
  }

  approveOrRejectButtonClickHandler(event) {
    const action = event.target.dataset.action;
    let isValid = true;
    const selectedRecords = [];
    // Loop through only selected records to check if comments are empty when rejecting
    this.filteredValidatorData.forEach((record) => {
      if (this.selectedCheckboxIds.has(record.Id)) {
        if (action === "Rejected" && !record.comment) {
          record.errorMessage = "Comment field cannot be empty while rejecting";
          isValid = false;
        } else {
          record.errorMessage = ""; // Clear previous errors
        }
        // Push the record's Id, comment, and action to the selectedRecords array
        selectedRecords.push({
          recordId: record.Id,
          comment: record.comment,
          action: action
        });

        console.log("selected recods are" + JSON.stringify(selectedRecords));
      }
    });

    if (isValid) {
      processApproveClick({ recordsObject: selectedRecords })
        .then((result) => {
          console.log("Records Updated Successfully:", result);
          if (action == "Approved") {
            this.showToast("Success", "Approved successfully.", "success");
          } else {
            this.showToast("Error", "Rejected successfully.", "error");
          }
          setTimeout(() => {
            window.location.reload();
          }, 2000);
        })
        .catch((error) => {
          console.log("The error is :", error);
          this.showToast("Error", "Failed to update selected records", "error");
        });
    } else {
      console.log("Error: Comment field cannot be empty while rejecting");
    }
  }

  handleCommentChange(event) {
    const recordId = event.target.dataset.id;
    const commentValue = event.target.value;
    const record = this.filteredValidatorData.find(
      (item) => item.Id === recordId
    );
    if (record) {
      record.comment = commentValue;
      record.errorMessage = ""; // Reset error message when comment is updated
    }
  }

  selectAllRows() {
    this.selectedCheckboxIds.clear(); // Clear previous selections
    this.template.querySelectorAll(".checkbox-class").forEach((checkbox) => {
      checkbox.checked = true;
      this.selectedCheckboxIds.add(checkbox.dataset.id); // Add all to selected
    });
  }
  viewButtonClickHandler(event) {
    const recId = event.currentTarget.dataset.recid;
    console.log("record id is ", recId);
    getViewLink({ relatedId: recId })
      .then((result) => {
        console.log("The link to show document is :", result);
        window.open(result);
      })
      .catch((error) => {
        console.log("The error is :", error);
      });
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}