package horizon

import (
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/db2/history"
	"github.com/stellar/horizon/render/hal"
	"github.com/stellar/horizon/render/sse"
	"github.com/stellar/horizon/resource"
)

// This file contains the actions:
//
// LedgerIndexAction: pages of ledgers
// LedgerShowAction: single ledger by sequence

// LedgerIndexAction renders a page of ledger resources, identified by
// a normal page query.
type LedgerIndexAction struct {
	Action
	Query   db.LedgerPageQuery
	Records []history.Ledger
	Page    hal.Page
}

// JSON is a method for actions.JSON
func (action *LedgerIndexAction) JSON() {
	action.Do(
		action.LoadQuery,
		action.LoadRecords,
		action.LoadPage,
		func() { hal.Render(action.W, action.Page) },
	)
}

// SSE is a method for actions.SSE
func (action *LedgerIndexAction) SSE(stream sse.Stream) {
	action.Setup(action.LoadQuery)
	action.Do(
		action.LoadRecords,
		func() {
			stream.SetLimit(int(action.Query.Limit))
			records := action.Records[stream.SentCount():]

			for _, record := range records {
				var res resource.Ledger
				res.Populate(action.Ctx, record)
				stream.Send(sse.Event{ID: res.PagingToken(), Data: res})
			}
		},
	)
}

// LoadQuery sets action.Query from the request params
func (action *LedgerIndexAction) LoadQuery() {
	action.ValidateCursorAsDefault()
	action.Query = db.LedgerPageQuery{
		SqlQuery:  action.App.HorizonQuery(),
		PageQuery: action.GetPageQuery(),
	}
}

// LoadRecords populates action.Records
func (action *LedgerIndexAction) LoadRecords() {
	action.Err = db.Select(action.Ctx, action.Query, &action.Records)
}

// LoadPage populates action.Page
func (action *LedgerIndexAction) LoadPage() {
	for _, record := range action.Records {
		var res resource.Ledger
		res.Populate(action.Ctx, record)
		action.Page.Add(res)
	}

	action.Page.BaseURL = action.BaseURL()
	action.Page.BasePath = action.Path()
	action.Page.Limit = action.Query.Limit
	action.Page.Cursor = action.Query.Cursor
	action.Page.Order = action.Query.Order
	action.Page.PopulateLinks()
}

// LedgerShowAction renders a ledger found by its sequence number.
type LedgerShowAction struct {
	Action
	Sequence int32
	Record   history.Ledger
}

// JSON is a method for actions.JSON
func (action *LedgerShowAction) JSON() {
	action.Do(
		action.loadParams,
		action.loadRecord,
		func() {
			var res resource.Ledger
			res.Populate(action.Ctx, action.Record)
			hal.Render(action.W, res)
		},
	)
}

func (action *LedgerShowAction) loadParams() {
	action.Sequence = action.GetInt32("id")
}

func (action *LedgerShowAction) loadRecord() {
	action.Err = action.HistoryQ().
		LedgerBySequence(&action.Record, action.Sequence)
}
