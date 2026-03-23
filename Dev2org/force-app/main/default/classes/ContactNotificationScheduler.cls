/**
 * Scheduler for ContactNotificationBatch to run daily
 */
global class ContactNotificationScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Run the batch job
        ContactNotificationBatch batch = new ContactNotificationBatch();
        Database.executeBatch(batch, 200);
    }
    
    /**
     * Method to schedule the job
     * Usage: ContactNotificationScheduler.scheduleDaily();
     */
    public static void scheduleDaily() {
        // Schedule to run every day at 8 AM
        String cronExpression = '0 0 8 * * ?';
        System.schedule('Contact Notification Batch - Daily', cronExpression, new ContactNotificationScheduler());
    }
    
    /**
     * Unschedule all Contact Notification jobs
     */
    public static void unscheduleDaily() {
        for (CronTrigger ct : [SELECT Id FROM CronTrigger 
                              WHERE CronJobDetail.Name = 'Contact Notification Batch - Daily']) {
            System.abortJob(ct.Id);
        }
    }
}
