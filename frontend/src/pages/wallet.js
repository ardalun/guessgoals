import React, { Fragment } from 'react';
import styled from 'styled-components';
import Screen from 'lib/screen';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import MainLayout from 'layouts/MainLayout';
import Box from 'components/Box';
import Button from 'components/Button';
import Heading from 'components/Heading';
import { setTitle, setDescription } from 'redux/page';
import { getLedgerEntries } from 'redux/wallet-page';
import { requireLogin } from 'lib/authman';
import LedgerEntry from 'components/LedgerEntry';
import PayoutDialog from 'components/PayoutDialog';
import NoTransactionsYet from 'assets/images/no-transactions-yet.svg';
import Pagination from 'components/Pagination';
import EmptyState from 'components/EmptyState';

const PageBanner = styled.div`
  display: flex;
  background: #1E262D;
  padding: 2.5rem;
  margin-top: 1.5rem;

  ${Screen.max('lg')} {
    margin: 0;
    padding: 2.5rem 1rem;
    border-bottom: 1px solid #40474E;
  }
`;

const InfoContainer = styled.div`
  flex-grow: 1;
`;

class WalletPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    requireLogin(ctx);
    await reduxStore.dispatch(setTitle('Wallet - GuessGoals'));
    await reduxStore.dispatch(setDescription('Review transaction history on your wallet and withdraw your prize'));
    await reduxStore.dispatch(getLedgerEntries());
    return {};
  }

  constructor(props) {
    super(props);
    this.state = {
      payoutDialogVisible: false
    }
  }

  openPayoutDialog = () => {
    this.setState({
      payoutDialogVisible: true
    });
  }

  closePayoutDialog = () => {
    this.setState({
      payoutDialogVisible: false
    });
  }

  render() {
    const { payoutDialogVisible } = this.state;
    return (
      <MainLayout>
        { this.renderPageBanner() }
        { this.renderPagination() }
        { this.renderLedgerEntries() }
        { this.renderEmptyState() }
        <PayoutDialog
          visible={payoutDialogVisible}
          closeDialog={this.closePayoutDialog}
        />
      </MainLayout>
    );
  }

  renderPageBanner = () => {
    const { walletTotal, walletUnconfirmed, walletUnlocked } = this.props;
    return (
      <PageBanner>
        <Box>
          <Heading as="span" sizeLike="h4" gray>BALANCE</Heading>
          <Heading as="span" sizeLike="h1">{walletTotal} BTC</Heading>
        </Box>
        <InfoContainer>
          <Box>
            <Heading as="span" sizeLike="h5" gray right>Pending Confirmation</Heading>
            <Heading as="span" sizeLike="h4" right>{walletUnconfirmed} BTC</Heading>
          </Box>
          <Box mt={1}>
            <Heading as="span" sizeLike="h5" gray right>Available For Payout</Heading>
            <Heading as="span" sizeLike="h4" right>{walletUnlocked} BTC</Heading>
          </Box>
          {
            walletUnlocked > 0 && <Box right mt={1}><Button onClick={this.openPayoutDialog}>Payout Now</Button></Box>
          }
        </InfoContainer>
      </PageBanner>
    );
  }

  renderPagination = () => {
    const { currentPage, recordsPerPage, totalRecords, ledgerEntries, loading } = this.props;

    return (
      <Pagination
        title="Transactions"
        currentPage={currentPage}
        currentPageRecords={ledgerEntries.length}
        recordsPerPage={recordsPerPage}
        totalRecords={totalRecords}
        loading={loading}
        getRecordsOfPage={this.props.getLedgerEntries}
      />
    );
  }

  renderLedgerEntries = () => {
    const { ledgerEntries, timezone } = this.props;
    if (ledgerEntries.length === 0) return;

    return (
      <div>
        {
          this.props.ledgerEntries.map(ledgerEntry => {
            return (
              <LedgerEntry 
                key={`ledger_entry_${ledgerEntry.id}`} 
                ledgerEntry={ledgerEntry}
                timezone={timezone}
              />
            );
          })
        }
      </div>
    );
  }

  renderEmptyState = () => {
    return (
      <EmptyState
        marginTop={5}
        show={this.props.ledgerEntries.length === 0}
        illustrationUrl={NoTransactionsYet}
        title="No Transactions Yet"
        message="Your transaction history will show up here."
      />
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  timezone:          deepRead(store, 'session.timezone'),
  walletTotal:       deepRead(store, 'session.user.wallet.total'),
  walletUnconfirmed: deepRead(store, 'session.user.wallet.unconfirmed'),
  walletUnlocked:    deepRead(store, 'session.user.wallet.unlocked'),
  ledgerEntries:     deepRead(store, 'walletPage.ledgerEntries'),
  currentPage:       deepRead(store, 'walletPage.currentPage'),
  recordsPerPage:    deepRead(store, 'walletPage.recordsPerPage'),
  totalRecords:      deepRead(store, 'walletPage.totalRecords'),
  loading:           deepRead(store, 'walletPage.loading')
});
const mapDispatchToProps = {
  getLedgerEntries
};

export default connect(mapStateToProps, mapDispatchToProps)(WalletPage);