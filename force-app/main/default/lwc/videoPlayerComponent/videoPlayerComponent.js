import { LightningElement } from 'lwc';

export default class VideoPlayerComponent extends LightningElement {

    get beds() {
        return [
            { key: 'None', value: 'None', selected:false },
            { key: 'Studio', value: 'Studio', selected:false },
            { key: '1 BR', value: '1 BR', selected:false },
            { key: '1.5 BR', value: '1.5 BR', selected:false },
            { key: '2 BR', value: '2 BR', selected:false },
            { key: '2.5 BR', value: '2.5 BR', selected:false },
            { key: '3 BR', value: '3 BR', selected:false },
            { key: '3.5 BR', value: '3.5 BR', selected:false },
            { key: '4 BR', value: '4 BR', selected:false },
            { key: '5 BR', value: '5 BR', selected:false },
            { key: '6 BR', value: '6 BR', selected:false },
            { key: '2 BR Duplex', value: '2 BR Duplex', selected:false },
            { key: '3 BR Duplex', value: '3 BR Duplex', selected:false },
            { key: '4 BR Duplex', value: '4 BR Duplex', selected:false },
        ];
    }

    handleOnItemSelected(event){
        alert(event.detail);
    }
}