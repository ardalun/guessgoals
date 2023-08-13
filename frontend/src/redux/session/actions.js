import * as actionTypes from './action-types';
import AuthApi from 'api/auth_api';
import { handleBackendError } from 'lib/errorman';
import AddressApi from 'api/address_api';
import { deepRead } from 'lib/helpers';
import { notifyError, notifySuccess } from 'lib/notify';

const deepStore = (path, value) => {
  return {
    type: actionTypes.DEEP_STORE,
    payload: {
      path,
      value
    }
  };
};

const storeSession = (data) => {
  return {
    type: actionTypes.STORE_SESSION,
    payload: {
      user: data.user,
      idToken: data.id_token
    }
  };
};

export const storeWallet = (walletData) => {
  return {
    type: actionTypes.STORE_WALLET,
    payload: { wallet: walletData }
  };
};

export const updateUnseenNotifs = (delta) => {
  return { 
    type: actionTypes.UPDATE_UNSEEN_NOTIFS,
    payload: { delta }
  };
};

export const pullAddressUpdates = () => (dispatch, getState) => {
  const store       = getState();
  const addressCode = deepRead(store, 'session.user.wallet.address.code');
  AddressApi.getAddress(addressCode)
    .then(resp => {
      if (resp.data.updated) {
        dispatch(storeWallet(resp.data.wallet));
        notifySuccess('Wallet Updated', 'We found a new transaction on your wallet and updated your balance.', 10);
      } else {
        notifyError('No Updates Found', 'Sorry, we just looked and did not find any new transaction on your wallet. If you are sure that your transaction is pushed to the mempool, we will pick it up in the next 10 minutes and notify you via email.', 20);
      }
    })
    .catch(error => {
      handleBackendError(error);
      throw error;
    })
}

export const login = (formData) => dispatch => {
  return AuthApi.login(formData)
    .then(resp => {
      dispatch(storeSession(resp.data));
    })
    .catch(error => {
      throw error;
    });
};

export const createSession = (idToken) => dispatch => {
  return AuthApi.createSession(idToken)
    .then(resp => {
      dispatch(storeSession(resp.data));
    })
    .catch(error => {
      throw error;
    });
}

export const deleteSession = () => {
  return { type: actionTypes.CLEAR_SESSION };
}

export const setTimezone = (timezone) => {
  return deepStore('timezone', timezone);
}