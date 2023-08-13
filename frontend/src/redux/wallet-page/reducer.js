import * as actionTypes from './action-types';

const initialStore = {
  loading: false,
  ledgerEntries: [],
  currentPage: null,
  recordsPerPage: null,
  totalRecords: null
};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.STORE_LEDGER_ENTRIES: {
      return {
        ...state,
        ledgerEntries: action.payload.ledgerEntries
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
    case actionTypes.STORE_NEW_LEDGER_ENTRY: {
      if (state.currentPage === 1) {
        return {
          ...state,
          ledgerEntries: [action.payload.ledgerEntry, ...state.ledgerEntries]
        };
      } else {
        return state;
      }
    }
    default: return state;
  }
};

export default reducer;