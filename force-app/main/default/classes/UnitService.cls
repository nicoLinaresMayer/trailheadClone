public with sharing class UnitService {
    public class CustomException extends Exception{}
    
    public static Boolean registerUnitResponse (Id unitId, String jsonAnswer){

            Savepoint sp = Database.setSavepoint();

        try{
            //Select Unit From DB
            Unit__c unit = [SELECT Module__c, (SELECT Id FROM Questions__r), (SELECT Id, Number_Tries__c FROM Unit_Responses__r WHERE Module_Response__r.User__c =: UserInfo.getUserId() ORDER BY Number_Tries__c DESC LIMIT 1) FROM Unit__c WHERE Id =: unitId];

            //Check If Module Resp Exist
            Module_Response__c moduleResp = [SELECT Id FROM Module_Response__c WHERE Module__c =: unit.Module__c AND User__c =: Userinfo.getUserId() AND Status__c = 'In Progress'];
            
            //If not exist, I create it
            if(moduleResp == null){
                moduleResp = new Module_Response__c(User__c = Userinfo.getUserId(), Module__c = unit.Module__c, Status__c = 'In Progress');
                insert moduleResp;      
            }          

            //Create & Insert a Unit Response
            Unit_Response__c unitResp = new Unit_Response__c(Unit__c = unitId, Module_Response__c = moduleResp.Id, Stage_Unit_Response__c = 'Draft');
           
            //Add number of tries
            unitResp.Number_Tries__c = !unit.Unit_Responses__r.isEmpty() ? unit.Unit_Responses__r[0].Number_Tries__c + 1 : 1;
            insert unitResp;

            //Create & Insert a Questions Response
            Map<Id,Id> answerMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);

            List<Question_Response__c> questionRespList = new List<Question_Response__c>();

            for(Question__c question : unit.Questions__r){
                if(answerMap.containsKey(question.Id)){
                questionRespList.add(new Question_Response__c(Question__c = question.Id, Unit_Response__c = unitResp.Id, Option__c = answerMap.get(question.Id)));
                }else{
                    throw new CustomException('La pregunta'
                    + question.Name + 'no fue respondida y es requerida!');
                }
            
            }
            
            insert questionRespList;
        
            //Update Unit Response with a stage 'Answered' to shoot the Trigger

            unitResp.Stage_Unit_Response__c = 'Answered';
            
            update unitResp;
            
            //ES NECESARIA LA QUERY?? O PODRIMOS SOLO RETORNAR unitResp?
            return [SELECT Status__c FROM Unit_Response__c WHERE Id =: unitId].Status__c == 'Completed' ? true : false;

        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }

    }
}
