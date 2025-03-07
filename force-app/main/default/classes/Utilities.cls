global with sharing class Utilities {
   
    public static string secParameter;
    public static String changeToWords(String numb, boolean isCurrency){
        //String val = "", wholeNo = numb, points = "", andStr = "", pointStr="";
        String val ='';
        String wholeNo = numb;
        String points ='';
        String andStr ='';
        String pointStr ='';
        String endStr = (isCurrency) ? ('Only') : ('');
        integer decimalPlace = numb.IndexOf('.');
        log('>>>'+decimalPlace);
        if (decimalPlace > 0){
            wholeNo = numb.Substring(0, decimalPlace);
            points = numb.Substring(decimalPlace+1);
            log('>>>'+points);
       system.debug('=====point==='+points);
            if(points != '' && Integer.valueof(points) > 0){
                andStr = (isCurrency)?('Dhiram'):('point');
                endStr = (isCurrency) ? ('fils '+endStr) : ('');
                pointStr = translateCents(points);
            }
        }
        val = translateWholeNumber(wholeNo).Trim() + ' ' + andStr + pointStr + ' ' + endStr;
        log('>>> val: '+val);
       
        return val;
    }
    
    public static  String translateWholeNumber(String num){
        string word = '';
        boolean beginsZero = false;//tests for 0XX
        boolean isDone = false;//test if already translated
        log('>>> num: '+num);
        if((num != '' || num != null) && num.Substring(0, 1) == '-')
         num = num.Substring(1,num.Length());
        log('>>> num Now: '+num);
        double dblAmt = (num == '' || num == null) ? 0.0 : Double.valueof(num);
        if (dblAmt == 0)  return '';
        integer pos = 0;//store digit grouping
        String place = '';//digit grouping name:hundres,thousand,etc...
        //if ((dblAmt > 0) && number.StartsWith("0"))
        if (dblAmt < 0) dblAmt = -1*dblAmt;
        if (dblAmt > 0){//test for zero or digit zero in a nuemric
           
            log('>>> dblAmt: '+dblAmt);
           
            
            beginsZero = num.StartsWith('0');
            
            while(num.StartsWith('0')){
                if(num.Length() != 0)
                    num = num.subString(1,num.Length());
            }
            integer numDigits = num.Length();
            log('>>> numDigits: '+numDigits);
            //integer pos = 0;//store digit grouping
            //String place = '';//digit grouping name:hundres,thousand,etc...
            if(numDigits==1){
                word = ones(num);
                isDone = true;
            }
            if(numDigits==2){
                word = tens(num);
                isDone = true;
            }
            if(numDigits==3){
                pos=math.mod(numDigits, 3) +1;
                place = ' Hundred ';
            }
            if(numDigits==4 || numDigits==5 || numDigits == 6){
                pos=math.mod(numDigits, 4) +1;
                place = ' Thousand ';
            }
            /*if (numDigits == 6 && numDigits != 7) {
                pos=math.mod(numDigits, 6) +1;
                place = ' Million ';
            }*/
            if (numDigits == 7 || numDigits==8 ||numDigits==9) {
                pos=math.mod(numDigits, 7) +1;
                place = ' Million ';
            }
            /*if(numDigits==8 ||numDigits==9){
                pos=math.mod(numDigits, 8) +1;
                place = ' Crore ';
            }*/
            if(numDigits==10){
                pos=math.mod(numDigits, 10) +1;
                place = ' Billion ';
            }
            log('>>>place: '+place);
       
            //add extra case options for anything above Billion...
            if(place == '' ){
                isDone = true;
            }
        }
        if (!isDone){//if transalation is not done, continue...(Recursion comes in now!!)
            word = translateWholeNumber(num.Substring(0, pos)) +
                place + translateWholeNumber(num.Substring(pos));
            log('>>> word: '+word.trim());
            //check for trailing zeros
            if (beginsZero) word = ' and ' + word.Trim();
        }
        //ignore digit grouping names
        if (word == null || word.Trim().Equals(place.Trim())) word = '';
       
        return word.Trim();
    }
    
    public static  String tens(String digit){
        integer digt = integer.valueof(digit);
       
        log('>>>digt: ' + digt);
       
        String name = null;
        if(digt==10){
            name = 'Ten';
        }
        if(digt==11){
            name = 'Eleven';
        }
        if(digt==12){
            name = 'Twelve';
        }
        if(digt==13){
            name = 'Thirteen';
        }
        if(digt==14){
            name = 'Fourteen';
        }
        if(digt==15){
            name = 'Fifteen';
        }
        if(digt==16){
            name = 'Sixteen';
        }
        if(digt==17){
            name = 'Seventeen';
        }
        if(digt==18){
            name = 'Eighteen';
        }
        if(digt==19){
            name = 'Nineteen';
        }
        if(digt==20){
            name = 'Twenty';
        }
        if(digt==30){
            name = 'Thirty';
        }
        if(digt==40){
            name = 'Forty';
        }
        if(digt==50){
            name = 'Fifty';
        }
        if(digt==60){
            name = 'Sixty';
        }
        if(digt==70){
            name = 'Seventy';
        }
        if(digt==80){
            name = 'Eighty';
        }
        if(digt==90){
            name = 'Ninety';
        }
       
        if (name <> null && name <> '' && digt > 0) {
            if(digt > 10 && digt < 20 )
                name = name;
            else
            name = name + ones(digit.Substring(1));
        }
        else {
            if (digt > 0){
                name = tens(digit.Substring(0, 1) + '0') + ' ' + ones(digit.Substring(1));
            }
        }
        return name;
    }
    public static  String ones(String digit){
        log('>>>digt in ones: ' + digit);
        if (digit == '') return '';
        integer digt = integer.valueof(digit);
       
        String name = '';
        if(digt==1){
            name = 'One';
        }
        if(digt==2){
            name = 'Two';
        }
        if(digt==3){
            name = 'Three';
        }
        if(digt==4){
            name = 'Four';
        }
        if(digt==5){
            name = 'Five';
        }
        if(digt==6){
            name = 'Six';
        }
        if(digt==7){
            name = 'Seven';
        }
        if(digt==8){
            name = 'Eight';
        }
        if(digt==9){
            name = 'Nine';
        }
        return name;
    }
    public static  String translateCents(String cents){
        String cts = '', digit = '', engOne = '';
        
        cts = ' ' + tens(cents);
        return cts;
    }
   
    public static void log(String msg) {
        //System.debug(msg);
    }
    
    
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        system.debug('fieldSetName::'+fieldSetName);
        system.debug('ObjectName::'+ObjectName);
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
                Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
          
        return fieldSetObj.getFields(); 
    }  
  
    
    public String line(String[] cells) {
        return String.join(cells, ',') + '\n';
    }
    
    public String format(Date d)    {
        return d != null ? '"' + d.format().escapeCsv() + '"' : '""';
    }
    
    public String format(String s) {
        return s != null ? '"' + s.escapeCsv() + '"' : '""';
    }
    
    public String format(Decimal d, Integer scale) {
        return d != null ? String.valueOf(d.setScale(scale)) : '';
    }
    
    public String format(Decimal d) {
        return format(d, 2);
    }
    
      Webservice static void doSavePDFAttachment(String Objid, String pagename, string fileName){
       
        List < Attachment > attachList = new List <Attachment> ();
        String frameSrcHTML = '/apex/' + pagename + '?id=' + Objid + '&renderpdf=false';
        String frameSrcPdf = '/apex/' + pagename + '?id=' + Objid;
        if(secParameter != null){
            frameSrcHTML+= '&'+secParameter;
            frameSrcPdf+= '&'+secParameter;
        }
        fileName = fileName == null ? pagename : fileName;
        String aName = fileName;
        String nameSubstring = aName + '.pdf';
        String htmlNameSubstring = aName + '.html';
        List < Attachment > aList = new List < Attachment > (); 
        attachList = [select id, name, body from Attachment where parentId =: Objid and(name LIKE: nameSubstring Or name LIKE: htmlNameSubstring) limit 2];
        
       PageReference p1 = new PageReference(frameSrcPdf);
        PageReference p2 = new PageReference(frameSrcHTML);
        if (attachList.size() == 2) {
            boolean htmlFlag = false;
            for (Attachment attach: attachList) {
                Attachment a1;
                if ((String.valueOf(attach.name)).containsIgnorecase('pdf'))
                    a1 = new Attachment(id = attach.id, name = attach.name);
                else if ((String.valueOf(attach.name)).containsIgnorecase('html')) {
                    a1 = new Attachment(id = attach.id, name = attach.name);
                    htmlFlag = true;
                }
        
        
        
                if (!Test.isRunningTest()) {
                    a1.body = p1.getContentAsPDF();
                    if (htmlFlag) {
                        a1.body = p2.getContent();
                        htmlFlag = false;
                    }
                    system.debug('+++p1.getContent()+2+++' + p1.getContent());
        
        
                } else {
                    a1.body = Blob.valueof('Test');
                }
                aList.add(a1);
            }
            system.debug('#@#@aList@#@#' + aList.size());
            upsert aList;
        
        }
        
        if (attachList.size() == 1 && attachList != Null) {
            Attachment a1;
            boolean htmlFlag = false;
            if ((String.valueOf(attachList[0].name)).containsIgnorecase('pdf')) {
                a1 = new Attachment(id = attachList[0].id, name = attachList[0].name);
            } else if ((String.valueOf(attachList[0].name)).containsIgnorecase('html')) {
                a1 = new Attachment(id = attachList[0].id, name = attachList[0].name);
                htmlFlag = true;
            } else {
                if (a1 == null) {
                    a1 = new attachment();
                    a1.parentId = Objid;
                    a1.name = aName + '.pdf';
                }
                if (!Test.isRunningTest()) {
                    if (htmlFlag)
                        a1.body = p2.getContent();
                    else
                        a1.body = p1.getContentAsPDF();
        
                } else {
                    a1.body = Blob.valueof('Test');
                }
            }
            aList.add(a1);
        
            Attachment a2 = new Attachment();
        
            if (htmlFlag) {
                a2.parentId = Objid;
                a2.name = aName + '.pdf';
                if (!Test.isRunningTest())
                    a2.body = p1.getContentAsPDF();
                else
                    a2.body = Blob.valueof('Test');
            } else {
                a2.parentId = Objid;
                a2.name = aName + '.html';
                if (!Test.isRunningTest()) {
        
                    a2.body = p2.getContent();
                    system.debug('++p1.getContent()+++++' + p1.getContent());
                } else
                    a2.body = Blob.valueof('Test');
                system.debug('++a2.body+2+++++' + a2.body);
            }
        
            aList.add(a2);
            system.debug('#@#@aList@#@#' + aList.size());
            upsert aList;
        }
        
        system.debug('#####test####%$%$%$');
        if (attachList.size() == 0 && attachList != Null) {
            system.debug('#####test####');
            system.debug('#####p1####' + p1);
            Attachment a1 = new Attachment();
            a1.parentId = Objid;
            a1.name = aName + '.pdf';
            if (!Test.isRunningTest()) {
                a1.body = p1.getContentAsPDF();
            } else
                a1.body = Blob.valueof('Test');
        
            aList.add(a1);
        
            system.debug('#####a1####' + a1);
            Attachment a2 = new Attachment();
            a2.parentId = Objid;
            a2.name = aName + '.html';
            if (!Test.isRunningTest()) {
                a2.body = p2.getContent();
            } else
                a2.body = Blob.valueof('Test');
            system.debug('+++a2.body+1+++' + string.valueof(a2.body));
            aList.add(a2);
            system.debug('#####a2####' + a2);
            system.debug('#@#@aList@#@#' + aList.size());
            upsert aList;
        } 
        
      
    }
        
}