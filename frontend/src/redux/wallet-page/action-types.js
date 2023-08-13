const mkKey = (key) => { return 'WALLET_PAGE::' + key; };

export const STORE_LEDGER_ENTRIES   = mkKey('STORE_LEDGER_ENTRIES');
export const SET_LOADING            = mkKey('SET_LOADING');
export const STORE_CURRENT_PAGE     = mkKey('STORE_CURRENT_PAGE');
export const STORE_RECORDS_PER_PAGE = mkKey('STORE_RECORDS_PER_PAGE');
export const STORE_TOTAL_RECORDS    = mkKey('STORE_TOTAL_RECORDS');
export const STORE_NEW_LEDGER_ENTRY = mkKey('STORE_NEW_LEDGER_ENTRY');