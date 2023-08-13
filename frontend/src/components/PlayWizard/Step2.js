import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Box from 'components/Box';
import TeamSticker from './TeamSticker';
import Heading from 'components/Heading';
import ScorePicker from './ScorePicker';
import { changeTeamScore } from 'redux/play';

class Step2 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      animationsEnabled: true
    }
  }

  componentDidMount() {
    this.animationTimer = setTimeout(() => {
      this.setState({ animationsEnabled: false });
    }, 1000);
  }

  componentWillUnmount() {
    clearTimeout(this.animationTimer);
  }

  render() {
    const { 
      homeTeam, 
      awayTeam, 
      homeScore,
      awayScore,
      changeTeamScore
    } = this.props;
    const { animationsEnabled } = this.state;

    return (
      <div>
        <Heading as="span" sizeLike="h4" gray animated={animationsEnabled && 200}>LEVEL 2</Heading>
        <Heading as="span" sizeLike="h1" animated={animationsEnabled && 300}>How many goals are scored?</Heading>
        <Box animated={animationsEnabled && 400} mt={0.25}>Players with the closest prediction will knock out the rest of players who made it to the level 2.</Box>
        <Box pt={3} flex>
          <TeamSticker 
            name={homeTeam && homeTeam.name}
            logoUrl={homeTeam && homeTeam.logo_url}
            animated={animationsEnabled && 300}
          />
          <ScorePicker 
            score={homeScore} 
            incrementScore={() => changeTeamScore('home', 1)} 
            decrementScore={() => changeTeamScore('home', -1)}
            animated={animationsEnabled && 400}
          />
          <ScorePicker 
            score={awayScore} 
            incrementScore={() => changeTeamScore('away', 1)} 
            decrementScore={() => changeTeamScore('away', -1)}
            animated={animationsEnabled && 500}
          />
          <TeamSticker
            name={awayTeam && awayTeam.name}
            logoUrl={awayTeam && awayTeam.logo_url}
            animated={animationsEnabled && 600} 
          />
        </Box>
      </div>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  homeTeam:  deepRead(store, 'play.match.home_team'),
  awayTeam:  deepRead(store, 'play.match.away_team'),
  homeScore: deepRead(store, 'play.play.home_score'),
  awayScore: deepRead(store, 'play.play.away_score')
});
const mapDispatchToProps = {
  changeTeamScore
};

export default connect(mapStateToProps, mapDispatchToProps)(Step2);