import ReactOnRails from 'react-on-rails';

import Login from '../admin-app/pages/Login';
import Dashboard from '../admin-app/pages/Dashboard';
import Payouts from '../admin-app/pages/Payouts';

import Stat from '../admin-app/components/Stat';
import Wallet from '../admin-app/components/Wallet';
import Navbar from '../admin-app/components/Navbar';
import EmptyState from '../admin-app/components/EmptyState';
import BadgesBar from '../admin-app/components/BadgesBar';

import 'bootstrap/dist/css/bootstrap.min.css';

ReactOnRails.register({
  Login,
  Dashboard,
  Stat,
  Wallet,
  Navbar,
  Payouts,
  EmptyState,
  BadgesBar
});
