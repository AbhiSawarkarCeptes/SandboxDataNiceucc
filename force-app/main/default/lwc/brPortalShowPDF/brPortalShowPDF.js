import { LightningElement, api, wire } from 'lwc';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import getPolicyFiles from '@salesforce/apex/BRPortalBrokerEventsController.getPolicyFiles';
import getBaseURL from '@salesforce/apex/BRPortalBrokerEventsController.getBaseURL';

export default class BrPortalShowPDF extends LightningElement {
    @api fileURL
    downloadIcon = portalAssests + '/assets/images/download-agreement.svg';
    view_icon = portalAssests + '/assets/images/view-icon.svg';
    download_icon = portalAssests + '/assets/images/download.svg';
    upload_doc_icon = portalAssests + '/assets/images/upload-doc-icon.svg';
    upload_icon = portalAssests + '/assets/images/upload-doc-icon.svg';
    policiesUrl
    policyURLS=[];
    baseUrl;
    policyInfo;

    //policy1URL = portal_Policy1 + '.pdf';

    get pdfHeight() {
        return 'height: 800 rem';
    }

    get url() {
        //"doc_Link":"https://sobharealty--sobhaqadxb.sandbox.my.salesforce.com/sfc/servlet.shepherd/document/download/069JX00000298usYAA"
        return '/sfc/servlet.shepherd/document/download/069JX000002OXg1YAG';
    }

    @wire(getBaseURL)
    getBaseURLInfo({ data, error }) {
        this.baseUrl=data;
    }

    @wire(getPolicyFiles)
    getPolicyFilesInfo({ data, error }) {
        /*if (data) {
            console.log('data is ' + JSON.stringify(data));
            // this.policiesUrl= data.map(item => {
            this.policiesUrl= this.transformPolicies(data);
        }
        if (error) {
            console.log("Error is ", error);
        }*/
        if (data) {
            this.policyInfo = data;
            this.policyInfo = data.map(item => {
                return {
                    policyName: item.policyName,
                    viewURL: item.viewURL
                };
            });
        } else if (error) {
            console.log("Error is ", error);
        }
    }

    transformPolicies(policiesUrl) {
        return Object.keys(policiesUrl).map(policyName => ({
            Name: policyName,
            Url: policiesUrl[policyName]
        }));
    }
}