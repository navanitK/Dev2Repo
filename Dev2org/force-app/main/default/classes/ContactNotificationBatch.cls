/**
 * Batch job to create contact notification tasks for accounts due for contact moments
 * Runs daily to check if accounts haven't been contacted in the past 6 months
 * 
 * Uses ContactNotificationService for business logic and AccountsSelector/TasksSelector for data access
 */
global class ContactNotificationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global Integer recordsProcessed = 0;
    global Integer tasksCreated = 0;
    
    /**
     * Get all accounts that are due for contact moment
     * Delegates to AccountsSelector via service
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        AccountsSelector selector = AccountsSelector.newInstance();
        return selector.selectAccountsDueForContactQueryLocator();
    }
    
    /**
     * Process each batch of accounts and create notification tasks
     * Delegates to ContactNotificationService for all business logic
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (scope.isEmpty()) {
            return;
        }
        
        try {
            // Convert SObject list to Account list
            List<Account> accounts = new List<Account>();
            for (SObject obj : scope) {
                accounts.add((Account)obj);
            }
            
            // Process accounts through service
            Integer created = processAccountsForNotifications(accounts);
            tasksCreated += created;
            recordsProcessed += scope.size();
            
        } catch (Exception e) {
            System.debug('Error in batch execute: ' + e.getMessage());
            System.debug('Stack: ' + e.getStackTraceString());
        }
    }
    
    /**
     * Process accounts and create notification tasks
     * @param accounts List of accounts to process
     * @return Number of tasks created
     */
    private Integer processAccountsForNotifications(List<Account> accounts) {
        Integer tasksCreated = 0;
        
        try {
            // Get selector instances
            TasksSelector tasksSelector = TasksSelector.newInstance();
            
            // Extract account IDs
            Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();
            
            // Get existing open notification tasks for these accounts
            List<Task> existingTasks = tasksSelector.selectOpenContactNotificationTasksByAccountIds(accountIds);
            Set<Id> accountsWithExistingTasks = new Set<Id>();
            
            for (Task task : existingTasks) {
                accountsWithExistingTasks.add(task.WhatId);
            }
            
            // Create tasks for accounts without existing notification tasks
            List<Task> tasksToCreate = new List<Task>();
            
            for (Account account : accounts) {
                if (!accountsWithExistingTasks.contains(account.Id)) {
                    tasksToCreate.add(ContactNotificationService.createContactNotificationTask(account));
                }
            }
            
            // Insert tasks
            if (!tasksToCreate.isEmpty()) {
                insert tasksToCreate;
                tasksCreated = tasksToCreate.size();
                System.debug('Batch created ' + tasksCreated + ' contact notification tasks');
            }
            
        } catch (DmlException e) {
            System.debug('Error creating tasks: ' + e.getMessage());
        }
        
        return tasksCreated;
    }
    
    /**
     * Send completion notification
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('ContactNotificationBatch completed. Records processed: ' + recordsProcessed + 
                     ', Tasks created: ' + tasksCreated);
        
        // Optional: Send email notification
        // ContactNotificationBatch.sendCompletionEmail(recordsProcessed, tasksCreated);
    }
    
    /**
     * Optional method to send completion email
     */
    private static void sendCompletionEmail(Integer processed, Integer created) {
        // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // email.setToAddresses(new String[]{UserInfo.getUserEmail()});
        // email.setSubject('Contact Notification Batch Job Complete');
        // email.setPlainTextBody('Processed ' + processed + ' accounts and created ' + created + ' tasks.');
        // Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}
