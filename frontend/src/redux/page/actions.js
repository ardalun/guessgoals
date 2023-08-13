import * as actionTypes from './action-types';

export const setTitle = (value) => {
  return {
    type: actionTypes.SET_TITLE,
    payload: { value }
  };
};

export const setDescription = (value) => {
  return {
    type: actionTypes.SET_DESCRIPTION,
    payload: { value }
  };
};

export const setPathName = (value) => {
  return {
    type: actionTypes.SET_PATH_NAME,
    payload: { value }
  };
}

export const setQuery = (value) => {
  return {
    type: actionTypes.SET_QUERY,
    payload: { value }
  };
}