import Api from 'api/api';

export default class NotifApi {
  
  static getNotifs(page) {
    return Api.backendSend({
      method: 'get',
      url: `/notifs?page=${page}`
    });
  }

  static getBoardNotifs() {
    return Api.backendSend({
      method: 'get',
      url: '/board_notifs'
    });
  }

  static markNotifsAsSeen(notifIds) {
    return Api.backendSend({
      method: 'put',
      url: '/notifs/mark_as_seen',
      data: {
        ids: notifIds
      }
    });
  }
}