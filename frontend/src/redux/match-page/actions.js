import * as actionTypes from './action-types';
import MatchApi from 'api/match_api';
import PlayApi from 'api/play_api';
import { handleBackendError } from 'lib/errorman';

const setLoading = (value) => {
  return {
    type: actionTypes.SET_LOADING,
    payload: { value }
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

const storeMatch = (match) => {
  return {
    type: actionTypes.STORE_MATCH,
    payload: { match }
  }
}

const storePlays = (plays) => {
  return {
    type: actionTypes.STORE_PLAYS,
    payload: { plays }
  }
}

export const getMatch = (matchId) => dispatch => {
  dispatch(setLoading(true));
  return MatchApi.getMatch(matchId)
    .then(resp => {
      dispatch(storeMatch(resp.data.match));
      dispatch(setLoading(false));
    })
    .catch(error => {
      dispatch(setLoading(false));
      handleBackendError(error);
    });
}

export const getMatchPlays = (matchId, page = 1) => dispatch => {
  dispatch(setLoading(true));
  return PlayApi.getMatchPlays(matchId, page)
    .then(resp => {
      dispatch(storePlays(resp.data.plays));
      dispatch(storeCurrentPage(resp.data.current_page));
      dispatch(storeRecordsPerPage(resp.data.records_per_page));
      dispatch(storeTotalRecords(resp.data.total_records));
      dispatch(setLoading(false));
    })
    .catch(error => {
      dispatch(setLoading(false));
      handleBackendError(error);
      throw error;
    });
}