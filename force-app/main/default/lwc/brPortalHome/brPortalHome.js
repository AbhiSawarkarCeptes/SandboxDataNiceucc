import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GALLERY_IMAGES from "@salesforce/resourceUrl/gallery_images";
import new_launch_icon from "@salesforce/resourceUrl/new_launch_icon";
import announcement_logo from "@salesforce/resourceUrl/announcement_logo";
import new_launches_img from "@salesforce/resourceUrl/new_launches_img";
import unit_icon from "@salesforce/resourceUrl/unit_icon";
import location_icon from "@salesforce/resourceUrl/location_icon";
import gallery_icon from "@salesforce/resourceUrl/gallery_icon";
import gallery_video from "@salesforce/resourceUrl/gallery_video";
import birthday_bg from "@salesforce/resourceUrl/birthday_background";
import getHomePageContents from '@salesforce/apex/BRPortalHomeController.getHomePageContents';
import getGallery from '@salesforce/apex/BRPortalHomeController.getGallery';
import { loadStyle } from 'lightning/platformResourceLoader';
import portalHomePageStyle from '@salesforce/resourceUrl/portalHomePageStyle';
import renewAgreement from '@salesforce/apex/BRPortalBrokerEventsController.renewAgreement';
import getProfileDetails from '@salesforce/apex/BRPortalBrokerEventsController.getProfileDetails';
import { refreshApex } from '@salesforce/apex';

export default class BrPortalHome extends NavigationMixin(LightningElement) {
    isRenewalModal = false;
    wiredData;
    content;
    contentLoaded = false;
    gallery_img_1;
    gallery_img_2;
    gallery_img_3;
    gallery_img_4;
    gallery_img_5;
    new_launches_logo;
    announcement_icon;
    new_launches_image;
    unit_image;
    location_image;
    gallery_image;
    gallery_video_link;
    birthday_bg_img;
    imageOddArray = [];
    imageEvenArray = [];
    latestProjects = [];
    imageGalleryLength;
    displayBirthdayCard = false;

    selectedEventValue;


    displayImages = true;
    displayVideos = true;
    videoGalleryLength;
    sobhaevents = [];
    videoEvenArray = [];
    videoOddArray = [];

    displayFullImage = false;
    selectedImageURL;

    isRenewal = true;
    showSpinner = false;

    closeImageModal() {
        this.displayFullImage = false;
        this.selectedImageURL = '';
    }

    openFullImage(event) {
        this.selectedImageURL = event.target.src;
        this.displayFullImage = true;
    }

    handleEventsChange(event) {
        // console.log('~~~~'+JSON.stringify(event.target.value));
        //this.selectedEventValue = event.detail.value;
        this.selectedEventValue = event.target.value;
        getGallery({ eventName: this.selectedEventValue })
        .then(result => {
            let oddImageArray = [];
            let evenImageArray = [];
            let galleryImageNames = result.imageGallery;
            this.imageGalleryLength = galleryImageNames.length;
            console.log('===> galleryImageNames ' + this.imageGalleryLength);
            for (let i = 0; i < galleryImageNames.length; i++) {
                if (i % 2 == 0)
                    evenImageArray.push(galleryImageNames[i]);
                else
                    oddImageArray.push(galleryImageNames[i]);
            }
            this.imageEvenArray = evenImageArray;
            this.imageOddArray = oddImageArray;

            let oddVideoArray = [];
            let evenVideoArray = [];
            let galleryVideoNames = result.videoGallery;
            this.videoGalleryLength = galleryVideoNames.length;
            for (let i = 0; i < galleryVideoNames.length; i++) {
                if (i % 2 == 0)
                    evenVideoArray.push(galleryVideoNames[i]);
                else
                    oddVideoArray.push(galleryVideoNames[i]);
            }
            this.videoEvenArray = evenVideoArray;
            this.videoOddArray = oddVideoArray;

        })
        .catch(error => {
            console.log('VVK error:', error);
        });
    }

    @wire(getProfileDetails)
    getProfileInfo(resultt) {
        this.wiredData = resultt;
        let { error, data } = resultt;
        console.log('===> data data ' + data);
        if (data) {
            let pro_Info = data;
            //console.log('===> R1R ' + pro_Info.RenewalModalPopup);
            if(pro_Info.RenewalModalPopup) {
                this.isRenewalModal = true;
            } else {
                this.isRenewalModal = false;
            }
            //console.log('===> R2R ' + this.isRenewalModal);
        } else if (error) {
            console.log("Error is ", error);
        }
    }

    connectedCallback() {
        loadStyle(this, portalHomePageStyle);
        this.loadHomePageContents();
        this.gallery_img_1 = GALLERY_IMAGES + '/' + 'gallery-img-1.png';    
        this.gallery_img_2 = GALLERY_IMAGES + '/' + 'gallery-img-2.png';
        this.gallery_img_3 = GALLERY_IMAGES + '/' + 'gallery-img-3.png';
        this.gallery_img_4 = GALLERY_IMAGES + '/' + 'gallery-img-4.png';
        this.gallery_img_5 = GALLERY_IMAGES + '/' + 'gallery-img-5.png';
        this.new_launches_logo = new_launch_icon;
        this.announcement_icon = announcement_logo;
        this.new_launches_image = new_launches_img;
        this.unit_image = unit_icon;
        this.location_image = location_icon;
        this.gallery_image = gallery_icon;
        this.gallery_video_link = gallery_video;
    }

    get backgroundImg() {
        let bg = 'background: url(' + birthday_bg + ') no-repeat';
        return bg;
    }

    loadHomePageContents() {
        getHomePageContents()
        .then(result => {
            this.content = result;
            let customerOffer = result.customerOffer;
            for(let i=0;i<customerOffer.length;i++) {
                let des = customerOffer[i].Offer_Description__c;
                des = des.replaceAll('<[/a-zAZ0-9]*>',' ');
                des = des.replaceAll('&nbsp;',' ');
                customerOffer[i].Offer_Description__c = des;
            }
            let content = this.content;
            content.customerOffer = customerOffer;
            this.content = content;
            this.content.announcements.forEach((item, index) => {
                this.content.announcements[index] = {
                    ...item,
                    isClipped: true
                }
            });
            this.latestProjects = result.latestProjects[0];
            let oddImageArray = [];
            let evenImageArray = [];
            let galleryImageNames = result.imageGallery;
            this.imageGalleryLength = galleryImageNames.length;
            console.log('===> img ' + this.imageGalleryLength);
            for (let i = 0; i < galleryImageNames.length; i++) {
                if (i % 2 == 0)
                    evenImageArray.push(galleryImageNames[i]);
                else
                    oddImageArray.push(galleryImageNames[i]);
            }
            this.imageEvenArray = evenImageArray;
            this.imageOddArray = oddImageArray;

            let oddVideoArray = [];
            let evenVideoArray = [];
            let galleryVideoNames = result.videoGallery;
            this.videoGalleryLength = galleryVideoNames.length;
            for (let i = 0; i < galleryVideoNames.length; i++) {
                if (i % 2 == 0)
                    evenVideoArray.push(galleryVideoNames[i]);
                else
                    oddVideoArray.push(galleryVideoNames[i]);
            }
            this.videoEvenArray = evenVideoArray;
            this.videoOddArray = oddVideoArray;

            let eventArr = [];
            let events = result.eventsList;
            for (let i = 0; i < events.length; i++) {
                eventArr.push({ label: events[i], value: events[i] });
                if (i == 0) {
                    this.selectedEventValue = events[i];
                }
            }
            this.sobhaevents = eventArr;

            this.contentLoaded = true;
            
        })
        .catch(error => {
            console.log('VVK error:', error);
        });
    }

    getProfileInfo22() {
        getProfileDetails22()
        .then(result => {
            this.wiredData = result;
            let { error, data } = result;
            console.log('===> R3R ');
            if (data) {
                let pro_Info = data;
                console.log('===> R4R ' + pro_Info.RenewalModalPopup);
                if(pro_Info.RenewalModalPopup) {
                    this.isRenewalModal = true;
                } else {
                    this.isRenewalModal = false;
                }
                console.log('===> R ' + this.isRenewalModal);
            } else if (error) {
                console.log("Error is ", error);
            }
        })
        .catch(error => {
            console.log('error: ', error);
        });
    }

    renewalButtonHandler() {
        this.showSpinner = true;
        renewAgreement()
        .then(result => {
            if (result) {
                // Record created successfully
                console.log('Renewal record created: ' + result);
                refreshApex(this.wiredData);
                this.showToast('Success', 'Renewal record created successfully.', 'success');

            } else {
                // Handle error
                console.error('Failed to create renewal record.');
                this.showToast('Error', 'Failed to create renewal record.', 'error');
            }
            this.showSpinner = false;
        })
        .catch(error => {
            // Handle error
            console.error('Error creating renewal record: ' + error.message);
            this.showToast('Error', 'Error creating renewal record.', 'error');
            this.showSpinner = false;
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

    navigateTab(event) {
        const currentTab = event.currentTarget.dataset.tab;
        let clickedElement = event.target;
        let listItems = this.template.querySelectorAll('.tab-area li');
        listItems.forEach(item => {
            item.classList.remove('active');
        });
        clickedElement.classList.add('active');
        let tabContent = this.template.querySelectorAll('.tab-content');
        tabContent.forEach(item => {
            item.classList.remove('active');
        });
        this.template.querySelector('.tab-content[data-id="' + currentTab + '"]').classList.add('active');
    }

    handleLongText(event) {
        try {
            const getID = event.currentTarget.dataset.id;
            const getElement = this.template.querySelector(`.announcement-descrp[data-id="${getID}"]`);
            getElement.style = "display:block; height:auto;";
            event.target.style.display = "none";
            console.log("getdata", getElement, getID, event.currentTarget);
        } catch (error) {
            console.log("error--handleLongText", error.message);
        }
    }

    handleRenewal(event) {
        const getFlag = event.detail.flag;
        this.isRenewal = getFlag;
    }
}