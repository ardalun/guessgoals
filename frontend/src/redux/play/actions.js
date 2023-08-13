import * as actionTypes from './action-types';
import { deepRead } from 'lib/helpers';
import MatchApi from 'api/match_api';
import PlayApi from 'api/play_api';
import { formatScorers } from 'lib/formatter';
import { handleBackendError } from 'lib/errorman';
import { storePlay } from 'redux/matches';

const deepStore = (path, value) => {
  return {
    type: actionTypes.DEEP_STORE,
    payload: {
      path,
      value
    }
  };
};

export const setWinnerTeam = (winnerTeam) => {
  return {
    type: actionTypes.SET_WINNER,
    payload: { value: winnerTeam }
  }
}

export const openHowToPlay = () => {
  return {
    type: actionTypes.OPEN_HOW_TO_PLAY
  }
}

export const openPlayWizard = (matchId) => (dispatch) => {
  dispatch(deepStore('matchLoading', true));
  dispatch(deepStore('wizardOpened', true));
  return MatchApi.getMatch(matchId)
    .then(resp => {
      dispatch(deepStore('matchLoading', false));
      dispatch(deepStore('match', resp.data.match));
    })
    .catch(error => {
      dispatch(deepStore('wizardOpened', false));
      dispatch(deepStore('matchLoading', false));
      handleBackendError(error);
      throw error;
    });
}

export const createPlay = () => (dispatch, getState) => {
  const store   = getState();
  const matchId = deepRead(store, 'play.match.id');
  let playForm  = { ...deepRead(store, 'play.play') };
  playForm.home_scorers = formatScorers(playForm.home_scorers);
  playForm.away_scorers = formatScorers(playForm.away_scorers);

  dispatch(deepStore('placeBetLoading', true));
  return PlayApi.createPlay(matchId, playForm)
    .then(resp => {
      dispatch(deepStore('placeBetLoading', false));
      dispatch(deepStore('showSuccess', true));
      dispatch(storePlay(resp.data.play));
    })
    .catch(error => {
      dispatch(deepStore('placeBetLoading', false));
      handleBackendError(error);
      throw error;
    });
}

export const cancelPlay = () => dispatch => {
  dispatch(deepStore('wizardOpened', false));
  setTimeout(() => dispatch({ type: actionTypes.CANCEL_PLAY }), 500);
}

export const goNext = () => {
  return {
    type: actionTypes.GO_NEXT
  };
}

export const goBack = () => {
  return {
    type: actionTypes.GO_BACK
  };
}

export const changeTeamScore = (team, delta) => {
  return {
    type: actionTypes.CHANGE_TEAM_SCORE,
    payload: { 
      team,
      delta 
    }
  }
}

export const changeHomeScorers = (player, delta) => {
  return {
    type: actionTypes.CHANGE_HOME_SCORERS,
    payload: { 
      player,
      delta 
    }
  }
}

export const changeAwayScorers = (player, delta) => {
  return {
    type: actionTypes.CHANGE_AWAY_SCORERS,
    payload: { 
      player,
      delta 
    }
  }
}

export const changeTeamGoals = (teamGoals) => {
  return deepStore('play.team_goals', teamGoals);
}