package core

import (
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestTransactionsQueries(t *testing.T) {
	tt := test.Start(t).Scenario("base")
	defer tt.Finish()
	q := &Q{tt.CoreRepo()}

	// Test TransactionsByLedger
	var txs []core.Transaction
	err := q.TransactionsByLedger(&txs, 2)

	if tt.Assert.NoError(err) {
		tt.Assert.Len(txs, 3)
	}

	// Test TransactionByHash
	var tx core.Transaction
	err = q.TransactionByHash(&tx, "cebb875a00ff6e1383aef0fd251a76f22c1f9ab2a2dffcb077855736ade2659a")

	if tt.Assert.NoError(err) {
		tt.Assert.Equal(int32(3), tx.LedgerSequence)
	}
}
