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

    public class TrailWrapper{ 
        //Registro de Trail solicitado
        @AuraEnabled
        public Trail__c trail; 
        //Módulos con Unidades relacionadas
        @AuraEnabled
        public List<Module__c> modulesList;
        //Ids de módulos relacionados al Trail actual en los que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedModuleIds; 
        //Ids de Unidades relacionadas a módulos del Trail actual que el Alumno ya aprobó
        @AuraEnabled
        public List<Id> passedUnitIds; 
        //Porcentaje de progreso del Alumno en el Trail
        @AuraEnabled
        public Integer progressTrail; 

        public TrailWrapper(Trail__c trail, List<Module__c> modulesList, List<Id> passedModuleIds, List<Id> passedUnitIds){
            this.trail = trail;
            this.modulesList = modulesList;
            this.passedModuleIds = passedModuleIds;
            this.passedUnitIds = passedUnitIds;      
            this.progressTrail = passedModuleIds.size()*100 / modulesList.size();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId){
        System.debug('Estoy en getTrailWrapper');
        //New Instance of TrailWrapper
        TrailWrapper trailWrap = new TrailWrapper([SELECT Name, Description__c, Trail_Time__c, Trail_Score__c FROM Trail__c WHERE Id =: trailId], getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));

        return trailWrap;
    }

        private static List<Module__c> getModules(Id trailId){
            //Search related modules
            List<Trail_Module__c> trailModules = [SELECT Module__c FROM Trail_Module__c WHERE Trail__c =: trailId];
            
            Set<Id> moduleIds = new Set<Id>();
            for(Trail_Module__c trailModule : trailModules){
                moduleIds.add(trailModule.Module__c);
            }
            return [SELECT Name, Module_Time_Estimated__c, Module_Score__c, (SELECT Name, Time_Estimated__c, Unit_Score__c, Content__c FROM Units__r) FROM Module__c WHERE Id IN : moduleIds];
        }

        private static List<Id> getModuleIdsCompleted(Id trailId){
        
            List<Module_Response__c> moduleResponses = [SELECT Module__c FROM Module_Response__c WHERE Status__c = 'Completed' AND Module__c IN :getModules(trailId) AND User__c =: Userinfo.getUserId()];

            Set<Id> completedModuleIds = new Set<Id>();
            for(Module_Response__c moduleResp : moduleResponses){
                completedModuleIds.add(moduleResp.Module__c);
            }
            return new List<Id>(completedModuleIds);
        }
        
        private static List<Id> getUnitIdsCompleted(Id trailId){
            List<Unit_Response__c> unitResponses = [SELECT Unit__c FROM Unit_Response__c WHERE Status__c = 'Completed' AND UserID__c =: Userinfo.getUserId() AND Unit__r.Module__c IN : getModules(trailId)];

            Set<Id> completedUnitIds = new Set<Id>();
            for(Unit_Response__c unitResp : unitResponses){
                completedUnitIds.add(unitResp.Unit__c);
            }
            return  new List<Id>(completedUnitIds);    
        }

    public class UnitWrapper{
        public Unit__c unit; 
        //Registro de Unidad solicitada
        public List<Question__c> questionList;    
        //Listado de Preguntas con Opciones relacionadas

        public UnitWrapper(Unit__c unit, List<Question__c> questionList){
            this.unit = unit;
            this.questionList = questionList;
        }
    }

    public UnitWrapper getUnitWrapper(Id unitId){
        return new UnitWrapper([SELECT Id, Content__c, Module__c, Time_Estimated__c, Name, Unit_Score__c FROM Unit__c WHERE Id = :unitId], [SELECT Id, (SELECT Id, Is_Correct__c, Description__c, Name FROM Options__r) FROM Question__c WHERE Unit__c =: unitId]);
    }
}
