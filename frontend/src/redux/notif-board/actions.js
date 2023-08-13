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

const storeNotifs = (boardNotifs) => {
  return {
    type: actionTypes.STORE_NOTIFS,
    payload: { boardNotifs }
  }
}

export const getBoardNotifs = () => dispatch => {
  dispatch(setLoading(true));
  return NotifApi.getBoardNotifs()
    .then(resp => {
      dispatch(storeNotifs(resp.data.notifs));
      dispatch(setLoading(false));
    })
    .catch(error => {
      dispatch(setLoading(false));
      handleBackendError(error);
    });
}

export const markUnseensAsSeen = () => (dispatch, getState) => {
  const store          = getState();
  let unseenNotifIds = deepRead(store, 'notifBoard.notifs')
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