trigger User on User (after update) {
    for(User user : Trigger.new){
        if(user.Accumulated_Score__c < 200){
            user.Rank__c = 'SCOUT';
        }else if(user.Accumulated_Score__c < 3000){
            user.Rank__c = 'HIKER';
        }else if(user.Accumulated_Score__c  < 9000){
            user.Rank__c = 'EXPLORER';
        }else if(user.Accumulated_Score__c < 18000){
            user.Rank__c = 'ADVENTURER';
        }else if(user.Accumulated_Score__c < 35000){
            user.Rank__c = 'MOUNTAINEER';
        }else if(user.Accumulated_Score__c < 50000){
            user.Rank__c = 'EXPEDITIONER';
        }else{
            user.Rank__c = 'RANGER';
        }
    }
}