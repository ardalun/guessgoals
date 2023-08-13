import React from 'react';
import styled, { css, keyframes } from 'styled-components';
import Screen from 'lib/screen';

import { slideInUp, slideInRight } from 'react-animations';

const slideInUpAnimation = keyframes`${slideInUp}`;
const slideInRightAnimation = keyframes`${slideInRight}`;

const NodeContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  animation: 300ms ${slideInUpAnimation};

  ${Screen.max('md')} {
    flex-direction: row;
    animation: 300ms ${slideInRightAnimation};
  }
`;

const Tail = styled.div`
  width: 2px;
  height: 32px;
  background: #37424C;

  ${props => (props.active || props.complete) && css`
    background: #FF7E00;
  `}

  ${Screen.max('md')} {
    width: 24px;
    height: 2px;
  }

`;

const Indicator = styled.div`
  height: 32px;
  width: 32px;
  border-radius: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #37424C;
  transition: background-color 300ms linear;

  ${props => props.active && css`
    background: #FF7E00;
  `}

  ${props => props.complete && css`
    background: none;
    border: 2px solid #FF7E00;
  `}

  ${Screen.max('md')} {
    width: 24px;
    height: 24px;
    font-size: 0.7rem;
  }
`;


class StepNode extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { children, noTail, complete, active } = this.props;
    return (
      <NodeContainer>
        { !noTail && <Tail complete={complete} active={active} /> }
        <Indicator complete={complete} active={active}>{ children }</Indicator>
      </NodeContainer>
    );
  }
}

export default StepNode;