global class ConfirmNoOfMeetingBatch Implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        findEvents();   
    }
    
    public void findEvents(){
        DateTime days15DateTime = System.today().addDays(15);
        Date days15Date = Date.newInstance(days15DateTime.year(), days15DateTime.month(), days15DateTime.day());
        List<Events__c> listOfEvents = [select Id,Name,Date_of_Proposal__c,Date_Of_Event__c,End_Date_Of_Event__c,City_Country__c,Country__c,Start_Time_of_the_Event__c,End_Time_of_the_Event__c,Confirmed_No_of_Meeting__c,Channel_Relationship_Manager__c,Channel_Relationship_Manager__r.Email from Events__c where Date_Of_Event__c =: days15Date]; 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Events__c e : listOfEvents){
            if(e.Channel_Relationship_Manager__c != null){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();  
                email.setSubject('Reminder to update Confirmed No. Of Meeting');
                email.setToAddresses(new List<string>{e.Channel_Relationship_Manager__r.Email});
                
                string dateOfProposal = (e.Date_of_Proposal__c!=null)?e.Date_of_Proposal__c.format():'';
                string startDate = (e.Date_Of_Event__c!=null)?e.Date_Of_Event__c.format():'';
                string endDate = (e.End_Date_Of_Event__c!=null)?e.End_Date_Of_Event__c.format():'';
                
                string htmlBody = 'Kind Attention,<br/><br/>';
                htmlBody = htmlBody + 'Following event is due in 15 days, please update Confirmed No. Of Meeting on priority.<br/><br/>';
                htmlBody = htmlBody + '<table border="1" style="border-collapse: collapse">';
                htmlBody = htmlBody + '<tr><td>' + 'Event Name' + '</td><td>' + e.Name + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'Date of Proposal' + '</td><td>' + dateOfProposal + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'Start Date of the Event' + '</td><td>' + startDate + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'End Date of the Event' + '</td><td>' + endDate + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'Start Time of the Event' + '</td><td>' + e.Start_Time_of_the_Event__c + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'End Time of the Event' + '</td><td>' + e.End_Time_of_the_Event__c + '</td></tr>';
                htmlBody = htmlBody + '<tr><td>' + 'City & Country' + '</td><td>' + e.City_Country__c + ', ' + e.Country__c + '</td></tr>';
                htmlBody += '</table><br/><br/>';
                htmlBody += 'Regards,<br/>';
                htmlBody += 'Salesforce Team.';
                
                email.setHtmlBody(htmlBody);
                emails.add(email);
            }
        }
        if(emails.size()>0){
            Messaging.sendEmail(emails);
        }
    }
}