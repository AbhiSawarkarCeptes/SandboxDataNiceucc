import { LightningElement, track, api} from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelJS";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmail from '@salesforce/apex/EmailTemplateController.getEmailAddress';
import sendEmail from '@salesforce/apex/EmailTemplateController.sendEmail';
import uploadFile from '@salesforce/apex/EmailTemplateController.uploadFile';

let XLS = {};

export default class EmailTemplate extends LightningElement {
    searchToEmail = '';
    searchKeyCCEmail = '';
    searchKeyBCCEmail = '';
    emailSubject = '';
    showResults = false;
    showCCResults = false;
    showBCCResults = false;
    searchResults = [];
    @track labelTo = [];
    @track labelCC = [];
    @track labelBCC = [];
    strAcceptedFormats = [".xls", ".xlsx"];
    strUploadFileName = ''; 
    emailEditable = false;
    excelRecords = [];
    showSpinner = false;
    contentDocumentId = '';
    contentVersionId = '';
    ShowPreview = false;
    fieldValue = " ";
    fieldLabel;
    required;
    fieldLength = 32000;
    visibleLines = 3;
    @api recordId;
    validity;
    errorMessage;
    sendEmailBtn = false;
    previewEmailBtn = false;
    file;
    fileName = '';
    allowedFormats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'clean',
        'table',
        'header',
        'color',
        'background',
        'code',
        'code-block',
        'script',
        'blockquote',
        'direction',
    ];


    connectedCallback() {
        this.showSpinner = true;
        Promise.all([loadScript(this, excelFileReader)])
        .then(() => {
            XLS = XLSX;
            this.showSpinner = false;
        })
        .catch((error) => {
            console.log("An error occurred while processing the file");
            this.showSpinner = false;
        });
        this.validity = true;
        document.documentElement.style.setProperty('--rta-visiblelines', (this.visibleLines * 2) + 'em');
        this.sendEmailBtn = true;
        this.previewEmailBtn = true;
        this.getEmail();
    }
    resetEmails() {
        this.searchToEmail = '';
        this.searchKeyCCEmail = '';
        this.searchKeyBCCEmail = '';
        this.emailSubject = '';
        this.showResults = false;
        this.showCCResults = false;
        this.showBCCResults = false;
        this.searchResults = [];
        this.labelTo = [];
        this.labelCC = [];
        this.labelBCC = [];
        this.fieldValue = ' ';
        this.excelRecords = [];
        this.strUploadFileName = "";
        this.emailEditable = false;
        this.sendEmailBtn = true; 
        this.previewEmailBtn = true; 
        this.contentDocumentId = '';
        this.contentVersionId = '';
        this.fileName = '';
    }
    handleEmailSubject(event) {
        this.emailSubject =  event.target.value;
    }
    createEmailDetails() {
        Object.keys(this.excelRecords).forEach((key) => {
            let St = this.emailSubject;
            let emailBody = this.fieldValue;
            Object.keys(this.excelRecords[key]).forEach((k) => {
                if(k != 'To' && k != 'TO') {
                    let s = '#'+k;
                    if(St.includes(s)){
                        St = St.replaceAll(s, this.excelRecords[key][k]);
                    }
                    if(emailBody.includes(s)) {
                        emailBody = emailBody.replaceAll(s, this.excelRecords[key][k]);
                    }
                }
            })
            this.excelRecords[key]['EmailSubject'] = St;
            this.excelRecords[key]['EmailBody'] = emailBody;
        })
    }
    handlePreview(){
        this.ShowPreview = true;
        this.createEmailDetails();
    }
    handleCancel(){
        this.ShowPreview = false;
    }
    handleChange(event) {
        if ((event.target.value).length > this.fieldLength) {
            this.validity = false;
            this.errorMessage = "You have exceeded the max length";
        }
        else {
            this.validity = true;
            this.fieldValue = event.target.value;
            console.log('======>'+this.fieldValue);
        }
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        this.emailSubject = '';
        this.searchToEmail = '';
        this.searchKeyCCEmail = '';
        this.searchKeyBCCEmail = '';
        this.fieldValue = ' ';
        this.showResults = false;
        this.showCCResults = false;
        this.showBCCResults = false;
        this.searchResults = [];
        this.labelTo = [];
        this.labelCC = [];
        this.labelBCC = [];
        this.emailEditable = true;
        const strUploadedFile = event.detail.files;
        if (strUploadedFile.length && strUploadedFile != "") {
          this.strUploadFileName = strUploadedFile[0].name;
          this.handleProcessExcelFile(strUploadedFile[0]);
        }
        else{
            this.showSpinner = false;
        }
    }
    handleProcessExcelFile(file) {
        let objFileReader = new FileReader();
        objFileReader.onload = (event) => {
            let objFiledata = event.target.result;
            let objFileWorkbook = XLS.read(objFiledata, {
            type: "binary"
            });
            let objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                objFileWorkbook.Sheets["Sheet1"]
            );
            if (objExcelToJSON.length === 0) {

                this.strUploadFileName = "";
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Kindly upload the file with data",
                        variant: "error"
                    })

                );
                this.emailEditable = false;

            }
            let toList = this.labelTo;
            let ccList = this.labelCC;
            let bccList = this.labelBCC;
            let excelRecords = this.excelRecords;
            Object.keys(objExcelToJSON).forEach((key) => {
                let map = {};
                Object.keys(objExcelToJSON[key]).forEach((k) => {
                    map[k] = objExcelToJSON[key][k];
                    if(k === 'To' || k ==='TO') {
                        if(objExcelToJSON[key][k].includes(',')) {
                            objExcelToJSON[key][k].split(',').forEach((t)=>{
                                toList.push(t);
                            })
                        }
                        else{
                            toList.push(objExcelToJSON[key][k]);
                        }
                        
                    }
                    if(k === 'CC' || k === 'Cc') {
                        if(objExcelToJSON[key][k].includes(',')) {
                            objExcelToJSON[key][k].split(',').forEach((t)=>{
                                ccList.push(t);
                            })
                        }
                        else{
                            ccList.push(objExcelToJSON[key][k]);
                        }
                        
                    }
                    if(k === 'BCC' || k === 'Bcc') {
                        if(objExcelToJSON[key][k].includes(',')) {
                            objExcelToJSON[key][k].split(',').forEach((t)=>{
                                bccList.push(t);
                            })
                        }
                        else{
                            bccList.push(objExcelToJSON[key][k]);
                        }
                    }
                });
                excelRecords.push(map);
            });
            console.log('----->'+excelRecords.length);
            if(excelRecords.length > 0) {
                this.sendEmailBtn = false;
                this.previewEmailBtn = false;
                this.showSpinner = false;
            }
            else{
                this.showSpinner = false;
            }
            this.excelRecords = excelRecords;
            this.labelTo  = toList;
            this.labelCC = ccList;
            this.labelBCC = bccList;
        };
        objFileReader.onerror = function (error) {
          this.dispatchEvent(
            new ShowToastEvent({
                title: "Error while reading the file",
                message: error.message,
                variant: "error"
            })
          );
        };
        objFileReader.readAsBinaryString(file);
    }
    showDialog() {
        this.showResults = true;
    }
    showCCDialog() {
        this.showCCResults = true;
    }
    showBCCDialog() {
        this.showBCCResults = true;
    }
    removePillItem(event) {
        if(!this.emailEditable){
            const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
            const itempill = this.labelTo;
            itempill.splice(pillIndex, 1);       
            this.labelTo = [...itempill];
            console.log(pillIndex, this.labelTo);
        }
    }
    removeCCItem(event) {
        if(!this.emailEditable){
            const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
            const itempill = this.labelCC;
            itempill.splice(pillIndex, 1);       
            this.labelCC = [...itempill];
            console.log(pillIndex, this.labelCC);
        }
    }
    removeBCCItem(event) {
        if(!this.emailEditable){
            const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
            const itempill = this.labelBCC;
            itempill.splice(pillIndex, 1);       
            this.labelBCC = [...itempill];
            console.log(pillIndex, this.labelBCC);
        }
    }
    handleSearchKeyChange(event) {
        this.searchToEmail = event.target.value;
        this.showResults = true;
        if (this.searchToEmail.length == 0 || this.searchToEmail == undefined) {
            this.searchToEmail = '';
            this.showResults = false;

        } else {
            this.getEmail();
        }
    }
    handleSearchCCChange(event) {
        this.searchKeyCCEmail = event.target.value;
        this.showCCResults = true;
        if (this.searchKeyCCEmail.length == 0 || this.searchKeyCCEmail == undefined) {
            this.searchKeyCCEmail = '';
            this.showCCResults = false;

        } else {
            this.getEmail();
        }
    }
    handleSearchBCChange(event) {
        this.searchKeyBCCEmail = event.target.value;
        this.showBCCResults = true;
        if (this.searchKeyBCCEmail.length == 0 || this.searchKeyBCCEmail == undefined) {
            this.searchKeyBCCEmail = '';
            this.showBCCResults = false;

        } else {
            this.getEmail();
        }
    }

    handleEmailClose() {
        this.showResults = false;
    }
    handleCCEmailClose() {
        this.showCCResults = false;
    }
    handleBCCEmailClose() {
        this.showBCCResults = false;
    }
    isEmailValid(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }


    handleEmailClick(event) {
        if(event.target.title !== '+ New Email Address') {
            this.searchToEmail = event.target.title;
            this.labelTo.push(this.searchToEmail);
        }
        else if(this.isEmailValid(this.searchToEmail)){
            this.labelTo.push(this.searchToEmail);
        }
        else{
            alert('Please Enter Valid Email Address');
        }
        this.searchToEmail = '';
        this.showResults = false;
    }
    handleCCClick(event) {
        if(event.target.title !== '+ New Email Address') {
            this.searchKeyCCEmail = event.target.title;
            this.labelCC.push(this.searchKeyCCEmail);
        }
        else if(this.isEmailValid(this.searchKeyCCEmail)){
            this.labelCC.push(this.searchKeyCCEmail);
        }
        else{
            alert('Please Enter Valid Email Address');
        }
        this.searchKeyCCEmail = '';
        this.showCCResults = false;
    }
    handleBCCClick(event) {
        if(event.target.title !== '+ New Email Address') {
            this.searchKeyBCCEmail = event.target.title;
            this.labelBCC.push(this.searchKeyBCCEmail);
        }
        else if(this.isEmailValid(this.searchKeyBCCEmail)){
            this.labelBCC.push(this.searchKeyBCCEmail);
        }
        else{
            alert('Please Enter Valid Email Address');
        }
        this.searchKeyBCCEmail = '';
        this.showBCCResults = false;
    }
    getEmail() {
        getEmail({
            searchKeyWrd: this.searchToEmail,
        }).then(result => {
            this.searchResults = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('rooro -> ',JSON.stringify(error));
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);
        });
    }
    handleFileChange(event) {
        this.file = event.target.files[0];
        if(this.file) {
            this.fileName = this.file.name;
            this.uploadFileToContentDocument(this.file);
        }
        else{
            this.showSpinner = false;
        }
    }

    uploadFileToContentDocument(file) {
        const reader = new FileReader();
        reader.onloadend = () => {
            const content = reader.result.split(',')[1]; // Base64 encoded file content
            this.showSpinner = true;
            uploadFile({ fileName: file.name, fileBody: content })
                .then(res => {
                    this.contentDocumentId = res.ContentDocumentId;
                    this.contentVersionId = res.Id;
                    console.log('File uploaded successfully:', res);
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'File Attached successfully:',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.showSpinner = false;
                    // Perform further actions if needed
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in File Attachment:',
                        variant: 'Error',
                    });
                    this.dispatchEvent(evt);
                    console.error('Error uploading file:', error);
                    this.showSpinner = false;
                    // Handle errors
                });
        };
        reader.readAsDataURL(file);
    }
    
    SendEmails(){
        this.showSpinner = true;
        this.createEmailDetails();
        console.log(JSON.stringify(this.excelRecords));
        console.log(this.contentDocumentId);
        sendEmail({
            emailDetails: JSON.stringify(this.excelRecords),
            contentDocumentId : this.contentDocumentId
        }).then(result => {
            this.resetEmails();
            if(result == 'Success') {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Email Sent successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
            else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    message: JSON.stringify(result)
                });
                this.dispatchEvent(evt);
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                label: 'Warning',
                title: 'Warning',
                variant: 'warning',
                message: JSON.stringify(error)
            });
            this.dispatchEvent(evt);

        });
    }
    priviewFile() {

    }
}