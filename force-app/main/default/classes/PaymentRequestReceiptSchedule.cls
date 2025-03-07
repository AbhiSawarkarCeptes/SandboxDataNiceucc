global class PaymentRequestReceiptSchedule  Implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        if (!isJobAlreadyRunning()) {
            Database.executeBatch(new PaymentRequestReceiptCreation());
        } else {
            System.debug('Previous job is still running, skipping this run.');
        }
    }

    private Boolean isJobAlreadyRunning() {
        List<AsyncApexJob> runningJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Processing' AND ApexClass.Name = 'PaymentRequestReceiptCreation' ];
        return runningJobs.size() > 0;
    }

}