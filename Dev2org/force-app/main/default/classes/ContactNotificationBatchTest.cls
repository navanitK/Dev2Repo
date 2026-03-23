@isTest
public class ContactNotificationBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        
        // Account 1: Due for contact (not contacted in 6+ months, active)
        Account accDue = new Account(
            Name = 'Due Contact Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'active'
        );
        accounts.add(accDue);
        
        // Account 2: Not due (contacted recently)
        Account accRecent = new Account(
            Name = 'Recent Contact Account',
            EF_LastContactMoment__c = System.today().addMonths(-2),
            SnoozeStatus__c = 'active'
        );
        accounts.add(accRecent);
        
        // Account 3: Snoozed (should not create task)
        Account accSnoozed = new Account(
            Name = 'Snoozed Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'inactive'
        );
        accounts.add(accSnoozed);
        
        insert accounts;
    }
    
    @isTest
    static void testBatchCreatesNotificationTasks() {
        Test.startTest();
        
        // Run the batch
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Verify task was created for due account only
        List<Task> tasks = [SELECT WhatId, Subject, OwnerId 
                           FROM Task 
                           WHERE Subject = 'hey contact your customer'];
        
        System.assertEquals(1, tasks.size(), 'Should create one task for the due account');
        
        // Verify the task relates to the correct account
        Account dueAccount = [SELECT Id FROM Account WHERE Name = 'Due Contact Account'];
        System.assertEquals(dueAccount.Id, tasks[0].WhatId, 'Task should relate to due account');
    }
    
    @isTest
    static void testBatchDoesNotCreateDuplicateTasks() {
        // Create a task manually first
        Account dueAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Due Contact Account'];
        
        Task existingTask = new Task(
            Subject = 'hey contact your customer',
            WhatId = dueAccount.Id,
            OwnerId = dueAccount.OwnerId,
            ActivityDate = System.today()
        );
        insert existingTask;
        
        Test.startTest();
        
        // Run the batch
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Verify no additional task was created
        List<Task> tasks = [SELECT Id FROM Task 
                           WHERE WhatId = :dueAccount.Id 
                           AND Subject = 'hey contact your customer'];
        
        System.assertEquals(1, tasks.size(), 'Should not create duplicate task');
    }
    
    @isTest
    static void testBatchAssignsToAccountOwner() {
        Test.startTest();
        
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        Account dueAccount = [SELECT OwnerId FROM Account WHERE Name = 'Due Contact Account'];
        Task task = [SELECT OwnerId FROM Task WHERE Subject = 'hey contact your customer' LIMIT 1];
        
        System.assertEquals(dueAccount.OwnerId, task.OwnerId, 'Task should be assigned to account owner');
    }
    
    @isTest
    static void testBatchIgnoresSnoozedAccounts() {
        Test.startTest();
        
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        Account snoozedAccount = [SELECT Id FROM Account WHERE Name = 'Snoozed Account'];
        
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :snoozedAccount.Id];
        
        System.assertEquals(0, tasks.size(), 'Should not create task for snoozed account');
    }
}
