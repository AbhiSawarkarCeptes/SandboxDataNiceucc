import {
    LightningElement,
    api,
    wire
} from 'lwc';
import getSteps from '@salesforce/apex/LwcApproveRejectBpstepController.getSteps';
import requestForMoreInfo from '@salesforce/apex/LwcApproveRejectBpstepController.requestForMoreInfo';
import approveStep from '@salesforce/apex/LwcApproveRejectBpstepController.approveStep';
import rejectStep from '@salesforce/apex/LwcApproveRejectBpstepController.rejectStep';
import validateOnLoad from '@salesforce/apex/LwcApproveRejectBpstepController.validateOnLoad';
import getBusinessProcessStepFields from '@salesforce/apex/LwcApproveRejectBpstepController.getBusinessProcessStepFields';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CloseActionScreenEvent
} from 'lightning/actions';

export default class LwcApproveRejectBpstep extends NavigationMixin(LightningElement) {
    radioValue;
    comment;
    showStep = false;
    brValue;
    @api recordId;
    businessProcessStep;
    showBankReference = false;
    stepOptions1 = [];
    @wire(getBusinessProcessStepFields, { recordId: '$recordId' })
    wiredBusinessProcessStep({ error, data }) {
        if (data) {
            this.businessProcessStep = data;
            // Extract fields and values
            console.log(data);
            if(this.businessProcessStep.Business_Process__r.Name == 'Pre-Registration - 5 days' && this.businessProcessStep.Sequence__c == 3){
                this.showBankReference = true;
            }
        } else if (error) {
            console.error('Error retrieving Business Process Step fields', error);
        }
    }
    get radioOptions() {
        return [{
                label: 'Approve',
                value: 'Approve'
            },
            {
                label: 'Reject',
                value: 'Reject'
            },
            {
                label: 'Request for more information',
                value: 'Request for more information'
            }
        ];
    }
    setpValue;

    get stepOptions() {
        return [{
                label: 'Step 1',
                value: '1'
            },
            {
                label: 'Step 2',
                value: '2'
            },
            {
                label: 'Step 3',
                value: '3'
            }
        ];
    }
    connectedCallback() {
        console.log('connectedCallback '+this.recordId);
    }
    renderedCallback() {
        console.log('renderedCallback '+this.recordId);
    }
    commentOnChange(event) {
        this.comment = event.target.value;
    }
    bROnChange(event) {
        this.brValue = event.target.value;
    }
    handleRadioChange(event) {
        
        this.radioValue = event.target.value;
        console.log(this.radioValue);
        if (this.radioValue == 'Request for more information') {
            getSteps({
                    bpsId: this.recordId
                })
                .then(result => {
                    console.log();
                    let dataList = JSON.parse(result);
                    this.stepOptions1 = [];
                    for (let i = 0; i < dataList.length; i++) {
                        this.stepOptions1.push({
                            label: dataList[i].Step__c + '-' + dataList[i].Department__c,
                            value: dataList[i].Id
                        });
                    }
                    console.log(this.stepOptions1);
                })
                .catch(error => {
                    console.log('error 2' + error);
                    console.log('error 2' + JSON.stringify(error));
                    const event = new ShowToastEvent({
                        title: 'Error..!',
                        message: error.body.pageErrors[0].message,
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                });
            this.showStep = true;
        } else {
            this.showStep = false;
        }
    }
    handleChange(event) {
        this.setpValue = event.target.value;
        console.log(this.setpValue);
    }
    handleOkay(e) {
        if(this.businessProcessStep.Business_Process__r.Name == 'Pre-Registration - 5 days' && this.businessProcessStep.Sequence__c == 3 && (this.brValue == '' || this.brValue == undefined ) ){
                const event = new ShowToastEvent({
                        title: 'Error..!',
                        message: 'Please fill Bank Reference Number',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                    return;
            }
        validateOnLoad({
                bpsId: this.recordId
            })
            .then(result => {
                if (result == false) {
                    const event = new ShowToastEvent({
                        title: 'Error..!',
                        message: 'Please Accept before Approve/Reject.',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                    //this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    if (!this.radioValue) {
                        const event = new ShowToastEvent({
                            title: 'Error..!',
                            message: 'Please select Action.',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    } else {
                        if (!this.comment) {
                            const event = new ShowToastEvent({
                                title: 'Error..!',
                                message: 'Please fill Comment.',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                        } else {
                            if (this.radioValue == 'Request for more information') {
                                if (!this.setpValue) {
                                    const event = new ShowToastEvent({
                                        title: 'Error..!',
                                        message: 'Please select step.',
                                        variant: 'error',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(event);
                                } else {
                                    requestForMoreInfo({
                                            bpsId: this.recordId,
                                            rejectingToBpsId: this.setpValue,
                                            comment: this.comment,
                                            brNumber:this.brValue
                                        })
                                        .then(result => {
                                            const event = new ShowToastEvent({
                                                title: 'Success..!',
                                                message: 'Rejected back to the Selected Step.',
                                                variant: 'success',
                                                mode: 'dismissable'
                                            });
                                            this.dispatchEvent(event);
                                            this[NavigationMixin.Navigate]({
                                                type: 'standard__recordPage',
                                                attributes: {
                                                    recordId: result,
                                                    actionName: 'view'
                                                }
                                            });
                                            this.dispatchEvent(new CloseActionScreenEvent());
                                        })
                                        .catch(error => {
                                            console.log('error 4' + error);
                                            console.log('error 4' + JSON.stringify(error));
                                            const event = new ShowToastEvent({
                                                title: 'Error..!',
                                                message: error.body.pageErrors[0].message,
                                                variant: 'error',
                                                mode: 'sticky'
                                            });
                                            this.dispatchEvent(event);
                                        });
                                }

                            } else if (this.radioValue == 'Approve') {
                                approveStep({
                                        bpsId: this.recordId,
                                        comment: this.comment,
                                        brNumber:this.brValue
                                    })
                                    .then(result => {
                                        const event = new ShowToastEvent({
                                            title: 'Success..!',
                                            message: 'Approved Successfully.',
                                            variant: 'success',
                                            mode: 'dismissable'
                                        });
                                        this.dispatchEvent(event);
                                        this[NavigationMixin.Navigate]({
                                            type: 'standard__recordPage',
                                            attributes: {
                                                recordId: result,
                                                actionName: 'view'
                                            }
                                        });

                                        this.dispatchEvent(new CloseActionScreenEvent());
                                    })
                                    .catch(error => {
                                        console.log('error 5' + error);
                                        console.log('error 5' + JSON.stringify(error));
                                        const event = new ShowToastEvent({
                                            title: 'Error..!',
                                            message: error.body.pageErrors[0].message,
                                            variant: 'error',
                                            mode: 'sticky'
                                        });
                                        this.dispatchEvent(event);
                                    });
                            } else if (this.radioValue == 'Reject') {
                                rejectStep({
                                        bpsId: this.recordId,
                                        comment: this.comment,
                                        brNumber:this.brValue
                                    })
                                    .then(result => {
                                        const event = new ShowToastEvent({
                                            title: 'Success..!',
                                            message: 'Rejected Successfully.',
                                            variant: 'success',
                                            mode: 'dismissable'
                                        });
                                        this.dispatchEvent(event);
                                        this[NavigationMixin.Navigate]({
                                            type: 'standard__recordPage',
                                            attributes: {
                                                recordId: result,
                                                actionName: 'view'
                                            }
                                        });
                                        this.dispatchEvent(new CloseActionScreenEvent());
                                    })
                                    .catch(error => {
                                        console.log('error 6' + error);
                                        console.log('error 6' + JSON.stringify(error));
                                        const event = new ShowToastEvent({
                                            title: 'Error..!',
                                            message: error.body.pageErrors[0].message,
                                            variant: 'error',
                                            mode: 'sticky'
                                        });
                                        this.dispatchEvent(event);
                                    });
                            }
                        }
                    }
                }
            })
            .catch(error => {
                console.log('error 3' + error);
                console.log('error 3' + JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error..!',
                    message: error.body.pageErrors[0].message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            });



    }
}