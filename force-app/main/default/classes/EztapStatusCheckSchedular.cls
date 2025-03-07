public class EztapStatusCheckSchedular implements Schedulable {
    public string txnId;
    public EztapStatusCheckSchedular(string txnId){
        this.txnId = txnId;
    }
	public void execute(SchedulableContext sc) {
        EztapStatusCheck ob = new EztapStatusCheck(txnId);
        Database.executeBatch(ob);
    }
}