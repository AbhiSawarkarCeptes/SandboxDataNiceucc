import { LightningElement, wire, track } from 'lwc';
import getAllActiveAnnouncements from '@salesforce/apex/CsoAnnouncementBoard.getAllActiveAnnouncements';
import getGeneralInstructions from '@salesforce/apex/CsoAnnouncementBoard.getGeneralInstructions';
import General_Instructions from '@salesforce/label/c.General_Instructions';

export default class CsoAnnouncementBoard extends LightningElement {
    @track data;
    @track pageSize = 3;
    label = General_Instructions;
    @track hasMoreData = true;
    generalInstructions

    //colors = ['#00BFFF', '#FF6F61', '#32CD32', '#DA70D6', '#DAA520'];
    colors = ['#00BFFF', '#00BFFF', '#00BFFF', '#00BFFF', '#00BFFF'];

    getRandomColor() {
        const randomIndex = Math.floor(Math.random() * this.colors.length);
        return this.colors[randomIndex];
    }


    @wire(getGeneralInstructions)
    wiredGeneralInstructions({ data, error }) {
        if (data) {
            this.generalInstructions = data;
            console.log('general instructions are ', this.generalInstructions);
        } else if (error) {
            console.error('Error fetching general instructions', error);
        }
    }
    @wire(getAllActiveAnnouncements, { pageSize: '$pageSize' })
    wiredAnnouncements({ data, error }) {
        if (data) {
            console.log('The announcements are ', data);
            // Format the date and set the data
            this.data = data.map(row => {
                return {
                    ...row,
                    CreatedDate: this.formatDate(row.CreatedDate),
                    notification2line: row.Notification__c.split(/\s+/).slice(0, 50).join(' '),
                    showFullText: false,
                    titleColor: `background-color :  ${this.getRandomColor()}`
                };
            });
            this.hasMoreData = data.length === this.pageSize;
            console.log('want to see data', data);
            console.log(this.data);
        } else if (error) {
            console.error('Error fetching announcements', error);
        }
    }

    formatDate(inputDate) {
        // Convert inputDate string to a Date object
        const inputDateTime = new Date(inputDate);

        // Get the current date
        const currentDate = new Date();
        console.log('the input date is --->', inputDateTime)
        // Check if the input date is today
        if (
            inputDateTime.getDate() === currentDate.getDate() &&
            inputDateTime.getMonth() === currentDate.getMonth() &&
            inputDateTime.getFullYear() === currentDate.getFullYear()
        ) {

            return 'Today';
        }

        // Check if the input date is yesterday
        const yesterday = new Date(currentDate);
        yesterday.setDate(currentDate.getDate() - 1);

        if (
            inputDateTime.getDate() === yesterday.getDate() &&
            inputDateTime.getMonth() === yesterday.getMonth() &&
            inputDateTime.getFullYear() === yesterday.getFullYear()
        ) {
            return 'Yesterday';
        }

        // If not today or yesterday, return the formatted date
        return inputDateTime.toLocaleDateString('en-US', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
           // hour: '2-digit',
           // minute: '2-digit',
           // second: '2-digit',
           // timeZone: 'UTC'
        });
    }


    handleViewMoreClick(event) {
        const announcementId = event.target.dataset.id;
        this.data = this.data.map(row => {
            if (row.Id === announcementId) {
                return { ...row, showFullText: true };
            }
            return row;
        });
    }

    handleViewLessClick(event) {
        const announcementId = event.target.dataset.id;
        this.data = this.data.map(row => {
            if (row.Id === announcementId) {
                return { ...row, showFullText: false };
            }
            return row;
        });
    }

    handleLoadMore() {
        this.pageSize = this.pageSize + 2;
        console.log('Loading more...');
    }

    connectedCallback() {
        let elementInView = false;
        window.addEventListener('scroll', event => {
            console.log(window.scrollY);
            var div = this.template.querySelector('.load-more');
            if (div) {
                var rect = div.getBoundingClientRect();
                const windowHeight = window.innerHeight;
                const topInView = rect.top >= 0 && rect.top <= windowHeight;
                const bottomInView = rect.bottom >= 0 && rect.bottom <= windowHeight;
                const fullyInView = topInView && bottomInView;

                if (fullyInView && !elementInView) {
                    elementInView = true;
                    console.log('Element is within the view');
                    this.handleLoadMore();
                }
                else if (!fullyInView) {
                    elementInView = false;
                }
            }
        });
    }




}