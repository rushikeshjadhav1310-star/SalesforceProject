/**
 * @description       : Unit tests for AccountTriggerHandler enforcing PersonEmail on Person Accounts
 * @author            : Agentforce
 * @group             :
 * @last modified on  : 12-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 */
@IsTest
private class AccountTriggerHandler_Test {

    @TestSetup
    static void setupData() {
        // Nothing required for Person Account tests; org must have Person Accounts enabled
    }

    @IsTest
    static void testInsertPersonAccountWithoutEmail_ShouldFail() {
        // Person Accounts require setting person-type fields
        Account pa = new Account();
        pa.put('RecordTypeId', getAnyPersonAccountRecordTypeId());
        pa.put('LastName', 'Test No Email'); // required for PersonAccounts
        // Deliberately do not set PersonEmail
        Test.startTest();
        try {
            insert pa;
            System.assert(false, 'Expected DMLException due to missing PersonEmail');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email is required for Person Accounts.'), 'Error message mismatch: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testInsertPersonAccountWithEmail_ShouldPass() {
        Account pa = new Account();
        pa.put('RecordTypeId', getAnyPersonAccountRecordTypeId());
        pa.put('LastName', 'Test With Email');
        pa.put('PersonEmail', 'user@example.com');
        Test.startTest();
        insert pa;
        Test.stopTest();
        System.assertNotEquals(null, pa.Id, 'Insert should succeed when PersonEmail is populated');
    }

    @IsTest
    static void testUpdatePersonAccountClearEmail_ShouldFail() {
        Account pa = new Account();
        pa.put('RecordTypeId', getAnyPersonAccountRecordTypeId());
        pa.put('LastName', 'Test Update Clear Email');
        pa.put('PersonEmail', 'keep@example.com');
        insert pa;

        pa.put('PersonEmail', null);
        Test.startTest();
        try {
            update pa;
            System.assert(false, 'Expected DMLException when clearing PersonEmail');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email is required for Person Accounts.'), 'Error message mismatch: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testBusinessAccount_NotEnforced() {
        // Create a Business Account (non-person) by not assigning a Person Account record type
        Account ba = new Account(Name = 'Business Co');
        Test.startTest();
        insert ba;
        Test.stopTest();
        System.assertNotEquals(null, ba.Id, 'Business Account insert should succeed without PersonEmail');
    }

    // Helper to fetch any Person Account record type Id
    private static Id getAnyPersonAccountRecordTypeId() {
        // Query record types for Account where IsPersonType = true
        // Some orgs may have multiple; select the first
        // We cannot query IsPersonType field via Apex SOQL. Instead, use a describe
        // to find any Person Account record type by DeveloperName convention when available.
        // Fallback: if only one record type exists and the org is Person Account-only, use it.
        List<RecordType> rts = [
            SELECT Id, DeveloperName, Name, SObjectType
            FROM RecordType
            WHERE SObjectType = 'Account'
            LIMIT 200
        ];
        System.assert(rts.size() > 0, 'No Account Record Types found.');
        // Try common developer names first
        for (RecordType rt : rts) {
            if (rt.DeveloperName != null && (rt.DeveloperName.toLowerCase().contains('person') || rt.DeveloperName.toLowerCase().contains('individual'))) {
                return rt.Id;
            }
        }
        // As a last resort, return the first, and let validation catch if it is not a Person Account
        return rts[0].Id;
    }
}
