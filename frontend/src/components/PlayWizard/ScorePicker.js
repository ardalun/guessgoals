import React from 'react';
import dynamic from 'next/dynamic';
import styled, { css, keyframes } from 'styled-components';
import Screen from 'lib/screen';
import Icon from 'components/Icon';
import { fadeInUp } from 'react-animations';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const Odometer = dynamic(import('react-odometerjs'), {
  ssr: false,
  loading: () => 0
});

const ScorePickerContainer = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin: 1rem;
  ${Screen.max('md')} {
    margin: 0.5rem;
  }
  ${Screen.max('xs')} {
    margin: 0.25rem;
  }
  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;

const UpOrDownButton = styled(Icon)`
  padding: 1rem;
  transition: transform 200ms ease;
  cursor: pointer;

  :hover {
    transform: scale(1.5);
  }
`;

const Score = styled.div`
  width: 4rem;
  height: 4rem;
  border-radius: 0.25rem;
  background: #1E262D;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  
  .odometer.odometer-auto-theme, .odometer.odometer-theme-default {
    line-height: 4rem;    
  }

  ${Screen.max('md')} {
    width: 3rem;
    height: 3rem;
    font-size: 1.5rem;
    .odometer.odometer-auto-theme, .odometer.odometer-theme-default {
      line-height: 3rem;
    }
  }
`;

class ScorePicker extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { score, incrementScore, decrementScore, animated } = this.props;
    return (
      <ScorePickerContainer animated={animated}>
        <UpOrDownButton className="im-arrow-up" onClick={incrementScore} />
        <Score><Odometer value={score} format="d" duration={20} /></Score>
        <UpOrDownButton className="im-arrow-down" onClick={decrementScore} />
      </ScorePickerContainer>
    );
  }
}

export default ScorePicker;