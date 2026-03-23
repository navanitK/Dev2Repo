/**
 * Unit tests for AccountsSelector
 * Tests SOQL query logic
 */
@isTest
public class AccountsSelectorTest {
    
    @testSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Due Account',
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'active'
            ),
            new Account(
                Name = 'Recent Account',
                EF_LastContactMoment__c = System.today().addDays(-10),
                SnoozeStatus__c = 'active'
            ),
            new Account(
                Name = 'Snoozed Account',
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'inactive'
            )
        };
        insert accounts;
    }
    
    @isTest
    static void testSelectAccountsDueForContact() {
        Test.startTest();
        
        AccountsSelector selector = AccountsSelector.newInstance();
        List<Account> dueAccounts = selector.selectAccountsDueForContact();
        
        Test.stopTest();
        
        System.assertEquals(1, dueAccounts.size(), 'Should return 1 due account');
        System.assertEquals('Due Account', dueAccounts[0].Name);
    }
    
    @isTest
    static void testSelectAccountsDueForContactQueryLocator() {
        Test.startTest();
        
        AccountsSelector selector = AccountsSelector.newInstance();
        Database.QueryLocator locator = selector.selectAccountsDueForContactQueryLocator();
        
        Test.stopTest();
        
        System.assertNotEquals(null, locator, 'Query locator should not be null');
    }
    
    @isTest
    static void testSelectById() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Due Account'];
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
        
        Test.startTest();
        
        AccountsSelector selector = AccountsSelector.newInstance();
        List<Account> selectedAccounts = selector.selectById(accountIds);
        
        Test.stopTest();
        
        System.assertEquals(1, selectedAccounts.size());
        System.assertEquals(testAccount.Id, selectedAccounts[0].Id);
    }
}
