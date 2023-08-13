import Api from 'api/api';

export default class MatchApi {
  static getMatches(leagueHandle) {
    return Api.backendSend({
      method: 'get',
      url: `/leagues/${leagueHandle}/matches`
    });
  }

  static getMatch(matchId) {
    return Api.backendSend({
      method: 'get',
      url: `/matches/${matchId}`
    });
  }

  static getPlayedMatches(page) {
    return Api.backendSend({
      method: 'get',
      url: `/played_matches?page=${page}`
    });
  }
}