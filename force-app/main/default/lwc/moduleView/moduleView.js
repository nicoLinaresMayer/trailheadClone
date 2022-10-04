import { LightningElement, api } from 'lwc';

export default class ModuleView extends LightningElement {
    @api module;
    @api passedModuleIds;

    get moduleIsCompleted(){
        console.log('result Getter->', this.passedModuleIds.includes(this.module.Id));

        console.log('passedModules->', JSON.parse(JSON.stringify(this.passedModuleIds)));
        console.log('moudles->', JSON.parse(JSON.stringify(this.module)));
        return this.passedModuleIds.includes(this.module.Id);
    }

}