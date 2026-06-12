const encodeUriComponent = require('encodeUriComponent');
const getEventData = require('getEventData');
const getRequestHeader = require('getRequestHeader');
const getTimestampMillis = require('getTimestampMillis');
const getType = require('getType');
const JSON = require('JSON');
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
    return;
  });

return profit;

/*==============================================================================
  Vendor related functions
==============================================================================*/

function getStapeProductFeedItemUrl(baseUrl, itemId) {
  const useStapeStore = data.productFeedSource === 'stapeStore'; // To avoid a breaking change.
  const innerPath = useStapeStore ? '/' : '/products/';
  return baseUrl + innerPath + enc(itemId);
}

function getStapeProductFeedBaseUrl(data) {
  let containerIdentifier;
  let defaultDomain;
  let containerApiKey;

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

  const useStapeStore = data.productFeedSource === 'stapeStore'; // To avoid a breaking change.
  const lookupPath = useStapeStore
    ? 'store/collections/' + enc(data.stapeStoreCollectionName || 'default') + '/documents'
    : 'poas/feeds/default';

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
  const useStapeStore = data.productFeedSource === 'stapeStore'; // To avoid a breaking change.
  const useCache = data.useCache;
  const requestBaseUrl = getStapeProductFeedBaseUrl(data);
  const requestOptions = getRequestOptions();
  const itemIdKey = data.itemsSource === 'ga4' ? data.ga4ItemIdKey : data.customItemIdKey;
  const itemPriceKey = data.itemsSource === 'custom' ? data.customItemPriceKey : 'price';
  const itemQuantityKey = data.itemsSource === 'custom' ? data.customItemQuantityKey : 'quantity';
  const discountKey = data.discountKey || 'discount';

  const responsePromises = items.map((item) => {
    const itemId = item[itemIdKey];
    const baseItem = {
      price: makeNumber(item[itemPriceKey]) || undefined,
      quantity: makeInteger(item[itemQuantityKey]) || 1,
      discount: data.useDiscount ? makeNumber(item[discountKey]) || 0 : 0
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

    return sendHttpRequest(requestUrl, requestOptions)
      .then((result) => {
        const parsedBody = JSON.parse(result.body || '{}');

        if (result.statusCode === 200 && parsedBody.success) {
          let profitValue;
          let profitType;

          if (useStapeStore && parsedBody.data.data) {
            profitValue = parsedBody.data.data[data.stapeStoreValueKey || 'margin'];
            profitType = parsedBody.data.data[data.stapeStoreValueTypeKey || 'value_type'];
          } else if (!useStapeStore) {
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
        return baseItem;
      });
  });

  return responsePromises;
}

function calculateProfit(itemsWithProfitInfo) {
  const useDiscount = data.useDiscount;

  const useItemLevelDiscount = useDiscount && data.discountType === 'item';
  let profit = itemsWithProfitInfo.reduce((acc, item) => {
    const itemDiscount = useItemLevelDiscount ? makeNumber(item.discount) || 0 : 0;
    if (getType(item.profit) === 'number') {
      if (item.profitType === 'absolute') {
        return acc + (item.profit - itemDiscount) * item.quantity;
      } else if (item.profitType === 'percent' && getType(item.price) === 'number') {
        return (
          acc +
          profitMarginCalculatorPerItem(
            data.discountFormula,
            item.price,
            itemDiscount,
            item.profit,
            item.quantity
          )
        );
      }
    } else if (data.useItemPriceAsFallback && getType(item.price) === 'number') {
      return acc + (item.price - itemDiscount) * item.quantity;
    }
    return acc;
  }, 0.0);

  const useOrderLevelDiscount = useDiscount && data.discountType === 'order';
  if (useOrderLevelDiscount && !useItemLevelDiscount) {
    const discountKey = data.discountKey || 'discount';
    const orderDiscount = makeNumber(getEventData(discountKey)) || 0;
    profit = profit - orderDiscount;
  }

  if (data.roundResult) return makeNumber(Math.round(profit * 100) / 100);
  return profit;
}

function profitMarginCalculatorPerItem(formula, price, discount, margin, quantity) {
  if (formula === 'discountOverItemPrice') {
    return (price - discount) * (margin / 100) * quantity;
  } else if (formula === 'discountOverItemProfit') {
    return (price * (margin / 100) - discount) * quantity;
  }
  return price * (margin / 100) * quantity;
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
