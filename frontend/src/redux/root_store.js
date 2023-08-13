import { createStore, combineReducers, applyMiddleware } from 'redux';
import { composeWithDevTools } from 'redux-devtools-extension';
import thunk from 'redux-thunk';
import formReducer from 'redux/form/reducer';
import sessionReducer from 'redux/session/reducer';
import pageReducer from 'redux/page/reducer';
import navigationReducer from 'redux/navigation/reducer';
import matchesReducer from 'redux/matches/reducer';
import playReducer from 'redux/play/reducer';
import notifBoardReducer from 'redux/notif-board/reducer';
import notifPageReducer from 'redux/notif-page/reducer';
import walletPageReducer from 'redux/wallet-page/reducer';
import myBetsPageReducer from 'redux/my-bets-page/reducer';
import matchPageReducer from 'redux/match-page/reducer';

const rootReducer = combineReducers({
  page:       pageReducer,
  session:    sessionReducer,
  navigation: navigationReducer,
  matches:    matchesReducer,
  play:       playReducer,
  form:       formReducer,
  notifBoard: notifBoardReducer,
  notifPage:  notifPageReducer,
  walletPage: walletPageReducer,
  myBetsPage: myBetsPageReducer,
  matchPage:  matchPageReducer
});

export function initializeStore (initialState) {
  return createStore(
    rootReducer,
    initialState,
    composeWithDevTools(applyMiddleware(thunk))
  )
}
