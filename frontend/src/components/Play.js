import React from 'react';
import styled from 'styled-components';
import Box from 'components/Box';
import Screen from 'lib/screen';

const PlayContainer = styled.div`
  width: 100%;
  padding: 1.5rem;
  display: flex;

  ${Screen.max('md')} {
    flex-direction: column;
    flex-flow: row wrap;
    padding: 1rem;
  }
`;

const PlayCol = styled.div`
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  ${Screen.max('md')} {
    width: 50%;
  }
`;

class Play extends React.Component {
  constructor(props) {
    super(props);
  }

  getNumOfLevels = () => {
    const { home_score, away_score } = this.props.play;

    if (home_score > 0 && away_score > 0) {
      return 4;
    } else if (home_score == 0 && away_score == 0) {
      return 2;
    } else {
      return 3;
    }
  }

  getWinnerName = () => {
    const { homeTeamName, awayTeamName } = this.props;
    const { winner_team } = this.props.play;

    if (winner_team === 'draw') {
      return 'Draw';
    } else if (winner_team === 'home') {
      return `${homeTeamName} wins`;
    } else {
      return `${awayTeamName} wins`;
    }
  }

  render() {
    return (
      <PlayContainer>
        { this.renderLevel1() }
        { this.renderLevel2() }
        { this.renderLevel3() }
        { this.renderLevel4() }
      </PlayContainer>
    );
  }

  renderLevel1 = () => {
    const { rank, winner_team_is_correct, goals_off } = this.props.play;

    const levelPassed = winner_team_is_correct || rank === 1;
    const wonHere     = rank === 1 && goals_off === null;

    return (
      <PlayCol>
        <Box body3 gray>LEVEL 1 - Outcome</Box>
        <Box body3 mb={rank ? 0 : 0.5}>{ this.getWinnerName() }</Box>
        {
          !rank ? null : (
            <Box body3 mb={0.5} red={!levelPassed} green={levelPassed}>
              { winner_team_is_correct ? 'Exact' : 'Wrong' } { wonHere ? ' - Won' : null }
            </Box>
          )
        }
      </PlayCol>
    );
  }

  renderLevel2 = () => {
    const { homeTeamName, awayTeamName } = this.props;
    const { home_score, away_score, rank, goals_off, correct_scorers } = this.props.play;

    const levelScored = !!rank && goals_off !== null;
    const levelPassed = correct_scorers !== null || rank === 1;
    const wonHere     = rank === 1 && correct_scorers === null;

    return (
      <PlayCol>
        <Box body3 gray>LEVEL 2 - Team Scores</Box>
        <Box body3 mb={levelScored ? 0 : 0.5}>{homeTeamName} {home_score} - {away_score} {awayTeamName}</Box>
        {
          !levelScored ? null : (
            <Box body3 mb={0.5} red={!levelPassed} green={levelPassed}>
              { goals_off === 0 ? 'Exact' : `${goals_off} goals off` } { wonHere ? ' - Won' : null }
            </Box>
          )
        }
      </PlayCol>
    );
  }
  renderLevel3 = () => {
    const { home_scorers, away_scorers, rank, correct_scorers, correct_team_goals } = this.props.play;
    let betSummary = <Box body3>N/A</Box>;

    if (home_scorers.length > 0 || away_scorers.length > 0) {
      let homeScorers = home_scorers.map((item, i) => {
        return <Box key={`home_scorer_${i}`} body3>{ item.name }</Box>;
      });
      let awayScorers = away_scorers.map((item, i) => {
        return <Box key={`away_scorer_${i}`} body3>{ item.name }</Box>;
      });
      betSummary = [...homeScorers, ...awayScorers];
    }

    const levelScored = !!rank && correct_scorers !== null;
    const levelPassed = correct_team_goals !== null || rank === 1;
    const wonHere     = rank === 1 && correct_team_goals === null;

    return (
      <PlayCol>
        <Box body3 gray>LEVEL 3 - Scorers</Box>
        <Box mb={levelScored ? 0 : 0.5}>{ betSummary }</Box>
        {
          !levelScored ? null : (
            <Box body3 mb={0.5} red={!levelPassed} green={levelPassed}>
              { correct_scorers } Correct { wonHere ? ' - Won' : null }
            </Box>
          )
        }
      </PlayCol>
    );
  }

  renderLevel4 = () => {
    const { homeTeamName, awayTeamName } = this.props;
    const { team_goals, rank, correct_team_goals, away_score, home_score } = this.props.play;
    
    let betSummary = <Box body3>N/A</Box>;

    if (home_score > 0 && away_score > 0) {
      betSummary = team_goals.map((team, i) => {
        return <Box key={`team_goal_${i}`} body3>{`${i + 1}. ${ team === 'home' ? homeTeamName : awayTeamName }`}</Box>;
      });
    }

    const levelScored = !!rank && correct_team_goals !== null;
    const levelPassed = rank === 1;
    const wonHere     = rank === 1;

    return (
      <PlayCol>
        <Box body3 gray>LEVEL 4 - Goals Order</Box>
        <Box mb={levelScored ? 0 : 0.5}>{ betSummary }</Box>
        {
          !levelScored ? null : (
            <Box body3 mb={0.5} red={!levelPassed} green={levelPassed}>
              { correct_team_goals } Correct { wonHere ? ' - Won' : null }
            </Box>
          )
        }
      </PlayCol>
    );
  }
}

export default Play;