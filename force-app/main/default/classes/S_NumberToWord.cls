public without sharing class S_NumberToWord {

    public static integer intNum;     // for integer part
    public static integer decNum;     // for decimal part
    public static String numInWords; // For currency in Words

    // Can be customized to Rupees and Paisa, Pounds and penny, etc based on req.
    public static String bigCurrencySingular    = ' Dirham ';
    public static String bigCurrencyplural      = ' Dirhams ';
    public static String smlCurrencySingular    = ' Fils ';
    public static String smlCurrencyplural      = ' Fils ';

    public static String[]  ones = new string[] {  'Zero ',  'One ',  'Two ',  'Three ',  'Four ',  'Five ',  'Six ',  'Seven ',  'Eight ',  'Nine ',  'Ten ',  'Eleven ',  'Twelve ',  'Thirteen ',  'Fourteen ',  'Fifteen ',  'Sixteen ',  'Seventeen ',  'Eighteen ',  'Nineteen ' };
    public static String[]  tens = new string[] {  ' ',  'Ten ',  'Twenty ',  'Thirty ',  'Forty ',  'Fifty ',  'Sixty ',  'Seventy ',  'Eighty ',  'Ninety ' };
    public static integer[] base = new integer[]{0,1,10,100,1000,1000,1000,1000000,1000000,1000000,1000000000};
    public static String[]  unit = new String[] { ' ', ' ', ' ', 'Hundred ', 'Thousand ', 'Thousand ', 'Thousand ', 'Million ', 'Million ', 'Million ', 'Billion ', 'Billion ', 'Billion ', 'Trillion '};


    public static List<String> wordsUpto99 = new List<String>();
    
    public static void config() {
        wordsUpTo99.add('Zero');
        wordsUpTo99.add('One');
        wordsUpTo99.add('Two');
        wordsUpTo99.add('Three');
        wordsUpTo99.add('Four');
        wordsUpTo99.add('Five');
        wordsUpTo99.add('Six');
        wordsUpTo99.add('Seven');
        wordsUpTo99.add('Eight');
        wordsUpTo99.add('Nine');
        wordsUpTo99.add('Ten');
        wordsUpTo99.add('Eleven');
        wordsUpTo99.add('Twelve');
        wordsUpTo99.add('Thirteen');
        wordsUpTo99.add('Fourteen');
        wordsUpTo99.add('Fifteen');
        wordsUpTo99.add('Sixteen');
        wordsUpTo99.add('Seventeen');
        wordsUpTo99.add('Eighteen');
        wordsUpTo99.add('Nineteen');
        wordsUpTo99.add('Twenty');
        wordsUpTo99.add('Twenty One');
        wordsUpTo99.add('Twenty Two');
        wordsUpTo99.add('Twenty Three');
        wordsUpTo99.add('Twenty Four');
        wordsUpTo99.add('Twenty Five');
        wordsUpTo99.add('Twenty Six');
        wordsUpTo99.add('Twenty Seven');
        wordsUpTo99.add('Twenty Eight');
        wordsUpTo99.add('Twenty Nine');
        wordsUpTo99.add('Thirty');
        wordsUpTo99.add('Thirty One');
        wordsUpTo99.add('Thirty Two');
        wordsUpTo99.add('Thirty Three');
        wordsUpTo99.add('Thirty Four');
        wordsUpTo99.add('Thirty Five');
        wordsUpTo99.add('Thirty Six');
        wordsUpTo99.add('Thirty Seven');
        wordsUpTo99.add('Thirty Eight');
        wordsUpTo99.add('Thirty Nine');
        wordsUpTo99.add('Fourty');
        wordsUpTo99.add('Fourty One');
        wordsUpTo99.add('Fourty Two');
        wordsUpTo99.add('Fourty Three');
        wordsUpTo99.add('Fourty Four');
        wordsUpTo99.add('Fourty Five');
        wordsUpTo99.add('Fourty Six');
        wordsUpTo99.add('Fourty Seven');
        wordsUpTo99.add('Fourty Eight');
        wordsUpTo99.add('Fourty Nine');
        wordsUpTo99.add('Fifty');
        wordsUpTo99.add('Fifty One');
        wordsUpTo99.add('Fifty Two');
        wordsUpTo99.add('Fifty Three');
        wordsUpTo99.add('Fifty Four');
        wordsUpTo99.add('Fifty Five');
        wordsUpTo99.add('Fifty Six');
        wordsUpTo99.add('Fifty Seven');
        wordsUpTo99.add('Fifty Eight');
        wordsUpTo99.add('Fifty Nine');
        wordsUpTo99.add('Sixty');
        wordsUpTo99.add('Sixty One');
        wordsUpTo99.add('Sixty Two');
        wordsUpTo99.add('Sixty Three');
        wordsUpTo99.add('Sixty Four');
        wordsUpTo99.add('Sixty Five');
        wordsUpTo99.add('Sixty Six');
        wordsUpTo99.add('Sixty Seven');
        wordsUpTo99.add('Sixty Eight');
        wordsUpTo99.add('Sixty Nine');
        wordsUpTo99.add('Seventy');
        wordsUpTo99.add('Seventy One');
        wordsUpTo99.add('Seventy Two');
        wordsUpTo99.add('Seventy Three');
        wordsUpTo99.add('Seventy Four');
        wordsUpTo99.add('Seventy Five');
        wordsUpTo99.add('Seventy Six');
        wordsUpTo99.add('Seventy Seven');
        wordsUpTo99.add('Seventy Eight');
        wordsUpTo99.add('Seventy Nine');
        wordsUpTo99.add('Eighty');
        wordsUpTo99.add('Eighty One');
        wordsUpTo99.add('Eighty Two');
        wordsUpTo99.add('Eighty Three');
        wordsUpTo99.add('Eighty Four');
        wordsUpTo99.add('Eighty Five');
        wordsUpTo99.add('Eighty Six');
        wordsUpTo99.add('Eighty Seven');
        wordsUpTo99.add('Eighty Eight');
        wordsUpTo99.add('Eighty Nine');
        wordsUpTo99.add('Ninety');
        wordsUpTo99.add('Ninety One');
        wordsUpTo99.add('Ninety Two');
        wordsUpTo99.add('Ninety Three');
        wordsUpTo99.add('Ninety Four');
        wordsUpTo99.add('Ninety Five');
        wordsUpTo99.add('Ninety Six');
        wordsUpTo99.add('Ninety Seven');
        wordsUpTo99.add('Ninety Eight');
        wordsUpTo99.add('Ninety Nine');
    }
    
    public static String convertNumbertoWords(decimal input) {
        Integer units =0;
        Integer tens =0;
        Integer hundreds =0;
        Integer thousands = 0;
        Integer tenthousands =0;
        Integer lakhs =0;
        Integer tenlakhs =0;
        Integer crores =0;
        Integer tencrores =0;
        Integer hundredcrores =0;
        String formattedWords;
        Boolean negative = false;
        if(input == 0) {
            formattedWords = 'Rupees: Nil';  
            return formattedWords;
        }
        config();
        if(input < 0) {
            negative = true;
        } 
        input = math.abs(input);
        String inputNumber = string.valueOf(input);
        inputNumber = inputNumber.replace(',','');
        Double max = 9999999999.00;
        if (input > max) {
            System.debug('unable to convert, number to large' + input) ;
            return 'Rs' + inputNumber + '/-';
        } else {
            Integer strlen = inputNumber.length();
            
            Integer stroffset = strlen;
            
            String words = '';
            
            stroffset     = strlen-1;
            
            System.debug('Strlen :: strOffset::' + strlen + '::' + stroffset);
            if (stroffset > -1)
                units  = Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                tens          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                hundreds          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                thousands          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                tenthousands          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                lakhs          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                tenlakhs          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                crores          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                tencrores          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            if (stroffset > -1)  
                hundredcrores          =  Integer.valueOf(inputNumber.substring(stroffset--,strlen--));
            String croresLabel = '';
            if (hundredcrores  >  0) {
                words  +=   wordsUpTo99[hundredcrores] +  ' Hundred';
                if (tencrores * 10 + crores < 1)
                    words  +=  ' Crores';
            }
            
            if (tencrores > 0   ||   crores > 0) {
                Integer num   = tencrores * 10 + crores;
                if (hundredcrores > 0)
                    words += ' and' ;
                words += ' ' + wordsUpTo99[num] + ' Crore';
                if(num > 1)
                    words +='s';
            }
            
            
            if (tenlakhs > 0   ||   lakhs > 0) {
                Integer num   = tenlakhs * 10 + lakhs;
                words +=  ' '+ wordsUpTo99[num] + ' Lakh';
                if (num > 1)
                    words += 's' ;
            }
            
            if (tenthousands > 0   ||   thousands > 0) {
                Integer num   = tenthousands * 10 + thousands;
                System.debug('index:' + num);
                System.debug('words array:' + wordsUpto99);
                words += ' '+ wordsUpTo99[num];
                words += ' Thousand';
            }
            
            if (hundreds  >  0) {
                words += ' '+ wordsUpTo99[hundreds] + ' Hundred';
            }
            
            if (tens > 0   ||   units > 0) {
                Integer num = tens * 10 + units;
                if(String.isNotBlank(words))
                    words += ' and';
                words +=  ' '+ wordsUpTo99[num];
            }
            if(negative)
                formattedWords = '-ve Rupees ' + words;
            else
                formattedWords = 'Rupees ' + words;
            System.debug('Number to words:' + input  + '::' + formattedWords);
        }
        return formattedWords;
    }  

    public static string CurrencyToWordsFormatAED(Integer num){
        S_NumberToWord.intNum = num;
        if( S_NumberToWord.intNum == 0 ){
            numInWords = 'Zero';
        }
        if( S_NumberToWord.intNum > 0 ){
            if( S_NumberToWord.intNum == 1 ){
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencySingular;
            }
            else{
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencyplural;
            }
        }
        System.debug(num+':'+S_NumberToWord.numInWords);
        return S_NumberToWord.numInWords;
    }

    
    public static String CurrencyToWordsFormatAED(Decimal num){
        String numToString = String.valueOf(num);
        List<String> parts = numToString.split('\\.');
        if( parts != null && parts.size()>0){
            S_NumberToWord.intNum = Integer.valueOf(parts[0]);S_NumberToWord.decNum = Integer.valueOf(parts[1]);
        } 
        if( S_NumberToWord.intNum == 0 ){
            S_NumberToWord.numInWords = 'Zero';
        }
        if( S_NumberToWord.intNum > 0 ){
            if( S_NumberToWord.intNum == 1 ){
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencySingular;
            }
            else{
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencyplural;
            }
        }
        if( S_NumberToWord.decNum > 0 ){
            if( S_NumberToWord.decNum == 1 ){
                S_NumberToWord.numInWords += S_NumberToWord.NumberToWords(S_NumberToWord.decNum) + S_NumberToWord.smlCurrencySingular;
            }
            else{
                S_NumberToWord.numInWords += 'AND ' + S_NumberToWord.NumberToWords(S_NumberToWord.decNum) + S_NumberToWord.smlCurrencyplural;
            }
        }
        System.debug(num+':'+S_NumberToWord.numInWords);
        return S_NumberToWord.numInWords;
    }
    
    public static String CurrencyToWordsFormat(Double num){
        String numToString = String.valueOf(num);
        List<String> parts = numToString.split('\\.');
        if( parts != null && parts.size()>0) {
            S_NumberToWord.intNum = Integer.valueOf(parts[0]);
            S_NumberToWord.decNum = Integer.valueOf(parts[1]);
        }
        if( S_NumberToWord.intNum == 0 ){
            S_NumberToWord.numInWords = 'Zero';
        }
        if( S_NumberToWord.intNum > 0 ){
            if( S_NumberToWord.intNum == 1 ){
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencySingular;
            }
            else{
                S_NumberToWord.numInWords = S_NumberToWord.NumberToWords(S_NumberToWord.intNum) + S_NumberToWord.bigCurrencyplural;
            }
        }
        if( S_NumberToWord.decNum > 0 ){
            if( S_NumberToWord.decNum == 1 ){
                S_NumberToWord.numInWords += S_NumberToWord.NumberToWords(S_NumberToWord.decNum) + S_NumberToWord.smlCurrencySingular;
            }
            else{
                S_NumberToWord.numInWords += 'AND ' + S_NumberToWord.NumberToWords(S_NumberToWord.decNum) + S_NumberToWord.smlCurrencyplural;
            }
        }
        System.debug(num+':'+S_NumberToWord.numInWords);
        return S_NumberToWord.numInWords;
    }
    
    public static String NumberToWords(Integer num){
        String words = '';
        integer digit, den, rem;
        digit = String.valueOf(num).length();
        den = num / S_NumberToWord.base[digit];
        rem = Math.mod(num,S_NumberToWord.base[digit]);
        if( digit == 1 ){
            words = S_NumberToWord.ones[num];
        }
        else if( digit == 2 ){
            if( den == 1 && rem >0 ){
                words = S_NumberToWord.ones[num];
            } else{
            words = S_NumberToWord.tens[den];
                if( rem > 0 ){
                    words += NumberToWords(rem);
                }
            }
        }
        else if( digit > 2 ){
            words += NumberToWords(den)+S_NumberToWord.unit[digit];
            if( rem > 0 ){
                words += NumberToWords(rem);
            }
        }
        return words;
    }
}