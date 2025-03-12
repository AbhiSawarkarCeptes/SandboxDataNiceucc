import { LightningElement, api, wire } from "lwc";
import portalAssests from "@salesforce/resourceUrl/portalBrokerAssets";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getProfileDetails from "@salesforce/apex/PortalBrokerEventsController.getProfileDetails";
import renewAgreement from "@salesforce/apex/PortalBrokerEventsController.renewAgreement";
import getPolicyFiles from "@salesforce/apex/PortalBrokerEventsController.getPolicyFiles";
import getBaseURL from "@salesforce/apex/PortalBrokerEventsController.getBaseURL";
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

export default class BrokerPortalShowPDF extends LightningElement {
  //@api fileId;
  //@api heightInRem;
  @api fileURL;
  downloadIcon = portalAssests + "/assets/images/download-agreement.svg";
  view_icon = portalAssests + "/assets/images/view-icon.svg";
  download_icon = portalAssests + "/assets/images/download.svg";
  upload_doc_icon = portalAssests + "/assets/images/upload-doc-icon.svg";
  upload_icon = portalAssests + "/assets/images/upload-doc-icon.svg";
  policiesUrl;
  policyURLS = [];
  baseUrl;
  get pdfHeight() {
    return "height: 800 rem";
  }

  get url() {
    //"doc_Link":"https://sobharealty--sobhaqadxb.sandbox.my.salesforce.com/sfc/servlet.shepherd/document/download/069JX00000298usYAA"
    return "/sfc/servlet.shepherd/document/download/069JX000002OXg1YAG";
  }

  @wire(getBaseURL)
  getBaseURLInfo({ data, error }) {
    this.baseUrl = data;
  }

  @wire(getPolicyFiles)
  getPolicyFilesInfo({ data, error }) {
    if (data) {
      console.log("data is " + JSON.stringify(data));
      // this.policiesUrl= data.map(item => {
      this.policiesUrl = this.transformPolicies(data);
    }
    if (error) {
      console.log("Error is ", error);
    }
  }

  transformPolicies(policiesUrl) {
    return Object.keys(policiesUrl).map((policyName) => ({
      Name: policyName,
      Url: URL.createObjectURL(
        new Blob([this.base64ToArrayBuffer(policiesUrl[policyName])], {
          type: "application/pdf"
        })
      )
    }));
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
}