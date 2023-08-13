import * as actionTypes from './action-types';

const initialStore = {
  loading: false,
  notifs: [],
};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.STORE_NOTIFS: {
      return {
        ...state,
        notifs: action.payload.boardNotifs
      };
    }
    case actionTypes.SET_LOADING: {
      return {
        ...state,
        loading: action.payload.value
      };
    }
    default: return state;
  }
};

export default reducer;