import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import createCase from '@salesforce/apex/CaseController.createCase';
import sendEmail from '@salesforce/apex/CaseController.sendEmail';
import fetchEmailTemplateInfo from '@salesforce/apex/CaseController.fetchEmailTemplateInfo';
import getAllCasesByCurrentUser from '@salesforce/apex/CaseController.getAllCasesByCurrentUser';
import portalEnquiryPage from '@salesforce/resourceUrl/portalEnquiryPage';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';


const PAGE_SIZE = 4;

export default class PortalHeaderButtons extends LightningElement {
    @track email = '';
    @track subject = '';
    @track phone = '';
    @track Remarks = '';
    @track Subject = '';
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
    thankYouMessageClass = 'thank-you-message';
    sobhaRealityImageUrl = CommonIcons + '/commonIcons/sobhaRealtyTextIcon.svg';
    emailAddress;
    subject;
    body;
    columns = [
        {
            label: 'Enqury Number',
            type: "text",
            fieldName: "CaseNumber", wrapText: true
        },
        { label: 'Date', fieldName: "CreatedDate", type: "text", wrapText: true },
        { label: 'Supplied Email', fieldName: "SuppliedEmail", type: "text", wrapText: true },
        { label: 'Contact Phone', fieldName: "SuppliedPhone", type: "text", wrapText: true },
        { label: 'Status', fieldName: "Status", type: "text", wrapText: true }
    ];
    logout_icon = 'background: url(' + portalAssests + '/assets/images/logout-icon.svg) left 13% center no-repeat';

    isEnquiryFormVisible = false;
    connectedCallback() {
        loadStyle(this, portalEnquiryPage);
        this.loadCaseDetails();
        this.totalPages = Math.ceil(this.caseDetailsPage.length / PAGE_SIZE) == 0 ? 1 : Math.ceil(this.caseDetailsPage.length / PAGE_SIZE);
        // Start data refresh interval

    }

    logout() {
        // let logoutURL = window.location.origin + '/brokerportal/CustomLoginPage';
        sessionStorage.removeItem("showOffersPopUp");
        let logoutURL = 'https://www.sobhapartnerportal.com/CustomLoginPage';
        window.location.replace(logoutURL);
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
        console.log("SEE" + this.phone);
        console.log("SEE2" + this.email);
        console.log("Subject" + this.Subject);
        console.log("SEE3" + this.Remarks);
        /*  try {
               console.log("INSEE"+this.phone);
             console.log("INSEE2"+this.email);
              console.log("INSEE3"+this.Remarks);
             const templateInfo = await fetchEmailTemplateInfo({ templateName: 'CreateEnquiry' });
             this.subject = templateInfo.Subject;
             this.body = templateInfo.Body;
             console.log(" this.body"+ this.body);
              console.log(" this.subject"+ this.subject);
             await sendEmail({ emailAddress: this.email, subject: this.subject, body: this.body });
             Console.log("Sent mail sucessfully");
             this.showThankYouMessage = true;
         } catch(error) {
             console.log("Error "+ JSON.stringify(error));
         } */
        //code changes by-Shaik Rehaman
        if (!this.email || !this.phone || !this.Remarks || !this.Subject) {
            // Show error toast if any required field is empty
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please provide values for all required fields',
                variant: 'error'
            });
            this.dispatchEvent(event);
            return;
        }
        //code changes by-Shaik Rehaman
        createCase({
            email: this.email,
            phone: this.phone,
            Remarks: this.Remarks,
            Subject: this.Subject
        }).then(result => {
            // Handle success
            console.log('Case created successfully:' + JSON.stringify(result));
            this.isRecordCreated = true;
            this.loadCaseDetails(result);
            this.isEnquiryFormVisible = false;

            // Show success toast
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Case submitted successfully & Sent mail sucessfully',
                variant: 'success'
            });
            this.dispatchEvent(event);
            // Reset input fields
            this.email = '';
            this.phone = '';
            this.Remarks = '';
            this.Subject = '';

            // Load case details after 3 seconds
            setTimeout(() => {
                this.loadCaseDetails();
            }, 3000);

        }).catch(error => {
            // Handle error
            console.error('Error creating case:', error);

            // Show error toast
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Error creating case: ' + error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        });

        // Logic to Hide the message after a 3 seconds 
        /*  window.setTimeout(() => {
                this.showThankYouMessage = false;
            }, 3000); */

        //    //LOGIC TO SHOW CREATED CASE DETAILS IN TABLE AFTER 3 SECONDS
        //     setInterval(() => {
        //     this.loadCaseDetails();
        // }, 3000);
    }

    loadCaseDetails() {
        getAllCasesByCurrentUser({ pageNumber: this.page, pageSize: PAGE_SIZE })
            .then(result => {
                console.log("CASE" + JSON.stringify(result));
                this.caseDetails = result;
                let tempResult = JSON.parse(JSON.stringify(result));
                let tempAry = [];
                tempResult.forEach(obj => {
                    let tempObj = obj;
                    tempObj.className = 'new';
                    if (tempObj.Status == 'In Progress') {
                        tempObj.className = 'pending';
                    } else if (tempObj.Status == 'Closed') {
                        tempObj.className = 'approved';
                    }
                    tempAry.push(tempObj);
                });
                this.caseDetailsPage = this.formatCaseDetails(tempAry);
                console.log("this.caseDetailsPage" + JSON.stringify(this.caseDetailsPage));
                this.totalRecords = result.length;
                if (this.totalRecords > 0) {
                    this.totalPages = Math.ceil(this.totalRecords / PAGE_SIZE);
                }
            })
            .catch(error => {
                console.error('Error fetching case details:', error);
            });
    }
    formatCaseDetails(caseDetails) {
        return caseDetails.map(caseDetail => ({
            ...caseDetail,
            formattedCreatedDate: this.formatDate(caseDetail.CreatedDate)
        }));
    }

    formatDate(dateTimeString) {
        const options = { day: '2-digit', month: 'long', year: 'numeric' };
        const date = new Date(dateTimeString);
        return new Intl.DateTimeFormat('en-GB', options).format(date);
    }
    resetForm() {
        this.email = '';
        this.Subject = '';
        this.phone = '';
        this.description = '';
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