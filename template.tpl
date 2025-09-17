___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Stape Store Margin Lookup",
  "description": "This variable allows you to retrieve margin data from Stape Store for each product in your items array and returns a combined margin value (accounting for quantity).",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "storeKeyId",
    "displayName": "Field containing the Product ID in your Stape Store",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "storeKeyMargin",
    "displayName": "Field containing the Margin Value in your Stape Store",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Use dot notation if needed (e.g. \u003ci\u003efoo.id\u003c/i\u003e, \u003ci\u003ebar.0.price\u003c/i\u003e)."
  },
  {
    "type": "LABEL",
    "name": "arrKeyIdLabel",
    "displayName": "The variable will look for standard \u003ci\u003eitems\u003c/i\u003e array of objects in the Event Data. You only need to select which field you are using as Item ID."
  },
  {
    "type": "RADIO",
    "name": "arrKeyId",
    "displayName": "Select field to be used as the Product ID",
    "radioItems": [
      {
        "value": "item_id",
        "displayValue": "item_id"
      },
      {
        "value": "item_sku",
        "displayValue": "item_sku"
      },
      {
        "value": "item_variant",
        "displayValue": "item_variant"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "item_id"
  },
  {
    "type": "GROUP",
    "name": "moreSettingsGroup",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "storeResponse",
        "checkboxText": "Store the result in cache",
        "simpleValueType": true,
        "help": "Store the response in Template Storage.  \n\u003cbr/\u003e\nIf a request is made with identical parameters, the cached response (if available) will be reused instead of sending a new request.  \n\u003cbr/\u003e\nThis caching applies separately to each unique Product ID."
      },
      {
        "type": "CHECKBOX",
        "name": "roundResult",
        "checkboxText": "Round result value to 2 decimal places",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "stapeStoreSettingsGroup",
    "displayName": "Stape Store Settings",
    "groupStyle": "ZIPPY_OPEN_ON_PARAM",
    "subParams": [
      {
        "type": "TEXT",
        "name": "stapeStoreCollectionName",
        "displayName": "Stape Store Collection Name",
        "simpleValueType": true,
        "help": "The name of the collection on the Stape Store that contains (or will contain) the document with the data.\n\u003cbr/\u003e\u003cbr/\u003e\nIf not set, the \u003ci\u003edefault\u003c/i\u003e Collection Name will be used."
      },
      {
        "type": "SELECT",
        "name": "useDifferentStapeStore",
        "displayName": "Use the Stape Store database of a different container",
        "macrosInSelect": true,
        "selectItems": [
          {
            "value": true,
            "displayValue": "True"
          },
          {
            "value": false,
            "displayValue": "False"
          }
        ],
        "simpleValueType": true,
        "subParams": [
          {
            "type": "TEXT",
            "name": "stapeStoreContainerApiKey",
            "displayName": "Stape Store Container API Key",
            "simpleValueType": true,
            "valueHint": "euk:kzlfoobar:55ec021d429be49e64e691429cf0f27440a1b789kzlfoobar",
            "help": "If you want to interact with the Stape Store of a different container hosted on Stape, specify the \u003cb\u003eContainer API Key\u003c/b\u003e of this container.\n\u003cbr/\u003e\u003cbr/\u003e\nTo find the \u003cb\u003eContainer API Key\u003c/b\u003e, go to the \u003ca href\u003d\"https://app.eu.stape.dev/container\"\u003eStape Admin panel\u003c/a\u003e, select the sGTM container which the Stape Store you want to interact with, go to the \u003ci\u003eSettings\u003c/i\u003e tab and scroll down to the \u003ci\u003eContainer settings\u003c/i\u003e section.",
            "enablingConditions": [
              {
                "paramName": "useDifferentStapeStore",
                "paramValue": false,
                "type": "NOT_EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          }
        ],
        "defaultValue": false
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "logsGroup",
    "displayName": "Logs Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "RADIO",
        "name": "logType",
        "displayName": "",
        "radioItems": [
          {
            "value": "no",
            "displayValue": "Do not log"
          },
          {
            "value": "debug",
            "displayValue": "Log to console during debug and preview"
          },
          {
            "value": "always",
            "displayValue": "Always log to console"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "debug"
      }
    ]
  },
  {
    "displayName": "BigQuery Logs Settings",
    "name": "bigQueryLogsGroup",
    "groupStyle": "ZIPPY_CLOSED",
    "type": "GROUP",
    "subParams": [
      {
        "type": "RADIO",
        "name": "bigQueryLogType",
        "radioItems": [
          {
            "value": "no",
            "displayValue": "Do not log to BigQuery"
          },
          {
            "value": "always",
            "displayValue": "Log to BigQuery"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "no"
      },
      {
        "type": "GROUP",
        "name": "logsBigQueryConfigGroup",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "TEXT",
            "name": "logBigQueryProjectId",
            "displayName": "BigQuery Project ID",
            "simpleValueType": true,
            "help": "Optional.  \u003cbr/\u003e\u003cbr/\u003e  If omitted, it will be retrieved from the environment variable \u003cI\u003eGOOGLE_CLOUD_PROJECT\u003c/i\u003e where the server container is running. If the server container is running on Google Cloud, \u003cI\u003eGOOGLE_CLOUD_PROJECT\u003c/i\u003e will already be set to the Google Cloud project\u0027s ID."
          },
          {
            "type": "TEXT",
            "name": "logBigQueryDatasetId",
            "displayName": "BigQuery Dataset ID",
            "simpleValueType": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          },
          {
            "type": "TEXT",
            "name": "logBigQueryTableId",
            "displayName": "BigQuery Table ID",
            "simpleValueType": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          }
        ],
        "enablingConditions": [
          {
            "paramName": "bigQueryLogType",
            "paramValue": "always",
            "type": "EQUALS"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

/// <reference path="./server-gtm-sandboxed-apis.d.ts" />

const sendHttpRequest = require('sendHttpRequest');
const encodeUriComponent = require('encodeUriComponent');
const JSON = require('JSON');
const templateDataStorage = require('templateDataStorage');
const Promise = require('Promise');
const sha256Sync = require('sha256Sync');
const logToConsole = require('logToConsole');
const getRequestHeader = require('getRequestHeader');
const getContainerVersion = require('getContainerVersion');
const getEventData = require('getEventData');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const Math = require('Math');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const BigQuery = require('BigQuery');

/*==============================================================================
==============================================================================*/

const traceId = getRequestHeader('trace-id');

const items = getEventData('items');
if (getType(items) !== 'array') return undefined;

const responsesForEachItem = lookupInStore(data, items);
return Promise.all(responsesForEachItem).then((results) => {
  let res = 0;

  results.forEach((result, index) => {
    const qt = makeNumber(items[index].quantity) || 1;
    const tmp = makeNumber(mapResponse(data, result));
    if (tmp) res += tmp * qt;
    else res += makeNumber(items[index].price) * qt;
  });

  if (data.roundResult) {
    res = makeNumber(Math.round(res * 100) / 100);
  }

  return res;
});

/*==============================================================================
  Vendor related functions
==============================================================================*/

function getStapeStoreBaseUrl(data) {
  let containerIdentifier;
  let defaultDomain;
  let containerApiKey;
  const collectionPath =
    'collections/' + enc(data.stapeStoreCollectionName || 'default') + '/documents';

  const shouldUseDifferentStore =
    isUIFieldTrue(data.useDifferentStapeStore) &&
    getType(data.stapeStoreContainerApiKey) === 'string';
  if (shouldUseDifferentStore) {
    const containerApiKeyParts = data.stapeStoreContainerApiKey.split(':');

    const containerLocation = containerApiKeyParts[0];
    const containerRegion = containerApiKeyParts[3] || 'io';
    containerIdentifier = containerApiKeyParts[1];
    defaultDomain = containerLocation + '.stape.' + containerRegion;
    containerApiKey = containerApiKeyParts[2];
  } else {
    containerIdentifier = getRequestHeader('x-gtm-identifier');
    defaultDomain = getRequestHeader('x-gtm-default-domain');
    containerApiKey = getRequestHeader('x-gtm-api-key');
  }

  return (
    'https://' +
    enc(containerIdentifier) +
    '.' +
    enc(defaultDomain) +
    '/stape-api/' +
    enc(containerApiKey) +
    '/v2/store/' +
    collectionPath
  );
}

function getOptions() {
  return { method: 'POST', headers: { 'Content-Type': 'application/json' } };
}

function getPostBody(data, itemId) {
  return {
    filter: {
      operator: 'and',
      conditions: [
        {
          field: data.storeKeyId,
          operator: 'equal',
          value: itemId
        }
      ]
    },
    pagination: {
      limit: 1
    }
  };
}

function lookupInStore(data) {
  const url = getStapeStoreBaseUrl(data);
  const options = getOptions();
  const responses = [];
  const arrKeyId = data.arrKeyId ? data.arrKeyId : 'item_id';

  items.forEach((item) => {
    const itemId = item[arrKeyId];

    const postBody = getPostBody(data, itemId);
    const cacheKey = data.storeResponse ? sha256Sync(url + JSON.stringify(postBody)) : '';

    if (data.storeResponse) {
      const cachedValue = templateDataStorage.getItemCopy(cacheKey);
      if (cachedValue) return responses.push(Promise.create((resolve) => resolve(cachedValue)));
    }

    log({
      Name: 'StapeStore',
      Type: 'Request',
      TraceId: traceId,
      EventName: 'StoreRead',
      RequestMethod: options.method,
      RequestUrl: url,
      RequestBody: postBody
    });

    const response = sendHttpRequest(url, options, JSON.stringify(postBody)).then((response) => {
      log({
        Name: 'StapeStore',
        Type: 'Response',
        TraceId: traceId,
        EventName: 'StoreRead',
        ResponseStatusCode: response.statusCode,
        ResponseHeaders: response.headers,
        ResponseBody: response.body
      });

      if (data.storeResponse) templateDataStorage.setItemCopy(cacheKey, response.body);

      return response.body;
    });

    responses.push(response);
  });

  return responses;
}

function mapResponse(data, bodyString) {
  const body = JSON.parse(bodyString || '{}');
  const document =
    getType(body) === 'object' &&
    getType(body.data) === 'object' &&
    getType(body.data.items) === 'array' &&
    getType(body.data.items[0]) === 'object'
      ? body.data.items[0]
      : {};
  const storedData = document.data || {};

  const storeKeyMargin = data.storeKeyMargin;
  if (!storeKeyMargin) return storedData;

  const keys = storeKeyMargin.trim().split('.');
  let value = storedData;
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (!value || !key) break;
    value = value[key];
  }

  return value;
}

/*==============================================================================
  Helpers
==============================================================================*/

function isUIFieldTrue(field) {
  return [true, 'true', 1, '1'].indexOf(field) !== -1;
}

function enc(data) {
  return encodeUriComponent(makeString(data || ''));
}

function log(rawDataToLog) {
  const logDestinationsHandlers = {};
  if (determinateIsLoggingEnabled()) logDestinationsHandlers.console = logConsole;
  if (determinateIsLoggingEnabledForBigQuery()) logDestinationsHandlers.bigQuery = logToBigQuery;

  const keyMappings = {
    // No transformation for Console is needed.
    bigQuery: {
      Name: 'tag_name',
      Type: 'type',
      TraceId: 'trace_id',
      EventName: 'event_name',
      RequestMethod: 'request_method',
      RequestUrl: 'request_url',
      RequestBody: 'request_body',
      ResponseStatusCode: 'response_status_code',
      ResponseHeaders: 'response_headers',
      ResponseBody: 'response_body'
    }
  };

  for (const logDestination in logDestinationsHandlers) {
    const handler = logDestinationsHandlers[logDestination];
    if (!handler) continue;

    const mapping = keyMappings[logDestination];
    const dataToLog = mapping ? {} : rawDataToLog;

    if (mapping) {
      for (const key in rawDataToLog) {
        const mappedKey = mapping[key] || key;
        dataToLog[mappedKey] = rawDataToLog[key];
      }
    }

    handler(dataToLog);
  }
}

function logConsole(dataToLog) {
  logToConsole(JSON.stringify(dataToLog));
}

function logToBigQuery(dataToLog) {
  const connectionInfo = {
    projectId: data.logBigQueryProjectId,
    datasetId: data.logBigQueryDatasetId,
    tableId: data.logBigQueryTableId
  };

  dataToLog.timestamp = getTimestampMillis();

  ['request_body', 'response_headers', 'response_body'].forEach((p) => {
    dataToLog[p] = JSON.stringify(dataToLog[p]);
  });

  BigQuery.insert(connectionInfo, [dataToLog], { ignoreUnknownValues: true });
}

function determinateIsLoggingEnabled() {
  const containerVersion = getContainerVersion();
  const isDebug = !!(
    containerVersion &&
    (containerVersion.debugMode || containerVersion.previewMode)
  );

  if (!data.logType) {
    return isDebug;
  }

  if (data.logType === 'no') {
    return false;
  }

  if (data.logType === 'debug') {
    return isDebug;
  }

  return data.logType === 'always';
}

function determinateIsLoggingEnabledForBigQuery() {
  if (data.bigQueryLogType === 'no') return false;
  return data.bigQueryLogType === 'always';
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "items"
              }
            ]
          }
        },
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "trace-id"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "x-gtm-identifier"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "x-gtm-default-domain"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "x-gtm-api-key"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "all"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_bigquery",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedTables",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "projectId"
                  },
                  {
                    "type": 1,
                    "string": "datasetId"
                  },
                  {
                    "type": 1,
                    "string": "tableId"
                  },
                  {
                    "type": 1,
                    "string": "operation"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 17/09/2024, 11:34:39

