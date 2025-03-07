global class DocusignEnvelopeVoidSCh1 Implements Schedulable{
     global void execute(SchedulableContext sc) {
        Database.executeBatch(new DocusignEnvelopeVoidBatch2(),1);
    }

}