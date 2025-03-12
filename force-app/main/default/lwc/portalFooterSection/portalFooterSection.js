import { LightningElement, track, wire } from "lwc";
import portalAssests from "@salesforce/resourceUrl/portalBrokerAssets";
import getNotifications from "@salesforce/apex/BrokerPortalNotificationController.getNotifications";
import getOffers from "@salesforce/apex/BrokerPortalNotificationController.getOffers";
import updateLastSeen from "@salesforce/apex/BrokerPortalNotificationController.updateLastSeen";
import getBRFileHistory from "@salesforce/apex/PortalBrokerEventsController.getBRFileHistory";
import createDataDownloadTracker from "@salesforce/apex/BrokerPortalSobhaProjectsController.createDataDownloadTracker";
import userId from '@salesforce/user/Id';

import CommonIcons from "@salesforce/resourceUrl/commonIcons";
import { loadStyle } from "lightning/platformResourceLoader";
import PortalFooterPage from "@salesforce/resourceUrl/portalFooterPage";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";

import { publish, subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from "lightning/messageService";
import msgService from "@salesforce/messageChannel/LMSChannel__c";

const channelJson = [
    {
        coverImg: "",
        header: "Exclusive 5% offer",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "23 Apr 2024",
    },
    {
        coverImg: "",
        header: "Exclusive 6% offer",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "24 Apr 2024",
    },
    {
        coverImg: "",
        header: "Exclusive 7% offer",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "25 Apr 2024",
    }
];

const notificationsJson = [
    {
        status: "Customer Offers",
        header: "Exclusive 5% offer",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "23 Apr 2024",
        notification: true,
        isOpened: true
    },
    {
        status: "Channel Partner Offers",
        header: "Exclusive 5% offer",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "23 Apr 2024",
        notification: true,
        isOpened: true
    },
    {
        status: "New Launch",
        header: "Penthouse - Sobha SeaHaven",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elitLorem. Lorem ipsum dolor sit amet, con...",
        date: "19 Apr 2024",
        notification: false,
        isOpened: false
    },
    {
        status: "Gallery",
        header: "",
        description: "New event Sobha Stars 2023 is added to the Gallery",
        date: "19 Apr 2024",
        notification: false,
        isOpened: false
    },
    {
        status: "approved",
        header: "",
        description: "Your Channel Relations manager has approved your (Marketing Events)",
        date: "10 Apr 2024",
        notification: false,
        isOpened: false
    },
    {
        status: "rejected",
        header: "",
        description: "Your Channel Relations manager has rejected your (Marketing Collaterals pertaining to specific Marketing Event)",
        date: "9 Apr 2024",
        notification: false,
        isOpened: false
    },

];

export default class PortalFooterSection extends NavigationMixin(LightningElement) {

    announcement_icon = portalAssests + "/assets/images/footer-announcement-icon.svg";
    notification_icon = portalAssests + "/assets/images/footer-notification-icon.svg";
    footerUpArrow_icon = CommonIcons + "/commonIcons/footerUpArrow.svg";
    footerDownArrow_icon = CommonIcons + "/commonIcons/footerDownArrow.svg";
    channelOfferImg = portalAssests + "/assets/images/new-launches-img.png";
    dateMonth;
    dateDay;
    totalNotifications;
    @track channelFlag = false;
    @track notificationFlag = false;

    @track channelPartnerData = [];
    @track notificationsData = [];

    @track notifications = [];
    @track showFooterFlag;

    @track offerHeader = "";
    @track offers;
    @track offerDataLoaded = false;
    @track showTotalNotificationCount = false;
    @track isRenewPopupVisible = true;
    @track showModalImage = false;
    @track cleanedUrl;

    @track brFileHistory = [];
    wiredActivities;
    countFlag = true;
    @track reactiveProperty;

    @wire(MessageContext)
    messageContext;

    @wire(getBRFileHistory, { showBalanceFiles: "$reactiveProperty" })
    getBRFileHistoryMethod(value) {
        this.wiredActivities = value;
        // Destructure the provisioned value
        const { data, error } = value;
        if (data) {
            this.brFileHistory = data.filter(item => Math.ceil(
                (new Date(item.expiryDate) -
                    new Date(new Date().toISOString().split("T")[0])) /
                (1000 * 60 * 60 * 24)
            ) <= 30
                ? true
                : false).map(item => {
                    const calExprDate = Math.ceil(
                        (new Date(item.expiryDate) -
                            new Date(new Date().toISOString().split("T")[0])) /
                        (1000 * 60 * 60 * 24)
                    );
                    return {
                        ...item,
                        isExpired: (calExprDate > 0) && (calExprDate <= 30),
                        expiryDate: this.formatDate(item.expiryDate)
                    }
                });
            if (this.countFlag) {
                this.totalNotifications = this.totalNotifications + this.brFileHistory.length;
            } else {
                let total = 0;
                this.notifications.forEach(item => {
                    if (item.isOpened == false) {
                        total += 1;
                    }
                });
                this.totalNotifications = total + this.brFileHistory.length;
            }
            this.showTotalNotificationCount = Boolean(this.totalNotifications > 0);
            console.log("OUTPUT : brFilehostory", this.brFileHistory, this.notificationsData);
        } else if (error) {
            this.brFileHistory = [];
            console.log("OUTPUT :getBRFileHistory ", error.message);
        }
    }

    async connectedCallback() {
        try {
            Promise.all([
                loadStyle(this, PortalFooterPage)
            ]).catch(error => {
                console.log("Error--PortalFooterPage", error.message);
            });
            const showFooter = sessionStorage.getItem("showFooter");
            if (showFooter != null) {
                this.showFooterFlag = JSON.parse(showFooter) == true ? true : false;
            } else {
                this.showFooterFlag = false;
            }

            subscribe(
                this.messageContext,
                msgService,
                (message) => {
                    console.log('OUTPUT : messagechaneel');
                    this.countFlag = false;
                    refreshApex(this.wiredActivities);
                }
            );

            await getNotifications()
                .then(result => {
                    console.log(result);
                    this.notifications = result;
                    let total = 0;
                    for (let i = 0; i < result.length; i++) {
                        if (result[i].isOpened == false) {
                            total = total + 1;
                        }
                    }
                    console.log(this.notifications, typeof this.notifications, "notfications");
                    // const getnotificationsData = JSON.parse(JSON.stringify(notificationsJson));
                    this.totalNotifications = total;
                    if (total > 0) {
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
                    this.reactiveProperty = false;
                })
                .catch(error => {
                    console.log(error);
                });

            const getPartnerData = JSON.parse(JSON.stringify(channelJson));
            this.channelPartnerData = getPartnerData.map(item => {
                return { ...item, coverImg: this.channelOfferImg }
            });

            var dat = new Date();
            this.dateMonth = dat.toLocaleString("en-US", { month: "short" });
            this.dateDay = dat.getDate();

            getOffers()
                .then(result => {
                    this.offers = result;
                    if (result.channelPartnerOffers.length > 0 && result.customerOffers.length > 0) {
                        this.offerHeader = "Offers";
                    }
                    else if (result.channelPartnerOffers.length > 0) {
                        this.offerHeader = "Channel Partner Offer";
                    }
                    else if (result.customerOffers.length > 0) {
                        this.offerHeader = "Customer Offer";
                    }
                    this.offerDataLoaded = true;
                })
                .catch(error => {
                    console.log(error);
                });
        } catch (error) {
            console.log(error.message, "error-Channel");
        }
    }

    renderedCallback() {
        console.log(this.showFooterFlag, this.hideFooterFlag, "showfooterflag--rendered");
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
            if (!this.notificationFlag) {
                this.totalNotifications = this.brFileHistory.length;
                var notificationsData = this.notificationsData;
                for (let i = 0; i < notificationsData.length; i++) {
                    notificationsData[i].isOpened = true;
                }
                this.notificationsData = notificationsData;
                this.showTotalNotificationCount = Boolean(this.totalNotifications);
            }
            this.channelFlag = false;
        }

        updateLastSeen()
            .then(result => { })
            .catch(error => {
                console.log(error);
            });
    }

    handleImageClick(event) {

        try {
            const getImage = event.currentTarget.dataset.image;
            const getName = "Viewed Offer:"+event.currentTarget.dataset.name; 
            createDataDownloadTracker({projectId:'',filterCriteria:getName})
            .then((result)=> {
                console.log(result);
            })
            const srcRegex = /<img[^>]+src="([^"]*)"/;
            const matches = String(getImage).match(srcRegex);
            if (matches && matches[1]) {
                const url = matches[1];
                let cleanedUrl = url.replace(/&amp;/g, "&");
                window.open(cleanedUrl, "_blank");
            }
        } catch (error) {
            console.log("OUTPUT : Error--handleImageClick", error.message);
        }
    }

    handleFooterBar(event) {
        try {
            sessionStorage.setItem("showFooter", !this.showFooterFlag);
            this.showFooterFlag = !this.showFooterFlag;
            this.channelFlag = false;
            this.notificationFlag = false;
        } catch (error) {
            console.log("error--handleFooterBar", error.message);
        }
    }

    formatDate(dateString) {
        const date = new Date(dateString);

        // Get day, month, year, hours, and minutes
        const day = date.getDate();
        const month = date.getMonth() + 1; // Months are zero-based, so add 1
        const year = date.getFullYear();
        let hours = date.getHours();
        const minutes = date.getMinutes();

        // Determine AM/PM and adjust hours if needed
        const ampm = hours >= 12 ? "pm" : "am";
        hours = hours % 12;
        hours = hours ? hours : 12; // The hour "0" should be "12"

        // Format day, month, hours, and minutes to have leading zero if needed
        const formattedDay = day;
        const formattedMonth = month;
        const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;

        // Combine them into the desired format
        return `${formattedDay}/${formattedMonth}/${year} ${hours}:${formattedMinutes} ${ampm}`;
    }
}