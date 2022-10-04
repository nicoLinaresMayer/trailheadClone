import { LightningElement, api, wire } from 'lwc';
import getTrailWrapper from '@salesforce/apex/UnitService.getTrailWrapper';

export default class TrailView extends LightningElement {
    trail;
    progressTrail;
    modulesList;
    passedModuleIds;
    @api recordId
   

    @wire(getTrailWrapper, { trailId: '$recordId' })
    wiredData({ error, data }) {
      if (data) {
        console.log('DATA->', data);
        this.trail = data.trail;
        this.progressTrail = data.progressTrail;
        this.modulesList = data.modulesList;
        this.passedModuleIds = data.passedModuleIds;
        console.log('data.passedmoduleIds', data.passedModuleIds);
        console.log('passsedmoduleID TRAILVIEW', this.passedModuleIds);
        
      } else if (error) {
         console.error('Error-->', error);
      }
    }
}