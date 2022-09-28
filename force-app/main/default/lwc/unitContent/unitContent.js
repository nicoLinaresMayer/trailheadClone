import { LightningElement, api, wire } from 'lwc';
import getUnitWrapper from "@salesforce/apex/UnitService.getUnitWrapper";
import { MessageContext, publish } from 'lightning/messageService';
import INDV_PROJECT from '@salesforce/messageChannel/IndividualProject__c'
export default class UnitContent extends LightningElement {
    @api recordId
    unit;
    questionList;

   /*  connectedCallback(){
      publish(this.messageContext, INDV_PROJECT, {questionList: this.questionList});
    } */

    @wire(MessageContext)
    messageContext;

    @wire(getUnitWrapper, { unitId: '$recordId' })
    wiredData({ error, data }) {
      if (data) {
        this.unit = data.unit;
        this.questionList = data.questionList;
        console.log('UNIT-->', this.unit);
        console.log('DATA-->', data);
        
        publish(this.messageContext, INDV_PROJECT, {questionList: this.questionList});


      } else if (error) {
         console.error('Error:', error);
      }
    }

    

}