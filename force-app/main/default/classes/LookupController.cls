public class LookupController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, String objectName, String filters, String recordId, String fields) {

        Integer limitNum = 20;

        String finalQuery = 'SELECT ' + fields + ' FROM ' + objectName;

        if(String.isBlank(recordId)){
            if(String.isNotBlank(searchTerm)){
                finalQuery += ' WHERE Name Like  \'%' + searchTerm + '%\' ';
            }
            
            if(String.isNotBlank(filters)){
                finalQuery += String.isNotBlank(searchTerm) ? ' AND ' : ' WHERE ';
                finalQuery += filters;
            }
        }else{
            finalQuery += ' WHERE Id =  \'' + recordId + '\'';
        }

        finalQuery+= ' LIMIT ' + limitNum;

        System.debug('Final Query::::' + finalQuery);

        List<sObject> lookUpList = database.query(finalQuery);

        return lookUpList;  
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUpSearch(String searchTerm, string myObject, String filter){
        System.debug('lookupSearch'+searchTerm);
        System.debug('myObject : '+myObject);
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
    
}