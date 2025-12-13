___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Stape Store Margin Lookup",
  "categories": [
    "UTILITY",
    "DATA_WAREHOUSING"
  ],
  "description": "This variable allows you to retrieve margin data from the Stape Product Feed for each product in your items array and returns a combined margin value (accounting for quantity).",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "itemsSource",
    "displayName": "Items Array Source",
    "radioItems": [
      {
        "value": "ga4",
        "displayValue": "GA4 items array from Event Data",
        "help": "The variable will look for standard GA4 \u003ci\u003eitems\u003c/i\u003e array of objects in the Event Data.",
        "subParams": [
          {
            "type": "RADIO",
            "name": "ga4ItemIdKey",
            "displayName": "Field to be used as the Item ID",
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
            "defaultValue": "item_id",
            "help": "The Item ID value will be used to search for the Item margin data in the Stape Product Feed."
          }
        ]
      },
      {
        "value": "custom",
        "displayValue": "Custom items array",
        "subParams": [
          {
            "type": "SELECT",
            "name": "customItems",
            "displayName": "Custom Items Array",
            "macrosInSelect": true,
            "selectItems": [],
            "simpleValueType": true,
            "notSetText": "(not set)",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          },
          {
            "type": "TEXT",
            "name": "customItemIdKey",
            "displayName": "Item ID Key Name",
            "simpleValueType": true,
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ],
            "help": "The Item ID value will be used to search for the Item margin data in the Stape Product Feed.",
            "valueHint": "id"
          },
          {
            "type": "TEXT",
            "name": "customItemPriceKey",
            "displayName": "Item Price Key Name",
            "simpleValueType": true,
            "valueHint": "price"
          },
          {
            "type": "TEXT",
            "name": "customItemQuantityKey",
            "displayName": "Item Quantity Key Name",
            "simpleValueType": true,
            "valueHint": "qtd",
            "help": "If quantity is not found, it will consider as 1."
          }
        ],
        "help": "Use this option if you items array doesn\u0027t follow the GA4 \u003ci\u003eitems\u003c/i\u003e array format."
      }
    ],
    "simpleValueType": true,
    "defaultValue": "ga4"
  },
  {
    "type": "GROUP",
    "name": "moreSettingsGroup",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "useItemPriceAsFallback",
        "checkboxText": "Use Item Price as fallback if the Item Margin is not found in the Stape Product Feed",
        "simpleValueType": true,
        "help": "If enabled, the variable will use the Item Price as the Item Margin if the Margin is not found for the particular Item. Otherwise, it will consider the Item Margin as 0 (zero)."
      },
      {
        "type": "CHECKBOX",
        "name": "useCache",
        "checkboxText": "Store the each Item Margin in cache",
        "simpleValueType": true,
        "help": "Store the response in Template Storage.  \n\u003cbr/\u003e\nIf a request is made with identical parameters, the cached response (if available) will be reused instead of sending a new request.  \n\u003cbr/\u003e\nThis caching applies separately to each unique Item ID.",
        "subParams": [
          {
            "type": "TEXT",
            "name": "cacheExpirationTime",
            "displayName": "Cache Expiration Time",
            "simpleValueType": true,
            "defaultValue": 180,
            "enablingConditions": [
              {
                "paramName": "useCache",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "help": "Defines how long Item Margin data stays in cache before being retrieved again from the Product Feed..",
            "valueValidators": [
              {
                "type": "POSITIVE_NUMBER"
              }
            ],
            "valueUnit": "minutes"
          }
        ]
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
    "name": "stapeProductFeedSettingsGroup",
    "displayName": "Stape Product Feed Settings",
    "groupStyle": "ZIPPY_OPEN_ON_PARAM",
    "subParams": [
      {
        "type": "SELECT",
        "name": "useDifferentStapeProductFeed",
        "displayName": "Use the Stape Product Feed database of a different container",
        "macrosInSelect": true,
        "selectItems": [
          {
            "value": true,
            "displayValue": "true"
          },
          {
            "value": false,
            "displayValue": "false"
          }
        ],
        "simpleValueType": true,
        "subParams": [
          {
            "type": "TEXT",
            "name": "stapeProductFeedContainerApiKey",
            "displayName": "Stape Container API Key",
            "simpleValueType": true,
            "valueHint": "euk:kzlfoobar:55ec021d429be49e64e691429cf0f27440a1b789kzlfoobar",
            "help": "If you want to interact with the Stape Product Feed of a different container hosted on Stape, specify the \u003cb\u003eContainer API Key\u003c/b\u003e of this container.\n\u003cbr/\u003e\u003cbr/\u003e\nTo find the \u003cb\u003eContainer API Key\u003c/b\u003e, go to the \u003ca href\u003d\"https://app.eu.stape.dev/container\"\u003eStape Admin panel\u003c/a\u003e, select the sGTM container which contains the Stape Product Feed you want to interact with, go to the \u003ci\u003eSettings\u003c/i\u003e tab and scroll down to the \u003ci\u003eContainer settings\u003c/i\u003e section.",
            "enablingConditions": [
              {
                "paramName": "useDifferentStapeProductFeed",
                "paramValue": false,
                "type": "NOT_EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "REGEX",
                "args": [
                  "^[^:]+:[^:]+:[^:]+(:[^:]+)?$"
                ]
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
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const Math = require('Math');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const BigQuery = require('BigQuery');

/*==============================================================================
==============================================================================*/

const items = data.itemsSource === 'ga4' ? getEventData('items') : data.customItems;
if (getType(items) !== 'array') return;

const itemsProfitRequests = getProfitforItems(data, items);
const profit = Promise.all(itemsProfitRequests)
  .then((itemsWithProfitInfo) => calculateProfit(itemsWithProfitInfo))
  .catch((result) => {
    log({
      Name: 'StapeProductFeed',
      Type: 'Message',
      EventName: 'ReadItemProfit',
      Message: 'Something went wrong.',
      Reason: JSON.stringify(result)
    });
    return;
  });

return profit;

/*==============================================================================
  Vendor related functions
==============================================================================*/

function getStapeProductFeedItemUrl(baseUrl, itemId) {
  return baseUrl + '/products/' + enc(itemId);
}

function getStapeProductFeedBaseUrl(data) {
  let containerIdentifier;
  let defaultDomain;
  let containerApiKey;
  const feedPath = '/feeds/default';

  const shouldUseDifferentStore =
    isUIFieldTrue(data.useDifferentStapeProductFeed) &&
    getType(data.stapeProductFeedContainerApiKey) === 'string';
  if (shouldUseDifferentStore) {
    const containerApiKeyParts = data.stapeProductFeedContainerApiKey.split(':');
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
    '/v2/poas' +
    feedPath
  );
}

function getRequestOptions() {
  return { method: 'GET' };
}

function getProfitforItems(data, items) {
  const useCache = data.useCache;
  const requestBaseUrl = getStapeProductFeedBaseUrl(data);
  const requestOptions = getRequestOptions();
  const itemIdKey = data.itemsSource === 'ga4' ? data.ga4ItemIdKey : data.customItemIdKey;
  const itemPriceKey = data.itemsSource === 'custom' ? data.customItemPriceKey : 'price';
  const itemQuantityKey = data.itemsSource === 'custom' ? data.customItemQuantityKey : 'quantity';

  const responsePromises = items.map((item) => {
    const itemId = item[itemIdKey];
    const baseItem = {
      price: makeNumber(item[itemPriceKey]) || undefined,
      quantity: makeInteger(item[itemQuantityKey]) || 1
    };

    const requestUrl = getStapeProductFeedItemUrl(requestBaseUrl, itemId);

    const cacheKey = useCache ? sha256Sync(requestUrl) : undefined;
    if (useCache) {
      const cachedValue = templateDataStorage.getItemCopy(cacheKey);
      if (cachedValue) {
        const cachedItemProfitInfo = cachedValue.profitInfo;
        const cachedItemExpiresAt = cachedValue.expiresAt;
        if (getTimestampMillis() < cachedItemExpiresAt) {
          return Promise.create((resolve) => resolve(mergeObj(baseItem, cachedItemProfitInfo)));
        }
      }
    }

    log({
      Name: 'StapeProductFeed',
      Type: 'Request',
      EventName: 'ReadItemProfit',
      RequestMethod: requestOptions.method,
      RequestUrl: requestUrl
    });

    return sendHttpRequest(requestUrl, requestOptions)
      .then((result) => {
        log({
          Name: 'StapeProductFeed',
          Type: 'result',
          EventName: 'ReadItemProfit',
          ResponseStatusCode: result.statusCode,
          ResponseHeaders: result.headers,
          ResponseBody: result.body
        });

        const parsedBody = JSON.parse(result.body || '{}');

        if (result.statusCode === 200 && parsedBody.success) {
          const profitInfo = {
            profit: makeNumber(parsedBody.data.value),
            profitType: parsedBody.data.value_type
          };

          if (useCache) {
            templateDataStorage.setItemCopy(cacheKey, {
              profitInfo: profitInfo,
              expiresAt: getTimestampMillis() + makeInteger(data.cacheExpirationTime) * 60 * 1000
            });
          }

          return mergeObj(baseItem, profitInfo);
        }
        return baseItem;
      })
      .catch((result) => {
        log({
          Name: 'StapeProductFeed',
          Type: 'Message',
          EventName: 'ReadItemProfit',
          Message: 'Request failed or timed out.',
          Reason: JSON.stringify(result)
        });
        return baseItem;
      });
  });

  return responsePromises;
}

function calculateProfit(itemsWithProfitInfo) {
  const profit = itemsWithProfitInfo.reduce((acc, item) => {
    if (getType(item.profit) === 'number') {
      if (item.profitType === 'absolute') {
        return acc + item.profit * item.quantity;
      } else if (item.profitType === 'percent' && getType(item.price) === 'number') {
        return acc + item.price * (item.profit / 100) * item.quantity;
      }
    } else if (data.useItemPriceAsFallback && getType(item.price) === 'number') {
      return acc + item.price * item.quantity;
    }
    return acc;
  }, 0.0);

  if (data.roundResult) return makeNumber(Math.round(profit * 100) / 100);
  return profit;
}

/*==============================================================================
  Helpers
==============================================================================*/

function isUIFieldTrue(field) {
  return [true, 'true', 1, '1'].indexOf(field) !== -1;
}

function enc(data) {
  if (['null', 'undefined'].indexOf(getType(data)) !== -1) data = '';
  return encodeUriComponent(makeString(data));
}

function mergeObj(target, source) {
  for (const key in source) {
    if (source.hasOwnProperty(key)) target[key] = source[key];
  }
  return target;
}

function log(rawDataToLog) {
  const logDestinationsHandlers = {};
  if (determinateIsLoggingEnabled()) logDestinationsHandlers.console = logConsole;
  if (determinateIsLoggingEnabledForBigQuery()) logDestinationsHandlers.bigQuery = logToBigQuery;

  rawDataToLog.TraceId = getRequestHeader('trace-id');

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

scenarios:
- name: Return undefined if no items array was found
  code: "[\n  {\n    itemsSource: 'ga4'\n  },\n  {\n    itemsSource: 'custom',\n \
    \   testMockData: { customItems: undefined }\n  }\n].forEach((scenario) => {\n\
    \  const copyMockData = setAllMockData(scenario.itemsSource, scenario.testMockData);\n\
    \  \n  let templateDataStorageGetItemCopyWasCalled = false;\n  let templateDataStorageSetItemCopyWasCalled\
    \ = false;\n  mockObject('templateDataStorage', {\n    getItemCopy: (key) => {\
    \ \n      templateDataStorageGetItemCopyWasCalled = true;\n    },\n    setItemCopy:\
    \ (key, value) => {\n      templateDataStorageSetItemCopyWasCalled = true;\n \
    \   }\n  });\n  \n  const variableResult = runCode(copyMockData);\n  \n  assertThat(templateDataStorageGetItemCopyWasCalled,\
    \ 'Should not call templateDataStorage.getItemCopy.').isFalse();\n  assertThat(templateDataStorageSetItemCopyWasCalled,\
    \ 'Should not call templateDataStorage.setItemCopy.').isFalse();\n  assertApi('sendHttpRequest').wasNotCalled();\n\
    \  assertThat(variableResult).isUndefined();\n});"
- name: '[Different Stape Product Feed] Request URL must be built using the provided
    Stape Container API Key'
  code: |-
    const copyMockData = setAllMockData('ga4', {
      useDifferentStapeProductFeed: true,
      stapeProductFeedContainerApiKey: 'abc:foobar:123123123abcfoobar:abc'
    });

    setGetEventData();

    const EXPECTED_REQUEST_BASE_URL_DIFFERENT_STAPE_PRODUCT_FEED = 'https://foobar.abc.stape.abc/stape-api/123123123abcfoobar/v2/poas/feeds/default/products/';
    const itemsProfitRequestUrls = GA4ITEMS.map(item => {
      return EXPECTED_REQUEST_BASE_URL_DIFFERENT_STAPE_PRODUCT_FEED + item[copyMockData.ga4ItemIdKey];
    });

    let sendHttpRequestExecutions = 0;
    mock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {
      assertThat(requestUrl).isEqualTo(itemsProfitRequestUrls[sendHttpRequestExecutions]);
      assertThat(requestOptions).isEqualTo({
        method: 'GET'
      });
      assertThat(requestBody).isUndefined();
      sendHttpRequestExecutions++;
      return Promise.create((resolve, reject) => {
        resolve({ statusCode: 200 });
      });
    });

    runCode(copyMockData);

    callLater(() => assertThat(sendHttpRequestExecutions).isEqualTo(itemsProfitRequestUrls.length));
- name: '[Request] Items Profit Product Feed Requests are built and sent successfully'
  code: "[\n  {\n    itemsSource: 'ga4',\n    testMock: () => { setGetEventData();\
    \ }\n  },\n  {\n    itemsSource: 'custom',\n  }\n].forEach((scenario) => {\n \
    \ \n  const copyMockData = setAllMockData(scenario.itemsSource, scenario.testMockData);\n\
    \  if (scenario.testMock) scenario.testMock();\n    \n  const isSourceGA4 = scenario.itemsSource\
    \ === 'ga4';\n  const itemsProfitRequestUrls = (isSourceGA4 ? GA4ITEMS : CUSTOMITEMS).map(item\
    \ => {\n    return EXPECTED_REQUEST_BASE_URL + item[isSourceGA4 ? copyMockData.ga4ItemIdKey\
    \ : copyMockData.customItemIdKey];\n  });\n  let sendHttpRequestExecutions = 0;\n\
    \  mock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {\n  \
    \  assertThat(requestUrl).isEqualTo(itemsProfitRequestUrls[sendHttpRequestExecutions]);\n\
    \    assertThat(requestOptions).isEqualTo({\n      method: 'GET'\n    });\n  \
    \  assertThat(requestBody).isUndefined();\n    sendHttpRequestExecutions++;\n\
    \    return Promise.create((resolve, reject) => {\n      resolve({ statusCode:\
    \ 200 });\n    });\n  });\n  \n  runCode(copyMockData);\n  \n  callLater(() =>\
    \ assertThat(sendHttpRequestExecutions).isEqualTo(itemsProfitRequestUrls.length));\n\
    });\n"
- name: '[Cache disabled] Cache is not being used, requests must always be made and
    cache must not be interacted with'
  code: "const copyMockData = setAllMockData('ga4', {\n  useCache: false\n});\nsetGetEventData();\n\
    \nlet templateDataStorageGetItemCopyWasCalled = false;\nlet templateDataStorageSetItemCopyWasCalled\
    \ = false;\nmockObject('templateDataStorage', {\n  getItemCopy: (key) => { \n\
    \    templateDataStorageGetItemCopyWasCalled = true;\n  },\n  setItemCopy: (key,\
    \ value) => {\n    templateDataStorageSetItemCopyWasCalled = true;\n  }\n});\n\
    \nrunCode(copyMockData);\n\ncallLater(() => {\n  assertThat(templateDataStorageGetItemCopyWasCalled,\
    \ 'Should not call templateDataStorage.getItemCopy.').isFalse();\n  assertThat(templateDataStorageSetItemCopyWasCalled,\
    \ 'Should not call templateDataStorage.setItemCopy.').isFalse();\n  assertApi('sendHttpRequest').wasCalled();\n\
    });"
- name: '[Cache enabled] Item Data in does not exist in cache, request must be made
    and cache must be updated'
  code: "const copyMockData = setAllMockData('ga4', {\n  useCache: true,\n  cacheExpirationTime:\
    \ EXPECTED_CACHE_EXPIRATION_TIME_IN_SECONDS + ''\n});\nsetGetEventData([GA4ITEMS[0]]);\n\
    \nlet templateDataStorageGetItemCopyWasCalled = false;\nlet templateDataStorageSetItemCopyWasCalled\
    \ = false;\nmockObject('templateDataStorage', {\n  getItemCopy: (key) => {\n \
    \   templateDataStorageGetItemCopyWasCalled = true;\n    callLater(() => {\n \
    \     assertThat(key).isEqualTo(EXPECTED_CACHE_KEY);\n    });\n    return;\n \
    \ },\n  setItemCopy: (key, value) => {\n    templateDataStorageSetItemCopyWasCalled\
    \ = true;\n    callLater(() => {\n      assertThat(key).isEqualTo(EXPECTED_CACHE_KEY);\n\
    \      assertThat(value).isEqualTo(EXPECTED_CACHE_OBJ);\n    });\n  }\n});\n\n\
    mock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {\n  return\
    \ Promise.create((resolve) => {\n    resolve({ \n      statusCode: 200, \n   \
    \   body: JSON.stringify(EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT)\n \
    \   });\n  });\n});\n\nrunCode(copyMockData);\n\ncallLater(() => {\n  assertThat(templateDataStorageGetItemCopyWasCalled,\
    \ 'Should call templateDataStorage.getItemCopy.').isTrue();\n  assertThat(templateDataStorageSetItemCopyWasCalled,\
    \ 'Should call templateDataStorage.setItemCopy.').isTrue();\n  assertApi('sendHttpRequest').wasCalled();\n\
    });"
- name: '[Cache enabled] Item Data exists in cache but is expired, request must be
    made and cache must be updated'
  code: "const copyMockData = setAllMockData('ga4', {\n  useCache: true,\n  cacheExpirationTime:\
    \ EXPECTED_CACHE_EXPIRATION_TIME_IN_SECONDS + ''\n});\nsetGetEventData([GA4ITEMS[0]]);\n\
    \nlet templateDataStorageGetItemCopyWasCalled = false;\nlet templateDataStorageSetItemCopyWasCalled\
    \ = false;\nmockObject('templateDataStorage', {\n  getItemCopy: (key) => {\n \
    \   templateDataStorageGetItemCopyWasCalled = true;\n    callLater(() => {\n \
    \     assertThat(key).isEqualTo(EXPECTED_CACHE_KEY);\n    });\n    return {\n\
    \      profitInfo: EXPECTED_CACHE_OBJ.profitInfo,\n      expiresAt: 1\n    };\n\
    \  },\n  setItemCopy: (key, value) => {\n    templateDataStorageSetItemCopyWasCalled\
    \ = true;\n    callLater(() => {\n      assertThat(key).isEqualTo(EXPECTED_CACHE_KEY);\n\
    \      assertThat(value).isEqualTo(EXPECTED_CACHE_OBJ);\n    });\n  }\n});\n\n\
    mock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {\n  return\
    \ Promise.create((resolve) => {\n    resolve({ \n      statusCode: 200, \n   \
    \   body: JSON.stringify(EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT)\n \
    \   });\n  });\n});\n\nrunCode(copyMockData);\n\ncallLater(() => {\n  assertThat(templateDataStorageGetItemCopyWasCalled,\
    \ 'Should call templateDataStorage.getItemCopy.').isTrue();\n  assertThat(templateDataStorageSetItemCopyWasCalled,\
    \ 'Should call templateDataStorage.setItemCopy.').isTrue();\n  assertApi('sendHttpRequest').wasCalled();\n\
    });"
- name: '[Cache enabled] Item Data exists in cache and is valid, request must not
    be made and cache must not be updated'
  code: |-
    const copyMockData = setAllMockData('ga4', {
      useCache: true,
      cacheExpirationTime: EXPECTED_CACHE_EXPIRATION_TIME_IN_SECONDS + ''
    });
    setGetEventData([GA4ITEMS[0]]);

    let templateDataStorageGetItemCopyWasCalled = false;
    let templateDataStorageSetItemCopyWasCalled = false;
    mockObject('templateDataStorage', {
      getItemCopy: (key) => {
        templateDataStorageGetItemCopyWasCalled = true;
        callLater(() => {
          assertThat(key).isEqualTo(EXPECTED_CACHE_KEY);
        });
        return EXPECTED_CACHE_OBJ;
      },
      setItemCopy: (key, value) => {
        templateDataStorageSetItemCopyWasCalled = true;
      }
    });

    runCode(copyMockData);

    callLater(() => {
      assertThat(templateDataStorageGetItemCopyWasCalled, 'Should call templateDataStorage.getItemCopy.').isTrue();
      assertThat(templateDataStorageSetItemCopyWasCalled, 'Should not call templateDataStorage.setItemCopy.').isFalse();
      assertApi('sendHttpRequest').wasNotCalled();
    });
- name: '[Request] Items Profit Product Feed Requests are not succesful, only Item
    Price and Item Quantity should be passed to Promise All'
  code: "setGetEventData([GA4ITEMS[0]]);\n\n[\n  {\n    description: 'Items Profit\
    \ Product Feed Requests returns something different than 200',\n    mock: (resolve,\
    \ reject) => { resolve({ statusCode: 400 }); }\n  },\n  {\n    description: 'Items\
    \ Profit Product Feed Requests returns 200 but body.success is not true',\n  \
    \  mock: (resolve, reject) => { resolve({ statusCode: 200, body: JSON.stringify({\
    \ success: false }) }); }\n  },\n  {\n    description: 'Items Profit Product Feed\
    \ Requests fails or times out',\n    mock: (resolve, reject) => { reject({ reason:\
    \ 'timed out' }); }\n  }\n].forEach((scenario) => {\n  const copyMockData = setAllMockData('ga4');\n\
    \  \n  mock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {\n\
    \    return Promise.create((resolve, reject) => {\n      scenario.mock(resolve,\
    \ reject);\n    });\n  });\n  \n  mockObject('Promise', {\n    all: (promises)\
    \ => {\n      return promises[0].then((baseItem) => {\n        callLater(() =>\
    \ assertThat(baseItem).isEqualTo({ price: GA4ITEMS[0].price, quantity: GA4ITEMS[0].quantity\
    \ }) );\n        return [baseItem];\n      });\n    }\n  });\n  \n  runCode(copyMockData);\n\
    });"
- name: '[Request] If an error happens when calculating profit, the variable must
    return undefined'
  code: "const copyMockData = setAllMockData('ga4');\nsetGetEventData([GA4ITEMS[0]]);\n\
    \nmock('sendHttpRequest', (requestUrl, requestOptions, requestBody) => {\n  return\
    \ Promise.create((resolve) => {\n    resolve({ \n      statusCode: 200, \n   \
    \   body: JSON.stringify(EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT)\n \
    \   });\n  });\n});\n\nmockObject('Promise', {\n  all: (promises) => {\n    return\
    \ promises[0].then((baseItem) => {\n      assertThat(baseItem).isEqualTo({ price:\
    \ GA4ITEMS[0].price, quantity: GA4ITEMS[0].quantity });\n      return Promise.create((resolve,\
    \ reject) => reject('Some error inside Promise.all().then(itemsWithProfitInfo)'));\n\
    \    });\n  }\n});\n\nrunCode(copyMockData).then((variableResult) => {\n  assertThat(variableResult).isUndefined();\n\
    });"
- name: '[Profit Calculation] Item does not have profit info and price is not used
    as fallback'
  code: "setGetEventData();\n\n[\n  {\n    description: 'Profit Value is Absolute',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ undefined, 'absolute')\n  },\n  {\n    description: 'Profit Value is Percent',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ undefined, 'percent')\n  },\n].forEach((scenario, index) => {\n  const copyMockData\
    \ = setAllMockData('ga4', {\n    useItemPriceAsFallback: false\n  });\n  \n  mock('sendHttpRequest',\
    \ (requestUrl, requestOptions, requestBody) => {\n    return Promise.create((resolve)\
    \ => {\n      resolve({ \n        statusCode: 404,\n        body: JSON.stringify({\
    \ success: false })\n      });\n    });\n  });\n  \n  runCode(copyMockData).then((variableResult)\
    \ => {\n    const expectedProfit = 0;\n    assertThat(variableResult).isEqualTo(expectedProfit);\n\
    \  });\n});"
- name: '[Profit Calculation] Item does not have profit info and price is used as
    fallback'
  code: "const calculateExpectedProfit = (itemsWithProfitInfo) => {\n  return itemsWithProfitInfo.reduce((acc,\
    \ item) => {\n    if (getType(item.price) === 'number') return acc + item.price\
    \ * item.quantity;\n    return acc;\n  }, 0.0);\n};\n\nGA4ITEMS[0].price = GA4ITEMS[0].price\
    \ + ''; // Checking if it successfully converts to Number.\nGA4ITEMS[0].quantity\
    \ = GA4ITEMS[0].quantity + ''; // Checking if it successfully converts to Number.\n\
    \nsetGetEventData();\n\n[\n  {\n    description: 'Profit Value is Absolute',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ undefined, 'absolute')\n  },\n  {\n    description: 'Profit Value is Percent',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ undefined, 'percent')\n  },\n].forEach((scenario, index) => {\n  const copyMockData\
    \ = setAllMockData('ga4', {\n    useItemPriceAsFallback: true\n  });\n  \n  mock('sendHttpRequest',\
    \ (requestUrl, requestOptions, requestBody) => {\n    return Promise.create((resolve)\
    \ => {\n      resolve({ \n        statusCode: 404,\n        body: JSON.stringify({\
    \ success: false })\n      });\n    });\n  });\n  \n  runCode(copyMockData).then((variableResult)\
    \ => {\n    const expectedProfit = calculateExpectedProfit(scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO);\n\
    \    assertThat(variableResult).isEqualTo(expectedProfit);\n  });\n});"
- name: '[Profit Calculation] item has profit info'
  code: "const calculateExpectedProfit = (itemsWithProfitInfo) => {\n  return itemsWithProfitInfo.reduce((acc,\
    \ item) => {\n    if (item.profitType === 'absolute') {\n      return acc + item.profit\
    \ * item.quantity;\n    } else if (item.profitType === 'percent' && getType(item.price)\
    \ === 'number') {\n      return acc + item.price * (item.profit / 100) * item.quantity;\n\
    \    }\n    return acc;\n  }, 0.0);\n};\n\nGA4ITEMS[0].price = GA4ITEMS[0].price\
    \ + ''; // Checking if it successfully converts to Number.\nGA4ITEMS[0].quantity\
    \ = GA4ITEMS[0].quantity + ''; // Checking if it successfully converts to Number.\n\
    \nsetGetEventData();\n\n[\n  {\n    description: 'Profit Value is Absolute',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ 2, 'absolute')\n  },\n  {\n    description: 'Profit Value is Percentage',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ 10, 'percent')\n  },\n].forEach((scenario, index) => {\n  const copyMockData\
    \ = setAllMockData('ga4', {\n    useItemPriceAsFallback: true\n  });\n  \n  mock('sendHttpRequest',\
    \ (requestUrl, requestOptions, requestBody) => {\n    return Promise.create((resolve)\
    \ => {\n      resolve({ \n        statusCode: 200,\n        body: JSON.stringify({\
    \ success: true, data: { value: scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO[index].profit,\
    \ value_type: scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO[index].profitType } })\n\
    \      });\n    });\n  });\n  \n  runCode(copyMockData).then((variableResult)\
    \ => {\n    const expectedProfit = calculateExpectedProfit(scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO);\n\
    \    assertThat(variableResult).isEqualTo(expectedProfit);\n  });\n});"
- name: '[Profit Calculation] Profit must be rounded'
  code: "const calculateExpectedProfit = (itemsWithProfitInfo) => {\n  return itemsWithProfitInfo.reduce((acc,\
    \ item) => {\n    if (item.profitType === 'absolute') {\n      return acc + item.profit\
    \ * item.quantity;\n    } else if (item.profitType === 'percent' && getType(item.price)\
    \ === 'number') {\n      return acc + item.price * (item.profit / 100) * item.quantity;\n\
    \    }\n    return acc;\n  }, 0.0);\n};\n\nGA4ITEMS[0].price = GA4ITEMS[0].price\
    \ + ''; // Checking if it successfully converts to Number.\nGA4ITEMS[0].quantity\
    \ = GA4ITEMS[0].quantity + ''; // Checking if it successfully converts to Number.\n\
    \nsetGetEventData();\n\n[\n  {\n    description: 'Profit Value is Absolute',\n\
    \    EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ 2, 'absolute')\n  },\n  {\n    description: 'Profit Value is Percent',\n   \
    \ EXPECTED_ITEMS_WITH_PROFIT_INFO: createMockItemsWithProfitInfoArray(GA4ITEMS,\
    \ 10, 'percent')\n  },\n].forEach((scenario, index) => {\n  const copyMockData\
    \ = setAllMockData('ga4', {\n    useItemPriceAsFallback: true,\n    roundResult:\
    \ true\n  });\n  \n  mock('sendHttpRequest', (requestUrl, requestOptions, requestBody)\
    \ => {\n    return Promise.create((resolve) => {\n      resolve({ \n        statusCode:\
    \ 200,\n        body: JSON.stringify({ success: true, data: { value: scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO[index].profit,\
    \ value_type: scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO[index].profitType } })\n\
    \      });\n    });\n  });\n  \n  runCode(copyMockData).then((variableResult)\
    \ => {\n    const expectedProfit = calculateExpectedProfit(scenario.EXPECTED_ITEMS_WITH_PROFIT_INFO);\n\
    \    const expectedRoundedProfit = makeNumber(Math.round(expectedProfit * 100)\
    \ / 100);\n    assertThat(variableResult).isEqualTo(expectedRoundedProfit);\n\
    \  });\n});"
setup: "const JSON = require('JSON');\nconst Promise = require('Promise');\nconst\
  \ parseUrl = require('parseUrl');\nconst Object = require('Object');\nconst makeInteger\
  \ = require('makeInteger');\nconst makeNumber = require('makeNumber');\nconst toBase64\
  \ = require('toBase64');\nconst sha256Sync = require('sha256Sync');\nconst callLater\
  \ = require('callLater');\nconst getEventData = require('getEventData');\nconst\
  \ getType = require('getType');\nconst Math = require('Math');\n\nconst assign =\
  \ () => {\n  const target = arguments[0];\n  for (let i = 1; i < arguments.length;\
  \ i++) {\n    for (let key in arguments[i]) {\n      target[key] = arguments[i][key];\n\
  \    }\n  }\n  return target;\n};\n\nconst createMockItemsWithProfitInfoArray =\
  \ (items, profit, profitType) => {\n  return items.map((item) => {\n    const baseItem\
  \ = {\n      price: makeNumber(item.price) || undefined,\n      quantity: makeInteger(item.quantity)\
  \ || 1\n    };\n    \n    if (profit && profitType) {\n      baseItem.profit = profit;\n\
  \      baseItem.profitType = profitType;\n    }\n    \n    return baseItem;\n  });\n\
  };\n\nconst GA4ITEMS = [{ item_id: '1', price: 10.01, quantity: 3 }, { item_id:\
  \ '2', price: 21.01 }, { item_id: '3', price: 50.3, quantity: 2 }];\nconst setGetEventData\
  \ = (customGA4Items) => {\n  mock('getEventData', (key) => {\n    if (key !== 'items')\
  \ return;\n    return customGA4Items || GA4ITEMS;\n  });\n};\n\nconst expectedBigQuerySettings\
  \ = {\n  logBigQueryProjectId: 'logBigQueryProjectId',\n  logBigQueryDatasetId:\
  \ 'logBigQueryDatasetId',\n  logBigQueryTableId: 'logBigQueryTableId'\n};\n\nconst\
  \ requiredConsoleKeys = ['Type', 'TraceId', 'Name'];\nconst requiredBqKeys = ['timestamp',\
  \ 'type', 'trace_id', 'tag_name'];\nconst expectedBqOptions = { ignoreUnknownValues:\
  \ true };\n\nconst mockData = {\n  useOptimisticScenario: false,\n  adStorageConsent:\
  \ 'optional',\n  logBigQueryProjectId: expectedBigQuerySettings.logBigQueryProjectId,\n\
  \  logBigQueryDatasetId: expectedBigQuerySettings.logBigQueryDatasetId,\n  logBigQueryTableId:\
  \ expectedBigQuerySettings.logBigQueryTableId\n};\n\nconst CUSTOMITEMS = [{ id:\
  \ '1', p: 10.01, qtd: 3 }, { id: '2', p: 21.01 }, { id: '3', p: 50.3, qtd: 2 }];\n\
  const setAllMockData = (itemsSource, objToBeMerged) => {\n  const base = {\n   \
  \ useItemPriceAsFallback: false,\n    useCache: false,\n    roundResult: false,\n\
  \    useDifferentStapeProductFeed: false,\n    logType: 'debug',\n    bigQueryLogType:\
  \ 'no'\n  };\n  \n  const mockDataByItemArraySource = {\n    ga4: {\n      itemsSource:\
  \ 'ga4',\n      ga4ItemIdKey: 'item_id',\n    },\n    custom: {\n      itemsSource:\
  \ 'custom',\n      customItems: CUSTOMITEMS,\n      customItemIdKey: 'id',\n   \
  \   customItemPriceKey: 'p',\n      customItemQuantityKey: 'qtd'\n    }\n  };\n\
  \  \n  return assign(JSON.parse(JSON.stringify(mockData)), base, mockDataByItemArraySource[itemsSource],\
  \ objToBeMerged || {});\n};\n\nmock('sendHttpRequest', (requestUrl, callback, requestOptions,\
  \ requestBody) => {\n  if (typeof callback === 'function') {\n    callback(200);\n\
  \  } else {\n    requestBody = requestOptions;\n    requestOptions = callback;\n\
  \    return Promise.create((resolve, reject) => {\n      resolve({ statusCode: 200\
  \ });\n    });  \n  }\n});\n\nmock('getRequestHeader', (header) => {\n  if (header\
  \ === 'trace-id') return 'expectedTraceId';\n  else if (header === 'x-gtm-identifier')\
  \ return 'expectedXGtmIdentifier';\n  else if (header === 'x-gtm-default-domain')\
  \ return 'expectedXGtmDefaultDomain';\n  else if (header === 'x-gtm-api-key') return\
  \ 'expectedXGtmApiKey';\n});\n\nconst NOW = 1747945830456;\nmock('getTimestampMillis',\
  \ NOW);\n\nconst EXPECTED_REQUEST_BASE_URL = 'https://expectedXGtmIdentifier.expectedXGtmDefaultDomain/stape-api/expectedXGtmApiKey/v2/poas/feeds/default/products/';\n\
  const EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT = {\n  data: {\n    created_at:\
  \ '2025-12-09T12:30:19.725535Z',\n    id: GA4ITEMS[0].item_id,\n    updated_at:\
  \ '2025-12-09T12:30:19.725535Z',\n    value: 10,\n    value_type: 'percent'\n  },\n\
  \  success: true\n};\n\nconst EXPECTED_CACHE_KEY = 'CivzT+aFuUBjEo6jvVPe1iJItRk8777gbgvtlhmHWfk=';\
  \ // sha256Sync('https://expectedXGtmIdentifier.expectedXGtmDefaultDomain/stape-api/expectedXGtmApiKey/v2/poas/feeds/default/products/1');\n\
  const EXPECTED_CACHE_EXPIRATION_TIME_IN_SECONDS = 180;\nconst EXPECTED_CACHE_OBJ\
  \ = { \n  profitInfo: { profit: EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT.data.value,\
  \ profitType: EXPECTED_SUCCESS_PRODUCT_FEED_ITEM_RETURN_OBJECT.data.value_type},\
  \ \n  expiresAt: NOW + EXPECTED_CACHE_EXPIRATION_TIME_IN_SECONDS * 60 * 1000 \n\
  };"


___NOTES___

Created on 17/09/2024, 11:34:39

