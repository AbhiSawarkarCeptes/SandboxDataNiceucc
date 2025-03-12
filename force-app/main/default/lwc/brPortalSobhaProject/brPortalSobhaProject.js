import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import dropdownarrow from '@salesforce/resourceUrl/dropdownarrow';
//import sobhahartland11 from '@salesforce/resourceUrl/sobhahartland11';
import sobhaprojectslogo from '@salesforce/resourceUrl/sobhaprojectslogo';
import sobhahortalnd11banner01 from '@salesforce/resourceUrl/sobhahortalnd11banner01';
import sobhahortalnd11banner02 from '@salesforce/resourceUrl/sobhahortalnd11banner02';
import sobhahortalnd11banner03 from '@salesforce/resourceUrl/sobhahortalnd11banner03';
import footerannouncementicon from '@salesforce/resourceUrl/footerannouncementicon';
import footernotificationicon from '@salesforce/resourceUrl/footernotificationicon';
import footeruparrow from '@salesforce/resourceUrl/footeruparrow';
//import profileimg from '@salesforce/resourceUrl/profileimg';
import getRelatedFiles from '@salesforce/apex/BRPortalSobhaProjectsController.getRelatedFiles';
import getAllProjects from '@salesforce/apex/BRPortalSobhaProjectsController.getAllProjects';
import getSubProjectDetails from '@salesforce/apex/BRPortalSobhaProjectsController.getSubProjectDetails';
import isEligibleForAction from '@salesforce/apex/BRPortalBrokerEventsController.isEligibleForAction';
import SOBHA_HARTLAND from '@salesforce/resourceUrl/Logo';
import SINIYA_ISLAND from '@salesforce/resourceUrl/Siniya_Island_Company_Logo';
import portalOverrideStyle from '@salesforce/resourceUrl/portalOverrideStyle';
import sobhaProjectsAssets from "@salesforce/resourceUrl/sobhaProjectsAssets";

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class BrPortalSobhaProject extends NavigationMixin(LightningElement) {

   @track dropdownarrow = dropdownarrow;
   //@track sobhahartland11 = sobhahartland11;
   @track sobhaprojectslogo = sobhaprojectslogo;
   @track sobhahortalnd11banner01 = sobhahortalnd11banner01;
   @track sobhahortalnd11banner02 = sobhahortalnd11banner02;
   @track sobhahortalnd11banner03 = sobhahortalnd11banner03;
   @track footerannouncementicon = footerannouncementicon;
   @track footernotificationicon = footernotificationicon;
   @track footeruparrow = footeruparrow;
   //@track profileimg = profileimg;
   @track showImageModal = false;
   @track getImageData;
   @track selectedImage;
   @track imageIndex;

   showProject = true;
   showSubProject = false;

   scrollBarWidths = 200;
   typologyImg = portalAssests + '/assets/images/typology.svg';
   cycleTrackImg = portalAssests + '/assets/images/cycle-track.svg';
   skyGardenImg = portalAssests + '/assets/images/sky-garden.svg';
   tennisCourtImg = portalAssests + '/assets/images/tennis-court.svg';
   swimmingPoolImg = portalAssests + '/assets/images/swimming-pool.svg';
   SubProjectImage1 = portalAssests + '/assets/images/SubProjectImage1.png';
   startingPriceImg = portalAssests + '/assets/images/startingPrice.png';
   locationImg = portalAssests + '/assets/images/locationImg.png';
   filesList = [];
   brouchername = ''; // define broucher file name here
   collateralname = ''; // define collateral file name here
   projectid = ''; // fetch the project id dynamically
   @api selectedProjectValue;
   @api selectedSubProjectValue;
   @api selectedSubProjectName;
   @api selectedSubProject3DTourLink;
   @api selectedBedValue = '';
   @api selectedAreaValue = '';
   @api selectedPriceValue = '';
   @api selectedPropertyTypeValue = '';
   @api allProjects = [];
   projects = [];
   @track projectsFilter = [];
   subProjects = [];
   unitTypes = [];
   floors = [];
   variants = [];
   subProjectDetails;

   @track display3DView = false;
   @track subProjectImageLinks = [];
   @track mainDivStyle = ''

   closeVideoModal() {
      this.display3DView = false;
   }

   View3DTour() {
      this.display3DView = true;
   }

   connectedCallback() {
      loadStyle(this, portalOverrideStyle);
      isEligibleForAction()
      .then(result => {
         if(result == false) {
            this.mainDivStyle = 'main-panel no-click';
         } else {
            this.mainDivStyle = 'main-panel';
         }
      })
      .catch(error => {
         console.log(error);
      });
      getAllProjects()
         .then(result => {
            this.allProjects = result;
            let allProj = [];
            let allProjFilter = [];
            allProjFilter.push({ "label": "  --None--  ", "value": "None" });
            for (let i = 0; i < result.length; i++) {
               if (i == 0) {
                  allProj.push({ "Id": result[i].Id, "Name": result[i].Name, "className": "nav-item nav-link" });
               } else {
                  allProj.push({ "Id": result[i].Id, "Name": result[i].Name, "className": "nav-item nav-link" });
               }
               allProjFilter.push({ "label": result[i].Name, "value": result[i].Id });
               /*if(result[i].Logo_URL__c != null) {
                  allProj[i].logoURL = result[i].Logo_URL__c;
               } else {
                  allProj[i].logoURL = sobhaprojectslogo;
               }*/
               if (result[i].Name == 'The S') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/TheS.svg";
               } else if (result[i].Name == 'Sobha Hartland') {
                  allProj[i].logoURL = SOBHA_HARTLAND;
               } else if (result[i].Name == 'Siniya Island') {
                  allProj[i].logoURL = SINIYA_ISLAND;
               } else if (result[i].Name == 'Sobha One') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/SobhaOne.svg";
               } else if (result[i].Name == 'Sobha SeaHaven') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/seahaven.svg";
               } else if (result[i].Name == 'Sobha Orbis') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/Orbis.svg";
               } else if (result[i].Name == 'Sobha Reserve') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/Reserve.svg";
               } else if (result[i].Name == 'Sobha Hartland - II') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/Hartland2.svg";
               } else if (result[i].Name == 'Verde By Sobha') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/verde.png";
               } else if (result[i].Name == 'Sobha Hartland II Villas') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/HartlandVillas.png";
               } else if (result[i].Name == 'Hartland Extension') {
                  allProj[i].logoURL = sobhaProjectsAssets + "/sobhaProjectsAssets/HartlandExt.png";
               } else {
                  allProj[i].logoURL = sobhaprojectslogo;
               }

               /*if(result[i].Logo_URL__c != null) {
                  allProj[i].logoURL = result[i].Logo_URL__c;
               } else {
                  allProj[i].logoURL = sobhaprojectslogo;
               }*/
               //allProj[i].logoURL = sobhaprojectslogo;
            }
            this.projects = allProj;
            this.projectsFilter = allProjFilter;
            console.log(this.projects, this.projectsFilter, "projectfilter");
         })
         .catch(error => {
            console.log(error);
         });
   }

   handleFilterModalClose(event) {
      this.isFilterModalOpen = false;
   }

   scrollLeft() {
      const track = this.template.querySelector('.list');
      let leftPos = parseInt(track.style.left) || 0;
      const scrollAmount = this.template.querySelector('.wrapper-nav').offsetWidth; // Adjust this as needed

      leftPos += scrollAmount;
      if (leftPos > 0) {
         leftPos = 0; // Reset to start if reached the beginning
      }

      track.style.left = leftPos + 'px';

      // Disable the left scroller if reached the beginning
      const leftScroller = this.template.querySelector('.scroller-left');
      leftScroller.disabled = leftPos === 0;
   }

   scrollRight() {
      const track = this.template.querySelector('.list');
      let leftPos = parseInt(track.style.left) || 0;
      const wrapperWidth = this.template.querySelector('.wrapper-nav').offsetWidth;
      const listWidth = this.getWidthOfList();
      const scrollAmount = wrapperWidth; // Adjust this as needed

      leftPos -= scrollAmount;
      const widthOfHidden = this.getWidthOfHidden();
      if (!((-leftPos) <= widthOfHidden)) {
         leftPos = -(listWidth - wrapperWidth); // Reset to end if reached the end
      }

      track.style.left = leftPos + 'px';

      console.log("wrapperwidth", wrapperWidth, `${listWidth} - ${Math.abs(leftPos)} <= ${widthOfHidden}`, listWidth - Math.abs(leftPos) <= widthOfHidden, "----------->", ` (${-leftPos}) <= ${widthOfHidden}`, (-leftPos) <= widthOfHidden);

      // Disable the right scroller if reached the end
      const rightScroller = this.template.querySelector('.scroller-right');
      rightScroller.disabled = (-leftPos) <= widthOfHidden;
   }


   getWidthOfHidden() {
      try {
         const wrapperNavWidth = this.template.querySelector('.wrapper-nav').offsetWidth;
         const navItems = this.template.querySelectorAll('.nav-item');
         let navItemsWidth = 0;
         navItems.forEach(item => {
            navItemsWidth += item.offsetWidth;
         });
         console.log(navItemsWidth, wrapperNavWidth, "wrapperNavWidth");
         return navItemsWidth - wrapperNavWidth;
      } catch (error) {
         console.log("error--getWidthOfHidden", error.message);
      }
   }

   getWidthOfList() {
      let itemsWidth = 0;
      this.template.querySelectorAll('.list .nav-item').forEach(obj => {
         let itemWidth = obj.offsetWidth;
         itemsWidth += itemWidth;
      });
      return itemsWidth;
   }

   getLeftPosi() {
      const wrapperNavWidth = this.template.querySelector('.wrapper-nav').offsetWidth;
      const ww = 0 - wrapperNavWidth;
      const leftPos = parseInt(this.template.querySelector('.list').style.left) || 0;
      return ww > leftPos ? ww : leftPos;
   }


   get beds() {
      return [
         { label: 'Studio', value: 'Studio' },
         { label: '1 BR', value: '1 BR' },
         { label: '1.5 BR', value: '1.5 BR' },
         { label: '2 BR', value: '2 BR' },
         { label: '2.5 BR', value: '2.5 BR' },
         { label: '3 BR', value: '3 BR' },
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
         { label: '0 – 500 Sq. Ft', value: '0 – 500 Sq. Ft' },
         { label: '500 – 1000 Sq. Ft', value: '500 – 1000 Sq. Ft' },
         { label: '1000 – 1500 Sq. Ft', value: '1000 – 1500 Sq. Ft' },
         { label: '1500 – 2000 Sq. Ft', value: '1500 – 2000 Sq. Ft' },
         { label: '2000 – 2500 Sq. Ft', value: '2000 – 2500 Sq. Ft' },
         { label: '2500 – 3000 Sq. Ft', value: '2500 – 3000 Sq. Ft' },
         { label: '3000 – 4000 Sq. Ft', value: '3000 – 4000 Sq. Ft' },
         { label: '4000 – 6000 Sq. Ft', value: '4000 – 6000 Sq. Ft' },
         { label: '6000+ Sq. Ft', value: 'Above 6000 Sq. Ft' },
      ];

   }

   get price() {
      return [
         { label: '0 – AED 1 Million', value: 'AED 0 Million – AED 1 Million' },
         { label: 'AED 1 Million – AED 2 Million', value: 'AED 1 Million – AED 2 Million' },
         { label: 'AED 2 Million – AED 3 Million', value: 'AED 2 Million – AED 3 Million' },
         { label: 'AED 3 Million – AED 4 Million', value: 'AED 3 Million – AED 4 Million' },
         { label: 'AED 4 Million – AED 5 Million', value: 'AED 4 Million – AED 5 Million' },
         { label: 'AED 5 Million – AED 6 Million', value: 'AED 5 Million – AED 6 Million' },
         { label: 'AED 6 Million – AED 8 Million', value: 'AED 6 Million – AED 8 Million' },
         { label: 'AED 8 Million – AED 10 Million', value: 'AED 8 Million – AED 10 Million' },
         { label: '10+ Million AED', value: 'Above 10 AED' },
      ];
   }

   get propertytypes() {
      return [
         { label: 'Apartment', value: 'Apartment' },
         { label: 'Villas', value: 'Villas' },
			{ label: 'Others', value: 'Others' }
      ];
   }
   
   handleProjectChange(event) {
      this.selectedProjectValue = event.detail.value;
   }

   handleBedChange(event) {
      this.selectedBedValue = event.detail.value;
   }

   handleAreaChange(event) {
      this.selectedAreaValue = event.detail.value;
   }

   handlePriceChange(event) {
      this.selectedPriceValue = event.detail.value;
   }

   handlepropertyTypeChange(event) {
      this.selectedPropertyTypeValue = event.detail.value;
   }

   downloadbrochure() {
      getRelatedFiles({ filename: this.selectedSubProjectName + '-Brochure', projectid: this.selectedSubProjectValue }).then(result => {
         if (result != undefined && result != null && result != '') {
            //let filedownloadurl = window.location.origin;
            //filedownloadurl=filedownloadurl+'/sfc/servlet.shepherd/document/download';
            //filedownloadurl+='/'+result;
            this[NavigationMixin.Navigate]({
               type: 'standard__webPage',
               attributes: {
                  url: result
               }
            }, false);
         } else {
            this.dispatchEvent(
					new ShowToastEvent({
						title: 'Brochure is not available.',
						message: 'Brochure is not available.',
						variant: 'error',
					})
				);
         }
      })
      .catch(
         error => {
            console.log(error);
            this.dispatchEvent(
               new ShowToastEvent({
                     title: 'Error: ',
                     message: error.message,
                     variant: 'error',
               })
            );
         }
      );
   }

   MarketingCollaterals() {
      getRelatedFiles({ filename: this.selectedSubProjectName + '-Collateral', projectid: this.selectedSubProjectValue }).then(result => {
         if (result != undefined && result != null && result != '') {
            this[NavigationMixin.Navigate]({
               type: 'standard__webPage',
               attributes: {
                  url: result
               }
            }, false);
         } else {
            this.dispatchEvent(
					new ShowToastEvent({
						title: 'Collateral is not available.',
						message: 'Collateral is not available.',
						variant: 'error',
					})
				);
         }
      })
      .catch(
         error => {
            console.log(error);
            this.dispatchEvent(
               new ShowToastEvent({
                     title: 'Error: ',
                     message: error.message,
                     variant: 'error',
               })
            );
         }
      );
   }

   openFilterModal() {
      this.isFilterModalOpen = true;
   }

   onProjectTabClick(event) {
      this.subProjects = [];
      this.showSubProject = false;
      let projectId = event.target.id;
      projectId = projectId.split('-')[0];
      this.selectedProjectValue = projectId;
      this.projectid = projectId;
      let allProjects = this.allProjects;
      for (let i = 0; i < allProjects.length; i++) {
         if (allProjects[i].Id == projectId) {
            let subProjects = allProjects[i].Projects__r;
            let tempSubProjs = [];
            for (let i = 0; i < subProjects.length; i++) {
               if (i == 0) {
                  tempSubProjs.push({ "Id": subProjects[i].Id, "Name": subProjects[i].Name, "className": "subProjectItem active" });
               } else {
                  tempSubProjs.push({ "Id": subProjects[i].Id, "Name": subProjects[i].Name, "className": "subProjectItem" });
               }
            }
            this.subProjects = tempSubProjs;
            break;
         }
      }
      let subProjs = this.subProjects;
      if (subProjs.length > 0) {
         this.selectedSubProjectValue = subProjs[0].Id;
         this.selectedSubProjectName = subProjs[0].Name;
         this.selectedSubProject3DTourLink = subProjs[0].X3D_Tour__c;
         this.getSubProjDetails(this.selectedSubProjectValue);
      }
   }

   onProjectClick(event) {
      this.onProjectTabClick(event);
      this.template.querySelectorAll('.nav-item').forEach(obj => {
         obj.classList.remove('active');
      });
      event.currentTarget.classList.add('active');
      this.showProject = false;
   }

   getSubProjDetails(subProjectId) {
      this.showSubProject = false;
      getSubProjectDetails({ subProjectId: subProjectId })
      .then(result => {
         try {
            //this.subProjectDetails = result;
            let subProjectDetails = result;
            let amenitiesList = subProjectDetails.amenities;
            for (let i = 0; i < amenitiesList.length; i++) {
               let amenityName = amenitiesList[i].Amenity_Name__c;
               amenityName = amenityName.toLowerCase();
               console.log('===> amenityName ' + amenityName);
               if (amenityName.includes('garden')) {
                  amenitiesList[i].imgURL = this.skyGardenImg;
               }
               else if (amenityName.includes('pool')) {
                  amenitiesList[i].imgURL = this.swimmingPoolImg;
               }
               else if (amenityName.includes('cycle')) {
                  amenitiesList[i].imgURL = this.cycleTrackImg;
               }
               else if (amenityName.includes('tennis')) {
                  amenitiesList[i].imgURL = this.tennisCourtImg;
               }
               else {
                  amenitiesList[i].imgURL = this.skyGardenImg;
               }
            }
            subProjectDetails.amenities = amenitiesList;
            this.subProjectDetails = subProjectDetails;
            this.selectedSubProjectName = subProjectDetails.name;
            this.selectedSubProject3DTourLink = subProjectDetails.threeDTour;
            this.getImageData = JSON.parse(JSON.stringify(subProjectDetails.imageURLs));
            let getModifiedImages = {};
            this.getImageData.forEach((item, index) => {
               getModifiedImages[`image${index + 1}`] = item;
            })
            this.subProjectImageLinks = getModifiedImages;

            /*let imag_List = [];
            imag_List = result.imageURLs;
            let imageLength = 0;
            let getModifiedImages = [];
            if(imag_List != undefined && imag_List != null) {
               imageLength = imag_List.length;
               if(imageLength > 4) {
                  imageLength = 4;
               }
               for(var i = 0; i < imageLength; i++) {
                  getModifiedImages.push(imag_List[i]);
               }
            }
            this.subProjectImageLinks = getModifiedImages;*/
         } catch (error) {
            console.log("error image", error.message);
         }
         this.showSubProject = true;
      })
      .catch(error => {
         console.log(error);
      });
   }

   onSubProjectClick(event) {
      let subprojectId = event.target.id;
      subprojectId = subprojectId.split('-')[0];
      this.selectedSubProjectValue = subprojectId;
      this.getSubProjDetails(this.selectedSubProjectValue);
      this.template.querySelectorAll('.subProjectItem').forEach(obj => {
         obj.classList.remove('active');
      });
      event.currentTarget.classList.add('active');
   }

   handleImages(event) {
      const getAction = event.currentTarget.dataset.action || event.detail.action;
      console.log('===> getAction ' + getAction);
      const getIndex = event.currentTarget.dataset.index || event.detail.index;
      console.log('===> getIndex ' + getIndex);
      if (getAction == "open" || getAction == "close") {
         this.showImageModal = !this.showImageModal;
      }
      this.imageIndex = getIndex;
   }
}