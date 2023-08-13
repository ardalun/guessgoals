import MatchApi from 'api/match_api';
import * as actionTypes from './action-types';

const deepStore = (path, value) => {
  return {
    type: actionTypes.DEEP_STORE,
    payload: {
      path,
      value
    }
  };
};

export const storePlay = (play) => {
  return {
    type: actionTypes.STORE_PLAY,
    payload: { play }
  }
}
 
export const getMatches = (leagueHandle) => dispatch => {
  return MatchApi.getMatches(leagueHandle)
    .then(resp => {
      dispatch(deepStore('index', resp.data.matches))
    })
    .catch(error => {
      throw error;
    });
}