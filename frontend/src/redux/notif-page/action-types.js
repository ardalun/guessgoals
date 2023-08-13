const mkKey = (key) => { return 'NOTIF_PAGE::' + key; };

export const STORE_NOTIFS           = mkKey('STORE_NOTIFS');
export const SET_LOADING            = mkKey('SET_LOADING');
export const STORE_CURRENT_PAGE     = mkKey('STORE_CURRENT_PAGE');
export const STORE_RECORDS_PER_PAGE = mkKey('STORE_RECORDS_PER_PAGE');
export const STORE_TOTAL_RECORDS    = mkKey('STORE_TOTAL_RECORDS');