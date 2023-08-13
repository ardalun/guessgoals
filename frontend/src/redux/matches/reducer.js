import * as actionTypes from './action-types';
import { deepWrite } from 'lib/helpers';

const initialStore = {
  index: {}
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
    case actionTypes.STORE_PLAY: {
      const { play } = action.payload;
      return {
        ...state,
        index: {
          ...state.index,
          [play.match_id]: {
            ...state.index[play.match_id],
            play: play
          }
        }
      }
    }
    default: return state;
  }
};

export default reducer;


