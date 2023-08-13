import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Router from 'next/router';
import styled, { css } from 'styled-components';
import Heading from 'components/Heading';
import Play from 'components/Play';
import Box from 'components/Box';
import Icon from 'components/Icon';
import Screen from 'lib/screen';
import { openPlayWizard, openHowToPlay } from 'redux/play';
import { handleBackendError } from 'lib/errorman';

const MatchContainer = styled.div`
  border-top: 1px solid #40474E;
  padding: 1rem;
  position: relative;
  cursor: pointer;
  :hover {
    background: #1E262D;
  }
`;

const RowInMatchContainer = styled.div`
  display: flex;
`;

const PlayWrapper = styled.div`
  background: #1E262D;
  width: 100%;
  margin-top: 1rem;
  border: 1px dashed #40474E;
`;

const LeftColumn = styled.div`
  display: inline-flex;
  align-items: center;
`;

const RightColumn = styled.div`
  flex-grow: 1;
  display: inline-flex;
  justify-content: flex-end;
  align-items: center;
  font-size: 0.875rem;
`;

const Logo = styled.img`
  width: 1.75rem;
  margin-bottom: 0.25rem;
`;

const StatsTable = styled.table`
  line-height: 1rem;

  td {
    padding: 0 0.5rem;
  }
  ${props => props.mobile && css`
    td {
      padding: 0 1rem 0 0;
    }
    ${Screen.min('xs')} {
      display: none;
    }
  `}

  ${props => props.nonMobile && css`
    ${Screen.max('xs')} {
      display: none;
    }
  `}
`;

const Unit = styled.span`
  font-size: 0.5625rem;
  margin-left: 0.2rem;
`;

class Match extends React.Component {
  constructor(props) {
    super(props);
    this.state = { 
      showWizard: false
    };
  }

  handleMatchClicked = () => {
    const { user, match } = this.props;
    if (user && match.play) {
      Router.push(`/match?match_id=${match.id}`, `/football/${match.league.handle}/${match.id}`);
    } else if (user && !match.play) {
      this.props.openPlayWizard(match.id)
        .catch(error => {
          handleBackendError(error);
        });
    } else {
      this.props.openHowToPlay();
    }
  }

  playIsPlaced = () => {
    return this.props.match && this.props.match.play;
  }

  render() {
    const { match, showDate } = this.props;
    return (
      <MatchContainer onClick={this.handleMatchClicked} played={!!match.play}>
        <RowInMatchContainer>
          <LeftColumn>
            <Box mr={0.5}>
              <Logo src={match.home_team.logo_url} />
              <Heading as="span" sizeLike="h5" center>{match.home_team.code}</Heading>
            </Box>
            <Box mr={1}>
              <Logo src={match.away_team.logo_url} />
              <Heading as="span" sizeLike="h5" center>{match.away_team.code}</Heading>
            </Box>
            <Box>
              <Box body3 gray>{showDate ? `${match.shortDateString} - ` : null} {match.timeString}</Box>
              <Box body2>{match.home_team.name} - {match.away_team.name}</Box>
              <Box body3 gray>Football <Icon name="im-arrow-right" size={0.6} mr={0.25} ml={0.25} /> {match.league.name}</Box>
              <StatsTable mobile>
                { this.renderMatchStats() }
              </StatsTable>
            </Box>
          </LeftColumn>
          <RightColumn>
            <StatsTable nonMobile>
              { this.renderMatchStats() }
            </StatsTable>
            <Box ml={1}><Icon name="im-arrow-right" mr={0.5} /></Box>
          </RightColumn>
        </RowInMatchContainer>
        { this.renderPlay() }
      </MatchContainer>
    );
  }

  renderMatchStats = () => {
    const { match } = this.props;
    if (match.pool_status === 'finalized') return;
    const viewRealStats = match.play && match.play.payment_status === 'accepted';
    return (
      <tbody>
        <tr>
          <td><Box body3 gray>Prize Pool</Box></td>
          <td>
            <Heading as="span" sizeLike="h4" orange inline>
              {viewRealStats ? match.real_prize : match.estimated_prize}
            </Heading>
            <Unit>BTC</Unit>
          </td>
          <td><Heading as="span" sizeLike="h5" gray inline>≈ $20</Heading></td>
        </tr>
        <tr>
          <td><Box body3 gray>Ticket Fee</Box></td>
          <td>
            <Heading as="span" sizeLike="h4" orange inline>
              {match.ticket_fee}
            </Heading>
            <Unit>BTC</Unit>
          </td>
          <td><Heading as="span" sizeLike="h5" gray inline>≈ $10</Heading></td>
        </tr>
        <tr>
          <td><Box body3 gray>Your Chance</Box></td>
          <td>
            <Heading as="span" sizeLike="h4" orange inline>
              {viewRealStats ? match.real_chance : match.estimated_chance}
            </Heading><Unit>%</Unit>
          </td>
        </tr>
      </tbody>
    )
  }

  renderPlay = () => {
    if (!this.playIsPlaced()) return;

    return (
      <RowInMatchContainer>
        <PlayWrapper>
          <Play 
            play={this.props.match.play} 
            homeTeamName={this.props.match.home_team.name}
            awayTeamName={this.props.match.away_team.name}
          />
        </PlayWrapper>
      </RowInMatchContainer>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  user: deepRead(store, 'session.user')
});
const mapDispatchToProps = {
  openPlayWizard,
  openHowToPlay
};

export default connect(mapStateToProps, mapDispatchToProps)(Match);