public class SendLatePaymentFee implements Queueable {
    public Set<Id> payIdset;

    public SendLatePaymentFee(Set<Id> payIds) {
        this.payIdset = payIds;
    }
    
    public void execute(QueueableContext context) {
        SendLateDemandLetter.sendMail(payIdSet);
    }
}