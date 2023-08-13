import * as actionTypes from './action-types';
import LedgerEntryApi from 'api/ledger_entry_api';
import { handleBackendError } from 'lib/errorman';

const setLoading = (value) => {
  return {
    type: actionTypes.SET_LOADING,
    payload: { value }
  }
}

const storeLedgerEntries = (ledgerEntries) => {
  return {
    type: actionTypes.STORE_LEDGER_ENTRIES,
    payload: { ledgerEntries }
  }
}

const storeCurrentPage = (value) => {
  return {
    type: actionTypes.STORE_CURRENT_PAGE,
    payload: { value }
  }
}

const storeRecordsPerPage = (value) => {
  return {
    type: actionTypes.STORE_RECORDS_PER_PAGE,
    payload: { value }
  }
}

const storeTotalRecords = (value) => {
  return {
    type: actionTypes.STORE_TOTAL_RECORDS,
    payload: { value }
  }
}

export const storeNewLedgerEntry = (ledgerEntry) => {
  return {
    type: actionTypes.STORE_NEW_LEDGER_ENTRY,
    payload: { ledgerEntry }
  }
}

export const getLedgerEntries = (page = 1) => dispatch => {
  dispatch(setLoading(true));
  return LedgerEntryApi.getLedgerEntries(page)
    .then(resp => {
      dispatch(storeLedgerEntries(resp.data.ledger_entries));
      dispatch(storeCurrentPage(resp.data.current_page));
      dispatch(storeRecordsPerPage(resp.data.records_per_page));
      dispatch(storeTotalRecords(resp.data.total_records));
      dispatch(setLoading(false));
    })
    .catch(error => {
      dispatch(setLoading(false));
      handleBackendError(error);
    });
}