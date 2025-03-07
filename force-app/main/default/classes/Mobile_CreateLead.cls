@RestResource(urlMapping = '/registeruser')
Global Class Mobile_CreateLead {
    @HttpPost
    Global Static void doPost() {
        List<ApiUtility.HttpResponseWrapper> rwList = new List<ApiUtility.HttpResponseWrapper>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        String responseString = '';
        String jsonString = '';
        String errorMessage = '';
        try {
            jsonString = req.requestBody.toString();
            LeadWrapper leadWrap = (LeadWrapper) System.JSON.deserialize(jsonString,LeadWrapper.class);
            String emailLead = leadWrap.Email;
            String countryCode='';
            String formatMobile='';
            Quotation__c quotRec = new Quotation__c();
            if(leadWrap.unitId != null && leadWrap.towerId != null){
                Map<String, decimal> carParkCharges = InventoryCostServices.getCarparkCharges(leadWrap.unitId);
                Map<String,Decimal> rateListMap = InventoryCostServices.getRateList(leadWrap.unitId);
                Map<String,Decimal> allChargesMap = InventoryCostServices.getAllChargesNew(leadWrap.unitId,0,0,0,rateListMap);
                List<InventoryCostServices.PlanDetailWrapper> payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
                List<Unit__c> unitRec = [Select Id,Project__c, Tower__c, Tower__r.Name, Project__r.Name, Unit_Type__c, Tower__r.Cluster__r.Name, Tower__r.Building_Number__c, Floor_No_to_print__c, Unit_No__c, Configuration__c, Chargeable_Area__c, Store_Area__c, Store_Unit__c from Unit__c where Id = :leadWrap.unitId LIMIT 1];
                Map<String,Integer> projChargeSeq = InventoryCostServices.getProjectChargesSequence(unitRec[0].Project__r.Name, unitRec[0].Tower__c);
                Decimal preRegistrationFees = allChargesMap.get('Stamp Duty and Registration AMOUNTTOTAL');
                Decimal totalAgreementValueFees = allChargesMap.get('Agreement Value AMOUNTTOTAL');
                Decimal oqoodFees = allChargesMap.get('DLD Admin Fees');
                Decimal knowledgeFees = allChargesMap.get('Knowledge Fees');
                Decimal preRegistrationCharges = allChargesMap.get('DLD');

                Payment_Plan__c pp = [select id,name,Payment_Plan_Editable__c,Subvention_Base_Rate__c,Subvention_Payment_Plan__c from Payment_Plan__c where Tower__c =: leadWrap.towerId and Status__c = 'Valid' and Name LIKE '%Standard%' Order by createdDate DESC LIMIT 1];
                payplanDetails = InventoryCostServices.getPlanDetailsNew(leadWrap.unitId, pp.Id, allChargesMap);
                List<PaymentPlanWrapper> paymentPlanWrapperList = new List<PaymentPlanWrapper>();
                Boolean isFirstPaymentPlan = false;
                for(InventoryCostServices.PlanDetailWrapper payPlan : payplanDetails){
                    PaymentPlanWrapper paymentPlanWrapper = new PaymentPlanWrapper();
                    Payment_Milestones__c payMiles = payPlan.pm;
                    paymentPlanWrapper.installment = payMiles != null ? payMiles.Installment__c : '';
                    paymentPlanWrapper.percentage = payPlan.percentage;
                    paymentPlanWrapper.amount = payPlan.total;
                    paymentPlanWrapper.paymentDate = !isFirstPaymentPlan ? 'On Booking' : '';
                    isFirstPaymentPlan = true;
                    paymentPlanWrapper.milestone = payPlan.toBePaid;
                    paymentPlanWrapperList.add(paymentPlanWrapper);                    
                }   
                QuoteResponseWrapper quoteResponseWrapper = new QuoteResponseWrapper();
                quoteResponseWrapper.towerName = unitRec[0].Tower__r.Name;
                quoteResponseWrapper.projectName = unitRec[0].Project__r.Name;
                quoteResponseWrapper.clusterName = unitRec[0].Tower__r.Cluster__r.Name;
                quoteResponseWrapper.buildingNumber = unitRec[0].Tower__r.Building_Number__c != null ? unitRec[0].Tower__r.Building_Number__c :'';
                quoteResponseWrapper.floorNo = unitRec[0].Floor_No_to_print__c != null ? unitRec[0].Floor_No_to_print__c :'';
                quoteResponseWrapper.unitType = unitRec[0].Unit_Type__c != null ? unitRec[0].Unit_Type__c :'';
                quoteResponseWrapper.unitNo = unitRec[0].Unit_No__c != null ? unitRec[0].Unit_No__c :'';
                quoteResponseWrapper.configuration = unitRec[0].Configuration__c != null ? unitRec[0].Configuration__c :'';
                quoteResponseWrapper.saleableArea = unitRec[0].Store_Area__c != null && unitRec[0].Store_Unit__c ? unitRec[0].Chargeable_Area__c +  unitRec[0].Store_Area__c: unitRec[0].Chargeable_Area__c;
                quoteResponseWrapper.purchasePrice = totalAgreementValueFees!= null ? totalAgreementValueFees : 0;
                quoteResponseWrapper.preRegistrationFees = preRegistrationFees!= null ? preRegistrationFees : 0;
                quoteResponseWrapper.payplanDetails = paymentPlanWrapperList;
                quoteResponseWrapper.knowledgeFees = knowledgeFees!= null ? knowledgeFees : 0;
                quoteResponseWrapper.oqoodFees = oqoodFees!= null ? oqoodFees : 0;
                quoteResponseWrapper.preRegistrationCharges = preRegistrationCharges!= null ? preRegistrationCharges : 0;
                responseString = (prepareResponse(quoteResponseWrapper,'Successfully Processed','Success',200,true)).toString().replace('"','');
                res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(quoteResponseWrapper,'Successfully Processed','Success',200,true)));
                res.statusCode = 200;  
            }
            else{
                if(leadWrap.countryCode!=null){
               // countryCode = leadWrap.countryCode;
                if(countryCode.endsWith('0')){
                    countryCode = countryCode.removeEnd('0');
                }
                if(countryCode.startsWith('+')){
                    countryCode =  countryCode.substringAfter('+');
                }
                }
                if(leadWrap.mobile != null){
                    formatMobile = leadWrap.mobile;
                    if(formatMobile.startsWith('0')){
                        formatMobile = formatMobile.substringAfter('0'); 
                        formatMobile = countryCode + formatMobile;
                    }
                    else{
                        formatMobile = countryCode + formatMobile;
                    }
                    //l.Mobile_Number_Formatted__c = true;
                }
                List<Task> taskList = new List<Task>(); //=========> Which Obejct to use?: Task/Activity
                List<String> UsrList = new List<String>();
                //===Checking : if exists in Lead==========
                List<Lead> lList = [SELECT Id, Email, Primary_Number__c, MobilePhone, ownerId,owner.isActive,Alternate_Mobile_Number__c, Phone, Office_Phone__c FROM Lead WHERE Email = :emailLead OR MobilePhone =: formatMobile OR Alternate_Mobile_Number__c =: formatMobile OR Office_Phone__c =: formatMobile OR Phone =: formatMobile OR Primary_Number__c =: formatMobile LIMIT 1];
                
                List<group> groupsForLead = [SELECT ID,Name FROM group WHERE  Name IN ('RUSSIAN Group For PSTL', 'Super Agent - English Language','Sunday Queue For Lead Assignments','Saturday Queue For Lead Assignments')];
                Map<String,ID> mapgroupNameToId = new Map<String,ID>();
                for(Group gr : groupsForLead){
                    mapgroupNameToId.put(gr.Name, gr.Id);
                }
                List<group> QueueId = [Select Id from Group where type='Queue' and Name= 'Telesales_Agent' LIMIT 1];
                for(GroupMember groupUsr : [Select UserOrGroupId From GroupMember where GroupId =: QueueId]){
                    UsrList.add(groupUsr.UserOrGroupId);
                }
                Integer listSize = UsrList.size() - 1;
                Datetime dt = System.now();
                String dayOfWeek = dt.format('EEEE');
                Integer Hour = dt.hour();
                Boolean isUpdate = false;
                List<Lead> leadList = new List<Lead>();
                if(lList.size() > 0) {
                    for(Lead l : llist) { 
                        //===Creating Re-Enquiry Task as the Lead exists in system===Map other fileds as well===
                        if(leadWrap.comments != null && String.isNotBlank(leadWrap.comments)){
                            l.Client_Comments__c = leadWrap.comments;
                            leadList.add(l);
                        }
                        taskList.add(createEnquiryTask(leadWrap, l, 'Re Enquiry Received from: Mobile App'));    
                        isUpdate = true;               
                    }
                }
                else{
                    Lead newLead = new Lead();
                    newLead.FirstName = leadWrap.firstName;
                    newLead.LastName = leadWrap.lastName;
                    newLead.Lead_Source__c = 'Digital';
                    newLead.LeadSource = 'Digital';
                    newLead.Lead_Sub_Source__c = 'Mobile App';
                    newLead.nationality__c = leadWrap.nationality;
                    newLead.RDS_Country_Code__c = leadWrap.countryCode;
                    newLead.MobilePhone = formatMobile;
                    newLead.News_Offer_Subscription__c = leadWrap.newsAndOffers;
                    newLead.Preferred_Method_of_Contact__c = leadWrap.modeOfContact;
                    if(leadWrap.language == 'en'){
                        newLead.Language__c = 'English';    
                    }else{
                        newLead.Language__c = leadWrap.language;    
                    }
                    
                    newLead.Email = leadWrap.Email;
                    newLead.Client_Comments__c = leadWrap.comments != null ? leadWrap.comments : null;
                    if(((dayOfWeek == 'Friday' && hour >= 19) || dayOfWeek == 'Saturday' || (dayOfWeek == 'Sunday' && hour < 19)||Test.isRunningTest())
                        && mapgroupNameToId.containsKey('Saturday Queue For Lead Assignments') && mapgroupNameToId.containsKey('Sunday Queue For Lead Assignments'))
                    {
                        /*if((dayOfWeek == 'Friday' && hour >= 19) || (dayOfWeek == 'Saturday' && hour <19) ||Test.isRunningTest()){
                            newLead.Route_To_Saturday_Queue1__c = true;
                            newLead.ownerId = mapgroupNameToId.get('Saturday Queue For Lead Assignments');
                        }
                        else if((dayOfWeek == 'Saturday' && hour >= 19) || (dayOfWeek == 'Sunday' && hour <19)){
                            newLead.Route_To_Sunday_Queue1__c = true;
                            newLead.ownerId = mapgroupNameToId.get('Sunday Queue For Lead Assignments');
                        }*/
                    }else if(mapgroupNameToId.containsKey('Super Agent - English Language')){
                        newLead.ownerId = mapgroupNameToId.get('Super Agent - English Language');
                    }
                    leadList.add(newLead);
                }
                if(leadList.size() > 0){
                    upsert leadList;
                    if(!isUpdate){
                        taskList.add(createEnquiryTask(leadWrap, leadList[0], 'Enquiry Received from: Mobile App')); 
                    }
                }
                if(taskList.size() > 0){
                    insert taskList;
                }

                /*ApiUtility.HttpResponseWrapper rw = new ApiUtility.HttpResponseWrapper();
                rw.success = True;
                rw.message = 'Successfully Processed';
                rwList.add(rw);*/
                responseString = (prepareResponse(null,'Successfully Processed','Success',200,true)).toString().replace('"','');
                res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Successfully Processed','Success',200,true)));
                res.statusCode = 200;  
            }
            
        }catch (Exception Ex) {
            
            errorMessage = ex.getMessage();
            res.responseBody = BLOB.valueOf(JSON.serialize(prepareResponse(null,'Error','Error',400,false)));
            res.statusCode = 400;
        }  
        Mobile_ApiUtility.createMobileAPILogs('registeruser','Mobile_createLead',jsonString,responseString,errorMessage,res.statusCode);
    }

    public static Task createEnquiryTask(LeadWrapper leadWrap, Lead l, String subject){
        Task reinquiryTask = new Task();
        reinquiryTask.Subject = subject;
        reinquiryTask.Task_Type__c = 'Enquiry Received';
        reinquiryTask.WhoId = l.Id;
        reinquiryTask.ActivityDate = Date.Today();
        reinquiryTask.Enquiry_Source__c = 'Digital';
        reinquiryTask.Enquiry_Sub_Source__c = 'Mobile App';
        reinquiryTask.Email_Id__c = leadWrap.email;
        reinquiryTask.Email_Id_New__c = leadWrap.email;
        reinquiryTask.dialingCode__c = leadWrap.countryCode;
        reinquiryTask.Mobile_Number_Webform__c = leadWrap.mobile;
        reinquiryTask.Lead_Lookup__c = l.id;
        reinquiryTask.News_Offer_Subscription__c = leadWrap.newsAndOffers;
        reinquiryTask.Are_you_looking_for__c = leadWrap.comments;//added by Ananth
        return reinquiryTask;
    }

    global class LeadWrapper{
        public String firstName;
        public String lastName;
        public String email;
        public String mobile;
        public String countryCode;
        public String nationality;
        public String language;
        public Boolean newsAndOffers;
        public String modeOfContact;
        public String comments;
        public String unitId;
        public String towerId;
    }

    public static HttpResponseWrapper prepareResponse(QuoteResponseWrapper rBody, string rMessage,string rStatus,integer rStatusCode,boolean rSuccess){
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        resWrap.data = rBody;
        resWrap.Message = rMessage;
        resWrap.status = rStatus;
        resWrap.statusCode = rStatusCode;
        resWrap.success = rSuccess;
        return resWrap;
    }

    public class HttpResponseWrapper{
        public String status;
        public Integer statusCode;
        public Boolean success;
        public String Message;
        public QuoteResponseWrapper data;
    }

    public class PaymentPlanWrapper{
        public String installment;
        public String percentage;
        public String amount;
        public String paymentDate;
        public String milestone;
    }

    public class QuoteResponseWrapper{
        String towerName;
        String projectName;
        String clusterName;
        String buildingNumber;
        String floorNo;
        String unitType;
        String unitNo;
        String configuration;
        Decimal saleableArea;
        Decimal purchasePrice;
        Decimal preRegistrationFees;
        Decimal preRegistrationCharges;
        Decimal knowledgeFees;
        Decimal oqoodFees;
        List<PaymentPlanWrapper> payplanDetails;
    }
    
}