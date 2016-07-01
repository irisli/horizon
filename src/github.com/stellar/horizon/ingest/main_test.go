package ingest

import (
	"github.com/stellar/go-stellar-base/network"
	"github.com/stellar/horizon/db"
	"github.com/stellar/horizon/test"
	"testing"
)

func TestIngestAccountMerge(t *testing.T) {
	tt := test.Start(t).ScenarioWithoutHorizon("account_merge")
	defer tt.Finish()

	err := ingest(tt)
	tt.Require.NoError(err)
}

func ingest(tt *test.T) error {
	return RunOnce(
		network.TestNetworkPassphrase,
		db.SqlQuery{tt.CoreDB},
		db.SqlQuery{tt.HorizonDB},
	)
}
