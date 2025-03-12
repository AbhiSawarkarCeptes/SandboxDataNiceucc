import { LightningElement, track } from 'lwc';
import accountRecMethod from '@salesforce/apex/BrokerDetailFormController.accountRecMethod';
import searchSalesManager from '@salesforce/apex/BrokerDetailFormController.searchSalesManager';
import getChrmEmail from '@salesforce/apex/BrokerDetailFormController.getChrmEmail';
import getChrmUser from '@salesforce/apex/BrokerDetailFormController.getChrmUser';
import registartionNoValidate from '@salesforce/apex/BrokerDetailFormController.registartionNoValidate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class BrokerDetailFormLWC extends NavigationMixin(LightningElement) {

    @track name;
    @track phone = '';
    @track email = '';
    @track regNumber;
    @track reraRegNo;
    @track regDate;
    @track termDate;
    @track agencyEmail;
    @track countryCode;
    @track street;
    @track city;
    @track state;
    @track country;
    @track poBox;
    @track firstName;
    @track lastName;
    @track countryAcc = '';
    @track contactEmail;
    @track contactCountryCode;
    @track contactPhone = '';
    @track numbers = [1];
    @track count = 1;
    @track disableRemove = true;
    @track contactDataMap = new Map();
    @track currentIndex;
    @track editedFld;
    @track nationality;
    @track passportNo;
    @track passportNationality;
    @track passportIssueDate;
    @track passportExpiryDate;
    @track EmiratesId;
    @track EmiratesIdIssueDate;
    @track EmiratesIdExpDate;
    @track brktype;
    @track brkSubType = '';
    @track brokerCategory;
    @track trnNo;
    @track salesManagerId = '';
    @track channelRelationshipId = '';
    @track CategoryFlag = false;
    @track TRNFlag = false;
    @track PassportFlag = false;
    @track chrmEmail = '';
    @track aiSiniyaCB = false;
    timeSpan = 750;
    event1;
    timeSpan2 = 3900;
    event2;

    @track searchKey = '';
    @track searchResults = [];
    @track showResults = false;
    @track isChrmUser = false;

    @track searchKey1 = '';
    @track searchResults1 = [];
    @track showResults1 = false;

    checkTrnNumber = '';
    checkPassportNumber = '';


    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.showResults = true;
        this.searchSalesManagers();
    }

    searchSalesManagers() {
        console.log(this.recordId);
        searchSalesManager({
            searchKeyWrd: this.searchKey
        }).then(result => {
            console.log(result);
            this.searchResults = result;
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
        });
    }
    getChrmEmail1() {
        getChrmEmail({
            searchKeyWrd: this.channelRelationshipId
        }).then(result => {
            console.log(result);
            if (result.length > 0) {
                this.chrmEmail = result;
            } else {
                this.chrmEmail = '';
            }
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
        });
    }
    getChrmUser1() {
        getChrmUser({
        }).then(result => {
            console.log(result);
            if (result != null) {
                this.isChrmUser = true;
                this.channelRelationshipId = result.Id;
                this.searchKey1 = result.Name;
                this.chrmEmail = result.Email;
            } else {
                this.isChrmUser = false;
                this.searchKey1 = '';
                this.channelRelationshipId = '';
                this.chrmEmail = '';
            }
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
        });
    }

    handleResultClick(event) {
        this.salesManagerId = event.target.title;
        this.searchKey = event.target.dataset.id;
        this.showResults = false;
        console.log(this.salesManagerId);
    }

    handleSearchKeyChange1(event) {
        this.searchKey1 = event.target.value;
        this.showResults1 = true;
        this.searchSalesManagers1();
        
    }

    handleBrokerCategoryChange(event) {        
            this.brokerCategory = event.target.value;
            console.log('**----',this.brokerCategory);
            if(this.brokerCategory == 'Individual'){
                 this.TRNFlag = true;
                 this.PassportFlag = false;
            }
            else if(this.brokerCategory == 'Company'){
                    this.PassportFlag = true;
                    this.TRNFlag = false;
            }                
    }

    searchSalesManagers1() {
        searchSalesManager({
            searchKeyWrd: this.searchKey1
        }).then(result => {
            console.log(result);
            this.searchResults1 = result;
        })
        .catch(error => {
            console.log('rooro -> ',JSON.stringify(error));
        });
    }

    handleResultClick1(event) {
        this.channelRelationshipId = event.target.title;
        this.searchKey1 = event.target.dataset.id;
        this.showResults1 = false;
        this.getChrmEmail1();
        console.log(this.channelRelationshipId);
    }

    showDialog() {
        this.showResults = true;
        this.showResults1 = false;
    }
    showDialog1() {
        this.showResults1 = true;
        this.showResults = false;
    }

    connectedCallback() {
        console.log('in1--');
        this.labelChanges();
        this.searchSalesManagers();
        this.searchSalesManagers1();
        this.getChrmUser1();
    }

    handleNameChange(event) {
        this.name = event.target.value.toUpperCase();
    }
    handleCHRMEmailChange(event) {
        this.chrmEmail = event.target.value;
    }
    handleAlSiniyaPartner(event) {
        this.aiSiniyaCB = event.target.value;
    }

    handlePhoneChange(event) {
        var temp = event.target.value;
        var phoneNumber = event.target.value;
        phoneNumber = phoneNumber.replace(/[^0-9+]/g, '');
        console.log(typeof phoneNumber);
        console.log(typeof temp);
        console.log(phoneNumber);
        console.log(temp);
        console.log(temp == phoneNumber);
        if (temp === phoneNumber) {
            if (phoneNumber.length <= 15) {
                this.phone = phoneNumber;
            } else {
                alert('Length of Phone number must be under 15 characters');
                this.phone = '';
            }
        } else {
            alert('Field can include only numbers OR + character');
            this.phone = '';
        }
    }

    handleEmailchange(event) {
        this.email = event.target.value;
    }

    handleBrokerTypeChange(event) {
        this.brktype = event.target.value;
        if(this.brktype != 'Standard'){
            this.CategoryFlag = false;
        }
    }

    handleBrokerSubTypeChange(event) {
        this.brkSubType = event.target.value;
        if(this.brktype == 'Standard' && this.brkSubType != '' && !this.brkSubType.includes('Broker International')){
            this.brokerCategory = 'Company';
            this.CategoryFlag = true;
        } else if (this.brktype == 'Standard' && this.brkSubType != '' && this.brkSubType.includes('Broker International')) {
            this.CategoryFlag = false;
            this.brokerCategory = '';
        }
        
    }
    handleCountryCodeChange(event) {
        this.countryCode = event.target.value;
    }
    handleCountryChange(event) {
        this.countryAcc = event.target.value;
    }

    handleRegistrationNumberchange(event) {
        this.regNumber = event.target.value;
    }

    handleReraRegistrationchange(event) {
        this.reraRegNo = this.changeDateFormat(event.target.value);
    }

    handleREGchange(event) {
        this.regDate =  this.changeDateFormat(event.target.value);
    }

    handleBrokerTerminationchange(event) {
        this.termDate =  this.changeDateFormat(event.target.value);
    }

    handleAgencyEmailchange(event) {
        this.agencyEmail = event.target.value;
    }

    handleStreetchange(event) {
        this.street = event.target.value;
    }  

    handleCitychange(event) {
        this.city = event.target.value;
    }
    
    handleStatechange(event) {
        this.state = event.target.value;
    }
    handleTrnNumberChange(event) {
        this.trnNo = event.target.value;
    }
    handlecheckRegValidation(event) {
        if(event.target.value != '' && event.target.value != undefined) {
            registartionNoValidate({
                regNumber : event.target.value
            }).then(result => {
                if(result === 'Success') {
                    this.checkPassportNumber = '';
                    this.checkTrnNumber = '';
                }
                else {
                    if(!this.TRNFlag) {
                        this.checkTrnNumber = this.trnNo;
                        this.checkPassportNumber = '';
                        alert('Trade License /Registration Number is already used in Account : '+result);
                    }
                    else if(!this.PassportFlag) {
                        this.checkPassportNumber = this.regNumber;
                        this.checkTrnNumber = '';
                        alert('Passport Number is already used in Account : '+result);
                    }
                }
            })
            .catch(error => {
                console.log('handlecheckRegValidation -> ',JSON.stringify(error));
            });
        }
    }

    handlePOBoxchange(event) {
        this.poBox = event.target.value;
    } 

    changeDateFormat(valDate) {
        let arr = valDate.split('-');
        return arr[2]+'/'+arr[1]+'/'+arr[0];
    } 

    handleFirstName(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'FirstName';
        this.firstName = event.target.value;
    } 

    handleLastName(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'LastName';
        this.lastName = event.target.value;
    } 

    handleContactEmail(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'Email';
        this.contactEmail = event.target.value;
    } 
    handleContryCode(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'CountryCode';
        this.contactCountryCode = event.target.value;
    } 

    handleContactPhone(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'Phone';
        this.contactPhone = event.target.value;
    } 

    handleNationality(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'Nationality';
        this.nationality = event.target.value;
    } 

    handlePassportNo(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'PassportNumber';
        this.passportNo = event.target.value;
    } 

    handlePassportNationality(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'PassportNationality';
        this.passportNationality = event.target.value;
    } 

    handlePassportIssueDate(event) {
        console.log(event.target);
        console.log(event.target.name);
        this.currentIndex = event.target.name;
        this.editedFld = 'PassportIssueDate';
        console.log(event.target.value);
        this.passportIssueDate = event.target.value;
    } 

    handlePassportExpiryDate(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'PassportExpiryDate';
        this.passportExpiryDate = event.target.value;
    } 

    handleEmiratesId(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'EmiratesId';
        this.EmiratesId = event.target.value;
    } 

    handleEmiratesIdIssueDate(event) {
        this.currentIndex = event.target.name;
        this.editedFld = 'EmiratesIdIssueDate';
        this.EmiratesIdIssueDate = event.target.value;
    } 

    handleEmiratesIdExpDate(event) {
        this.currentIndex = event.target.name;
        console.log(this.currentIndex);
        this.editedFld = 'EmiratesIdExpiryDate';
        this.EmiratesIdExpDate = event.target.value;
    } 

    fillMap() {
        console.log('inn');
        console.log(this.lastName);
        let fn = this.firstName != undefined ? this.firstName : '';
        let ln = this.lastName != undefined ? this.lastName : '';
        let ph = this.contactPhone != undefined ? this.contactPhone : '';
        let em = this.contactEmail != undefined ? this.contactEmail : '';
        let nt = this.nationality != undefined ? this.nationality : '';
        let pno = this.passportNo != undefined ? this.passportNo : '';
        let cc = this.contactCountryCode != undefined ? this.contactCountryCode : '';
        let pna = this.passportNationality != undefined ? this.passportNationality : '';
        let pid = this.passportIssueDate != undefined ? this.passportIssueDate : '';
        let ped = this.passportExpiryDate != undefined ? this.passportExpiryDate : '';
        let ei = this.EmiratesId != undefined ? this.EmiratesId : '';
        let eid = this.EmiratesIdIssueDate != undefined ? this.EmiratesIdIssueDate : '';
        let eed = this.EmiratesIdExpDate != undefined ? this.EmiratesIdExpDate : '';
        let mapDt = this.contactDataMap;
        console.log('mapDt*----'+mapDt);
        let curIndex = this.currentIndex;
        console.log('mapDt*----'+curIndex);
        if(((ln != null && ln != '' && ln != undefined) && (fn != null && fn != '' && fn != undefined) ) || mapDt.has(curIndex)) {
            console.log(curIndex);
            let ele = this.editedFld;
            let dt = '';
            console.log(ele)
            console.log(pid);
            console.log(ped);
            console.log(ln);
            if(!mapDt.has(curIndex)) {
                dt = '{"FirstName":"'+fn+'","LastName":"'+ln+'","Email":"'+em+'","Phone":"'+ph+'","Nationality":"'+nt+'","PassportNumber":"'+pno+'","CountryCode":"'+cc+'","PassportNationality":"'+pna+'","PassportIssueDate":"'+pid+'","PassportExpiryDate":"'+ped+'","EmiratesId":"'+ei+'","EmiratesIdIssueDate":"'+eid+'","EmiratesIdExpiryDate":"'+eed+'"}';
            } else if(mapDt.has(curIndex)) {
                let dataObj = JSON.parse(mapDt.get(curIndex));
                if(ele == 'FirstName') {
                    dataObj[ele] = fn;
                } else if(ele == 'LastName') {
                    dataObj[ele] = ln;
                } else if(ele == 'Email') {
                    dataObj[ele] = em;
                } else if(ele == 'Phone') {
                    dataObj[ele] = ph;
                } else if(ele == 'Nationality') {
                    dataObj[ele] = na;
                } else if(ele == 'PassportNumber') {
                    dataObj[ele] = pno;
                } else if(ele == 'CountryCode') {
                    dataObj[ele] = pno;
                } else if(ele == 'PassportNationality') {
                    dataObj[ele] = pna;
                } else if(ele == 'PassportIssueDate') {
                    dataObj[ele] = pid;
                } else if(ele == 'PassportExpiryDate') {
                    dataObj[ele] = ped;
                } else if(ele == 'EmiratesId') {
                    dataObj[ele] = ei;
                } else if(ele == 'EmiratesIdIssueDate') {
                    dataObj[ele] = eid;
                } else if(ele == 'EmiratesIdExpiryDate') {
                    dataObj[ele] = eed;
                } 
                dt = JSON.stringify(dataObj);
            }
            mapDt.set(curIndex, dt);
            this.contactDataMap = mapDt;
            ln = '';
            this.lastName = '';
            this.firstName = '';
            this.contactPhone = '';
            this.contactEmail = '';
            this.nationality = '';
            this.passportNo = '';
            this.passportNationality = '';
            this.passportIssueDate = '';
            this.passportExpiryDate = '';
            this.EmiratesId = '';
            this.EmiratesIdIssueDate = '';
            this.EmiratesIdExpDate = '';
            this.contactCountryCode = '';
        }        
    }
    addContactRow() {
        this.fillMap();
        let mapDt = this.contactDataMap;
        let addArr = this.numbers;
        console.log(mapDt.size,'**--**',addArr.length);
        console.log('**--**',mapDt.has(this.currentIndex));
        if(mapDt.size == addArr.length && mapDt.has(this.currentIndex)) {
            addArr.push(addArr.length+1);
            this.numbers = addArr;
            this.triggerEventOnce();
        } else {
            
            if(this.lastName == null || this.lastName == '' || this.lastName == undefined){
                let eventMsg = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Enter Last Name',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                this.dispatchEvent(eventMsg);
                alert('Please Enter Last Name');
            }
            else if(this.firstName == null || this.firstName == '' || this.firstName == undefined){
                let eventMsg = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter first Name',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(eventMsg);
                alert('Please Enter first Name');
            }
        }
    }

    removeContactRow() {
        let map1 = this.contactDataMap;
        let index = this.numbers.length;
        let removeArr = this.numbers;
        if(removeArr.length > 1) {
            removeArr.splice(removeArr.indexOf(index), 1);
            this.numbers = removeArr;
            if(map1.has(index)) {
                map1.delete(index);
            }
            this.contactDataMap = map1;
            const obj = JSON.parse(map1.get(index - 1));
            this.lastName = obj["LastName"];
            this.currentIndex = index - 1;
            this.template.querySelector('[data-id="'+(index - 1)+'"]').classList.add('highlitghted-card');
        }
        if(removeArr.length == 1) {
            this.disableRemove = true;
            this.template.querySelector('[data-id="removeBtnId"]').classList.add("disabled");
        }
    }

    triggerEventOnce() {
        this.event1 = setTimeout(() => {
            let btn = this.template.querySelector('[data-id="removeBtnId"]');
            if(btn != null) {
                btn.classList.remove("disabled");
            }
            this.disableRemove = false;
            this.template.querySelector('[data-id="'+(this.numbers.length)+'"]').classList.add('highlitghted-card');
            this.template.querySelector('[data-id="'+(this.numbers.length-1)+'"]').classList.remove('highlitghted-card');
        }, this.timeSpan);
    }

    labelChanges() {
        this.event2 = setTimeout(() => {
            let nodes = this.template.querySelectorAll('[data-id="labels"]');
            console.log('in--'+this.getElementsByTagName('label'));
            console.log(nodes);
            console.log(JSON.stringify(this.getElementsByTagName('label')));
            console.log(JSON.parse(JSON.stringify(nodes)));
            console.log(nodes.length);
            for (let i = 0; i < nodes.length; i++) {
                console.log(nodes[i]);
                let content = nodes[i].outerText;
                console.log(content);
                console.log(nodes[i].label);
                if(content === 'Billing Zip/Postal Code') {
                    //nodes[i].label = 'PO Box';
                }
                if(content === 'Billing State/Province') {
                  //  nodes[i].innerHTML = 'State';
                }
                if(content === 'Email ID 1') {
                   // nodes[i].innerHTML = 'Email';
                }
                if(content.includes('Billing ')) {
                  //  nodes[i].innerHTML = content.replace('Billing ','');
                }
            }
            if (navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/webOS/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/iPod/i) || navigator.userAgent.match(/BlackBerry/i) || navigator.userAgent.match(/Windows Phone/i)) {
                this.template.querySelector('[data-id="sldsGrid"]').classList.add('slds-grid_vertical');
                this.template.querySelector('[data-id="sldsGrid1"]').classList.add('slds-grid_vertical');
                this.template.querySelector('[data-id="sldsGrid2"]').classList.add('slds-grid_vertical');
                this.template.querySelector('[data-id="sldsGrid3"]').classList.add('slds-grid_vertical');
            }
        }, this.timeSpan2);
    }

    createAccRec() {
        console.log('inn'); 
        if ((this.brokerCategory != null  && ((this.brokerCategory == 'Company' && this.trnNo != null) || (this.brokerCategory == 'Individual' && this.regNumber != null) ))  ) {
            console.log('inn2');
            if(this.checkTrnNumber != null && this.checkTrnNumber != '' && this.checkTrnNumber == this.trnNo) {
                alert('Trade License /Registration Number is already used in Account.');
            }
            else if(this.checkRegNumber != null && this.checkRegNumber != '' && this.checkRegNumber == this.regNumber) {
                alert('Registration Number is already used in Account.');
            } 
            else {
                this.fillMap();
                console.log('inn3');
                let mapDt = this.contactDataMap;
                console.log(mapDt);
                console.log(mapDt != null);
                console.log(mapDt != '');
                console.log(mapDt != undefined);
                console.log(mapDt != '');
                console.log(mapDt.size > 0);
                console.log(mapDt.has(this.currentIndex));            
                if (mapDt != null && mapDt != '' && mapDt != undefined && mapDt != '' && mapDt.size > 0 && mapDt.has(this.currentIndex)) {
                    console.log(mapDt);
                    var obj = Object.fromEntries(mapDt);
                    console.log(obj);
                    var jsonString = JSON.stringify(obj);
                    console.log(jsonString);
                    if (this.brkSubType == '' || this.brkSubType == undefined || this.brkSubType == null) 
                        alert('Please Select Broker Sub Type');
                    else if(this.phone == null || this.phone == '') {
                        alert('Please fill Phone Number.');
                    }
                    else if(this.agencyEmail == null || this.agencyEmail == '') {
                        alert('Please fill Email Address.');
                    }
                    else if(this.countryAcc == null || this.countryAcc == '') {
                        alert('Please Select Dialing Country for Account.');
                    }
                    else if(this.salesManagerId == null || this.salesManagerId == '') {
                        alert('Please Select Sales Manager.');
                    }
                    else if(this.channelRelationshipId == null || this.channelRelationshipId == '') {
                        alert('Please Select Channel Relationship Manager.');
                    }
                    else if(this.chrmEmail == null || this.chrmEmail == '') {
                        alert('Please Fill CHRM Email.');
                    }
                    else {
                        accountRecMethod({ aiSiniya : this.aiSiniyaCB, brkCat : this.brokerCategory, accSm : this.salesManagerId, accCr : this.channelRelationshipId, accName: this.name, accTrnNumber: this.trnNo, accBrkType: this.brktype, accBrkSubType: this.brkSubType, accPhone: this.phone, accEmail: this.email, accRegNo: this.regNumber, accDoj: this.reraRegNo, accResDate: this.regDate, accTermDate: this.termDate, accAlterPhone: this.agencyEmail, contactRecs: jsonString.replaceAll('\\', ''), contryCode : this.countryCode, countryAcc : this.countryAcc, chrmEmail : this.chrmEmail})
                        .then(result => {
                            this.message = result;
                            this.error = undefined;
                            if (this.message !== undefined) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success',
                                        message: 'Account and It\'s Contact are created',
                                        variant: 'success',
                                    }),
                                );
                            }
                            alert('Account and It\'s Contact are created');
                            let u = window.location.href;
                            window.open(u.substring(0, u.indexOf('.com') + 4) + '/' + result.Id, '_blank');
                            location.reload();

                        })
                        .catch(error => {
                            this.message = undefined;
                            this.error = error;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error creating record',
                                    message: error.body.message,
                                    variant: 'error',
                                }),
                            );
                            alert(error.body.message);
                        });
                    }
                } else {
                    if(this.lastName == null || this.lastName == '' || this.lastName == undefined){
                        let eventMsg = new ShowToastEvent({
                                title: 'Error',
                                message: 'Please Enter Last Name',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                        this.dispatchEvent(eventMsg);
                        alert('Please Enter Last Name');
                    }
                    else if(this.firstName == null || this.firstName == '' || this.firstName == undefined){
                        let eventMsg = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please Enter first Name',
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(eventMsg);
                        alert('Please Enter first Name');
                    }
                }
            }
        } else {
            console.log('OUTPUT : enter in else part',);
            if (this.brktype == '' || this.brktype == undefined || this.brktype == null) {
                alert('Please Select Broker Type');
            } else if (this.brkSubType == '' || this.brkSubType == undefined || this.brkSubType == null) {
                alert('Please Select Broker Sub Type');
            } 
            else if (this.brktype == 'Sobha Connect' && this.brokerCategory == 'Individual' && (this.regNumber == null || this.regNumber == undefined || this.regNumber == '')) {
                alert('Please Fill Registration/Passport Number');
            } 
            else if (this.brktype == 'Standard' && (this.trnNo == null || this.trnNo == undefined || this.trnNo == '')) {
                alert('Please Fill TRN Number');
            }
            else if(this.brokerCategory == null || this.brokerCategory == undefined || this.brokerCategory == ''){
                alert('Please Fill Broker Category');
            }
            else if(this.brokerCategory == 'Individual' && (this.regNumber == null || this.regNumber == undefined || this.regNumber == '')){
                alert('Broker Category = Individual please update Registration/Passport Number');
            }
        }
    }

    cancelBtn() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
        let u = window.location.href;
        window.open(u.substring(0,u.indexOf('.com')+4), '_self');
    }
}