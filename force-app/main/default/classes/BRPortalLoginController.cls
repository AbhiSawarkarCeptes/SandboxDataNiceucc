global with sharing class BRPortalLoginController {
    global String username {get; set;}
    global String password {get; set;}
    public String orgId {get; set;}
    public String siteURL  {get; set;}
    public String startURL {get; set;}
    public List<AuthProvider> authProviders {get; set;}
    public String usernameForgot {get; set;}
    public String msg {get; set;}
    global BRPortalLoginController() {
        msg = '';
        orgId = UserInfo.getOrganizationId();
        siteURL = Site.getBaseUrl();
        startURL = System.currentPageReference().getParameters().get('startURL') != null ? System.currentPageReference().getParameters().get('startURL') : '/';
        System.debug('===> startURL' + startURL);
        authProviders = [SELECT Id, DeveloperName, FriendlyName, ProviderType FROM AuthProvider ];
    }
    global PageReference login() {
        msg = '';
        System.PageReference pref;
        if(String.isBlank(username) || String.isBlank(password)) {
            msg = 'Please enter the required fields.';
            return null;
        }
        System.debug('===> startURL' + startURL);
        if(!String.isBlank(username) && !String.isBlank(password)) {
            System.debug('===> Call here');
            pref = Site.login(username, password, startUrl);
            //pref = Site.login(username, password, '/newBrokerPortal/s/');
        }
        if(pref == null) {
            msg = 'Please check your email address and password.If you still can\'t log in, contact your Salesforce administrator.';
        }
        return pref;
    }
    public PageReference forgotPassword() {
        msg = '';
        try {
            if(String.isBlank(usernameForgot)) {
                msg = 'Please enter the required field.';
                return null;
            }
            Site.forgotPassword(usernameForgot);
        } catch(Exception exe) {
            msg = exe.getMessage();
        }
        return null;
    }
    global String getEncodedSiteUrl() {
        return EncodingUtil.urlEncode(siteURL, 'UTF-8');
    }
    global String getEncodedStartUrl() {
        return EncodingUtil.urlEncode(startURL, 'UTF-8');
    }
}