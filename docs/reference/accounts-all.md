---
title: All Accounts
clientData:
  laboratoryUrl: https://www.stellar.org/laboratory/#explorer?resource=accounts&endpoint=all
---

The all accounts endpoint returns a collection of all the [accounts](./resources/account.md) that have ever existed. Results
are ordered by account creation time. An account id may show up multiple times if they were [merged](./resources/operation.md#Account_Merge) and then [created](./resources/operation.md#Create_Account) again.

This endpoint can also be used in [streaming](../learn/responses.md#streaming) mode so it is possible to use it to listen for new accounts as they get made in the Stellar network.
If called in streaming mode Horizon will start at the earliest known account unless a `cursor` is set. In that case it will start from the `cursor`. You can also set `cursor` value to `now` to only stream accounts created since your request time.

## Request

```
GET /accounts{?cursor,limit,order}
```

### Arguments

| name | notes | description | example |
| ---- | ----- | ----------- | ------- |
| `?cursor` | optional, any, default _null_ | A paging token, specifying where to start returning records from. When streaming this can be set to `now` to stream object created since your request time. | `12884905984` |
| `?order`  | optional, string, default `asc` | The order in which to return rows, "asc" or "desc" | `asc` |
| `?limit` | optional, number, default `10` | Maximum number of records to return | `200` |

### curl Example Request

```shell
curl "https://horizon-testnet.stellar.org/accounts?limit=200&order=desc"
```

### JavaScript Example Request

```javascript
var StellarSdk = require('stellar-sdk');
var server = new StellarSdk.Server('https://horizon-testnet.stellar.org');

server.accounts()
  .call()
  .then(function (accountResults) {
    //page 1
    console.log(accountResults.records)
    return accountResults.next()
  })
  .then(function (accountResults) {
    //page 2
    console.log(accountResults.records)
  })
  .catch(function (err) {
    console.log(err)
  })

```

## Response

If called normally this endpoint responds with a [page](./resources/page.md) of accounts.
If called in streaming mode the account resources are returned individually.
See [accounts](./resources/account.md) for reference.

### Example Response

```json
{
  "_embedded": {
    "records": [
      {
        "id": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO",
        "paging_token": "77309415424",
        "account_id": "GBIA4FH6TV64KSPDAJCNUQSM7PFL4ILGUVJDPCLUOPJ7ONMKBBVUQHRO"
      },
      {
        "id": "GC2ADYAIPKYQRGGUFYBV2ODJ54PY6VZUPKNCWWNX2C7FCJYKU4ZZNKVL",
        "paging_token": "463856472064",
        "account_id": "GC2ADYAIPKYQRGGUFYBV2ODJ54PY6VZUPKNCWWNX2C7FCJYKU4ZZNKVL"
      },
      {
        "id": "GB4ZONAMYWRCU7KPV6A6DEPIY3YDZFVFTFC42XQGLWJQ53GQEDE3TI4C",
        "paging_token": "605590392832",
        "account_id": "GB4ZONAMYWRCU7KPV6A6DEPIY3YDZFVFTFC42XQGLWJQ53GQEDE3TI4C"
      },
      {
        "id": "GBC6OK4WVUKWUTHNJLKLYJ57G6UUQTJMHY2ON6R4DMRRCRDKYAWGH6CY",
        "paging_token": "31490700218368",
        "account_id": "GBC6OK4WVUKWUTHNJLKLYJ57G6UUQTJMHY2ON6R4DMRRCRDKYAWGH6CY"
      },
      {
        "id": "GC5BIFJBP5GTNYB3WHM7MA7J3Z2EF7VE7XCDU7V47AOZMGIBB4324W63",
        "paging_token": "35631048691712",
        "account_id": "GC5BIFJBP5GTNYB3WHM7MA7J3Z2EF7VE7XCDU7V47AOZMGIBB4324W63"
      },
      {
        "id": "GD7IDKHPOQJ2DFICCBSX5QEDSXSC5U7HRZLKNIXGCLDRRU5UOBEYABJO",
        "paging_token": "35927401435136",
        "account_id": "GD7IDKHPOQJ2DFICCBSX5QEDSXSC5U7HRZLKNIXGCLDRRU5UOBEYABJO"
      },
      {
        "id": "GBSN5O2Q47RDWKANTBK5PZAOMHMQQZE53LS32OKCBY6XGXZSFAVD7SUR",
        "paging_token": "46269682683904",
        "account_id": "GBSN5O2Q47RDWKANTBK5PZAOMHMQQZE53LS32OKCBY6XGXZSFAVD7SUR"
      },
      {
        "id": "GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB",
        "paging_token": "46316927324160",
        "account_id": "GBBM6BKZPEHWYO3E3YKREDPQXMS4VK35YLNU7NFBRI26RAN7GI5POFBB"
      },
      {
        "id": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75",
        "paging_token": "46428596473856",
        "account_id": "GAKLBGHNHFQ3BMUYG5KU4BEWO6EYQHZHAXEWC33W34PH2RBHZDSQBD75"
      },
      {
        "id": "GBAP36MOHWTXNGO6I6UYUXSOF7AA2PA5Y26PJW6VG7CVDFQPIX243ILV",
        "paging_token": "46669114642432",
        "account_id": "GBAP36MOHWTXNGO6I6UYUXSOF7AA2PA5Y26PJW6VG7CVDFQPIX243ILV"
      }
    ]
  },
  "_links": {
    "next": {
      "href": "/accounts?order=asc&limit=10&cursor=46669114642432"
    },
    "prev": {
      "href": "/accounts?order=desc&limit=10&cursor=77309415424"
    },
    "self": {
      "href": "/accounts?order=asc&limit=10&cursor="
    }
  }
}
```

### Example Streaming Event

```json
{
  "_links": {
    "effects": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/effects/{?cursor,limit,order}",
      "templated": true
    },
    "offers": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/offers/{?cursor,limit,order}",
      "templated": true
    },
    "operations": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/operations/{?cursor,limit,order}",
      "templated": true
    },
    "self": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36"
    },
    "transactions": {
      "href": "/accounts/GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36/transactions/{?cursor,limit,order}",
      "templated": true
    }
  },
  "id": "GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36",
  "paging_token": "66035122180096",
  "account_id": "GA2HGBJIJKI6O4XEM7CZWY5PS6GKSXL6D34ERAJYQSPYA6X6AI7HYW36",
  "sequence": 66035122176002,
  "balances": [
    {
      "asset_type": "native",
      "balance": 999999980
    }
  ]
}
```

## errors

- The [standard errors](../learn/errors.md#Standard_Errors).
