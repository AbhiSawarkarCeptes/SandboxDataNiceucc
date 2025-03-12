import { LightningElement, api, track } from 'lwc';
import CommonIcons from '@salesforce/resourceUrl/commonIcons';

export default class BrImageCarousel extends LightningElement {

    @api getData;
    @api imageIndex;
    @track currentIndex = 0;
    autoScrollInterval;
    downloadIcon = CommonIcons + "/commonIcons/download-icon.svg";


    connectedCallback() {
        // this.startAutoScroll();
        this.currentIndex = Number(this.imageIndex);
        console.log(this.imageIndex, typeof this.imageIndex, "imageindex");
    }

    // startAutoScroll() {
    //     this.autoScrollInterval = setInterval(() => {
    //         this.nextSlide();
    //     }, 3000);
    // }

    // stopAutoScroll() {
    //     clearInterval(this.autoScrollInterval);
    // }

    // handleMouseOver() {
    //     this.stopAutoScroll();
    // }

    // handleMouseLeave() {
    //     this.startAutoScroll();
    // }

    previousSlide() {
        this.currentIndex = this.currentIndex === 0 ? this.getData.length - 1 : this.currentIndex - 1;
    }

    nextSlide() {
        this.currentIndex = this.currentIndex === this.getData.length - 1 ? 0 : this.currentIndex + 1;
    }

    get containerStyles() {
        return `transform: translateX(-${this.currentIndex * 100}%)`;
    }

    // get slideStyles() {
    //    return `width: ${100 / this.getImageData.length}%`;
    // }

    handleCloseBtn(event) {
        this.dispatchEvent(new CustomEvent('closemodal', { detail: { action: "close" } }));
    }

    handleDownload() {
        const link = document.createElement('a');
        link.href = this.getData[this.currentIndex];
        link.download = 'downloaded_image'; // You can set custom filename here
        link.target = '_blank';

        // Trigger the download
        document.body.appendChild(link);
        link.click();

        // Clean up
        document.body.removeChild(link);
    }
}