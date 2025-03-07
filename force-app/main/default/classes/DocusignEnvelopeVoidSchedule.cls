Global class DocusignEnvelopeVoidSchedule Implements Schedulable{
     global void execute(SchedulableContext sc) {
        Database.executeBatch(new DocusignEnvelopeVoidBatch(),1);
    }

}