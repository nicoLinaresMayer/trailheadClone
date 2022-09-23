import { LightningElement, api, wire } from 'lwc';
import getTrail from '@salesforce/apex/UnitService.getTrailWrapper';

export default class TrailView extends LightningElement {
    trail;
    @api recordId
   

    @wire(getTrail, { trailId: '$recordId' })
    wiredData({ error, data }) {
      if (data) {
        console.log('Data-->', data);
        this.trail = data.modulesList[0].Name;
        console.log('Relacionadas-->', data.modulesList[0].Units__r);
      } else if (error) {
         console.error('Error-->', error);
      }
    }
}