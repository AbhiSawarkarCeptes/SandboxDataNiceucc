import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import createCase from '@salesforce/apex/BRPortalHeaderButtonController.createCase';
import getAllCasesByCurrentUser from '@salesforce/apex/BRPortalHeaderButtonController.getAllCasesByCurrentUser';
import portalEnquiryPage from '@salesforce/resourceUrl/portalEnquiryPage';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';
import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import { NavigationMixin } from "lightning/navigation";

const PAGE_SIZE = 4;

export default class BrPortalHeaderButton extends NavigationMixin(LightningElement) {
    @track show_Spinner = false;
    @track email = '';
    @track subject = '';
    @track phone = '';
    @track Remarks = '';
    @track isModalOpen = false;
    @track isRecordCreated = false;
    @track caseDetails;
    @track page = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track caseDetailsPage = [];
    @track pagedCaseDetails = [];
    @track currentPage = 1;
    @track showThankYouMessage = false;
    @track disableGeneralEnquiry = true;
    thankYouMessageClass = 'thank-you-message';
    sobhaRealityImageUrl = CommonIcons + '/commonIcons/sobhaRealtyTextIcon.svg';
    emailAddress;
    subject;
    body;
    logout_icon = 'background: url(' + portalAssests + '/assets/images/logout-icon.svg) left 13% center no-repeat';
    isEnquiryFormVisible = false;
    
    connectedCallback() {
        isEligibleForAction()
        .then(result => {
            if(result == false) {
                this.disableGeneralEnquiry = true;
            } else {
                this.disableGeneralEnquiry = false;
            }
        })
        .catch(error => {
            console.log(error);
        });
        loadStyle(this, portalEnquiryPage);
        this.loadCaseDetails();
        this.totalPages = Math.ceil(this.caseDetailsPage.length / PAGE_SIZE);
        //Start data refresh interval
    }
    
    async logoutCommunity() {
        this.show_Spinner = true;
        //let logoutURL = window.location.origin + '/secur/logout.jsp';
        //window.location.replace(logoutURL + '?retUrl=' + '/newBrokerPortal/BRPortalLogin');
        //let logoutURL = 'https://www.sobhapartnerportal.com/CustomLoginPage';
        //window.location.replace(logoutURL);

        // Logout
        const logoutUrl = await getLogoutUrl();
        await fetch(logoutUrl);

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: window.location.origin + '/newBrokerPortal/BRPortalLogin'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, '_self');
        });
    }

    toggleForm() {
        this.loadCaseDetails();
        this.isEnquiryFormVisible = true;
    }

    hideModalBox() {
        this.isEnquiryFormVisible = false;
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
    }

    async handleSubmit() {
        this.isEnquiryFormVisible = false;
        if(!this.email || !this.phone || !this.Remarks || !this.subject) {
            this.isEnquiryFormVisible = true;
            // Show error toast if any required field is empty
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please provide values for all required fields.',
                variant: 'error'
            });
            this.dispatchEvent(event);
            return;
        }
        this.show_Spinner = true;
        createCase({
            email: this.email,
            phone: this.phone,
            Remarks: this.Remarks,
            Subject: this.subject
        }).then(result => {
            // Handle success
            console.log('Service request created successfully:', result);
            if (!result.includes('maintained')) {
                this.isRecordCreated = true;
                this.loadCaseDetails(result);
                
                // Show success toast
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Service request submitted successfully & Sent an email sucessfully.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            } else if(result.includes('maintained')) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: result,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.isEnquiryFormVisible = true;
            }
            //this.isEnquiryFormVisible = false;
            // Reset input fields
            this.email = '';
            this.phone = '';
            this.Remarks = '';
            this.subject = '';
            // Load case details after 3 seconds
            /*setTimeout(() => {
                this.loadCaseDetails();
            }, 3000);*/
            this.loadCaseDetails();
            this.show_Spinner = false;
        }).catch(error => {
            // Handle error
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error creating service request: ' + error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
            this.isEnquiryFormVisible = true;
            this.show_Spinner = false;
        });
    }

    loadCaseDetails() {
        getAllCasesByCurrentUser({ pageNumber: this.page, pageSize: PAGE_SIZE })
            .then(result => {
                this.caseDetails = result;
                let tempResult = JSON.parse(JSON.stringify(result));
                let tempAry = [];
                tempResult.forEach(obj => {
                    let tempObj = obj;
                    tempObj.className = 'new';
                    if (tempObj.srRecord.PropStrength__Status__c == 'In Progress') {
                        tempObj.className = 'pending';
                    } else if (tempObj.srRecord.PropStrength__Status__c == 'Closed') {
                        tempObj.className = 'approved';
                    }
                    tempAry.push(tempObj);
                });
                this.caseDetailsPage = tempAry;
                this.totalRecords = result.length;
                this.totalPages = Math.ceil(this.totalRecords / PAGE_SIZE);
            })
            .catch(error => {
                console.error('Error fetching case details:', error);
            });
    }

    formatCaseDetails(caseDetails) {
        return caseDetails.map(caseDetail => ({
            ...caseDetail,
            formattedCreatedDate: this.formatDate(caseDetail.srRecord.CreatedDate)
        }));
    }

    formatDate(dateTimeString) {
        const options = { day: '2-digit', month: 'long', year: 'numeric' };
        const date = new Date(dateTimeString);
        return new Intl.DateTimeFormat('en-GB', options).format(date);
    }

    resetForm() {
        this.email = '';
        this.subject = '';
        this.phone = '';
        this.Remarks = '';
    }

    updatePagedCaseDetails() {
        const startIndex = (this.currentPage - 1) * PAGE_SIZE;
        const endIndex = this.currentPage * PAGE_SIZE;
        this.pagedCaseDetails = this.caseDetailsPage.slice(startIndex, endIndex);
    }

    previousPage() {
        if (this.page > 1) {
            this.page--;
            this.updateCurrentPage();
        }
    }

    nextPage() {
        if (this.page < this.totalPages) {
            this.page++;
            this.updateCurrentPage();
        }
    }

    updateCurrentPage() {
        // Update the current page number displayed
        this.currentPage = this.page;
    }

    get isFirstPage() {
        return this.page === 1;
    }

    get isLastPage() {
        return this.page === this.totalPages;
    }

    get paginatedCaseDetails() {
        const startIndex = (this.page - 1) * PAGE_SIZE;
        const endIndex = this.page * PAGE_SIZE;
        return this.caseDetailsPage.slice(startIndex, endIndex);
    }

    formattedDate(dateTimeString) {
        const options = { day: '2-digit', month: 'long', year: 'numeric' };
        const date = new Date(dateTimeString);
        return new Intl.DateTimeFormat('en-GB', options).format(date);
    }
}