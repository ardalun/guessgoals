import React from 'react';
import jerseyUrl from 'assets/images/jersey.svg';
import jerseySelectedUrl from 'assets/images/jersey-selected.svg';
import styled, { css, keyframes } from 'styled-components';
import { fadeInUp } from 'react-animations';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const homeG = -3;
const awayG = 405;
const homeStart = 33;
const homeEnd = 220;
const awayStart = 220;
const awayEnd = 405;
const yStart  = 0;
const yEnd    = 230;

const findLane = (team, formation, position) => {
  let lines = team === 'home' ? formation.split('-') : formation.split('-').reverse();
  const pos = team === 'home' ? position : 11 - position;
  let positionCursor = 0;
  for(let i = 0; i < lines.length; i++) {
    positionCursor += parseInt(lines[i]);
    if (pos <= positionCursor) {
      return i;
    }
  }
  return lines.length - 1;
}

const findPosInLane = (team, formation, position) => {
  let lines = team === 'home' ? formation.split('-') : formation.split('-').reverse();
  const pos = team === 'home' ? position : 11 - position;
  let positionCursor = 0;
  for(let i = 0; i < lines.length; i++) {
    positionCursor += parseInt(lines[i]);
    if (pos <= positionCursor) {
      return pos - (positionCursor - parseInt(lines[i]));
    }
  }
  return lines.length - 1;
}

const calculateTopHome = (formation, position) => {
  if (position === 0) { return (yStart + yEnd) / 2 - 16; }
  const lane = findLane('home', formation, position);
  const laneSize = parseInt(formation.split('-')[lane]);
  if (laneSize < 4) {
    const verticalSplit = (yEnd - yStart) / (laneSize + 1);
    const posInLane = findPosInLane('home', formation, position);
    return posInLane * verticalSplit - 16;
  } else {
    const verticalSplit = (yEnd - yStart) / laneSize;
    const posInLane = findPosInLane('home', formation, position);
    return (posInLane - 1) * verticalSplit + verticalSplit / 2 - 16;
  }
}

const calculateTopAway = (formation, position) => {
  if (position === 0) { return (yStart + yEnd) / 2 - 16; }
  const lane = findLane('away', formation, position);
  const laneSize = parseInt(formation.split('-').reverse()[lane]);
  if (laneSize < 4) {
    const verticalSplit = (yEnd - yStart) / (laneSize + 1);
    const posInLane = findPosInLane('away', formation, position);
    return posInLane * verticalSplit - 16;
  } else {
    const verticalSplit = (yEnd - yStart) / laneSize;
    const posInLane = findPosInLane('away', formation, position);
    return (posInLane - 1) * verticalSplit + verticalSplit / 2 - 16;
  }
}

const calculateTopBench = (position) => {
  const laneSize = position < 4 ? 4 : 3;
  const verticalSplit = (yEnd - yStart) / (laneSize + 1);
  const posInLane = position % laneSize;
  return (posInLane + 1) * verticalSplit - 16;
}

const calculateLeftHome = (formation, position) => {
  if (position === 0) { return homeG; }

  const lane = findLane('home', formation, position);
  const lanesCount = formation.split('-').length;
  const gutter = ((homeEnd - homeStart) - lanesCount * 42) / (lanesCount - 1);
  return homeStart + lane * (42 + gutter);
}

const calculateLeftAway = (formation, position) => {
  if (position === 0) { return awayG; }

  const lane = findLane('away', formation, position);
  const lanesCount = formation.split('-').length;
  const gutter = ((awayEnd - awayStart) - lanesCount * 42) / (lanesCount - 1);
  return awayStart + lane * (42 + gutter);
}

const calculateLeftBench = (position) => {
  const lane = position < 4 ? 0 : 1;
  const gutter = 8;
  return gutter + lane * (42 + gutter);
}

const calculateTop = (role, team, formation, position) => {
  if (role === 'bench') {
    return calculateTopBench(position);
  } else if (team === 'home') {
    return calculateTopHome(formation, position);
  } else {
    return calculateTopAway(formation, position);
  }
}
const calculateLeft = (role, team, formation, position) => {
  if (role === 'bench') {
    return calculateLeftBench(position);
  } else if (team === 'home') {
    return calculateLeftHome(formation, position);
  } else {
    return calculateLeftAway(formation, position);
  }
}

const PlayerContainer = styled.div`
  width: 42px;
  height: 32px;
  font-size: 0.5625rem;
  font-family: 'Roboto Condensed';
  color: #858585;
  line-height: 1;
  text-align: center;

  background-image: url(${jerseyUrl});
  background-repeat: no-repeat;
  background-size: 24px;
  background-position-x: center;

  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  cursor: pointer;

  &:hover {
    background-image: url(${jerseySelectedUrl});
    overflow: visible;
    white-space: pre-wrap;
    color: white;
    padding-left: 0px;
  }
  
  position: absolute;
  top:  ${props => `${calculateTop(props.role, props.team, props.formation, props.position)}px` };
  left: ${props => `${calculateLeft(props.role, props.team, props.formation, props.position)}px` };

  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;

const Number = styled.div`
  padding-top: 5px;
  padding-bottom: 9px;
  text-align: center;
`;

class Player extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { name, number, incrementScore } = this.props;
    return (
      <PlayerContainer {...this.props} onClick={incrementScore}>
        <Number>{number}</Number>
        {name}
      </PlayerContainer>
    );
  }
}

export default Player;