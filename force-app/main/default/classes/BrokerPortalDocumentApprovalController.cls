public with sharing class BrokerPortalDocumentApprovalController {
  @AuraEnabled(cacheable=true)
  public static List<Document_validator__c> getDocumentValidatorData(
    String brId
  ) {
    String query = 'SELECT Id,Name, File_Name__c, File_Type__c,Broker_Registration__r.Name_as_per_trade_license__c, Broker_Registration__c, Broker_Registration__r.Name, Channel_Partner__c, Approval_status__c, BR_doc_history_id__c, CreatedDate FROM Document_validator__c ';

    if (brId != null) {
      query +=
        'WHERE Broker_Registration__c = :brId ' +
        'AND Approval_status__c NOT IN (\'Approved\', \'Rejected\') ';
    } else {
      query += 'WHERE Approval_status__c NOT IN (\'Approved\', \'Rejected\') ';
    }

    query += 'ORDER BY CreatedDate DESC';

    return Database.query(query);
  }

  @AuraEnabled
  public static string getViewLink(Id relatedId) {
    String url;
    ContentDistribution conDistribution = [
      SELECT
        Id,
        DistributionPublicUrl,
        ContentVersion.FileType,
        ContentDownloadUrl,
        RelatedRecord.Name
      FROM ContentDistribution
      WHERE RelatedRecordId = :relatedId
      ORDER BY createddate DESC
    ];
    if (conDistribution != null)
      url = conDistribution.DistributionPublicUrl;
    else {
      url = '';
    }
    return url;
  }
  public class RecordApprovalData {
    @AuraEnabled
    public String recordId { get; set; }
    @AuraEnabled
    public String comment { get; set; }
    @AuraEnabled
    public String action { get; set; }
  }

  @AuraEnabled
  public static String processApproveClick(
    List<RecordApprovalData> recordsObject
  ) {
    // Collect Ids of records to be updated
    Set<Id> recordIds = new Set<Id>();
    string globalAction;
    for (RecordApprovalData recordData : recordsObject) {
      recordIds.add(recordData.recordId);
    }

    // Query records to be updated
    List<Document_validator__c> dvList = [
      SELECT Id, Approval_status__c, Comments__c
      FROM Document_validator__c
      WHERE Id IN :recordIds
    ];

    // Update each record's Approval_status__c and Comment__c fields
    for (Document_validator__c dv : dvList) {
      for (RecordApprovalData recordData : recordsObject) {
        if (dv.Id == recordData.recordId) {
          dv.Approval_status__c = recordData.action;
          dv.Comments__c = recordData.comment; // Assuming Comment__c is the field for comments
          globalAction = recordData.action;
          break;
        }
      }
    }

    // Perform the update
    try {
      update dvList;
      if (globalAction == 'Rejected') {
        rejectionEmailSend(recordsObject);
      }
    } catch (Exception ex) {
      System.debug('Exception is ' + ex);
    }
    update dvList;

    return 'Records updated successfully' + JSON.serialize(recordsObject);
  }
  // @AuraEnabled
  // public static string processRejectClick(Id relatedId) {
  // }
  @AuraEnabled
  public static void rejectionEmailSend(
    List<RecordApprovalData> recordsObject
  ) {
    // Collect broker and document details from recordsObject
    Set<Id> recordIds = new Set<Id>();
    for (RecordApprovalData recordData : recordsObject) {
      recordIds.add(recordData.recordId);
    }

    // Query the relevant data (assuming Comments__c contains the rejection reason)
    List<Document_validator__c> dvList = [
      SELECT
        Id,
        File_Name__c,
        File_Type__c,
        Broker_Registration__r.Name,
        Broker_Registration__r.Name_as_per_trade_license__c,
        Broker_Registration__r.Email__c,
        Broker_Registration__r.CHRM_Manager_Email__c,
        Broker_Registration__r.crmOps__r.Email,
        Comments__c
      FROM Document_validator__c
      WHERE Id IN :recordIds
    ];

    if (dvList.isEmpty()) {
      return; // No records to process
    }

    // Build email body for each broker
    Map<String, List<Document_validator__c>> brokerDocumentsMap = new Map<String, List<Document_validator__c>>();

    // Group documents by broker name
    for (Document_validator__c dv : dvList) {
      String brokerName = dv.Broker_Registration__r.Name_as_per_trade_license__c;
      if (!brokerDocumentsMap.containsKey(brokerName)) {
        brokerDocumentsMap.put(brokerName, new List<Document_validator__c>());
      }
      brokerDocumentsMap.get(brokerName).add(dv);
    }

    // Loop through each broker to build and send the email
    for (String brokerName : brokerDocumentsMap.keySet()) {
      List<Document_validator__c> documents = brokerDocumentsMap.get(
        brokerName
      );
      String brokerEmail = documents[0].Broker_Registration__r.Email__c;

      // Build the email body in HTML format
      String emailBody = '<html><body>';
      emailBody += '<p>Dear ' + brokerName + ',</p>';
      emailBody += '<p>I hope this email finds you well.</p>';
      emailBody += '<p>The following document(s) uploaded by you need to be resubmitted through the Portal due to the following reasons for rejection:</p>';

      // Create a list of documents and rejection reasons
      emailBody += '<ul>';
      for (Document_validator__c dv : documents) {
        emailBody +=
          '<li><strong>' +
          dv.File_Type__c +
          ': </strong> ' +
          dv.Comments__c +
          '</li>';
      }
      emailBody += '</ul>';

      emailBody += '<p>Please do not hesitate to contact your Channel Relation Manager regarding any questions you may have.</p>';
      emailBody += '<p>Thank you for your cooperation.</p>';
      emailBody += '<p>Best regards,<br/>Channel Operations<br/>Sobha Realty</p>';
      emailBody += '</body></html>';

      // Set up and send the email
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(new List<String>{ brokerEmail });
      email.setSubject('Document Rejection Notice - Sobha Realty');
      email.setHtmlBody(emailBody);

      // Send the email
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }
  }
}