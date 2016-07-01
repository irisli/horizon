// Package ingest contains the ingestion system for horizon.  This system takes
// data produced by the connected stellar-core database, transforms it and
// inserts it into the horizon database.
package ingest

import (
	"time"

	sq "github.com/lann/squirrel"
	"github.com/stellar/horizon/cache"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/db2"
)

const (
	// CurrentVersion reflects the latest version of the ingestion
	// algorithm. As rows are ingested into the horizon database, this version is
	// used to tag them.  In the future, any breaking changes introduced by a
	// developer should be accompanied by an increase in this value.
	//
	// Scripts, that have yet to be ported to this codebase can then be leveraged
	// to re-ingest old data with the new algorithm, providing a seamless
	// transition when the ingested data's structure changes.
	CurrentVersion = 5
)

// Cursor iterates through a stellar core database's ledgers
type Cursor struct {
	// FirstLedger is the beginning of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	FirstLedger int32
	// LastLedger is the end of the range of ledgers (inclusive) that will
	// attempt to be ingested in this session.
	LastLedger int32
	// DB is the stellar-core db that data is ingested from.
	DB *db2.Repo

	// Err is the error that caused this iteration to fail, if any.
	Err error

	lg   int32
	tx   int
	op   int
	data *LedgerBundle
}

// EffectIngestion is a helper struct to smooth the ingestion of effects.  this
// struct will track what the correct operation to use and order to use when
// adding effects into an ingestion.
type EffectIngestion struct {
	Dest        *Ingestion
	OperationID int64
	added       int
}

// LedgerBundle represents a single ledger's worth of novelty created by one
// ledger close
type LedgerBundle struct {
	Sequence        int32
	Header          core.LedgerHeader
	TransactionFees []core.TransactionFee
	Transactions    []core.Transaction
}

// Ingester represents the data ingestion subsystem of horizon.
type Ingester struct {
	// HorizonDB is the connection to the horizon database that ingested data will
	// be written to.
	HorizonDB *db2.Repo

	// CoreDB is the stellar-core db that data is ingested from.
	CoreDB *db2.Repo

	// Network is the passphrase for the network being imported
	Network string

	tick            *time.Ticker
	historySequence int32
	coreSequence    int32
}

type Ingestion struct {
	// DB is the sql repo to be used for writing any rows into the horizon
	// database.
	DB *db2.Repo

	ledgers                  sq.InsertBuilder
	transactions             sq.InsertBuilder
	transaction_participants sq.InsertBuilder
	operations               sq.InsertBuilder
	operation_participants   sq.InsertBuilder
	effects                  sq.InsertBuilder
	accounts                 sq.InsertBuilder
}

// Session represents a single attempt at ingesting data into the history
// database.
type Session struct {
	Cursor    *Cursor
	Ingestion *Ingestion
	// Network is the passphrase for the network being imported
	Network string

	// ClearExisting causes the session to clear existing data from the horizon db
	// when the session is run.
	ClearExisting bool

	//
	// Results fields
	//

	// Err is the error that caused this session to fail, if any.
	Err error

	// Ingested is the number of ledgers that were successfully ingested during
	// this session.
	Ingested int

	accountCache *cache.HistoryAccount
}

// New initializes the ingester, causing it to begin polling the stellar-core
// database for now ledgers and ingesting data into the horizon database.
func New(network string, core, horizon *db2.Repo) *Ingester {
	i := &Ingester{
		Network:   network,
		HorizonDB: horizon,
		CoreDB:    core,
	}
	i.tick = time.NewTicker(1 * time.Second)
	return i
}

// NewSession initialize a new ingestion session, from `first` to `last` using
// `i`.
func NewSession(first, last int32, i *Ingester) *Session {
	hdb := i.HorizonDB.Clone()

	return &Session{
		Ingestion: &Ingestion{
			DB: hdb,
		},
		Cursor: &Cursor{
			FirstLedger: first,
			LastLedger:  last,
			DB:          i.CoreDB,
		},
		Network:      i.Network,
		accountCache: cache.NewHistoryAccount(hdb),
	}
}

// RunOnce runs a single ingestion session
func RunOnce(network string, core, horizon *db2.Repo) (*Session, error) {
	i := New(network, core, horizon)
	err := i.updateLedgerState()
	if err != nil {
		return nil, err
	}

	is := NewSession(
		i.historySequence+1,
		i.coreSequence,
		i,
	)

	is.Run()

	return is, is.Err
}
