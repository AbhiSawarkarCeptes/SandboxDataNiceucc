public class TestDataFactorySobha {
    public static String recordTypeName;
    public static String offerThrough;
    public static String incSlabMarketCategory;
    public static String bookingStatus;
    public static String bookingThrough;
    public static String addBrokerSlabType;
    public static String milestoneType;
    public static String paymentAmountDueType;
    public static String docusignEnvelopeStatus;
    public static String docusignEnvelopeType;
    public static String enquiryStatus;
    public static String assignmentGroupName;
    public static Integer groupOrder;

    public static Account createAccount(Id accId) {
        User testUserRec = [SELECT Id FROM User LIMIT 1];
        recordTypeName = recordTypeName != null ? recordTypeName : 'Broker';
        
        Account acc = new Account();
        if(accId != null) {
            acc.Id = accId;
        }
        acc.Name = 'Test Account Record';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        acc.PropStrength__Broker_Type__c ='Standard';
        acc.Broker_Category__c = 'Individual';
        acc.Name_as_per_passport__c = 'passportName';
        acc.Registration_Passport_Number__c = '123'+String.valueOf(Math.random()).substring(0,5);
        acc.TRN_Number__c ='456'+Math.random();
        acc.Channel_Relationship_Manager__c = testUserRec.id;
        acc.Sales_Manager_User__c = testUserRec.id;
        acc.PropStrength__Broker_Approval_Status__c = 'All Missing Documents Uploaded';
        
        recordTypeName = null;
        
        return acc;
    }
    
    public static User createUser(Id userId) {
        Profile prof = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        
        User testUserRec = new User();
        if(userId != null) {
            testUserRec.Id = userId;
        }
        testUserRec.Alias = 'standard';
        testUserRec.Email='testUser111A@'+Math.random()+'testorganise.com';  
        testUserRec.EmailEncodingKey='UTF-8';
        testUserRec.LastName='Testing11';
        testUserRec.LanguageLocaleKey='en_US'; 
        testUserRec.LocaleSidKey='en_US';
        testUserRec.ProfileId = prof.Id;
        testUserRec.IsActive=true;
        testUserRec.TimeZoneSidKey='America/Los_Angeles'; 
        testUserRec.UserName='testUser111A@'+Math.random()+'testorganise.com'; 
        return testUserRec;
    }
    
    public static Contact createContact(Id contId) {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        Contact contRec = new Contact();
        if(contId != null) {
            contRec.Id = contId;
        }
        contRec.FirstName = 'Test' + DateTime.now();
        contRec.LastName = 'Contact Record';
        contRec.PropStrength__Resident_Status__c = 'Resident Citizen';
        contRec.Emirates_ID__c = '784-1234-1111111-1';
        contRec.Email = 'test@test'+String.valueOf(Math.random()).substring(0,5)+'123.com';
        contRec.AccountId = accRec.Id;
        
        return contRec;
    }

    public static PropStrength__Assignment_Group_Name__c createAssignmentGroup(Id assGrpId) {
        assignmentGroupName = assignmentGroupName != null ? assignmentGroupName : 'Arabic';
        
        PropStrength__Assignment_Group_Name__c assignmentGroupRec = new PropStrength__Assignment_Group_Name__c();
        if(assGrpId != null) {
            assignmentGroupRec.Id = assGrpId;
        }
        assignmentGroupRec.Name = assignmentGroupName;
        assignmentGroupRec.PropStrength__Active__c = true;

        assignmentGroupName = null;
        
        return assignmentGroupRec;
    }

    public static PropStrength__Group_Member__c createAssignmentGroupMember(Id assGrpMemId) {
        PropStrength__Assignment_Group_Name__c assGrp = [SELECT Id FROM PropStrength__Assignment_Group_Name__c LIMIT 1];
        
        PropStrength__Group_Member__c assignmentGroupMemberRec = new PropStrength__Group_Member__c();
        if(assignmentGroupMemberRec != null) {
            assignmentGroupMemberRec.Id = assGrpMemId;
        }
        assignmentGroupMemberRec.PropStrength__User__c = UserInfo.getUserId();
        assignmentGroupMemberRec.PropStrength__Order__c = groupOrder;
        assignmentGroupMemberRec.PropStrength__Active__c = 'TRUE';
        assignmentGroupMemberRec.PropStrength__Assignment_Group__c = assGrp.Id;
        
        groupOrder = null;
        
        return assignmentGroupMemberRec;
    }
    
    public static PropStrength__Request__c createEnquiry(Id enqId) {
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        List<PropStrength__Assignment_Group_Name__c> assGrp = [SELECT Id FROM PropStrength__Assignment_Group_Name__c LIMIT 1];

        enquiryStatus = enquiryStatus != null ? enquiryStatus : 'Open';
        
        PropStrength__Request__c enqRec = new PropStrength__Request__c();
        if(enqId != null) {
            enqRec.Id = enqId;
        }
        enqRec.PropStrength__Primary_Contact__c = contRec.Id;
        enqRec.Sales_Head__c = UserInfo.getUserId();
        enqRec.Sales_SVP__c = UserInfo.getUserId();
        enqRec.Sales_VP__c = UserInfo.getUserId();
        enqRec.PropStrength__Request_Status__c = enquiryStatus;
        if(!assGrp.isEmpty()){
            enqRec.Assignment_Group__c = assGrp[0].Id;
        }

        enquiryStatus = null;
        
        return enqRec;
    }
    
    public static PropStrength__Projects__c createProject(Id projId) {
        PropStrength__Projects__c projRec = new PropStrength__Projects__c();
        if(projId != null) {
            projRec.Id = projId;
        }
        projRec.Name = 'Test Project'+String.valueOf(Math.random()).substring(0,5);
        projRec.PropStrength__Active__c = true;
        projRec.T_link_Demand_Days__c = 1;
        projRec.Grace_Days_Time_Linked__c = 5;
        projRec.Grace_Days__c = 5;
        projRec.PropStrength__Active__c = true;
        return projRec;
    }
    
    public static PropStrength__Property_Type__c createPropertyType(Id propTypeId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Property_Type__c propTypeRec = new PropStrength__Property_Type__c();
        if(propTypeId != null) {
            propTypeRec.Id = propTypeId;
        }
        propTypeRec.PropStrength__Project__c = projRec.Id;
        propTypeRec.PropStrength__Active__c = true;
        propTypeRec.PropStrength__Area__c = 5000;
        propTypeRec.PropStrength__Pricing_Expire__c = false;
        propTypeRec.PropStrength__Property_Type_Code__c = '3 BR Zazen'+String.valueOf(Math.random()).substring(0,5);
        
        return propTypeRec;
    }
    
    public static PropStrength__Tower__c createTower(Id towerId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Tower__c towerRec = new PropStrength__Tower__c();
        if(towerId != null) {
            towerRec.Id = towerId;
        }
        towerRec.PropStrength__Tower_Name__c = 'T1 P1 Tower';
        towerRec.PropStrength__Project_Name__c =  projRec.Id;
        towerRec.PropStrength__Tower_Code__c = 'A1'+Math.random();
        towerRec.CRM_Executive__c = UserInfo.getUserId();
        
        return towerRec;
    }
    
    public static PropStrength__Property__c createProperty(Id propId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Property_Type__c propTypeRec = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Tower__c towerRec = [SELECT Id FROM PropStrength__Tower__c LIMIT 1];
        
        recordTypeName = recordTypeName != null ? recordTypeName : 'Apartment';
        
        PropStrength__Property__c propRec = new PropStrength__Property__c();
        if(propId != null) {
            propRec.Id = propId;
        }
        propRec.Plot_Location_Plan_Uploaded__c =  System.Today();
        propRec.Master_Plan_Uploaded__c = System.Today();
        propRec.PropStrength__Tower__c = towerRec.Id;
        propRec.Annexure_Document_Uploaded__c = System.Today();
        propRec.Requisite_Hold_Payment_Type__c = 'Amount';
        propRec.Requisite_Hold_Payment__c = 1000;
        propRec.RecordTypeId = Schema.SObjectType.PropStrength__Property__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        propRec.PropStrength__Property_Type__c = propTypeRec.Id;
        propRec.PropStrength__Project_Name__c = projRec.Id;
        propRec.PropStrength__Active__c = true;
        
        recordTypeName = null;
        
        return propRec;
    }
    
    public static PropStrength__Payment_Plan__c createPaymentPlan(Id ppId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Payment_Plan__c ppdRec = new PropStrength__Payment_Plan__c();
        if(ppId != null) {
            ppdRec.Id = ppId;
        }
        ppdRec.PropStrength__Project__c = projRec.Id; 
        ppdRec.PropStrength__Payment_Plan_Code__c ='Test Plan123'+Math.random();
        ppdRec.PropStrength__Active__c = true;
        ppdRec.Name = 'Test Plan';
        
        return ppdRec;
    }
    
    public static PropStrength__Offer__c createOffer(Id offerId) {
        offerThrough = offerThrough != null ? offerThrough : 'Direct';
        
        PropStrength__Request__c enqRec = [SELECT Id FROM PropStrength__Request__c LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Property_Type__c propTypeRec = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Property__c propRec = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        PropStrength__Payment_Plan__c ppdRec = [SELECT Id FROM PropStrength__Payment_Plan__c LIMIT 1];
        
        PropStrength__Offer__c offerRec = new PropStrength__Offer__c();
        if(offerId != null) {
            offerRec.Id = offerId;
        }
        offerRec.PropStrength__Request__c = enqRec.Id;
        offerRec.PropStrength__Offer_Through__c = offerThrough;
        offerRec.PropStrength__Payment_Plan__c = ppdRec.Id;
        offerRec.PropStrength__Is_Brokrage_Calculated__c = true;
        offerRec.PropStrength__Transaction__c= true;
        offerRec.PropStrength__Project__c = projRec.Id;
        offerRec.PropStrength__Property__c = propRec.Id;
        offerRec.PropStrength__Property_Type__c = propTypeRec.Id;
        offerRec.PropStrength__Primary_Contact__c = contRec.Id;
        offerRec.Deviation_on_Payment_Plan__c = true;
        offerRec.Sales_Head__c = UserInfo.getUserId();
        offerRec.Sales_SVP__c = UserInfo.getUserId();
        offerRec.Sales_VP__c = UserInfo.getUserId();

        offerThrough = null;
        
        return offerRec;
    }
    
    public static Incentive_Slab__c createIncentiveSlab(Id incSlabId) {
        recordTypeName = recordTypeName != null ? recordTypeName : 'Sales Manager Incentive';
        incSlabMarketCategory = incSlabMarketCategory != null ? incSlabMarketCategory : 'Loyalty Sales';
        
        Incentive_Slab__c incSlabRec = new Incentive_Slab__c();
        if(incSlabId != null) {
            incSlabRec.Id = incSlabId;
        }
        incSlabRec.Indirect_Sales__c=10;
        incSlabRec.Direct_Sales__c=10;
        incSlabRec.Approved_Discount_Sales__c=10;
        incSlabRec.Loyalty_Sales__c = 10;
        incSlabRec.Intl_Broker_New_Customer_Inc__c = 10;
        incSlabRec.TL_Channel_Relation_Split__c = 10;
        incSlabRec.RM_Channel_Split__c = 10;
        incSlabRec.VP_Channel_Relations_Split__c = 10;
        incSlabRec.Sobha_Connect_UAE_Old_Inc__c = 10;
        incSlabRec.Sobha_Connect_UAE_New_Inc__c = 10;
        incSlabRec.Intl_Broker_Old_Customer_Inc__c = 10;
        incSlabRec.Marketing_Category__c = incSlabMarketCategory;
        incSlabRec.Marketing_Incentive__c = 10;
        incSlabRec.Sales_Director_Split__c = 10;
        incSlabRec.Loyalty_Sales_Executive_Split__c = 10;
        incSlabRec.Telesales_Agent_Split__c = 10;
        incSlabRec.Mall_Team_Lead_Split__c = 10;
        incSlabRec.Promoter_Split__c = 10;
        incSlabRec.Marketing_Head_Split__c = 10;
        incSlabRec.TeleSales_Head_Split__c = 10;
        incSlabRec.Team_Lead_Split__c = 10;
        incSlabRec.Digital_Marketing_Head_Split__c = 10;
        incSlabRec.Campaign_Manager_Split__c = 10;
        incSlabRec.Days_To__c = 365;
        incSlabRec.Days_From__c = 1;
        incSlabRec.CSO_Split__c = 10;
        incSlabRec.VP_Split__c = 10;
        incSlabRec.Sales_Head_Split__c = 10;
        incSlabRec.RecordTypeId = Schema.SObjectType.Incentive_Slab__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        recordTypeName = null;
        incSlabMarketCategory = null;
        
        return incSlabRec;
    }
    
    public static PropStrength__PrePayment_Received__c createPrePaymentReceive(Id prPayId) {
        PropStrength__Offer__c offerRec = [SELECT Id FROM PropStrength__Offer__c LIMIT 1];
        
        PropStrength__PrePayment_Received__c prePayRec = new PropStrength__PrePayment_Received__c();
        if(prPayId != null) {
            prePayRec.Id = prPayId;
        }
        prePayRec.PropStrength__Amount__c = 1000;
        prePayRec.PropStrength__Offer__c = offerRec.Id;
        
        return prePayRec;
    }
    
    public static PropStrength__Brokerage_Scheme__c createBrokerageScheme(Id brkSchemeId) {
        PropStrength__Brokerage_Scheme__c brkSchemeRec = new PropStrength__Brokerage_Scheme__c();
        if(brkSchemeId != null) {
            brkSchemeRec.Id = brkSchemeId;
        }
        brkSchemeRec.PropStrength__Scheme_Name__c = 'Test Brokerage Scheme';
        brkSchemeRec.PropStrength__Standard_Brokerage_BSP__c = 2;
        brkSchemeRec.PropStrength__Active__c = true;
        brkSchemeRec.Approval_Status__c = 'Approved';
        
        return brkSchemeRec;
    }
    
    public static PropStrength__Additional_Brokerage_Slab__c createAddBrokerSlab(Id addBrkId) {
        PropStrength__Brokerage_Scheme__c brkSchemeRec = [SELECT Id FROM PropStrength__Brokerage_Scheme__c LIMIT 1];
        addBrokerSlabType = addBrokerSlabType != null ? addBrokerSlabType : 'Amount';
            
        PropStrength__Additional_Brokerage_Slab__c addBrokerSlabrec = new PropStrength__Additional_Brokerage_Slab__c();
        if(addBrkId != null) {
            addBrokerSlabrec.Id = addBrkId;
        }
        addBrokerSlabrec.PropStrength__Brokerage_Scheme__c = brkSchemeRec.Id;
        addBrokerSlabrec.Name = 'Additional Brokerage';
        addBrokerSlabrec.PropStrength__Active__c = true;
        addBrokerSlabrec.PropStrength__Effective_end_Date__c =System.today()-2;
        addBrokerSlabrec.PropStrength__Effective_Start_Date__c =System.today()-5;
        addBrokerSlabrec.PropStrength__Range_To__c =200;
        addBrokerSlabrec.PropStrength__Range_From__c = 2;
        addBrokerSlabrec.PropStrength__Type__c = addBrokerSlabType;

        addBrokerSlabType = null;
        
        return addBrokerSlabrec;
    }
    
    public static PropStrength__Application_Booking__c createApplicationBooking(Id bookId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Contact contRec = [SELECT Id FROM Contact LIMIT 1];
        PropStrength__Offer__c offerRec = [SELECT Id FROM PropStrength__Offer__c LIMIT 1];
        PropStrength__Property_Type__c propTypeRec = [SELECT Id FROM PropStrength__Property_Type__c LIMIT 1];
        PropStrength__Property__c propRec = [SELECT Id FROM PropStrength__Property__c LIMIT 1];
        PropStrength__Brokerage_Scheme__c brkSchemeRec = [SELECT Id FROM PropStrength__Brokerage_Scheme__c LIMIT 1];
        
        bookingThrough = bookingThrough != null ? bookingThrough : 'Direct';
        bookingStatus = bookingStatus != null ? bookingStatus : 'Application Form Filled';
        
        PropStrength__Application_Booking__c appBookingRec = new PropStrength__Application_Booking__c();
        if(bookId != null) {
            appBookingRec.Id = bookId;
        }
        appBookingRec.PropStrength__Brokerage_Scheme__c = brkSchemeRec.Id;
        appBookingRec.PropStrength__Property__c = propRec.Id;
        appBookingRec.PropStrength__Property_Type__c = propTypeRec.Id;
        appBookingRec.PropStrength__Offer__c=offerRec.Id;
        appBookingRec.PropStrength__Project__c = projRec.Id;
        appBookingRec.PropStrength__Booking_Date__c = System.Today().addDays(-3);
        appBookingRec.PropStrength__Booking_Through__c = bookingThrough;
        appBookingRec.PropStrength__Total_Basic_Sales_Price__c = 100;
        appBookingRec.PropStrength__Status__c =bookingStatus;
        appBookingRec.PropStrength__Active__c = true;
        appBookingRec.DSPA_Transaction_Exception__c = true;
        appBookingRec.HO_Appointment_Exception__c = true;
        appBookingRec.Home_Orientation_Exception__c = true;
        appBookingRec.MOU_Transaction_Exception__c = true;
        appBookingRec.Pre_Registration_Transaction_Exception__c = true;
        appBookingRec.SPA_Transaction_Exception__c = true;
        appBookingRec.Title_Deed_Process_Exception__c = true;
        appBookingRec.PropStrength__Broker_Account__c = accRec.Id;
        appBookingRec.PropStrength__Primary_Customer__c = contRec.Id;

        bookingStatus = null;
        bookingThrough = null;
        
        return appBookingRec;
    }
    
    public static PropStrength__Milestone_Group__c createMilestoneGroup(Id mgId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        
        PropStrength__Milestone_Group__c milestonegroupRec = new PropStrength__Milestone_Group__c();
        if(mgId != null) {
            milestonegroupRec.Id = mgId;
        }
        milestonegroupRec.PropStrength__Project__c = projRec.Id;
        milestonegroupRec.PropStrength__Status__c = 'Completed';
        milestonegroupRec.Name = 'Test Milestone Group';
        milestonegroupRec.PropStrength__Active__c = true;
        
        return milestonegroupRec;
    }
    
    public static PropStrength__Milestone__c createMilestone(Id mileId) {
        PropStrength__Projects__c projRec = [SELECT Id FROM PropStrength__Projects__c LIMIT 1];
        PropStrength__Milestone_Group__c milestonegroupRec = [SELECT Id FROM PropStrength__Milestone_Group__c LIMIT 1];

        milestoneType = milestoneType != null ? milestoneType : 'Time Linked';
        
        PropStrength__Milestone__c milestoneRec = new PropStrength__Milestone__c();
        if(mileId != null) {
            milestoneRec.Id = mileId;
        }
        milestoneRec.PropStrength__Project__c = projRec.Id;
        milestoneRec.PropStrength__Status__c = 'Completed';
        milestoneRec.PropStrength__Milestone_Group__c = milestonegroupRec.Id;
        milestoneRec.PropStrength__Milestone_Type__c = milestoneType;
        milestoneRec.PropStrength__Milestone_Code__c = 'Test Milestone code'+String.valueOf(Math.random()).substring(0,5);
        milestoneRec.PropStrength__Milestone_Name__c = 'Test Milestone'+String.valueOf(Math.random()).substring(0,5);

        milestoneType = null;
        
        return milestoneRec;
    }
    
    public static PropStrength__Payment_Plan_Details__c createPaymentPlanDetail(Id ppdId) {
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        PropStrength__Milestone__c milestoneRec = [SELECT Id FROM PropStrength__Milestone__c LIMIT 1];
        
        PropStrength__Payment_Plan_Details__c ppdRec = new PropStrength__Payment_Plan_Details__c();
        if(ppdId != null) {
            ppdRec.Id = ppdId;
        }
        ppdRec.PropStrength__Application_Booking__c = appBookRec.Id;
        ppdRec.PropStrength__Milestone__c = milestoneRec.Id;
        
        return ppdRec;
    }
    
    public static PropStrength__Received_Payment__c createPayment(Id payId) {
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];

        recordTypeName = recordTypeName != null ? recordTypeName : 'Payment Received';
        paymentAmountDueType = paymentAmountDueType != null ? paymentAmountDueType : 'Cheque Bouncing Charges';
        
        PropStrength__Received_Payment__c payRec = new PropStrength__Received_Payment__c();
        if(payId != null) {
            payRec.Id = payId;
        }
        payRec.PropStrength__Application_Booking__c = appBookRec.Id;
        payRec.PropStrength__Payment_Date__c = System.Today()+31;
        payRec.Rebate_Calculated__c = FALSE;
        payRec.PropStrength__Receipt_Reversed__c = FALSE;
        payRec.PropStrength__Amount_Due_Type__c = paymentAmountDueType;
        payRec.RecordTypeId = Schema.SObjectType.PropStrength__Received_Payment__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        payRec.PropStrength__Amount__c = 1000;
        
        recordTypeName = null;
        paymentAmountDueType = null;
        
        return payRec;
    }

    public static PropStrength__Transaction_Requests__c createTransactionRequest(Id trId) {
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];
        
        recordTypeName = recordTypeName != null ? recordTypeName : 'DSPA Process';
        
        PropStrength__Transaction_Requests__c trRec = new PropStrength__Transaction_Requests__c();
        if(trId != null) {
            trRec.Id = trId;
        }
        trRec.RecordTypeId = Schema.SObjectType.PropStrength__Transaction_Requests__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        trRec.PropStrength__Application_Booking__c = appBookRec.Id;

        recordTypeName = null;
        
        return trRec;
    }

    public static dfsle__EnvelopeStatus__c createDocusignEnvelopeStatus(Id envId) {
        PropStrength__Transaction_Requests__c trRec = [SELECT Id FROM PropStrength__Transaction_Requests__c LIMIT 1];
        PropStrength__Application_Booking__c appBookRec = [SELECT Id FROM PropStrength__Application_Booking__c LIMIT 1];

        docusignEnvelopeStatus = docusignEnvelopeStatus != null ? docusignEnvelopeStatus : 'Sent';
        docusignEnvelopeType = docusignEnvelopeType != null ? docusignEnvelopeType : 'NOC TR';
        
        dfsle__EnvelopeStatus__c envRec = new dfsle__EnvelopeStatus__c();
        if(envId != null) {
            envRec.Id = envId;
        }
        envRec.dfsle__Status__c = docusignEnvelopeStatus;
        envRec.Envelope_Type__c = docusignEnvelopeType;
        envRec.Transaction_Request__c = trRec.Id;
        envRec.Application_Booking__c = appBookRec.Id;

        docusignEnvelopeStatus = null;
        docusignEnvelopeType = null;
        
        return envRec;
    }
    public static Broker_Renewal__c createBrokerRenewal(Id brkNewId) {
        Broker_Renewal__c br = new Broker_Renewal__c();
        if(brkNewId != null) {
            br.Id = brkNewId;
        }
        br.Name_as_per_trade_license__c = 'Testing';
        br.Email_ID_1__c = 'existing@example.com';
        br.Mobile_No__c = '1234567890';
        br.Broker_Type__c = 'Channel Partner';
        br.Broker_Sub_Type__c = 'Broker UAE';
        br.Name_as_per_trade_license__c = 'Test Trade License';
        br.Registration_Number__c = '123456';
        br.Broker_Category__c = 'Company';
        br.Registration_Link_Expiry_Date_Time__c = System.now().addDays(2);
        br.Broker_Approval_Status__c = 'Broker Empanelment Form Filled';
        return br;
    }
    
    public static Sobha_Connect__c createSobhaConnect(Id sobhaConnectId) {
        Sobha_Connect__c sc = new Sobha_Connect__c();
        if(sobhaConnectId != null) {
            sc.Id = sobhaConnectId;
        }
        sc.Channel_Relationship_Head__c = UserInfo.getUserId();
        sc.Channel_Relationship_Manager__c = UserInfo.getUserId();
        
        return sc;
    }
    
    public static Customer_Registration__c createCustomerRegistration(Id custRegId) {
        Sobha_Connect__c sc = [SELECT Id FROM Sobha_Connect__c LIMIT 1];
        Customer_Registration__c cr = new Customer_Registration__c();
        if(custRegId != null) {
            cr.Id = custRegId;
        }
        cr.First_Name__c = 'Test First Name';
        cr.Last_Name__c = 'Test Last Name';
        cr.Sobha_Connect__c = sc.Id;
        cr.Property_Type__c = 'Apartment';
        return cr;
    }
}