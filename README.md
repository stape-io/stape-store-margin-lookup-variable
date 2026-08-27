# Stape Store Margin Lookup Variable for Google Tag Manager Server Container

The **Stape Store Margin Lookup Variable** for GTM Server allows you to **retrieve margin data** from `Stape POAS Data Feed` or `Stape Store` for each product in your `items` array and returns a **combined margin value** that accounts for quantity, enabling you to track **Profit on Ad Spend (POAS)** for your conversion events and advertising campaigns.

## Useful Resources
- [How to set up POAS Data Feed](https://stape.io/helpdesk/documentation/poas-data-feed-power-up)
- [Setting up Profit on Ad Spend via Stape Store](https://stape.io/blog/profit-on-ad-spend-why-it-matters-and-how-to-set-it-up-via-stape-store)
- [Profit tracking with sGTM and Stape Store: a complete guide](https://stape.io/blog/profit-tracking-sgtm-stape-store)

## How to Configure `Stape Store` as a Product Feed Source

When using Stape Store to store margin data, you must organize it following the schema below. In Stape Store, margin data is organized in **collections**, where each document in a collection represents a single product:

- **Document ID** — must match the product ID used in your `items` array (e.g., the value of `item_id`).
- **Margin value field** — a numeric field holding the margin amount. Defaults to `margin`; configurable via the **Feed key for profit margin value** setting in the template.
- **Margin type field** *(optional)* — a string field set to either `absolute` (fixed currency amount) or `percent` (fraction of revenue). Defaults to `value_type`; configurable via the **Feed key for profit margin value type** setting.

Product data can be uploaded to Stape Store via the [REST API](https://api.store.stape.io/store-api/v2/doc) or through the [CSV import](https://stape.io/blog/profit-tracking-sgtm-stape-store#2-add-product-margin-data-to-stape-store) feature in the Stape Store interface.

## Open Source

The **Stape Store Margin Lookup Variable for GTM Server Side** is developed and maintained by the [Stape Team](https://stape.io/) under the Apache 2.0 license.

### GTM Gallery Status
🟢 [Listed](https://tagmanager.google.com/gallery/#/owners/stape-io/templates/stape-store-margin-lookup-variable)
