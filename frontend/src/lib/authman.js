import { deepRead } from 'lib/helpers';
import CookieJar from 'lib/cookie_jar';
import Router from 'next/router';
import { deleteSession } from 'redux/session';

export const requireLogin = (ctx) => {
  const {req, res, reduxStore, asPath} = ctx;
  const user = deepRead(reduxStore.getState(), 'session.user');
  if (user === null) {
    const isBrowser = typeof req === 'undefined';
    if (isBrowser) {
      CookieJar.setDocumentCookie('redirect_path', asPath, 1);
      Router.push('/auth/login', '/login');
    } else {
      res.cookie('redirect_path', req.path);
      res.redirect('/login');
    }
  }
};

export const ensureLoggedOut = (ctx) => {
  const {req, res, reduxStore} = ctx;
  const user = deepRead(reduxStore.getState(), 'session.user');
  if (user !== null) {
    reduxStore.dispatch(deleteSession());
    const isBrowser = typeof req === 'undefined';
    if (isBrowser) {
      CookieJar.deleteDocumentCookie('id_token');
    } else {
      res.clearCookie('id_token');
    }
  }
};