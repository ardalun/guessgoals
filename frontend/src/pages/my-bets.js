import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import { getPlayedMatches } from 'redux/my-bets-page';
import { formatMatches } from 'lib/formatter';
import Box from 'components/Box';
import Match from 'components/Match';
import Pagination from 'components/Pagination';
import NoBetsYet from 'assets/images/no-plays-yet.svg';
import { requireLogin } from 'lib/authman';
import EmptyState from 'components/EmptyState';

class MyBetsPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    requireLogin(ctx);
    await reduxStore.dispatch(setTitle('Play Football Lottery with Bitcoin - GuessGoals'));
    await reduxStore.dispatch(setDescription('Your ticket is your prediction'));
    await reduxStore.dispatch(getPlayedMatches());
    return {};
  }

  getMatchDates = () => {
    return formatMatches(this.props.matches, this.props.timezone, false);
  }

  render() {
    return (
      <MainLayout>
        { this.renderPagination() }
        { this.renderMyBets() }
        { this.renderEmptyState() }
      </MainLayout>
    );
  }

  renderPagination = () => {
    const { currentPage, recordsPerPage, totalRecords, matches, loading } = this.props;

    return (
      <Pagination
        title="My bets"
        currentPage={currentPage}
        currentPageRecords={matches.length}
        recordsPerPage={recordsPerPage}
        totalRecords={totalRecords}
        loading={loading}
        getRecordsOfPage={this.props.getPlayedMatches}
      />
    );
  }

  renderMyBets = () => {
    return (
      <div>
        {
          this.getMatchDates().map((matchDate, index) => {
            return (
              <Fragment key={`match_date_${index}`}>
                {matchDate.matches.map(match => <Match key={`match_${match.id}`} match={match} showDate />)}
              </Fragment>
            );
          })
        }
      </div>
    );
  }

  renderEmptyState = () => {
    return (
      <EmptyState
        marginTop={10}
        show={this.props.matches.length === 0}
        illustrationUrl={NoBetsYet}
        title="No Bets Yet"
        message="Your bets will be listed here."
      />
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  matches:        Object.values(deepRead(store, 'myBetsPage.matches')) || [],
  timezone:       deepRead(store, 'session.timezone'),
  currentPage:    deepRead(store, 'myBetsPage.currentPage'),
  recordsPerPage: deepRead(store, 'myBetsPage.recordsPerPage'),
  totalRecords:   deepRead(store, 'myBetsPage.totalRecords'),
  loading:        deepRead(store, 'myBetsPage.loading')
});
const mapDispatchToProps = {
  getPlayedMatches
};

export default connect(mapStateToProps, mapDispatchToProps)(MyBetsPage);