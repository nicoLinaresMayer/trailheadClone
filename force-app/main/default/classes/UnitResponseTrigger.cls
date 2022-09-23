public with sharing class UnitResponseTrigger {
    public static void onBeforeUpdate(List<Unit_Response__c> unitRespList, Map<Id, Unit_Response__c> oldUnitRespMap){
        List<Unit_Response__c> answeredUnitResp = new List<Unit_Response__c>();

        for(Unit_Response__c unitRes :unitRespList){
            if(unitRes.Stage_Unit_Response__c == 'Answered' && oldUnitRespMap.get(unitRes.Id).Stage_Unit_Response__c == 'Draft'){
                answeredUnitResp.add(unitRes);
            }
        }

        Map<Id,Unit_Response__c> unitRespWithQuestionRespFromDB = new Map<Id,Unit_Response__c> ([SELECT Id, (SELECT Id, Option__r.Is_Correct__c FROM Question_Responses__r) FROM Unit_Response__c WHERE Id IN :answeredUnitResp]);


        for (Unit_Response__c unitResp : answeredUnitResp) {
            unitResp.Status__c = 'Completed';
            unitResp.Stage_Unit_Response__c = 'Success';
            for(Question_Response__c questionResp : unitRespWithQuestionRespFromDB.get(unitResp.Id).Question_Responses__r) {
                if(!questionResp.Option__r.Is_Correct__c){
                    unitResp.Status__c = 'In Progress';
                    unitResp.Stage_Unit_Response__c = 'Fail';
                    break;               
                }
            }

            if(unitResp.Status__c == 'Completed'){
                if(unitResp.Number_Tries__c == 1){
                    unitResp.Score__c = unitRespWithQuestionRespFromDB.get(unitResp.Id).Unit__r.Unit_Score__c;
                } else if(unitResp.Number_Tries__c == 2){
                    unitResp.Score__c = unitRespWithQuestionRespFromDB.get(unitResp.Id).Unit__r.Unit_Score__c / 2;
                }else {
                    unitResp.Score__c = unitRespWithQuestionRespFromDB.get(unitResp.Id).Unit__r.Unit_Score__c / 4;
                }
            }
        }
    }

    public static void onAfterUpdate(List<Unit_Response__c> unitRespList, Map<Id, Unit_Response__c> oldUnitRespMap){
        List<Unit_Response__c> completedUnitRespList = new List<Unit_Response__c>();
        
        for(Unit_Response__c unitResp : unitRespList){
            if(unitResp.Status__c == 'Completed' && oldUnitRespMap.get(unitResp.Id).Status__c != 'Completed'){
                completedUnitRespList.add(unitResp);
            }   
        }

        Set<Id> usersIds = new Set<Id>();

        for (Unit_Response__c completedUR : completedUnitRespList) {
            usersIds.add(completedUR.UserID__c);
        }

        Map<Id,User> usersMap = new Map<Id,User> ([SELECT Id, Accumulated_Score__c FROM User WHERE Id IN :usersIds]);

        for (Unit_Response__c unitResp : completedUnitRespList) {
            usersMap.get(unitResp.UserID__c).Accumulated_Score__c += unitResp.Score__c;
        }
        update usersMap.values();
    }
}
