import * as actionTypes from './action-types';
import MatchApi from 'api/match_api';
import { handleBackendError } from 'lib/errorman';

const setLoading = (value) => {
  return {
    type: actionTypes.SET_LOADING,
    payload: { value }
  }
}

const storeMatches = (matches) => {
  return {
    type: actionTypes.STORE_MATCHES,
    payload: { matches }
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

export const getPlayedMatches = (page = 1) => dispatch => {
  dispatch(setLoading(true));
  return MatchApi.getPlayedMatches(page)
    .then(resp => {
      dispatch(storeMatches(resp.data.matches));
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