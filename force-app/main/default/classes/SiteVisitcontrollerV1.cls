public class SiteVisitcontrollerV1 {
    public PropStrength__Request__c sv {get;set;}
    public String strError {get;set;}
    public String strSuccess {get;set;}
    public Contact cont {get;set;}
    public Boolean disableBrokerAcc {get;set;}
    public Boolean disableBrokerCont {get;set;}
    public String brkAccName {get;set;}
    public String brkContName {get;set;}
    
    public SiteVisitcontrollerV1 () {
        sv = new PropStrength__Request__c ();
        cont = new Contact();
        disableBrokerAcc = true;
        disableBrokerCont = true;
        brkContName = '';
        brkAccName = '';
        if (Apexpages.Currentpage().getParameters().get('EnquiryId') != null && Apexpages.Currentpage().getParameters().get('EnquiryId') != '') {
            sv.Id = Apexpages.Currentpage().getParameters().get('EnquiryId');
            sv = [SELECT Id, PropStrength__Broker_Account__c, PropStrength__Broker_Contact__r.Name, PropStrength__Broker_Account__r.Name, PropStrength__Broker_Contact__c, Visiting_With__c, Configuration_SM__c, SM_Feedback_Given__c, Budget_In_Mn__c, Sales_Manager_Feedback__c, Site_Visit_Rating__c, Visit_Next_Action__c, SM_Next_Action_Date__c, Possession_Timeline__c, Indicative_Budget_In_Mn__c, Product__c, Type__c, Project_Name__c, PropStrength__Primary_Contact__c, PropStrength__Project__r.Name, PropStrength__Primary_Contact__r.FirstName, PropStrength__Primary_Contact__r.LastName, PropStrength__Primary_Contact__r.Email, PropStrength__Primary_Contact__r.MobilePhone, PropStrength__Request_Source__c, Enquiry_Sub_Source__c, Purpose_Of_Purchase__c, Existing_Sobha_Owner__c, Visiting_On_Behalf_Of__c, How_Did_You_Hear_About_Us__c, Unit_Number__c, Sub_Source__c, Name_of_Person__c, Channel_Partner__c, Employee_Id__c, Channel_Partner_Contact_Person__c, Sobha_Connect__c FROM PropStrength__Request__c WHERE Id = :sv.Id];
            if(sv.PropStrength__Request_Source__c == 'Channel Partner') {
                disableBrokerAcc = false;
                disableBrokerCont = false;
                brkContName = sv.PropStrength__Broker_Contact__r.Name;
                brkAccName = sv.PropStrength__Broker_Account__r.Name;
            } else {
                disableBrokerAcc = true;
                disableBrokerCont = true;
                brkContName = '';
                brkAccName = '';
            }
        }
        if (Apexpages.Currentpage().getParameters().get('projectId') != null && Apexpages.Currentpage().getParameters().get('projectId') != '')
            sv.PropStrength__Project__c = Apexpages.Currentpage().getParameters().get('projectId');
        if (Apexpages.Currentpage().getParameters().get('Email') != null && Apexpages.Currentpage().getParameters().get('Email') != '')
            cont.Email = Apexpages.Currentpage().getParameters().get('Email');
        if (Apexpages.Currentpage().getParameters().get('mobilePhone') != null && Apexpages.Currentpage().getParameters().get('mobilePhone') != '')
            cont.MobilePhone = Apexpages.Currentpage().getParameters().get('mobilePhone');
        if (Apexpages.Currentpage().getParameters().get('contId') != null && Apexpages.Currentpage().getParameters().get('contId') != '') {
            sv.PropStrength__Primary_Contact__c = Apexpages.Currentpage().getParameters().get('contId');
            cont = [SELECT Id, Email, MobilePhone, FirstName, LastName FROM Contact WHERE Id = :sv.PropStrength__Primary_Contact__c];
        }
        if (Apexpages.Currentpage().getParameters().get('enqSource') != null && Apexpages.Currentpage().getParameters().get('enqSource') != '') {
            sv.PropStrength__Request_Source__c = Apexpages.Currentpage().getParameters().get('enqSource');
        }
        
    }
    
    public PageReference save() {
        if(cont.LastName == null || cont.LastName == '') {
            strError = 'Please Enter Last Name Under Customer Details Section';
            return null;
        } else {
            try {
                System.debug(sv);
                System.debug(cont);
                upsert cont;
                sv.PropStrength__Primary_Contact__c = cont.Id;
                upsert sv;
                strSuccess = 'Successfully!! Record Updated.';
                strError = '';
                return new PageReference('/'+sv.Id);
            } catch(Exception e) {
                strError = 'Error!! '+e.getMessage();
                strSuccess = '';
                return null;
            }
        }
    }

    public void handleEnqSourceChange() {
        System.debug(sv.PropStrength__Request_Source__c);
        if(sv.PropStrength__Request_Source__c == 'Channel Partner') {
            disableBrokerAcc = false;
            disableBrokerCont = false;
        } else {
            disableBrokerAcc = true;
            disableBrokerCont = true;
        }
    }
}