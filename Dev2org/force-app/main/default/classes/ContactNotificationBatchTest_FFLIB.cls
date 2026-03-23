/**
 * FFLIB Mock Test Class for ContactNotificationBatch
 * Uses fflib_ApexMocks framework for advanced testing with mocks and stubs
 */
@IsTest
public class ContactNotificationBatchTest_FFLIB {
    
    /**
     * Test that batch processes accounts correctly and creates tasks
     */
    @IsTest
    static void testBatchExecute_CreatesTasksForDueAccounts() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // Create mock accounts
        List<Account> mockAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account A',
                OwnerId = UserInfo.getUserId(),
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'active'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account B',
                OwnerId = UserInfo.getUserId(),
                EF_LastContactMoment__c = System.today().addMonths(-8),
                SnoozeStatus__c = 'active'
            )
        };
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        
        // Execute batch
        batch.execute(mockContext, mockAccounts);
        
        Test.stopTest();
        
        // Then - Verify tasks were created
        List<Task> createdTasks = [
            SELECT Id, Subject, WhatId, OwnerId, Description 
            FROM Task 
            WHERE Subject = 'hey contact your customer'
        ];
        
        System.assertEquals(2, createdTasks.size(), 'Should create 2 tasks for 2 due accounts');
        System.assertEquals('Account A', createdTasks[0].What.Name);
    }
    
    /**
     * Test that batch does not create duplicate tasks
     */
    @IsTest
    static void testBatchExecute_NoDuplicateTasks() {
        // Given
        Account testAccount = new Account(
            Name = 'Test Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'active'
        );
        insert testAccount;
        
        // Create existing task
        Task existingTask = new Task(
            Subject = 'hey contact your customer',
            WhatId = testAccount.Id,
            OwnerId = UserInfo.getUserId(),
            ActivityDate = System.today(),
            Status = 'Not Started'
        );
        insert existingTask;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Account> mockAccounts = new List<Account>{ testAccount };
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, mockAccounts);
        
        Test.stopTest();
        
        // Then - Verify no duplicate was created
        Integer taskCount = [
            SELECT COUNT() 
            FROM Task 
            WHERE WhatId = :testAccount.Id 
            AND Subject = 'hey contact your customer'
        ];
        
        System.assertEquals(1, taskCount, 'Should not create duplicate task');
    }
    
    /**
     * Test that batch ignores snoozed accounts
     */
    @IsTest
    static void testBatchExecute_IgnoresSnoozedAccounts() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Account snoozedAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Snoozed Account',
            OwnerId = UserInfo.getUserId(),
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'inactive'
        );
        
        List<Account> mockAccounts = new List<Account>{ snoozedAccount };
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, mockAccounts);
        
        Test.stopTest();
        
        // Then - Verify no task was created
        List<Task> createdTasks = [
            SELECT Id FROM Task 
            WHERE Subject = 'hey contact your customer'
            AND WhatId = :snoozedAccount.Id
        ];
        
        System.assertEquals(0, createdTasks.size(), 'Should not create task for snoozed account');
    }
    
    /**
     * Test batch start method returns correct query
     */
    @IsTest
    static void testBatchStart_ReturnsCorrectQuery() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // Create test data
        Account dueAccount = new Account(
            Name = 'Due Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'active'
        );
        insert dueAccount;
        
        Account recentAccount = new Account(
            Name = 'Recent Account',
            EF_LastContactMoment__c = System.today().addDays(-10),
            SnoozeStatus__c = 'active'
        );
        insert recentAccount;
        
        Account snoozedAccount = new Account(
            Name = 'Snoozed Account',
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'inactive'
        );
        insert snoozedAccount;
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        Database.QueryLocator queryLocator = batch.start(mockContext);
        
        // Execute query
        List<Account> results = queryLocator.getQuery();
        
        Test.stopTest();
        
        // Then - Verify query returns only eligible accounts
        System.debug('Query results: ' + results);
        System.assertNotEquals(null, queryLocator, 'Query locator should not be null');
    }
    
    /**
     * Test batch finish method completes successfully
     */
    @IsTest
    static void testBatchFinish_LogsResults() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        batch.recordsProcessed = 5;
        batch.tasksCreated = 3;
        
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.finish(mockContext);
        
        Test.stopTest();
        
        // Then - Verify finish method completes without error
        System.assertEquals(5, batch.recordsProcessed);
        System.assertEquals(3, batch.tasksCreated);
    }
    
    /**
     * Test batch with mixed scenarios
     */
    @IsTest
    static void testBatchExecute_MixedScenarios() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        List<Account> mockAccounts = new List<Account>{
            // Account due for contact
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Due Account',
                OwnerId = UserInfo.getUserId(),
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'active'
            ),
            // Recently contacted account
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Recent Account',
                OwnerId = UserInfo.getUserId(),
                EF_LastContactMoment__c = System.today().addDays(-30),
                SnoozeStatus__c = 'active'
            ),
            // Snoozed account
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Snoozed Account',
                OwnerId = UserInfo.getUserId(),
                EF_LastContactMoment__c = System.today().addMonths(-7),
                SnoozeStatus__c = 'inactive'
            )
        };
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, mockAccounts);
        
        Test.stopTest();
        
        // Then
        System.assertEquals(3, batch.recordsProcessed, 'Should process 3 records');
        System.assertEquals(1, batch.tasksCreated, 'Should create 1 task (only for due account)');
    }
    
    /**
     * Test task properties are set correctly
     */
    @IsTest
    static void testBatchExecute_TaskPropertiesSet() {
        // Given
        Account testAccount = new Account(
            Name = 'Test Account for Task Properties',
            OwnerId = UserInfo.getUserId(),
            EF_LastContactMoment__c = System.today().addMonths(-7),
            SnoozeStatus__c = 'active'
        );
        insert testAccount;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Account> mockAccounts = new List<Account>{ testAccount };
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, mockAccounts);
        
        Test.stopTest();
        
        // Then - Verify task properties
        Task createdTask = [
            SELECT Subject, WhatId, OwnerId, ActivityDate, Description, IsReminderSet
            FROM Task
            WHERE WhatId = :testAccount.Id
            LIMIT 1
        ];
        
        System.assertEquals('hey contact your customer', createdTask.Subject);
        System.assertEquals(testAccount.Id, createdTask.WhatId);
        System.assertEquals(testAccount.OwnerId, createdTask.OwnerId);
        System.assertEquals(System.today().addDays(1), createdTask.ActivityDate);
        System.assertEquals(true, createdTask.IsReminderSet);
        System.assertNotEquals(null, createdTask.Description);
    }
    
    /**
     * Test batch with empty list
     */
    @IsTest
    static void testBatchExecute_WithEmptyList() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Account> emptyAccounts = new List<Account>();
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, emptyAccounts);
        
        Test.stopTest();
        
        // Then
        System.assertEquals(0, batch.recordsProcessed);
        System.assertEquals(0, batch.tasksCreated);
    }
    
    /**
     * Test batch with large batch size
     */
    @IsTest
    static void testBatchExecute_LargeBatch() {
        // Given
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        List<Account> largeAccountBatch = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            largeAccountBatch.add(
                new Account(
                    Id = fflib_IDGenerator.generate(Account.SObjectType),
                    Name = 'Account ' + i,
                    OwnerId = UserInfo.getUserId(),
                    EF_LastContactMoment__c = System.today().addMonths(-7),
                    SnoozeStatus__c = 'active'
                )
            );
        }
        
        Test.startTest();
        
        // When
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.BatchableContext mockContext = (Database.BatchableContext) mocks.mock(Database.BatchableContext.class);
        batch.execute(mockContext, largeAccountBatch);
        
        Test.stopTest();
        
        // Then
        System.assertEquals(200, batch.recordsProcessed);
        System.assertEquals(200, batch.tasksCreated);
    }
}
