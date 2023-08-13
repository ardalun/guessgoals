import Api from 'api/api';

export default class LeagueApi {
  static getLeagues() {
    return Api.backendSend({
      method: 'get',
      url: '/leagues'
    });
  }
}