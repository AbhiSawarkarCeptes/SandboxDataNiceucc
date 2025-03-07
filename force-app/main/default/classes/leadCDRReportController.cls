/***************
Name: leadCDRReportController
Author: PR-SHOBA
Description: Used to get the Lead report along with opportunity and it is 
    called from LWC component 'leadCDRReportDashboard'
******************/
public class leadCDRReportController {
	
    @AuraEnabled
    public static String getCDRLeadRecords(){
        try{
            Map<String, List<CDR__c>> mapCDRReport = new Map<String, List<CDR__c>>();
            Map<String, Integer> leadCountMap = new Map<String, Integer>();
            Map<String, Integer> oppLeadCountMap = new Map<String, Integer>();
            Map<String, String> leadIdWithSaleAgntMap = new Map<String, String>();
            List<String> leadConvertedList = new List<String>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<leadCDRWrapper> leadCDRWrapperList = new List<leadCDRWrapper>();
            Map<string, metaDataWrapper> teamTelesaleMap = new Map<String, metaDataWrapper>();
            
            date todayDate = date.Today();
            List<Lead> leadList = [Select Id, IsConverted, Presales_Agent__r.Name, Name, Lead_Id__c, Status, (select Id, Duration__c from CDRS__r) from Lead WHERE createdDate >=: todayDate];
            List<Lead_CDR_Report_Configuration__mdt> configList =[Select MasterLabel, Team__c, Telesales_Team__c from Lead_CDR_Report_Configuration__mdt];
            
            if(leadList.size()>0){
                if(configList.size()>0){
                	teamTelesaleMap = getTeamAndTeleSaleDetails(configList);
                }
                for(Lead ld: leadList){
                    if(ld.IsConverted){
                        leadConvertedList.add(ld.Lead_Id__c);
                        leadIdWithSaleAgntMap.put(ld.Presales_Agent__r.Name, ld.Lead_Id__c);
                    }
                    if(leadCountMap.containsKey(ld.Presales_Agent__r.Name)){
                        leadCountMap.put(ld.Presales_Agent__r.Name, leadCountMap.get(ld.Presales_Agent__r.Name)+1);
                    } else {
                        leadCountMap.put(ld.Presales_Agent__r.Name, 1);
                    }
                    if(mapCDRReport.containsKey(ld.Presales_Agent__r.Name)){
                        List<CDR__c> newCDRList = generateMapList(ld.CDRS__r);
                        list<CDR__c> cdList = mapCDRReport.get(ld.Presales_Agent__r.Name);
                        cdList.addAll(newCDRList);
                        mapCDRReport.put(ld.Presales_Agent__r.Name, cdList);
                    } else {
                        List<CDR__c> newCDRList = generateMapList(ld.CDRS__r);
                        mapCDRReport.put(ld.Presales_Agent__r.Name, newCDRList);
                    }
                }
                
                if(leadConvertedList.size()>0){
                    oppList = [Select Id, Lead_Id__c from Opportunity where Lead_Id__c IN:leadConvertedList];
                    if(oppList.size()>0){
                        for(Opportunity opp: oppList){
                            if(oppLeadCountMap.containsKey(opp.Lead_Id__c)){
                                oppLeadCountMap.put(opp.Lead_Id__c, oppLeadCountMap.get(opp.Lead_Id__c)+1);
                            } else {
                                oppLeadCountMap.put(opp.Lead_Id__c, 1);
                            }
                        }
                    }
                }
                
                for(String mapKey: teamTelesaleMap.keyset()){
                    Integer Duration = 0; Integer convertOpp =0; Integer totalLead =0;
                    String team = null; String teleSaleTeam = null;
                    
                    if(mapCDRReport.containsKey(mapKey)){
                    	List<CDR__c> newClist = mapCDRReport.get(mapKey);
                        if(newClist.size()>0){
                            for(CDR__c c: newClist){
                                if(c.Duration__c!=null){
                                    Duration = Duration+Integer.valueOf(c.Duration__c);
                                }
                            }
                        }
                    }
                   
                    if(leadCountMap.containsKey(mapKey)){
                        totalLead = leadCountMap.get(mapKey);
                    }
                    team = teamTelesaleMap.get(mapKey).team;
                    teleSaleTeam = teamTelesaleMap.get(mapKey).teleSaleTeam;
                    convertOpp = getConvertedOpp(mapKey, leadIdWithSaleAgntMap, oppLeadCountMap);
                    leadCDRWrapper wrp = new leadCDRWrapper();
                    wrp.preSaleAgentName = mapKey;
                    wrp.totalLeads = totalLead;
                    wrp.duration = Duration;
                    wrp.convertedOpportunity = convertOpp;
                    wrp.team = team;
                    wrp.teleSaleTeam = teleSaleTeam;
                    system.debug('~~'+wrp);
                    leadCDRWrapperList.add(wrp);
                }
            }
            return JSON.serialize(leadCDRWrapperList);
        } catch (Exception e) {
            system.debug('~~~~'+e.getMessage()+'~~~'+e.getStackTraceString());
            throw new AuraHandledException('Error on Apex catch: '+ e.getMessage());
        }
    }
    
    public static Map<string, metaDataWrapper> getTeamAndTeleSaleDetails(List<Lead_CDR_Report_Configuration__mdt> configList){
        Map<string, metaDataWrapper> mapData = new Map<string, metaDataWrapper>();
        for(Lead_CDR_Report_Configuration__mdt cf: configList){
            metaDataWrapper mtc = new metaDataWrapper();
            mtc.team = cf.Team__c;
            mtc.teleSaleTeam = cf.Telesales_Team__c;
            mapData.put(cf.MasterLabel, mtc);
        }
        return mapData;
    }
    
    public static Integer getConvertedOpp(String preSaleAgentName, Map<String, String> leadIdWithSaleAgntMap, Map<String, Integer> oppLeadCountMap){
        Integer oppConverted =0;
        if(leadIdWithSaleAgntMap.containsKey(preSaleAgentName)){
            String leadId = leadIdWithSaleAgntMap.get(preSaleAgentName);
            if(oppLeadCountMap.containsKey(leadId)){
                oppConverted = oppLeadCountMap.get(leadId);
            }
        }
        return oppConverted;
    }
    
    public static List<CDR__c> generateMapList(List<CDR__c> cdrList){
        List<CDR__c> newCDRList = new List<CDR__c>();
        if(cdrList.size()>0){
            newCDRList = cdrList;
        } else {
            CDR__c cd = new CDR__c(Duration__c='0');
            newCDRList.add(cd);
        }
        return newCDRList;
    }
    
    public class leadCDRWrapper {
        @AuraEnabled public String preSaleAgentName;
        @AuraEnabled public Integer totalLeads;
    	@AuraEnabled public Integer duration;
        @AuraEnabled public Integer convertedOpportunity;
        @AuraEnabled public String team;
        @AuraEnabled public String teleSaleTeam;
    }
    
    public class metaDataWrapper{
        public String team;
        public String teleSaleTeam;
    }
    
}