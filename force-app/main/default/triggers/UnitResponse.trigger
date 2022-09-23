trigger UnitResponse on Unit_Response__c (before update, after update) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            UnitResponseTrigger.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            UnitResponseTrigger.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}