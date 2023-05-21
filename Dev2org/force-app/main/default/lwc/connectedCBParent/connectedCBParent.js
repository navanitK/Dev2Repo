import { LightningElement, api, wire, track} from 'lwc';

export default class connectedCBParent extends LightningElement {
    printString = 'initial value';

    connectedCallback(){
        console.log('connected CB Parent');
        
    }

    handleUpdate(){
        console.log('Set Parents input');
        var inp  = this.template.querySelector("lightning-input");
        console.log('its now : ' + inp.value);
        this.printString= inp.value;
    }
}
