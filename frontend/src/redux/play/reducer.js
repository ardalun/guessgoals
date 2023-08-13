import * as actionTypes from './action-types';
import { deepWrite } from 'lib/helpers';

const initialStore = {
  wizardOpened:      false,
  steps:             [1, 2, 5],
  currentStepIndex:  0,
  match:             null,
  play:              {
    winner_team:  null,
    home_score:   0,
    away_score:   0,
    home_scorers: {},
    away_scorers: {},
    team_goals:   []
  },
  matchLoading:      false,
  placeBetLoading:   false,
  nextButtonEnabled: false,
  showSuccess:       false,
  showHowToPlay:     false
};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.DEEP_STORE: {
      return deepWrite(
        state,
        action.payload.path,
        action.payload.value
      );
    }
    case actionTypes.SET_WINNER: {
      return {
        ...state,
        steps: action.payload.value !== 'draw' ? [1, 2, 3, 5] : [1, 2, 5],
        play: {
          ...state.play,
          winner_team: action.payload.value,
          home_score: action.payload.value === 'home' ? 1 : 0,
          away_score: action.payload.value === 'away' ? 1 : 0,
          home_scorers: [],
          away_scorers: [],
          team_goals: action.payload.value === 'home' ? ['home'] : action.payload.value === 'away' ? ['away'] : []
        },
        nextButtonEnabled: true
      };
    }
    case actionTypes.CHANGE_TEAM_SCORE: {
      let newHomeScore = state.play.home_score + (action.payload.team === 'home' ? action.payload.delta : 0);
      let newAwayScore = state.play.away_score + (action.payload.team === 'away' ? action.payload.delta : 0);
      
      const homeWinViolated = state.play.winner_team === 'home' && newHomeScore <= newAwayScore;
      const awayWinViolated = state.play.winner_team === 'away' && newHomeScore >= newAwayScore; 
      const drawViolated = state.play.winner_team === 'draw' && newHomeScore !== newAwayScore;
      
      if (homeWinViolated) {
        newHomeScore = action.payload.team === 'home' ? newHomeScore : newAwayScore + 1;
        newAwayScore = action.payload.team === 'home' ? newHomeScore - 1 : newAwayScore;
      }

      if (awayWinViolated) {
        newHomeScore = action.payload.team === 'home' ? newHomeScore : newAwayScore - 1;
        newAwayScore = action.payload.team === 'home' ? newHomeScore + 1 : newAwayScore;
      }

      if (drawViolated) {
        newHomeScore = action.payload.team === 'home' ? newHomeScore : newAwayScore;
        newAwayScore = action.payload.team === 'home' ? newHomeScore : newAwayScore;
      }

      const changeAllowed = newHomeScore > -1 && newAwayScore > -1 && newHomeScore <= 14 && newAwayScore <= 14;
      newHomeScore = changeAllowed ? newHomeScore : state.play.home_score;
      newAwayScore = changeAllowed ? newAwayScore : state.play.away_score;
      const threeSteps = newHomeScore === 0 && newAwayScore === 0;
      const fourSteps = newHomeScore === 0 || newAwayScore === 0;
      return {
        ...state,
        steps: threeSteps ? [1, 2, 5] : fourSteps ? [1, 2, 3, 5] : [1, 2, 3, 4, 5],
        play: {
          ...state.play,
          home_score: newHomeScore,
          away_score: newAwayScore,
          home_scorers: {},
          away_scorers: {},
          team_goals:   Array(newHomeScore).fill('home').concat(Array(newAwayScore).fill('away'))
        }
      };
    }
    case actionTypes.CHANGE_HOME_SCORERS: {
      let predictedHomeGoals = Object.values(state.play.home_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      let predictedAwayGoals = Object.values(state.play.away_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      const currentScorer = state.play.home_scorers[action.payload.player.id];
      const currentGoals  = (currentScorer && currentScorer.goals) || 0;
      const newGoals      = currentGoals + action.payload.delta;
      if (predictedHomeGoals + action.payload.delta > state.play.home_score || newGoals < 0) return state;

      const totalGoals = predictedHomeGoals + predictedAwayGoals + action.payload.delta;
      return {
        ...state,
        nextButtonEnabled: totalGoals === state.play.home_score + state.play.away_score,
        play: {
          ...state.play,
          home_scorers: {
            ...state.play.home_scorers,
            [action.payload.player.id]: {
              player: action.payload.player,
              goals: newGoals
            }
          }
        }
      };
    }
    case actionTypes.CHANGE_AWAY_SCORERS: {
      const predictedHomeGoals = Object.values(state.play.home_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      const predictedAwayGoals = Object.values(state.play.away_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      const currentScorer = state.play.away_scorers[action.payload.player.id];
      const currentGoals  = (currentScorer && currentScorer.goals) || 0;
      const newGoals      = currentGoals + action.payload.delta;
      if (predictedAwayGoals + action.payload.delta > state.play.away_score || newGoals < 0) return state;
      
      const totalGoals = predictedHomeGoals + predictedAwayGoals + action.payload.delta;
      return {
        ...state,
        nextButtonEnabled: totalGoals === state.play.home_score + state.play.away_score,
        play: {
          ...state.play,
          away_scorers: {
            ...state.play.away_scorers,
            [action.payload.player.id]: {
              player: action.payload.player,
              goals: newGoals
            }
          }
        }
      }
    }
    case actionTypes.GO_NEXT: {
      const predictedHomeGoals = Object.values(state.play.home_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      const predictedAwayGoals = Object.values(state.play.away_scorers).map(item => item.goals).reduce((a, b) => a + b, 0);
      const nextStepIndex = state.currentStepIndex + 1;
      const nextStep = state.steps[nextStepIndex];
      let nextButtonEnabled = true;
      if (nextStep === 3 && predictedHomeGoals + predictedAwayGoals !== state.play.home_score + state.play.away_score) {
        nextButtonEnabled = false;
      }
      return {
        ...state,
        currentStepIndex: nextStepIndex,
        nextButtonEnabled: nextButtonEnabled
      }
    }
    case actionTypes.GO_BACK: {
      const nextStepIndex = state.currentStepIndex - 1;
      return {
        ...state,
        currentStepIndex: nextStepIndex,
        nextButtonEnabled: true
      }
    }
    case actionTypes.OPEN_HOW_TO_PLAY: {
      return {
        ...state,
        wizardOpened: true,
        showHowToPlay: true
      }
    }
    case actionTypes.CANCEL_PLAY: {
      return initialStore;
    }
    default: return state;
  }
};

export default reducer;