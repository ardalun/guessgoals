import axios from 'axios';
import { deepRead } from 'lib/helpers';
import getConfig from 'next/config';

const { publicRuntimeConfig } = getConfig();

if (typeof window !== 'undefined') {
  window.active_ajax = 0;
  axios.interceptors.request.use(function (config) {
    window.active_ajax += 1;
    return config;
  }, function (error) {
    window.active_ajax += 1;
    return Promise.reject(error);
  });
  
  axios.interceptors.response.use(function (response) {
    window.active_ajax -= 1;
    return response;
  }, function (error) {
    window.active_ajax -= 1;
    return Promise.reject(error);
  });
}

class Api {
  constructor () {
    if (!Api.instance) { Api.instance = this; }
    return Api.instance;
  }

  setReduxStore(reduxStore) {
    this.reduxStore = reduxStore;
  }

  getReduxStore() {
    return this.reduxStore || window.__NEXT_REDUX_STORE__;
  }

  getIdToken(){
    return deepRead(this.getReduxStore().getState(), 'session.idToken');
  }

  getTimezone(){
    return deepRead(this.getReduxStore().getState(), 'session.timezone');
  }
  
  backendSend(options) {
    return axios({
      method: options.method,
      url: `${publicRuntimeConfig.backendRoute}${options.url}`,
      data: options.data,
      headers: {
        ...options.headers,
        Authorization: this.getIdToken(),
        Timezone: this.getTimezone()
      }
    });    
  }

  frontendSend(options) {
    return axios({
      method: options.method,
      url: `${publicRuntimeConfig.frontendRoute}${options.url}`,
      data: options.data,
      headers: {
        ...options.headers,
        Authorization: this.getIdToken(),
        Timezone: this.getTimezone()
      }
    });    
  }
}

const instance = new Api();

export default instance;