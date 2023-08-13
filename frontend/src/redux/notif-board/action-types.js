const mkKey = (key) => { return 'NOTIF_BOARD::' + key; };

export const STORE_NOTIFS = mkKey('STORE_NOTIFS');
export const SET_LOADING  = mkKey('SET_LOADING');