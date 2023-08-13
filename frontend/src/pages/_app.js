import App, { Container } from 'next/app';
import React from 'react';
import withReduxStore from '../lib/with-redux-store';
import { Provider } from 'react-redux';
import { createSession, setTimezone } from 'redux/session';
import { getLeagues } from 'redux/navigation';
import { setQuery, setPathName } from 'redux/page';
import * as Sentry from '@sentry/browser';
import Api from 'api/api';
import { subscribeToWalletUpdates, subscribeToNotifs } from 'lib/cable';
import NProgress from 'nprogress';
import Router from 'next/router';

Router.events.on('routeChangeStart', url => {
  NProgress.start();
  NProgress.set(0.3);
})
Router.events.on('routeChangeComplete', () => NProgress.done())
Router.events.on('routeChangeError', () => NProgress.done())

class MyApp extends App {
  static async getInitialProps({ Component, ctx }) {
    const isServer = typeof ctx.req !== 'undefined';
    if (isServer) {
      await this.serverGetInitialProps(ctx);
    } else {
      await this.browserGetInitialProps(ctx);
    }

    let pageProps = {};
    if (Component.getInitialProps) {
      pageProps = await Component.getInitialProps(ctx)
    }
    return { pageProps };
  }

  static async serverGetInitialProps(ctx) {
    const { req, res, reduxStore, pathname, query } = ctx;
    Api.setReduxStore(reduxStore);
    await reduxStore.dispatch(setTimezone(req.cookies.timezone || 'UTC'));
    if (req.cookies && req.cookies.id_token) {
      res.clearCookie('redirect_path');
      await reduxStore.dispatch(createSession(req.cookies.id_token)).catch(_error => {});
    }
    await reduxStore.dispatch(setQuery(query));
    await reduxStore.dispatch(setPathName(pathname));
    await reduxStore.dispatch(getLeagues()).catch(_error => {});
  }

  // This method is only called, when frontend route is changed
  // It WILL NOT be called on the first page load
  // If you want to run a code on first page load use componentDidMount
  static async browserGetInitialProps(ctx) {
    const { reduxStore, pathname, query } = ctx;
    await reduxStore.dispatch(setQuery(query));
    await reduxStore.dispatch(setPathName(pathname));
  }

  // This method is only called on browser after the first page load
  componentDidMount() {
    if (process.env.NODE_ENV === 'production') {
      Sentry.init({dsn: "https://715a62a0b605466e95ccc50e152af8b0@sentry.io/1477833"});
    }
    subscribeToWalletUpdates();
    subscribeToNotifs();
  }

  render () {
    const { Component, pageProps, reduxStore } = this.props;
    return (
      <Container>
        <Provider store={reduxStore}>
          <Component {...pageProps} />
        </Provider>
      </Container>
    )
  }
}

export default withReduxStore(MyApp);