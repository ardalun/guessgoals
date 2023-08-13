import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled from 'styled-components';
import Screen from 'lib/screen';
import StepNode from './StepNode';
import Icon from 'components/Icon';

const ChainContainer = styled.div`
  display: flex;
  flex-direction: column;
  position: absolute;
  margin: 0.5rem;

  ${Screen.max('md')} {
    flex-direction: row;
    position: fixed;
    background: #262F37;
    top: 0;
    left: 0;
    right: 0;
    padding: 1rem;
    justify-content: center;
    margin: 0;
  }
`;

class StepsChain extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { currentStepIndex, steps } = this.props;
    const currentStep = steps[currentStepIndex];
    return (
      <ChainContainer>
        { steps.map((step, i) => (
          <StepNode 
            key={`node_${i}`} 
            noTail={step == 1} 
            active={step === currentStep} 
            complete={currentStepIndex > i}
          >{i + 1 === steps.length ? <Icon name="im-check" size={0.6} /> : i + 1}
          </StepNode>
        ))}
      </ChainContainer>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  steps:            deepRead(store, 'play.steps'),
  currentStepIndex: deepRead(store, 'play.currentStepIndex'),
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(StepsChain);