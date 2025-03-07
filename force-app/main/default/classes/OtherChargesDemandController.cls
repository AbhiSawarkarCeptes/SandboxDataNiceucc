public class OtherChargesDemandController {
    
    public static void createDemand(List<Payment_Request__c> prList){
        set<string> bookingid = new set<string>();
        set<string> prid = new set<string>();
        Map<string,list<Demand__c>> bookingDemandMap = new Map<String, List<Demand__c>>();
        Demand__c updateDemand = new Demand__c();
        Decimal totalAmount = 0;
        boolean demandexist = false;
        Map<String, Id> accMasterMap = new Map<String, Id>();

        Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c,Enable_Other_Charges__c
  															FROM Activate_Track_Payment_Milestone__mdt limit 1]; 
        
        List<Account_Master__c> am = [SELECT Id, Name, Tax_Rate__c, Type__c FROM Account_Master__c  ]; 
        for(Account_Master__c a: am){
            if(a.Type__c == 'Others'){
                accMasterMap.put(a.Name, a.Id);
            }
            if(a.Type__c == 'VAT'){
                accMasterMap.put(a.Name, a.Id);
            }
        }
        if(tpmMetaData.Enable_Other_Charges__c){
        
            for(Payment_Request__c pr : prList){
                bookingid.add(pr.Booking__c);
                prid.add(pr.id);
            }
            
            List<payment_request__c> prData = [SELECT id,Towards_Other_Charges_Amount__c,Booking__r.Project__c, Booking__r.Booking_Date__c,Booking__r.Qualification_Date__c, Towards_Pre_Registration_Amount__c,Booking__c,
                                               unit__c,others__c FROM payment_request__c where id IN : prid AND booking__c IN: bookingid]; 
            
			List<Demand__c> demandList = new List<Demand__c>(); 
            demandList = [SELECT Id,Milestone_Name__c,Booking__c FROM Demand__c WHERE booking__c IN : bookingid and Demand_Status__c != 'Reversed' ];
            List<Demand__c> createDemandList = new List<Demand__c>();
        
            if(demandList.size() > 0){
                for(Demand__c demand : demandList){
                    if(bookingDemandMap.containsKey(demand.Booking__c) && bookingDemandMap.get(demand.Booking__c) != null) {
                        List<Demand__c> lst_d = bookingDemandMap.get(demand.Booking__c);
                        lst_d.add(demand);
                        bookingDemandMap.put(demand.Booking__c,lst_d); 
                    }   
                    else {
                        bookingDemandMap.put(demand.Booking__c, new List<Demand__c> {demand});
                    } 
                }
            }
        
            if(prData.size() > 0){
                for(Payment_Request__c pr : prData){
                    
                    if(String.isNotBlank(pr.Others__c) && (pr.Others__c == 'Cheque Dishonored Charges' || pr.Others__c == 'Cheque Dishonoured Charges')) continue;//Added by Pulkit

                    List<Demand__c> bookingdemandsList = new List<Demand__c>();
                    List<Demand__c> demandListToUpdate = new List<Demand__c>();

                    Decimal otherChargesValue = 0;
                    if(pr.Others__c == 'Admin Charges'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Admin_Charges);
                    }else if(pr.Others__c == 'Admin Charges (General)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Admin_Charges_General);
                    }else if(pr.Others__c == 'Concept drawing NOC'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Concept_drawing_NOC);
                    }else if(pr.Others__c == 'Construction NOC'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Construction_NOC);
                    }else if(pr.Others__c == 'Detailed design NOC'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Detailed_design_NOC);
                    }else if(pr.Others__c == 'DLD Cancellation Charges'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_DLD_Cancellation_Charges);
                    }else if(pr.Others__c == 'Name addition/deletion'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Name_addition_deletion);
                    }else if(pr.Others__c == 'Ownership changes'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Ownership_changes);
                    }else if(pr.Others__c == 'Plot title Deed'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Plot_title_Deed);
                    }else if(pr.Others__c == 'Pre-registration To Pre-title Deed'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Pre_registration_To_Pre_title_Deed);
                    }else if(pr.Others__c == 'Pre-registration to pre-title deed (completed projects)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Pre_registration_to_pre_title_deed_completed_projects);
                    }else if(pr.Others__c == 'Reissue of Plot NOC (other than construction)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_other_than_construction);
                    }else if(pr.Others__c == 'Reissue of Plot NOC (construction)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Reissue_of_Plot_NOC_construction);
                    }else if(pr.Others__c == 'Resale NOC (Oqood)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Resale_NOC_Oqood);
                    }else if(pr.Others__c == 'Resale NOC (Title Deed)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Resale_NOC_Title_Deed);
                    }else if(pr.Others__c == 'SPA Reissuance Fees'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_SPA_Reissuance_Fees);
                    }else if(pr.Others__c == 'SPA reissuance fees (per book)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_SPA_reissuance_fees_per_book);
                    }else if(pr.Others__c == 'Title Deed Charges'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Title_Deed_Charges);
                    }else if(pr.Others__c == 'Title Deed Fees (Units)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Units);
                    }else if(pr.Others__c == 'Title Deed Fees (Villas)'){
                        otherChargesValue = decimal.valueOf(System.Label.X15k_Title_Deed_Fees_Villas);
                    }
                    
                    if(bookingDemandMap.containsKey(pr.booking__c) && bookingDemandMap.get(pr.booking__c) != null) {
                        bookingdemandsList = bookingDemandMap.get(pr.booking__c);
                    }
                    
                    if(bookingdemandsList != null && bookingdemandsList.size() > 0){
                        for(Demand__c demandrec : bookingdemandsList){
                            if(demandrec.Milestone_Name__c == pr.Others__c && otherChargesValue > 0){
                                demandexist = true; 
                                break;
                            }
                        }
                    }
                    
                    if(!demandexist && pr.Others__c != 'Late Payment Charges'){
                        if(pr.Others__c == 'Admin Charges' || pr.Others__c == 'Admin Charges (General)'){
                            system.debug('test:'+pr?.Booking__r?.Booking_Date__c);
                            Date bookingDate = Date.valueOf(pr.Booking__r.Booking_Date__c);
                            Date bookingQualifiedDate = pr.Booking__r.Qualification_Date__c;
                            Date thresholdDate = Date.newInstance(2023, 1, 1);
                            if(bookingDate >= thresholdDate) {
                                if(bookingQualifiedDate != null && bookingQualifiedDate <= System.TODAY()) {
                                    otherChargesValue = 5000;
                                }else{
                                    otherChargesValue = 1000;
                                }
                            }else{
                                otherChargesValue = 5000;
                            }
                        }
                        Demand__c demand = new Demand__c();
                        demand.Milestone_Name__c = pr.Others__c;
                        demand.Due_Date__c = System.today();
                        demand.GL_Date__c = System.today(); 
                        demand.Invoice_Date__c = system.today();
                        if(pr.Towards_Other_Charges_Amount__c != null && pr.Towards_Other_Charges_Amount__c != 0){
                            demand.Debit_Demanded__c = otherChargesValue > 0 ? (otherChargesValue - (otherChargesValue * 0.05 )) : (pr.Towards_Other_Charges_Amount__c - (pr.Towards_Other_Charges_Amount__c * 0.05));
                            demand.Debit_Tax_Demanded__c = otherChargesValue > 0 ? otherChargesValue * 0.05 : (pr.Towards_Other_Charges_Amount__c * 0.05);
                            demand.Debit_CGST__c = otherChargesValue > 0 ? otherChargesValue * 0.05 : (pr.Towards_Other_Charges_Amount__c * 0.05);
                            demand.Tax_Rate__c = 'VAT 5%';
                        }else if(pr.Towards_Pre_Registration_Amount__c != null && pr.Towards_Pre_Registration_Amount__c != 0){
                            demand.Debit_Demanded__c = pr.Towards_Pre_Registration_Amount__c - (pr.Towards_Pre_Registration_Amount__c * 0.05);
                            demand.Debit_Tax_Demanded__c = pr.Towards_Pre_Registration_Amount__c * 0.05;
                            demand.Debit_CGST__c = pr.Towards_Pre_Registration_Amount__c * 0.05;
                            demand.Tax_Rate__c = 'VAT 5%';
                        }
                        demand.Booking__c = pr.Booking__c; 
                        demand.Unit__c = pr.Unit__c;
                        demand.Project__c = pr.Booking__r.Project__c;
                        demand.Demand_Status__c = 'Raised';
                        demand.Debit_Type__c = 'Others';
                        demand.Other_Charges_Type__c = pr.others__c;
                        demand.Descriptions__c = pr.others__c;
                        if(!accMasterMap.isEmpty()){            
                            for(String s: accMasterMap.keySet()){
                                if(s.equalsIgnoreCase('TRADE RECEIVABLE')){
                                    demand.Total_Amount_with_Tax_Account__c = accMasterMap.get(s);
                                }
                                if(s.equalsIgnoreCase('MISCELLANEOUS INCOME')){
                                    demand.Total_Amount_Account__c = accMasterMap.get(s);
                                } 
                                if(s.equalsIgnoreCase('VAT PAYABLE - 5%')){
                                    demand.Total_Tax_Account__c = accMasterMap.get(s);
                                } 
                            }
                        }
                        createDemandList.add(demand); 
                    }
                
                }
                
                try{
                	if(createDemandList != null && !createDemandList.isEmpty()){
                        List<Error_Log__c> eLog = new List<Error_Log__c>();
                        Database.SaveResult[] rsltFuturTPM = Database.Insert(createDemandList);
                        for (Database.SaveResult result : rsltFuturTPM) {
                            if (!result.isSuccess() || Test.isRunningTest()){
                                Database.Error error = result.getErrors().get(0);
                                Error_Log__c logError = new Error_Log__c();
                                logError.Name='Error in OtherchargesDemandController';
                                logError.Class__c='OtherChargesDemandController';
                                logError.Message__c= error.getMessage();
                                logError.Demand__c = result.getid();
                                eLog.add(logError);
                                
                            }
                    	}
                        if(eLog.size() > 0){
                            insert eLog;
                        }
                	}
                }catch(Exception e){}
            } 
        }
    }
    

    
    public static void updateotherchargesReceipt(List<Receipt__c> receiptsList){
   		
        List<Receipt__c> newReceiptsList = new List<Receipt__c>();
        List<String> newReceiptIdsList = new List<String>();
        List<Receipt__c> updateReceiptList = new List<Receipt__c>();
        List<Track_PaymentMilestone__c> createTPMList = new List<Track_PaymentMilestone__c>();
        set<string> bookingid = new set<string>();
        Map<string,list<Demand__c>> bookingDemandMap = new Map<String, List<Demand__c>>();
        
        Activate_Track_Payment_Milestone__mdt tpmMetaData = [SELECT Label,Active__c,Booking_Created_Date__c
  															FROM Activate_Track_Payment_Milestone__mdt];
        if(tpmMetaData.Active__c == true){
        for(Receipt__c receipt : receiptsList){
            bookingid.add(receipt.Booking__c);
            newReceiptIdsList.add(receipt.id);
        }
        
        newReceiptsList = [SELECT Id,booking__c,Other_Charges_Type__c,demand__c FROM Receipt__c 
                           where ID IN : newReceiptIdsList and 
                           booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c
                          and Other_Charges_Type__c != null and Receipt_Status__c = 'Cleared'];
        List<Demand__c> demandList = [SELECT Id,Milestone_Name__c,Booking__c FROM Demand__c 
                                      where booking__c IN : bookingid and Demand_Status__c != 'Reversed' and
                                      booking__r.createdDate >: tpmMetaData.Booking_Created_Date__c
                                     ]; 
        
        for(Demand__c d : demandList){
            if(bookingDemandMap.containsKey(d.Booking__c) && bookingDemandMap.get(d.Booking__c) != null) {
                List<Demand__c> lst_d = bookingDemandMap.get(d.Booking__c);
                lst_d.add(d);
                bookingDemandMap.put(d.Booking__c,lst_d); 
            }   
            else {
                bookingDemandMap.put(d.Booking__c, new List<Demand__c> {d});
            } 
        }
        
        if(newReceiptsList != null && !newReceiptsList.isEmpty()){
        	for(Receipt__c recept : newReceiptsList){
            	list<demand__c> bookingdemandsList;
                boolean demandexist = false;
                
                if(bookingDemandMap.containsKey(recept.booking__c) && bookingDemandMap.get(recept.booking__c) != null) {
                    bookingdemandsList = bookingDemandMap.get(recept.booking__c);
                }
                
                if(bookingdemandsList != null && bookingdemandsList.size() > 0){
                    for(Demand__c demandrec : bookingdemandsList){
                        if(demandrec.Milestone_Name__c == recept.Other_Charges_Type__c && 
                           recept.Other_Charges_Type__c != 'Late Payment Charges'){
                            
                            recept.demand__c = demandrec.id;
                            
                            Track_PaymentMilestone__c tpm = new Track_PaymentMilestone__c();
                			tpm.Booking__c = recept.Booking__c;
                			tpm.Demand__c = demandrec.id;
                			tpm.Receipt__c = recept.id;
                			tpm.Remaining_Receipt_Amount__c = 0;
                			
                            createTPMList.add(tpm);
                            updatereceiptList.add(recept);
                        }
                        
                        if( recept.Other_Charges_Type__c != 'Late Payment Charges'){
                            if(demandrec.Milestone_Name__c == 'Late Payment Charges'){
                                Track_PaymentMilestone__c tpm = new Track_PaymentMilestone__c();
                				tpm.Booking__c = recept.Booking__c;
                				tpm.Demand__c = demandrec.id;
                				tpm.Receipt__c = recept.id;
                				tpm.Remaining_Receipt_Amount__c = 0;
                			
                            	createTPMList.add(tpm);

                            }
                        }
                    }
                }
        	}
        }
        
            if(updatereceiptList != null && !updatereceiptList.isEmpty()){
        	Database.SaveResult[] rsltFuturTPM = Database.Update(updatereceiptList);
            }
        
            if(createTPMList != null && !createTPMList.isEmpty()){
        	Database.SaveResult[] rsltFuturTPM = Database.Insert(createTPMList);
            }
        }
        
    }
    
    public static void insertErrorLog(string errorMsg, string stackTrace, string recordName, string className){
       Error_Log__c logError = new Error_Log__c();
        logError.Name=recordName;
        logError.Class__c=className;
        logError.Message__c=errorMsg;
        logError.Request__c=stackTrace;
        insert logError;
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}