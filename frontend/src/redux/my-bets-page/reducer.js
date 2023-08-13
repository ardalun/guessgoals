import * as actionTypes from './action-types';

const initialStore = {
  loading: false,
  matches: {},
  currentPage: null,
  recordsPerPage: null,
  totalRecords: null
};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.STORE_MATCHES: {
      return {
        ...state,
        matches: action.payload.matches
      };
    }
    case actionTypes.SET_LOADING: {
      return {
        ...state,
        loading: action.payload.value
      };
    }
    case actionTypes.STORE_CURRENT_PAGE: {
      return {
        ...state,
        currentPage: action.payload.value
      }
    }
    case actionTypes.STORE_RECORDS_PER_PAGE: {
      return {
        ...state,
        recordsPerPage: action.payload.value
      }
    }
    case actionTypes.STORE_TOTAL_RECORDS: {
      return {
        ...state,
        totalRecords: action.payload.value
      }
    }
    default: return state;
  }
};

export default reducer;