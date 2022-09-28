import { LightningElement, api } from 'lwc';

const TILE_WRAPPER_SELECTED_CLASS = 'tile-wrapper selected custom-box slds-box slds-p-around_medium'
const TILE_WRAPPER_UNSELECTED_CLASS = 'tile-wrapper custom-box slds-box slds-p-around_medium'

export default class UnitOptions extends LightningElement {
    @api option;
    @api optionSelected;
    optionId;
    
    handleClick(){     
        let optionId = this.option.Id;
        const boatselect = new CustomEvent("optionselect",{
            detail:{
                optionId}})
        this.dispatchEvent(boatselect);
    }

    get tileClass() { 
        if(this.option.Id){
            if(this.optionSelected == this.option.Id){
                return TILE_WRAPPER_SELECTED_CLASS
            } else{
                return TILE_WRAPPER_UNSELECTED_CLASS
            } 
        }       
    }       
}