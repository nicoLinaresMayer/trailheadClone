import { LightningElement, api } from 'lwc';

const TILE_WRAPPER_SELECTED_CLASS = 'tile-wrapper selected custom-box slds-box slds-p-around_medium'
const TILE_WRAPPER_UNSELECTED_CLASS = 'tile-wrapper custom-box slds-box slds-p-around_medium'

export default class UnitOptions extends LightningElement {
    @api option;
    @api question
    @api optionSelected;
    optionId;
    
    handleClick(){     
        let optionId = this.option.Id;
        let questionId = this.question.Id
        const response = new CustomEvent("optionselect",{
            detail:{
                optionId,
                questionId}})
        this.dispatchEvent(response);
    }

     get tileClass() { 
         if(this.optionSelected.includes(this.option.Id)){
            return TILE_WRAPPER_SELECTED_CLASS
        } else{
            return TILE_WRAPPER_UNSELECTED_CLASS
        }     
    }    
  
}