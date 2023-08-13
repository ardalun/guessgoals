import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled, { css, keyframes } from 'styled-components';
import { fadeInUp } from 'react-animations';
import Heading from 'components/Heading';
import Box from 'components/Box';
import Screen from 'lib/screen';
import Player from './Player';
import MobilePlayer from './MobilePlayer';
import Icon from 'components/Icon';
import { changeHomeScorers, changeAwayScorers } from 'redux/play';

import pitchUrl from 'assets/images/pitch.svg';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const NonMobileLineup = styled.div`
  ${Screen.max('md')} {
    display: none;
  }
`;

const Stadium = styled.div`
  display: flex;
`;

const Pitch = styled.div`
  background-image: ${props => `url(${props.bgSrc})`};
  height: 230px;
  width: 440px;
  background-repeat: no-repeat;
  background-size: contain;
  background-position-x: center;
  position: relative;
  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;

const Bench = styled.div`
  width: 100px;
  position: relative;
`;

const Scoreboard = styled.div`
  padding: 2rem 100px 0;
  display: flex;
  ${Screen.max('md')} {
    display: none;
  }

  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;

const HomeBoard = styled.div`
  width: 50%;
`;

const AwayBoard = styled.div`
  width: 50%;
  text-align: right;
`;

const MobileLineup = styled.div`
  margin: 0 -1rem;
  ${Screen.min('md')} {
    display: none;
  }
`;

const GoalIndicator = styled.div`
  display: inline-block;
  width: 1.5rem;
  height: 1.5rem;
  line-height: 1.5rem;
  text-align: center;
  margin-left: 0.125rem;
  margin-right: 0.125rem;
  border-radius: 100px;
  background: #1E262D;
  overflow: hidden;
  transition: background-color 500ms ease;
  font-family: 'Roboto Condensed';
  
  ${props => props.selected && css`
    background: #FF7E00;
    cursor: pointer;
    &:hover {
      background: #37424C;
    }
  `}
`;

class Step3 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      animationsEnabled: true,
      mouseOverIndicator: null
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
    const { homeTeamName, awayTeamName } = this.props;
    const { animationsEnabled } = this.state;
    return (
      <div>
        <Heading as="span" sizeLike="h4" gray animated={animationsEnabled && 200}>LEVEL 3</Heading>
        <Heading as="span" sizeLike="h1" animated={animationsEnabled && 300}>Who score the goals?</Heading>
        <Box animated={animationsEnabled && 400} mt={0.25}>Players with the most correct scorers picked will knock out other players who made it to the level 3.</Box>
        <NonMobileLineup>
          <Scoreboard animated={animationsEnabled && 400}>
            { this.renderHomeBoard() }
            { this.renderAwayBoard() }
          </Scoreboard>
          <Stadium>
            <Bench>{ this.renderHomeBench() }</Bench>
            <Pitch bgSrc={pitchUrl} animated={animationsEnabled && 400}>
              { this.renderHomePitch() }
              { this.renderAwayPitch() }
            </Pitch>
            <Bench>{ this.renderAwayBench() }</Bench>
          </Stadium>
        </NonMobileLineup>
        <MobileLineup ons>
          <Box pl={1} pt={2} mb={1}><Heading as="span" sizeLike="h2" animated={animationsEnabled && 400}>{homeTeamName}</Heading></Box>
          { this.renderHomeLineup() }
          <Box pl={1} pt={3} mb={1}><Heading as="span" sizeLike="h2" animated={animationsEnabled && 400}>{awayTeamName}</Heading></Box>
          { this.renderAwayLineup() }
        </MobileLineup>
      </div>
    );
  }

  renderHomeBoard = () => {
    const { mouseOverIndicator } = this.state;
    const { homeTeamName, homeScorers, homeScore } = this.props;
    const players = [];
    for (let key in homeScorers) {
      const scorer = homeScorers[key];
      for (let i = 0; i < scorer.goals; i++) {
        players.push(scorer.player);
      }
    }
    const unpredictedGoals = homeScore - players.length;
    for (let i = 0; i < unpredictedGoals; i++) {
      players.push(null);
    }
    return (
      <HomeBoard>
        <Box mb={0.25}><Heading as="span" sizeLike="h4" gray>{homeTeamName}</Heading></Box>
        {
          players.map((player, index) => {
            return (
              <GoalIndicator
                key={`home_goal_indicator_${index}`}
                onMouseEnter={() => this.setState({ mouseOverIndicator: player && `${index}:${player.id}` })}
                onMouseLeave={() => this.setState({ mouseOverIndicator: null })}
                onClick={player && (() => this.props.changeHomeScorers(player, -1))}
                selected={player}
              >
                {player && mouseOverIndicator !== `${index}:${player.id}` && player.number}
                {player && mouseOverIndicator === `${index}:${player.id}` && <Icon name="im-close" size={0.7} red/>}
              </GoalIndicator>
            );
          })
        }
      </HomeBoard>
    );
  }

  renderAwayBoard = () => {
    const { mouseOverIndicator } = this.state;
    const { awayTeamName, awayScorers, awayScore } = this.props;
    const players = [];
    for (let key in awayScorers) {
      const scorer = awayScorers[key];
      for (let i = 0; i < scorer.goals; i++) {
        players.push(scorer.player);
      }
    }
    const unpredictedGoals = awayScore - players.length;
    for (let i = 0; i < unpredictedGoals; i++) {
      players.push(null);
    }
    return (
      <AwayBoard>
        <Box mb={0.25}><Heading as="span" sizeLike="h4" gray right>{awayTeamName}</Heading></Box>
        {
          players.reverse().map((player, index) => {
            return (
              <GoalIndicator 
                key={`away_goal_indicator_${index}`}
                onMouseEnter={() => this.setState({ mouseOverIndicator: player && `${index}:${player.id}` })}
                onMouseLeave={() => this.setState({ mouseOverIndicator: null })}
                onClick={player && (() => this.props.changeAwayScorers(player, -1))}
                selected={player}
              >
                {player && mouseOverIndicator !== `${index}:${player.id}` && player.number}
                {player && mouseOverIndicator === `${index}:${player.id}` && <Icon name="im-close" size={0.7} red/>}
              </GoalIndicator>
            );
          })
        }
      </AwayBoard>
    );
  }

  renderHomeBench = () => {
    const { homeScorers, homeFormationPlayers } = this.props;
    const { animationsEnabled } = this.state;

    return homeFormationPlayers.slice(11).map((player, index) => {
      return (
        <Player
          key={`home_b_player_${index}`}
          role='bench'
          position={index}
          number={player.number}
          name={player.name}
          score={(homeScorers[player.id] && homeScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeHomeScorers(player, 1)}
          decrementScore={() => this.props.changeHomeScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    });
  }
  renderHomePitch = () => {
    const { homeScorers, homeFormation, homeFormationPlayers } = this.props;
    const { animationsEnabled } = this.state;

    return homeFormationPlayers.slice(0, 11).map((player, index) => {
      return (
        <Player 
          key={`home_p_player_${index}`} 
          team='home'
          formation={homeFormation} 
          role='pitch'
          position={index}
          number={player.number}
          name={player.name}
          score={(homeScorers[player.id] && homeScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeHomeScorers(player, 1)}
          decrementScore={() => this.props.changeHomeScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    });
  }
  
  renderAwayPitch = () => {
    const { awayScorers, awayFormation, awayFormationPlayers } = this.props;
    const { animationsEnabled } = this.state;

    return awayFormationPlayers.slice(0, 11).map((player, index) => {
      return (
        <Player 
          key={`away_p_player_${index}`} 
          team='away' 
          formation={awayFormation}
          role='pitch'
          position={index}
          number={player.number}
          name={player.name}
          score={(awayScorers[player.id] && awayScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeAwayScorers(player, 1)}
          decrementScore={() => this.props.changeAwayScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    })
  }

  renderAwayBench = () => {
    const { awayScorers, awayFormationPlayers } = this.props;
    const { animationsEnabled } = this.state;

    return awayFormationPlayers.slice(11).map((player, index) => {
      return (
        <Player
          key={`home_b_player_${index}`}
          role='bench'
          position={index}
          number={player.number}
          name={player.name}
          score={(awayScorers[player.id] && awayScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeAwayScorers(player, 1)}
          decrementScore={() => this.props.changeAwayScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    });
  }

  renderHomeLineup = () => {
    const { homeFormationPlayers, homeScorers } = this.props;
    const { animationsEnabled } = this.state;

    return homeFormationPlayers.map(player => {
      return (
        <MobilePlayer
          key={`home_mobile_p_${player.id}`}
          name={player.name} 
          number={player.number} 
          score={(homeScorers[player.id] && homeScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeHomeScorers(player, 1)}
          decrementScore={() => this.props.changeHomeScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    });
  }

  renderAwayLineup = () => {
    const { awayFormationPlayers, awayScorers } = this.props;
    const { animationsEnabled } = this.state;
    
    return awayFormationPlayers.map(player => {
      return (
        <MobilePlayer 
          key={`away_mobile_p_${player.id}`}
          name={player.name} 
          number={player.number}
          score={(awayScorers[player.id] && awayScorers[player.id].goals) || 0}
          incrementScore={() => this.props.changeAwayScorers(player, 1)}
          decrementScore={() => this.props.changeAwayScorers(player, -1)}
          animated={animationsEnabled && 600}
        />
      );
    });
  }
}

const mapStateToProps = (store, ownProps) => ({
  homeTeamName: deepRead(store, 'play.match.home_team.name'),
  awayTeamName: deepRead(store, 'play.match.away_team.name'),
  homeFormation: deepRead(store, 'play.match.home_formation'),
  awayFormation: deepRead(store, 'play.match.away_formation'),
  homeFormationPlayers: deepRead(store, 'play.match.home_formation_players') || [],
  awayFormationPlayers: deepRead(store, 'play.match.away_formation_players') || [],
  homeScore: deepRead(store, 'play.play.home_score'),
  awayScore: deepRead(store, 'play.play.away_score'),
  homeScorers: deepRead(store, 'play.play.home_scorers'),
  awayScorers: deepRead(store, 'play.play.away_scorers')
});
const mapDispatchToProps = {
  changeHomeScorers,
  changeAwayScorers
};

export default connect(mapStateToProps, mapDispatchToProps)(Step3);