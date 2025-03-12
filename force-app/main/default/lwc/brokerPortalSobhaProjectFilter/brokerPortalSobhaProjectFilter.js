import { LightningElement, api, wire,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import portalOverrideStyle from '@salesforce/resourceUrl/portalOverrideStyle';
import getRelatedFiles from '@salesforce/apex/BrokerPortalSobhaProjectsController.getRelatedFiles';
import createDataDownloadTracker from '@salesforce/apex/BrokerPortalSobhaProjectsController.createDataDownloadTracker';
// import getonlyProjects from '@salesforce/apex/BrokerPortalSobhaProjectsController.getonlyProjects';

export default class BrokerPortalSobhaProjectFilter extends LightningElement {
    
    isFilterModalOpen=false;
    filesList=[];
    brouchername='360 Riverside Crescent'; // define broucher file name here
    collateralname='test'; // define collateral file name here
    projectid='a0R5t000001PqeCEAS'; // fetch the project id dynamically
    @api selectedProjectValue;
    @api selectedBedValue='';
    @api selectedAreaValue='';
    @api selectedPriceValue='';
    @api selectedPropertyTypeValue='';
    @api allProjects;
    @api projects = [];
    @api downloadTrackerId;
    subProjects = [];
    unitTypes = [];
    floors = [];
    variants = [];

    connectedCallback() {
        loadStyle(this, portalOverrideStyle); 
    }

    handleFilterModalClose(event){
      this.isFilterModalOpen=false;
    }

    openFilterModal(){
        this.createDataDownloadTracker();
        this.isFilterModalOpen=true;
    }

     createDataDownloadTracker() {
        createDataDownloadTracker({projectId:'',filterCriteria:'FilterProperties'})
            .then(result => {
                // Store the created download tracker Id for future updates.
                this.downloadTrackerId = result;
                console.log('downloadTrackerId',this.downloadTrackerId);
            })
            .catch(error => {
                console.error('Error creating download tracker record:', error);
            });
    }

    handleProjectChange(event){
        if(event.detail.value=='None')
            this.selectedProjectValue='';
        else
            this.selectedProjectValue=event.detail.value;
    }

    handleBedChange(event){
        if(event.detail.value=='None')
            this.selectedBedValue='';
        else
            this.selectedBedValue=event.detail.value;
    }

    handleAreaChange(event){
        if(event.detail.value=='None')
            this.selectedAreaValue='';
        else
            this.selectedAreaValue=event.detail.value;
    }

    handlePriceChange(event){
        if(event.detail.value=='None')
            this.selectedPriceValue='';
        else
            this.selectedPriceValue=event.detail.value;
    }

    handlepropertyTypeChange(event){
        if(event.detail.value=='None')
            this.selectedPropertyTypeValue='';
        else
            this.selectedPropertyTypeValue=event.detail.value;
    }

          
    downloadbrochure()
    {
       getRelatedFiles({filename: this.brouchername, projectid: this.projectid}).then(result =>
          {
             console.log('Resulut is', JSON.stringify(result));
             if(result.length > 0)
             {
               let filedownloadurl =window.location.origin;
               filedownloadurl=filedownloadurl+'/sfc/servlet.shepherd/document/download';
               filedownloadurl+='/'+result;
                console.log('filedownloadurl is', filedownloadurl);
                this[ NavigationMixin.Navigate ] ( {
                  type : 'standard__webPage',
                  attributes : {
                      url: filedownloadurl
                  }
                 }, false);
             }
          }
       )
    }

    MarketingCollaterals()
    {
       getRelatedFiles({filename: this.collateralname, projectid: this.projectid}).then(result =>
          {
             console.log('Resulut is', JSON.stringify(result));
             if(result.length > 0)
             {
               let filedownloadurl =window.location.origin;
               filedownloadurl=filedownloadurl+'/sfc/servlet.shepherd/document/download';
               filedownloadurl+='/'+result;
                console.log('filedownloadurl is', filedownloadurl);
                this[ NavigationMixin.Navigate ] ( {
                  type : 'standard__webPage',
                  attributes : {
                      url: filedownloadurl
                  }
                 }, false);
             }
          }
       )
   }

    get beds() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Studio', value: 'Studio' },
            { label: '1 BR', value: '1 BR' },
            { label: '1.5 BR', value: '1.5 BR' },
            { label: '2 BR', value: '2 BR' },
            { label: '2.5 BR', value: '2.5 BR' },
            { label: '3 BR', value: '3 BR' },
            { label: '3.5 BR', value: '3.5 BR' },
            { label: '4 BR', value: '4 BR' },
            { label: '5 BR', value: '5 BR' },
            { label: '6 BR', value: '6 BR' },
            { label: '2 BR Duplex', value: '2 BR Duplex' },
            { label: '3 BR Duplex', value: '3 BR Duplex' },
            { label: '4 BR Duplex', value: '4 BR Duplex' },
        ];
    }

    get areas() {
        return [
            { label: 'None', value: 'None' },
            { label: '0 – 500 Sq. Ft', value: '0 – 500 Sq. Ft' },
            { label: '500 – 1000 Sq. Ft', value: '500 – 1000 Sq. Ft' },
            { label: '1000 – 1500 Sq. Ft', value: '1000 – 1500 Sq. Ft' },
            { label: '1500 – 2000 Sq. Ft', value: '1500 – 2000 Sq. Ft' },
            { label: '2000 – 2500 Sq. Ft', value: '2000 – 2500 Sq. Ft' },
            { label: '2500 – 3000 Sq. Ft', value: '2500 – 3000 Sq. Ft' },
            { label: '3000 – 4000 Sq. Ft', value: '3000 – 4000 Sq. Ft' },
            { label: '4000 – 6000 Sq. Ft', value: '4000 – 6000 Sq. Ft' },
            { label: '6000+ Sq. Ft', value: '6000+ Sq. Ft' },
        ];
        
    }

    get price() {
        return [
            { label: 'None', value: 'None' },
            { label: '0 – AED 1 Million', value: 'AED 0 Million – AED 1 Million' },
            { label: 'AED 1 Million – AED 2 Million', value: 'AED 1 Million – AED 2 Million' },
            { label: 'AED 2 Million – AED 3 Million', value: 'AED 2 Million – AED 3 Million' },
            { label: 'AED 3 Million – AED 4 Million', value: 'AED 3 Million – AED 4 Million' },
            { label: 'AED 4 Million – AED 5 Million', value: 'AED 4 Million – AED 5 Million' },
            { label: 'AED 5 Million – AED 6 Million', value: 'AED 5 Million – AED 6 Million' },
            { label: 'AED 6 Million – AED 8 Million', value: 'AED 6 Million – AED 8 Million' },
            { label: 'AED 8 Million – AED 10 Million', value: 'AED 8 Million – AED 10 Million' },
            { label: 'AED 10+ Million', value: '10+ Million' },
        ];
    }

    get propertytypes() {
        return [
            { label: 'None', value: 'None' },
            { label: 'Apartments', value: 'Apartments' },
            { label: 'Villas', value: 'Villas' },
            { label: 'Others', value: 'Others' },
        ];
    }

    get currencies() {
        return [
            { label: 'AED', value: 'AED' },
            { label: 'Euro', value: 'Euro' },
            { label: 'GBP', value: 'GBP' },
            { label: 'USD', value: 'USD' },
        ];
    }
}