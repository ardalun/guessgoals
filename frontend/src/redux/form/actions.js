import * as actionTypes from './action-types';

export const setForm = (formName, data) => {
  return {
    type: actionTypes.SET_FORM,
    payload: {
      formName,
      data
    }
  };
};

export const setField = (formName, fieldName, value) => {
  return {
    type: actionTypes.SET_FIELD,
    payload: {
      formName,
      fieldName,
      value
    }
  }; 
}

export const setErrors = (formName, errors) => {
  let formattedErrors = {};
  Object.keys(errors).forEach(key => {
    formattedErrors[key] = errors[key][0];
  });
  return {
    type: actionTypes.SET_ERRORS,
    payload: {
      formName,
      errors: formattedErrors
    }
  }
}