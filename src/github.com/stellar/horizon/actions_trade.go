package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/resource"
)

// TradeIndexAction renders a page of effect resources, filtered to include
// only trades, identified by a normal page query and optionally filtered by an account
// or order book
type TradeIndexAction struct {
	Action
	Query   db.EffectPageQuery
	Records []history.Effect
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *TradeIndexAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() {
			hal.Render(action.W, action.Page)
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *TradeIndexAction) LoadQuery() {
	action.Query = db.EffectPageQuery{
		SqlQuery:  action.App.HorizonQuery(),
		PageQuery: action.GetPageQuery(),
		Filter:    &db.EffectTypeFilter{history.EffectTrade},
	}

	if address := action.GetString("account_id"); address != "" {
		action.Query.Filter = db.FilterAll(
			action.Query.Filter,
			&db.EffectAccountFilter{action.Query.SqlQuery, address},
		)
		return
	}

	// HACK: see if it looks like we're specifying an order book on params
	// try to load it if so
	if action.GetString("selling_asset_type") != "" {
		selling := action.GetAsset("selling_")
		buying := action.GetAsset("buying_")
		f := &db.EffectOrderBookFilter{}
		action.Do(
			func() { action.Err = selling.Extract(&f.SellingType, &f.SellingCode, &f.SellingIssuer) },
			func() { action.Err = buying.Extract(&f.BuyingType, &f.BuyingCode, &f.BuyingIssuer) },
		)

		action.Query.Filter = db.FilterAll(action.Query.Filter, f)
	}

}

// LoadRecords populates action.Records
func (action *TradeIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *TradeIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.Trade
		action.Err = res.Populate(action.Ctx, record)
		if action.Err != nil {
			return
		}
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}
