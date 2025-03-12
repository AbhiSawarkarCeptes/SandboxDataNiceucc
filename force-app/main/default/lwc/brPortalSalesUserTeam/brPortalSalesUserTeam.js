import { LightningElement,track,wire,api } from 'lwc';
import getSalesTeam from '@salesforce/apex/BRPortalBrokerEventsController.getSalesTeam';

export default class BrPortalSalesUserTeam extends LightningElement {
    searchKeyTeam = '';
    objectApiName='User';
    recordsTeamList = [];
    message=""
    error=""
    selectedRecordId=""
    selectedValue = "";
    @api fieldapi
    handleKeyChange(event)
    {
        this.searchKeyTeam=event.target.value;
        console.log("in child",this.searchKeyTeam);
        // console.log(this.searchKey);
        // console.log(this.fieldapi);
        this.getLookupResult();
    }
    getLookupResult() { 

        getSalesTeam({ searchKey: this.searchKeyTeam, objectName : this.objectApiName })  
        
            .then((result) => {  
        
            if (result.length===0) {  
        
            this.recordsTeamList = [];  
        
            this.message = "No Records Found";  
        
            } else {  
        
            this.recordsTeamList = result.map(record => {
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
        
            this.recordsTeamList = [];  
        
            });  
        
        }


        onRecordSelection(event) {  
        
        this.selectedRecordId = event.target.dataset.key;  
        
        this.selectedValue = event.target.dataset.name;  
        
        
        this.searchKeyTeam = "";  
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
            
            this.searchKeyTeam = "";  

            this.recordsTeamList = [];
        }

        get recordPresent()
        {
            if(this.recordsTeamList.length===0)
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
            console.log('call here 116' + this.searchKeyTeam);
            console.log('call here 116' + this.selectedRecordId);
            console.log('call here 116' + this.selectedValue);
            console.log('call here 116' + JSON.stringify(this.recordsTeamList));
            //this.searchKey = '';
            //this.recordsList = [];
        }

        @api callFromParentTeam() {
            console.log('===> call 12623');
            console.log('call here 11623' + JSON.stringify(this.recordsTeamList));
            this.searchKeyTeam = '';
            this.recordsTeamList = [];
        }
}