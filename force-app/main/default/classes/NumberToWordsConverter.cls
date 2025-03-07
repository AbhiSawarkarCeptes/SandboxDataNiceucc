public class NumberToWordsConverter {
    private static final String[] units = new String[]{
        'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'
    };
    
    private static final String[] teens = new String[]{
        'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };
    
    private static final String[] tens = new String[]{
        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };
    
    private static final String[] thousands = new String[]{
        '', 'Thousand', 'Million', 'Billion'
    };
    
    public static String convertToWords(Decimal amount) {
        Integer intPart = (Integer) amount.intValue();
        Decimal decimalPart = amount - intPart;
        
        String intWords = convertIntToWords(intPart);
        String decimalWords = convertDecimalToWords(decimalPart);
        
        if (decimalWords != '') {
            return intWords + ' Dirhams and ' + decimalWords;
        } else {
            return intWords + ' Dirhams';
        }
    }
    
    private static String convertIntToWords(Integer amount) {
        if (amount < 10) {
            return units[amount];
        } else if (amount < 20) {
            return teens[amount - 10];
        } else if (amount < 100) {
            return tens[amount / 10] + (Math.mod(amount, 10) > 0 ? '-' + units[Math.mod(amount, 10)] : '');
        } else if (amount < 1000) {
            return units[amount / 100] + ' Hundred' + (Math.mod(amount, 100) > 0 ? ' and ' + convertIntToWords(Math.mod(amount, 100)) : '');
        } else {
            String result = '';
            for (Integer i = 3; i >= 0; i--) {
                Integer divisor = (Integer) Math.pow(1000, i);
                Integer quotient = amount / divisor;
                if (quotient > 0) {
                    result += convertIntToWords(quotient) + ' ' + thousands[i] + ' ';
                    amount = Math.mod(amount, divisor);
                }
            }
            return result.trim();
        }
    }
    
    private static String convertDecimalToWords(Decimal amount) {
        if (amount == 0) {
            return '';
        }
        
        Integer decimalPart = (Integer) (amount * 100).intValue();
        return convertIntToWords(decimalPart) + ' Fils';
    }
}