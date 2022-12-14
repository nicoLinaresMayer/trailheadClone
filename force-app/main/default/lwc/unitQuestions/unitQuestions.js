import { LightningElement, wire, api } from 'lwc';
import { MessageContext, subscribe, publish } from 'lightning/messageService';
import INDV_PROJECT from '@salesforce/messageChannel/IndividualProject__c'
import registerUnitResponse from "@salesforce/apex/UnitService.registerUnitResponse"
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UNIT_COMPLETED_PNG from '@salesforce/resourceUrl/unitCompleted';
export default class UnitQuestions extends LightningElement {
    questionList;
    subscription = null;
    optionId;
    optionSelectedMap = {};
    optionSelected = [];
    @api recordId;
    imageUnitCompleted = UNIT_COMPLETED_PNG;

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
            {this.questionList = message.questionList}
            );
    }    

    handleSelected(event){
        this.optionSelectedMap[event.detail.questionId] = event.detail.optionId;

        this.optionSelected = Object.values(this.optionSelectedMap);
        
    }

    handleSubmit(){        
        registerUnitResponse({unitId: this.recordId, jsonAnswer: JSON.stringify(this.optionSelectedMap)})
        .then((res)=>{
            let flag = res == 0 ? true : false;
            if(flag){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Answer Submited',
                    variant: 'success'
                }));
                publish(this.messageContext, INDV_PROJECT, {refresh: true});
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Wrong Answer',
                    message: 'Number of Tries: ' + res,
                    variant: 'error'
                }));
            }
        })
        .catch(e=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'ERROR',
                message: e.body.message,
                variant: 'error'
            }));
        })
    }
}