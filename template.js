const BigQuery = require('BigQuery');
const encodeUriComponent = require('encodeUriComponent');
const getContainerVersion = require('getContainerVersion');
const getEventData = require('getEventData');
const getRequestHeader = require('getRequestHeader');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const JSON = require('JSON');
const logToConsole = require('logToConsole');
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const Math = require('Math');
const Promise = require('Promise');
const sendHttpRequest = require('sendHttpRequest');
const sha256Sync = require('sha256Sync');
const templateDataStorage = require('templateDataStorage');

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
  const innerPath = data.useCustomStoreCollection ? '' : '/products/';
  return baseUrl + innerPath + enc(itemId);
}

function getStapeProductFeedBaseUrl(data) {
  const customCollectionName = data.customCollectionName;
  const poasFeedPath = 'poas/feeds/default';
  const collectionFeedPath = 'collections/' + enc(customCollectionName) + '/documents/';
  let containerIdentifier;
  let defaultDomain;
  let containerApiKey = data.stapeProductFeedContainerApiKey || data.containerApiKey;

  const shouldUseDifferentStore =
    isUIFieldTrue(data.useDifferentStapeProductFeed) && getType(containerApiKey) === 'string';

  const shouldUseCustomCollection =
    data.useCustomStoreCollection && getType(containerApiKey) === 'string';

  if (shouldUseDifferentStore || shouldUseCustomCollection) {
    const containerApiKeyParts = containerApiKey.split(':');
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

  const lookupPath = shouldUseCustomCollection ? 'store/' + collectionFeedPath : poasFeedPath;

  return (
    'https://' +
    enc(containerIdentifier) +
    '.' +
    enc(defaultDomain) +
    '/stape-api/' +
    enc(containerApiKey) +
    '/v2/' +
    lookupPath
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

  const feedItemPriceKey = data.useCustomStoreCollection && data.valueKey;
  const feedItemValueTypeKey = data.useCustomStoreCollection && data.valueTypeKey;

  const responsePromises = items.map((item) => {
    const itemId = item[itemIdKey];

    let parsedPrice = makeNumber(item[itemPriceKey]);
    let parsedQty = makeInteger(item[itemQuantityKey]);

    const baseItem = {
      price: parsedPrice === 0 ? 0 : parsedPrice || undefined,
      quantity: parsedQty || 1
    };

    if (!itemId) {
      return Promise.create((resolve) => resolve(baseItem));
    }

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
          Type: 'Response',
          EventName: 'ReadItemProfit',
          ResponseStatusCode: result.statusCode,
          ResponseHeaders: result.headers,
          ResponseBody: result.body
        });

        const parsedBody = JSON.parse(result.body || '{}');

        if (result.statusCode === 200 && parsedBody.success) {
          let profitValue;
          let profitType;

          if (data.useCustomStoreCollection && parsedBody.data.data) {
            profitValue = parsedBody.data.data[feedItemPriceKey];
            profitType = parsedBody.data.data[feedItemValueTypeKey];
          } else {
            profitValue = parsedBody.data.value;
            profitType = parsedBody.data.value_type;
          }

          const profitInfo = {
            profit: makeNumber(profitValue),
            profitType: profitType || 'absolute'
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
      .catch((error) => {
        log({
          Name: 'StapeProductFeed',
          Type: 'Message',
          EventName: 'ReadItemProfit',
          Message: 'Request failed or timed out.',
          Reason: JSON.stringify(error)
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
