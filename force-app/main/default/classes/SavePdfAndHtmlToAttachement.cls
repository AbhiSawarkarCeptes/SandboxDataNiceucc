global class SavePdfAndHtmlToAttachement {
    WebService static void doSaveReceipt(String Objid, String pagename){
        String frameSrc = '/apex/'+pagename+'?id=' + Objid+'&type=Receipt';
        String aName = pagename;
        String nameSubstring = aName +'.pdf';
        List<Attachment> aList = new List<Attachment>();
        List<Attachment> attachList = [select id,name,body from Attachment where parentId=:Objid and (name LIKE :nameSubstring) limit 2];
        if(attachList !=Null && attachList.size() == 1) {
            for(Attachment attach : attachList) {
                Attachment a1;
                if((String.valueOf(attach.name)).containsIgnorecase('pdf'))
                    a1 = new Attachment(id=attach.id,name=attach.name);
                PageReference p1 = new PageReference(frameSrc); 
                if(!Test.isRunningTest()){
                    a1.body = p1.getContentAsPDF();
                }else{
                    a1.body = Blob.valueof('Test');
                }  
                aList.add(a1); 
            }
            upsert aList; 
        } 
        if(attachList !=Null && attachList.size() == 0) {
            PageReference p1 = new PageReference(frameSrc);
            Attachment a1 = new Attachment();
            a1.parentId = Objid; 
            a1.name = aName +'.pdf';
            if(!Test.isRunningTest()){
                a1.body = p1.getContentAsPDF();
            } else
                a1.body = Blob.valueof('Test');
            aList.add(a1);        
            upsert aList; 
        }  
    }
    
     WebService static void doSaveAgreement(String Objid, String pagename){
        String frameSrc = '/apex/'+pagename+'?id=' + Objid+'&type=Agreement';
        String aName = pagename;
        String nameSubstring = aName +'.pdf';
        List<Attachment> aList = new List<Attachment>();
        List<Attachment> attachList = [select id,name,body from Attachment where parentId=:Objid and (name LIKE :nameSubstring) limit 2];
        if(attachList !=Null && attachList.size() == 1) {
            for(Attachment attach : attachList) {
                Attachment a1;
                if((String.valueOf(attach.name)).containsIgnorecase('pdf'))
                    a1 = new Attachment(id=attach.id,name=attach.name);
                PageReference p1 = new PageReference(frameSrc); 
                if(!Test.isRunningTest()){
                    a1.body = p1.getContentAsPDF();
                }else{
                    a1.body = Blob.valueof('Test');
                }  
                aList.add(a1); 
            }
            upsert aList; 
        } 
        if(attachList !=Null && attachList.size() == 0) {
            PageReference p1 = new PageReference(frameSrc);
            Attachment a1 = new Attachment();
            a1.parentId = Objid; 
            a1.name = aName +'.pdf';
            if(!Test.isRunningTest()){
                a1.body = p1.getContentAsPDF();
            } else
                a1.body = Blob.valueof('Test');
            aList.add(a1);        
            upsert aList; 
        }  
    }
    
     WebService static void doSave(String Objid, String pagename){
        
        String frameSrc = '/apex/'+pagename+'?id='+Objid+'&renderpdf=false';
        system.debug('#@#@frameSrc@#@#'+frameSrc);
        String aName = pagename;
        String nameSubstring = aName +'.pdf';
        String htmlNameSubstring = aName +'.html';
        List<Attachment> aList = new List<Attachment>();//and name =: aName
        List<Attachment> attachList = [select id,name,body from Attachment where parentId=:Objid and (name LIKE :nameSubstring Or name LIKE :htmlNameSubstring) limit 2];
        system.debug('#@#@attachList@#@#'+attachList.size()+'***'+attachList);
        system.debug('#@#@nameSubstring@#@#'+nameSubstring);
        system.debug('#@#@htmlNameSubstring@#@#'+htmlNameSubstring);
        if(attachList.size() == 2 && attachList !=Null)
        {
            boolean htmlFlag = false;
            for(Attachment attach : attachList)
            {
                Attachment a1;
                if((String.valueOf(attach.name)).containsIgnorecase('pdf'))
                    a1 = new Attachment(id=attach.id,name=attach.name);
                else if((String.valueOf(attach.name)).containsIgnorecase('html'))
                    a1 = new Attachment(id=attach.id,name=attach.name);
                //else
                //{
                PageReference p1 = new PageReference(frameSrc); 
                
                if(!Test.isRunningTest()){
                    a1.body = p1.getContentAsPDF();
                    if(htmlFlag)
                        a1.body = p1.getContent();
                    system.debug('+++p1.getContent()+2+++'+p1.getContent());
                    
                    htmlFlag = true;
                }else{
                    a1.body = Blob.valueof('Test');
                }
                // } 
                aList.add(a1); 
            }
            system.debug('#@#@aList@#@#'+aList.size());
            system.debug('#@#@aList@#@#'+aList);
            upsert aList;
            
        } 
        
        if(attachList.size() == 1 && attachList!=Null)
        {
            Attachment a1;
            PageReference p1 = new PageReference(frameSrc); 
            boolean htmlFlag = false;
            if((String.valueOf(attachList[0].name)).containsIgnorecase('pdf'))
            {
                a1 = new Attachment(id=attachList[0].id,name=attachList[0].name);
            }
            else if((String.valueOf(attachList[0].name)).containsIgnorecase('html'))
            {
                a1 = new Attachment(id=attachList[0].id,name=attachList[0].name);
                htmlFlag = true;
            }
            else
            {
                if(a1 == null)
                {
                    a1      = new attachment();
                    a1.parentId = Objid; 
                    a1.name = aName +'.pdf';
                }
                if(!Test.isRunningTest())
                {
                    if(htmlFlag)
                        a1.body = p1.getContent();
                    else
                        a1.body = p1.getContentAsPDF();
                    
                }else{
                    a1.body = Blob.valueof('Test');
                }
            } 
            aList.add(a1); 
            
            //insert second
            Attachment a2 = new Attachment();
            
            if(htmlFlag)
            {
                a2.parentId = Objid; 
                a2.name = aName +'.pdf';
                if(!Test.isRunningTest())
                    a2.body = p1.getContentAsPDF();
                else
                    a2.body = Blob.valueof('Test');
            }
            else {
                a2.parentId = Objid; 
                a2.name = aName +'.html';
                if(!Test.isRunningTest()){
                    
                    a2.body = p1.getContent();
                    system.debug('++p1.getContent()+++++'+p1.getContent());
                } else
                    a2.body = Blob.valueof('Test');
                system.debug('++a2.body+2+++++'+a2.body);
            }
            
            aList.add(a2); 
            system.debug('#@#@aList@#@#'+aList.size());
            system.debug('#@#@aList@#@#'+aList);
            upsert aList;
        }
        
        system.debug('#####test####%$%$%$');
        if(attachList.size() == 0 && attachList !=Null)
        {
            system.debug('#####test####');
            PageReference p1 = new PageReference(frameSrc); 
            system.debug('#####p1####'+p1);
            Attachment a1 = new Attachment();
            a1.parentId = Objid; 
            a1.name = aName +'.pdf';
            if(!Test.isRunningTest()){
                system.debug('+++p1.getContentAsPDF+1++'+p1.getContentAsPDF());
                a1.body = p1.getContentAsPDF();
            }else
                a1.body = Blob.valueof('Test');
            
            aList.add(a1); 
            
            system.debug('#####a1####'+a1);       
            Attachment a2 = new Attachment();
            a2.parentId = Objid; 
            a2.name = aName +'.html';
            if(!Test.isRunningTest()){
                
                a2.body = p1.getContent();
                system.debug('++p1.getContent() 1+++'+p1.getContent());
            } else
                a2.body = Blob.valueof('Test');
            system.debug('+++a2.body+1+++'+string.valueof(a2.body));
            aList.add(a2); 
            system.debug('#####a2####'+a2);   
            system.debug('#@#@aList@#@#'+aList.size());
            upsert aList; 
        }  
    }

}