public class X_RequestMetadata {
    public Xpedeon_API_Metadata__mdt metadataAPI{get; private set;}
    public List<Xpedeon_Metadata_Headers__mdt> metadataHeaders{get;private set;}
    public List<Xpedeon_Static_Data__mdt> staticMetadata{get;private set;}
     public List<Xpedeon_Static_Value_Mapping__mdt> staticValueMetadata{get;private set;}
    
    public X_RequestMetadata(String requestName){
        this.metadataAPI = Xpedeon_API_Metadata__mdt.getInstance(requestName);
        this.metadataHeaders = getMetadataHeaders(this.metadataAPI.Id);
        this.staticMetadata = getMetadataStaticData(this.metadataAPI.Id);
        this.staticValueMetadata = getmetadataStaticValueData(this.metadataAPI.Id);
    }
    
    static List<Xpedeon_Metadata_Headers__mdt> getMetadataHeaders(String parentId){
        List<Xpedeon_Metadata_Headers__mdt> retValues = new List<Xpedeon_Metadata_Headers__mdt>();
        
        for(Xpedeon_Metadata_Headers__mdt header : Xpedeon_Metadata_Headers__mdt.getAll().values()){
            if(header.Xpedeon_API_Metadata__c == parentId){
                retValues.add(header);
            }
        }
        
        return retValues;
    }
    
    static List<Xpedeon_Static_Data__mdt> getMetadataStaticData(String parentId){
        List<Xpedeon_Static_Data__mdt> retValues = new List<Xpedeon_Static_Data__mdt>();
        
        for(Xpedeon_Static_Data__mdt header : Xpedeon_Static_Data__mdt.getAll().values()){
            if(header.Xpedeon_API_Metadata__c == parentId){
                retValues.add(header);
            }
        }
        
        return retValues;
    }
    
    static List<Xpedeon_Static_Value_Mapping__mdt> getmetadataStaticValueData(String parentId){
        List<Xpedeon_Static_Value_Mapping__mdt> retValues = new List<Xpedeon_Static_Value_Mapping__mdt>();
        
        for(Xpedeon_Static_Value_Mapping__mdt header : Xpedeon_Static_Value_Mapping__mdt.getAll().values()){
            if(header.Xpedeon_API_Metadata__c == parentId){
                retValues.add(header);
            }
        }
        
        return retValues;
    }
    
}