public class UnitTriggerHandler {
    
    @future(callOut=true)
    Public static void sendToMobileAPI(string newUnitString, string oldUnitString){
        Mobile_App__mdt mobile_appmdt = Mobile_App__mdt.getInstance('Mobile_Link');
        String endpoint = mobile_appmdt.End_Point__c;
        // string endPointURL = 'https://srdevapimgmt.sobhaapps.com/srprosalesforce/v1/salesforce/unit';
        String endPointURL = endpoint+'/srprosalesforce/v1/salesforce/unit';
        string methodType = 'POST';
        list<Unit__c> newList = (list<Unit__c>)JSON.deserialize(newUnitString, list<Unit__c>.Class);
        String errorMessage;
        Integer statusCode;
        String response;
        requestBodyWrapper wrap;
        List<requestBodyWrapper> wraplst = new List<requestBodyWrapper>(); 
        try{
            for(Unit__c ut :newList){
                wrap = new requestBodyWrapper();
                if(oldUnitString != null){
                    Map<Id,Unit__c> oldMap = (Map<Id,Unit__c>)JSON.deserialize(oldUnitString, Map<Id,Unit__c>.Class);
                    System.debug('oldMap : '+oldMap);
                    if(ut.name != oldMap.get(ut.Id).name){
                        if(ut.name != null){
                            wrap.unitName = ut.name;
                        }
                    }else{
                        wrap.unitName = oldMap.get(ut.Id).name;
                    }
                    
                    if(ut.Floor_No_to_print__c != oldMap.get(ut.Id).Floor_No_to_print__c){//if the floor no is null, can we pass 0
                        if(ut.Floor_No_to_print__c != null && ut.Floor_No_to_print__c != 'NA'){
                            wrap.floorNumber = ut.Floor_No_to_print__c;
                        }else{ 
                            wrap.floorNumber = '0';
                        }
                    }else{
                        if(oldMap.get(ut.Id).Floor_No_to_print__c != null && ut.Floor_No_to_print__c != 'NA'){
                            wrap.floorNumber = oldMap.get(ut.Id).Floor_No_to_print__c;
                        }else{
                            wrap.floorNumber = '0';
                        }
                        
                    }
                    
                    if(ut.Unit_Type__c != oldMap.get(ut.Id).Unit_Type__c){
                        if(ut.Unit_Type__c != null){
                            wrap.unitType = ut.Unit_Type__c;
                        }
                    }else{
                        wrap.unitType = oldMap.get(ut.Id).Unit_Type__c;
                    } 
                    
                    if(ut.Puchase_Price__c != oldMap.get(ut.Id).Puchase_Price__c){
                        if(ut.Puchase_Price__c != null){
                            wrap.unitPrice = ut.Puchase_Price__c;
                        }
                    }else{
                        wrap.unitPrice = oldMap.get(ut.Id).Puchase_Price__c;
                    }
                    
                    if(ut.DLD_Unit_No__c != oldMap.get(ut.Id).DLD_Unit_No__c){
                        if(ut.DLD_Unit_No__c != null){
                            wrap.unitNumber = ut.DLD_Unit_No__c;
                        }
                    }else{
                        wrap.unitNumber = oldMap.get(ut.Id).DLD_Unit_No__c;
                    } 
                    
                    if(ut.Not_Available_for_Sales__c != oldMap.get(ut.Id).Not_Available_for_Sales__c){
                        if(ut.Not_Available_for_Sales__c != null){
                            wrap.isNotAvailableForSale = ut.Not_Available_for_Sales__c;
                        }
                    }else{
                        wrap.isNotAvailableForSale = oldMap.get(ut.Id).Not_Available_for_Sales__c;
                    }
                    
                    if(ut.Unit_Status__c != oldMap.get(ut.Id).Unit_Status__c){
                        if(ut.Unit_Status__c != null){
                            wrap.availabilityStatus = ut.Unit_Status__c;
                        }
                    }else{
                        wrap.availabilityStatus = oldMap.get(ut.Id).Unit_Status__c;
                    }
                    if(ut.DLD_Building_Number__c != oldMap.get(ut.Id).DLD_Building_Number__c){
                        if(ut.DLD_Building_Number__c != null){
                            wrap.DLDBuildingNumber = ut.DLD_Building_Number__c;
                        }
                    }else{
                        wrap.DLDBuildingNumber = oldMap.get(ut.Id).DLD_Building_Number__c;
                    }
                    
                    if(ut.No_of_Bedroom__c != oldMap.get(ut.Id).No_of_Bedroom__c){
                        if(ut.No_of_Bedroom__c != null){                       
                            // wrap.noOfBedrooms = ut.No_of_Bedroom__c;
                            list<String> bedroom = ut.No_of_Bedroom__c.split(' ');
                            if(bedroom[0] != null){
                                System.debug('bedroom[0]'+bedroom[0]);
                                if(bedroom[0].isNumeric()){
                                    wrap.noOfBedrooms = Decimal.valueOf(bedroom[0]);
                                }else{
                                    wrap.noOfBedrooms = 0;
                                }
                            }
                        }
                    }else{
                        if(oldMap.get(ut.Id).No_of_Bedroom__c !=null){
                            // wrap.noOfBedrooms = Decimal.valueOf(oldMap.get(ut.Id).No_of_Bedroom__c);
                            list<String> bedroom = oldMap.get(ut.Id).No_of_Bedroom__c.split(' ');
                            if(bedroom[0] != null){
                                System.debug('bedroom[0]'+bedroom[0].IsNumeric());
                                if(bedroom[0].contains('NA') || bedroom[0].contains('Plot') || bedroom[0].contains('Polyclinic') || bedroom[0].contains('Restaurant') || bedroom[0].contains('Retail') ||  bedroom[0].contains('Studio')){
                                    System.debug('inside if isnumeric');
                                    wrap.noOfBedrooms = 0;
                                    
                                }else{
                                    System.debug('inside if elsessisnumeric, '+Decimal.valueOf(bedroom[0]));
                                    wrap.noOfBedrooms = Decimal.valueOf(bedroom[0]);
                                }
                            }
                        }else {
                            list<String> bedroom = ut.No_of_Bedroom__c.split(' ');
                            if(bedroom[0] != null){
                                System.debug('bedroom[0]'+bedroom[0]);
                                if(bedroom[0].contains('NA') || bedroom[0].contains('Plot') || bedroom[0].contains('Polyclinic') || bedroom[0].contains('Restaurant') || bedroom[0].contains('Retail') ||  bedroom[0].contains('Studio')){
                                    System.debug('inside if isnumeric');
                                    wrap.noOfBedrooms = 0;
                                    
                                }else{
                                    System.debug('inside if elsessisnumeric, '+Decimal.valueOf(bedroom[0]));
                                    wrap.noOfBedrooms = Decimal.valueOf(bedroom[0]);
                                }
                            }
                        }
                        
                    }
                    
                    if(ut.Permitted_Use__c != oldMap.get(ut.Id).Permitted_Use__c){
                        if(ut.Permitted_Use__c != null){
                            wrap.permittedUse = ut.Permitted_Use__c;
                        }
                    }else{
                        wrap.permittedUse = oldMap.get(ut.Id).Permitted_Use__c;
                    }
                    
                    if(ut.Project_Property_Type__c != oldMap.get(ut.Id).Project_Property_Type__c){
                        if(ut.Project_Property_Type__c != null){
                            wrap.projectPropertyType = ut.Project_Property_Type__c;
                        }
                    }else{
                        wrap.projectPropertyType = oldMap.get(ut.Id).Project_Property_Type__c;
                    }
                    
                    if(ut.Car_Park_Count_1__c != oldMap.get(ut.Id).Car_Park_Count_1__c){
                        if(ut.Car_Park_Count_1__c != null){
                            wrap.noOfParkings = ut.Car_Park_Count_1__c;
                        }
                    }else{
                        wrap.noOfParkings = oldMap.get(ut.Id).Car_Park_Count_1__c;
                    }
                    
                    /*  if(ut.Project_Unit_Type__r.Name != oldMap.get(ut.Id).Project_Unit_Type__r.Name){
if(ut.Project_Unit_Type__r.Name != null){
wrap.propertyType = ut.Project_Unit_Type__r.Name;
}
}else{
wrap.propertyType = oldMap.get(ut.Id).Project_Unit_Type__r.Name;
} */
                    
                    if(ut.Car_Park_Type_1__c != oldMap.get(ut.Id).Car_Park_Type_1__c){
                        if(ut.Car_Park_Type_1__c != null){
                            wrap.parkingType = ut.Car_Park_Type_1__c;
                        }
                    }else{
                        wrap.parkingType = oldMap.get(ut.Id).Car_Park_Type_1__c;
                    }
                    
                    if(ut.Total_Area__c != oldMap.get(ut.Id).Total_Area__c){
                        if(ut.Total_Area__c != null && ut.Total_Area__c > 0){
                            wrap.totalArea = ut.Total_Area__c;
                        }else if(ut.Total_Area__c == 0 && ut.Chargeable_Area__c > 0){
                            wrap.totalArea = ut.Chargeable_Area__c;
                        }
                    }else{
                        if(ut.Chargeable_Area__c != null){
                            wrap.totalArea = ut.Chargeable_Area__c;
                            wrap.saleableArea = ut.Chargeable_Area__c;
                        }
                       // wrap.totalArea = oldMap.get(ut.Id).Total_Area__c;
                    }
                    
                    if(ut.Chargeable_Area__c != oldMap.get(ut.Id).Chargeable_Area__c){
                        if(ut.Chargeable_Area__c != null){
                            wrap.saleableArea = ut.Chargeable_Area__c;
                        }
                    }else{
                        wrap.saleableArea = oldMap.get(ut.Id).Chargeable_Area__c;
                    } 
                    
                    if(ut.Plot_Area__c != oldMap.get(ut.Id).Plot_Area__c){
                        if(ut.Plot_Area__c != null){
                            wrap.plotArea = ut.Plot_Area__c;
                        }
                    }else{
                        wrap.plotArea = oldMap.get(ut.Id).Plot_Area__c;
                    }
                    
                    if(ut.RERA_Chargeable_Area_Sq_Ft__c != oldMap.get(ut.Id).RERA_Chargeable_Area_Sq_Ft__c){
                        if(ut.RERA_Chargeable_Area_Sq_Ft__c != null){
                            wrap.RERAApplicableArea = ut.RERA_Chargeable_Area_Sq_Ft__c;
                        }
                    }else{
                        wrap.RERAApplicableArea = oldMap.get(ut.Id).RERA_Chargeable_Area_Sq_Ft__c;
                    }
                    
                    if(ut.Parking_Bay_Allocation_No__c   != oldMap.get(ut.Id).Parking_Bay_Allocation_No__c  ){
                        if(ut.Parking_Bay_Allocation_No__c   != null){
                            wrap.parkingBays = ut.Parking_Bay_Allocation_No__c  ;
                        }
                    }else{
                        wrap.parkingBays = oldMap.get(ut.Id).Parking_Bay_Allocation_No__c  ;
                    }
                    
                    if(ut.Plot_Number__c != oldMap.get(ut.Id).Plot_Number__c){
                        if(ut.Plot_Number__c != null){
                            wrap.plotNumber = ut.Plot_Number__c;
                        }else{
                            wrap.plotNumber = '';
                        }
                    }else{
                        if(ut.Plot_Number__c != null){
                            wrap.plotNumber = oldMap.get(ut.Id).Plot_Number__c;
                        }else{
                            wrap.plotNumber = 'A';
                        }
                    }
                    
                    if(ut.Id != oldMap.get(ut.Id).Id){
                        if(ut.Id != null){
                            wrap.sfUnitId = ut.Id;
                        }
                    }else{
                        wrap.sfUnitId = oldMap.get(ut.Id).Id;
                    }
                    
                    /*if(ut.Tower__c != oldMap.get(ut.Id).Tower__c){
                        if(ut.Tower__c != null){
                            wrap.sfTowerId = ut.Tower__c;
                        }
                    }else{
                        wrap.sfTowerId = oldMap.get(ut.Id).Tower__c;
                    }*/
                    
                    if(ut.Mobile_App_Tower__c != oldMap.get(ut.Id).Mobile_App_Tower__c){
                        if(ut.Mobile_App_Tower__c != null){
                            wrap.sfTowerId = ut.Mobile_App_Tower__c;
                        }
                    }else{
                        wrap.sfTowerId = oldMap.get(ut.Id).Mobile_App_Tower__c;
                    }
                    Unit__c u1 = oldMap.get(ut.Id);
                    List<Unit__c> u = [select id,name,tower__r.Cluster__c,Mobile_App_Cluster__c,tower__r.Tower_Type__c from unit__c where id =:u1.Id];
                    
                    
                    //wrap.sfCommunityId = u[0].tower__r.Cluster__c;
                    wrap.sfCommunityId = u[0].Mobile_App_Cluster__c;
                    
                    if(u[0].tower__r.Tower_Type__c != null){
                        wrap.propertyType = u[0].tower__r.Tower_Type__c;
                    } else {
                        wrap.propertyType = 'Apartments';
                    }
                    
                    
                    if(ut.Project__c != oldMap.get(ut.Id).Project__c){
                        if(ut.Project__c != null){
                            wrap.sfMasterCommunityId = ut.Project__c;
                        }
                    }else{
                        wrap.sfMasterCommunityId = oldMap.get(ut.Id).Project__c;
                    }
                    
                    if(ut.View_Type__c != oldMap.get(ut.Id).View_Type__c){
                        if(ut.View_Type__c != null){
                            wrap.views = ut.View_Type__c;
                        }
                    }else{
                        wrap.views = oldMap.get(ut.Id).View_Type__c;
                    }
                    
                    /* if(ut.DLP_End_Date__c != oldMap.get(ut.Id).DLP_End_Date__c){
if(ut.DLP_End_Date__c != null){
wrap.dlpDate = ut.DLP_End_Date__c;
}
}else{
wrap.dlpDate = oldMap.get(ut.Id).DLP_End_Date__c;
} */
                    
                }
                else{
                    if(ut.name != null){
                        wrap.unitName = ut.name;
                    }
                    if(ut.Floor_No_to_print__c != null){
                        wrap.floorNumber = ut.Floor_No_to_print__c;
                    }else{
                        wrap.floorNumber = '0';
                    }
                    if(ut.Unit_Type__c != null){
                        wrap.unitType = ut.Unit_Type__c;
                    }
                    if(ut.Puchase_Price__c != null){
                        wrap.unitPrice = ut.Puchase_Price__c;
                    }
                    if(ut.DLD_Unit_No__c != null){
                        wrap.unitNumber = ut.DLD_Unit_No__c;
                    }
                    if(ut.Not_Available_for_Sales__c != null){
                        wrap.isNotAvailableForSale = ut.Not_Available_for_Sales__c;
                    }
                    if(ut.Unit_Status__c != null){
                        wrap.availabilityStatus = ut.Unit_Status__c;
                    }
                    if(ut.DLD_Building_Number__c != null){
                        wrap.DLDBuildingNumber = ut.DLD_Building_Number__c;
                    }
                   // Unit__c u1 = ut.Id;
                    List<Unit__c> u = [select id,name,tower__r.Cluster__c,Mobile_App_Cluster__c,tower__r.Tower_Type__c from unit__c where id =:ut.Id];
                    
                    
                    //wrap.sfCommunityId = u[0].tower__r.Cluster__c;
                    wrap.sfCommunityId = u[0].Mobile_App_Cluster__c;
                    
                    
                    
                    if(u[0].tower__r.Tower_Type__c != null){
                        wrap.propertyType = u[0].tower__r.Tower_Type__c;
                    } else {
                        wrap.propertyType = 'Apartments';
                    }
                    
                    
                    if(ut.No_of_Bedroom__c != null){                       
                        // wrap.noOfBedrooms = ut.No_of_Bedroom__c;
                        list<String> bedroom = ut.No_of_Bedroom__c.split(' ');
                        if(bedroom[0] != null){
                            System.debug('bedroom[0]'+bedroom[0]);
                            if(bedroom[0].isNumeric()){
                                wrap.noOfBedrooms = Decimal.valueOf(bedroom[0]);
                            }else{
                                wrap.noOfBedrooms = 0;
                            }
                        }
                    }
                    if(ut.Permitted_Use__c != null){
                        wrap.permittedUse = ut.Permitted_Use__c;
                    }
                    if(ut.Project_Property_Type__c != null){
                        wrap.projectPropertyType = ut.Project_Property_Type__c;
                    }
                    if(ut.Car_Park_Count_1__c != null){
                        wrap.noOfParkings = ut.Car_Park_Count_1__c;
                    }
                    if(ut.Car_Park_Type_1__c != null){
                        wrap.parkingType = ut.Car_Park_Type_1__c;
                    }
                   /* if(ut.Total_Area__c != null){
                        wrap.totalArea = ut.Total_Area__c;
                    }else if(ut.Total_Area__c == 0 && ut.Chargeable_Area__c > 0){
                        wrap.totalArea = ut.Chargeable_Area__c; 
                    } */
                    
                // yet to deploy the below changes    
                    if(ut.Chargeable_Area__c != null){
                        wrap.totalArea = ut.Chargeable_Area__c;
                        wrap.saleableArea = ut.Chargeable_Area__c;
                    }
                    
                    
                    if(ut.Plot_Area__c != null){
                        wrap.plotArea = ut.Plot_Area__c;
                    }
                    if(ut.RERA_Chargeable_Area_Sq_Ft__c != null){
                        wrap.RERAApplicableArea = ut.RERA_Chargeable_Area_Sq_Ft__c;
                    }
                    if(ut.Parking_Bay_Allocation_No__c   != null){
                        wrap.parkingBays = ut.Parking_Bay_Allocation_No__c  ;
                    }
                    if(ut.Plot_Number__c != null){
                        wrap.plotNumber = ut.Plot_Number__c;
                    }else{
                        wrap.plotNumber = '';
                    }
                    if(ut.Id != null){
                        wrap.sfUnitId = ut.Id;
                    }
                    if(ut.Mobile_App_Tower__c != null){
                        wrap.sfTowerId = ut.Mobile_App_Tower__c;
                    }
                    /*if(ut.Tower__c != null){
                        wrap.sfTowerId = ut.Tower__c;
                    }*/
                    if(ut.Project__c != null){
                        wrap.sfMasterCommunityId = ut.Project__c;
                    }
                    if(ut.View_Type__c != null){
                        wrap.views = ut.View_Type__c;
                    }
                }
                wraplst.add(wrap);
            }
            
            if(wraplst != null){
                response = MobileIntegrationCallOutsAPI.callMobileApp(endPointURL,methodType,JSON.serialize(wraplst[0]));
                system.debug('response '+response);
            }
        }catch(Exception e){
            errorMessage = e.getMessage();
            statusCode = 400;
        }
        
        Mobile_ApiUtility.createMobileAPILogs('UnitTriggerHandler','UnitTriggerHandler',JSON.serialize(wraplst),response,errorMessage,statusCode);
        
    }
    
    class requestBodyWrapper{
        //string name;
        String floorNumber;
        string unitType;
        string unitName; //Name of the unit
        Decimal unitPrice;
        String unitNumber; // DLD unit no
        boolean isNotAvailableForSale;
        String availabilityStatus;
        String DLDBuildingNumber; //DLD_Building_Number__c
        Decimal noOfBedrooms;// No_of_Bedroom__c
        String permittedUse;// Permitted_Use__c
        String projectPropertyType;
        Decimal noOfParkings;
        String propertyType;
        String parkingType;
        Decimal totalArea;
        Decimal saleableArea;
        Decimal plotArea;
        /*   String bookingID; 
String bookingStatus;
String bookingName;
String customerName;
String customerEmail; */
        //   Date handoverDate; // pending
        //   Date actualHandoverDate;
        //    boolean isHandoverCompleted; //pending
        Decimal RERAApplicableArea;
        String plotNumber;
        String sfUnitId;
        String sfCommunityId;
        String sfTowerId;
        String sfMasterCommunityId;
        String views;
        String parkingBays;
        //   Date dlpDate;
    }
  /*  public static void updateSalesVP(List<Unit__c> unitList, Map<Id,Unit__c> oldMap){
        String managerId = [select id,managerId from user where id =: userinfo.getUserId()].managerId;
        for(Unit__C u : unitList){
            if(u.Unit_Hold_Requested__c == true && u.Unit_Hold_Requested__c != oldMap.get(u.id).Unit_Hold_Requested__c){
                u.Sales_VP_For_Approval__c = managerId;
            }
        }
    }
    public static void calculateHours(List<Unit__c> unitList, Map<Id,Unit__c> oldMap){
        for(Unit__C u : unitList){
            if(u.Unit_Hold_Request_Status__c == 'Approved' && u.Unit_Hold_Request_Status__c != oldMap.get(u.id).Unit_Hold_Request_Status__c){
                if(u.Request_Time__c.contains('Hour')){
                    u.Hours_To_Validate_PR_Availability__c = Integer.valueOf(u.Request_Time__c.split(' ')[0]);
                }else{
                    u.Hours_To_Validate_PR_Availability__c =  Integer.valueOf(u.Request_Time__c.split(' ')[0])*24;
                }
            }
        }
    } */
    public static void invalidateUnit_Hold_Request(List<Unit__c> newList, Map<Id,Unit__c> oldMap){
        List<Unit__c> listOfUnit = new List<Unit__c>();
        for(Unit__c u : newList){
            if(u.unit_status__c != oldMap.get(u.id).unit_status__c 
            && u.unit_status__c == 'Available'){
                Unit__c uObj = new Unit__c(id=u.id);
                uObj.Time_To_Validate_PR__c = null; 
                listOfUnit.add(uObj);
            }
        }
        if(listOfUnit.size()> 0) update listOfUnit;
        List<unit_hold__c> uhList = [SELECT ID FROM Unit_Hold__C WHERE Unit__c IN: listOfUnit AND status__c = 'Active'];
        for(unit_hold__c uh: uhList){
            uh.status__c = 'inactive';
        }
        if(uhList.size()>0)update uhList;
        
    }
}