/**
 * FFLIB Selector for Task queries
 * Handles all SOQL queries for Task objects related to contact notifications
 */
public with sharing class TasksSelector extends fflib_SObjectSelector {
    
    public static final String CONTACT_NOTIFICATION_SUBJECT = 'hey contact your customer';
    
    public static TasksSelector newInstance() {
        return (TasksSelector) Application.Selector.newInstance(Task.SObjectType);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Task.Id,
            Task.Subject,
            Task.WhatId,
            Task.WhoId,
            Task.OwnerId,
            Task.ActivityDate,
            Task.Status,
            Task.Description,
            Task.IsReminderSet,
            Task.ReminderDateTime
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }
    
    /**
     * Select existing open contact notification tasks for given account IDs
     * @param accountIds Set of account IDs to check
     * @return List of existing open tasks
     */
    public List<Task> selectOpenContactNotificationTasksByAccountIds(Set<Id> accountIds) {
        return (List<Task>) Database.query(
            newQueryFactory()
                .setCondition('WhatId IN :accountIds AND Subject = :subject AND Status != \'Completed\'')
                .toSOQL()
        );
    }
    
    /**
     * Select all open contact notification tasks for a user
     * @param userId The user ID
     * @return List of open contact notification tasks
     */
    public List<Task> selectOpenContactNotificationTasksByUserId(Id userId) {
        return (List<Task>) Database.query(
            newQueryFactory()
                .setCondition('OwnerId = :userId AND Subject = :subject AND Status != \'Completed\'')
                .setOrdering('ActivityDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }
    
    /**
     * Select open contact notification tasks for a specific account
     * @param accountId The account ID
     * @return List of open tasks for the account
     */
    public List<Task> selectOpenContactNotificationTasksByAccountId(Id accountId) {
        return (List<Task>) Database.query(
            newQueryFactory()
                .setCondition('WhatId = :accountId AND Subject = :subject AND Status != \'Completed\'')
                .setOrdering('ActivityDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }
    
    /**
     * Select all open contact notification tasks (admin/reporting)
     * @return List of all open contact notification tasks
     */
    public List<Task> selectOpenContactNotificationTasks() {
        return (List<Task>) Database.query(
            newQueryFactory()
                .setCondition('Subject = :subject AND Status != \'Completed\'')
                .setOrdering('ActivityDate', fflib_QueryFactory.SortOrder.ASCENDING)
                .toSOQL()
        );
    }
    
    /**
     * Get the contact notification subject constant
     */
    public static String getContactNotificationSubject() {
        return CONTACT_NOTIFICATION_SUBJECT;
    }
}
