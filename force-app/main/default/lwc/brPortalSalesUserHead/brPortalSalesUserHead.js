import { LightningElement,track,wire,api } from 'lwc';
import getSalesTeam from '@salesforce/apex/BRPortalBrokerEventsController.getSalesTeam';

export default class BrPortalSalesUserHead extends LightningElement {
    searchKey = '';
    objectApiName='User';
    recordsList = [];
    message=""
    error=""
    selectedRecordId=""
    selectedValue = "";
    @api fieldapi
    handleKeyChange(event)
    {
        this.searchKey=event.target.value;
        console.log("in child",this.searchKey);
        // console.log(this.searchKey);
        // console.log(this.fieldapi);
        this.getLookupResult();
    }
    getLookupResult() { 

        getSalesTeam({ searchKey: this.searchKey, objectName : this.objectApiName })  
        
            .then((result) => {  
        
            if (result.length===0) {  
        
            this.recordsList = [];  
        
            this.message = "No Records Found";  
        
            } else {  
        
            this.recordsList = result.map(record => {
               const firstName = record.FirstName ? record.FirstName : '';
                    const lastName = record.LastName ? record.LastName : '';
                    const completeName = (firstName + ' ' + lastName).trim();

                    return {
                        ...record,
                        FirstName: firstName,
                        LastName: lastName,
                        completeName: completeName
                    };
            });
        
            this.message = "";  
        
            }  
        
            this.error = undefined;  
        
            })  
        
            .catch((error) => {  
        
            this.error = error;  
        
            this.recordsList = [];  
        
            });  
        
        }


        onRecordSelection(event) {  
        
        this.selectedRecordId = event.target.dataset.key;  
        
        this.selectedValue = event.target.dataset.name;  
        
        
        this.searchKey = "";  
        setTimeout(() => {

            this.dispatchEvent(
                new CustomEvent('select', {
                    detail: {
                        fieldName:this.fieldapi,
                        value: this.selectedRecordId
                    }
                })
            );
            
        }, 1000);
        
        
        //this.onSelecetedRecordUpdate();  
        
        } 
        removeRecordOnLookup()
        {
            this.selectedRecordId = "";  
        
            this.selectedValue = "";  
            
            this.searchKey = "";  

            this.recordsList = [];
        }

        get recordPresent()
        {
            if(this.recordsList.length===0)
                {
                    return false;
                }
            else
            {
                return true;
            }
        }

        onLeave(event) {
            console.log('call here 116');
            console.log('call here 116' + this.searchKey);
            console.log('call here 116' + this.selectedRecordId);
            console.log('call here 116' + this.selectedValue);
            console.log('call here 116' + JSON.stringify(this.recordsList));
            //this.searchKey = '';
            //this.recordsList = [];
        }

        @api callFromParentHead() {
            console.log('===> call 12666');
            console.log('call here 11666' + JSON.stringify(this.recordsList));
            this.searchKey = '';
            this.recordsList = [];
        }
}