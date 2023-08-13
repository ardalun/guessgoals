import React from 'react';
import dynamic from 'next/dynamic';
import styled, { css } from 'styled-components';
import Icon from 'components/Icon';

const Odometer = dynamic(import('react-odometerjs'), {
  ssr: false,
  loading: () => 0
});

const GoalCounterContainer = styled.div`
  display: flex;
  font-family: 'Roboto Condensed';
  color: #858585;
`;

const Score = styled.div`
  width: 4rem;
  height: 6rem;
  background: #1E262D;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  
  .odometer.odometer-auto-theme, .odometer.odometer-theme-default {
    line-height: 6rem;
  }
`;

const ButtonGroup = styled.div`
  display: flex;
  flex-direction: column;
`;

const UpOrDownButton = styled(Icon)`
  height: 3rem;
  width: 3rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 200ms ease;
  cursor: pointer;

  :hover {
    transform: scale(1.5);
  }
`;

class GoalCounter extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { count, incrementCount, decrementCount, animated } = this.props;

    return (
      <GoalCounterContainer>
        <Score><Odometer value={count} format="d" duration={20} /></Score>
        <ButtonGroup>
          <UpOrDownButton className="im-arrow-up" onClick={incrementCount} />
          <UpOrDownButton className="im-arrow-down" onClick={decrementCount} />
        </ButtonGroup>
      </GoalCounterContainer>
    );
  }
}

export default GoalCounter;