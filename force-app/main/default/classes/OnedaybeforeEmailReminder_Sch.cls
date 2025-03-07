global class OnedaybeforeEmailReminder_Sch implements Schedulable {
   
    public void execute(SchedulableContext sc)
    {      
       OnedaybeforeEmailReminder batch = new OnedaybeforeEmailReminder();
       Database.executeBatch(batch,20);
    }
    
}