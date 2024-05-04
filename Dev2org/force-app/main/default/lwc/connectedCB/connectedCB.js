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

    constructor(){
        super();
        console.log('### Child Constructor');
    }

    connectedCallback(){
        console.log('### Child connected CB');
        //only executes once when chil instantiates. 
        //if the attrribute value changes in the Parent the connected callback does not get called again.
        //so for computation against passed in field, use getter and setter
        //this.printString = this.statusValue;
        
        //onChange="callme"
    }

    renderedCallback(){
        console.log('### Child rendered Call back');
        template.querylocator('button').assEventListener(Submit); 
    }

    disconnectedCallback(){
        console.log('### Child disconnectedCallback');
    }

    handleUpdate(){
        console.log('handleUpdate');
        var inp  = this.template.querySelector("lightning-input");
        this.printString= inp.value;
    }

     //event handler   
    callMe(event){

    }

    Submit(event){

    }
}

