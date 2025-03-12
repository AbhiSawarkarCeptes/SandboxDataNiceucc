import { LightningElement, wire, api, track } from "lwc";
import portalAssests from "@salesforce/resourceUrl/portalBrokerAssets";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getProfileDetails from "@salesforce/apex/PortalBrokerEventsController.getProfileDetails";
import renewAgreement from "@salesforce/apex/PortalBrokerEventsController.renewAgreement";
import getRelatedContacts from "@salesforce/apex/PortalBrokerEventsController.getRelatedContacts";
import getBRFileHistory from "@salesforce/apex/PortalBrokerEventsController.getBRFileHistory";
import updateBRHistoryRecord from "@salesforce/apex/PortalBrokerEventsController.updateBRHistoryRecord";
import sendEmailToCHRM from "@salesforce/apex/PortalBrokerEventsController.sendEmailToCHRM";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import uploadFiles from "@salesforce/apex/PortalBrokerEventsController.uploadFiles";
import { refreshApex } from "@salesforce/apex";
import uploadMultipleFiles from "@salesforce/apex/PortalBrokerEventsController.uploadMultipleFiles";
import uploadMultipleBalanceFiles from "@salesforce/apex/PortalBrokerEventsController.uploadMultipleBalanceFiles";
import setUserPhoto from "@salesforce/apex/PortalBrokerEventsController.setProfilePicture";
import deleteUserPhoto from "@salesforce/apex/PortalBrokerEventsController.deleteUserPhoto";
import CommonIcons from "@salesforce/resourceUrl/commonIcons";
import isEligibleForAction from "@salesforce/apex/PortalBrokerEventsController.isEligibleForAction";
import getPolicyFiles from "@salesforce/apex/PortalBrokerEventsController.getPolicyFiles";

import getPdfFile from "@salesforce/apex/PortalBrokerEventsController.getBodyFile";
import getImgFile from "@salesforce/apex/PortalBrokerEventsController.getBodyFile";

import { publish, subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import msgService from "@salesforce/messageChannel/LMSChannel__c";

export default class PortalProfile extends NavigationMixin(LightningElement) {
  @track recdId;
  @track brRecordId;
  @track conId;
  showUploadBalanceDocument = false;
  @track filesData = [];
  @track showDropdown = false;
  @track showFileInput = false;
  firstCall = true;
  showDocumentUploadModule = false;
  profileInfo;
  downloadIcon = portalAssests + "/assets/images/download-agreement.svg";
  view_icon = portalAssests + "/assets/images/view-icon.svg";
  download_icon = portalAssests + "/assets/images/download.svg";
  upload_doc_icon = portalAssests + "/assets/images/upload-doc-icon.svg";
  upload_icon = portalAssests + "/assets/images/upload-doc-icon.svg";
  onUploadStatus = false;
  relatedCons;
  fileUrl;
  uploadedfileId;
  showDocumentModule = false;
  brFilesInfo;
  filesCount;
  listOfEmails = [];
  wiredActivities = {};
  showBalanceFiles = false;
  pencilIcon = CommonIcons + "/commonIcons/pen-bold.svg";
  UploadModuleSelectedText = "View Primary Documents";
  showPolicies = false;
  policiesUrl = "/sfc/servlet.shepherd/document/download/069JX000002OXg1YAG";
  @track isEligible;
  @track policyFiles;
  showPdfFile = false;
  showImgFile = false;
  fileUrlPreview;
  AgreementVersionId;
  NOCVersionId;

  disableSubmitBtn = true;

  @wire(MessageContext)
  messageContext;

  @wire(getBRFileHistory, { showBalanceFiles: "$showBalanceFiles" })
  getBRFileHistoryMethod(value) {
    this.wiredActivities = value;
    // Destructure the provisioned value
    const { data, error } = value;
    if (data) {
      console.log("getBRFileHistoryMethod portion is ", JSON.stringify(data));
      const date = new Date();
      const formattedDate = date.toISOString().split("T")[0];
      console.log(formattedDate);
      console.log(new Date().toISOString().split("T")[0]);
      this.brFilesInfo = data.map((item) => {
        let fileType = item.fileType;
        if (item.fileName.includes("Agreement")) {
          fileType = "Agreement";
          this.AgreementVersionId = item.latestVersionId;
        } else if (item.fileName.includes("NOC")) {
          fileType = "NOC";
          this.NOCVersionId = item.latestVersionId;
        }
        let expiryDateFormatted = "";
        if (item.expiryDate) {
          expiryDateFormatted = new Date(item.expiryDate)
            .toISOString()
            .split("T")[0];
        }
        const expiryDuration = Math.ceil(
          (new Date(item.expiryDate) -
            new Date(new Date().toISOString().split("T")[0])) /
          (1000 * 60 * 60 * 24)
        );
        const expiryClass = this.expiryDurationClass(expiryDuration);
        return {
          fileId: item.fileId,
          ...item,
          expiryDate: expiryDateFormatted,
          //  expiryDuration: (new Date(item.record.Expiry_date__c) - new Date()) / (1000 * 60 * 60 * 24),
          expiryDuration: Math.ceil(
            (new Date(item.expiryDate) -
              new Date(new Date().toISOString().split("T")[0])) /
            (1000 * 60 * 60 * 24)
          ),
          fileUrl: `${item.baseUrl}/sfc/servlet.shepherd/document/download/${item.fileId}`,
          latestVersionId: item.latestVersionId,
          baseUrl: item.baseUrl,
          filetype: fileType,
          fileName: item.fileName,
          objectName: item.ObjectName,
          recordId: item.recordId,
          bolflg:
            item.fileName.startsWith("Agreement") ||
              item.fileName.startsWith("NOC")
              ? true
              : false,
          expiryClass,
          isActiveExpiryClass: expiryClass === "expiry-active",
          fileExtention: item.fileExtention,
          isExpired:
            Math.ceil(
              (new Date(item.expiryDate) -
                new Date(new Date().toISOString().split("T")[0])) /
              (1000 * 60 * 60 * 24)
            ) > 0
              ? true
              : false
        };
      });
      console.log(
        "ContentDocument portion is ",
        JSON.stringify(this.brFilesInfo)
      );
      this.filesCount = this.brFilesInfo
        ? this.brFilesInfo.filter((item) => item.expiryDuration <= 30).length
        : "";
    } else if (error) {
      console.log("Error is ", error);
    }
  }
  wiredData;
  @wire(getProfileDetails)
  getProfileInfo(result) {
    this.wiredData = result;
    let { error, data } = result;
    if (data) {
      console.log("Data portion is ", JSON.stringify(data));
      this.profileInfo = data;
      this.listOfEmails.push(data.CHRMEmail);
      this.conId = data.conId;
      this.brRecordId = data.brRecordId;
    } else if (error) {
      console.log("Error is ", error);
    }
  }
  get downloadUrl() {
    return this.profileInfo ? this.profileInfo.doc_Link : "";
    // return `/sfc/servlet.shepherd/document/download/${this.fileUrl}?operationContext=S1`;
  }
  get downloadNOCUrl() {
    return this.profileInfo ? this.profileInfo.NOC_Link : "";
    // return `/sfc/servlet.shepherd/document/download/${this.fileUrl}?operationContext=S1`;
  }

  connectedcallback() {
    let isEligibleAction = isEligibleForAction();
    if (isEligibleAction == false) {
      this.isEligible = "disableAction";
    }
  }

  @wire(getRelatedContacts)
  getRelatedContacts({ error, data }) {
    if (data) {
      console.log("Related contact data is  ", JSON.stringify(data));
      //this.profileInfo = data;
      this.relatedCons = data;
    } else if (error) {
      console.log("Error is ", error);
    }
  }
  get firstName() {
    return this.profileInfo && this.profileInfo.Name
      ? this.profileInfo.Name
      : "";
  }
  get email() {
    return this.profileInfo && this.profileInfo.Email_Id
      ? this.profileInfo.Email_Id
      : "";
  }
  get accountAndFinEmail() {
    return this.profileInfo && this.profileInfo.AccEmail
      ? this.profileInfo.AccEmail
      : "";
  }
  get authSignatoryPassportName() {
    return this.profileInfo && this.profileInfo.authSignatoryPassportName
      ? this.profileInfo.authSignatoryPassportName
      : "";
  }

  get Designation() {
    return this.profileInfo && this.profileInfo.Designation
      ? this.profileInfo.Designation
      : "";
  }
  get ownersEmail() {
    return this.profileInfo && this.profileInfo.ownersEmail
      ? this.profileInfo.ownersEmail
      : "";
  }
  get mobileNumber() {
    return this.profileInfo && this.profileInfo.Mobile_No
      ? this.profileInfo.Mobile_No
      : "";
  }
  get brokerCategory() {
    return this.profileInfo && this.profileInfo.BrokerCategory
      ? this.profileInfo.BrokerCategory
      : "";
  }
  get regNumber() {
    return this.profileInfo && this.profileInfo.Passport_No
      ? this.profileInfo.Passport_No
      : "";
  }
  get ownerName() {
    return this.profileInfo && this.profileInfo.Name_as_per_trade_license__c
      ? this.profileInfo.Name_as_per_trade_license__c
      : "";
  }
  get brokerId() {
    return this.profileInfo && this.profileInfo.Broker_Id
      ? this.profileInfo.Broker_Id
      : "";
  }
  get tradeLicenceNum() {
    return this.profileInfo && this.profileInfo.TradeLicenceNum
      ? this.profileInfo.TradeLicenceNum
      : "";
  }
  get reraNumber() {
    return this.profileInfo && this.profileInfo.Rera_no
      ? this.profileInfo.Rera_no
      : "";
  }
  get expiryDate() {
    return this.profileInfo && this.profileInfo.Expiry_Date
      ? this.formatDate(this.profileInfo.Expiry_Date)
      : "";
  }
  formatDate(str) {
    var arr = str.split("-");
    var months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    var month = months[parseInt(arr[1] - 1)];
    return arr[2] + " " + month + " " + arr[0];
  }
  get expiryDateDays() {
    return this.agreementRenewalDaysLeft();
  }
  get CompanyName() {
    return this.profileInfo && this.profileInfo.CompanyName
      ? this.profileInfo.CompanyName
      : "";
  }
  get AuthorisedSignatory() {
    return this.profileInfo && this.profileInfo.Authorised_signatory
      ? this.profileInfo.Authorised_signatory
      : "";
  }
  get Title() {
    return this.profileInfo && this.profileInfo.Title
      ? this.profileInfo.Title
      : "";
  }
  get address() {
    if (this.profileInfo && this.profileInfo.Address) {
      return this.profileInfo.Address.replace(/\b\w/g, (char) =>
        char.toUpperCase()
      ).replace(/\B\w/g, (char) => char.toLowerCase());
    }
    return "";
  }

  get photoUrl() {
    return this.profileInfo && this.profileInfo.Photo_Url
      ? this.profileInfo.Photo_Url
      : "";
  }
  get brokerType() {
    return this.profileInfo && this.profileInfo.Broker_Type
      ? this.profileInfo.Broker_Type
      : "";
  }
  get isUnderRenewal() {
    return this.profileInfo ? this.profileInfo.Renewal_status : "";
  }

  get isNotUnderRenewalBefore30days() {
    let flag = false;
    if (
      this.profileInfo &&
      !this.profileInfo.Renewal_status &&
      this.agreementRenewalDaysLeft() <= 30
    ) {
      flag = true;
    }
    return flag;
  }

  agreementRenewalDaysLeft() {
    if (this.profileInfo && this.profileInfo.Expiry_Date) {
      const expiryDate = new Date(this.profileInfo.Expiry_Date);
      const currentDate = new Date();
      const timeDifference = expiryDate.getTime() - currentDate.getTime();
      const daysRemaining = Math.ceil(timeDifference / (1000 * 3600 * 24)); // Convert milliseconds to days
      return daysRemaining;
    }
    return "";
  }

  renderedCallback() {
    if (this.firstCall) {
      this.firstCall = false;
      Promise.all([
        // loadScript(this,portalAssests+'/assets/js/main.js'),
        //loadStyle(this, portalAssests + '/assets/css/style.css')
      ])
        .then(() => {
          console.log("Files loaded successfully");
        })
        .catch((error) => {
          console.log("Something went wrong ", error);
        });
    }
  }
  handleIconClick() {
    this.showDropdown = !this.showDropdown;
  }
  renewalButtonHandler() {
    renewAgreement()
      .then((result) => {
        if (result) {
          // Record created successfully
          console.log("Renewal record created: " + result);

          this.showToast(
            "Success",
            "Renewal record created successfully.",
            "success"
          );
          window.location.reload();
        } else {
          // Handle error
          console.error("Failed to create renewal record.");
          this.showToast("Error", "Failed to create renewal record.", "error");
        }
      })
      .catch((error) => {
        // Handle error
        console.error("Error creating renewal record: " + error.message);
        this.showToast("Error", "Error creating renewal record.", "error");
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

  docClickHandler() {
    console.log("Selected value changed to");
    this.showDocumentUploadModule = !this.showDocumentUploadModule;
    this.disableSubmitBtn = true;
    const selectElement = document.getElementById("documentSelect");
    console.log("Selected value changed to:", selectElement);
  }

  sidebarDownloadIconClickHandler() {
    // console.log("test");
    // console.log(this.profileInfo.doc_Link);
    // console.log(this.profileInfo.NOC_Link);
    // // window.open(this.profileInfo.doc_Link);
    // // window.open(this.profileInfo.NOC_Link);
    // const file1 = this.template.querySelector('a[ref="agreement"]');
    // const file2 = this.template.querySelector('a[ref="noc"]');

    // // Trigger click events on both anchor tags
    // file1.click();
    // console.log("Fiel 1 clicked");
    // setTimeout(() => {
    //   file2.click();
    // }, 3000);
    // console.log("File 2 clicked");
    let fileFormat = "pdf";
    let fileName = "Agreement";
    this.getFile(this.AgreementVersionId, fileFormat.toLowerCase(), fileName);
  }

  viewIconClickHandler(event) {
    // Accessing the dataset property of the clicked element to retrieve the 'id' attribute
    const versionId = event.currentTarget.dataset.versionid;
    const baseUrl = event.currentTarget.dataset.baseurl;
    const filraddress = event.currentTarget.dataset.filraddress;
    const fileFormat = event.currentTarget.dataset.fileextention;
    // const finalURl = `${baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${versionId}`
    const finalURl = filraddress;
    // Log the fileId to ensure it's correctly retrieved
    console.log(finalURl);

    if (fileFormat != "PDF") {
      console.log("not in pdf");
      this.getFileImg(versionId);
      this.showPdfFile = false;
      this.showDocumentUploadModule = false;
    } else if (fileFormat === "PDF") {
      console.log("in pdf");
      this.showDocumentUploadModule = true;
      this.getFilePdf(versionId);
    }
  }
  getFileImg(contVId) {
    getImgFile({ contVersionId: contVId })
      .then((result) => {
        console.log(result);
        if (result != null) {
          this.fileUrlPreview = "data:image/jpeg;base64," + result;
          this.showImgFile = true;
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
      });
  }

  getFilePdf(contVId) {
    console.log("in getfilepdf");
    getPdfFile({ contVersionId: contVId })
      .then((result) => {
        console.log("===> result 331 " + result);
        if (result != null) {
          const blobVal = new Blob([this.base64ToArrayBuffer(result)], {
            type: "application/pdf"
          });
          console.log(blobVal);
          this.fileUrlPreview = URL.createObjectURL(blobVal);
          console.log("===> result 415 " + this.fileUrlPreview);
          this[NavigationMixin.Navigate](
            {
              type: "standard__webPage",
              attributes: {
                url: this.fileUrlPreview
              }
            },
            false
          );
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
      });
  }
  base64ToArrayBuffer(base64) {
    const binaryString = window.atob(base64);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; ++i) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    this.showSpinner = false;
    return bytes.buffer;
  }
  hidePreviewModal() {
    this.showImgFile = false;
    this.showPdfFile = false;
    this.showDocumentUploadModule = true;
  }
  downloadIconClickHandler(event) {
    const versionId = event.currentTarget.dataset.versionid;
    const baseUrl = event.currentTarget.dataset.baseurl;
    const filraddress = event.currentTarget.dataset.filraddress;
    const fileFormat = event.currentTarget.dataset.fileextention;
    const fileName = event.currentTarget.dataset.filename;
    // const finalURl = `${baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${versionId}`
    const finalURl = filraddress;
    // Log the fileId to ensure it's correctly retrieved
    console.log(finalURl);
    console.log("in pdf");
    this.showDocumentUploadModule = true;
    this.getFile(versionId, fileFormat.toLowerCase(), fileName);
    //alert("you clicked download icon");
  }

  getFile(contVId, fileType, fileName) {
    console.log("in getFile");
    getPdfFile({ contVersionId: contVId }) // You might want to rename this server call if handling multiple file types
      .then((result) => {
        console.log("===> result 331 " + result);
        if (result != null) {
          let mimeType;
          switch (fileType) {
            case "pdf":
              mimeType = "application/pdf";
              break;
            case "png":
              mimeType = "image/png";
              break;
            case "jpg":
            case "jpeg":
              mimeType = "image/jpeg";
              break;
            // Add more types if needed
            default:
              mimeType = "application/octet-stream"; // Fallback for unknown types
          }

          const blobVal = new Blob([this.base64ToArrayBuffer(result)], {
            type: mimeType
          });
          console.log(blobVal);

          // Create a download link and set it to download the file
          const downloadLink = document.createElement("a");
          downloadLink.href = URL.createObjectURL(blobVal);
          downloadLink.download = fileName; // Set the name of the downloaded file with appropriate extension
          document.body.appendChild(downloadLink);
          downloadLink.click(); // Programmatically click the link to trigger the download
          document.body.removeChild(downloadLink); // Clean up the DOM by removing the link

          this.fileUrlPreview = downloadLink.href;
          console.log("===> result 415 " + this.fileUrlPreview);
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
        this.showSpinner = false;
      });
  }

  uploadIconClickHandler(event) {
    alert("you clicked upload icon");
    let dataId = event.currentTarget.dataset.id;
    this.template
      .querySelector('span[data-id="' + dataId + '"] lightning-file-upload')
      .click();
  }

  openfileUpload(event) {
    const getFileInput = this.template.querySelector(".uplodInput");
    getFileInput.click();
  }

  get acceptedFormats() {
    return [".pdf", ".png", ".jpg", ".jpeg"];
  }
  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    let uploadedFileNames = "";
    for (let i = 0; i < uploadedFiles.length; i++) {
      uploadedFileNames += uploadedFiles[i].name + ", ";
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message:
          uploadedFiles.length +
          " Files uploaded Successfully: " +
          uploadedFileNames,
        variant: "success"
      })
    );
  }

  handleFilesChange(event) {
    const file = event.target.files[0];

    const filetype1 = event.target.dataset.filetype;
    const recordid = event.target.dataset.recordid;
    console.log("filetype : ", JSON.stringify(recordid));

    var reader = new FileReader();
    reader.onload = () => {
      var base64input = reader.result.split(",")[1];
      this.fileData = {
        filename: file.name,
        base64: base64input,
        recordId: recordid,
        filetype: filetype1
      };
      //console.log(this.fileData)

      const { base64, filename, recordId, filetype } = this.fileData;
      //  uploadFiles({ base64 : base64,filename : filename, recordId: recordId, filetype : filetype }).then(result=>{
      uploadFiles({ base64, filename, recordId, filetype })
        .then((result) => {
          this.fileData = null;
          let title = `${filename} uploaded successfully!!`;
          this.showToast(
            "Success",
            "Renewal record created successfully.",
            "success"
          );
          this.notifyCHRMviaEmail(
            "Email_notification_on_file_upload_to_chrm_1716375322473"
          );
          this.uploadedfileId = result;
          console.log("THISFILE" + this.uploadedfileId);
          console.log("File uploaded successfully", title);
        })
        .catch((error) => {
          console.log("File uploaded failed", error);
        });
    };
    reader.readAsDataURL(file);
  }

  uploadBalanceDocumentHandler(event) {
    this.showUploadBalanceDocument = !this.showUploadBalanceDocument;
    this.recdId = event.currentTarget.dataset.recid;
  }

  handleDrop(event) {
    event.preventDefault();
    const files = event.dataTransfer.files;
    // Handle dropped files
    if (files.length > 0) {
      // Handle file upload logic here
      for (var i = 0; i < files.length; i++) {
        // if (event.target.files[i].size > MAX_FILE_SIZE) {
        //     this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
        //     return;
        // }
        console.log("Within for loop in files change");

        let file = files[i];
        let reader = new FileReader();
        reader.onload = (e) => {
          var fileContents = reader.result.split(",")[1];
          this.filesData.push({
            fileName: file.name,
            fileContent: fileContents
          });
        };
        reader.readAsDataURL(file);
      }
      console.log("File data is ", this.filesData);
      console.log(files, "files");
    }
  }

  handleBrowse() {
    const fileInput = this.template.querySelector(
      '.file-upload-design input[type="file"]'
    );
    fileInput.click();
  }

  handleDragOver(event) {
    event.preventDefault();
  }

  handleBalanceFilesChange(event) {
    console.log("Handle BalanceFile change invoked");
    console.log("Within files change");
    console.log("Within files change: files count", event.target.files.length);
    console.log("Within files change: rec Id", this.recdId);
    //this.recdId= event.currentTarget.dataset.recid;
    if (event.target.files.length > 0) {
      for (var i = 0; i < event.target.files.length; i++) {
        // if (event.target.files[i].size > MAX_FILE_SIZE) {
        //     this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
        //     return;
        // }
        console.log("Within for loop in files change");

        let file = event.target.files[i];
        let reader = new FileReader();
        reader.onload = (e) => {
          var fileContents = reader.result.split(",")[1];
          this.filesData.push({
            fileName: file.name,
            fileContent: fileContents
          });
        };
        reader.readAsDataURL(file);
      }
      console.log("File data is ", this.filesData);
    }
  }

  uploadBalanceFiles() {
    if (this.filesData == [] || this.filesData.length == 0) {
      this.showToast("Error", "Please select files first", "error");
      return;
    }
    this.showSpinner = true;
    console.log("brRecord id is ", this.brRecordId);
    uploadMultipleBalanceFiles({
      brRecordId: this.brRecordId,
      filedata: JSON.stringify(this.filesData)
    })
      .then((result) => {
        console.log(result);
        if (result && result == "success") {
          this.filesData = [];

          this.showToast("Success", "Successfully uploaded file.", "success");
        } else {
          this.showToast("Error", result, "error");
        }
      })
      .catch((error) => {
        if (error && error.body && error.body.message) {
          this.showToast("Error", error.body.message, "error");
        }
      })
      .finally(() => (this.showSpinner = false));
  }

  uploadFiles() {
    if (this.filesData == [] || this.filesData.length == 0) {
      this.showToast("Error", "Please select files first", "error");
      return;
    }
    this.showSpinner = true;
    uploadMultipleFiles({
      recordId: this.recdId,
      filedata: JSON.stringify(this.filesData)
    })
      .then((result) => {
        console.log(result);
        if (result && result == "success") {
          this.filesData = [];

          this.showToast("Success", "Successfully uploaded file.", "success");
        } else {
          this.showToast("Error", result, "error");
        }
      })
      .catch((error) => {
        if (error && error.body && error.body.message) {
          this.showToast("Error", error.body.message, "error");
        }
      })
      .finally(() => (this.showSpinner = false));
  }

  removeReceiptImage(event) {
    var index = event.currentTarget.dataset.id;
    this.filesData.splice(index, 1);
  }

  notifyCHRMviaEmail(templateDevName) {
    sendEmailToCHRM({
      emailAddList: this.listOfEmails,
      templateApiName: templateDevName,
      recId: this.conId
    })
      .then((result) => {
        console.log("email sent to chrm team ");
      })
      .catch((error) => {
        console.log("Email send failed", error.message);
      });
  }
  fileData;

  expiryDurationClass(num) {
    if (num < 15) return "expiry-inactive";
    else if (num >= 15 && num <= 50) return "expiry-warning";
    else if (num > 50) return "expiry-active";
  }

  updateBRRecords(event) {
    let dataset = [];

    // Get all date picker elements
    const expiryDateInputs = this.template.querySelectorAll(".BRExpiryDate");

    // Iterate over each date picker and construct the dataset
    expiryDateInputs.forEach((input) => {
      // Get the selected expiry date
      const expiryDate = input.value;

      // Get the fileId associated with this row
      const recId = input.dataset.id;

      // Construct the dataset for this row
      let rowData = {
        Id: recId,
        expiryDate: expiryDate
        // Add more fields to the rowData object as needed
      };

      if (rowData.expiryDate) dataset.push(rowData);
    });

    // Now, dataset contains all data from all rows
    console.log(dataset);
    updateBRHistoryRecord({ fileExpiryList: dataset })
      .then((result) => {
        // Handle success response
        refreshApex(this.wiredActivities);
        this.disableSubmitBtn = true;
        const messagePayload = {
          flag: true
        };
        publish(this.messageContext, msgService, messagePayload);
        this.showToast("Success", "Successfully updated record.", "success");
        console.log("Processed successfully:", result);
      })
      .catch((error) => {
        // Handle error response
        this.showToast("Error", "Failed to update record.", "error");
        console.error("Error processing file expiry list:", error);
      });
  }

  handleExpiryDate(event) {
    try {
      const expiryDateInputs = this.template.querySelectorAll(".dateUpdate");
      console.log(
        Array.isArray(expiryDateInputs),
        typeof expiryDateInputs,
        expiryDateInputs,
        "expiryDateInputs1"
      );
      let checkUpdate = false;
      expiryDateInputs.forEach((input) => {
        checkUpdate = checkUpdate || input.value.length != 0;
        console.log(
          "OUTPUT : expiryDateInputs1",
          checkUpdate,
          checkUpdate || input.value.length == 0,
          input.value,
          input.value.length
        );
      });
      if (checkUpdate) {
        this.disableSubmitBtn = false;
      } else {
        this.disableSubmitBtn = true;
      }
      console.log(expiryDateInputs, this.disableSubmitBtn, "expiryDateInputs1");
    } catch (error) {
      console.log("Error-->handleExpiryDate", error.message);
    }
  }

  handleProfileChange(event) {
    const file = event.target.files[0];
    console.log(file.type);

    let base64Data = "";
    let fileReader = new FileReader();
    // set onload function of FileReader object
    fileReader.onloadend = () => {
      base64Data = fileReader.result.split(",")[1];
      this.setProfilePicture(
        file.name,
        file.type,
        encodeURIComponent(base64Data)
      );
      console.log("FileBase64" + base64Data);
    };

    console.log("121");

    fileReader.readAsDataURL(file);
    console.log("4as54");
  }
  fileId = "";
  setProfilePicture(name, type, base64) {
    console.log("111");
    setUserPhoto({
      fileName: name,
      fileType: type,
      base64Data: base64
    })
      .then((smallPhotoUrl) => {
        console.log(smallPhotoUrl);
        //this.fileId = smallPhotoUrl;
        refreshApex(this.wiredData);
        //alert('uploaded');
        location.reload();
      })
      .catch((error) => { });
    console.log("454");
  }

  triggerFileInput() {
    const fileInput = this.template.querySelector(".file-input");
    fileInput.click();
    this.showDropdown = false;
  }

  handleDeleteImage() {
    //if (this.fileId) {
    deleteUserPhoto()
      .then(() => {
        refreshApex(this.wiredData);
        // this.photoUrl = 'https://via.placeholder.com/150';
        //this.fileId = null;
        this.showDropdown = false;
        this.showToast("Success", "File deleted successfully.", "success");
        location.reload();
      })
      .catch((error) => {
        console.log("File delete failed" + error);
        console.error("File delete failed", error);
        this.showToast("Error", "File delete failed.", "error");
      });
    // } else {
    //     this.photoUrl = 'https://via.placeholder.com/150';
    //     this.showDropdown = false;
    // }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
  uploadModuleDropDownChange(event) {
    this.UploadModuleSelectedText = event.target.value;
    console.log("selection is ");
    let selection = event.target.value;
    console.log(selection);
    if (selection == "View Secondary Documents") {
      this.showBalanceFiles = true;
    } else {
      this.showBalanceFiles = false;
    }
  }
  get SelectOptions() {
    return [
      { label: "View Primary Documents", value: "View Primary Documents" },
      { label: "View Secondary Documents", value: "View Secondary Documents" }
    ];
  }
  policiesButtonClickHandler(event) {
    getPolicyFiles()
      .then((result) => {
        this.policyFiles = result;
        console.log("Policies button click handler result is ", result);
      })
      .catch((error) => {
        console.error("Error retrieving policy files:", error);
        // Optionally, show a toast message or handle the error
      });
    console.log("clicked policies");
    this.showPolicies = !this.showPolicies;
  }
}