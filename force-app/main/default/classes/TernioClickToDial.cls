public with sharing class TernioClickToDial {
    private final Id Id;
    private final Id recordId;
    public List<Map<String, String>> PhoneFields { get; set; }
    
    public TernioClickToDial (ApexPages.StandardController controller) {
        SObject obj = controller.getRecord();
        Id = obj.Id;
        recordId = ApexPages.currentPage().getParameters().get('id');
        System.debug('recordId' +recordId);
        List<Map<String,String>> phone_fields = Nice_ClickToDialUtility.getPhoneFields((string)Id);
        // this loop is to ensure that the entire `List<Map<String,String>>` has the minimum fields we expect.
        // the first item in the list is a map with `HasViewAccess: boolean`. Unsure if this is to be incorporated at this stage.
        for (Integer i = phone_fields.size()-1; i >= 0; i--)
        {
            Map<String,String> phone_field = phone_fields[i];
            if(!phone_field.containsKey('value') && !phone_field.containsKey('label'))
            {
                phone_fields.remove(i);
            }
        }
        PhoneFields = phone_fields;
    }
}