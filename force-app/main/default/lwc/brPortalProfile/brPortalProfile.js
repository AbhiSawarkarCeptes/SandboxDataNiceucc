import { LightningElement, wire, api, track } from 'lwc';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getProfileDetails from '@salesforce/apex/BRPortalBrokerEventsController.getProfileDetails';
import renewAgreement from '@salesforce/apex/BRPortalBrokerEventsController.renewAgreement';
import getRelatedContacts from '@salesforce/apex/BRPortalBrokerEventsController.getRelatedContacts';
import getBRFileHistory from '@salesforce/apex/BRPortalBrokerEventsController.getBRFileHistory';
import updateBRHistoryRecord from '@salesforce/apex/BRPortalBrokerEventsController.updateBRHistoryRecord';
import sendEmailToCHRM from '@salesforce/apex/BRPortalBrokerEventsController.sendEmailToCHRM';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import uploadFiles from '@salesforce/apex/BRPortalBrokerEventsController.uploadFiles';
import { refreshApex } from '@salesforce/apex';
import uploadMultipleFiles from '@salesforce/apex/BRPortalBrokerEventsController.uploadMultipleFiles';
import uploadMultipleBalanceFiles from '@salesforce/apex/BRPortalBrokerEventsController.uploadMultipleBalanceFiles';
import setUserPhoto from '@salesforce/apex/BRPortalBrokerEventsController.setProfilePicture';
import deleteUserPhoto from '@salesforce/apex/BRPortalBrokerEventsController.deleteUserPhoto';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';
import getPdfFile from '@salesforce/apex/BRPortalBrokerEventsController.getBodyFile';
import getImgFile from '@salesforce/apex/BRPortalBrokerEventsController.getBodyFile';
import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';
import getPolicyFiles from '@salesforce/apex/BRPortalBrokerEventsController.getPolicyFiles';

export default class BRPortalProfile extends NavigationMixin(LightningElement) {
    @track recdId
    @track brRecordId
    @track conId
    showUploadBalanceDocument = false;
    @track filesData = [];
    @track showDropdown = false;
    @track showFileInput = false;
    firstCall = true;
    showDocumentUploadModule = false;
    profileInfo
    downloadIcon = portalAssests + '/assets/images/download-agreement.svg';
    view_icon = portalAssests + '/assets/images/view-icon.svg';
    download_icon = portalAssests + '/assets/images/download.svg';
    upload_doc_icon = portalAssests + '/assets/images/upload-doc-icon.svg';
    upload_icon = portalAssests + '/assets/images/upload-doc-icon.svg';
    onUploadStatus = false;
    relatedCons
    fileUrl;
    uploadedfileId;
    showDocumentModule = false;
    brFilesInfo
    filesCount
    listOfEmails = [];
    wiredActivities = {}
    showBalanceFiles = false;
    pencilIcon = CommonIcons + "/commonIcons/pen-bold.svg"
    UploadModuleSelectedText = 'View Primary Documents'
    showSpinner = false;
    showPdfFile = false;
    showImgFile = false;
    fileUrlPreview;
    showPolicies = false;
    policiesUrl = '/sfc/servlet.shepherd/document/download/069JX000002OXg1YAG';
    @track isEligible = 'main-panel';
    @track policyFiles;


    @wire(getBRFileHistory, { showBalanceFiles: '$showBalanceFiles' })
    getBRFileHistoryMethod(result) {
        this.wiredActivities = result;
        // Destructure the provisioned value
        const { error, data } = result;
        console.log("getBRFileHistoryMethod portion is aaaaaaaaaaaaaaa ", JSON.stringify(result));
        if (data) {
            console.log("getBRFileHistoryMethod portion is ", JSON.stringify(data));
            const date = new Date();
            const formattedDate = date.toISOString().split('T')[0];
            console.log(formattedDate);
            console.log(new Date().toISOString().split('T')[0]);
            this.brFilesInfo = data.map(item => {
                /*let fileName = item.fileName;
                console.log('===> fileName ' + fileName);
                if (item.fileName.includes('Agreement')) {
                    fileName = 'Agreement';
                } else if (item.fileName.includes('NOC')) {
                    fileName = 'NOC';
                } else if (item.fileName.includes('Trade')) {
                    fileName = 'Trade Licence';
                } else if (item.fileName.includes('RERA')) {
                    fileName = 'RERA Certificate';
                } else if (item.fileName.includes('Emirates')) {
                    fileName = 'Emirates ID';
                } else if (item.fileName.includes('Passport')) {
                    fileName = 'Passport';
                } else if (item.fileName.includes('Visa')) {
                    fileName = 'Visa Copy';
                }*/
                let expiryDateFormatted = '';
                if (item.expiryDate) {
                    console.log('===> item.expiryDate ' + item.expiryDate);
                    //expiryDateFormatted = new Date(item.expiryDate).toISOString().split('T')[0];
                    //expiryDateFormatted = new Date(item.expiryDate).toString();
                    expiryDateFormatted = item.expiryDate.split(' ')[0];
                    console.log('===> item.expiryDateFormatted ' + expiryDateFormatted);
                }
                //const expiryDuration = Math.ceil((new Date((item.expiryDate).toISOString().split('T')[0]) - new Date(new Date().toISOString().split('T')[0])) / (1000 * 60 * 60 * 24));
                const expiryDuration = Math.ceil((new Date(item.expiryDate) - new Date(new Date().toISOString().split('T')[0])) / (1000 * 60 * 60 * 24));
                //const expiryDuration = Math.ceil((new Date(item.expiryDate) - new Date(new Date().toString())) / (1000 * 60 * 60 * 24));
                const expiryClass = this.expiryDurationClass(expiryDuration);
                return {
                    fileId: item.fileId,
                    ...item.record,
                    expiryDate: expiryDateFormatted,
                    //  expiryDuration: (new Date(item.record.Expiry_date__c) - new Date()) / (1000 * 60 * 60 * 24),
                    expiryDuration: expiryDuration,
                    fileUrl: `${item.baseUrl}/sfc/servlet.shepherd/document/download/${item.fileId}`,
                    latestVersionId: item.latestVersionId,
                    baseUrl: item.baseUrl,
                    filetype: item.fileType,
                    fileName: item.fileName,
                    objectName: item.ObjectName,
                    recordId: item.recordId,
                    bolflg: (item.fileName.startsWith('Agreement') || item.fileName.startsWith('NOC')) ? true : false,
                    expiryClass,
                    isActiveExpiryClass : expiryClass === 'expiry-active',
                    isExpired: Math.ceil((new Date(item.expiryDate) - new Date(new Date().toISOString().split('T')[0])) / (1000 * 60 * 60 * 24)) > 0 ? true : false
                };
            });
            console.log("ContentDocument portion is ", JSON.stringify(this.brFilesInfo));
            this.filesCount = this.brFilesInfo ? this.brFilesInfo.filter(item => item.expiryDuration <= 30).length : '';
        }
        else if (error) {
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
        }
        else if (error) {
            console.log("Error is ", error);
        }
    }
    get downloadUrl() {
        return this.profileInfo ? this.profileInfo.doc_Link : '';
    }
    get downloadNOCUrl() {
        return this.profileInfo ? this.profileInfo.NOC_Link : '';
    }
    connectedcallback() {
        let isEligibleAction = isEligibleForAction();
        if(isEligibleAction == false) {
            this.isEligible = 'disableAction';
        }
    }

    @wire(getRelatedContacts)
    getRelatedContacts({ error, data }) {
        if (data) {
            console.log("Related contact data is  ", JSON.stringify(data));
            //this.profileInfo = data;
            this.relatedCons = data;
        }
        else if (error) {
            console.log("Error is ", error);
        }
    }
    get firstName() { return this.profileInfo && this.profileInfo.Name ? this.profileInfo.Name : ''; }
    get email() { return this.profileInfo && this.profileInfo.Email_Id ? this.profileInfo.Email_Id : ''; }
    get mobileNumber() { return this.profileInfo && this.profileInfo.Mobile_No ? this.profileInfo.Mobile_No : ''; }
    get paasportNumber() { return this.profileInfo && this.profileInfo.Passport_No ? this.profileInfo.Passport_No : ''; }
    get regNumber() { return this.profileInfo && this.profileInfo.Reg_num ? this.profileInfo.Reg_num : ''; }
    get ownerName() { return this.profileInfo && this.profileInfo.owner_Id ? this.profileInfo.owner_Id : ''; }
    get brokerId() { return this.profileInfo && this.profileInfo.Broker_Id ? this.profileInfo.Broker_Id : ''; }
    get reraNumber() {
        return this.profileInfo && this.profileInfo.Rera_no ? this.profileInfo.Rera_no : '';
    }
    get expiryDate() { return this.profileInfo && this.profileInfo.Expiry_Date ? this.formatDate(this.profileInfo.Expiry_Date) : ''; }
    formatDate(str) {
        var arr = str.split("-");
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var month = months[parseInt(arr[1] - 1)];
        return arr[2] + ' ' + month + ' ' + arr[0];
    }
    get expiryDateDays() {
        if (this.profileInfo && this.profileInfo.Expiry_Date) {
            const expiryDate = new Date(this.profileInfo.Expiry_Date);
            const currentDate = new Date();
            const timeDifference = expiryDate.getTime() - currentDate.getTime();
            const daysRemaining = Math.ceil(timeDifference / (1000 * 3600 * 24)); // Convert milliseconds to days
            return daysRemaining;
        }
        return '';
    }
    get CompanyName() { return this.profileInfo && this.profileInfo.CompanyName ? this.profileInfo.CompanyName : ''; }
    get authManagerName() { return this.profileInfo && this.profileInfo.auth_Id ? this.profileInfo.auth_Id : ''; }
    get Title() { return this.profileInfo && this.profileInfo.Title ? this.profileInfo.Title : ''; }
    get address() {
        if (this.profileInfo && this.profileInfo.Address) {
            return this.profileInfo.Address.replace(/\b\w/g, char => char.toUpperCase())
                                           .replace(/\B\w/g, char => char.toLowerCase());
        }
        return '';
    }
    get designationAuth() { return this.profileInfo && this.profileInfo.designation_Auth ? this.profileInfo.designation_Auth : ''; }
    get ownerEmailId() { return this.profileInfo && this.profileInfo.owner_Email_Id ? this.profileInfo.owner_Email_Id : ''; }
    get financeEmailId() { return this.profileInfo && this.profileInfo.finance_Email_Id ? this.profileInfo.finance_Email_Id : ''; }

    get photoUrl() { return this.profileInfo && this.profileInfo.Photo_Url ? this.profileInfo.Photo_Url : ''; }
    get brokerType() { return this.profileInfo && this.profileInfo.Broker_Type ? this.profileInfo.Broker_Type : ''; }
    get isUnderRenewal() {
        return this.profileInfo ? this.profileInfo.Renewal_status : '';
    }
    renderedCallback() {
        if (this.firstCall) {
            this.firstCall = false;
            Promise.all([
                // loadScript(this,portalAssests+'/assets/js/main.js'),
                //loadStyle(this, portalAssests + '/assets/css/style.css')
            ]).then(() => {
                console.log('Files loaded successfully');
            })
            .catch((error) => {
                console.log('Something went wrong ', error);
            })
        }

    }
    handleIconClick() {
        this.showDropdown = !this.showDropdown;
    }
    renewalButtonHandler() {
        this.showSpinner = true;
        renewAgreement()
        .then(result => {
            console.log('===> result 185 ' + result);
            if (result && result == 'Success') {
                // Record created successfully
                console.log('Renewal record created: ' + result);
                this.showToast('Success', 'Renewal initiated successfully.', 'success');
            } else {
                // Handle error
                console.error('Failed to create renewal record.');
                this.showToast('Error', 'Failed to create renewal.', 'error');
            }
            this.showSpinner = false;
        })
        .catch(error => {
            // Handle error
            console.error('Error creating renewal record: ' + error.message);
            this.showToast('Error', 'Error creating renewal record.', 'error');
            this.showSpinner = false;
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
        console.log('Selected value changed to');
        this.showDocumentUploadModule = !this.showDocumentUploadModule;
        const selectElement = document.getElementById('documentSelect'); 
        console.log('Selected value changed to:', selectElement);
    }

    sidebarDownloadIconClickHandler() {
        console.log('test');
        console.log(this.profileInfo.doc_Link);
        console.log(this.profileInfo.NOC_Link);
        window.open(this.profileInfo.doc_Link, '_blank');
        setTimeout(() => {
            window.open(this.profileInfo.NOC_Link, '_blank');
        }, 3000);
        // window.open(this.profileInfo.doc_Link);
        // window.open(this.profileInfo.NOC_Link);
        /*const file1 = this.template.querySelector('a[ref="agreement"]');
        const file2 = this.template.querySelector('a[ref="noc"]');
        // Trigger click events on both anchor tags
        file1.click();
        console.log('Fiel 1 clicked')
        setTimeout(() => {
            file2.click();
        }, 3000);
        console.log('File 2 clicked')*/
    }

    viewIconClickHandler(event) {
        this.showSpinner = true;
        // Accessing the dataset property of the clicked element to retrieve the 'id' attribute
        const versionId = event.currentTarget.dataset.versionid;
        const baseUrl = event.currentTarget.dataset.baseurl;
        const filraddress = event.currentTarget.dataset.filraddress;
        //const finalURl = `${baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${versionId}`
        const finalURl = filraddress;
        // Log the fileId to ensure it's correctly retrieved
        console.log(finalURl);
        const finalFileType = event.currentTarget.dataset.filetype;
        console.log('===> finalFileType ' + finalFileType);
        console.log(versionId);
        let idsValue = this.getQueryParam(versionId, "ids");
        console.log('===> idsValue ' + idsValue);
        const contVerionId = idsValue;
        if (finalFileType != 'PDF') {
            console.log('not in pdf');
            this.getFileImg(contVerionId);
            this.showPdfFile = false;
            this.showDocumentUploadModule = false;
        } else if (finalFileType === 'PDF') {
            console.log('in pdf');
            this.showDocumentUploadModule = true;
            this.getFilePdf(contVerionId);
        }
        // Use NavigationMixin to navigate to the file preview page
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: versionId
        //     }
        // }, false);
    }

    getQueryParam(versionUrl, parameterName) {
        let resultValue = new URL(versionUrl).searchParams;
        return resultValue.get(parameterName);
    }

    hidePreviewModal() {
        this.showImgFile = false;
        this.showPdfFile = false;
        this.showDocumentUploadModule = true;
    }

    getFileImg(contVId) {
        getImgFile({ contVersionId: contVId})
        .then(result => {
            console.log(result);
            if (result != null) {
                this.fileUrlPreview = 'data:image/jpeg;base64,' + result;
                this.showImgFile = true;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.showSpinner = false;
        });
    }

    getFilePdf(contVId) {
        getPdfFile({ contVersionId: contVId})
        .then(result => {
            console.log('===> result 331 ' + result);
            if (result != null) {
                const blobVal = new Blob([this.base64ToArrayBuffer(result)], { type: 'application/pdf' });
                console.log(blobVal);
                this.fileUrlPreview = URL.createObjectURL(blobVal);
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.fileUrlPreview
                    }
                }, false);
            }
            this.showSpinner = false;
        })
        .catch(error => {
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

    downloadIconClickHandler() {
        alert("you clicked download icon");
    }

    uploadIconClickHandler(event) {
        alert("you clicked upload icon");
        let dataId = event.currentTarget.dataset.id;
        this.template.querySelector('span[data-id="' + dataId + '"] lightning-file-upload').click();
    }

    @track brRecordId;

    openfileUpload(event) {
        const version_Id = event.currentTarget.dataset.versionid;
        console.log('===> version_Id ' + version_Id);
        this.brRecordId = version_Id;
        console.log('===> this.brRecordId ' + this.brRecordId);
        //const getFileInput = this.template.querySelector("." + version_Id + "");
        this.template.querySelectorAll('.uplodInput').forEach(ele => {
            if(ele.name == version_Id){
                ele.click();
            }
        });
    }

    @track br_Record_Balance;

    openfileUploadBalance(event) {
        const version_Id_Balance = event.currentTarget.dataset.versionid;
        console.log('===> version_Id_Balance ' + version_Id_Balance);
        this.br_Record_Balance = version_Id_Balance;
        console.log('===> this.br_Record_Balance ' + this.br_Record_Balance);
        //const getFileInputBalance = this.template.querySelector("." + version_Id_Balance + "");
        //getFileInputBalance.click();
        this.template.querySelectorAll('.uplodInput').forEach(ele => {
            if(ele.name == version_Id_Balance){
                ele.click();
            }
        });
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    
    handleUploadFinished(event) {
        // Get the list of uploaded files 
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
    }

    handleFilesChange(event) {
        var file = event.target.files[0];
        var filetype1 = event.currentTarget.dataset.filetype;
        //var rec_id = event.currentTarget.dataset.idx;
        var rec_id = this.brRecordId;
        console.log('===> rec_id ' + rec_id);
        this.showSpinner = true;
        var reader = new FileReader();
        reader.onload = () => {
            var base64input = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64input,
                'record_Id': rec_id,
                'filetype': filetype1
            }
            //console.log(this.fileData)
            let { base64, filename, record_Id, filetype } = this.fileData;
            //  uploadFiles({ base64 : base64,filename : filename, recordId: recordId, filetype : filetype }).then(result=>{
            uploadFiles({ base64, filename, record_Id, filetype }).then(result => {
                //console.log('==> result result ' + JSON.stringify(result));
                this.fileData = null;
                //let title = `${filename} uploaded successfully!!`
                refreshApex(this.wiredActivities);
                this.showSpinner = false;
                this.showToast('Success', 'File uploded successfully.', 'success');
                //this.notifyCHRMviaEmail('Email_notification_on_file_upload_to_chrm_1716375322473');
                //this.uploadedfileId = result;
            })
            .catch(error => {
                console.log('File uploaded failed', error);
                this.showSpinner = false;
            });
        }
        reader.readAsDataURL(file)
    }

    handleFilesChangeBalance(event) {
        var file = event.target.files[0];
        var filetype1 = event.currentTarget.dataset.filetype;
        //var rec_id = event.currentTarget.dataset.idx;
        var rec_id = this.br_Record_Balance;
        console.log('===> rec_id ' + rec_id);
        this.showSpinner = true;
        var reader = new FileReader();
        reader.onload = () => {
            var base64input = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64input,
                'record_Id': rec_id,
                'filetype': filetype1
            }
            //console.log(this.fileData)
            let { base64, filename, record_Id, filetype } = this.fileData;
            //  uploadFiles({ base64 : base64,filename : filename, recordId: recordId, filetype : filetype }).then(result=>{
            uploadFiles({ base64, filename, record_Id, filetype }).then(result => {
                //console.log('==> result result ' + JSON.stringify(result));
                this.fileData = null;
                //let title = `${filename} uploaded successfully!!`
                refreshApex(this.wiredActivities);
                this.showSpinner = false;
                this.showToast('Success', 'File uploded successfully.', 'success');
                //this.notifyCHRMviaEmail('Email_notification_on_file_upload_to_chrm_1716375322473');
                //this.uploadedfileId = result;
            })
            .catch(error => {
                console.log('File uploaded failed', error);
                this.showSpinner = false;
            });
        }
        reader.readAsDataURL(file)
    }

    uploadBalanceDocumentHandler(event) {
        this.showUploadBalanceDocument = !this.showUploadBalanceDocument
        //this.recdId = event.currentTarget.dataset.recid;
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
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents });
                };
                reader.readAsDataURL(file);
            }
            console.log("File data is ", this.filesData);
            console.log(files, "files");
        }
    }

    handleBrowse() {
        const fileInput = this.template.querySelector('.file-upload-design input[type="file"]');
        fileInput.click();
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleBalanceFilesChange(event) {
        console.log('Handle BalanceFile change invoked');
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
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({ 'fileName': file.name, 'fileContent': fileContents });
                };
                reader.readAsDataURL(file);
            }
            console.log("File data is ", this.filesData);
        }
    }

    uploadBalanceFiles() {
        if (this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'Please select files first', 'error'); return;
        }
        this.showSpinner = true;
        console.log('brRecord id is ', this.brRecordId);
        uploadMultipleBalanceFiles({
            brRecordId: this.brRecordId,
            filedata: JSON.stringify(this.filesData)
        })
        .then(result => {
            console.log(result);
            if (result && result == 'success') {
                this.filesData = [];
                this.showUploadBalanceDocument = !this.showUploadBalanceDocument;
                this.showToast('Success', 'Successfully uploaded file.', 'success');
                refreshApex(this.wiredActivities);
            } else {
                this.showToast('Error', result, 'error');
            }
        }).catch(error => {
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message, 'error');
            }
        }).finally(() => this.showSpinner = false);
    }

    uploadFiles() {
        if (this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'Please select files first', 'error'); return;
        }
        this.showSpinner = true;
        uploadMultipleFiles({
            recordId: this.recdId,
            filedata: JSON.stringify(this.filesData)
        })
        .then(result => {
            console.log(result);
            if (result && result == 'success') {
                this.filesData = [];

                this.showToast('Success', 'Successfully uploaded file.', 'success');
            } else {
                this.showToast('Error', result, 'error');
            }
        }).catch(error => {
            if (error && error.body && error.body.message) {
                this.showToast('Error', error.body.message, 'error');
            }
        }).finally(() => this.showSpinner = false);
    }

    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }

    notifyCHRMviaEmail(templateDevName) {
        sendEmailToCHRM({ emailAddList: this.listOfEmails, templateApiName: templateDevName, recId: this.conId }).then(result => {
            console.log('email sent to chrm team ');
        })
        .catch(error => {
            console.log('Email send failed', error.message)
        });
    }
    fileData;

    expiryDurationClass(num) {
        if (num < 15)
            return 'expiry-inactive';
        else if (num >= 15 && num <= 45)
            return 'expiry-warning';
        else if (num > 45)
            return 'expiry-active';
    }

    updateBRRecords(event) {
        this.showSpinner = true;
        let dataset = [];
        // Get all date picker elements
        const expiryDateInputs = this.template.querySelectorAll('.BRExpiryDate');
        // Iterate over each date picker and construct the dataset
        expiryDateInputs.forEach(input => {
            // Get the selected expiry date
            const expiryDate = input.value;
            // Get the filename associated with this row
            const recName = input.dataset.filename;
            // Get the fileId associated with this row
            const recId = input.dataset.id;
            // Construct the dataset for this row
            let rowData = {
                Id: recId,
                expiryDate: expiryDate,
                docName: recName
                // Add more fields to the rowData object as needed
            };
            if (rowData.expiryDate && rowData.Id)
                dataset.push(rowData);
        });
        // Now, dataset contains all data from all rows
        console.log(dataset);
        updateBRHistoryRecord({ fileExpiryList: dataset })
        .then(result => {
            if (result && result == 'Updated') {
                // Handle success response
                refreshApex(this.wiredActivities);
                this.showToast('Success', 'Successfully updated record.', 'success');
            } else {
                this.showToast('Success', 'No updation on record.', 'success');
            }
            this.showSpinner = false;
        })
        .catch(error => {
            // Handle error response
            this.showToast('Error', 'Failed to update record.', 'error');
            console.error('Error processing file expiry list:', error);
            this.showSpinner = false;
        });
    }

    handleProfileChange(event) {
        const file = event.target.files[0];
        console.log(file.type);

        let base64Data = '';
        let fileReader = new FileReader();
        // set onload function of FileReader object
        fileReader.onloadend = () => {
            base64Data = fileReader.result.split(',')[1];
            this.setProfilePicture(file.name, file.type, encodeURIComponent(base64Data));
            console.log("FileBase64" + base64Data);
        };
        console.log('121');
        fileReader.readAsDataURL(file);
        console.log('4as54');
    }

    fileId = '';
    setProfilePicture(name, type, base64) {
        console.log('111');
        setUserPhoto({
            fileName: name,
            fileType: type,
            base64Data: base64
        })
        .then((smallPhotoUrl) => {
            console.log(smallPhotoUrl);
            //this.fileId = smallPhotoUrl;
            refreshApex(this.wiredData);
            location.reload();
        })
        .catch((error) => {
        });
        console.log('454');
    }

    triggerFileInput() {
        const fileInput = this.template.querySelector('.file-input');
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
                this.showToast('Success', 'File deleted successfully.', 'success');
                location.reload();
            })
            .catch(error => {
                console.log('File delete failed' + error);
                console.error('File delete failed', error);
                this.showToast('Error', 'File delete failed.', 'error');
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
            variant,
        });
        this.dispatchEvent(event);
    }

    uploadModuleDropDownChange(event) {
        this.UploadModuleSelectedText = event.target.value;
        console.log('selection is ');
        let selection = event.target.value;
        console.log(selection);
        if (selection == 'View Secondary Documents') {
            this.showBalanceFiles = true;
        } else {
            this.showBalanceFiles = false;
        }
    }

    get SelectOptions() {
        return [
            { label: 'View Primary Documents', value: 'View Primary Documents' },
            { label: 'View Secondary Documents', value: 'View Secondary Documents' }
        ];
    }

    policiesButtonClickHandler(event) {
        getPolicyFiles()
        .then(result => {
            this.policyFiles = result;
            //console.log('Policies button click handler result is ', JSON.stringify(result));
        })
        .catch(error => {
            console.error('Error retrieving policy files:', error);
            // Optionally, show a toast message or handle the error
        });
        console.log('clicked policies');
        this.showPolicies = !this.showPolicies;
    }

    handleOnclickPolicy(event) {
        this.showSpinner = true;
        const versionId = event.currentTarget.dataset.versionid;
        this.getFilePdf(versionId);
    }
}