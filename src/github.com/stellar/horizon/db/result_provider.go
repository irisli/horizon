package db

import (
	"bytes"
	"encoding/base64"
	"github.com/jmoiron/sqlx"
	"github.com/stellar/go-stellar-base/xdr"
	"github.com/stellar/horizon/db/records/core"
	"github.com/stellar/horizon/txsub"
	"golang.org/x/net/context"
)

type ResultProvider struct {
	Core    *sqlx.DB
	History *sqlx.DB
}

func (rp *ResultProvider) ResultByHash(ctx context.Context, hash string) txsub.Result {

	// query history database
	var hr TransactionRecord
	hq := TransactionByHashQuery{
		SqlQuery: SqlQuery{rp.History},
		Hash:     hash,
	}

	err := Get(ctx, hq, &hr)
	if err == nil {
		return txResultFromHistory(hr)
	}

	if err != ErrNoResults {
		return txsub.Result{Err: err}
	}

	// query core database
	var cr core.Transaction
	cq := CoreTransactionByHashQuery{
		SqlQuery: SqlQuery{rp.Core},
		Hash:     hash,
	}

	err = Get(ctx, cq, &cr)
	if err == nil {
		return txResultFromCore(cr)
	}

	if err != ErrNoResults {
		return txsub.Result{Err: err}
	}

	// if no result was found in either db, return ErrNoResults
	return txsub.Result{Err: txsub.ErrNoResults}
}

func txResultFromHistory(tx TransactionRecord) txsub.Result {
	return txsub.Result{
		Hash:           tx.TransactionHash,
		LedgerSequence: tx.LedgerSequence,
		EnvelopeXDR:    tx.TxEnvelope,
		ResultXDR:      tx.TxResult,
		ResultMetaXDR:  tx.TxMeta,
	}
}

func txResultFromCore(tx core.Transaction) txsub.Result {
	//decode the result xdr, extract TransactionResult
	var trp xdr.TransactionResultPair
	err := xdr.SafeUnmarshalBase64(tx.ResultXDR, &trp)

	if err != nil {
		return txsub.Result{Err: err}
	}

	tr := trp.Result

	// re-encode result to base64
	var raw bytes.Buffer
	_, err = xdr.Marshal(&raw, tr)

	if err != nil {
		return txsub.Result{Err: err}
	}

	trx := base64.StdEncoding.EncodeToString(raw.Bytes())

	// if result is success, send a normal resposne
	if tr.Result.Code == xdr.TransactionResultCodeTxSuccess {
		return txsub.Result{
			Hash:           tx.TransactionHash,
			LedgerSequence: tx.LedgerSequence,
			EnvelopeXDR:    tx.EnvelopeXDR,
			ResultXDR:      trx,
			ResultMetaXDR:  tx.ResultMetaXDR,
		}
	}

	// if failed, produce a FailedTransactionError
	return txsub.Result{
		Err: &txsub.FailedTransactionError{
			ResultXDR: trx,
		},
		Hash:           tx.TransactionHash,
		LedgerSequence: tx.LedgerSequence,
		EnvelopeXDR:    tx.EnvelopeXDR,
		ResultXDR:      trx,
		ResultMetaXDR:  tx.ResultMetaXDR,
	}
}
