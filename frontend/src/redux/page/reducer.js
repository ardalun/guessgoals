import * as actionTypes from './action-types';

const initialStore = {
  title: null,
  description: null,
  pathName: null,
  query: {}
};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.SET_TITLE: {
      return {
        ...state,
        title: action.payload.value
      }
    }
    case actionTypes.SET_DESCRIPTION: {
      return {
        ...state,
        description: action.payload.value
      }
    }
    case actionTypes.SET_PATH_NAME: {
      return {
        ...state,
        pathName: action.payload.value
      }
    }
    case actionTypes.SET_QUERY: {
      return {
        ...state,
        query: action.payload.value
      }
    }
    default: return state;
  }
};

export default reducer;