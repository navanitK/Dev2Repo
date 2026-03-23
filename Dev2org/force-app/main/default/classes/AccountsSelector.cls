/**
 * FFLIB Selector for Account queries
 * Handles all SOQL queries for Account objects
 */
public with sharing class AccountsSelector extends fflib_SObjectSelector {
    
    public static AccountsSelector newInstance() {
        return (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.Name,
            Account.OwnerId,
            Account.EF_LastContactMoment__c,
            Account.SnoozeStatus__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }
    
    /**
     * Select all accounts that are due for contact moment
     * Criteria: Last contact was 6+ months ago AND Snooze Status is 'active'
     * @return List of eligible accounts
     */
    public List<Account> selectAccountsDueForContact() {
        Date sixMonthsAgo = System.today().addMonths(-6);
        return (List<Account>) Database.query(
            newQueryFactory()
                .setCondition('SnoozeStatus__c = \'active\' AND EF_LastContactMoment__c != null AND EF_LastContactMoment__c <= :sixMonthsAgo')
                .toSOQL()
        );
    }
    
    /**
     * Get query locator for accounts due for contact (for batch processing)
     * @return QueryLocator for batch job
     */
    public Database.QueryLocator selectAccountsDueForContactQueryLocator() {
        Date sixMonthsAgo = System.today().addMonths(-6);
        return Database.getQueryLocator(
            newQueryFactory()
                .setCondition('SnoozeStatus__c = \'active\' AND EF_LastContactMoment__c != null AND EF_LastContactMoment__c <= :sixMonthsAgo')
                .toSOQL()
        );
    }
    
    /**
     * Select accounts by IDs
     * @param accountIds Set of account IDs to retrieve
     * @return List of accounts
     */
    public List<Account> selectById(Set<Id> accountIds) {
        return (List<Account>) Database.query(
            newQueryFactory()
                .setCondition('Id IN :accountIds')
                .toSOQL()
        );
    }
}
