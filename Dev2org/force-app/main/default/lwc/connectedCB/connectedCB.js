import { LightningElement, api, wire, track} from 'lwc';

export default class connectedCB extends LightningElement {
    //@api statusValue;
    printString;
    _statusValue;

    @api 
    set statusValue(inputFromParent){
        if(this._statusValue !== inputFromParent ){
            this._statusValue = inputFromParent;            
            this.printString = this._statusValue;
        }
    }

    get statusValue(){
        this._statusValue;
    }

    connectedCallback(){
        console.log('connected CB');
        //this.printString = this.statusValue;
    }

    handleUpdate(){
        console.log('handleUpdate');
        var inp  = this.template.querySelector("lightning-input");
        this.printString= inp.value;
    }
}
