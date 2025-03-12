import { LightningElement, track } from 'lwc';
import portalAssests from '@salesforce/resourceUrl/portalBrokerAssets';
import getNotifications from '@salesforce/apex/BRPortalNotificationController.getNotifications';
import getOffers from '@salesforce/apex/BRPortalNotificationController.getOffers';
import updateLastSeen from '@salesforce/apex/BRPortalNotificationController.updateLastSeen';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';
import { loadStyle } from 'lightning/platformResourceLoader';
import PortalFooterPage from '@salesforce/resourceUrl/portalFooterPage';
import { NavigationMixin } from 'lightning/navigation';

export default class BrPortalFooterSection extends NavigationMixin(LightningElement) {
    announcement_icon = portalAssests + '/assets/images/footer-announcement-icon.svg';
    notification_icon = portalAssests + '/assets/images/footer-notification-icon.svg';
    footerUpArrow_icon = CommonIcons + '/commonIcons/footerUpArrow.svg';
    footerDownArrow_icon = CommonIcons + '/commonIcons/footerDownArrow.svg';
    channelOfferImg = portalAssests + '/assets/images/new-launches-img.png';
    dateMonth; dateDay;
    totalNotifications;
    @track channelFlag = false;
    @track notificationFlag = false;
    @track notificationsData = [];
    @track notifications = [];
    @track showFooterFlag = true;
    @track offerHeader = ''
    @track offerWrapList = [];
    @track offers;
    @track offerDataLoaded = false;
    @track showTotalNotificationCount = false;
    @track isRenewPopupVisible = true;
    @track cleanedUrl;

    connectedCallback() {
        try {
            Promise.all([
                loadStyle(this, PortalFooterPage)
            ]).catch(error => {
                console.log("Error--PortalFooterPage", error.message);
            });
            const showFooter = sessionStorage.getItem("showFooter");
            console.log('===> showFooter ' + showFooter);
            if (showFooter != null) {
                this.showFooterFlag = JSON.parse(showFooter) == true ? true : false;
            } else {
                this.showFooterFlag = false;
            }
            console.log(typeof showFooter, "Footer--connected");
            getNotifications()
            .then(result => {
                console.log(result);
                this.notifications = result;
                let total = 0;
                for(let i=0;i<result.length;i++) {
                    if(result[i].isOpened == false) {
                        total = total + 1;
                    }
                }
                console.log(this.notifications, typeof this.notifications, "notfications");
                this.totalNotifications = total;
                if(total > 0) {
                    this.showTotalNotificationCount = true;
                }
                this.notificationsData = this.notifications.map(item => {
                    let className, iconName, isIcon, iconText;
                    if (String(item.status).toLowerCase() !== "approved" && String(item.status).toLowerCase() !== "rejected") {
                        className = `slds-col slds-size_3-of-12 status-style ${this.getRandomColorClass()}`;
                        isIcon = false;
                    } else {
                        iconName = String(item.status).toLowerCase() == "approved" ? "action:approval" : "action:close";
                        iconText = String(item.status).toLowerCase() == "approved" ? "Approved" : "Rejected";
                        isIcon = true;
                    }
                    return { ...item, className, isIcon, iconName, iconText };
                });
            })
            .catch(error => {
                console.log(error);
            });

            var dat = new Date();
            this.dateMonth = dat.toLocaleString('en-US', { month: 'short' });
            this.dateDay = dat.getDate();

            getOffers()
                .then(result => {
                    /*this.offers = result;
                    if(result.channelPartnerOffers.length > 0 && result.customerOffers.length > 0) {
                        this.offerHeader = 'Offers';
                    }
                    else if(result.channelPartnerOffers.length > 0) {
                        this.offerHeader = 'Channel Partner Offer';
                    }
                    else if(result.customerOffers.length > 0) {
                        this.offerHeader = 'Customer Offer';
                    }*/
                    this.offerWrapList = result;
                    this.offerHeader = 'Offers';
                    this.offerDataLoaded = true;
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error.message, "error-Channel");
        }
    }

    getRandomColorClass() {
        const randomNumber = Math.floor(Math.random() * 3) + 1;
        return `random-color-${randomNumber}`;
    }

    handlePopOver(event) {
        const getAction = event.currentTarget.dataset.action;
        if (getAction == "channel") {
            this.channelFlag = !this.channelFlag;
            this.notificationFlag = false;
        }
        if (getAction == "notifications") {
            this.notificationFlag = !this.notificationFlag;
            if(!this.notificationFlag) {
                this.totalNotifications = 0;
                var notificationsData = this.notificationsData;
                for(let i=0;i<notificationsData.length;i++) {
                    notificationsData[i].isOpened = true;
                }
                this.notificationsData = notificationsData;
                this.showTotalNotificationCount = false;
            }
            this.channelFlag = false;
        }
        updateLastSeen()
        .then(result => {
        })
        .catch(error => {
            console.log(error);
        });
    }

    handleImageClick(event) {
        try {
            const getImage = event.currentTarget.dataset.image;
            const srcRegex = /<img[^>]+src="([^"]*)"/;
            const matches = String(getImage).match(srcRegex);
            if (matches && matches[1]) {
                const url = matches[1];
                this.cleanedUrl = url.replace(/&amp;/g, "&");
                console.log('===> this.cleanedUrl ' + this.cleanedUrl);
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.cleanedUrl
                    }
                }).then(generatedUrl => {
                    window.open(generatedUrl, '_blank');
                });
            }
        } catch (error) {
            console.log('OUTPUT : Error--handleImageClick', error.message);
        }
    }

    handleFooterBar(event) {
        /*const getAction = event.currentTarget.dataset.action;
        if (getAction == "down") {
            this.showFooterFlag = false;
        } else {
            this.showFooterFlag = true;
        }
        sessionStorage.setItem("showFooter", this.showFooterFlag);*/
        try {
            const getAction = event.currentTarget.dataset.action;
            sessionStorage.setItem("showFooter", !this.showFooterFlag);
            this.showFooterFlag = !this.showFooterFlag;
        } catch (error) {
            console.log("error--handleFooterBar", error.message);
        }
    }
}