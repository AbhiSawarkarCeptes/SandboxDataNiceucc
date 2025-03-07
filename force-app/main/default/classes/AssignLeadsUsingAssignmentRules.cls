public class AssignLeadsUsingAssignmentRules {
	@future
	 public static void LeadAssign(List < Id > LeadIds) {
	
	  system.debug('inside lead assignment rules method' + LeadIds);
	  Database.DMLOptions dmo = new Database.DMLOptions();
	  dmo.assignmentRuleHeader.useDefaultRule = true;
	  Lead Leads = [select id, ownerId from lead where lead.id in : LeadIds];
	  Leads.setOptions(dmo);
	  update Leads;
	  List < lead > leadList = new List < Lead > ();
	  leadList = [select id, ownerId from lead where lead.id in : LeadIds];

 	}
 

}