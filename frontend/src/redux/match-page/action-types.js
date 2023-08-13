const mkKey = (key) => { return 'MATCH_PAGE::' + key; };

export const SET_LOADING            = mkKey('SET_LOADING');
export const STORE_MATCH            = mkKey('STORE_MATCH');
export const STORE_PLAYS            = mkKey('STORE_PLAYS');
export const STORE_CURRENT_PAGE     = mkKey('STORE_CURRENT_PAGE');
export const STORE_RECORDS_PER_PAGE = mkKey('STORE_RECORDS_PER_PAGE');
export const STORE_TOTAL_RECORDS    = mkKey('STORE_TOTAL_RECORDS');