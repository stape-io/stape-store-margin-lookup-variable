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
const BigQuery = require('BigQuery');

/*==============================================================================
==============================================================================*/

const traceId = getRequestHeader('trace-id');

const storeKeyId = data.storeKeyId;
const storeKeyMargin = data.storeKeyMargin;

const items = data.items ? data.items : getEventData('items');
const arrKeyQt = data.arrKeyQt ? data.arrKeyQt : 'quantity';
const arrKeyId = data.arrKeyId ? data.arrKeyId : 'item_id';

const promises = [];
let res = 0;

if (!items) return undefined;

for (let i = 0; i < items.length; i++) {
  if (items[i][arrKeyId]) promises.push(getResponseBody(items[i][arrKeyId]));
}

return Promise.all(promises).then((results) => {
  for (let i = 0; i < results.length; i++) {
    let qt = makeNumber(items[i][arrKeyQt]) ? makeNumber(items[i][arrKeyQt]) : 1;
    let tmp = makeNumber(mapResponse(results[i]));
    if (tmp) res += tmp * qt;
    else res += makeNumber(items[i]['price']) * qt;
  }

  if (data.roundResult) {
    res = makeNumber(Math.round(res * 100) / 100);
  }

  return res;
});

/*==============================================================================
  Vendor related functions
==============================================================================*/

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

function getOptions() {
  return { method: 'POST', headers: { 'Content-Type': 'application/json' } };
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

  log({
    Name: 'StapeStore',
    Type: 'Request',
    TraceId: traceId,
    EventName: 'StoreRead',
    RequestMethod: options.method,
    RequestUrl: url,
    RequestBody: postBody
  });

  return sendHttpRequest(url, options, JSON.stringify(postBody)).then((response) => {
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
}

/*==============================================================================
  Helpers
==============================================================================*/

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
