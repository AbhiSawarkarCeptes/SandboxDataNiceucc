import { LightningElement, api, track } from 'lwc';

export default class BrPortalReusableCarousel extends LightningElement {
    currentSlide = 0;
    slideWidth = 0;
    slideContainer;
    intervalId;
    @api getData;
    @api textColor;
    @api backgroundColor;
    @api cardTitle;
    @track showNoOfferMsg = false;

    connectedCallback() {
        if (this.getData.length == 0) {
            this.showNoOfferMsg = true;
        }
        console.log(this.getData, "getdata");
        let css = this.template.host.style;
        css.setProperty('--cardColor', this.textColor);
        css.setProperty('--cardBgColor', this.backgroundColor);
        this.startAutoSlide();
    }

    renderedCallback() {
        this.slideContainer = this.template.querySelector('.slides');
        this.slideWidth = this.slideContainer.offsetWidth - 1;
    }

    startAutoSlide() {
        this.intervalId = setInterval(() => {
            this.nextSlide();
        }, 5000);
    }

    stopAutoSlide() {
        clearInterval(this.intervalId);
    }

    nextSlide() {
        if (this.currentSlide < this.getData.length - 1) {
            this.currentSlide++;
        } else {
            this.currentSlide = 0;
        }
        this.updateSlidePosition();
    }

    prevSlide() {
        if (this.currentSlide > 0) {
            this.currentSlide--;
        } else {
            this.currentSlide = this.getData.length - 1;
        }
        this.updateSlidePosition();
    }

    updateSlidePosition() {
        if (this.slideContainer) {
            this.slideContainer.style.transform = `translateX(-${this.currentSlide * this.slideWidth}px)`;
        }
    }
}