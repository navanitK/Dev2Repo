/**
 * Unit tests for ContactNotificationService
 * Tests business logic layer
 */
@isTest
public class ContactNotificationServiceTest {
    
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'Due Contact Account',
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'active'
            ),
            new Account(
                Name = 'Recent Contact Account',
                EF_LastContactMoment__c = System.today().addMonths(-2),
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
    static void testCreateNotificationTasksForDueAccounts() {
        Test.startTest();
        
        Integer tasksCreated = ContactNotificationService.createNotificationTasksForDueAccounts();
        
        Test.stopTest();
        
        System.assertEquals(1, tasksCreated, 'Should create 1 task for due account');
        
        List<Task> tasks = [SELECT Subject FROM Task WHERE Subject = 'hey contact your customer'];
        System.assertEquals(1, tasks.size());
    }
    
    @isTest
    static void testCreateContactNotificationTask() {
        Account testAccount = [SELECT Id, OwnerId, Name FROM Account WHERE Name = 'Due Contact Account'];
        
        Test.startTest();
        
        Task task = ContactNotificationService.createContactNotificationTask(testAccount);
        
        Test.stopTest();
        
        System.assertEquals('hey contact your customer', task.Subject);
        System.assertEquals(testAccount.Id, task.WhatId);
        System.assertEquals(testAccount.OwnerId, task.OwnerId);
        System.assertNotEquals(null, task.ActivityDate);
    }
    
    @isTest
    static void testCompleteNotificationTask() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Due Contact Account'];
        
        Task task = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            ActivityDate = System.today()
        );
        insert task;
        
        Test.startTest();
        
        ContactNotificationService.completeNotificationTask(task.Id);
        
        Test.stopTest();
        
        Task completedTask = [SELECT Status FROM Task WHERE Id = :task.Id];
        System.assertEquals('Completed', completedTask.Status);
    }
    
    @isTest
    static void testGetContactNotificationsForUser() {
        Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Due Contact Account'];
        
        Task task = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            OwnerId = testAccount.OwnerId,
            ActivityDate = System.today(),
            Status = 'Not Started'
        );
        insert task;
        
        Test.startTest();
        
        List<Task> tasks = ContactNotificationService.getContactNotificationsForUser(testAccount.OwnerId);
        
        Test.stopTest();
        
        System.assertEquals(1, tasks.size());
        System.assertEquals(task.Id, tasks[0].Id);
    }
    
    @isTest
    static void testGetContactNotificationsForAccount() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Due Contact Account'];
        
        Task task = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            ActivityDate = System.today(),
            Status = 'Not Started'
        );
        insert task;
        
        Test.startTest();
        
        List<Task> tasks = ContactNotificationService.getContactNotificationsForAccount(testAccount.Id);
        
        Test.stopTest();
        
        System.assertEquals(1, tasks.size());
        System.assertEquals(testAccount.Id, tasks[0].WhatId);
    }
    
    @isTest
    static void testGetAllOpenContactNotifications() {
        Account testAccount = [SELECT Id, OwnerId FROM Account WHERE Name = 'Due Contact Account'];
        
        List<Task> tasksToCreate = new List<Task>{
            new Task(
                Subject = 'hey contact your customer',
                WhatId = testAccount.Id,
                OwnerId = testAccount.OwnerId,
                ActivityDate = System.today()
            ),
            new Task(
                Subject = 'hey contact your customer',
                WhatId = testAccount.Id,
                OwnerId = testAccount.OwnerId,
                ActivityDate = System.today().addDays(1)
            )
        };
        insert tasksToCreate;
        
        Test.startTest();
        
        List<Task> allTasks = ContactNotificationService.getAllOpenContactNotifications();
        
        Test.stopTest();
        
        System.assertEquals(2, allTasks.size());
    }
}
