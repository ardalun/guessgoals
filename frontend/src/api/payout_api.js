import Api from 'api/api';

export default class PayoutApi {

  static createPayout(address) {
    return Api.backendSend({
      method: 'post',
      url: '/payouts',
      data: {
        address: address
      }
    });
  }
}