import { LightningElement, api, wire } from 'lwc';
import fetchQuestionsAndAnswers from '@salesforce/apex/Nice_CustomerVerificationController.fetchQuestionsAndAnswers';
import createCustomerVerificationLog from '@salesforce/apex/Nice_CustomerVerificationController.createCustomerVerificationLog';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class Nice_CustomerVerification extends LightningElement {

    @api recordId; // Record ID passed to the LWC
    questionAnswerMap;
    error;

    radioOptions =[
            { label: 'Yes', value: 'true' },
            { label: 'No', value: 'false' },
        ];

    @wire(CurrentPageReference) //it gets executed before the connected callback and avilable to use
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            console.log('currentPageReference ', currentPageReference);
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        console.log('recordId -->'+ this.recordId);
        this.loadQuestionsAndAnswers();
    }

    loadQuestionsAndAnswers() {
        fetchQuestionsAndAnswers({ recordId: this.recordId })
            .then(data => {
                this.questionAnswerMap = Object.entries(data).map(([key, value], index) => {
                    return { 
                        no : index + 1,
                        question: key, 
                        answer: value, 
                        userAnswer: '', 
                        showInput: false, 
                        selectedValue: '' };
                });
                this.error = null;
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }

    handleRadioChange(event) {
        const question = event.target.dataset.id;
        const selectedValue = event.detail.value;
        this.questionAnswerMap = this.questionAnswerMap.map(item => {
            if (item.question === question) {
                return { ...item, selectedValue, showInput: selectedValue === 'false' };
            }
            return item;
        });
    }

    handleUserAnswerChange(event) {
        const question = event.target.dataset.id;
        const userAnswer = event.target.value;
        this.questionAnswerMap = this.questionAnswerMap.map(item => {
            if (item.question === question) {
                return { ...item, userAnswer };
            }
            return item;
        });
    }

    handleSubmit() {
        this.error = undefined;
        if (!this.validateHandleSubmit()) {
            return;
        }

        let trueCount = 0;
        let falseCount = 0;

        const cvlogs = this.questionAnswerMap.map(item => {

            const isValidAnswer = item.selectedValue === 'true';
            if (isValidAnswer) {
                trueCount++;
            } else {
                falseCount++;
            }

            return {
                question: item.question,
                expectedAnswer: item.answer,
                actualAnswer: isValidAnswer ? item.answer : item.userAnswer,
                isValidAnswer: isValidAnswer ? 'Yes' : 'No',
            };
        });

        const verificationResult = trueCount > 2 ? 'Success' : 'Fail';

        createCustomerVerificationLog({ cvLogs: JSON.stringify(cvlogs), recordId: this.recordId, status: verificationResult })
            .then(() => {
                this.showToast('Success', `Records created successfully`, 'success');
                this.handleClose();
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }
    
    validateHandleSubmit() {

        let isValid = true;
        let validationMessage = '';

        for (const item of this.questionAnswerMap) {
            if (!item.selectedValue) {
                isValid = false;
                validationMessage = `Please select an option for Question ${item.no}.`;
                break;
            } else if (item.selectedValue === 'false' && !item.userAnswer.trim()) {
                isValid = false;
                validationMessage = `Please provide an answer for Question ${item.no} where "No" is selected.`;
                break;
            }
        }

        if (!isValid) {
            this.error = validationMessage;
        }

        return isValid;
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
   
}