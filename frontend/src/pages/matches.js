import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import { getMatches } from 'redux/matches';
import { formatMatches } from 'lib/formatter';
import Banner from 'components/Banner';
import ResourceSelector from 'components/ResourceSelector';
import MatchDate from 'components/MatchDate';
import Match from 'components/Match';
import PlayWizard from 'components/PlayWizard';
import EmptyState from 'components/EmptyState';
import NoMatches from 'assets/images/not-started-yet.svg';
class MatchesPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Play Football Lottery with Bitcoin - GuessGoals'));
    await reduxStore.dispatch(setDescription('Play football lottery where your ticket is your prediction. Win significantly more than regular betting with significantly less risk than regular lottery.'));
    await reduxStore.dispatch(getMatches(query.league_handle));
    return {};
  }

  getMatchDates = () => {
    return formatMatches(this.props.matches, this.props.timezone);
  }

  render() {
    return (
      <MainLayout>
        <Banner />
        <ResourceSelector />
        <PlayWizard />
        {
          this.getMatchDates().map((matchDate, index) => {
            return this.renderMatchDate(matchDate, index);
          })
        }
        { this.renderEmptyState() }
      </MainLayout>
    );
  }

  renderMatchDate = (matchDate, index) => {
    return (
      <Fragment key={`match_date_${index}`}>
        <MatchDate dateString={matchDate.dateString}/>
        {matchDate.matches.map(match => <Match key={`match_${match.id}`} match={match} />)}
      </Fragment>
    );
  }

  renderEmptyState = () => {
    return (
      <EmptyState
        marginTop={10}
        show={this.props.matches.length === 0}
        illustrationUrl={NoMatches}
        title="No Matches Available for Betting"
        message="Upcoming matches will be listed here."
      />
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  matches: Object.values(deepRead(store, 'matches.index')) || [],
  timezone: deepRead(store, 'session.timezone')
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(MatchesPage);