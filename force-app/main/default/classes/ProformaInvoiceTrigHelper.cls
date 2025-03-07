/*********************************************************************
 * Class Name  :   ProformaInvoiceTrigHelper
 * Description :   Helper Class of ProformaInvoiceTrigger
 * Created Date:   02/04/2024
 * Authored By :   CloudSteer Technology Pte Ltd
 * -------------------------------------------------------------------
 * Version History : 
   Created By       :   Nishank Manwani
   Last Modified By :   Nishank Manwani 02/04/2024
 *********************************************************************/

public class ProformaInvoiceTrigHelper {

    //Added by Nishank Manwani on 02/04/2024 to add validation to check single property is present on enquiry or not
    public static void validationPropCheckOnEnq(List<Proforma_Invoice__c> piList) {
        Set<Id> enqList = new Set<Id>();
        for(Proforma_Invoice__c piRec : piList) {
            if(piRec.Enquiry__c != null) {
                enqList.add(piRec.Enquiry__c);
            }
        }

        if(!enqList.isEmpty()) {
            Map<Id, PropStrength__Request__c> enqMap = new Map<Id, PropStrength__Request__c>([SELECT Id, PropStrength__Selected_Property_Ids__c FROM PropStrength__Request__c 
                                                                                                WHERE Id IN :enqList]);

            for(Proforma_Invoice__c piRec : piList) {
                if(piRec.Enquiry__c != null && enqMap.get(piRec.Enquiry__c).PropStrength__Selected_Property_Ids__c == null ) {
                    piRec.addError('Please select a property on Enquiry');
                }
                if(enqMap.get(piRec.Enquiry__c).PropStrength__Selected_Property_Ids__c != null && enqMap.get(piRec.Enquiry__c).PropStrength__Selected_Property_Ids__c.contains(',')) {
                    piRec.addError('Please select single property on Enquiry');
                }
            }
        }
    }
}