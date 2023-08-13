import * as actionTypes from './action-types';
import { deepWrite } from 'lib/helpers';

const initialStore = {
  user: null,
  timezone: 'UTC',
  idToken: null
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
    case actionTypes.STORE_WALLET: {
      return {
        ...state,
        user: {
          ...state.user,
          wallet: action.payload.wallet
        }
      }
    }
    case actionTypes.STORE_SESSION: {
      return {
        ...state,
        user: action.payload.user,
        idToken: action.payload.idToken
      };
    }
    case actionTypes.CLEAR_SESSION: {
      return {
        ...state,
        user: null,
        idToken: null
      };
    }
    case actionTypes.UPDATE_UNSEEN_NOTIFS: {
      return {
        ...state,
        user: {
          ...state.user,
          unseen_notifs: Math.max(0, state.user.unseen_notifs + action.payload.delta)
        }
      }
    }
    default: return state;
  }
};

export default reducer;