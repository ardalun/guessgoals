import Api from 'api/api';

export default class AddressApi {
  static getAddress(code) {
    return Api.backendSend({
      method: 'get',
      url: `/addresses/${code}`
    });
  }
}