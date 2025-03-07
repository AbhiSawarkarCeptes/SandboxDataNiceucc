public class FormatMobileNumber {
    
    public static Map 

<String, String> getDetailsByMobile(String mobilePhone) {
        String mobileNumber = '';
        string countryCode = '';
        string country = '';
        Integer count = 0;
        Integer mSize = 0;
        Map<String, String> details = new Map <String, String>();
        String formattedPhone = formatPhone(mobilePhone); //Test:'+374 9192 0995'
        System.debug('Inside format mobile class formattedPhone=========' + formattedPhone );
        
        if (string.isNotBlank(formattedphone) && formattedPhone.length() > 12 && string.isBlank(country)) {
            count = 1;
            system.debug('Inside > 12:: ' + formattedPhone);
            while (String.isBlank(country) && count <= 5) {
                Integer i = formattedPhone.length() - count;
                countryCode = formattedPhone.subString(0, formattedPhone.length() - i);
                mobileNumber = formattedPhone.substring(countryCode.length());
                mSize = mobileNumber.length();
                System.debug('formattedPhone=========' + formattedPhone);
                System.debug('mSize='+mSize+'count='+count);
                if(string.isBlank(country)){
                    if((countryCode.equals('+86') || countryCode.equals('86') || countryCode.equals('0086') || countryCode.equals('086')) && mSize == 11)
                        country = 'China'; //11-
                    else if ((countryCode.equals('+55') || countryCode.equals('55') || countryCode.equals('0055') || countryCode.equals('055')) && mSize == 11)
                        country = 'Brazil'; //11-
                    else if ((countryCode.equals('+673') || countryCode.equals('673') || countryCode.equals('00673') || countryCode.equals('0673')))
                        country = 'Brunei'; //10-
                    else if ((countryCode.equals('+43') || countryCode.equals('43') || countryCode.equals('0043') || countryCode.equals('043')) && mSize == 11)
                        country = 'Austria'; //11-
                    else if ((countryCode.equals('+358') || countryCode.equals('358') || countryCode.equals('00358') || countryCode.equals('0358')) && mSize == 10)
                        country = 'Åland Islands'; //10-
                    else if ((countryCode.equals('+880') || countryCode.equals('880') || countryCode.equals('00880') || countryCode.equals('0880')) && mSize == 10)
                        country = 'Bangladesh'; //10-
                    else if ((countryCode.equals('+39') || countryCode.equals('39') || countryCode.equals('0039') || countryCode.equals('039')) && mSize == 10)
                        country = 'Italy'; //10-
                    else if ((countryCode.equals('+976') || countryCode.equals('976') || countryCode.equals('00976') || countryCode.equals('0976')) && mSize == 10)
                        country = 'Mongolia'; //10-
                    else if ((countryCode.equals('+977') || countryCode.equals('977') || countryCode.equals('00977') || countryCode.equals('0977')) && mSize == 10)
                        country = 'Nepal'; //10- 
                    else if ((countryCode.equals('+358') || countryCode.equals('358') || countryCode.equals('00358') || countryCode.equals('0358')) && mSize == 10)
                        country = 'Finland'; //10- 
                    else if (countryCode.equals('+254') || countryCode.equals('254') || countryCode.equals('00254') || countryCode.equals('0254'))
                        country = 'Kenya'; //?- 
                     else if ((countryCode.equals('+850') || countryCode.equals('850') || countryCode.equals('00850') || countryCode.equals('0850')) && mSize == 7)
                        country = 'North Korea'; //7
                    else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                        country = 'South Korea'; //?- 
                    else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                        country = 'Argentina'; //?-
                    else if((countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061')) && mSize == 15)
                        country = 'Australia';    
                }
                count = count + 1;
            }
        }
        
        if (string.isNotBlank(formattedphone) && formattedPhone.length() > 11 && string.isBlank(country)) {
            count = 1;
            system.debug('Inside > 11:: ' + formattedphone);
            while (String.isBlank(country) && count <= 5) {
                system.debug('count:: ' + count);
                Integer i = formattedPhone.length() - count;
                system.debug('i:: ' + i);
                countryCode = formattedPhone.subString(0, formattedPhone.length() - i);
                system.debug('countryCode::: ' + countryCode);
                mobileNumber = formattedPhone.substring(countryCode.length());
                system.debug('mobileNumber::: ' + mobileNumber);
                mSize = mobileNumber.length();
                system.debug('mSize:: ' + mSize);
                System.debug('formattedPhone=========' + formattedPhone);
                
                if(string.isBlank(country)){
                    if ((countryCode.equals('+91') || countryCode.equals('91') || countryCode.equals('0091') || countryCode.equals('091')) && mSize == 10)
                        country = 'India'; //10-
                    else if(countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061'))
                        country = 'Australia';    
                    else if ((countryCode.equals('+355') || countryCode.equals('355') || countryCode.equals('00355') || countryCode.equals('0355')) && mSize == 9)
                        country = 'Albania'; //9-
                    else if ((countryCode.equals('+376') || countryCode.equals('376') || countryCode.equals('00376') || countryCode.equals('0376')) && mSize == 9)
                        country = 'Andorra'; //9-
                    else if ((countryCode.equals('+244') || countryCode.equals('244') || countryCode.equals('00244') || countryCode.equals('0244')) && mSize == 9)
                        country = 'Angola'; //9-
                    else if ((countryCode.equals('+1-264') || countryCode.equals('1-264') || countryCode.equals('001-264') || countryCode.equals('01-264')))
                country = 'Anguilla'; //9-
                    else if ((countryCode.equals('+1-268') || countryCode.equals('1-268') || countryCode.equals('001-268') || countryCode.equals('01-268')) && mSize == 9)
                        country = 'Antigua and Barbuda'; //9-
                    else if ((countryCode.equals('+355') || countryCode.equals('355') || countryCode.equals('00355') || countryCode.equals('0355')) && mSize == 9)
                        country = 'Albania'; //9-
                    else if ((countryCode.equals('+213') || countryCode.equals('213') || countryCode.equals('00213') || countryCode.equals('0213')) && mSize == 9)
                        country = 'Algeria'; //9-
                    else if ((countryCode.equals('+684') || countryCode.equals('684') || countryCode.equals('00684') || countryCode.equals('0684')) && mSize == 9)
                        country = 'American Samoa'; //9-
                        else if ((countryCode.equals('+376') || countryCode.equals('376') || countryCode.equals('00376') || countryCode.equals('0376')) && mSize == 9)
                        country = 'Andorra'; //9-
                    else if ((countryCode.equals('+994') || countryCode.equals('994') || countryCode.equals('00994') || countryCode.equals('0994')) && mSize == 9)
                        country = 'Azerbaijan'; //9-
                    else if ((countryCode.equals('+1-242') || countryCode.equals('1-242') || countryCode.equals('001-242') || countryCode.equals('01-242')) && mSize == 9)
                        country = 'Bahamas'; //9-
                    else if ((countryCode.equals('+43') || countryCode.equals('43') || countryCode.equals('0043') || countryCode.equals('043')) && mSize == 10)
                        country = 'Austria'; //10- 
                    else if ((countryCode.equals('+20') || countryCode.equals('20') || countryCode.equals('0020') || countryCode.equals('020')) && mSize == 10)
                        country = 'Egypt'; //10- 
                    else if ((countryCode.equals('+49') || countryCode.equals('49') || countryCode.equals('0049') || countryCode.equals('049')) && mSize == 10)
                        country = 'Germany'; //10-
                    else if ((countryCode.equals('+233') || countryCode.equals('233') || countryCode.equals('00233') || countryCode.equals('0233')) && mSize == 9)
                        country = 'Ghana'; //9-
                    else if ((countryCode.equals('+44-1534') || countryCode.equals('44-1534') || countryCode.equals('0044-1534') || countryCode.equals('044-1534')))
                        country = 'Jersey'; //9-
                    else if ((countryCode.equals('+1-664') || countryCode.equals('1-664') || countryCode.equals('001-664') || countryCode.equals('01-664')))
                        country = 'Montserrat'; //9-
                    else if ((countryCode.equals('+966') || countryCode.equals('966') || countryCode.equals('00966') || countryCode.equals('0966')) && mSize == 9)
                        country = 'Saudi Arabia'; //9-
                    else if ((countryCode.equals('+1-721') || countryCode.equals('1-721') || countryCode.equals('001-721') || countryCode.equals('01-721')))
                        country = 'Sint Maarten'; //9-
                    else if ((countryCode.equals('+375') || countryCode.equals('375') || countryCode.equals('00375') || countryCode.equals('0375')) && mSize == 9)
                        country = 'Belarus'; //9-
                    else if ((countryCode.equals('+855') || countryCode.equals('855') || countryCode.equals('00855') || countryCode.equals('0855')) && mSize == 9)
                        country = 'Cambodia'; //9-
                    else if ((countryCode.equals('+57') || countryCode.equals('57') || countryCode.equals('0057') || countryCode.equals('057')) && mSize == 10)
                        country = 'Colombia'; //10-
                    else if ((countryCode.equals('+269') || countryCode.equals('269') || countryCode.equals('00269') || countryCode.equals('0269')))
                        country = 'Comoros'; //10-
                    else if ((countryCode.equals('+372') || countryCode.equals('372') || countryCode.equals('00372') || countryCode.equals('0372')))
                        country = 'Estonia'; //8-
                    else if ((countryCode.equals('+1-767') || countryCode.equals('1-767') || countryCode.equals('001-767') || countryCode.equals('01-767')) && mSize == 9)
                        country = 'Dominica'; //9-
                    else if ((countryCode.equals('+1-809') || countryCode.equals('1-809') || countryCode.equals('001-809') || countryCode.equals('01-809')) && mSize == 9)
                        country = 'Dominican Republic'; //9-
                    else if ((countryCode.equals('+670') || countryCode.equals('670') || countryCode.equals('00670') || countryCode.equals('0670')) && mSize == 9)
                        country = 'East Timor'; //9-
                    else if ((countryCode.equals('+503') || countryCode.equals('503') || countryCode.equals('00503') || countryCode.equals('0503')) && mSize == 9)
                        country = 'El Salvador'; //9-
                    else if ((countryCode.equals('+291') || countryCode.equals('291') || countryCode.equals('00291') || countryCode.equals('0291')) && mSize == 9)
                        country = 'Eritrea'; //9-
                    else if ((countryCode.equals('+240') || countryCode.equals('240') || countryCode.equals('00240') || countryCode.equals('0240')) && mSize == 9)
                        country = 'Equatorial Guinea'; //9-
                    else if ((countryCode.equals('+679') || countryCode.equals('679') || countryCode.equals('00679') || countryCode.equals('0679')) && mSize == 9)
                        country = 'Fiji'; //9-
                    else if ((countryCode.equals('+689') || countryCode.equals('689') || countryCode.equals('00689') || countryCode.equals('0689')) && mSize == 9)
                        country = 'French Polynesia'; //9-
                    else if ((countryCode.equals('+243') || countryCode.equals('243') || countryCode.equals('00243') || countryCode.equals('0243')))
                        country = 'Congo, Democratic Republic of the'; //10-
                    else if ((countryCode.equals('+242') || countryCode.equals('242') || countryCode.equals('00242') || countryCode.equals('0242')))
                        country = 'Congo, Republic of the'; //10-
                    else if ((countryCode.equals('+241') || countryCode.equals('241') || countryCode.equals('00241') || countryCode.equals('0241')) && mSize == 9)
                        country = 'Gabon'; //9-
                    else if ((countryCode.equals('+220') || countryCode.equals('220') || countryCode.equals('00220') || countryCode.equals('0220')) && mSize == 9)
                        country = 'Gambia'; //9-
                    else if ((countryCode.equals('+995') || countryCode.equals('995') || countryCode.equals('00995') || countryCode.equals('0995')) && mSize == 9)
                        country = 'Georgia'; //9-
                    else if ((countryCode.equals('+30') || countryCode.equals('30') || countryCode.equals('0030') || countryCode.equals('030')) && mSize == 10)
                        country = 'Greece'; //10 -
                    else if ((countryCode.equals('+502') || countryCode.equals('502') || countryCode.equals('00502') || countryCode.equals('0502')) && mSize == 9)
                        country = 'Guatemala'; //9-
                    else if ((countryCode.equals('+224') || countryCode.equals('224') || countryCode.equals('00224') || countryCode.equals('0224')) && mSize == 9)
                        country = 'Guinea'; //9-
                    else if ((countryCode.equals('+245') || countryCode.equals('245') || countryCode.equals('00245') || countryCode.equals('0245')) && mSize == 9)
                        country = 'Guinea-Bissau'; //9-
                    else if ((countryCode.equals('+44-1481') || countryCode.equals('44-1481') || countryCode.equals('0044-1481') || countryCode.equals('044-1481')))
                        country = 'Guernsey'; //9-
                    else if ((countryCode.equals('+1-671') || countryCode.equals('1-671') || countryCode.equals('001-671') || countryCode.equals('01-671')) && mSize == 9)
                        country = 'Guam'; //9-
                    else if ((countryCode.equals('+592') || countryCode.equals('592') || countryCode.equals('00592') || countryCode.equals('0592')) && mSize == 9)
                        country = 'Guyana'; //9-
                    else if ((countryCode.equals('+509') || countryCode.equals('509') || countryCode.equals('00509') || countryCode.equals('0509')) && mSize == 9)
                        country = 'Haiti'; //9-
                    else if ((countryCode.equals('+504') || countryCode.equals('504') || countryCode.equals('00504') || countryCode.equals('0504')) && mSize == 9)
                        country = 'Honduras'; //9-
                    else if ((countryCode.equals('+44-1624') ||countryCode.equals('44-1624') || countryCode.equals('0044-1624') || countryCode.equals('044-1624')))
                        country = 'Isle of Man'; //10-
                    else if ((countryCode.equals('+962') || countryCode.equals('962') || countryCode.equals('00962') || countryCode.equals('0962')))
                        country = 'Jordan'; //8-    
                    else if ((countryCode.equals('+686') ||countryCode.equals('686') || countryCode.equals('00686') || countryCode.equals('0686')))
                        country = 'Kiribati'; //10-
                    else if ((countryCode.equals('+381') ||countryCode.equals('381') || countryCode.equals('00381') || countryCode.equals('0381')))
                        country = 'Kosovo'; //10-
                    else if ((countryCode.equals('+856') ||countryCode.equals('856') || countryCode.equals('00856') || countryCode.equals('0856')))
                        country = 'Laos'; //10-
                    else if ((countryCode.equals('+266') ||countryCode.equals('266') || countryCode.equals('00266') || countryCode.equals('0266')))
                        country = 'Lesotho'; //10-
                    else if ((countryCode.equals('+231') ||countryCode.equals('231') || countryCode.equals('00231') || countryCode.equals('0231')))
                        country = 'Liberia'; //10-
                    else if ((countryCode.equals('+423') ||countryCode.equals('423') || countryCode.equals('00423') || countryCode.equals('0423')))
                        country = 'Liechtenstein'; //10-
                    else if ((countryCode.equals('+389') ||countryCode.equals('389') || countryCode.equals('00389') || countryCode.equals('0389')))
                        country = 'Macedonia'; //10-
                    else if ((countryCode.equals('+265') ||countryCode.equals('265') || countryCode.equals('00265') || countryCode.equals('0265')))
                        country = 'Malawi'; //10-
                    else if ((countryCode.equals('+356') ||countryCode.equals('356') || countryCode.equals('00356') || countryCode.equals('0356')))
                        country = 'Malta'; //10-
                    else if ((countryCode.equals('+692') ||countryCode.equals('692') || countryCode.equals('00692') || countryCode.equals('0692')))
                        country = 'Marshall Islands'; //10-
                    else if ((countryCode.equals('+52') || countryCode.equals('52') || countryCode.equals('0052') || countryCode.equals('052')) && mSize == 10)
                        country = 'Mexico'; //10-
                    else if ((countryCode.equals('+377') || countryCode.equals('377') || countryCode.equals('00377') || countryCode.equals('0377')))
                country = 'Monaco'; //8-
                    else if ((countryCode.equals('+382') || countryCode.equals('382') || countryCode.equals('00382') || countryCode.equals('0382')) && mSize == 8)
                        country = 'Montenegro'; //8-
                    else if ((countryCode.equals('+212') || countryCode.equals('212') || countryCode.equals('00212') || countryCode.equals('0212')))
                        country = 'Morocco'; //8-
                    else if ((countryCode.equals('+258') || countryCode.equals('258') || countryCode.equals('00258') || countryCode.equals('0258')) && mSize == 8)
                        country = 'Mozambique'; //8-
                    else if ((countryCode.equals('+95') ||countryCode.equals('95') || countryCode.equals('0095') || countryCode.equals('095')))
                        country = 'Myanmar'; //10-
                    else if ((countryCode.equals('+264') ||countryCode.equals('264') || countryCode.equals('00264') || countryCode.equals('0264')))
                        country = 'Namibia'; //10-
                    else if ((countryCode.equals('+505') ||countryCode.equals('505') || countryCode.equals('00505') || countryCode.equals('0505')))
                        country = 'Nicaragua'; //10-
                    else if ((countryCode.equals('+1-670') ||countryCode.equals('1-670') || countryCode.equals('001-670') || countryCode.equals('01-670')))
                        country = 'Northern Mariana Islands'; //10-
                    else if ((countryCode.equals('+674') || countryCode.equals('674') || countryCode.equals('00674') || countryCode.equals('0674')) && mSize == 8)
                        country = 'Nauru'; //8-
                    else if ((countryCode.equals('+968') ||countryCode.equals('968') || countryCode.equals('00968') || countryCode.equals('0968')))
                        country = 'Oman'; //10-
                    else if ((countryCode.equals('+680') ||countryCode.equals('680') || countryCode.equals('00680') || countryCode.equals('0680')))
                        country = 'Palau'; //10-
                    else if ((countryCode.equals('+970') ||countryCode.equals('970') || countryCode.equals('00970') || countryCode.equals('0970')))
                        country = 'Palestine'; //10-
                    else if ((countryCode.equals('+675') || countryCode.equals('675') || countryCode.equals('00675') || countryCode.equals('0675')) && mSize == 9)
                        country = 'Papua New Guinea'; //9-
                    else if ((countryCode.equals('+595') || countryCode.equals('595') || countryCode.equals('00595') || countryCode.equals('0595')))
                country = 'Paraguay'; //9-
                    else if ((countryCode.equals('+63') || countryCode.equals('63') || countryCode.equals('0063') || countryCode.equals('063')) && mSize == 10)
                        country = 'Philippines'; //10-
                    else if ((countryCode.equals('+92') || countryCode.equals('92') || countryCode.equals('0092') || countryCode.equals('092')) && mSize == 10)
                        country = 'Pakistan'; //10-
                    else if ((countryCode.equals('+64') || countryCode.equals('64') || countryCode.equals('0064') || countryCode.equals('064')) && mSize == 10)
                        country = 'New Zealand'; //10-
                    else if ((countryCode.equals('+351') || countryCode.equals('351') || countryCode.equals('00351') || countryCode.equals('0351')) && mSize == 9)
                        country = 'Portugal'; //9-
                    else if ((countryCode.equals('+1-939') || countryCode.equals('1-939') || countryCode.equals('001-939') || countryCode.equals('01-939')) && mSize == 9)
                        country = 'Puerto Rico'; //9-
                    else if ((countryCode.equals('+40') || countryCode.equals('40') || countryCode.equals('0040') || countryCode.equals('040')) && mSize == 9)
                        country = 'Romania'; //9-
                    else if ((countryCode.equals('+250') || countryCode.equals('250') || countryCode.equals('00250') || countryCode.equals('0250')) && mSize == 9)
                        country = 'Rwanda'; //9-
                    else if ((countryCode.equals('+1-758') || countryCode.equals('1-758') || countryCode.equals('001-758') || countryCode.equals('01-758')) && mSize == 9)
                        country = 'Saint Lucia'; //9-
                    else if ((countryCode.equals('+1-869') || countryCode.equals('1-869') || countryCode.equals('001-869') || countryCode.equals('01-869')) && mSize == 9)
                        country = 'Saint Kitts and Nevis'; //9-
                    else if ((countryCode.equals('+1-784') || countryCode.equals('1-784') || countryCode.equals('001-784') || countryCode.equals('01-784')) && mSize == 9)
                        country = 'Saint Vincent and the Grenadines'; //9-
                    else if ((countryCode.equals('+221') || countryCode.equals('221') || countryCode.equals('00221') || countryCode.equals('0221')))
                country = 'Senegal'; //9-
                    else if ((countryCode.equals('+685') || countryCode.equals('685') || countryCode.equals('00685') || countryCode.equals('0685')) && mSize == 9)
                        country = 'Samoa'; //9-
                    else if ((countryCode.equals('+378') || countryCode.equals('378') || countryCode.equals('00378') || countryCode.equals('0378')) && mSize == 9)
                        country = 'San Marino'; //9-
                    else if ((countryCode.equals('+239') || countryCode.equals('239') || countryCode.equals('00239') || countryCode.equals('0239')) && mSize == 9)
                        country = 'Sao Tome and Principe'; //9-
                    else if ((countryCode.equals('+381') || countryCode.equals('381') || countryCode.equals('00381') || countryCode.equals('0381')) && mSize == 9)
                        country = 'Serbia and Montenegro'; //9-
                    else if ((countryCode.equals('+232') || countryCode.equals('232') || countryCode.equals('00232') || countryCode.equals('0232')) && mSize == 9)
                        country = 'Sierra Leone'; //9-
                    else if ((countryCode.equals('+421') || countryCode.equals('421') || countryCode.equals('00421') || countryCode.equals('0421')))
                country = 'Slovakia'; //8-
                    else if ((countryCode.equals('+386') || countryCode.equals('386') || countryCode.equals('00386') || countryCode.equals('0386')) && mSize == 9)
                        country = 'Slovenia'; //9-
                    else if ((countryCode.equals('+677') || countryCode.equals('677') || countryCode.equals('00677') || countryCode.equals('0677')) && mSize == 9)
                        country = 'Solomon Islands'; //9-
                    else if ((countryCode.equals('+252') || countryCode.equals('252') || countryCode.equals('00252') || countryCode.equals('0252')) && mSize == 9)
                        country = 'Somalia'; //9-
                    else if ((countryCode.equals('+597') || countryCode.equals('597') || countryCode.equals('00597') || countryCode.equals('0597')) && mSize == 9)
                        country = 'Suriname'; //9-
                    else if ((countryCode.equals('+963') || countryCode.equals('963') || countryCode.equals('00963') || countryCode.equals('0963')) && mSize == 9)
                        country = 'Syria'; //9 -
                    else if ((countryCode.equals('+268') || countryCode.equals('268') || countryCode.equals('00268') || countryCode.equals('0268')) && mSize == 9)
                        country = 'Swaziland'; //9-
                    else if ((countryCode.equals('+46') || countryCode.equals('46') || countryCode.equals('0046') || countryCode.equals('046')) && mSize == 10)
                        country = 'Sweden'; //10-
                    else if ((countryCode.equals('+886') || countryCode.equals('886') || countryCode.equals('00886') || countryCode.equals('0886')) && mSize == 9)
                        country = 'Taiwan'; //9-
                    else if ((countryCode.equals('+676') || countryCode.equals('676') || countryCode.equals('00676') || countryCode.equals('0676')) && mSize == 9)
                        country = 'Tonga'; //9-
                    else if ((countryCode.equals('+228') || countryCode.equals('228') || countryCode.equals('00228') || countryCode.equals('0228')) && mSize == 9)
                        country = 'Togo'; //9-
                    else if ((countryCode.equals('+1-868') || countryCode.equals('1-868') || countryCode.equals('001-868') || countryCode.equals('01-868')))
                        country = 'Trinidad and Tobago'; //8-
                    else if ((countryCode.equals('+216') || countryCode.equals('216') || countryCode.equals('00216') || countryCode.equals('0216')))
                        country = 'Tunisia'; //9-
                    else if ((countryCode.equals('+1-649') || countryCode.equals('1-649') || countryCode.equals('001-649') || countryCode.equals('01-649')))
                        country = 'Turks and Caicos Islands'; //9-
                    else if ((countryCode.equals('+688') || countryCode.equals('688') || countryCode.equals('00688') || countryCode.equals('0971')) && mSize == 9)
                        country = 'Tuvalu'; //9-    
                    else if ((countryCode.equals('+971') || countryCode.equals('971') || countryCode.equals('00971') || countryCode.equals('0688')) && mSize == 9)
                        country = 'United Arab Emirates'; //9-
                    else if ((countryCode.equals('+44') || countryCode.equals('44') || countryCode.equals('0044') || countryCode.equals('044')) && mSize == 10)
                        country = 'United Kingdom'; //10-
                    else if ((countryCode.equals('+380') || countryCode.equals('380') || countryCode.equals('00380') || countryCode.equals('0380')) && mSize == 9)
                        country = 'Ukraine'; //9 -
                    else if ((countryCode.equals('+998') || countryCode.equals('998') || countryCode.equals('00998') || countryCode.equals('0998')))
                        country = 'Uzbekistan'; //8-
                    else if ((countryCode.equals('+678') || countryCode.equals('678') || countryCode.equals('00678') || countryCode.equals('0678')))
                        country = 'Vanuatu'; //9-
                    else if ((countryCode.equals('+379') || countryCode.equals('379') || countryCode.equals('00379') || countryCode.equals('0379')))
                        country = 'Vatican City'; //9-
                    else if ((countryCode.equals('+58') || countryCode.equals('58') || countryCode.equals('0058') || countryCode.equals('058')))
                        country = 'Venezuela'; //9-
                    else if ((countryCode.equals('+84') || countryCode.equals('84') || countryCode.equals('0084') || countryCode.equals('084')))
                        country = 'Vietnam'; //8-
                    else if ((countryCode.equals('+1-284') || countryCode.equals('1-284') || countryCode.equals('001-284') || countryCode.equals('01-284')))
                        country = 'Virgin Islands, British'; //9-
                    else if ((countryCode.equals('+1-340') || countryCode.equals('1-340') || countryCode.equals('001-340') || countryCode.equals('01-340')))
                        country = 'Virgin Islands, U.S.'; //9-
                    else if ((countryCode.equals('+967') || countryCode.equals('967') || countryCode.equals('00967') || countryCode.equals('0967')) && mSize == 9)
                        country = 'Yemen'; //9-
                    else if ((countryCode.equals('+263') || countryCode.equals('263') || countryCode.equals('00263') || countryCode.equals('0263')))
                        country = 'Zimbabwe'; //8-
                    else if ((countryCode.equals('+95') || countryCode.equals('95') || countryCode.equals('0095') || countryCode.equals('095')) && mSize == 10)
                        country = 'Myanmar'; //10-
                    else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                        country = 'South Korea'; //?- 
                    else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                        country = 'Argentina'; //?-
                    else if ((countryCode.equals('+39') || countryCode.equals('39') || countryCode.equals('0039') || countryCode.equals('039')) && mSize == 10)
                        country = 'Italy'; //10-
                }
                count = count + 1;
            }
            system.debug('country:: ' + country);
        }
        if (string.isNotBlank(formattedphone) && formattedPhone.length() > 10 && string.isBlank(country)) {
            count = 1;
            while (String.isBlank(country) && count <= 5) {
                Integer i = formattedPhone.length() - count;
                countryCode = formattedPhone.subString(0, formattedPhone.length() - i);
                mobileNumber = formattedPhone.substring(countryCode.length());
                mSize = mobileNumber.length();
                System.debug('formattedPhone=========' + mobileNumber );
                
                if(string.isBlank(country)){
                    if ((countryCode.equals('+1') || countryCode.equals('1') || countryCode.equals('001')) && mSize == 10)
                        country = 'United States'; //10-     
                    else if ((countryCode.equals('+93') || countryCode.equals('93') || countryCode.equals('0093') || countryCode.equals('093')) && mSize == 9)
                        country = 'Afghanistan'; //9-
                    else if(countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061'))
                        country = 'Australia';     
                    else if ((countryCode.equals('+506') || countryCode.equals('506') || countryCode.equals('00506') || countryCode.equals('0506')) && mSize == 8)
                        country = 'Costa Rica'; //8-
                    else if ((countryCode.equals('+385') || countryCode.equals('385') || countryCode.equals('00385') || countryCode.equals('0385')))
                country = 'Croatia'; //10-
                    else if ((countryCode.equals('+53') || countryCode.equals('53') || countryCode.equals('0053') || countryCode.equals('053')))
                country = 'Cuba'; //10-
                    else if ((countryCode.equals('+357') || countryCode.equals('357') || countryCode.equals('00357') || countryCode.equals('0357')))
                country = 'Cyprus'; //10-
                    else if ((countryCode.equals('+420') || countryCode.equals('420') || countryCode.equals('00420') || countryCode.equals('0420')))
                country = 'Czech Republic'; //10-
                    else if (countryCode.equals('+971') || countryCode.equals('971') || countryCode.equals('00971') || countryCode.equals('0971'))
                        country = 'United Arab Emirates';
                    else if ((countryCode.equals('+36') || countryCode.equals('36') || countryCode.equals('0036') || countryCode.equals('036')) && mSize == 9)
                        country = 'Hungary'; //9-
                    else if ((countryCode.equals('+354') || countryCode.equals('354') || countryCode.equals('00354') || countryCode.equals('0354')))
                country = 'Iceland'; //10-
                    else if ((countryCode.equals('+965') || countryCode.equals('965') || countryCode.equals('00965') || countryCode.equals('0965')) && mSize == 8)
                        country = 'Kuwait'; //8-
                     else if ((countryCode.equals('+996') || countryCode.equals('996') || countryCode.equals('00996') || countryCode.equals('0996')) && mSize == 7)
                        country = 'Kyrgyzstan'; //7
                     else if ((countryCode.equals('+371') || countryCode.equals('371') || countryCode.equals('00371') || countryCode.equals('0371')) && mSize == 7)
                        country = 'Latvia'; //7
                    else if ((countryCode.equals('+961') || countryCode.equals('961') || countryCode.equals('00961') || countryCode.equals('0961')) && mSize == 7)
                        country = 'Lebanon'; //7
                    else if ((countryCode.equals('+218') || countryCode.equals('218') || countryCode.equals('00218') || countryCode.equals('0218')) && mSize == 7)
                        country = 'Libya'; //7
                    else if ((countryCode.equals('+370') || countryCode.equals('370') || countryCode.equals('00370') || countryCode.equals('0370')) && mSize == 7)
                        country = 'Lithuania'; //7
                    else if ((countryCode.equals('+352') || countryCode.equals('352') || countryCode.equals('00352') || countryCode.equals('0352')) && mSize == 7)
                        country = 'Luxembourg'; //7
                    else if ((countryCode.equals('+261') || countryCode.equals('261') || countryCode.equals('00261') || countryCode.equals('0261')) && mSize == 7)
                        country = 'Madagascar'; //7
                    else if ((countryCode.equals('+973') || countryCode.equals('973') || countryCode.equals('00973') || countryCode.equals('0973')) && mSize == 8)
                        country = 'Bahrain'; //8 -
                    else if ((countryCode.equals('+32') || countryCode.equals('32') || countryCode.equals('0032') || countryCode.equals('032')) && mSize == 9)
                        country = 'Belgium'; //9-
                    else if ((countryCode.equals('+387') || countryCode.equals('387') || countryCode.equals('00387') || countryCode.equals('0387')) && mSize == 8)
                        country = 'Bosnia and Herzegovina'; //8-
                    else if ((countryCode.equals('+267') || countryCode.equals('267') || countryCode.equals('00267') || countryCode.equals('0267')))
                country = 'Botswana'; //10-
                    else if ((countryCode.equals('+33') || countryCode.equals('33') || countryCode.equals('0033') || countryCode.equals('033')) && mSize == 9)
                        country = 'France'; //9-    
                    else if ((countryCode.equals('+95') || countryCode.equals('95') || countryCode.equals('0095') || countryCode.equals('095')) && mSize == 9)
                        country = 'Myanmar'; //9-
                    else if ((countryCode.equals('+230') || countryCode.equals('230') || countryCode.equals('00230') || countryCode.equals('0230')) && mSize == 8)
                        country = 'Mauritius'; //8-
                    else if ((countryCode.equals('+222') || countryCode.equals('222') || countryCode.equals('00222') || countryCode.equals('0222')) && mSize == 8)
                        country = 'Mauritania'; //8-
                    else if ((countryCode.equals('+691') || countryCode.equals('691') || countryCode.equals('00691') || countryCode.equals('0691')) && mSize == 8)
                        country = 'Micronesia'; //8-
                    else if ((countryCode.equals('+373') || countryCode.equals('373') || countryCode.equals('00373') || countryCode.equals('0373')) && mSize == 8)
                        country = 'Moldova'; //8-
                    else if ((countryCode.equals('+31') || countryCode.equals('31') || countryCode.equals('0031') || countryCode.equals('031')) && mSize == 9)
                        country = 'Netherlands'; //9-
                    else if ((countryCode.equals('+64') || countryCode.equals('64') || countryCode.equals('0064') || countryCode.equals('064')) && mSize == 9)
                        country = 'New Zealand'; //9-
                    else if ((countryCode.equals('+234') || countryCode.equals('234') || countryCode.equals('00234') || countryCode.equals('0234')) && mSize == 8)
                        country = 'Nigeria'; //8-
                    else if ((countryCode.equals('+507') || countryCode.equals('507') || countryCode.equals('00507') || countryCode.equals('0507')) && mSize == 8)
                        country = 'Panama'; //8-
                    else if ((countryCode.equals('+51') || countryCode.equals('51') || countryCode.equals('0051') || countryCode.equals('051')) && mSize == 9)
                        country = 'Peru'; //9-
                    else if ((countryCode.equals('+48') || countryCode.equals('48') || countryCode.equals('0048') || countryCode.equals('048')) && mSize == 9)
                        country = 'Poland'; //9 -
                    else if ((countryCode.equals('+7') || countryCode.equals('7') || countryCode.equals('007') || countryCode.equals('07')) && mSize == 10)
                        country = 'Russia'; //10- 
                    else if ((countryCode.equals('+27') || countryCode.equals('27') || countryCode.equals('0027') || countryCode.equals('027')) && mSize == 9)
                        country = 'South Africa'; //9 -
                    else if ((countryCode.equals('+34') || countryCode.equals('34') || countryCode.equals('0034') || countryCode.equals('034')) && mSize == 9)
                        country = 'Spain'; //9-
                    else if ((countryCode.equals('+41') || countryCode.equals('41') || countryCode.equals('0041') || countryCode.equals('041')) && mSize == 9)
                        country = 'Switzerland'; //9-
                    else if ((countryCode.equals('+66') || countryCode.equals('66') || countryCode.equals('0066') || countryCode.equals('066')) && mSize == 9)
                        country = 'Thailand'; //9-
                    else if ((countryCode.equals('+90') || countryCode.equals('90') || countryCode.equals('0090') || countryCode.equals('090')) && mSize == 9)
                        country = 'Turkey'; //9-
                    else if ((countryCode.equals('+993') || countryCode.equals('993') || countryCode.equals('00993') || countryCode.equals('0993')) && mSize == 7)
                        country = 'Turkmenistan'; //7
                    else if ((countryCode.equals('+256') || countryCode.equals('256') || countryCode.equals('00256') || countryCode.equals('0256')) && mSize == 7)
                        country = 'Uganda'; //7
                    else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                        country = 'South Korea'; //?- 
                    else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                        country = 'Argentina'; //?-
                }
                count = count + 1;
            }
        }
        
        if (string.isNotBlank(formattedphone) && formattedPhone.length() > 9 && string.isBlank(country)) {
            
            count = 1;
            while (String.isBlank(country) && count <= 5) {
                Integer i = formattedPhone.length() - count;
                countryCode = formattedPhone.subString(0, formattedPhone.length() - i);
                mobileNumber = formattedPhone.substring(countryCode.length());
                mSize = mobileNumber.length();
                System.debug('formattedPhone=========' + mobileNumber );
                
                if(string.isBlank(country)){
                    if (countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061'))
                        country = 'Australia';
                    else if (countryCode.equals('+60') ||countryCode.equals('60') || countryCode.equals('0060') || countryCode.equals('060'))
                        country = 'Malaysia';
                    else if (countryCode.equals('+971') || countryCode.equals('971') || countryCode.equals('00971') || countryCode.equals('0971'))
                        country = 'United Arab Emirates';
                    else if (countryCode.equals('+965') || countryCode.equals('965') || countryCode.equals('00965') || countryCode.equals('0965'))
                        country = 'Kuwait';
                    else if ((countryCode.equals('+974') || countryCode.equals('974') || countryCode.equals('00974') || countryCode.equals('0974')) && mSize == 8)
                        country = 'Qatar'; //8
                    else if (countryCode.equals('+968') || countryCode.equals('968') || countryCode.equals('00968') || countryCode.equals('0968'))
                        country = 'Oman'; //?
                    if ((countryCode.equals('+45') || countryCode.equals('45') || countryCode.equals('0045') || countryCode.equals('045')) && mSize == 8)
                        country = 'Denmark'; //8-
                    else if ((countryCode.equals('+253') || countryCode.equals('253') || countryCode.equals('00253') || countryCode.equals('0253')))
                        country = 'Djibouti'; //10-
                    else if ((countryCode.equals('+248') || countryCode.equals('248') || countryCode.equals('00248') || countryCode.equals('0248')) && mSize == 7)
                        country = 'Seychelles'; //7
                    else if ((countryCode.equals('+65') || countryCode.equals('65') || countryCode.equals('0065') || countryCode.equals('065')) && mSize == 8)
                        country = 'Singapore'; //8
                    else if ((countryCode.equals('+852') || countryCode.equals('852') || countryCode.equals('00852') || countryCode.equals('0852')) && mSize == 8)
                        country = 'Hong Kong'; //8
                    else if ((countryCode.equals('+297') || countryCode.equals('297') || countryCode.equals('00297') || countryCode.equals('0297')) && mSize == 7)
                        country = 'Aruba'; //7
                    else if ((countryCode.equals('+64') || countryCode.equals('64') || countryCode.equals('0064') || countryCode.equals('064')) && mSize == 8)
                        country = 'New Zealand'; //8 -
                    else if ((countryCode.equals('+246') || countryCode.equals('246') || countryCode.equals('00246') || countryCode.equals('0246')) && mSize == 7)
                        country = 'British Indian Ocean Territory'; //7
                    else if ((countryCode.equals('+62') || countryCode.equals('62') || countryCode.equals('0062') || countryCode.equals('062')) && mSize == 7)
                        country = 'Indonesia'; //7
                    else if ((countryCode.equals('+98') || countryCode.equals('98') || countryCode.equals('0098') || countryCode.equals('098')) && mSize == 7)
                        country = 'Iran'; //7
                    else if ((countryCode.equals('+964') || countryCode.equals('964') || countryCode.equals('00964') || countryCode.equals('0964')) && mSize == 7)
                        country = 'Iraq'; //7
                    else if ((countryCode.equals('+353') || countryCode.equals('353') || countryCode.equals('00353') || countryCode.equals('0353')) && mSize == 9)
                        country = 'Ireland'; //9
                    else if ((countryCode.equals('+972') || countryCode.equals('972') || countryCode.equals('00972') || countryCode.equals('0972')) && mSize == 9)
                        country = 'Israel'; //9
                    else if ((countryCode.equals('+81') || countryCode.equals('81') || countryCode.equals('0081') || countryCode.equals('081')) && mSize == 11)
                        country = 'Japan'; //11
                    else if ((countryCode.equals('+7') || countryCode.equals('7') || countryCode.equals('007') || countryCode.equals('07')) && mSize == 10)
                        country = 'Kazakhstan'; //10
                    else if ((countryCode.equals('+965') || countryCode.equals('965') || countryCode.equals('00965') || countryCode.equals('0965')) && mSize == 8)
                        country = 'Kuwait'; //8
                    else if ((countryCode.equals('+960') || countryCode.equals('960') || countryCode.equals('00960') || countryCode.equals('0960')) && mSize == 7)
                        country = 'Maldives'; //7-
                    else if ((countryCode.equals('+852') || countryCode.equals('852') || countryCode.equals('00852') || countryCode.equals('0852')) && mSize == 8)
                        country = 'Hong Kong'; //8
                    else if ((countryCode.equals('+47') || countryCode.equals('47') || countryCode.equals('0047') || countryCode.equals('047')) && mSize == 8)
                        country = 'Norway'; //8-
                    else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                        country = 'South Korea'; //?- 
                    else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                        country = 'Argentina'; //?-
                }
                count = count + 1;
            }
        }
        
        if (string.isNotBlank(formattedphone) && formattedPhone.length() > 8 && string.isBlank(country)) {
            
            count = 1;
            while (String.isBlank(country) && count <= 5) {
                Integer i = formattedPhone.length() - count;
                countryCode = formattedPhone.subString(0, formattedPhone.length() - i);
                mobileNumber =formattedPhone.substring(countryCode.length());
                mSize = mobileNumber.length();
                System.debug('formattedPhone=========' + mobileNumber );
                
                
                if(string.isBlank(country)){
                    if ((countryCode.equals('+60') || countryCode.equals('60') || countryCode.equals('0060') || countryCode.equals('060')) && mSize == 7)
                        country = 'Malaysia'; //7-
                    else if(countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061'))
                        country = 'Australia';   
                    else if ((countryCode.equals('+299') || countryCode.equals('299') || countryCode.equals('00299') || countryCode.equals('0299')) && mSize == 6)
                        country = 'Greenland'; //6-
                    else if ((countryCode.equals('+960') || countryCode.equals('960') || countryCode.equals('00960') || countryCode.equals('0960')) && mSize == 7)
                        country = 'Maldives'; //7-
                    else if (countryCode.equals('+974') || countryCode.equals('974') || countryCode.equals('00974') || countryCode.equals('0974'))
                        country = 'Qatar';
                    else if (countryCode.equals('+968') || countryCode.equals('968') || countryCode.equals('00968') || countryCode.equals('0968'))
                        country = 'Oman';
                    else if ((countryCode.equals('+973') || countryCode.equals('973') || countryCode.equals('00973') || countryCode.equals('0973')) && mSize == 8)
                        country = 'Bahrain'; //8-
                    else if (countryCode.equals('+65') || countryCode.equals('65') || countryCode.equals('0065') || countryCode.equals('065'))
                        country = 'Singapore';
                    else if ((countryCode.equals('+852') || countryCode.equals('852') || countryCode.equals('00852') || countryCode.equals('0852')) && mSize == 8)
                        country = 'Hong Kong'; //8-
                    else if (countryCode.equals('+374') || countryCode.equals('374') || countryCode.equals('00374') || countryCode.equals('0374'))
                        country = 'Armenia';
                    else if (countryCode.equals('+501') || countryCode.equals('501') || countryCode.equals('00501') || countryCode.equals('0501'))
                        country = 'Belize';
                    else if (countryCode.equals('+975') || countryCode.equals('975') || countryCode.equals('00975') || countryCode.equals('0975'))
                        country = 'Bhutan'; //-
                    else if (countryCode.equals('+359') || countryCode.equals('359') || countryCode.equals('00359') || countryCode.equals('0359'))
                        country = 'Bulgaria';
                    else if ((countryCode.equals('+226') || countryCode.equals('226') || countryCode.equals('00226') || countryCode.equals('0226')))
                country = 'Burkina Faso'; //10-
                    else if ((countryCode.equals('+257') || countryCode.equals('257') || countryCode.equals('00257') || countryCode.equals('0257')))
                country = 'Burundi'; //10-
                    else if ((countryCode.equals('+94') || countryCode.equals('94') || countryCode.equals('0094') || countryCode.equals('094')) && mSize == 7)
                        country = 'Sri Lanka'; //7
                    else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                        country = 'Argentina'; //?- 
                    else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                        country = 'South Korea'; //?- 
                }
                count = count + 1;
            }
        }
        if (String.isNotBlank(country) && String.isNotBlank(countryCode) && String.isNotBlank((mobileNumber))) {
            details.put('country', country);
            details.put('countryCode', '+'+countryCode);
            details.put('mobileNumber', String.valueOf(mobileNumber));
        } else {
            details.put('country', 'India');
            details.put('countryCode', '+91');
            details.put('mobileNumber', formattedPhone);
        }
        System.debug('"countryCode="'+details+'mobilePhone='+formattedPhone);
        return details;
    }
    
    public static Map <String, String> getCountryByCountryCode(String countryCode) {
        string country = '';
        Map <String, String> details = new Map <String, String>();
        System.debug('countryCode=========' + countryCode);
        
        if(string.isBlank(country)){
            if((countryCode.equals('+86') || countryCode.equals('86') || countryCode.equals('0086') || countryCode.equals('086')))
                country = 'China'; //11-
            else if ((countryCode.equals('+55') || countryCode.equals('55') || countryCode.equals('0055') || countryCode.equals('055')))
                country = 'Brazil'; //11-            
            else if ((countryCode.equals('+297') || countryCode.equals('358') || countryCode.equals('00358') || countryCode.equals('0358')))
                country = 'Åland Islands'; //10-
            else if ((countryCode.equals('+880') || countryCode.equals('880') || countryCode.equals('00880') || countryCode.equals('0880')))
                country = 'Bangladesh'; //10-
            else if ((countryCode.equals('+1-246') || countryCode.equals('1-246') || countryCode.equals('001-246') || countryCode.equals('01-246')))
                country = 'Barbados'; //10-
            else if (countryCode.equals('+39') || countryCode.equals('39') || countryCode.equals('0039') || countryCode.equals('039'))
                country = 'Italy'; //10-
             else if ((countryCode.equals('+1-876') || countryCode.equals('1-876') || countryCode.equals('001-876') || countryCode.equals('01-876')))
                        country = 'Jamaica'; //7
            else if ((countryCode.equals('+976') || countryCode.equals('976') || countryCode.equals('00976') || countryCode.equals('0976')))
                country = 'Mongolia'; //10-
            else if ((countryCode.equals('+977') || countryCode.equals('977') || countryCode.equals('00977') || countryCode.equals('0977')))
                country = 'Nepal'; //10- 
            else if ((countryCode.equals('+358') || countryCode.equals('358') || countryCode.equals('00358') || countryCode.equals('0358')))
                country = 'Finland'; //10- 
            else if (countryCode.equals('+254') || countryCode.equals('254') || countryCode.equals('00254') || countryCode.equals('0254'))
                country = 'Kenya'; //?- 
            else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                country = 'South Korea'; //?- 
            else if ((countryCode.equals('+91') || countryCode.equals('91') || countryCode.equals('0091') || countryCode.equals('091')))
                country = 'India'; //10-
            else if ((countryCode.equals('+355') || countryCode.equals('355') || countryCode.equals('00355') || countryCode.equals('0355')))
                country = 'Albania'; //9-
            else if ((countryCode.equals('+213') || countryCode.equals('213') || countryCode.equals('00213') || countryCode.equals('0213')))
                country = 'Algeria'; //9-
            else if ((countryCode.equals('+994') || countryCode.equals('994') || countryCode.equals('00994') || countryCode.equals('0994')))
                country = 'Azerbaijan'; //9-
            else if ((countryCode.equals('+43') || countryCode.equals('43') || countryCode.equals('0043') || countryCode.equals('043')))
                country = 'Austria'; //10- 
            else if ((countryCode.equals('+20') || countryCode.equals('20') || countryCode.equals('0020') || countryCode.equals('020')))
                country = 'Egypt'; //10- 
            else if ((countryCode.equals('+49') || countryCode.equals('49') || countryCode.equals('0049') || countryCode.equals('049')))
                country = 'Germany'; //10-
            else if ((countryCode.equals('+233') || countryCode.equals('233') || countryCode.equals('00233') || countryCode.equals('0233')))
                country = 'Ghana'; //9-
            else if ((countryCode.equals('+966') || countryCode.equals('966') || countryCode.equals('00966') || countryCode.equals('0966')))
                country = 'Saudi Arabia'; //9-
            else if ((countryCode.equals('+375') || countryCode.equals('375') || countryCode.equals('00375') || countryCode.equals('0375')))
                country = 'Belarus'; //9-
            else if ((countryCode.equals('+855') || countryCode.equals('855') || countryCode.equals('00855') || countryCode.equals('0855')))
                country = 'Cambodia'; //9-
            else if ((countryCode.equals('+237') || countryCode.equals('237') || countryCode.equals('00237') || countryCode.equals('0237')))
                country = 'Cameroon'; //10-
            else if ((countryCode.equals('+1') || countryCode.equals('1') || countryCode.equals('001') || countryCode.equals('01')))
                country = 'Canada'; //10-
            else if ((countryCode.equals('+238') || countryCode.equals('238') || countryCode.equals('00238') || countryCode.equals('0238')))
                country = 'Cape Verde'; //10-
            else if ((countryCode.equals('+1-345') || countryCode.equals('1-345') || countryCode.equals('001-345') || countryCode.equals('01-345')))
                country = 'Cayman Islands'; //10-
            else if ((countryCode.equals('+236') || countryCode.equals('236') || countryCode.equals('00236') || countryCode.equals('0236')))
                country = 'Central African Republic'; //10-
            else if ((countryCode.equals('+235') || countryCode.equals('235') || countryCode.equals('00235') || countryCode.equals('0235')))
                country = 'Chad'; //10-
            else if ((countryCode.equals('+56') || countryCode.equals('56') || countryCode.equals('0056') || countryCode.equals('056')))
                country = 'Chile'; //10-
            else if ((countryCode.equals('+57') || countryCode.equals('57') || countryCode.equals('0057') || countryCode.equals('057')))
                country = 'Colombia'; //10-
            else if ((countryCode.equals('+251') || countryCode.equals('251') || countryCode.equals('00251') || countryCode.equals('0251')))
                country = 'Ethiopia'; //10-
            else if ((countryCode.equals('+995') || countryCode.equals('995') || countryCode.equals('00995') || countryCode.equals('0995')))
                country = 'Georgia'; //9-
            else if ((countryCode.equals('+30') || countryCode.equals('30') || countryCode.equals('0030') || countryCode.equals('030')))
                country = 'Greece'; //10 -
            else if ((countryCode.equals('+52') || countryCode.equals('52') || countryCode.equals('0052') || countryCode.equals('052')))
                country = 'Mexico'; //10-
            else if ((countryCode.equals('+95') || countryCode.equals('95') || countryCode.equals('0095') || countryCode.equals('095')))
                country = 'Myanmar'; //10-
            else if ((countryCode.equals('+63') || countryCode.equals('63') || countryCode.equals('0063') || countryCode.equals('063')))
                country = 'Philippines'; //10-
            else if ((countryCode.equals('+92') || countryCode.equals('92') || countryCode.equals('0092') || countryCode.equals('092')))
                country = 'Pakistan'; //10-
            else if ((countryCode.equals('+64') || countryCode.equals('64') || countryCode.equals('0064') || countryCode.equals('064')))
                country = 'New Zealand'; //10-
            else if ((countryCode.equals('+351') || countryCode.equals('351') || countryCode.equals('00351') || countryCode.equals('0351')))
                country = 'Portugal'; //9-
            else if ((countryCode.equals('+249') || countryCode.equals('249') || countryCode.equals('00249') || countryCode.equals('0249')))
                        country = 'Sudan'; //7
            else if ((countryCode.equals('+211') || countryCode.equals('211') || countryCode.equals('00211') || countryCode.equals('0211')))
                country = 'Sudan, South'; //10-
            else if ((countryCode.equals('+963') || countryCode.equals('963') || countryCode.equals('00963') || countryCode.equals('0963')))
                country = 'Syria'; //9 -
            else if ((countryCode.equals('+46') || countryCode.equals('46') || countryCode.equals('0046') || countryCode.equals('046')))
                country = 'Sweden'; //10-
            else if ((countryCode.equals('+886') || countryCode.equals('886') || countryCode.equals('00886') || countryCode.equals('0886')))
                country = 'Taiwan'; //9-
            else if ((countryCode.equals('+255') || countryCode.equals('255') || countryCode.equals('00255') || countryCode.equals('0255')))
                country = 'Tanzania'; //9-
            else if ((countryCode.equals('+971') || countryCode.equals('971') || countryCode.equals('00971') || countryCode.equals('0971')))
                country = 'United Arab Emirates'; //9 -
            else if ((countryCode.equals('+44') || countryCode.equals('44') || countryCode.equals('0044') || countryCode.equals('044')))
                country = 'United Kingdom'; //10-
            else if ((countryCode.equals('+380') || countryCode.equals('380') || countryCode.equals('00380') || countryCode.equals('0380')))
                country = 'Ukraine'; //9 -
            else if ((countryCode.equals('+967') || countryCode.equals('967') || countryCode.equals('00967') || countryCode.equals('0967')))
                country = 'Yemen'; //9-
            else if ((countryCode.equals('+1') || countryCode.equals('1') || countryCode.equals('01') || countryCode.equals('001')))
                country = 'United States'; //10-
            else if ((countryCode.equals('+598') || countryCode.equals('598') || countryCode.equals('00598') || countryCode.equals('0598')))
                country = 'Uruguay'; //10-
            else if ((countryCode.equals('+260') || countryCode.equals('260') || countryCode.equals('00260') || countryCode.equals('0260')))
                country = 'Zambia'; //8-
            else if ((countryCode.equals('+93') || countryCode.equals('93') || countryCode.equals('0093') || countryCode.equals('093')))
                country = 'Afghanistan'; //9-     
            else if ((countryCode.equals('+506') || countryCode.equals('506') || countryCode.equals('00506') || countryCode.equals('0506')))
                country = 'Costa Rica'; //8-
            else if ((countryCode.equals('+36') || countryCode.equals('36') || countryCode.equals('0036') || countryCode.equals('036')))
                country = 'Hungary'; //9-
            else if ((countryCode.equals('+965') || countryCode.equals('965') || countryCode.equals('00965') || countryCode.equals('0965')))
                country = 'Kuwait'; //8-
            else if ((countryCode.equals('+973') || countryCode.equals('973') || countryCode.equals('00973') || countryCode.equals('0973')))
                country = 'Bahrain'; //8 -
            else if ((countryCode.equals('+32') || countryCode.equals('32') || countryCode.equals('0032') || countryCode.equals('032')))
                country = 'Belgium'; //9-
            else if ((countryCode.equals('+387') || countryCode.equals('387') || countryCode.equals('00387') || countryCode.equals('0387')))
                country = 'Bosnia and Herzegovina'; //8-
            else if ((countryCode.equals('+593') || countryCode.equals('593') || countryCode.equals('00593') || countryCode.equals('0593')))
                country = 'Ecuador'; //8-
            else if ((countryCode.equals('+33') || countryCode.equals('33') || countryCode.equals('0033') || countryCode.equals('033')))
                country = 'France'; //9-  
            else if ((countryCode.equals('+230') || countryCode.equals('230') || countryCode.equals('00230') || countryCode.equals('0230')))
                country = 'Mauritius'; //8-
            else if ((countryCode.equals('+31') || countryCode.equals('31') || countryCode.equals('0031') || countryCode.equals('031')))
                country = 'Netherlands'; //9-
            else if ((countryCode.equals('+227') || countryCode.equals('227') || countryCode.equals('00227') || countryCode.equals('0227')))
                country = 'Niger'; //10-
            else if ((countryCode.equals('+234') || countryCode.equals('234') || countryCode.equals('00234') || countryCode.equals('0234')))
                country = 'Nigeria'; //8-
            else if ((countryCode.equals('+92') || countryCode.equals('92') || countryCode.equals('0092') || countryCode.equals('092')))
                country = 'Pakistan'; //8-
            else if ((countryCode.equals('+507') || countryCode.equals('507') || countryCode.equals('00507') || countryCode.equals('0507')))
                country = 'Panama'; //8-
            else if ((countryCode.equals('+51') || countryCode.equals('51') || countryCode.equals('0051') || countryCode.equals('051')))
                country = 'Peru'; //9-
            else if ((countryCode.equals('+48') || countryCode.equals('48') || countryCode.equals('0048') || countryCode.equals('048')))
                country = 'Poland'; //9 -
            else if ((countryCode.equals('+7') || countryCode.equals('7') || countryCode.equals('007') || countryCode.equals('07')))
                country = 'Russia'; //10- 
            else if ((countryCode.equals('+27') || countryCode.equals('27') || countryCode.equals('0027') || countryCode.equals('027')))
                country = 'South Africa'; //9 -
            else if ((countryCode.equals('+34') || countryCode.equals('34') || countryCode.equals('0034') || countryCode.equals('034')))
                country = 'Spain'; //9-
            else if ((countryCode.equals('+41') || countryCode.equals('41') || countryCode.equals('0041') || countryCode.equals('041')))
                country = 'Switzerland'; //9-
            else if ((countryCode.equals('+66') || countryCode.equals('66') || countryCode.equals('0066') || countryCode.equals('066')))
                country = 'Thailand'; //9-
            else if ((countryCode.equals('+992') || countryCode.equals('992') || countryCode.equals('00992') || countryCode.equals('0992')))
                        country = 'Tajikistan'; //7
            else if ((countryCode.equals('+90') || countryCode.equals('90') || countryCode.equals('0090') || countryCode.equals('090')))
                country = 'Turkey'; //9-
            else if ((countryCode.equals('+974') || countryCode.equals('974') || countryCode.equals('00974') || countryCode.equals('0974')))
                country = 'Qatar'; //8
            else if (countryCode.equals('+968') || countryCode.equals('968') || countryCode.equals('00968') || countryCode.equals('0968'))
                country = 'Oman'; //?
            if ((countryCode.equals('+45') || countryCode.equals('45') || countryCode.equals('0045') || countryCode.equals('045')))
                country = 'Denmark'; //8-
            else if ((countryCode.equals('+65') || countryCode.equals('65') || countryCode.equals('0065') || countryCode.equals('065')))
                country = 'Singapore'; //8
            else if ((countryCode.equals('+852') || countryCode.equals('852') || countryCode.equals('00852') || countryCode.equals('0852')))
                country = 'Hong Kong'; //8
            else if ((countryCode.equals('+297') || countryCode.equals('297') || countryCode.equals('00297') || countryCode.equals('0297')))
                country = 'Aruba'; //7
            else if ((countryCode.equals('+64') || countryCode.equals('64') || countryCode.equals('0064') || countryCode.equals('064')))
                country = 'New Zealand'; //8 -
            else if ((countryCode.equals('246') || countryCode.equals('00246') || countryCode.equals('0246')))
                country = 'British Indian Ocean Territory'; //7
            else if ((countryCode.equals('+62') || countryCode.equals('62') || countryCode.equals('0062') || countryCode.equals('062')))
                country = 'Indonesia'; //7
            else if ((countryCode.equals('+353') || countryCode.equals('353') || countryCode.equals('00353') || countryCode.equals('0353')))
                country = 'Ireland'; //9
            else if ((countryCode.equals('+972') || countryCode.equals('972') || countryCode.equals('00972') || countryCode.equals('0972')))
                country = 'Israel'; //9
            else if ((countryCode.equals('+81') || countryCode.equals('81') || countryCode.equals('0081') || countryCode.equals('081')))
                country = 'Japan'; //11
            else if ((countryCode.equals('+7') || countryCode.equals('7') || countryCode.equals('007') || countryCode.equals('07')))
                country = 'Kazakhstan'; //10
            else if ((countryCode.equals('+960') || countryCode.equals('960') || countryCode.equals('00960') || countryCode.equals('0960')))
                country = 'Maldives'; //7-
            else if ((countryCode.equals('+223') || countryCode.equals('223') || countryCode.equals('00223') || countryCode.equals('0223')))
                country = 'Mali'; //8-
            else if ((countryCode.equals('+47') || countryCode.equals('47') || countryCode.equals('0047') || countryCode.equals('047')))
                country = 'Norway'; //8- 
            else if ((countryCode.equals('+60') || countryCode.equals('60') || countryCode.equals('0060') || countryCode.equals('060')))
                country = 'Malaysia'; //7-
            else if ((countryCode.equals('+299') || countryCode.equals('299') || countryCode.equals('00299') || countryCode.equals('0299')))
                country = 'Greenland'; //6-
            else if ((countryCode.equals('+1-473') || countryCode.equals('1-473') || countryCode.equals('001-473') || countryCode.equals('01-473')))
                        country = 'Grenada'; //9-
            else if (countryCode.equals('+974') || countryCode.equals('974') || countryCode.equals('00974') || countryCode.equals('0974'))
                country = 'Qatar';
            else if (countryCode.equals('+968') || countryCode.equals('968') || countryCode.equals('00968') || countryCode.equals('0968'))
                country = 'Oman';
            else if ((countryCode.equals('+973') || countryCode.equals('973') || countryCode.equals('00973') || countryCode.equals('0973')))
                country = 'Bahrain'; //8-
            else if (countryCode.equals('+374') || countryCode.equals('374') || countryCode.equals('00374') || countryCode.equals('0374'))
                country = 'Armenia';
            else if (countryCode.equals('+501') || countryCode.equals('501') || countryCode.equals('00501') || countryCode.equals('0501'))
                country = 'Belize';
                else if ((countryCode.equals('+229') || countryCode.equals('229') || countryCode.equals('00229') || countryCode.equals('0229')))
                country = 'Benin'; //10-
                else if ((countryCode.equals('+1-441') || countryCode.equals('1-441') || countryCode.equals('001-441') || countryCode.equals('01-441')))
                country = 'Bermuda'; //10-
            else if (countryCode.equals('+975') || countryCode.equals('975') || countryCode.equals('00975') || countryCode.equals('0975'))
                country = 'Bhutan'; //-
            else if ((countryCode.equals('+591') || countryCode.equals('591') || countryCode.equals('00591') || countryCode.equals('0591')))
                country = 'Bolivia'; //10-
            else if (countryCode.equals('+359') || countryCode.equals('359') || countryCode.equals('00359') || countryCode.equals('0359'))
                country = 'Bulgaria';
            else if ((countryCode.equals('+94') || countryCode.equals('94') || countryCode.equals('0094') || countryCode.equals('094')))
                country = 'Sri Lanka'; //7
            else if (countryCode.equals('+54') || countryCode.equals('54') || countryCode.equals('0054') || countryCode.equals('054'))
                country = 'Argentina'; //?-
            else if (countryCode.equals('+225') || countryCode.equals('225') || countryCode.equals('00225') || countryCode.equals('0225'))
                country = 'Côte d\'Ivoire'; //?-  
            else if (countryCode.equals('+82') || countryCode.equals('82') || countryCode.equals('0082') || countryCode.equals('082'))
                country = 'South Korea'; //?- 
            else if(countryCode.equals('+61') || countryCode.equals('61') || countryCode.equals('0061') || countryCode.equals('061'))
                country = 'Australia';   
           else if ((countryCode.equals('+357') || countryCode.equals('357') || countryCode.equals('00357') || countryCode.equals('0357')))
                country = 'Cyprus'; //10-
           else if ((countryCode.equals('+253') || countryCode.equals('253') || countryCode.equals('00253') || countryCode.equals('0253')))
                        country = 'Djibouti'; //10-
           else if ((countryCode.equals('+98') || countryCode.equals('98') || countryCode.equals('0098') || countryCode.equals('098')))
                        country = 'Iran'; //7
           else if ((countryCode.equals('+964') || countryCode.equals('964') || countryCode.equals('00964') || countryCode.equals('0964')))
                        country = 'Iraq'; //7
           else if ((countryCode.equals('+962') || countryCode.equals('962') || countryCode.equals('00962') || countryCode.equals('0962')))
                        country = 'Jordan'; //8- 
           else if ((countryCode.equals('+961') || countryCode.equals('961') || countryCode.equals('00961') || countryCode.equals('0961')) )
                        country = 'Lebanon'; //7
           else if ((countryCode.equals('+218') || countryCode.equals('218') || countryCode.equals('00218') || countryCode.equals('0218')))
                        country = 'Libya'; //7 
           else if ((countryCode.equals('+356') ||countryCode.equals('356') || countryCode.equals('00356') || countryCode.equals('0356')))
                        country = 'Malta'; //10-
           else if ((countryCode.equals('+212') || countryCode.equals('212') || countryCode.equals('00212') || countryCode.equals('0212')))
                        country = 'Morocco'; //8-
           else if ((countryCode.equals('+970') ||countryCode.equals('970') || countryCode.equals('00970') || countryCode.equals('0970')))
                        country = 'Palestine'; //10-
           else if ((countryCode.equals('+7') || countryCode.equals('7') || countryCode.equals('007') || countryCode.equals('07')))
                        country = 'Russia'; //10- 
           else if ((countryCode.equals('+248') || countryCode.equals('248') || countryCode.equals('00248') || countryCode.equals('0248')))
                        country = 'Seychelles'; //7
           else if ((countryCode.equals('+216') || countryCode.equals('216') || countryCode.equals('00216') || countryCode.equals('0216')))
                        country = 'Tunisia'; //9-
           else if ((countryCode.equals('+993') || countryCode.equals('993') || countryCode.equals('00993') || countryCode.equals('0993')))
                        country = 'Turkmenistan'; //7
           else if ((countryCode.equals('+998') || countryCode.equals('998') || countryCode.equals('00998') || countryCode.equals('0998')))
                        country = 'Uzbekistan'; //8-
           else if ((countryCode.equals('+84') || countryCode.equals('84') || countryCode.equals('0084') || countryCode.equals('084')))
                        country = 'Vietnam'; //8-
           else if ((countryCode.equals('+263') || countryCode.equals('263') || countryCode.equals('00263') || countryCode.equals('0263')))
                        country = 'Zimbabwe'; //8-
        }
        
        if (String.isNotBlank(country)) {
            details.put('country', country);           
        } else {
            details.put('country', 'India');          
        }
        System.debug('"countryCode="'+details);
        return details;
    }
    
    public static String formatPhone(String phone) {
        phone.replaceAll('\\s+', '');
        String regex = '[^0-9]';
        String formattedPhone = phone.replaceAll(regex, '');
        System.debug('Inside formatted phone method:' + formattedPhone);
        return formattedPhone;
    }   
}