import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Heading from 'components/Heading';
import Box from 'components/Box';
import TeamSticker from './TeamSticker';
import { setWinnerTeam } from 'redux/play';
import drawIcon from 'assets/images/draw.svg';

class Step1 extends React.Component {
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
      winner_team,
      setWinnerTeam
    } = this.props;

    const { animationsEnabled } = this.state;

    return (
      <div>
        <Heading as="span" sizeLike="h4" gray animated={animationsEnabled && 200}>LEVEL 1</Heading>
        <Heading as="span" sizeLike="h1" animated={animationsEnabled && 300}>Which team wins?</Heading>
        <Box animated={animationsEnabled && 400} mt={0.25}>
          Correct answers knock out incorrect ones. You will be a winner if you survive all levels or if you end up the only player left in earlier levels.
        </Box>
        <Box pt={3} flex>
          <TeamSticker 
            name={homeTeam && homeTeam.name}
            logoUrl={homeTeam && homeTeam.logo_url}
            selected={winner_team === 'home'}
            onClick={() => setWinnerTeam('home')}
            animated={300}
          />
          <TeamSticker 
            name="Draw" 
            logoUrl={drawIcon}
            selected={winner_team === 'draw'}
            onClick={() => setWinnerTeam('draw')}
            animated={400} 
          />
          <TeamSticker
            name={awayTeam && awayTeam.name}
            logoUrl={awayTeam && awayTeam.logo_url}
            selected={winner_team === 'away'}
            onClick={() => setWinnerTeam('away')}
            animated={500} 
          />
        </Box>
      </div>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  homeTeam:    deepRead(store, 'play.match.home_team'),
  awayTeam:    deepRead(store, 'play.match.away_team'),
  winner_team: deepRead(store, 'play.play.winner_team')
});
const mapDispatchToProps = {
  setWinnerTeam
};

export default connect(mapStateToProps, mapDispatchToProps)(Step1);