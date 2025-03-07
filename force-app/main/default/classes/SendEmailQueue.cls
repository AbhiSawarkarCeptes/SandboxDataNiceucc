public class SendEmailQueue implements Queueable {
    public Set<Id> payIdset;

    public SendEmailQueue(Set<Id> payIds) {
        this.payIdset = payIds;
    }
    
    public void execute(QueueableContext context) {
        SendDemandLetter.sendMail(payIdSet);
    }
}