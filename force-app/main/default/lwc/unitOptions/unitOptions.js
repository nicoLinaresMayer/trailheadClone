import { LightningElement, api } from 'lwc';

const TILE_WRAPPER_SELECTED_CLASS = 'tile-wrapper selected custom-box slds-box slds-p-around_medium'
const TILE_WRAPPER_UNSELECTED_CLASS = 'tile-wrapper custom-box slds-box slds-p-around_medium'

export default class UnitOptions extends LightningElement {
    @api optionList;
    @api optionSelected;
    optionId;
    

    handleClick(event){
        console.log('id', JSON.parse(JSON.stringify(event.target.dataset.id)));
        this.optionId = event.target.dataset.id;
        console.log('PROP DEL PADRE optionselected-', this.optionSelected);
    }

    get tileClass() { 
        console.log('TILECLASS-->');
        console.log('OPT LIST', JSON.parse(JSON.stringify(this.optionList)));
        if(this.optionId){
            if(this.optionSelected == this.optionId){
                return TILE_WRAPPER_SELECTED_CLASS
            } else{
                return TILE_WRAPPER_UNSELECTED_CLASS
            } 
        }       
    }

    selectOption() { 
        let optionId = this.optionId;
        const boatselect = new CustomEvent("optionselect",{
            detail:{
                optionId}})
        this.dispatchEvent(boatselect);
      }
}