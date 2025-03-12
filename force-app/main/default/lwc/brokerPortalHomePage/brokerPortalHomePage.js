import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import GALLERY_IMAGES from "@salesforce/resourceUrl/gallery_images";
import new_launch_icon from "@salesforce/resourceUrl/new_launch_icon";
import announcement_logo from "@salesforce/resourceUrl/announcement_logo";
import new_launches_img from "@salesforce/resourceUrl/new_launches_img";
import unit_icon from "@salesforce/resourceUrl/unit_icon";
import location_icon from "@salesforce/resourceUrl/location_icon";
// import diwaliWishes from "@salesforce/resourceUrl/diwaliWishes";
import gallery_icon from "@salesforce/resourceUrl/gallery_icon";
import gallery_video from "@salesforce/resourceUrl/gallery_video";
import birthday_bg from "@salesforce/resourceUrl/birthday_background";
import getHomePageContents from "@salesforce/apex/BrokerPortalHomePageController.getHomePageContents";
import getGallery from "@salesforce/apex/BrokerPortalHomePageController.getGallery";
import getOffers from "@salesforce/apex/BrokerPortalNotificationController.getOffers";
import { loadStyle } from "lightning/platformResourceLoader";
import portalHomePageStyle from "@salesforce/resourceUrl/portalHomePageStyle";

export default class BrokerPortalHomePage extends NavigationMixin(
  LightningElement
) {
  @track getAllImages;
  @track imageIndex;
  @track showOfferPopUp;
  @track getAllOffers = [];
  // @track diwaliWishes = diwaliWishes;
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

  /*get sobhaevents() {
        return [
            { label: 'Event 1', value: 'Event 1' },
            { label: 'Event 2', value: 'Event 2' },
            { label: 'Event 3', value: 'Event 3' },
        ];
    }*/

  closeImageModal() {
    this.displayFullImage = false;
    this.selectedImageURL = "";
    this.imageIndex = 0;
  }

  openFullImage(event) {
    this.selectedImageURL = event.target.src;
    this.displayFullImage = true;
    this.imageIndex = this.getAllImages.findIndex(item => item == this.selectedImageURL);
  }

  handleEventsChange(event) {
    // console.log('~~~~'+JSON.stringify(event.target.value));
    //this.selectedEventValue = event.detail.value;
    this.selectedEventValue = event.target.value;
    getGallery({ eventName: this.selectedEventValue })
      .then((result) => {
        let oddImageArray = [];
        let evenImageArray = [];
        let galleryImageNames = result.imageGallery;
        this.getAllImages = galleryImageNames;
        this.imageGalleryLength = galleryImageNames.length;
        for (let i = 0; i < galleryImageNames.length; i++) {
          if (i % 2 == 0) evenImageArray.push(galleryImageNames[i]);
          else oddImageArray.push(galleryImageNames[i]);
        }
        this.imageEvenArray = evenImageArray;
        this.imageOddArray = oddImageArray;

        let oddVideoArray = [];
        let evenVideoArray = [];
        let galleryVideoNames = result.videoGallery;
        this.videoGalleryLength = galleryVideoNames.length;
        for (let i = 0; i < galleryVideoNames.length; i++) {
          if (i % 2 == 0) evenVideoArray.push(galleryVideoNames[i]);
          else oddVideoArray.push(galleryVideoNames[i]);
        }
        this.videoEvenArray = evenVideoArray;
        this.videoOddArray = oddVideoArray;
      })
      .catch((error) => {
        console.log("VVK error:", error);
      });
  }

  connectedCallback() {
    const getOfferPopupVal = JSON.parse(sessionStorage.getItem('showOffersPopUp'));
    if (getOfferPopupVal != null) {
      this.showOfferPopup = false;
    } else {
      this.showOfferPopUp = true;
    }

    getOffers()
      .then((result) => {
        this.getAllOffers = result;
      })
      .catch((error) => {
        console.log(error);
      });

    loadStyle(this, portalHomePageStyle);
    this.loadHomePageContents();
    this.gallery_img_1 = GALLERY_IMAGES + "/" + "gallery-img-1.png";
    this.gallery_img_2 = GALLERY_IMAGES + "/" + "gallery-img-2.png";
    this.gallery_img_3 = GALLERY_IMAGES + "/" + "gallery-img-3.png";
    this.gallery_img_4 = GALLERY_IMAGES + "/" + "gallery-img-4.png";
    this.gallery_img_5 = GALLERY_IMAGES + "/" + "gallery-img-5.png";
    this.new_launches_logo = new_launch_icon;
    this.announcement_icon = announcement_logo;
    this.new_launches_image = new_launches_img;
    this.unit_image = unit_icon;
    this.location_image = location_icon;
    this.gallery_image = gallery_icon;
    this.gallery_video_link = gallery_video;
  }

  get backgroundImg() {
    let bg = "background: url(" + birthday_bg + ") no-repeat";
    return bg;
  }

  loadHomePageContents() {
    getHomePageContents()
      .then((result) => {
        this.content = result;
        console.log(
          "Announcement Content Version Map:",
          result.announcementContentVersionMap
        );

        let customerOffer = result.customerOffer;
        for (let i = 0; i < customerOffer.length; i++) {
          let des = customerOffer[i].Offer_Description__c;
          des = des.replaceAll("<[/a-zAZ0-9]*>", " ");
          des = des.replaceAll("&nbsp;", " ");
          customerOffer[i].Offer_Description__c = des;
        }
        let content = this.content;
        content.customerOffer = customerOffer;
        this.content = content;
        this.content.announcements.forEach((item, index) => {
          const downloadUrl = result.announcementContentVersionMap
            ? result.announcementContentVersionMap[item.Id]
            : "";
          this.content.announcements[index] = {
            ...item,
            isClipped: true,
            downloadUrl: downloadUrl ? downloadUrl : undefined
          };
        });
        this.latestProjects = result.latestProjects[0];
        let oddImageArray = [];
        let evenImageArray = [];
        let galleryImageNames = result.imageGallery;
        this.getAllImages = galleryImageNames;
        this.imageGalleryLength = galleryImageNames.length;
        for (let i = 0; i < galleryImageNames.length; i++) {
          if (i % 2 == 0) evenImageArray.push(galleryImageNames[i]);
          else oddImageArray.push(galleryImageNames[i]);
        }
        this.imageEvenArray = evenImageArray;
        this.imageOddArray = oddImageArray;

        let oddVideoArray = [];
        let evenVideoArray = [];
        let galleryVideoNames = result.videoGallery;
        this.videoGalleryLength = galleryVideoNames.length;
        for (let i = 0; i < galleryVideoNames.length; i++) {
          if (i % 2 == 0) evenVideoArray.push(galleryVideoNames[i]);
          else oddVideoArray.push(galleryVideoNames[i]);
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
        console.log("latestProjects", this.latestProjects);
      })
      .catch((error) => {
        console.log("VVK error:", error);
      });
  }

  navigateTab(event) {
    const currentTab = event.currentTarget.dataset.tab;
    let clickedElement = event.target;
    let listItems = this.template.querySelectorAll(".tab-area li");
    listItems.forEach((item) => {
      item.classList.remove("active");
    });
    clickedElement.classList.add("active");
    let tabContent = this.template.querySelectorAll(".tab-content");
    tabContent.forEach((item) => {
      item.classList.remove("active");
    });
    this.template
      .querySelector('.tab-content[data-id="' + currentTab + '"]')
      .classList.add("active");
  }

  handleLongText(event) {
    try {
      const getID = event.currentTarget.dataset.id;
      const getElement = this.template.querySelector(
        `.announcement-descrp[data-id="${getID}"]`
      );
      getElement.style = "display:block; height:auto;";
      event.target.style.display = "none";

      console.log("getdata", getElement, getID, event.currentTarget);
    } catch (error) {
      console.log("error--handleLongText", error.message);
    }
  }

  handleOfferPopUp() {
    this.showOfferPopUp = false;
    sessionStorage.setItem("showOffersPopUp", false);
  }

  handleRenewal(event) {
    const getFlag = event.detail.flag;
    this.isRenewal = getFlag;
  }
  handleDownload(event) {
    console.log("handle download clicker");
    let dUrl = event.currentTarget.dataset.downloadurl;
    console.log("handle download url is " + dUrl);
    window.open(dUrl);
  }
}