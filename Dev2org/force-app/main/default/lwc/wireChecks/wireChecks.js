import { LightningElement, api, wire, track} from 'lwc';
import { getRecord ,getFieldValue} from 'lightning/uiRecordApi';
import REVENUE_FIELD from '@salesforce/schema/Account.Name';

const fields = [REVENUE_FIELD];

export default class wireChecks extends LightningElement {
    //@api statusValue;
    printString;
    _statusValue;
    _userInput;

    @wire (getRecord, { 
        recordId : '$_userInput', 
        fields
    })
    account;

    get revenue() {
        return getFieldValue(this.account.data, REVENUE_FIELD);
    }

    get merror() {
        console.log( JSON.stringify(getFieldValue(this.account.error)));
    }

    connectedCallback(){
        console.log('connected CB');
        //only executes once when chil instantiates. 
        //if the attrribute value changes in the Parent the connected callback does not get called again.
        //so for computation against passed in field, use getter and setter
        //this.printString = this.statusValue;
    }

    handleUpdate(){
        console.log('handleUpdate');
        var inp  = this.template.querySelector("lightning-input");
        this._userInput = inp.value;
    }
}
