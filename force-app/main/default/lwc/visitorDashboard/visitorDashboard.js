import { LightningElement, track, api, wire } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVisitors from '@salesforce/apex/VisitorDashboardController.getVisitors';
import acceptRejectVisitor from '@salesforce/apex/VisitorDashboardController.acceptRejectVisitor';
import getContentDocumentId from '@salesforce/apex/VisitorDashboardController.getContentDocumentId';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import IMAGE_URL_FIELD from 
    '@salesforce/schema/ContentDocument.LatestPublishedVersion.VersionDataUrl';
export default class VisitorDashboard extends NavigationMixin(LightningElement) {
    
    @track visitorData=[];

    subscription = {};
    @api channelName = '/event/Visitor__e';

    @track isViewModalOpen = false;
    @track isEditModalOpen = false;
    @track visitorId = '';
    @track isBtnDisabled = false;

    showSpinner = false;
    showSpinnerModal = false;

    @track docId;

    @wire(getRecord, {recordId: '$docId', fields: [IMAGE_URL_FIELD] })
    contentDocImage;

    get imageUrl() {
        return getFieldValue(this.contentDocImage.data, IMAGE_URL_FIELD);
    }

    connectedCallback() {
        this.registerErrorListener();
        this.handleSubscribe();
        this.loadVisitors();
    }
 
    handleSubscribe() {
        console.log('inside subscribe0');
        const self = this;
        const messageCallback = function (response) {
            console.log('inside subscribe1');
            self.loadVisitors();
            
        };
        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('inside subscribe2');
            this.subscription = response;
        });
    }

    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }

    loadVisitors(){
        this.showSpinner = true;
        getVisitors()
            .then(result=>{
                this.showSpinner = false;
                this.visitorData = result;
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('getVisitors errors: '+error.message);
            }); 
    }

    viewVisitor(event){
        this.contentDocImage = null;
        this.showSpinnerModal = true;
        var visId = event.currentTarget.id;
        visId = visId.split('-')[0];
        this.visitorId=visId;
        getContentDocumentId({visitorId : visId})
            .then(result=>{
                this.docId = result;
                this.isViewModalOpen=true;
                setTimeout(() => {
                    this.showSpinnerModal = false;
                }, 2000);
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('getContentDocumentId errors: '+error.message);
            });
    }

    closeViewModal(event){
        this.isViewModalOpen=false;
    }

    editVisitor(event){
        var visId = event.currentTarget.id;
        visId = visId.split('-')[0];
        this.visitorId=visId;
        this.isEditModalOpen=true;
    }

    closeEditModal(event){
        this.isEditModalOpen=false;
    }

    submitVisitorDetails(event){
        this.isEditModalOpen=false;
        this.isViewModalOpen=false;
    }

    handleEditSubmit(event){
        this.isEditModalOpen=false;
    }

    handleEditSuccess(event){
        this.isEditModalOpen=false;
        this.loadVisitors();
    }

    navigateToVisitorRegistration(event){
        let recId = event.currentTarget.id;
        recId = recId.split('-')[0];
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: 'Visitor_Registration__c',
                actionName: 'view'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

    acceptVisitor(event){
        if(confirm("Are you sure you want to approve?")){
            this.isBtnDisabled = true;
            let recId = this.visitorId;
            this.showSpinnerModal = true;
            acceptRejectVisitor({visitorId : recId, status : 'Accepted', proceedWithExistingLead : false})
                .then(result=>{
                    this.showSpinnerModal = false;
                    let msg = 'Visitor accepted successfully.';
                    if(result.includes('success')){
                        /*if(result.includes('#')){
                            msg = 'Visitor accepted successfully. Opportunity Id: '+result.split('#')[1] + ' | Site Visit Id: '+result.split('#')[2];
                        }*/

                        this.loadVisitors();
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: msg,
                        });
                        this.dispatchEvent(evt);
                        this.isViewModalOpen=false;
                    }
                    else if(result.includes('site visit happend')){
                        //if(confirm(result)){
                            this.showSpinnerModal = true;
                            acceptRejectVisitor({visitorId : recId, status : 'Accepted', proceedWithExistingLead : true})
                            .then(result=>{
                                this.showSpinnerModal = false;
                                let msg = 'Visitor accepted successfully.';
                                if(result.includes('success')){
                                    /*if(result.includes('#')){
                                        msg = 'Visitor accepted successfully. Opportunity Id: '+result.split('#')[1] + ' | Site Visit Id: '+result.split('#')[2];
                                    }*/
                                    this.loadVisitors();
                                    const evt = new ShowToastEvent({
                                        variant: 'success',
                                        message: msg,
                                    });
                                    this.dispatchEvent(evt);
                                    this.isViewModalOpen=false;
                                }
                                else{
                                    const evt = new ShowToastEvent({
                                        variant: 'error',
                                        message: result,
                                    });
                                    this.dispatchEvent(evt);
                                }
                                this.isBtnDisabled = false;
                            })
                            .catch(error => {
                                this.showSpinnerModal = false;
                                this.isBtnDisabled = false;
                                console.log('acceptVisitor errors: '+error.message);
                            }); 
                        //}
                    }
                    else{
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: result,
                        });
                        this.dispatchEvent(evt);
                    }
                    this.isBtnDisabled = false;
                })
                .catch(error => {
                    this.showSpinnerModal = false;
                    this.isBtnDisabled = false;
                    console.log('acceptVisitor errors: '+error.message);
                }); 
        }
        else{
            
        }
    }

    rejectVisitor(event){
        if(confirm("Are you sure you want to reject?")){
            this.isBtnDisabled = true;
            let recId = this.visitorId;
            this.showSpinnerModal = true;
            acceptRejectVisitor({visitorId : recId, status : 'Rejected', proceedWithExistingLead : false})
                .then(result=>{
                    this.showSpinnerModal = false;
                    if(result=='success'){
                        this.loadVisitors();
                        const evt = new ShowToastEvent({
                            variant: 'success',
                            message: 'Visitor rejected successfully.',
                        });
                        this.dispatchEvent(evt);
                        this.isViewModalOpen=false;
                    }
                    else{
                        const evt = new ShowToastEvent({
                            variant: 'error',
                            message: result,
                        });
                        this.dispatchEvent(evt);
                    }
                    this.isBtnDisabled = false;
                })
                .catch(error => {
                    this.showSpinnerModal = false;
                    this.isBtnDisabled = false;
                    console.log('rejectVisitor errors: '+error.message);
                });
        }
        else{
            
        }
    }
}