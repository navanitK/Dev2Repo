import { LightningElement, api, wire, track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
export default class connectedCBParent extends LightningElement {
    printString = 'initial value';
    @api recordId;
    constructor(){
        super();
        console.log('### Parent Constructor');
    }

    connectedCallback(){
        console.log('### Parent connected CB');
        //only executes once when chil instantiates. 
        //if the attrribute value changes in the Parent the connected callback does not get called again.
        //so for computation against passed in field, use getter and setter
        //this.printString = this.statusValue;
    }

    renderedCallback(){
        console.log('### Parent rendered Call back');
    }

    disconnectedCallback(){
        console.log('### Parent disconnectedCallback');
    }

    @wire (getRecord, { 
        recordId : '$recordId', 
        fields : ['Contact.Name']
    })    
    wiredContact({ error, data }) {
        console.log('### Wire Data call back');
        if (data) {
            
        } else if (error) {
            
        }
    }

    handleUpdate(){
        console.log('Set Parents input');
        var inp  = this.template.querySelector("lightning-input");
        console.log('its now : ' + inp.value);
        this.printString= inp.value;
    }
}
