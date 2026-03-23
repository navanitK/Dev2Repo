/**
 * Service class for Contact Notification business logic
 * Handles creation and management of contact notification tasks
 * Uses FFLIB Selectors for data access
 */
public with sharing class ContactNotificationService {
    
    private static final String CONTACT_NOTIFICATION_SUBJECT = 'hey contact your customer';
    
    /**
     * Create notification tasks for accounts due for contact
     * Uses selector to get accounts and existing tasks, then creates new tasks
     */
    public static Integer createNotificationTasksForDueAccounts() {
        Integer tasksCreated = 0;
        
        try {
            // Get selector instances
            AccountsSelector accountsSelector = AccountsSelector.newInstance();
            TasksSelector tasksSelector = TasksSelector.newInstance();
            
            // Get all accounts due for contact
            List<Account> dueAccounts = accountsSelector.selectAccountsDueForContact();
            
            if (dueAccounts.isEmpty()) {
                System.debug('No accounts due for contact at this time');
                return 0;
            }
            
            // Extract account IDs
            Set<Id> accountIds = new Map<Id, Account>(dueAccounts).keySet();
            
            // Get existing open notification tasks for these accounts
            List<Task> existingTasks = tasksSelector.selectOpenContactNotificationTasksByAccountIds(accountIds);
            Set<Id> accountsWithExistingTasks = new Set<Id>();
            
            for (Task task : existingTasks) {
                accountsWithExistingTasks.add(task.WhatId);
            }
            
            // Create tasks for accounts without existing notification tasks
            List<Task> tasksToCreate = new List<Task>();
            
            for (Account account : dueAccounts) {
                if (!accountsWithExistingTasks.contains(account.Id)) {
                    tasksToCreate.add(createContactNotificationTask(account));
                }
            }
            
            // Insert tasks
            if (!tasksToCreate.isEmpty()) {
                insert tasksToCreate;
                tasksCreated = tasksToCreate.size();
                System.debug('Created ' + tasksCreated + ' contact notification tasks');
            }
            
        } catch (Exception e) {
            System.debug('Error in createNotificationTasksForDueAccounts: ' + e.getMessage());
            System.debug('Stack: ' + e.getStackTraceString());
            throw new ContactNotificationException('Error creating notification tasks: ' + e.getMessage());
        }
        
        return tasksCreated;
    }
    
    /**
     * Create a single contact notification task for an account
     * @param account The account to create a task for
     * @return Task object (not inserted)
     */
    public static Task createContactNotificationTask(Account account) {
        return new Task(
            Subject = CONTACT_NOTIFICATION_SUBJECT,
            WhoId = null,
            WhatId = account.Id,
            OwnerId = account.OwnerId,
            ReminderDateTime = System.now().addDays(1),
            IsReminderSet = true,
            ActivityDate = System.today().addDays(1),
            Description = 'Plan a contact moment on short term with ' + account.Name
        );
    }
    
    /**
     * Mark a contact notification task as completed
     * @param taskId The ID of the task to complete
     */
    public static void completeNotificationTask(Id taskId) {
        try {
            Task task = new Task(Id = taskId, Status = 'Completed');
            update task;
            System.debug('Completed task: ' + taskId);
        } catch (DmlException e) {
            System.debug('Error completing task: ' + e.getMessage());
            throw new ContactNotificationException('Error completing task: ' + e.getMessage());
        }
    }
    
    /**
     * Get contact notification tasks for a user
     * @param userId The user ID
     * @return List of open contact notification tasks for the user
     */
    public static List<Task> getContactNotificationsForUser(Id userId) {
        TasksSelector tasksSelector = TasksSelector.newInstance();
        return tasksSelector.selectOpenContactNotificationTasksByUserId(userId);
    }
    
    /**
     * Get contact notification tasks for an account
     * @param accountId The account ID
     * @return List of open contact notification tasks for the account
     */
    public static List<Task> getContactNotificationsForAccount(Id accountId) {
        TasksSelector tasksSelector = TasksSelector.newInstance();
        return tasksSelector.selectOpenContactNotificationTasksByAccountId(accountId);
    }
    
    /**
     * Get all open contact notification tasks (admin use)
     * @return List of all open contact notification tasks
     */
    public static List<Task> getAllOpenContactNotifications() {
        TasksSelector tasksSelector = TasksSelector.newInstance();
        return tasksSelector.selectOpenContactNotificationTasks();
    }
    
    /**
     * Custom exception for ContactNotification errors
     */
    public class ContactNotificationException extends Exception {}
}
