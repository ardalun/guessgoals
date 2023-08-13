import * as actionTypes from './action-types';
import { deepRead } from 'lib/helpers';

const initialStore = {};

const reducer = (state = initialStore, action) => {
  switch (action.type) {
    case actionTypes.SET_FORM: {
      return {
        ...state,
        [action.payload.formName]: {
          data: action.payload.data,
          errors: {},
          isDirty: false
        }
      }
    }
    case actionTypes.SET_FIELD: {
      const oldData = deepRead(state, `${action.payload.formName}.data`);
      const oldErrors = deepRead(state, `${action.payload.formName}.errors`);
      return {
        ...state,
        [action.payload.formName]: {
          data: {
            ...oldData,
            [action.payload.fieldName]: action.payload.value
          },
          errors: {
            ...oldErrors,
            [action.payload.fieldName]: null
          },
          isDirty: false
        }
      }
    }
    case actionTypes.SET_ERRORS: {
      const oldForm = deepRead(state, action.payload.formName);
      return {
        ...state,
        [action.payload.formName]: {
          ...oldForm,
          errors: action.payload.errors,
          isDirty: false
        }
      }
    }
    default: return state;
  }
};

export default reducer;


