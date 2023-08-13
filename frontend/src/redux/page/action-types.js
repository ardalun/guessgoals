const mkKey = (key) => { return 'PAGE::' + key; };

export const SET_TITLE       = mkKey('SET_TITLE');
export const SET_DESCRIPTION = mkKey('SET_DESCRIPTION');
export const SET_PATH_NAME   = mkKey('SET_PATH_NAME');
export const SET_QUERY       = mkKey('SET_QUERY');