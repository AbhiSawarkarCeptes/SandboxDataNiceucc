Public Class ParseNumber {
    Public Static String fetchNumber(String str) {
        String num='';
        if(str != null) { 
            for(Integer i=0; i< str.length(); i++) {
                String temp = String.valueOf(str.subString(i, i+1));
                System.debug('**** '+temp);
                if(temp.isNumeric()) {
                    num+=temp;
                }
            }
        }
        return num.replaceFirst('^0+','');
    }
}