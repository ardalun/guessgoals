import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import { Modal } from 'antd';
import styled from 'styled-components';
import Screen from 'lib/screen';
import Spinner from 'components/Spinner';
import Box from 'components/Box';
import Button from 'components/Button';
import Icon from 'components/Icon';
import Heading from 'components/Heading';
import StepsChain from './StepsChain';
import Step1 from './Step1';
import Step2 from './Step2';
import Step3 from './Step3';
import Step4 from './Step4';
import Step5 from './Step5';
import HowToPlay from './HowToPlay';
import { goNext, goBack, cancelPlay, createPlay } from 'redux/play';

const StyledModal = styled(Modal)`
  padding-top: 24px;
  width: 800px !important;

  .ant-modal-wrap{
    position: absolute;
  }
  .ant-modal-content {
    background: #262F37;
    color: white;
    position: sticky;
  }
  .ant-modal-body {
    height: 575px;
    overflow-y: scroll;
    display: flex;
  }
  .ant-modal-close-x {
    color: #858585;
    background: #262F37;
    border-radius: 0.25rem;
  }

  ${Screen.max('md')} {
    margin: 0;
    padding: 0;
    max-width: 100vw;
    min-width: 100vw;
    
    .ant-modal-body {
      height: 100vh;
    }
  }
`;

const StyledSpinner = styled(Spinner)`
  position: absolute;
  top: calc(50% - 50px);
  left: calc(50% - 50px);
  width: 100px;
  height: 100px;
  font-size: 16px;
`;

const StepBody = styled.div`
  padding: 1rem;
  padding-left: 6rem;
  width: 100%;
  
  ${Screen.max('md')} {
    padding: 1rem;
    position: fixed;
    left: 0;
    right: 0;
    top: 3.5rem;
    bottom: 4.5rem;
    overflow-y: scroll;
  }
`;

const WizardFooter = styled.div`
  display: flex;
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: #262F37;
  border-radius: 0 0 0.25rem 0.25rem;
  padding: 1rem 1.5rem 1.5rem;

  ${Screen.max('md')} {
    border-radius: 0;
    position: fixed;
    padding: 1rem;
    border-top: 1px solid #40474E;
    background: #1E262D;
  }
`;

const RightAlignedMenu = styled.div`
  flex-grow: 1;
  justify-content: flex-end;
  align-items: center;
  display: inline-flex;
`;

const SuccessContainer = styled.div`
  width: 100%;
  margin: 4rem auto 0;
  max-width: 500px;
`;

class PlayWizard extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      v: true
    };
  }

  cancelPlay = () => {
    const { cancelPlay, matchLoading, placeBetLoading } = this.props;
    if (!placeBetLoading && !matchLoading) {
      cancelPlay();
    }
  }

  render() {
    const { wizardOpened } = this.props;
    return (
      <StyledModal 
        centered
        visible={wizardOpened}
        footer={null}
        onCancel={this.cancelPlay}
        maskClosable={false}
      >
        { this.renderHowToPlay() }
        { this.renderSpinner() }
        { this.renderWizardContent() }
        { this.renderSuccess() }
      </StyledModal>
    );
  }

  renderHowToPlay = () => {
    if (!this.props.showHowToPlay) return;
    return (
      <HowToPlay />
    );
  }

  renderSuccess = () => {
    const { showSuccess, cancelPlay } = this.props;
    if (!showSuccess) return;
    return (
      <SuccessContainer>
        <Box mb={1} center animated={200}><Icon name="im-checkmark" green thick size={3} /></Box>
        <Box mb={1.5} animated={300}><Heading as="span" sizeLike="h1" center>Thank You</Heading></Box>
        <Box mb={1} gray animated={400}>Your bet is placed.</Box>
        <Box mb={1} gray animated={400}>
          As more bets are received on this match, the prize pool is raised while your chance is affected due to competing with more bettors.
        </Box>
        <Box mb={2} gray animated={400}>We will update you with the latest odds and the prize pool value once this pool is closed upon the match start.</Box>
        <Box animated={500} center><Button secondary large onClick={cancelPlay}>Continue</Button></Box>
      </SuccessContainer>
    );
  }

  renderSpinner = () => {
    if (!this.props.matchLoading) return;
    return <StyledSpinner />;
  }

  renderWizardContent = () => {
    const { currentStepIndex, steps, matchLoading, showSuccess, showHowToPlay } = this.props;
    
    if (matchLoading || showSuccess || showHowToPlay) return;
    const currentStep = steps[currentStepIndex];
    return (
      <Fragment>
        <StepsChain />
        <StepBody>
          { currentStep === 1 && <Step1 /> }
          { currentStep === 2 && <Step2 /> }
          { currentStep === 3 && <Step3 /> }
          { currentStep === 4 && <Step4 /> }
          { currentStep === 5 && <Step5 /> }
        </StepBody>
        <WizardFooter>
          { this.renderBackButton() }
          <RightAlignedMenu>
            { this.renderNextButton() }
            { this.renderPlaceMyBetButton() }
          </RightAlignedMenu>
        </WizardFooter>
      </Fragment>
    )
  }

  renderBackButton = () => {
    if (this.props.currentStepIndex === 0) return;

    return (
      <Button secondary onClick={this.props.goBack}>
        <Icon name="im-arrow-left" size={0.75} mr={0.5} /> Back
      </Button>
    );
  }

  renderPlaceMyBetButton = () => {
    const { steps, currentStepIndex, walletTotal, ticketFee, placeBetLoading, createPlay } = this.props;
    const currentStep = steps[currentStepIndex];
    if (currentStep !== 5) return;

    return (
      <Button 
        onClick={createPlay} 
        disabled={walletTotal < ticketFee}
        loading={placeBetLoading}
      >
        Place My Bet
        <Icon name="im-arrow-right" size={0.75} ml={0.5} />
      </Button>
    );
  }

  renderNextButton = () => {
    const { steps, currentStepIndex, goNext, nextButtonEnabled } = this.props;
    const currentStep = steps[currentStepIndex];
    if (currentStep === 5) return;

    return (
      <Button 
        onClick={goNext} 
        disabled={!nextButtonEnabled}
      >
        Next
        <Icon name="im-arrow-right" size={0.75} ml={0.5} />
      </Button>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  matchLoading:      deepRead(store, 'play.matchLoading'),
  wizardOpened:      deepRead(store, 'play.wizardOpened'),
  steps:             deepRead(store, 'play.steps'),
  currentStepIndex:  deepRead(store, 'play.currentStepIndex'),
  nextButtonEnabled: deepRead(store, 'play.nextButtonEnabled'),
  walletTotal:       deepRead(store, 'session.user.wallet.total'),
  ticketFee:         deepRead(store, 'play.match.ticket_fee'),
  placeBetLoading:   deepRead(store, 'play.placeBetLoading'),
  showSuccess:       deepRead(store, 'play.showSuccess'),
  showHowToPlay:     deepRead(store, 'play.showHowToPlay')
});
const mapDispatchToProps = {
  goNext,
  goBack,
  cancelPlay,
  createPlay
};

export default connect(mapStateToProps, mapDispatchToProps)(PlayWizard);