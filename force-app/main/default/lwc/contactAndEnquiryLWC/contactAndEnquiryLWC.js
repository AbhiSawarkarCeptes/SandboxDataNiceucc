import { LightningElement, track, api } from 'lwc';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContact from '@salesforce/apex/ContactAndEnquiryLWCController.createContact';
import My_Resource from '@salesforce/resourceUrl/Broker_logo';
import searchBrokerAccount from '@salesforce/apex/ContactAndEnquiryLWCController.searchBrokerAccount';
import searchBrokerContact from '@salesforce/apex/ContactAndEnquiryLWCController.searchBrokerContact';


export default class ContactAndEnquiryLWC extends LightningElement {
    @track firstName;
    @track lastName;
    @track email;
    @track phone;
    @track description;
    @track displayErrorMessage = false;
    @track errorMessage = '';
    @track successMessage = '';
    @track displaysuccessMessage = false;
    @track selectedCountry = '';
    @track prefLang;
    @track enqType;
    @track enqSource;
    cntryCode = '';
    showSpinner = true;
    searchResults = [];
    searchContactResults = [];
    logoImg = My_Resource;
    cardStyle = '';
    searchKeyBrkAcc = '';
    searchKeyBrkCont = '';
    searchBrkAccId = '';
    searchBrkContId = '';
    showResults = false;
    showContactResults = false;
    showBrokerDetails = false;
    contactInput = true;

    connectedCallback() {
        if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
            this.cardStyle = 'margin: 15rem 2rem; box-shadow: 0 0 15px black; background: black;';
            this.showSpinner = false;
        } else {
            this.cardStyle = 'margin: 2rem 22rem; box-shadow: 0 0 15px black; background: black;';
            this.showSpinner = false;
        }
    }
    get options() {
        return [
            { label: 'Arabic', value: 'Arabic' },
            { label: 'Russian', value: 'Russian' },
            { label: 'French', value: 'French' },
            { label: 'English', value: 'English' },
            { label: 'Hindi', value: 'Hindi' }
        ];
    }
    get optionsTypeOfEnquiry() {
        return [
            { label: 'Direct', value: 'Direct' },
            { label: 'Indirect', value: 'Indirect' },
        ];
    }
    get optionsEnquirySource() {
        return [
            { label: 'Web', value: 'Web' },
            { label: 'Direct Mail', value: 'Direct Mail' },
            { label: 'Phone Enquiry', value: 'Phone Enquiry' },
            { label: 'Word of Mouth', value: 'Word of Mouth' },
            { label: 'Walk-in', value: 'Walk-in' },
            { label: 'Channel Partner', value: 'Channel Partner' },
            { label: 'Sobha Connect', value: 'Sobha Connect' },
            { label: 'Loyalty Sales', value: 'Loyalty Sales' },
            { label: 'Trade Show/ Exhibition', value: 'Trade Show/ Exhibition' },
            { label: 'Advertisement', value: 'Advertisement' },
            { label: 'Hoarding', value: 'Hoarding' },
            { label: 'Newspaper', value: 'Newspaper' },
            { label: 'Radio', value: 'Radio' },
            { label: 'Print Media', value: 'Print Media' },
            { label: 'Digital Platform', value: 'Digital Platform' },
            { label: 'Property Portal', value: 'Property Portal' },
            { label: 'Contact Centre', value: 'Contact Centre' },
            { label: 'Mall Stand', value: 'Mall Stand' },
            { label: 'Unified Messaging', value: 'Unified Messaging' },
            { label: 'Telesales', value: 'Telesales' },
            { label: 'Employee Reference', value: 'Employee Reference' },
            { label: 'Management Reference', value: 'Management Reference' },
            { label: 'Employee', value: 'Employee' },
            { label: 'Stand Leads', value: 'Stand Leads' }
        ];
    }

    countryOptions = [
 {
  label: "Afghanistan",
  value: "AF",
  code: "93"
 },
 {
  label: "Åland Islands",
  value: "AX",
  code: "358"
 },
 {
  label: "Albania",
  value: "AL",
  code: "355"
 },
 {
  label: "Algeria",
  value: "DZ",
  code: "213"
 },
 {
  label: "American Samoa",
  value: "AS",
  code: "1"
 },
 {
  label: "Andorra",
  value: "AD",
  code: "376"
 },
 {
  label: "Angola",
  value: "AO",
  code: "244"
 },
 {
  label: "Anguilla",
  value: "AI",
  code: "1"
 },
 {
  label: "Antarctica",
  value: "AQ",
  code: "672"
 },
 {
  label: "Antigua and Barbuda",
  value: "AG",
  code: "1"
 },
 {
  label: "Argentina",
  value: "AR",
  code: "54"
 },
 {
  label: "Armenia",
  value: "AM",
  code: "374"
 },
 {
  label: "Aruba",
  value: "AW",
  code: "297"
 },
 {
  label: "Australia",
  value: "AU",
  code: "61"
 },
 {
  label: "Austria",
  value: "AT",
  code: "43"
 },
 {
  label: "Azerbaijan",
  value: "AZ",
  code: "994"
 },
 {
  label: "Bahamas",
  value: "BS",
  code: "1"
 },
 {
  label: "Bahrain",
  value: "BH",
  code: "973"
 },
 {
  label: "Bangladesh",
  value: "BD",
  code: "880"
 },
 {
  label: "Barbados",
  value: "BB",
  code: "1"
 },
 {
  label: "Belarus",
  value: "BY",
  code: "375"
 },
 {
  label: "Belgium",
  value: "BE",
  code: "32"
 },
 {
  label: "Belize",
  value: "BZ",
  code: "501"
 },
 {
  label: "Benin",
  value: "BJ",
  code: "229"
 },
 {
  label: "Bermuda",
  value: "BM",
  code: "1"
 },
 {
  label: "Bhutan",
  value: "BT",
  code: "975"
 },
 {
  label: "Bolivia (Plurinational State of)",
  value: "BO",
  code: "591"
 },
 {
  label: "Bonaire, Sint Eustatius and Saba",
  value: "BQ",
  code: "599"
 },
 {
  label: "Bosnia and Herzegovina",
  value: "BA",
  code: "387"
 },
 {
  label: "Botswana",
  value: "BW",
  code: "267"
 },
 {
  label: "Bouvet Island",
  value: "BV",
  code: "47"
 },
 {
  label: "Brazil",
  value: "BR",
  code: "55"
 },
 {
  label: "British Indian Ocean Territory",
  value: "IO",
  code: "246"
 },
 {
  label: "United States Minor Outlying Islands",
  value: "UM",
  code: "246"
 },
 {
  label: "Virgin Islands (British)",
  value: "VG",
  code: "1"
 },
 {
  label: "Virgin Islands (U.S.)",
  value: "VI",
  code: "1 340"
 },
 {
  label: "Brunei Darussalam",
  value: "BN",
  code: "673"
 },
 {
  label: "Bulgaria",
  value: "BG",
  code: "359"
 },
 {
  label: "Burkina Faso",
  value: "BF",
  code: "226"
 },
 {
  label: "Burundi",
  value: "BI",
  code: "257"
 },
 {
  label: "Cambodia",
  value: "KH",
  code: "855"
 },
 {
  label: "Cameroon",
  value: "CM",
  code: "237"
 },
 {
  label: "Canada",
  value: "CA",
  code: "1"
 },
 {
  label: "Cabo Verde",
  value: "CV",
  code: "238"
 },
 {
  label: "Cayman Islands",
  value: "KY",
  code: "1"
 },
 {
  label: "Central African Republic",
  value: "CF",
  code: "236"
 },
 {
  label: "Chad",
  value: "TD",
  code: "235"
 },
 {
  label: "Chile",
  value: "CL",
  code: "56"
 },
 {
  label: "China",
  value: "CN",
  code: "86"
 },
 {
  label: "Christmas Island",
  value: "CX",
  code: "61"
 },
 {
  label: "Cocos (Keeling) Islands",
  value: "CC",
  code: "61"
 },
 {
  label: "Colombia",
  value: "CO",
  code: "57"
 },
 {
  label: "Comoros",
  value: "KM",
  code: "269"
 },
 {
  label: "Congo",
  value: "CG",
  code: "242"
 },
 {
  label: "Congo (Democratic Republic of the)",
  value: "CD",
  code: "243"
 },
 {
  label: "Cook Islands",
  value: "CK",
  code: "682"
 },
 {
  label: "Costa Rica",
  value: "CR",
  code: "506"
 },
 {
  label: "Croatia",
  value: "HR",
  code: "385"
 },
 {
  label: "Cuba",
  value: "CU",
  code: "53"
 },
 {
  label: "Curaçao",
  value: "CW",
  code: "599"
 },
 {
  label: "Cyprus",
  value: "CY",
  code: "357"
 },
 {
  label: "Czech Republic",
  value: "CZ",
  code: "420"
 },
 {
  label: "Denmark",
  value: "DK",
  code: "45"
 },
 {
  label: "Djibouti",
  value: "DJ",
  code: "253"
 },
 {
  label: "Dominica",
  value: "DM",
  code: "1"
 },
 {
  label: "Dominican Republic",
  value: "DO",
  code: "1"
 },
 {
  label: "Ecuador",
  value: "EC",
  code: "593"
 },
 {
  label: "Egypt",
  value: "EG",
  code: "20"
 },
 {
  label: "El Salvador",
  value: "SV",
  code: "503"
 },
 {
  label: "Equatorial Guinea",
  value: "GQ",
  code: "240"
 },
 {
  label: "Eritrea",
  value: "ER",
  code: "291"
 },
 {
  label: "Estonia",
  value: "EE",
  code: "372"
 },
 {
  label: "Ethiopia",
  value: "ET",
  code: "251"
 },
 {
  label: "Falkland Islands (Malvinas)",
  value: "FK",
  code: "500"
 },
 {
  label: "Faroe Islands",
  value: "FO",
  code: "298"
 },
 {
  label: "Fiji",
  value: "FJ",
  code: "679"
 },
 {
  label: "Finland",
  value: "FI",
  code: "358"
 },
 {
  label: "France",
  value: "FR",
  code: "33"
 },
 {
  label: "French Guiana",
  value: "GF",
  code: "594"
 },
 {
  label: "French Polynesia",
  value: "PF",
  code: "689"
 },
 {
  label: "French Southern Territories",
  value: "TF",
  code: "262"
 },
 {
  label: "Gabon",
  value: "GA",
  code: "241"
 },
 {
  label: "Gambia",
  value: "GM",
  code: "220"
 },
 {
  label: "Georgia",
  value: "GE",
  code: "995"
 },
 {
  label: "Germany",
  value: "DE",
  code: "49"
 },
 {
  label: "Ghana",
  value: "GH",
  code: "233"
 },
 {
  label: "Gibraltar",
  value: "GI",
  code: "350"
 },
 {
  label: "Greece",
  value: "GR",
  code: "30"
 },
 {
  label: "Greenland",
  value: "GL",
  code: "299"
 },
 {
  label: "Grenada",
  value: "GD",
  code: "1"
 },
 {
  label: "Guadeloupe",
  value: "GP",
  code: "590"
 },
 {
  label: "Guam",
  value: "GU",
  code: "1"
 },
 {
  label: "Guatemala",
  value: "GT",
  code: "502"
 },
 {
  label: "Guernsey",
  value: "GG",
  code: "44"
 },
 {
  label: "Guinea",
  value: "GN",
  code: "224"
 },
 {
  label: "Guinea-Bissau",
  value: "GW",
  code: "245"
 },
 {
  label: "Guyana",
  value: "GY",
  code: "592"
 },
 {
  label: "Haiti",
  value: "HT",
  code: "509"
 },
 {
  label: "Heard Island and McDonald Islands",
  value: "HM",
  code: "672"
 },
 {
  label: "Vatican City",
  value: "VA",
  code: "379"
 },
 {
  label: "Honduras",
  value: "HN",
  code: "504"
 },
 {
  label: "Hungary",
  value: "HU",
  code: "36"
 },
 {
  label: "Hong Kong",
  value: "HK",
  code: "852"
 },
 {
  label: "Iceland",
  value: "IS",
  code: "354"
 },
 {
  label: "India",
  value: "IN",
  code: "91"
 },
 {
  label: "Indonesia",
  value: "ID",
  code: "62"
 },
 {
  label: "Ivory Coast",
  value: "CI",
  code: "225"
 },
 {
  label: "Iran (Islamic Republic of)",
  value: "IR",
  code: "98"
 },
 {
  label: "Iraq",
  value: "IQ",
  code: "964"
 },
 {
  label: "Ireland",
  value: "IE",
  code: "353"
 },
 {
  label: "Isle of Man",
  value: "IM",
  code: "44"
 },
 {
  label: "Israel",
  value: "IL",
  code: "972"
 },
 {
  label: "Italy",
  value: "IT",
  code: "39"
 },
 {
  label: "Jamaica",
  value: "JM",
  code: "1"
 },
 {
  label: "Japan",
  value: "JP",
  code: "81"
 },
 {
  label: "Jersey",
  value: "JE",
  code: "44"
 },
 {
  label: "Jordan",
  value: "JO",
  code: "962"
 },
 {
  label: "Kazakhstan",
  value: "KZ",
  code: "76"
 },
 {
  label: "Kenya",
  value: "KE",
  code: "254"
 },
 {
  label: "Kiribati",
  value: "KI",
  code: "686"
 },
 {
  label: "Kuwait",
  value: "KW",
  code: "965"
 },
 {
  label: "Kyrgyzstan",
  value: "KG",
  code: "996"
 },
 {
  label: "Lao People's Democratic Republic",
  value: "LA",
  code: "856"
 },
 {
  label: "Latvia",
  value: "LV",
  code: "371"
 },
 {
  label: "Lebanon",
  value: "LB",
  code: "961"
 },
 {
  label: "Lesotho",
  value: "LS",
  code: "266"
 },
 {
  label: "Liberia",
  value: "LR",
  code: "231"
 },
 {
  label: "Libya",
  value: "LY",
  code: "218"
 },
 {
  label: "Liechtenstein",
  value: "LI",
  code: "423"
 },
 {
  label: "Lithuania",
  value: "LT",
  code: "370"
 },
 {
  label: "Luxembourg",
  value: "LU",
  code: "352"
 },
 {
  label: "Macao",
  value: "MO",
  code: "853"
 },
 {
  label: "North Macedonia",
  value: "MK",
  code: "389"
 },
 {
  label: "Madagascar",
  value: "MG",
  code: "261"
 },
 {
  label: "Malawi",
  value: "MW",
  code: "265"
 },
 {
  label: "Malaysia",
  value: "MY",
  code: "60"
 },
 {
  label: "Maldives",
  value: "MV",
  code: "960"
 },
 {
  label: "Mali",
  value: "ML",
  code: "223"
 },
 {
  label: "Malta",
  value: "MT",
  code: "356"
 },
 {
  label: "Marshall Islands",
  value: "MH",
  code: "692"
 },
 {
  label: "Martinique",
  value: "MQ",
  code: "596"
 },
 {
  label: "Mauritania",
  value: "MR",
  code: "222"
 },
 {
  label: "Mauritius",
  value: "MU",
  code: "230"
 },
 {
  label: "Mayotte",
  value: "YT",
  code: "262"
 },
 {
  label: "Mexico",
  value: "MX",
  code: "52"
 },
 {
  label: "Micronesia (Federated States of)",
  value: "FM",
  code: "691"
 },
 {
  label: "Moldova (Republic of)",
  value: "MD",
  code: "373"
 },
 {
  label: "Monaco",
  value: "MC",
  code: "377"
 },
 {
  label: "Mongolia",
  value: "MN",
  code: "976"
 },
 {
  label: "Montenegro",
  value: "ME",
  code: "382"
 },
 {
  label: "Montserrat",
  value: "MS",
  code: "1"
 },
 {
  label: "Morocco",
  value: "MA",
  code: "212"
 },
 {
  label: "Mozambique",
  value: "MZ",
  code: "258"
 },
 {
  label: "Myanmar",
  value: "MM",
  code: "95"
 },
 {
  label: "Namibia",
  value: "NA",
  code: "264"
 },
 {
  label: "Nauru",
  value: "NR",
  code: "674"
 },
 {
  label: "Nepal",
  value: "NP",
  code: "977"
 },
 {
  label: "Netherlands",
  value: "NL",
  code: "31"
 },
 {
  label: "New Caledonia",
  value: "NC",
  code: "687"
 },
 {
  label: "New Zealand",
  value: "NZ",
  code: "64"
 },
 {
  label: "Nicaragua",
  value: "NI",
  code: "505"
 },
 {
  label: "Niger",
  value: "NE",
  code: "227"
 },
 {
  label: "Nigeria",
  value: "NG",
  code: "234"
 },
 {
  label: "Niue",
  value: "NU",
  code: "683"
 },
 {
  label: "Norfolk Island",
  value: "NF",
  code: "672"
 },
 {
  label: "Korea (Democratic People's Republic of)",
  value: "KP",
  code: "850"
 },
 {
  label: "Northern Mariana Islands",
  value: "MP",
  code: "1"
 },
 {
  label: "Norway",
  value: "NO",
  code: "47"
 },
 {
  label: "Oman",
  value: "OM",
  code: "968"
 },
 {
  label: "Pakistan",
  value: "PK",
  code: "92"
 },
 {
  label: "Palau",
  value: "PW",
  code: "680"
 },
 {
  label: "Palestine, State of",
  value: "PS",
  code: "970"
 },
 {
  label: "Panama",
  value: "PA",
  code: "507"
 },
 {
  label: "Papua New Guinea",
  value: "PG",
  code: "675"
 },
 {
  label: "Paraguay",
  value: "PY",
  code: "595"
 },
 {
  label: "Peru",
  value: "PE",
  code: "51"
 },
 {
  label: "Philippines",
  value: "PH",
  code: "63"
 },
 {
  label: "Pitcairn",
  value: "PN",
  code: "64"
 },
 {
  label: "Poland",
  value: "PL",
  code: "48"
 },
 {
  label: "Portugal",
  value: "PT",
  code: "351"
 },
 {
  label: "Puerto Rico",
  value: "PR",
  code: "1"
 },
 {
  label: "Qatar",
  value: "QA",
  code: "974"
 },
 {
  label: "Republic of Kosovo",
  value: "XK",
  code: "383"
 },
 {
  label: "Réunion",
  value: "RE",
  code: "262"
 },
 {
  label: "Romania",
  value: "RO",
  code: "40"
 },
 {
  label: "Russian Federation",
  value: "RU",
  code: "7"
 },
 {
  label: "Rwanda",
  value: "RW",
  code: "250"
 },
 {
  label: "Saint Barthélemy",
  value: "BL",
  code: "590"
 },
 {
  label: "Saint Helena, Ascension and Tristan da Cunha",
  value: "SH",
  code: "290"
 },
 {
  label: "Saint Kitts and Nevis",
  value: "KN",
  code: "1"
 },
 {
  label: "Saint Lucia",
  value: "LC",
  code: "1"
 },
 {
  label: "Saint Martin (French part)",
  value: "MF",
  code: "590"
 },
 {
  label: "Saint Pierre and Miquelon",
  value: "PM",
  code: "508"
 },
 {
  label: "Saint Vincent and the Grenadines",
  value: "VC",
  code: "1"
 },
 {
  label: "Samoa",
  value: "WS",
  code: "685"
 },
 {
  label: "San Marino",
  value: "SM",
  code: "378"
 },
 {
  label: "Sao Tome and Principe",
  value: "ST",
  code: "239"
 },
 {
  label: "Saudi Arabia",
  value: "SA",
  code: "966"
 },
 {
  label: "Senegal",
  value: "SN",
  code: "221"
 },
 {
  label: "Serbia",
  value: "RS",
  code: "381"
 },
 {
  label: "Seychelles",
  value: "SC",
  code: "248"
 },
 {
  label: "Sierra Leone",
  value: "SL",
  code: "232"
 },
 {
  label: "Singapore",
  value: "SG",
  code: "65"
 },
 {
  label: "Sint Maarten (Dutch part)",
  value: "SX",
  code: "1"
 },
 {
  label: "Slovakia",
  value: "SK",
  code: "421"
 },
 {
  label: "Slovenia",
  value: "SI",
  code: "386"
 },
 {
  label: "Solomon Islands",
  value: "SB",
  code: "677"
 },
 {
  label: "Somalia",
  value: "SO",
  code: "252"
 },
 {
  label: "South Africa",
  value: "ZA",
  code: "27"
 },
 {
  label: "South Georgia and the South Sandwich Islands",
  value: "GS",
  code: "500"
 },
 {
  label: "Korea (Republic of)",
  value: "KR",
  code: "82"
 },
 {
  label: "Spain",
  value: "ES",
  code: "34"
 },
 {
  label: "Sri Lanka",
  value: "LK",
  code: "94"
 },
 {
  label: "Sudan",
  value: "SD",
  code: "249"
 },
 {
  label: "South Sudan",
  value: "SS",
  code: "211"
 },
 {
  label: "Suriname",
  value: "SR",
  code: "597"
 },
 {
  label: "Svalbard and Jan Mayen",
  value: "SJ",
  code: "47"
 },
 {
  label: "Swaziland",
  value: "SZ",
  code: "268"
 },
 {
  label: "Sweden",
  value: "SE",
  code: "46"
 },
 {
  label: "Switzerland",
  value: "CH",
  code: "41"
 },
 {
  label: "Syrian Arab Republic",
  value: "SY",
  code: "963"
 },
 {
  label: "Taiwan",
  value: "TW",
  code: "886"
 },
 {
  label: "Tajikistan",
  value: "TJ",
  code: "992"
 },
 {
  label: "Tanzania, United Republic of",
  value: "TZ",
  code: "255"
 },
 {
  label: "Thailand",
  value: "TH",
  code: "66"
 },
 {
  label: "Timor-Leste",
  value: "TL",
  code: "670"
 },
 {
  label: "Togo",
  value: "TG",
  code: "228"
 },
 {
  label: "Tokelau",
  value: "TK",
  code: "690"
 },
 {
  label: "Tonga",
  value: "TO",
  code: "676"
 },
 {
  label: "Trinidad and Tobago",
  value: "TT",
  code: "1"
 },
 {
  label: "Tunisia",
  value: "TN",
  code: "216"
 },
 {
  label: "Turkey",
  value: "TR",
  code: "90"
 },
 {
  label: "Turkmenistan",
  value: "TM",
  code: "993"
 },
 {
  label: "Turks and Caicos Islands",
  value: "TC",
  code: "1"
 },
 {
  label: "Tuvalu",
  value: "TV",
  code: "688"
 },
 {
  label: "Uganda",
  value: "UG",
  code: "256"
 },
 {
  label: "Ukraine",
  value: "UA",
  code: "380"
 },
 {
  label: "United Arab Emirates",
  value: "AE",
  code: "971"
 },
 {
  label: "United Kingdom of Great Britain and Northern Ireland",
  value: "GB",
  code: "44"
 },
 {
  label: "United States of America",
  value: "US",
  code: "1"
 },
 {
  label: "Uruguay",
  value: "UY",
  code: "598"
 },
 {
  label: "Uzbekistan",
  value: "UZ",
  code: "998"
 },
 {
  label: "Vanuatu",
  value: "VU",
  code: "678"
 },
 {
  label: "Venezuela (Bolivarian Republic of)",
  value: "VE",
  code: "58"
 },
 {
  label: "Vietnam",
  value: "VN",
  code: "84"
 },
 {
  label: "Wallis and Futuna",
  value: "WF",
  code: "681"
 },
 {
  label: "Western Sahara",
  value: "EH",
  code: "212"
 },
 {
  label: "Yemen",
  value: "YE",
  code: "967"
 },
 {
  label: "Zambia",
  value: "ZM",
  code: "260"
 },
 {
  label: "Zimbabwe",
  value: "ZW",
  code: "263"
 }
    ];



    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlePhoneChange(event) {
        console.log(event.target.value);
        console.log(this.cntryCode);
        this.phone = event.target.value;
    }

    handleDescChange(event) {
        console.log(event.target.value);
        this.description = event.target.value;
    }

    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        this.phone = this.getCountryCode();
        this.cntryCode = this.getCountryCode();
    }

    handleChangePL(event) {
        this.prefLang = event.detail.value;
    }
    handleChangeET(event) {
        this.enqType = event.detail.value;
        if(this.enqType == 'Indirect') {
            this.showBrokerDetails = true;
        }
        else{
            this.showBrokerDetails = false;
        }
    }
    handleChangeSrc(event) {
        this.enqSource = event.detail.value;
    }

    getCountryCode() {
        for (let country of this.countryOptions) {
            if (country.value === this.selectedCountry) {
                return '+'+country.code;
            }
        }
        return '';
    }
    handleSearchKeyChange(event) {
        this.searchKeyBrkAcc = event.target.value;
        this.showResults = true;
        if (this.searchKeyBrkAcc.length == 0 || this.searchKeyBrkAcc == undefined) {
            console.log('in condition handleSearchKeyChange');
            this.searchKeyBrkAcc = '';
            this.searchKeyBrkCont = '';
            this.searchBrkAccId = '';
            this.searchBrkAccId = '';
            this.showResults = false;
            this.contactInput = true;
            this.searchContactResults = [];
        } 
        else{
            this.searchBrokerAcc();
        }
    }
    handleContSearchKeyChange(event) {
        this.searchKeyBrkCont = event.target.value;
        this.showContactResults = true;
        if (this.searchKeyBrkCont.length == 0 || this.searchKeyBrkCont == undefined) {
            console.log('in condition handleSearchKeyChange');
            this.searchKeyBrkCont = '';
            this.searchBrkContId = '';
            this.showContactResults = false;
        } 
        else{
            this.searchBrokerCont();
        }
    }
    showDialog() {
        this.showResults = true;
        this.searchBrokerAcc();
    }
    showContDialog() {
        this.showContactResults = true;
        this.searchBrokerCont();
    }
    closeDropList() {
        this.showResults = false;
    }
    closeContactDropList() {
        this.showContactResults = false;
    }
    handleResultClick(event) {
        this.searchBrkAccId = event.target.title;
        this.searchKeyBrkAcc = event.target.dataset.id;
        this.showResults = false;
        this.contactInput = false;
    }
    handleContactResultClick(event) {
        this.searchBrkContId = event.target.title;
        this.searchKeyBrkCont = event.target.dataset.id;
        this.showContactResults = false;
    }
    searchBrokerAcc() {
        searchBrokerAccount({
            searchKeyWrd: this.searchKeyBrkAcc
        }).then(result => {
            this.searchResults = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.displaysuccessMessage = false;
            this.displayErrorMessage = true;
            this.errorMessage = error.body.message;
            console.log(error.body.message);
        })
    }
    searchBrokerCont() {
        searchBrokerContact({
            searchKeyWrd: this.searchKeyBrkCont,
            accId : this.searchBrkAccId
        }).then(result => {
            this.searchContactResults = result;
            this.showSpinner = false;
        })
        .catch(error => {
            this.displaysuccessMessage = false;
            this.displayErrorMessage = true;
            this.errorMessage = error.body.message;
            console.log(error.body.message);
        })
    }
    handleSave() {
        this.showSpinner = true; 
        if ((this.lastName && this.lastName.trim() !== '') &&
            (this.email && this.email.trim() !== '') &&
            (this.phone && this.phone.trim() !== '') && 
            (this.description && this.description.trim() !== '') &&
            (this.enqSource && this.enqSource.trim() !== '') &&
            (this.enqType && this.enqType.trim() !== '') && 
            (this.enqType != 'Indirect' || (this.enqType == 'Indirect' && this.searchBrkAccId != '' && this.searchBrkContId != ''))
        ) {
            let phoneNumber = this.phone.replace(this.cntryCode, '');
            phoneNumber = phoneNumber.substr(phoneNumber.length-10);
            console.log(phoneNumber);
            phoneNumber = this.cntryCode.includes('+') ? this.cntryCode.replace('+','')+phoneNumber : this.cntryCode + phoneNumber;
            console.log(phoneNumber);
            const contactData = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Email: this.email,
                Phone: phoneNumber,
                Description: this.description,
                Country_Code__c : this.cntryCode
            };

            const enqData = {
                Prefered_LAnguage__c: this.prefLang,
                Type_Of_Enquiry__c : this.enqType,
                PropStrength__Request_Source__c : this.enqSource,
                PropStrength__Broker_Account__c : this.searchBrkAccId,
                PropStrength__Broker_Contact__c : this.searchBrkContId
            };
            console.log(contactData);
            console.log(enqData);
            createContact({ contactData, enqData })
                .then((result) => {
                    this.displayErrorMessage = false;
                    this.displaysuccessMessage = true;
                    this.successMessage = result;
                    this.clearFields();
                    
                })
                .catch(error => {
                    this.displaysuccessMessage = false;
                    this.displayErrorMessage = true;
                    this.errorMessage = 'Please fill the required field.';
                    console.log(error.body.message);
                })
                .finally(() => {
                    this.showSpinner = false;
                    // Code to save the record
                    // This code will execute regardless of success or error
                });
        } else {
            this.displaysuccessMessage = false;
            this.displayErrorMessage = true;
            this.errorMessage = 'Please fill the required field.';
            this.showSpinner = false;
        }
    }

    clearFields() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.prefLang = '';
        this.enqType = '';
        this.enqSource = '';
        this.description = '';
        this.searchResults = [];
        this.searchContactResults = [];
        this.searchKeyBrkAcc = '';
        this.searchKeyBrkCont = '';
        this.showResults = false;
        this.showContactResults = false;
        this.showBrokerDetails = false;
        this.contactInput = true;
        this.selectedCountry = '';
        this.cntryCode = '';
    }
}