import * as actionTypes from './action-types';
import NotifApi from 'api/notif_api';
import { deepRead } from 'lib/helpers';
import { updateUnseenNotifs } from 'redux/session';
import { handleBackendError } from 'lib/errorman';

const setLoading = (value) => {
  return {
    type: actionTypes.SET_LOADING,
    payload: { value }
  }
}

const storeNotifs = (notifs) => {
  return {
    type: actionTypes.STORE_NOTIFS,
    payload: { notifs }
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

export const getNotifs = (page = 1) => dispatch => {
  dispatch(setLoading(true));
  return NotifApi.getNotifs(page)
    .then(resp => {
      dispatch(storeNotifs(resp.data.notifs));
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

export const markUnseensAsSeen = () => (dispatch, getState) => {
  const store          = getState();
  let unseenNotifIds = deepRead(store, 'notifPage.notifs')
    .filter(item => !item.seen)
    .map(item => item.id);
  
  if (unseenNotifIds.length == 0)
    return;
  
  return NotifApi.markNotifsAsSeen(unseenNotifIds)
    .then(resp => {
      dispatch(updateUnseenNotifs(-unseenNotifIds.length));
    })
    .catch(error => {
      handleBackendError(error);
    })
}