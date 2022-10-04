import { LightningElement, api, wire } from 'lwc';
import getUnitWrapper from "@salesforce/apex/UnitService.getUnitWrapper";
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import INDV_PROJECT from '@salesforce/messageChannel/IndividualProject__c'
import {refreshApex} from '@salesforce/apex';

export default class UnitContent extends LightningElement {
    @api recordId
    unit;
    questionList;
    _wiredResult;
    subscription = null;

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
          {if (message.refresh) refreshApex(this._wiredResult)}
          );
  }

    @wire(getUnitWrapper, { unitId: '$recordId' })
    wiredData(result) {
      const {data,error} = result;
      this._wiredResult = result;
      if (data) {
        
        this.unit = data.unit;
        this.questionList = data.isCompleted ? undefined : data.questionList;
        
        publish(this.messageContext, INDV_PROJECT, {questionList: this.questionList});
        
    } else if (error) {
         console.error('Error:', error);
      }
    }
}