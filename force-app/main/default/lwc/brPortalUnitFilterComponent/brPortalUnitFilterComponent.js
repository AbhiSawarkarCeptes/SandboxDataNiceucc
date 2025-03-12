import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import userId from '@salesforce/user/Id';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import getUnits from '@salesforce/apex/BRPortalSobhaProjectsController.getUnits';
import createQuotation from '@salesforce/apex/BRPortalSobhaProjectsController.createQuotation';
import getAllProjects from '@salesforce/apex/BRPortalSobhaProjectsController.getAllProjects';
import portalOverrideStyle from '@salesforce/resourceUrl/portalOverrideStyle';
import createExportTracker from '@salesforce/apex/BRPortalSobhaProjectsController.createExportTracker';

export default class BrPortalUnitFilterComponent extends NavigationMixin(LightningElement) {
   showSpinner = false;
   unitList = [];
   projectLoaded = false;
   @api selectedProjectValue = '';
   @api selectedBedValue = '';
   @api selectedAreaValue = '';
   @api selectedPriceValue = '';
   @api selectedPropertyTypeValue = '';
   selectedProjectName = ''
   closeIcon = portalAssests + '/assets/images/close.svg';
   displayProjectFilter = false;
   displayUnitTypeFilter = false;
   displayVariantsFilter = false;
   displayFloorFilter = false;
   displayUnitFilter = false;
   displayAreaFilter = false;
   displayPriceFilter = false;
   allProjects;
   @track projects = [];
   /*@track beds = [
      { key: '1 BR', value: '1 BR' },
      { key: '1.5 BR', value: '1.5 BR' },
      { key: '2 BR', value: '2 BR' },
      { key: '2.5 BR', value: '2.5 BR' },
      { key: '3 BR', value: '3 BR' },
      { key: '3.5 BR', value: '3.5 BR' },
      { key: '4 BR', value: '4 BR' },
      { key: '5 BR', value: '5 BR' },
      { key: '1 Bed Type A', value: '1 Bed Type A' },
      { key: '1 Bed Type B', value: '1 Bed Type B' },
      { key: '1 Bed Type C', value: '1 Bed Type C' },
      { key: '1 Bed Type D', value: '1 Bed Type D' },
      { key: '1 Bed Type D1', value: '1 Bed Type D1' },
      { key: '1 Bed Type E', value: '1 Bed Type E' },
      { key: '1 Bed Type F', value: '1 Bed Type F' },
      { key: '1 Bed Type G', value: '1 Bed Type G' },
      { key: '1.5 BED TYPE A', value: '1.5 BED TYPE A' },
      { key: '1.5 BED TYPE B', value: '1.5 BED TYPE B' },
      { key: '1.5 BED TYPE C', value: '1.5 BED TYPE C' },
      { key: '2 Bed Type A', value: '2 Bed Type A' },
      { key: '2 Bed Type B', value: '2 Bed Type B' },
      { key: '2 Bed Type C', value: '2 Bed Type C' },
      { key: '2 Bed Type D', value: '2 Bed Type D' },
      { key: '2 Bed Type D1', value: '2 Bed Type D1' },
      { key: '2 Bed Type E', value: '2 Bed Type E' },
      { key: '2 Bed Type F', value: '2 Bed Type F' },
      { key: '2 Bed Type G', value: '2 Bed Type G' },
      { key: '3 Bed Type A', value: '3 Bed Type A' },
      { key: '3 Bed Type B', value: '3 Bed Type B' },
      { key: '3 Bed Type C', value: '3 Bed Type C' },
      { key: '3 Bed Type D', value: '3 Bed Type D' },
      { key: '3 Bed Type E', value: '3 Bed Type E' },
      { key: '3 Bed Type F', value: '3 Bed Type F' },
      { key: '4 Bed Duplex A', value: '4 Bed Duplex A' },
      { key: '4 Bed Duplex B', value: '4 Bed Duplex B' },
      { key: '4 Bed Duplex C', value: '4 Bed Duplex C' },
      { key: 'Villa', value: 'Villa' },
      { key: '3BR + Servant', value: '3BR + Servant' },
      { key: '4BR + Servant', value: '4BR + Servant' },
      { key: 'Office', value: 'Office' }
   ];*/
   @track beds = [
      { key: 'Studio', value: 'Studio' },
      { key: '1 BR', value: '1 BR' },
      { key: '1.5 BR', value: '1.5 BR' },
      { key: '2 BR', value: '2 BR' },
      { key: '2.5 BR', value: '2.5 BR' },
      { key: '3 BR', value: '3 BR' },
      { key: '4 BR', value: '4 BR' },
      { key: '5 BR', value: '5 BR' },
      { key: '6 BR', value: '6 BR' },
      { key: '2 BR Duplex', value: '2 BR Duplex' },
      { key: '3 BR Duplex', value: '3 BR Duplex' },
      { key: '4 BR Duplex', value: '4 BR Duplex' }
   ];
   @track areas = [
      { key: '0 – 500 Sq. Ft', value: '0 – 500 Sq. Ft' },
      { key: '500 – 1000 Sq. Ft', value: '500 – 1000 Sq. Ft' },
      { key: '1000 – 1500 Sq. Ft', value: '1000 – 1500 Sq. Ft' },
      { key: '1500 – 2000 Sq. Ft', value: '1500 – 2000 Sq. Ft' },
      { key: '2000 – 2500 Sq. Ft', value: '2000 – 2500 Sq. Ft' },
      { key: '2500 – 3000 Sq. Ft', value: '2500 – 3000 Sq. Ft' },
      { key: '3000 – 4000 Sq. Ft', value: '3000 – 4000 Sq. Ft' },
      { key: '4000 – 6000 Sq. Ft', value: '4000 – 6000 Sq. Ft' },
      { key: 'Above 6000 Sq. Ft', value: '6000+ Sq. Ft' },
   ];
   @track price = [
      { key: 'AED 0 Million – AED 1 Million', value: 'AED 0 Million – AED 1 Million' },
      { key: 'AED 1 Million – AED 2 Million', value: 'AED 1 Million – AED 2 Million' },
      { key: 'AED 2 Million – AED 3 Million', value: 'AED 2 Million – AED 3 Million' },
      { key: 'AED 3 Million – AED 4 Million', value: 'AED 3 Million – AED 4 Million' },
      { key: 'AED 4 Million – AED 5 Million', value: 'AED 4 Million – AED 5 Million' },
      { key: 'AED 5 Million – AED 6 Million', value: 'AED 5 Million – AED 6 Million' },
      { key: 'AED 6 Million – AED 8 Million', value: 'AED 6 Million – AED 8 Million' },
      { key: 'AED 8 Million – AED 10 Million', value: 'AED 8 Million – AED 10 Million' },
      { key: 'Above 10 AED', value: '10+ Million AED' },
   ];
   @track propertytypes = [
      { key: 'Apartment', value: 'Apartment' },
      { key: 'Villas', value: 'Villas' },
      { key: 'Others', value: 'Others' }
   ];
   @track areascolumn = [
      { key: '0 – 500 Sq. Ft', value: '0 – 500 Sq. Ft' },
      { key: '500 – 1000 Sq. Ft', value: '500 – 1000 Sq. Ft' },
      { key: '1000 – 1500 Sq. Ft', value: '1000 – 1500 Sq. Ft' },
      { key: '1500 – 2000 Sq. Ft', value: '1500 – 2000 Sq. Ft' },
      { key: '2000 – 2500 Sq. Ft', value: '2000 – 2500 Sq. Ft' },
      { key: '2500 – 3000 Sq. Ft', value: '2500 – 3000 Sq. Ft' },
      { key: '3000 – 4000 Sq. Ft', value: '3000 – 4000 Sq. Ft' },
      { key: '4000 – 6000 Sq. Ft', value: '4000 – 6000 Sq. Ft' },
      { key: 'Above 6000 Sq. Ft', value: '6000+ Sq. Ft' },
   ];
   @track pricecolumn = [
      { key: '0 – AED 1 Million', value: 'AED 0 Million – AED 1 Million' },
      { key: 'AED 1 Million – AED 2 Million', value: 'AED 1 Million – AED 2 Million' },
      { key: 'AED 2 Million – AED 3 Million', value: 'AED 2 Million – AED 3 Million' },
      { key: 'AED 3 Million – AED 4 Million', value: 'AED 3 Million – AED 4 Million' },
      { key: 'AED 4 Million – AED 5 Million', value: 'AED 4 Million – AED 5 Million' },
      { key: 'AED 5 Million – AED 6 Million', value: 'AED 5 Million – AED 6 Million' },
      { key: 'AED 6 Million – AED 8 Million', value: 'AED 6 Million – AED 8 Million' },
      { key: 'AED 8 Million – AED 10 Million', value: 'AED 8 Million – AED 10 Million' },
      { key: 'Above 10 AED', value: '10+ Million AED' },
   ];
   @track subProjects = [];
   @track unitTypes = [];
   @track floors = [];
   @track variants = [];
   @track unitNames = [];
   selectedSubFilters = [];
   refreshSection = true;
   @track selectedSubProjects = [];
   @track selectedUnitTypes = [];
   @track selectedFloors = [];
   @track selectedFloorsDisplay = [];
   @track selectedUnitNames = [];
   @track selectedVariantes = [];
   @track selectedVariantesDisplay = [];
   @track selectedAreas = [];
   @track selectedPrices = [];
   noUnitsFound = false;
   @track selectedProjectMain = [];
   @track selectedBedMain = [];
   @track selectedAreaMain = [];
   @track selectedPriceMain = [];
   @track selectedPropertyTypeMain = [];
   columnHeader = ['Project', 'Unit Type', 'Variants', 'Floor', 'Unit No.', 'Total Unit Area (sq. ft.)', 'Starting Price (AED)']
   @track loggedInUserId = userId;
   showDownloadQuotationConfirmation = false;

   euro = 0.25;
   gbp = 0.21;
   usd = 0.27;

   selectedUnitIdForDownloadQuotation = '';
   customerName='';
   customerEmail='';

   @track selectedCurrency = 'AED';
   @track currencyList = [
      { label: 'AED', value: 'AED' },
      { label: 'Euro', value: 'Euro' },
      { label: 'GBP', value: 'GBP' },
      { label: 'USD', value: 'USD' },
   ];

   handleCustomerNameChange(event) {
      this.customerName = event.detail.value;
   }

   handleCustomerEmailChange(event) {
      this.customerEmail = event.detail.value;
   }

   handleCurrencyChange(event){
      this.selectedCurrency = event.detail.value;
      let unitList = this.unitList;
      let nfObject = new Intl.NumberFormat('en-US');
      for (var i = 0; i < unitList.length; i++) {
         let pp = unitList[i].PropStrength__Total_Sales_Consideration__c;
         if(this.selectedCurrency == 'Euro') {
            pp = pp * this.euro;
         }
         else if(this.selectedCurrency == 'GBP') {
            pp = pp * this.gbp;
         }
         else if(this.selectedCurrency == 'USD') {
            pp = pp * this.usd;
         }
         pp = pp.toFixed(2);
         unitList[i].displayPrice = nfObject.format(pp);
      }
      this.unitList = unitList;
   }
   
   closeDownloadQuotationConfirmation() {
      this.showDownloadQuotationConfirmation = false;
   }

   exportUnitData() {
      // Prepare a html table
      let doc = '<table>';
      // Add styles for the table
      doc += '<style>';
      doc += 'table, th, td {';
      doc += '    border: 1px solid black;';
      doc += '    border-collapse: collapse;';
      doc += '}';
      doc += '</style>';
      // Add all the Table Headers
      doc += '<tr>';
      this.columnHeader.forEach(element => {
         doc += '<th>' + element + '</th>'
      });
      doc += '</tr>';
      // Add the data rows
      this.unitList.forEach(record => {
         doc += '<tr>';
         doc += '<th>' + record.PropStrength__Tower__r.Name + '</th>';
         doc += '<th>' + record.PropStrength__Unit_Type__c + '</th>';
         doc += '<th>' + record.Variant__c + '</th>';
         doc += '<th>' + record.Floor_Name__c + '</th>';
         doc += '<th>' + record.Name + '</th>';
         doc += '<th>' + String.valueOf(record.PropStrength__Super_Area__c) + '</th>';
         doc += '<th>' + String.valueOf(record.PropStrength__Total_Sales_Consideration__c) + '</th>';
         doc += '</tr>';
      });
      doc += '</table>';
      var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
      let downloadElement = document.createElement('a');
      downloadElement.href = element;
      downloadElement.target = '_self';
      // use .csv as extension on below line if you want to export data as csv
      downloadElement.download = 'Units.xls';
      document.body.appendChild(downloadElement);
      downloadElement.click();
      let filterStr = '';
      if (this.selectedProjectName != '')
         filterStr += this.selectedProjectName + ' | ';
      if (this.selectedBedValue != '')
         filterStr += this.selectedBedValue + ' | ';
      if (this.selectedAreaValue != '')
         filterStr += this.selectedAreaValue + ' | ';
      if (this.selectedPriceValue != '')
         filterStr += this.selectedPriceValue + ' | ';
      if (this.selectedPropertyTypeValue != '')
         filterStr += this.selectedPropertyTypeValue + ' | ';
      let subFilters = this.selectedSubFilters;
      for (let i = 0; i < subFilters.length; i++) {
         filterStr += subFilters[i] + ' | ';
      }
      createExportTracker({ projectid: this.selectedProjectValue, userid: this.loggedInUserId, filterStr: filterStr })
      .then(result => {
         console.log('tracker result' + JSON.stringify(result));
      })
      .catch(error => {
         this.errorMsg = error;
         console.log('Error:' + JSON.stringify(error));
      })
   }

   handleSubProjectRemove(event) {
      let selectedSubProjects = this.selectedSubProjects;
      const index = selectedSubProjects.indexOf(event.detail.name);
      if (index >= 0)
         selectedSubProjects.splice(index, 1);
      this.selectedSubProjects = selectedSubProjects;
      let subProjects = this.subProjects;
      for (let i = 0; i < subProjects.length; i++) {
         if (subProjects[i].value == event.detail.name) {
            subProjects[i].selected = false;
         }
      }
      this.subProjects = subProjects;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleUnitTypeRemove(event) {
      let selectedUnitTypes = this.selectedUnitTypes;
      const index = selectedUnitTypes.indexOf(event.detail.name);
      if (index >= 0)
         selectedUnitTypes.splice(index, 1);
      this.selectedUnitTypes = selectedUnitTypes;

      let unitTypes = this.unitTypes;
      for (let i = 0; i < unitTypes.length; i++) {
         if (unitTypes[i].value == event.detail.name) {
            unitTypes[i].selected = false;
         }
      }
      this.unitTypes = unitTypes;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleVarientRemove(event) {
      let selectedVariantes = this.selectedVariantes;
      let selectedVariantesDisplay = this.selectedVariantesDisplay;
      const index = selectedVariantesDisplay.indexOf(event.detail.name);
      if (index >= 0) {
         selectedVariantes.splice(index, 1);
         selectedVariantesDisplay.splice(index, 1);
      }
      this.selectedVariantes = selectedVariantes;
      this.selectedVariantesDisplay = selectedVariantesDisplay;
      let variants = this.variants;
      for (let i = 0; i < variants.length; i++) {
         if (variants[i].value == event.detail.name) {
            variants[i].selected = false;
         }
      }
      this.variants = variants;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleFloorRemove(event) {
      let selectedFloors = this.selectedFloors;
      let selectedFloorsDisplay = this.selectedFloorsDisplay;
      const index = selectedFloorsDisplay.indexOf(event.detail.name);
      let removedItem = '';
      if (index >= 0) {
         removedItem = selectedFloors[index];
         selectedFloors.splice(index, 1);
         selectedFloorsDisplay.splice(index, 1);
      }
      this.selectedFloors = selectedFloors;
      this.selectedFloorsDisplay = selectedFloorsDisplay;
      let floors = this.floors;
      for (let i = 0; i < floors.length; i++) {
         if (floors[i].value == removedItem) {
            floors[i].selected = false;
         }
      }
      this.floors = floors;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleUnitNameRemove(event) {
      let selectedUnitNames = this.selectedUnitNames;
      const index = selectedUnitNames.indexOf(event.detail.name);
      if (index >= 0)
         selectedUnitNames.splice(index, 1);
      this.selectedUnitNames = selectedUnitNames;
      let unitNames = this.unitNames;
      for (let i = 0; i < unitNames.length; i++) {
         if (unitNames[i].value == event.detail.name) {
            unitNames[i].selected = false;
         }
      }
      this.unitNames = unitNames;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleSubAreaRemove(event) {
      let selectedAreas = this.selectedAreas;
      const index = selectedAreas.indexOf(event.detail.name);
      if (index >= 0)
         selectedAreas.splice(index, 1);
      this.selectedAreas = selectedAreas;
      let areascolumn = this.areascolumn;
      for (let i = 0; i < areascolumn.length; i++) {
         if (areascolumn[i].value == event.detail.name) {
            areascolumn[i].selected = false;
         }
      }
      this.areascolumn = areascolumn;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleSubPriceRemove(event) {
      let selectedPrices = this.selectedPrices;
      const index = selectedPrices.indexOf(event.detail.name);
      if (index >= 0)
         selectedPrices.splice(index, 1);
      this.selectedPrices = selectedPrices;

      let pricecolumn = this.pricecolumn;
      for (let i = 0; i < pricecolumn.length; i++) {
         if (pricecolumn[i].value == event.detail.name) {
            pricecolumn[i].selected = false;
         }
      }
      this.pricecolumn = pricecolumn;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   handleProjectRemove(event) {
      let selectedProjectMain = this.selectedProjectMain;
      const index = selectedProjectMain.indexOf(event.detail.name);
      if (index >= 0)
         selectedProjectMain.splice(index, 1);
      this.selectedProjectMain = selectedProjectMain;
      if (selectedProjectMain.length == 0)
         this.selectedProjectValue = '';

      let projects = this.projects;
      for (let i = 0; i < projects.length; i++) {
         if (projects[i].value == event.detail.name) {
            projects[i].selected = false;
         }
      }
      this.projectLoaded = false;
      this.projects = projects;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handleBedRemove(event) {
      let selectedBedMain = this.selectedBedMain;
      const index = selectedBedMain.indexOf(event.detail.name);
      if (index >= 0)
         selectedBedMain.splice(index, 1);
      this.selectedBedMain = selectedBedMain;
      if (selectedBedMain.length == 0)
         this.selectedBedValue = '';
      let beds = this.beds;
      for (let i = 0; i < beds.length; i++) {
         if (beds[i].value == event.detail.name) {
            beds[i].selected = false;
         }
      }
      this.projectLoaded = false;
      this.beds = beds;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handleAreaRemove(event) {
      let selectedAreaMain = this.selectedAreaMain;
      const index = selectedAreaMain.indexOf(event.detail.name);
      if (index >= 0)
         selectedAreaMain.splice(index, 1);
      this.selectedAreaMain = selectedAreaMain;
      if (selectedAreaMain.length == 0)
         this.selectedAreaValue = '';
      let areas = this.areas;
      for (let i = 0; i < areas.length; i++) {
         if (areas[i].value == event.detail.name) {
            areas[i].selected = false;
         }
      }
      this.projectLoaded = false;
      this.areas = areas;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handlePriceRemove(event) {
      let selectedPriceMain = this.selectedPriceMain;
      const index = selectedPriceMain.indexOf(event.detail.name);
      if (index >= 0)
         selectedPriceMain.splice(index, 1);
      this.selectedPriceMain = selectedPriceMain;
      if (selectedPriceMain.length == 0)
         this.selectedPriceValue = '';
      let price = this.price;
      for (let i = 0; i < price.length; i++) {
         if (price[i].value == event.detail.name) {
            price[i].selected = false;
         }
      }
      this.projectLoaded = false;
      this.price = price;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handlePropertyTypeRemove(event) {
      let selectedPropertyTypeMain = this.selectedPropertyTypeMain;
      const index = selectedPropertyTypeMain.indexOf(event.detail.name);
      if (index >= 0)
         selectedPropertyTypeMain.splice(index, 1);
      this.selectedPropertyTypeMain = selectedPropertyTypeMain;
      if (selectedPropertyTypeMain.length == 0)
         this.selectedPropertyTypeValue = '';
      let propertytypes = this.propertytypes;
      for (let i = 0; i < propertytypes.length; i++) {
         if (propertytypes[i].value == event.detail.name) {
            propertytypes[i].selected = false;
         }
      }
      this.projectLoaded = false;
      this.propertytypes = propertytypes;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handleRemove(event) {
      let selectedSubFilters = this.selectedSubFilters;
      const index = selectedSubFilters.indexOf(event.detail.name);
      if (index >= 0)
         selectedSubFilters.splice(index, 1);
      this.refreshSection = false;
      this.selectedSubFilters = selectedSubFilters;
      let selectedSubProjects = this.selectedSubProjects;
      const subIndex = selectedSubProjects.indexOf(event.detail.name);
      if (subIndex >= 0)
         selectedSubProjects.splice(subIndex, 1);
      this.selectedSubProjects = selectedSubProjects;
      let selectedUnitTypes = this.selectedUnitTypes;
      const subIndex1 = selectedUnitTypes.indexOf(event.detail.name);
      if (subIndex1 >= 0)
         selectedUnitTypes.splice(subIndex1, 1);
      this.selectedSubProjects = selectedSubProjects;
      let selectedFloors = this.selectedFloors;
      const subIndex2 = selectedFloors.indexOf(event.detail.name);
      if (subIndex2 >= 0)
         selectedFloors.splice(subIndex2, 1);
      this.selectedSubProjects = selectedSubProjects;
      let selectedUnitNames = this.selectedUnitNames;
      const subIndex3 = selectedUnitNames.indexOf(event.detail.name);
      if (subIndex3 >= 0)
         selectedUnitNames.splice(subIndex3, 1);
      this.selectedUnitNames = selectedUnitNames;
      let selectedVariantes = this.selectedVariantes;
      const subIndex4 = selectedVariantes.indexOf(event.detail.name);
      if (subIndex4 >= 0)
         selectedVariantes.splice(subIndex4, 1);
      this.selectedVariantes = selectedVariantes;

      let selectedAreas = this.selectedAreas;
      const subIndex5 = selectedAreas.indexOf(event.detail.name);
      if (subIndex5 >= 0)
         selectedAreas.splice(subIndex5, 1);
      this.selectedAreas = selectedAreas;
      let pricecolumn = this.pricecolumn;
      let removedPrice = '';
      for (let i = 0; i < pricecolumn.length; i++) {
         if (pricecolumn[i].label == event.detail.name) {
            removedPrice = pricecolumn[i].value;
            break;
         }
      }
      if (removedPrice != '') {
         let selectedPrices = this.selectedPrices;
         const subIndex6 = selectedPrices.indexOf(removedPrice);
         if (subIndex6 >= 0)
            selectedPrices.splice(subIndex6, 1);
         this.selectedPrices = selectedPrices;
      }
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
      this.refreshSection = true;
   }

   handleProjectChange(event) {
      let projects = this.projects;
      let selectedProjects = event.detail;
      let selectedProjectMain = [];
      for (let i = 0; i < selectedProjects.length; i++) {
         selectedProjectMain.push(selectedProjects[i].value);
      }
      for (let j = 0; j < projects.length; j++) {
         if (selectedProjectMain.includes(projects[j].value)) {
            projects[j].selected = true;
         }
         else {
            projects[j].selected = false;
         }
      }
      this.projects = projects;
      this.selectedProjectMain = selectedProjectMain;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handleBedChange(event) {
      let beds = this.beds;
      let selectedBeds = event.detail;
      let selectedBedMain = [];
      for (let i = 0; i < selectedBeds.length; i++) {
         selectedBedMain.push(selectedBeds[i].value);
      }
      for (let j = 0; j < beds.length; j++) {
         if (selectedBedMain.includes(beds[j].value)) {
            beds[j].selected = true;
         }
         else {
            beds[j].selected = false;
         }
      }
      this.beds = beds;
      this.selectedBedMain = selectedBedMain;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handleAreaChange(event) {
      let areas = this.areas;
      let selectedArea = event.detail;
      let selectedAreaMain = [];
      for (let i = 0; i < selectedArea.length; i++) {
         selectedAreaMain.push(selectedArea[i].value);
      }
      for (let j = 0; j < areas.length; j++) {
         if (selectedAreaMain.includes(areas[j].value)) {
            areas[j].selected = true;
         }
         else {
            areas[j].selected = false;
         }
      }
      this.areas = areas;
      this.selectedAreaMain = selectedAreaMain;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handlePriceChange(event) {
      let price = this.price;
      let selectedPrice = event.detail;
      let selectedPriceMain = [];
      for (let i = 0; i < selectedPrice.length; i++) {
         selectedPriceMain.push(selectedPrice[i].value);
      }
      for (let j = 0; j < price.length; j++) {
         if (selectedPriceMain.includes(price[j].value)) {
            price[j].selected = true;
         }
         else {
            price[j].selected = false;
         }
      }
      this.price = price;
      this.selectedPriceMain = selectedPriceMain;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }

   handlepropertyTypeChange(event) {
      let propertytypes = this.propertytypes;
      let selectedPropertyTypes = event.detail;
      let selectedPropertyTypeMain = [];
      for (let i = 0; i < selectedPropertyTypes.length; i++) {
         selectedPropertyTypeMain.push(selectedPropertyTypes[i].value);
      }
      for (let j = 0; j < propertytypes.length; j++) {
         if (selectedPropertyTypeMain.includes(propertytypes[j].value)) {
            propertytypes[j].selected = true;
         }
         else {
            propertytypes[j].selected = false;
         }
      }
      this.propertytypes = propertytypes;
      this.selectedPropertyTypeMain = selectedPropertyTypeMain;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
   }
   
   closeFilterModal() {
      const closeModalEvent = new CustomEvent("filtermodalclosure", {
      });
      this.dispatchEvent(closeModalEvent);
   }

   projectFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayProjectFilter = !this.displayProjectFilter;
      this.displayUnitTypeFilter = false;
      this.displayVariantsFilter = false;
      this.displayFloorFilter = false;
      this.displayUnitFilter = false;
      this.displayAreaFilter = false;
      this.displayPriceFilter = false;
   }

   unitTypeFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayUnitTypeFilter = !this.displayUnitTypeFilter;
      this.displayProjectFilter = false;
      this.displayVariantsFilter = false;
      this.displayFloorFilter = false;
      this.displayUnitFilter = false;
      this.displayAreaFilter = false;
      this.displayPriceFilter = false;
   }

   variantsFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayVariantsFilter = !this.displayVariantsFilter;
      this.displayProjectFilter = false;
      this.displayUnitTypeFilter = false;
      this.displayFloorFilter = false;
      this.displayUnitFilter = false;
      this.displayAreaFilter = false;
      this.displayPriceFilter = false;
   }

   floorFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayFloorFilter = !this.displayFloorFilter;
      this.displayProjectFilter = false;
      this.displayUnitTypeFilter = false;
      this.displayVariantsFilter = false;
      this.displayUnitFilter = false;
      this.displayAreaFilter = false;
      this.displayPriceFilter = false;
   }

   unitFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayUnitFilter = !this.displayUnitFilter;
      this.displayProjectFilter = false;
      this.displayUnitTypeFilter = false;
      this.displayVariantsFilter = false;
      this.displayFloorFilter = false;
      this.displayAreaFilter = false;
      this.displayPriceFilter = false;
   }

   areaFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayAreaFilter = !this.displayAreaFilter;
      this.displayProjectFilter = false;
      this.displayUnitTypeFilter = false;
      this.displayVariantsFilter = false;
      this.displayFloorFilter = false;
      this.displayUnitFilter = false;
      this.displayPriceFilter = false;
   }

   priceFilterClicked(event) {
      event.target.style.color = "#1F55DE";
      this.displayPriceFilter = !this.displayPriceFilter;
      this.displayProjectFilter = false;
      this.displayUnitTypeFilter = false;
      this.displayVariantsFilter = false;
      this.displayFloorFilter = false;
      this.displayUnitFilter = false;
      this.displayAreaFilter = false;
   }

   onProjectSelect(event) {
      let subProjects = this.subProjects;
      let subProjectsSelected = event.detail;
      let selectedSubProjects = [];
      for (let i = 0; i < subProjectsSelected.length; i++) {
         selectedSubProjects.push(subProjectsSelected[i].value);
      }
      for (let j = 0; j < subProjects.length; j++) {
         if (selectedSubProjects.includes(subProjects[j].value)) {
            subProjects[j].selected = true;
         }
         else {
            subProjects[j].selected = false;
         }
      }
      this.subProjects = subProjects;
      this.selectedSubProjects = selectedSubProjects;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onUnitTypeSelect(event) {
      let unitTypes = this.unitTypes;
      let unitTypesSelected = event.detail;
      let selectedUnitTypes = [];
      for (let i = 0; i < unitTypesSelected.length; i++) {
         selectedUnitTypes.push(unitTypesSelected[i].value);
      }
      for (let j = 0; j < unitTypes.length; j++) {
         if (selectedUnitTypes.includes(unitTypes[j].value)) {
            unitTypes[j].selected = true;
         }
         else {
            unitTypes[j].selected = false;
         }
      }
      this.unitTypes = unitTypes;
      this.selectedUnitTypes = selectedUnitTypes;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onVariantSelect(event) {
      let variants = this.variants;
      let variantsSelected = event.detail;
      let selectedVariantes = [];
      let selectedVariantesDisplay = [];
      for (let i = 0; i < variantsSelected.length; i++) {
         selectedVariantes.push(variantsSelected[i].value);
         selectedVariantesDisplay.push('Variant: ' + variantsSelected[i].value);
      }
      for (let j = 0; j < variants.length; j++) {
         if (selectedVariantes.includes(variants[j].value)) {
            variants[j].selected = true;
         }
         else {
            variants[j].selected = false;
         }
      }
      this.variants = variants;
      this.selectedVariantes = selectedVariantes;
      this.selectedVariantesDisplay = selectedVariantesDisplay;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onFloorSelect(event) {
      let floors = this.floors;
      let floorsSelected = event.detail;
      let selectedFloors = [];
      let selectedFloorsDisplay = [];
      for (let i = 0; i < floorsSelected.length; i++) {
         selectedFloors.push(floorsSelected[i].value);
         selectedFloorsDisplay.push('Floor: ' + floorsSelected[i].value);
      }
      for (let j = 0; j < floors.length; j++) {
         if (selectedFloors.includes(floors[j].value)) {
            floors[j].selected = true;
         }
         else {
            floors[j].selected = false;
         }
      }
      this.floors = floors;
      this.selectedFloors = selectedFloors;
      this.selectedFloorsDisplay = selectedFloorsDisplay;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onUnitSelect(event) {
      let unitNames = this.unitNames;
      let unitsSelected = event.detail;
      let selectedUnitNames = [];
      for (let i = 0; i < unitsSelected.length; i++) {
         selectedUnitNames.push(unitsSelected[i].value);
      }
      for (let j = 0; j < unitNames.length; j++) {
         if (selectedUnitNames.includes(unitNames[j].value)) {
            unitNames[j].selected = true;
         }
         else {
            unitNames[j].selected = false;
         }
      }
      this.unitNames = unitNames;
      this.selectedUnitNames = selectedUnitNames;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onAreaSelect(event) {
      let areascolumn = this.areascolumn;
      let areaSelected = event.detail;
      let selectedAreas = [];
      for (let i = 0; i < areaSelected.length; i++) {
         selectedAreas.push(areaSelected[i].value);
      }
      for (let j = 0; j < areascolumn.length; j++) {
         if (selectedAreas.includes(areascolumn[j].value)) {
            areascolumn[j].selected = true;
         }
         else {
            areascolumn[j].selected = false;
         }
      }
      this.areascolumn = areascolumn;
      this.selectedAreas = selectedAreas;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   onPriceSelect(event) {
      let pricecolumn = this.pricecolumn;
      let priceSelected = event.detail;
      let selectedPrices = [];
      for (let i = 0; i < priceSelected.length; i++) {
         selectedPrices.push(priceSelected[i].value);
      }
      for (let j = 0; j < pricecolumn.length; j++) {
         if (selectedPrices.includes(pricecolumn[j].value)) {
            pricecolumn[j].selected = true;
         }
         else {
            pricecolumn[j].selected = false;
         }
      }
      this.pricecolumn = pricecolumn;
      this.selectedPrices = selectedPrices;
      this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices, true);
   }

   getSelectedUnits(projectId, config, area, price, propType, subProjects, unitTypes, floors, unitNames, variants, areas, prices, fromColumn) {
      if (fromColumn == undefined) {
         fromColumn = false;
      }
      this.showSpinner = true;
      getUnits({ projectId: projectId, config: config, area: area, price: price, propertyType: propType, subProjects: subProjects, unitTypes: unitTypes, floors: floors, unitNames: unitNames, variants: variants, areas: areas, prices: prices })
      .then(result => {
         let nfObject = new Intl.NumberFormat('en-US');
         for (var i = 0; i < result.length; i++) {
            let pp = result[i].PropStrength__Total_Sales_Consideration__c;
            //console.log('===> pp '+ pp);
            pp = pp.toFixed(2);
            result[i].PropStrength__Total_Sales_Consideration__c = nfObject.format(pp);
            if(result[i].PropStrength__Project_Name__r.Master_Project__r.Name != undefined && 
               result[i].PropStrength__Project_Name__r.Master_Project__r.Name != null) {
               result[i].masterProjectName = result[i].PropStrength__Project_Name__r.Master_Project__r.Name;
            }
            if(result[i].PropStrength__Project_Name__r.Name != undefined && 
               result[i].PropStrength__Project_Name__r.Name != null) {
               result[i].proprtyProjectName = result[i].PropStrength__Project_Name__r.Name;
            }
         }
         this.unitList = result;
         if (result.length > 0)
            this.noUnitsFound = false;
         else
            this.noUnitsFound = true;
         let unitTypes = [];
         let unitTypesTmp = [];
         let floors = [];
         let floorsTmp = [];
         let variants = [];
         let variantsTmp = [];
         let unitNames = [];
         let unitNamesTmp = [];
         let subprojects = [];
         let subprojectsTmp = [];
         for (let i = 0; i < result.length; i++) {
            if (result[i].PropStrength__Unit_Type__c != undefined && result[i].PropStrength__Unit_Type__c != null && result[i].PropStrength__Unit_Type__c != '' && !unitTypesTmp.includes(result[i].PropStrength__Unit_Type__c)) {
               unitTypes.push({ value: result[i].PropStrength__Unit_Type__c, key: result[i].PropStrength__Unit_Type__c });
               unitTypesTmp.push(result[i].PropStrength__Unit_Type__c);
            }
            if(result[i].PropStrength__Floor_Number__c != undefined && result[i].PropStrength__Floor_Number__c != null && !floorsTmp.includes((result[i].PropStrength__Floor_Number__c).toString())) {
               floors.push({ value: ((result[i].PropStrength__Floor_Number__c).toString()), key:((result[i].PropStrength__Floor_Number__c).toString()) });
               floorsTmp.push((result[i].PropStrength__Floor_Number__c).toString());
            }
            if (result[i].Variant__c != undefined && result[i].Variant__c != null && result[i].Variant__c != '' && !variantsTmp.includes(result[i].Variant__c)) {
               variants.push({ value: result[i].Variant__c, key: result[i].Variant__c });
               variantsTmp.push(result[i].Variant__c);
            }
            if (result[i].Name != undefined && result[i].Name != null && result[i].Name != '' && !unitNamesTmp.includes(result[i].Name)) {
               unitNames.push({ value: result[i].Name, key: result[i].Name });
               unitNamesTmp.push(result[i].Name);
            }
            if (result[i].PropStrength__Project_Name__r.Name != undefined && result[i].PropStrength__Project_Name__r.Name != null && result[i].PropStrength__Project_Name__r.Name != '' && !subprojectsTmp.includes(result[i].PropStrength__Project_Name__r.Name)) {
               subprojects.push({ value: result[i].PropStrength__Project_Name__r.Name, key: result[i].PropStrength__Project_Name__r.Name });
               subprojectsTmp.push(result[i].PropStrength__Project_Name__r.Name);
            }
         }
         floors.sort();
         //if (!fromColumn) {
            this.unitTypes = unitTypes;
            this.floors = floors;
            this.variants = variants;
            this.unitNames = unitNames;
            this.subProjects = subprojects;
         //}
         this.projectLoaded = true;
         this.showSpinner = false;
      })
      .catch(error => {
         this.showSpinner = false;
         console.log(error);
      });
   }

   getProjects() {
      getAllProjects()
      .then(result => {
         this.allProjects = result;
         let projs = [];
         for (let i = 0; i < result.length; i++) {
            projs.push({ value: result[i].Name, key: result[i].Id });
            if (this.selectedProjectValue == result[i].Id) {
               this.selectedProjectName = result[i].Name;
               let selectedProjectMain = this.selectedProjectMain;
               if (this.selectedProjectName != undefined && this.selectedProjectName != null && !selectedProjectMain.includes(this.selectedProjectName))
                  selectedProjectMain.push(this.selectedProjectName);
               this.selectedProjectMain = selectedProjectMain;

               let selectedBedMain = this.selectedBedMain;
               if (this.selectedBedValue != undefined && this.selectedBedValue != '' && !selectedBedMain.includes(this.selectedBedValue))
                  selectedBedMain.push(this.selectedBedValue);
               this.selectedBedMain = selectedBedMain;

               let selectedAreaMain = this.selectedAreaMain;
               if (this.selectedAreaValue != undefined && this.selectedAreaValue != null && this.selectedAreaValue != '' && !selectedAreaMain.includes(this.selectedAreaValue))
                  selectedAreaMain.push(this.selectedAreaValue);
               this.selectedAreaMain = selectedAreaMain;

               let selectedPriceMain = this.selectedPriceMain;
               if (this.selectedPriceValue != undefined && this.selectedPriceValue != null && this.selectedPriceValue != '' && !selectedPriceMain.includes(this.selectedPriceValue))
                  selectedPriceMain.push(this.selectedPriceValue);
               this.selectedPriceMain = selectedPriceMain;

               let selectedPropertyTypeMain = this.selectedPropertyTypeMain;
               if (this.selectedPropertyTypeValue != undefined && this.selectedPropertyTypeValue != null && this.selectedPropertyTypeValue != '' && !selectedPropertyTypeMain.includes(this.selectedPropertyTypeValue))
                  selectedPropertyTypeMain.push(this.selectedPropertyTypeValue);
               this.selectedPropertyTypeMain = selectedPropertyTypeMain;
            }
         }
         this.getSelectedUnits(this.selectedProjectMain, this.selectedBedMain, this.selectedAreaMain, this.selectedPriceMain, this.selectedPropertyTypeMain, this.selectedSubProjects, this.selectedUnitTypes, this.selectedFloors, this.selectedUnitNames, this.selectedVariantes, this.selectedAreas, this.selectedPrices);
         this.projects = projs;
         let projects = this.projects;
         for (let j = 0; j < projects.length; j++) {
            if (projects[j].value == this.selectedProjectName) {
               projects[j].selected = true;
            }
            else {
               projects[j].selected = false;
            }
         }
         this.projects = projects;
         this.projectLoaded = true;
      })
      .catch(error => {
         console.log(error);
      });
   }

   connectedCallback() {
      loadStyle(this, portalOverrideStyle);
      let selectedBedMain = this.selectedBedMain;
      if (this.selectedBedValue != '' && !selectedBedMain.includes(this.selectedBedValue))
         selectedBedMain.push(this.selectedBedValue);
      this.selectedBedMain = selectedBedMain;
      let beds = this.beds;
      for (let j = 0; j < beds.length; j++) {
         if (beds[j].value == this.selectedBedValue) {
            beds[j].selected = true;
         }
         else {
            beds[j].selected = false;
         }
      }
      this.beds = beds;
      let selectedAreaMain = this.selectedAreaMain;
      if (this.selectedAreaValue != '' && !selectedAreaMain.includes(this.selectedAreaValue))
         selectedAreaMain.push(this.selectedAreaValue);
      this.selectedAreaMain = selectedAreaMain;

      let areas = this.areas;
      for (let j = 0; j < areas.length; j++) {
         if (areas[j].value == this.selectedAreaValue) {
            areas[j].selected = true;
         }
         else {
            areas[j].selected = false;
         }
      }
      this.areas = areas;
      let selectedPriceMain = this.selectedPriceMain;
      if (this.selectedPriceValue != '' && !selectedPriceMain.includes(this.selectedPriceValue))
         selectedPriceMain.push(this.selectedPriceValue);
      this.selectedPriceMain = selectedPriceMain;
      let price = this.price;
      for (let j = 0; j < price.length; j++) {
         if (price[j].value == this.selectedPriceValue) {
            price[j].selected = true;
         }
         else {
            price[j].selected = false;
         }
      }
      this.price = price;
      let selectedPropertyTypeMain = this.selectedPropertyTypeMain;
      if (this.selectedPropertyTypeValue != '' && !selectedPropertyTypeMain.includes(this.selectedPropertyTypeValue))
         selectedPropertyTypeMain.push(this.selectedPropertyTypeValue);
      this.selectedPropertyTypeMain = selectedPropertyTypeMain;
      let propertytypes = this.propertytypes;
      for (let j = 0; j < propertytypes.length; j++) {
         if (propertytypes[j].value == this.selectedPropertyTypeValue) {
            propertytypes[j].selected = true;
         }
         else {
            propertytypes[j].selected = false;
         }
      }
      this.propertytypes = propertytypes;
      this.getProjects();
   }

   downloadQuotationConfirmation(event) {
      this.showDownloadQuotationConfirmation = true;
      this.selectedUnitIdForDownloadQuotation = event.target.name;
   }

   downloadQuotation(event) {
      if(this.customerName == '' || this.customerName == undefined || this.customerEmail == '' || this.customerEmail == undefined) {
         this.showToast('Error', 'Customer Name & Email needs to be entered to download the Quote', 'error');
         return;
      }
      this.showSpinner = true;
      let unitId = this.selectedUnitIdForDownloadQuotation;
      createQuotation({ unitId: unitId, customerName: this.customerName, customerEmail: this.customerEmail })
      .then(result => {
         if(result != '') {
            let resultType = result.split('++')[0];
            if(resultType == 'Success') {
               let resultUrl = result.split('++')[1];
               console.log('===> resultUrl ' + resultUrl);
               this[NavigationMixin.GenerateUrl]({
                  type: 'standard__webPage',
                  attributes: {
                     url: '/newBrokerPortal/' + resultUrl
                  }
               }).then(generatedUrl => {
                  window.open(generatedUrl, '_blank');
               });
            }
            else if(resultType == 'Error') {
               let resultMsg = result.split('++')[1];
               this.showToast('Error', resultMsg, 'error');

            }
         } else if(result == '') {
            this.showToast('Error', 'There is no quotation in this property.', 'error');
         }
         this.showSpinner = false;
         this.showDownloadQuotationConfirmation = false;
      })
      .catch(error => {
         this.showSpinner = false;
         this.showDownloadQuotationConfirmation = false;
         console.log(error);
         this.showToast('Error', error, 'error');
      });
   }

   showToast(title, message, variant) {
      const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
      });
      this.dispatchEvent(event);
   }
}