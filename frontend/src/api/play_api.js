import Api from 'api/api';

export default class PlayApi {
  static createPlay(matchId, playForm) {
    return Api.backendSend({
      method: 'post',
      url: `/matches/${matchId}/plays`,
      data: playForm
    });
  }

  static getMatchPlays(matchId, page) {
    return Api.backendSend({
      method: 'get',
      url: `/matches/${matchId}/plays?page=${page}`
    });
  }
}