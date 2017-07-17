DBQuery.shellBatchSize=200

function printRes(cursor) {
  while (cursor.hasNext()) {
    printjson(cursor.next());
  }
}

DB.prototype.yubo_findAll = function(id, showAll) {
  showAll = !!showAll;
  var proj = showAll ? {} : {
    topicId: 1,
    borrowers: 1,
    milestoneId: 1,
    postSubmission: 1,
    followUpOnly: 1,
    processId: 1,
    loanId: 1,
    requestId: 1,
    requirement: 1,
    requirementConfigs: 1,
    applicationTemplateId: 1,
    type: 1,
    userId: 1,
    email: 1,
    name: 1
  };
  var findQuery = {
    $or: [
      { _id: id },
      { topicId: id },
      { loanId: id }
    ]
  };
  var colls = ['applications', 'loanApplicationTemplates', 'loanProcesses', 'loanRequests', 'parties'];
  colls.forEach(function(collname) {
    print('------------------------------');
    print(collname);
    printRes(db[collname].find(findQuery, proj));
  });
  print();
};

DB.prototype.yubo_findActivities = function(loanId) {
  return db.activities.find(
    { 'target._id': loanId },
    {
      actor: 1,
      verb: 1,
      'object.task.processId': 1,
      'object.process._id': 1,
      'object.followUp.text': 1,
      'object.followUp.type': 1,
      'object.templateId': 1,
      'object.task.templateId': 1,
      'object.milestone._id': 1,
      published: 1
    }
  ).sort({ published: -1 });
};

DB.prototype.yubo_printFU = function(FUId) {
  var FU = db.followUps.findOne({ _id: FUId }) || db.followUpsArchive.findOne({ _id: FUId });
  var documentId = FU.document.attachmentId;
  var LPs = db.loanProcesses.find({
    topicId : FU.loanId,
    processId: "Docusign Follow-Up_0",
    'context.followUp._id': FU._id,
  }, { 'context.uid': 1 }).toArray();
  var contextUids = LPs.map(function(lp) { return lp.context.uid });

  print('FUs');
  print('------------------------------');
  printRes(db.followUps.find({ _id: FUId }, { 'document.attachmentId': 1, context: 1, text: 1, loanId: 1, createdAt: 1 }));
  print('FUs Archive');
  printRes(db.followUpsArchive.find({ _id: FUId }, { 'document.attachmentId': 1, context: 1, text: 1, loanId: 1, createdAt: 1, _mqDeletedAt: 1 }));

  print('LPs');
  print('------------------------------');
  printjson(LPs);

  print('LRs');
  print('------------------------------');
  printRes(db.loanRequests.find(
    { 'context.uid': { $in: contextUids } },
    { created: 1, _meta: 1, contextUid: 1 }
  ).sort({ created: 1 }));

  print('Tasks');
  print('------------------------------');
  printRes(db.tasks.find({
    topicId : FU.loanId,
    processId: "Docusign Follow-Up_0",
    contextUid: { $in: contextUids }
  }, { created: 1, _meta: 1, contextUid: 1 }).sort({ created: 1 }));

  print('Docs');
  print('------------------------------');
  printjson(db.documents.findOne({ _id: documentId }, { status: 1, _meta: 1 }));

  print('Signatures');
  print('------------------------------');
  printRes(db.signatures.find({
    documentId: documentId
  }, { status: 1, _meta: 1 }));
}

function yubo_dropTests() {
  db.getMongo().getDBNames().forEach(function(i) {
    if (/testdb/.test(i)) {
      print(`dropping database ${i}`);
      db.getSiblingDB(i).dropDatabase();
    } else {
      print(`not dropping database ${i}`);
    }
  });
}

function yubo_dropAll() {
  db.getMongo().getDBNames().forEach(function(i) {
    print(`dropping database ${i}`);
    db.getSiblingDB(i).dropDatabase();
  });
  print("Dropped all DBs");
}

function yubo_clear() {
  db.user.remove({ appRole: "borrower" });

  dbsToClear = ["tasks", 'topics', "applications", "parties", "userEvents", "partyPermissions", "loanProcesses", "activities", "files", "documents", "loanRequests", "followUps", "loanApplicationTemplates", "entityHistory", "errors"];
  dbsToClear.forEach(function(name) {
    print(`clearing collection ${name}`);
    db.getCollection(name).remove({});
  });
  db.getCollectionNames().forEach(function(name) {
    if (/Archive/.test(name)) {
      print(`clearing collection ${name}`);
      db.getCollection(name).remove({});
    }
  });
  db.applicationTemplates.remove({ isDefault: false });
  print("Cleared!");
}

function yubo_simpleApp() {
  db.applicationTemplates.update(
    { isDefault: true },
    {
      $set: {
        name : "short",
        requirementConfigs : [
          {
            ruleConfig : { },
            requestId : "Getting To Know You",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Assets",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Income",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Real Estate Owned",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Declarations",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Additional Questions",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Review Application",
            milestoneId : "Review Application"
          },
          {
            ruleConfig : { },
            requestId : "Submit Application",
            milestoneId : "Submit Application"
          }
        ],
        archived : false,
        lastUpdated : Date.now(),
        hidden: false
      }
    }
  );
  print("Simple app put in");
}

function yubo_cheatingApp() {
  db.applicationTemplates.update(
    { isDefault: true },
    {
      $set: {
        name : "cheating",
        requirementConfigs : [
          {
            ruleConfig : { },
            requestId : "Getting To Know You",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Assets",
            milestoneId : "Full Application"
          },
          {
            ruleConfig : { },
            requestId : "Review Application",
            milestoneId : "Review Application"
          },
          {
            ruleConfig : { },
            requestId : "Submit Application",
            milestoneId : "Submit Application"
          },
          {
            ruleConfig : { },
            requestId : "Tax Transcripts",
            milestoneId : "Post-Submission"
          }
        ],
        archived : false,
        lastUpdated : Date.now(),
        hidden: false
      }
    }
  );
  print("Ridiculously simple app put in");
}

function yubo_followUpApp() {
  db.requests.remove({});
  var insertRequests = [
    {
      _id : "b1c6cb3e-dac9-4a57-a026-6e28156360e4",
      type : "Document Request",
      document : {
        typeInfo : {
          type : "OTHER",
          text : "ESign Joint",
          category : "Income",
          entity : "Party"
        },
        eSignTemplate : {
          "templateId" : "b8e9bbc2-8582-46c7-a003-e1adbcad50ee",
          "name" : "Business License - follow-up template docusign template"
        },
      },
      expanded : true,
      comments : "joint",
      context : [ { "borrowerType" : "BORROWER" }, { "borrowerType" : "COBORROWER" } ],
      name : "ESign Joint",
      processId : "Other Document Follow-Up_0",
      dependentRequestIds : [ ],
      exclusiveRequestIds : [ ],
      validMilestoneIds : [
          "Documents",
          "Post-Submission"
      ]
    }, {
      _id : "2df606b6-41ca-4161-82ff-aa2e72df6015",
      type : "Document Request",
      document : {
        typeInfo : {
          type : "OTHER",
          text : "ESign",
          category : "Income",
          entity : "Party"
        },
        eSignTemplate : {
          templateId : "fd8cd4bd-f77d-42bb-89c4-550409c249ab",
          name : "ESign - follow-up template docusign template"
        },
      },
      expanded : true,
      comments : "two-borrower doc, cob sign only",
      context : [ { "borrowerType" : "BORROWER" }, { "borrowerType" : "COBORROWER" } ],
      name : "ESign two-borrower doc, cob sign only",
      processId : "Other Document Follow-Up_0",
      dependentRequestIds : [ ],
      exclusiveRequestIds : [ ],
      validMilestoneIds : [
          "Documents",
          "Post-Submission"
      ]
    }, {
      _id : "573a84d9-72b1-4bc4-b096-d883c5182f71",
      type : "Document Request",
      document : {
        typeInfo : {
          type : "MORTGAGE_STATEMENT",
          category : "Property",
          text : "Mortgage Statement",
          entity : "Property"
        }
      },
      expanded : true,
      comments : "foo",
      context : [ { "borrowerType" : "BORROWER" }, { "borrowerType" : "COBORROWER" } ],
      name : "TwoBorrower",
      processId : "Other Document Follow-Up_0",
      dependentRequestIds : [ ],
      exclusiveRequestIds : [ ],
      validMilestoneIds : [
        "Documents",
        "Post-Submission"
      ]
    }, {
      _id : "41ea9fe6-a760-482f-a2fe-3fbd06249d6e",
      type : "Document Request",
      name : "OneBorrower",
      processId : "Other Document Follow-Up_0",
      document : {
        typeInfo : {
          type : "OTHER",
          text : "Settlement Agent or Title Company Information",
          category : "Miscellaneous",
          entity : "Party"
        }
      },
      expanded : true,
      validMilestoneIds : [
        "Documents",
        "Post-Submission"
      ],
      comments : "baz",
      dependentRequestIds : [ ],
      exclusiveRequestIds : [ ],
      context : [ { "borrowerType" : "BORROWER" } ]
    }
  ];
  db.requests.insert(insertRequests);
  yubo_cheatingApp();
  insertRequests.forEach(request => {
    db.applicationTemplates.update({ isDefault: true }, {
      $push: {
        requirementConfigs : {
          ruleConfig : { },
          requestId : request._id,
          milestoneId : "Documents"
        },
      }
    });
  });
  print(`${insertRequests.length} followups added to app template`);
}

function yubo_enableFF() {
  db.featureFlags.update({
    _id: {
      $nin: [
        'sesEnabled',
        'skipEmptyFirstTasks20170117',
        'pullAssetsWithSSOOAuthToken',
        'reactTaskForm05172017',
        'multipleAccountsTaxTranscriptsWorkflow20170613',
      ]
    }
  }, { $set: { enabled: true } }, { multi: true });
  print ("Most FFs enabled");
}

function yubo_disableFF() {
  db.featureFlags.update({}, { $set: { enabled: false } }, { multi: true });
  print ("All FFs disabled!");
}

function yubo_countAll() {
  collections=db.getCollectionNames()
  for(i = 0; i < collections.length; i++) {
    print(collections[i]); print(db.getCollection(collections[i]).count());
  }
}

function yubo_enableDocusign() {
  db.providerInfo.remove({});
  db.providerInfo.insert({
    name : "DOCUSIGN",
    username : "yubo@blendlabs.com",
    enabled : true,
    encryptedPassword : DOCUSIGN_PW,
    encryptedAt : ISODate().getTime()
  });
  db.configs.update({}, { $set: { enable1003sign: false } });
  print("Docusign Enabled");
}

function yubo_init() {
  yubo_clear();
  yubo_simpleApp();
  yubo_enableFF();
  yubo_enableDocusign();
}

function yubo_rmEmail() {
  db.user.remove({ email: { $regex: /yubo.*blendlabs.com/ } });
  print("Emails removed");
}

function resetSuper() {
  db.user.update(
    { email: 'e2esuper@blendlabs.com' },
    { $set: {
      passwordLastChanged: ISODate().getTime(),
      lastLogin: ISODate().getTime()
    } }
  );
  print("super reset");
}
