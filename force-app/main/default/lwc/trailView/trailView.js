import { LightningElement, api, wire } from 'lwc';
import getTrailWrapper from '@salesforce/apex/UnitService.getTrailWrapper';

export default class TrailView extends LightningElement {
    trail;
    progressTrail;
    modulesList;
    @api recordId
   

    @wire(getTrailWrapper, { trailId: '$recordId' })
    wiredData({ error, data }) {
      if (data) {
        this.trail = data.trail;
        this.progressTrail = data.progressTrail;
        this.modulesList = data.modulesList;
      } else if (error) {
         console.error('Error-->', error);
      }
    }
}