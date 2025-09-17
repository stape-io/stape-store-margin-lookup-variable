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
