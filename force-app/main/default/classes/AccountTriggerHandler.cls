/**
 * @description       : Trigger handler for Account to enforce PersonEmail is not null on insert/update
 * @author            : Agentforce
 * @group             :
 * @last modified on  : 12-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * @notes             :
 *   - One Trigger Per Object pattern with a handler class
 *   - Bulkified logic, no SOQL/DML in loops
 *   - Uses return-early pattern
 *   - Validates only Person Accounts (IsPersonAccount = true)
 */
public with sharing class AccountTriggerHandler {

    /**
     * Entry point from trigger
     */
    public static void run(
        List<Account> newList,
        Map<Id, Account> oldMap,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isBefore
    ) {
        if (newList == null || newList.isEmpty()) return;
        if (!isBefore) return; // We only need before context to addError

        if (isInsert || isUpdate) {
            validatePersonEmailNotNull(newList);
        }
    }

    /**
     * Ensures PersonEmail is populated for Person Accounts
     * - Applies on before insert/before update
     * - Skips non-Person Accounts
     */
    private static void validatePersonEmailNotNull(List<Account> records) {
        if (records == null || records.isEmpty()) return;

        for (Account acc : records) {
            // Only enforce for Person Accounts
            if (acc.get('IsPersonAccount') == true) {
                // Add error if PersonEmail is null or blank
                if (isBlank((String)acc.get('PersonEmail'))) {
                    acc.addError('Email is required for Person Accounts.');
                }
            }
        }
    }

    /**
     * Utility: checks if a string is null, empty, or whitespace-only
     */
    private static Boolean isBlank(String s) {
        return s == null || s.trim().length() == 0;
    }
}
