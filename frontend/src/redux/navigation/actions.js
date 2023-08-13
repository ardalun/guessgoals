import * as actionTypes from './action-types';
import LeagueApi from 'api/league_api';

const deepStore = (path, value) => {
  return {
    type: actionTypes.DEEP_STORE,
    payload: {
      path,
      value
    }
  };
};

export const getLeagues = () => dispatch => {
  return LeagueApi.getLeagues()
    .then(resp => {
      dispatch(deepStore('leagues', resp.data.leagues))
    })
    .catch(error => {
      throw error;
    });
}