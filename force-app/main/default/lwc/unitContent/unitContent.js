import { LightningElement, api, wire } from 'lwc';
import getUnitWrapper from "@salesforce/apex/UnitService.getUnitWrapper";
export default class UnitContent extends LightningElement {
    @api recordId
    unit;
    questionList;

    @wire(getUnitWrapper, { unitId: '$recordId' })
    wiredData({ error, data }) {
      if (data) {
        this.unit = data.unit;
        this.questionList = data.questionList;
        console.log('UNIT-->', this.unit);
        console.log('DATA-->', data);
      } else if (error) {
         console.error('Error:', error);
      }
    }
}