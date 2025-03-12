import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDemands from '@salesforce/apex/DueDemandsController.getDueDemands';
import demandActions from '@salesforce/apex/DueDemandsController.demandActions';



export default class DueDemands extends NavigationMixin(LightningElement) {
    
    @track demandData=[];
  
    //@wire( getDemands ) 
    //demandRecord({ error, data }) { 
 
      //  if ( data ) { 
 //
   //         this.demandData = data; 
 
     //   } else if ( error )
       //     console.log( 'Error is ' + JSON.stringify( error ) );
         
    //}

    connectedCallback() {
      this.loadDemands();
    }

    loadDemands(){
        
        getDemands()
            .then(result=>{
                //alert(result.length);
                this.demandData =result;
                console.log('I am demandData'+this.demandData);
               
            })
            .catch(error => {
                console.log('i am error in leaddemands');
            }); 
    }

    onDemandSelect(event){

        var bookingId = event.currentTarget.id;
        bookingId = bookingId.split('-')[0];
        console.log('I am row id'+bookingId);
        demandActions({
            bookingId : bookingId
        })
            .then(result=>{
                console.log('succeded-->');
                
                this.loadDemands();
                alert('Email sent to customer');
                
                console.log('i am after refresh');
            })
            .catch(error => {
                console.log('i am error in bookingselect'+JSON.stringify(error));
            });
    }
}