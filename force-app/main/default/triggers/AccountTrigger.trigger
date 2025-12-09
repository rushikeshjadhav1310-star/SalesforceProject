/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
// One Trigger Per Object: Account
trigger AccountTrigger on Account (before insert, before update) {
    AccountTriggerHandler.run(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isBefore);
}
