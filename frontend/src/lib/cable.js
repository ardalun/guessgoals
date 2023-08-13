import { deepRead } from 'lib/helpers';
import { storeWallet, updateUnseenNotifs } from 'redux/session';
import Notif from 'components/Notif';
import { notifyComponent } from 'lib/notify';
import getConfig from 'next/config';

const { publicRuntimeConfig } = getConfig();

export const subscribeToWalletUpdates = () => {
  if (typeof window === 'undefined') return;

  const store      = window.__NEXT_REDUX_STORE__;
  const cableRoute = deepRead(store.getState(), 'routes.cable');
  const idToken    = deepRead(store.getState(), 'session.idToken');
  if (idToken) {
    import('actioncable').then(actioncable => {
      const cable = actioncable.createConsumer(`${publicRuntimeConfig.cableRoute}?id_token=${idToken}`);
      cable.subscriptions.create(
        { channel: 'WalletsChannel' },
        {
          received: (data) => {
            store.dispatch(storeWallet(data));
          }
        }
      );
    });
  }
}

export const subscribeToNotifs = () => {
  if (typeof window === 'undefined') return;

  const store      = window.__NEXT_REDUX_STORE__;
  const cableRoute = deepRead(store.getState(), 'routes.cable');
  const idToken    = deepRead(store.getState(), 'session.idToken');
  if (idToken) {
    import('actioncable').then(actioncable => {
      const cable = actioncable.createConsumer(`${publicRuntimeConfig.cableRoute}?id_token=${idToken}`);
      cable.subscriptions.create(
        { channel: 'NotifsChannel' },
        {
          received: (data) => {
            store.dispatch(updateUnseenNotifs(1));
            notifyComponent(<Notif notif={data} forNotify />, 10)
          }
        }
      );
    });
  }
}