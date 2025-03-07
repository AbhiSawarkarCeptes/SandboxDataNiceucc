public with sharing class ImageFile {

    public Document doc {get; set;}
    public String url {get; set;}
    
    public ImageFile(Document docc, String urll) {
        doc = docc;
        url = urll; 
    }  
}