import * as actionTypes from './action-types';
import { deepWrite } from 'lib/helpers';

const initialStore = {
  leagues: {}
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
    default: return state;
  }
};

export default reducer;


