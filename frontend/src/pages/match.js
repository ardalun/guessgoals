import React from 'react';
import styled from 'styled-components';
import Screen from 'lib/screen';
import { deepRead } from 'lib/helpers';
import { connect } from 'react-redux';
import MainLayout from 'layouts/MainLayout';
import Box from 'components/Box';
import Play from 'components/Play';
import Heading from 'components/Heading';
import { setTitle, setDescription } from 'redux/page';
import { getMatch, getMatchPlays } from 'redux/match-page';
import Pagination from 'components/Pagination';
import { convertToTimeZone } from 'date-fns-timezone';
import { format } from 'date-fns';
import EmptyState from 'components/EmptyState';
import NotStartedYet from 'assets/images/not-started-yet.svg';

const PageBanner = styled.div`
  background: #1E262D;
  padding: 1.5rem 2.5rem;
  margin-top: 1.5rem;

  ${Screen.max('lg')} {
    margin: 0;
    padding: 1.5rem 1rem;
    border-bottom: 1px solid #40474E;
  }
`;

const Bettor = styled.div`
  border-top: 2px solid #FF7E00;
  padding: 0.5rem 1rem;
  font-family: 'Source Sans Pro';
  font-size: 0.875rem;
  background: #1E262D;
`;

const LogoAndStatsRow = styled.div`
  display: flex;
`;

const LogoImage = styled.img`
  height: 100px;
  width: auto;
`;

const StatsCol = styled.div`
  text-align: center;
  flex-grow: 1;
`;

const TeamNameAndGoalsRow = styled.div`
  margin-top: 1rem;
  display: flex;
`;

const HomeCol = styled.div`
  width: 50%;
  text-align: left;
`;

const AwayCol = styled.div`
  width: 50%;
  text-align: right;
`;

const Badge = styled.div`
  display: inline-block;
  color: white;
  font-size: 0.75rem;
  padding: 0 0.35rem;
  border-radius: 0.1rem;
  background: #F64747;
`;

class MatchPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Football Highlights - GuessGoals'));
    await reduxStore.dispatch(setDescription('Watch latest football highlights.'));
    await reduxStore.dispatch(getMatch(query.match_id));
    try {
      await reduxStore.dispatch(getMatchPlays(query.match_id))
    } catch (error) {
      res.redirect('/my-bets')
    }
    return {};
  }

  isFinalized = () => {
    return this.props.match.pool_status === 'finalized';
  }

  isLive = () => {
    const { status, pool_status } = this.props.match;
    return pool_status === 'pending_outcome' || status === 'in_progress';
  }
  render() {
    return (
      <MainLayout>
        { this.renderPageBanner() }
        { this.renderPagination() }
        { this.renderPlays() }
        { this.renderEmptyState() }
      </MainLayout>
    );
  }

  renderPageBanner = () => {
    const { 
      league,
      home_team,
      away_team,
      home_score,
      away_score,
      home_goals,
      away_goals,
      starts_at,
      stadium
    } = this.props.match;
    
    const dateObj    = convertToTimeZone(new Date(starts_at), {timeZone: this.props.timezone});
    const dateString = format(dateObj, 'YYYY-MM-DD h:mm A');
    return (
      <PageBanner>
        <LogoAndStatsRow>
          <LogoImage src={home_team.logo_url} />
          <StatsCol>
            <Box gray body3>{league.name}</Box>
            <Box gray body3>{stadium}</Box>
            <Box gray body3>{dateString}</Box>
            { this.isLive() ? <Badge gray>Live</Badge> : null }
            { this.isFinalized() ? <Heading as="span" sizeLike="h1" center>{home_score} : {away_score}</Heading> : null }
          </StatsCol>
          <LogoImage src={away_team.logo_url} />
        </LogoAndStatsRow>
        <TeamNameAndGoalsRow>
          <HomeCol>
            <Box mb={0.5}><Heading as="span" sizeLike="h2">{home_team.name}</Heading></Box>
            {
              this.isFinalized() && home_goals.map((goal, index) => {
                return (
                  <Box gray body3 key={`home_goal_${index}`}>{goal.player_name} {goal.minute}'</Box>
                );
              })
            }
          </HomeCol>
          <AwayCol>
            <Box mb={0.5}><Heading as="span" sizeLike="h2" right>{away_team.name}</Heading></Box>
            {
              this.isFinalized() && away_goals.map((goal, index) => {
                return (
                  <Box gray body3 key={`away_goal_${index}`}>{goal.player_name} {goal.minute}'</Box>
                );
              })
            }
          </AwayCol>
        </TeamNameAndGoalsRow>
      </PageBanner>
    );
  }

  renderPagination = () => {
    const { currentPage, recordsPerPage, totalRecords, plays, loading } = this.props;

    return (
      <Pagination
        title="Placed Bets"
        currentPage={currentPage}
        currentPageRecords={plays.length}
        recordsPerPage={recordsPerPage}
        totalRecords={totalRecords}
        loading={loading}
        getRecordsOfPage={(page) => this.props.getMatchPlays(this.props.match.id, page)}
      />
    );
  }

  renderPlays = () => {
    const { plays, match } = this.props;

    return (
      <Box>
        {
          plays.map(play => {
            return (
              <Box key={`play_${play.id}`}>
                <Bettor>
                  { play.rank ? `Ranked ${play.rank} - ` : '' } @{play.username}
                </Bettor>
                <Play 
                  play={play} 
                  homeTeamName={match.home_team.name} 
                  awayTeamName={match.away_team.name}
                />
              </Box>
            );
          })
        }
      </Box>
    );
  }

  renderEmptyState = () => {
    return (
      <EmptyState
        marginTop={5}
        show={this.props.match.pool_status === 'betting_open'}
        illustrationUrl={NotStartedYet}
        title="Game Not Started Yet"
        message="We reveal all the bets here once the match starts."
      />
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  match:          deepRead(store, 'matchPage.match'),
  plays:          deepRead(store, 'matchPage.plays'),
  currentPage:    deepRead(store, 'matchPage.currentPage'),
  recordsPerPage: deepRead(store, 'matchPage.recordsPerPage'),
  totalRecords:   deepRead(store, 'matchPage.totalRecords'),
  loading:        deepRead(store, 'matchPage.loading'),
  timezone:       deepRead(store, 'session.timezone')
});
const mapDispatchToProps = {
  getMatchPlays
};

export default connect(mapStateToProps, mapDispatchToProps)(MatchPage);