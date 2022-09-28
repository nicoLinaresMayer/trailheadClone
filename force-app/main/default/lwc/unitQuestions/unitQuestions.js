import { LightningElement, api, wire } from 'lwc';
import { MessageContext, subscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import INDV_PROJECT from '@salesforce/messageChannel/IndividualProject__c'


export default class UnitQuestions extends LightningElement {
    questionList;
    subscription = null;
    optionId;
    optionSelected;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        if(this.subscription != null){
            return
        }
        this.subscription = subscribe(
            this.messageContext,
            INDV_PROJECT,
            (message) => 
            {this.questionList = message.questionList}, 
            {scope: APPLICATION_SCOPE}
            );
    }    

    handleSelected(event){
        console.log('llego al padre handleSelected', event.detail.optionId);
        this.optionSelected = event.detail.optionId;
    }
}