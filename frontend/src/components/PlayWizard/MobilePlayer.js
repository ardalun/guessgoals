import React from 'react';
import jerseyUrl from 'assets/images/jersey.svg';
import jerseySelectedUrl from 'assets/images/jersey-selected.svg';
import styled, { css, keyframes } from 'styled-components';
import GoalCounter from './GoalCounter';
import { fadeInUp } from 'react-animations';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const MobilePlayerContainer = styled.div`
  border-bottom: 1px solid #40474E;
  display: flex;
  font-family: 'Roboto Condensed';
  color: #858585;
  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;

const Jersey = styled.div`
  background-image: url(${jerseyUrl});
  background-repeat: no-repeat;
  background-size: 64px;
  background-position-x: center;
  font-size: 1.2rem;
  width: 64px;
  height: 4rem;
  margin-left: 0.5rem;
  text-align: center;
  padding-top: 10px;
  margin-top: 1rem;
  margin-bottom: 1rem;

  ${props => props.selected && css`
    color: white;
    background-image: url(${jerseySelectedUrl});
  `}
`;

const PlayerName = styled.div`
  display: flex;
  align-items: center;
  padding-left: 1rem;
  flex-grow: 1;
  ${props => props.selected && css`
    color: white;
  `}
`;

class MobilePlayer extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { name, number, animated, score, incrementScore, decrementScore } = this.props;

    return (
      <MobilePlayerContainer animated={animated}>
        <Jersey selected={score > 0}>{ number }</Jersey>
        <PlayerName selected={score > 0}>{ name }</PlayerName>
        <GoalCounter
          count={score}
          incrementCount={incrementScore}
          decrementCount={decrementScore}
        />
      </MobilePlayerContainer>
    );
  }
}

export default MobilePlayer;