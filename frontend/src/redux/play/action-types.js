const mkKey = (key) => { return 'PLAY::' + key; };

export const DEEP_STORE          = mkKey('DEEP_STORE');
export const SET_WINNER          = mkKey('SET_WINNER');
export const GO_BACK             = mkKey('GO_BACK');
export const GO_NEXT             = mkKey('GO_NEXT');
export const CANCEL_PLAY         = mkKey('CANCEL_PLAY');
export const CHANGE_TEAM_SCORE   = mkKey('CHANGE_TEAM_SCORE');
export const CHANGE_HOME_SCORERS = mkKey('CHANGE_HOME_SCORERS');
export const CHANGE_AWAY_SCORERS = mkKey('CHANGE_AWAY_SCORERS');
export const OPEN_HOW_TO_PLAY    = mkKey('OPEN_HOW_TO_PLAY')