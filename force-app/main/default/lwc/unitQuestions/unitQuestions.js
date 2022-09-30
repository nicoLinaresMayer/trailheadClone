import { LightningElement, wire, api } from 'lwc';
import { MessageContext, subscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import INDV_PROJECT from '@salesforce/messageChannel/IndividualProject__c'
import registerUnitResponse from "@salesforce/apex/UnitService.registerUnitResponse"
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class UnitQuestions extends LightningElement {
    questionList;
    subscription = null;
    optionId;
    optionSelectedMap = {};
    optionSelected = [];
    @api recordId;

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
        this.optionSelectedMap[event.detail.questionId] = event.detail.optionId;

        this.optionSelected = Object.values(this.optionSelectedMap);
        
    }

    handleSubmit(){
        console.log('Map to Apex', this.optionSelectedMap);
        console.log('Map to Apex', JSON.stringify(this.optionSelectedMap));
        
        registerUnitResponse({unitId: this.recordId, jsonAnswer: JSON.stringify(this.optionSelectedMap)})
        .then((res)=>{
            console.log('EN EL THEN');
            if(res){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Answer Submited',
                    variant: 'success'
                }));
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Wrong Answer',
                    message: 'Number of Tries :',
                    variant: 'error'
                }));
            }
        })
        .catch(e=>{
            console.log('error--Z', e);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: e.body.pageErrors[0].message,
                variant: 'error'
            }));
        })
    }
}