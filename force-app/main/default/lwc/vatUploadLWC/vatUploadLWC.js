import { LightningElement, api } from 'lwc';
import uploadFile from '@salesforce/apex/VatUploadController.uploadFile';


export default class VatUploadLWC extends LightningElement {
    @api recordId;
    displaySuccess = false;
    displaySubmit = false;
    showSpinner = false;
    fileData1 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    fileData2 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    fileData3 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    fileData4 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    fileData5 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    fileData6 = {
        'filename':'',
        'base64': '',
        'recordId': ''
    };
    connectedCallback() {
        console.log('LWC Component Called');
        console.log('LWC Component Called'+ this.recordId);
        this.displaySubmit = true;
    }
    openfileUpload(event) {
        const file = event.target.files[0];
        const name = event.target.title;
        console.log(name);
        console.log(event.target.title)
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            if(name == 'Visa Copy') {
                this.fileData1 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
            if(name == 'Emirates ID') {
                this.fileData2 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
            if(name == 'Vat Certificate') {
                this.fileData3 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
            if(name == 'POA/MOA') {
                this.fileData4 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
            if(name == 'Witness ID') {
                this.fileData5 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
            if(name == 'Other doument') {
                this.fileData6 = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
            }
           
        }
        reader.readAsDataURL(file)
    }
    handleSave() {
        this.showSpinner = true;
        if(this.fileData1.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData1.base64, this.fileData1.filename, this.recordId);
            this.fileData1 = {'filename':'','base64': '','recordId': ''};
        }
        else if(this.fileData2.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData2.base64, this.fileData2.filename, this.recordId);
            this.fileData2 = {'filename':'','base64': '','recordId': ''};
        }
        else if(this.fileData3.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData3.base64, this.fileData3.filename, this.recordId);
            this.fileData3 = {'filename':'','base64': '','recordId': ''};
        }
        else if(this.fileData4.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData4.base64, this.fileData4.filename, this.recordId);
            this.fileData4 = {'filename':'','base64': '','recordId': ''};
            
        }
        else if(this.fileData5.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData5.base64, this.fileData5.filename, this.recordId);
            this.fileData5 = {'filename':'','base64': '','recordId': ''};
            
        }
        else if(this.fileData6.filename != '' && this.recordId != '') {
            this.handleUpload(this.fileData6.base64, this.fileData6.filename, this.recordId);
            this.fileData6 = {'filename':'','base64': '','recordId': ''};
        }
        else {
            this.displaySuccess = true;
            this.displaySubmit = false;
            this.showSpinner = false;
        }
    }
    handleUpload(base64, fileName, recId) {
        uploadFile({ 
            base64 : base64,
            filename: fileName,
            recordId : recId
        }).then(result=>{
            this.handleSave();
        })
        .catch(error => {
            this.displaySubmit = true;
            this.displaySuccess = false;
            this.showSpinner = false;
            alert('Error: '+ error.body.pageErrors[0].message +' While uploading file: '+fileName);
        });
    }
}