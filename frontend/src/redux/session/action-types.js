const mkKey = (key) => { return 'SESSION::' + key; };

export const DEEP_STORE              = mkKey('DEEP_STORE');
export const STORE_SESSION           = mkKey('STORE_SESSION');
export const CLEAR_SESSION           = mkKey('CLEAR_SESSION');
export const STORE_WALLET            = mkKey('STORE_WALLET');
export const SET_LISTENING_ON_WALLET = mkKey('SET_LISTENING_ON_WALLET');
export const UPDATE_UNSEEN_NOTIFS    = mkKey('UPDATE_UNSEEN_NOTIFS');