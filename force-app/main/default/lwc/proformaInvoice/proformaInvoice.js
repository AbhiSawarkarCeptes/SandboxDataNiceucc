import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import getobject from '@salesforce/apex/ProformaInvoiceController.objectName';
import callopportunity from '@salesforce/apex/ProformaInvoiceController.getOpportunity';
import callbooking from '@salesforce/apex/ProformaInvoiceController.getBooking';
import calculate from '@salesforce/apex/ProformaInvoiceController.calculate';
//import generatepdf from '@salesforce/apex/ProformaInvoiceController.generatePDF';
import createandsubmit from '@salesforce/apex/ProformaInvoiceController.createAndSubmit';
import updateParent from '@salesforce/apex/ProformaInvoiceController.updateParent';
import generatePDFForBooking from '@salesforce/apex/ProformaInvoiceController.generatePDFForBooking';
import sendEmailAfterApproval from '@salesforce/apex/ProformaInvoiceController.sendEmailAfterApproval';
import checkPDFGeneration from '@salesforce/apex/ProformaInvoiceController.checkPDFGeneration'


export default class ComboboxRequired extends NavigationMixin(LightningElement) {
    @api recordId;
    @track parentdata; //contains the current Record data
    @track purchaseprice;   //contains Purchase Price from Unit tagged 
    @track value = 'Percentage (1% - 100%)';  //contains second set of list of options after we select Unit Price, not DLD
    @track value1; //contains first list of options consists of Unit Price and DLD Amount
    @track inputValue;  //captures user's input in Percentage based on selection(value)
    @track totalAmount; //calculated Value on the screen based on the selection(Percentage or Amount)
    @track dldAmount = 123;   //calculated DLD Amount at backend
    @track percentagevalue; //captures user's input in Percentage based on selection(value)
    @track amountvalue; //captures user's input in Amount based on selection(value)
    @track unitexist = true; //contains a boolean value to check if Unit is tagged to the Opportunity record
    @track unitPriceOption; //contains a boolean value (For Eg- returns 'true' if 'Unit Price' is selected not 'DLD Amount')
    @track isActiveBasicCloseDate = false;  //contains a boolean value to check if Is Active Basis Closed Date exists on the Opportunity record
    @track proformaInvoiceId;   //contains the newly created Proforma Invoice record Id for navigation
    @track ProformaInvoiceType;
    @track DLDAmountOption = false;
    @track bookingLookup;
    @track bookingExist = false;
    @track isPercentage = false;
    @track fromBooking = false;
    @track disableCreation = true;
    @track amountExceeds = false;
    @track generatePDF = false;

    connectedCallback() {
        if (this.recordId) {
            console.log('i am renderedcallback' + this.recordId);

            checkPDFGeneration({
                recId: this.recordId
            }).then(result => {
                this.generatePDF = result;
            })
                .catch(error => {
                    console.log('-----error-----' + JSON.stringify(error));
                })

            getobject({
                recordId: this.recordId
            }).then(result => {
                console.log('object result :' + result);
                if (result == 'Opportunity') {
                    this.fromBooking = false;
                    callopportunity({
                        recId: this.recordId
                    })
                        .then(result => {
                            this.parentdata = result;
                            this.isActiveBasicCloseDate = result.Is_Active_basis_close_date__c;
                            this.bookingLookup = result.Booking__c;
                            if (result.Unit__c == null) {
                                this.unitexist = false;
                            }
                            else if (this.isActiveBasicCloseDate == true && this.bookingLookup == null) {
                                console.log('------- PASSED ------' + result);
                                this.unitexist = true;
                                this.purchaseprice = result.Unit__r.Puchase_Price__c;
                                this.bookingExist = false;
                            }
                            else if (this.bookingLookup != null) {
                                console.log('------Booking Lookup Value------->' + this.bookingLookup);
                                this.bookingExist = true;
                                this.unitexist = true;
                            } else {
                                this.unitexist = false;
                            }
                            console.log('hi i am PurchasePrice details-->' + JSON.stringify(this.purchaseprice));
                            console.log('hi i am Is Active Basis Close Date details-->' + result.Is_Active_basis_close_date__c);
                        })
                        .catch(error => {
                            console.log('-----error-----' + JSON.stringify(error));
                        })
                } else {
                    this.fromBooking = true;
                    callbooking({
                        recId: this.recordId
                    })
                        .then(result => {
                            this.parentdata = result;
                            console.log('this.parentdata --> ',JSON.parse(JSON.stringify(this.parentdata)));
                            if (result.Unit__c == null) {
                                this.unitexist = false;
                            } else {
                                this.purchaseprice = parseFloat(result.Agreement_Value__c);
                                console.log('this.purchaseprice --> ',this.purchaseprice);
                                if (this.parentdata.Unit__c != null) {
                                    this.unitexist = true;
                                }
                            }
                        })
                        .catch(error => {
                            console.log('-----error-----' + JSON.stringify(error));
                        })
                }
            })
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get options() {
        return [
            { label: 'Percentage', value: 'Percentage' },
            { label: 'Amount', value: 'Amount' },
        ];
    }

    get options1() {
        return [
            { label: 'Unit Price', value: 'UnitPrice' },
            { label: 'DLD Amount', value: 'DLDAmount' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log('hi i am selectedvalue-->' + this.value);
        if (this.value == 'Percentage') {
            this.percentagevalue = 'Percentage (1% - 100%)';
            this.isPercentage = true;
        } else {
            this.amountvalue = this.value;
            this.isPercentage = false;
        }
    }

    handleChange1(event) {
        const fields = {};
        this.value1 = event.detail.value;
        console.log('First Validation- value1 = -->' + this.value1);
        if (this.value1 == 'UnitPrice') {
            this.unitPriceOption = true;
            this.ProformaInvoiceType = 'Unit Price';
            console.log('You have selected Unit Price Option ++++' + this.value1);
            updateParent({
                recId: this.recordId,
                ProformaInvoiceTypeApex: this.ProformaInvoiceType,
                fromBooking: this.fromBooking
            })
                .then(result => {
                    console.log('RESULT------------UNIT PRICE-------' + result);
                })
        } else if (this.value1 == 'DLDAmount') {
            this.unitPriceOption = false;
            this.DLDAmountOption = true;
            console.log('-----------DLD AMOUNT SELECTED--------->');
            console.log('------Current Opportunity Record Id--------->' + this.recordId);
            this.ProformaInvoiceType = 'DLD Amount';
            console.log('------Proforma Invoice Type Entered--------->' + this.ProformaInvoiceType);
            updateParent({
                recId: this.recordId,
                ProformaInvoiceTypeApex: this.ProformaInvoiceType,
                fromBooking: this.fromBooking
            })

                .then(result => {
                    console.log('RESULT------------DLD-------' + result);
                })

                //  this.recordId.Proforma_Invoice_Type__c='DLD Amount';            
                .catch(error => {
                    console.log('---DLD 004--error appeared-----' + JSON.stringify(error));
                })
        }
    }

    inputvalueChange(event) {
        console.log('SFDX - > PurchasePrice ',this.purchaseprice,' ---> ',event.detail.value);
        if (event.detail.value > this.purchaseprice) {
            this.amountExceeds = true;
        } else {
            this.amountExceeds = false;
        }
        this.inputValue = event.detail.value;
    }
    handleClick(event) {

        if (this.amountExceeds) {
            console.log('Amount exceeds');
            const evt = new ShowToastEvent({
                title: 'Error!!',
                message: 'Amount can not exceeds Purchase price',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }

        let optionVal;
        if (this.value === 'Percentage (1% - 100%)') {
            optionVal = 'Percentage';
        } else {
            optionVal = this.value;
        }
        console.log('option val :' + optionVal);

        calculate({
            selectedOption: optionVal,
            inputValue: this.inputValue,
            purchasePrice: this.purchaseprice,
            recId: this.recordId,
            fromBooking: this.fromBooking

        })
            .then(result => {

                this.totalAmount = result;
                this.disableCreation = false;
                console.log('-----TOTAL AMOUNT----->' + this.totalAmount);
                console.log('----------OPPORTUNITY RECORD ID-------->' + this.recordId);
            })
            .catch(error => {
                console.log('-----error-----' + JSON.stringify(error));
            })

    }
    createAndSubmitRFP(event) {
        console.log('hi i am generatepdf-->');
        createandsubmit({
            recId: this.recordId,
            amountvalue: this.amountvalue,
            purchasePrice: this.purchaseprice,
            totalvalue: this.totalAmount,
            fromBooking: this.fromBooking
        })
            .then(result => {
                //this.amountvalue = this.totalAmount; 
                this.proformaInvoiceId = result;
                console.log('-----Proforma Invoice Record Generated-------' + result);
                console.log('-----Proforma Invoice Record Generated 2-------' + this.proformaInvoiceId);
                if (this.proformaInvoiceId !== null && this.proformaInvoiceId !== '') {
                    console.log('Performa invoice id generated');
                    console.log('From booking :' + this.fromBooking);
                    if (this.generatePDF) {
                        console.log('Is from booking');
                        generatePDFForBooking({
                            recId: this.proformaInvoiceId,
                            amountvalue: this.amountvalue
                        })
                            .then(result1 => {
                                console.log('Sending email');
                                console.log('-----Proforma Invoice Record Generated 453-------' + result1);
                                sendEmailAfterApproval({
                                    recId: this.proformaInvoiceId
                                })
                                    .then(result2 => {
                                        console.log('Email sent');
                                        console.log('-----Proforma Invoice Record Generated 3453-------' + result2);
                                        const evt = new ShowToastEvent({
                                            title: 'Heads Up!!',
                                            message: 'Request for payment is generated successfully',
                                            variant: 'success',
                                            mode: 'dismissable'
                                        });
                                        this.dispatchEvent(evt);
                                        this[NavigationMixin.Navigate]({
                                            type: 'standard__recordPage',
                                            attributes: {
                                                recordId: this.proformaInvoiceId,
                                                objectApiName: 'Proforma_Invoice__c',
                                                actionName: 'view'
                                            }
                                        });
                                    })
                                    .catch(error => {
                                        console.log('-----error-----' + JSON.stringify(error));
                                    })

                            })
                            .catch(error => {
                                console.log('-----error-----' + JSON.stringify(error));
                            })
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Heads Up!!',
                            message: 'Request for payment is generated successfully and submitted for Sales Approval',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.proformaInvoiceId,
                                objectApiName: 'Proforma_Invoice__c',
                                actionName: 'view'
                            }
                        });
                    }



                } else {
                    const evt = new ShowToastEvent({
                        title: 'Warning!!',
                        message: 'Sorry! Request for payment Record is not generated.',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                console.log('-------AFTER INVOKE----->' + this.proformaInvoiceId);
            })
            .catch(error => {
                console.log('-----error-----' + JSON.stringify(error));
            })
    }

    generatepdfDLD(event) {
        console.log('hi i am generatepdf-->');
        generatepdf({
            oppoId: this.recordId,
            totalvalue: this.dldAmount

        })
            .then(result => {
                this.proformaInvoiceId = result;
                console.log('--DLD 001---Proforma Invoice Record Generated-------' + result);
                console.log('--DLD 002---Proforma Invoice Record Generated 2-------' + this.proformaInvoiceId);
                if (this.proformaInvoiceId !== null && this.proformaInvoiceId !== '') {
                    const evt = new ShowToastEvent({
                        title: 'Heads Up!!',
                        message: 'Proforma Invoice is generated successfully',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.proformaInvoiceId,
                            objectApiName: 'Proforma_Invoice__c',
                            actionName: 'view'
                        }
                    });

                } else {
                    const evt = new ShowToastEvent({
                        title: 'Warning!!',
                        message: 'Sorry! Proforma Invoice Record is not generated.',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                console.log('--DLD 003-----AFTER INVOKE----->' + this.proformaInvoiceId);
            })
            .catch(error => {
                console.log('-----error-----' + JSON.stringify(error));
            })
    }



    navigateToRecordPage() {
        console.log('----------------Entered into Navigation Method-----------------');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.proformaInvoiceId,
                objectApiName: 'Proforma_Invoice__c',
                actionName: 'view'
            }
        });
    }
}