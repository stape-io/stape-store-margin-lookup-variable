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
    "displayName": "Field containing product ID in your Stape Store",
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
    "displayName": "Field containing margin value in your Stape Store",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "LABEL",
    "name": "label1",
    "displayName": "Variable will look for standard \u0027items\u0027 array of objects in the Event Data. You only need to select which field we\u0027re using as item id."
  },
  {
    "type": "RADIO",
    "name": "arrKeyId",
    "displayName": "Select field to be used as product id",
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
    "name": "settings",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "storeResponse",
        "checkboxText": "Store response in cache",
        "simpleValueType": true,
        "help": "Store the response in Template Storage. If all parameters of the request are the same response will be taken from the cache if it exists. This will apply to each individual request for a specific product id"
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
const isLoggingEnabled = determinateIsLoggingEnabled();
const traceId = isLoggingEnabled ? getRequestHeader('trace-id') : undefined;
const makeNumber = require('makeNumber');

const getEventData = require('getEventData');
const storeKeyId = data.storeKeyId;
const storeKeyMargin = data.storeKeyMargin;

const items = data.items ? data.items : getEventData('items');
const arrKeyQt = data.arrKeyQt ? data.arrKeyQt : 'quantity';
const arrKeyId = data.arrKeyId ? data.arrKeyId : 'item_id';

let promises = [];
var res = 0;

if (!items)
  return undefined;

for (let i = 0; i < items.length; i++) {
  if (items[i][arrKeyId]) promises.push(getResponseBody(items[i][arrKeyId])); 
}

return Promise.all(promises)
  .then((results) => {
    for (let i = 0; i < results.length; i++) {
      let qt = makeNumber(items[i][arrKeyQt]) ? makeNumber(items[i][arrKeyQt]) : 1;
      let tmp = makeNumber(mapResponse(results[i]));
      if (tmp) 
        res += tmp * qt;
      else 
        res += makeNumber(items[i]['price']) * qt;
    }
    return res;
  });



function getOptions() {
  return {method: 'POST', headers: { 'Content-Type': 'application/json' }};
}


function mapResponse(bodyString) {
  const body = JSON.parse(bodyString);
  let document = body && body.length > 0 ? body[0] : {};
  document = document.data || {};

  if (!storeKeyMargin) return document;

  const keys = storeKeyMargin.trim().split('.');
  let value = document;
  for (let i = 0; i < keys.length; i++) {
    const key = keys[i];
    if (!value || !key) break;
    value = value[key];
  }

  return value;
}


function getPostBody(productId) {
  return {
    data: [[storeKeyId, 'equal', productId]],
    limit: 1
  };
}


function getResponseBody(productId) {
  const url = getStoreUrl();
  const options = getOptions();
  const postBody = getPostBody(productId);
  const cacheKey = data.storeResponse ? sha256Sync(url + JSON.stringify(postBody)) : '';

  if (data.storeResponse) {
    const cachedValue = templateDataStorage.getItemCopy(cacheKey);
    if (cachedValue) return Promise.create((resolve) => resolve(cachedValue));
  }

  if (isLoggingEnabled) {
    logToConsole(
      JSON.stringify({
        Name: 'StapeStore',
        Type: 'Request',
        TraceId: traceId,
        EventName: 'StoreRead',
        RequestMethod: options.method,
        RequestUrl: url,
        RequestBody: postBody,
      })
    );
  }
  return sendHttpRequest(url, options, JSON.stringify(postBody)).then((response) => {
    if (isLoggingEnabled) {
      logToConsole(
        JSON.stringify({
          Name: 'StapeStore',
          Type: 'Response',
          TraceId: traceId,
          EventName: 'StoreRead',
          ResponseStatusCode: response.statusCode,
          ResponseHeaders: response.headers,
          ResponseBody: response.body,
        })
      );
    }

    if (data.storeResponse) templateDataStorage.setItemCopy(cacheKey, response.body);

    return response.body;
  });
}

function getStoreUrl() {
  const containerIdentifier = getRequestHeader('x-gtm-identifier');
  const defaultDomain = getRequestHeader('x-gtm-default-domain');
  const containerApiKey = getRequestHeader('x-gtm-api-key');

  return (
    'https://' +
    enc(containerIdentifier) +
    '.' +
    enc(defaultDomain) +
    '/stape-api/' +
    enc(containerApiKey) +
    '/v1/store'
  );
}


function determinateIsLoggingEnabled() {
  const containerVersion = getContainerVersion();
  const isDebug = !!(containerVersion && (containerVersion.debugMode || containerVersion.previewMode));

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

function enc(data) {
  data = data || '';
  return encodeUriComponent(data);
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
            "string": "any"
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
            "string": "debug"
          }
        }
      ]
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 17/09/2024, 11:34:39


