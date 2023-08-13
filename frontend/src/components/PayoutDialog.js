import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import { Modal } from 'antd';
import Screen from 'lib/screen';
import Heading from 'components/Heading';
import Box from 'components/Box';
import styled, { css } from 'styled-components';
import FormInput from 'components/FormInput';
import Checkbox from 'components/Checkbox';
import Button from 'components/Button';
import PayoutApi from 'api/payout_api';
import { setField, setErrors } from 'redux/form';
import { storeNewLedgerEntry } from 'redux/wallet-page';
import { handleBackendError } from 'lib/errorman';
import Icon from 'components/Icon';

const StyledModal = styled(Modal)`
  padding-top: 24px;
  width: 570px !important;

  .ant-modal-content {
    background: #262F37;
    color: white;
  }
  .ant-modal-body {
    overflow-y: scroll;
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

const AvailableAmount = styled.div`
  background: #1E262D;
  padding: 1.5rem;
  border-radius: 0.25rem;
`;

const DialogFooter = styled.div`
  display: flex;
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: #262F37;
  border-radius: 0 0 0.25rem 0.25rem;
  padding: 1.5rem;

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
  padding-bottom: 1rem;
  max-width: 500px;
  margin: 1.5rem auto 0;

  ${Screen.max('md')} {
    margin-top: 6rem;
  }
`;

const FORM_NAME = 'payout';

class PayoutDialog extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = {
      boxChecked: false,
      showSuccess: false,
      loading: false
    }
  }

  handleBoxCheckChanged = (e) => {
    this.setState({
      boxChecked: e.target.checked
    });
  }

  submitPayoutRequest = () => {
    const { address } = this.props;
    this.setState({ loading: true });

    PayoutApi.createPayout(address)
      .then(resp => {
        this.setState({
          showSuccess: true,
          loading: false
        });
        this.props.storeNewLedgerEntry(resp.data.ledger_entry);
      })
      .catch(error => {
        let stateUpdate = { loading: false };
        const errorCode = deepRead(error, 'response.data.error_code');
        if (errorCode === 'validation_failed') {
          const errors = deepRead(error, 'response.data.validation_errors');
          this.props.setErrors(FORM_NAME, errors);
          stateUpdate.boxChecked = false;
        } else {
          handleBackendError(error);
        }
        this.setState(stateUpdate);
      })
  }

  resetAndClose = () => {
    this.props.closeDialog();
    setTimeout(() => {
      this.props.setField(FORM_NAME, 'address', null);
      this.setState({
        boxChecked: false,
        showSuccess: false
      });
    }, 1000);
  }

  render() {
    const { visible } = this.props;
    return(
      <StyledModal 
        centered
        visible={visible}
        footer={null}
        onCancel={this.resetAndClose}
        maskClosable={false}
      >
        { this.renderPayoutForm() }
        { this.renderSuccess() }
      </StyledModal>
    );
  }

  renderPayoutForm = () => {
    const { boxChecked, showSuccess } = this.state;
    const { closeDialog, loading } = this.props;
    if (showSuccess) return;
    return (
      <Box pb={3}>
        <Box mb={2}>
          <Heading as="span" sizeLike="h1">Request a Payout</Heading>
        </Box>
        <Box mb={1}>
          <AvailableAmount>
            <Heading as="span" sizeLike="h4" gray>Available For Payout</Heading>
            <Heading as="span" sizeLike="h2">0.002 BTC</Heading>
          </AvailableAmount>
        </Box>
        <Box mb={1}>
          <FormInput
            name="address"
            formName={FORM_NAME}
            fieldName="address"
            placeholder="Enter an External Address"
            onChange={() => this.setState({boxChecked: false})}
          />
        </Box>
        <Box mb={1}>
          <Checkbox
            checked={boxChecked}
            onChange={this.handleBoxCheckChanged}
          >This address is mine and I am sure it is correct.</Checkbox>
        </Box>
        <DialogFooter>
          <RightAlignedMenu>
            <Box mr={0.75}>
              <Button secondary onClick={closeDialog}>Cancel</Button>
            </Box>
            <Button 
              disabled={!boxChecked}
              loading={loading}
              onClick={this.submitPayoutRequest}
            >Submit</Button>
          </RightAlignedMenu>
        </DialogFooter>
      </Box>
    );
  }

  renderSuccess = () => {
    const { showSuccess } = this.state;
    if (!showSuccess) return;
    return (
      <SuccessContainer>
        <Box mb={1} center animated={200}><Icon name="im-checkmark" green thick size={3} /></Box>
        <Box mb={1.5} animated={300}><Heading as="span" sizeLike="h1" center>Thank You</Heading></Box>
        <Box mb={2} gray animated={400}>
          We received your payout request and started processing it already. 
          Payouts could take up to two days to complete. We will notify you via email once this request is updated.
        </Box>
        <Box center animated={500}><Button secondary large onClick={this.resetAndClose}>Continue</Button></Box>
      </SuccessContainer>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  address: deepRead(store, `form.${FORM_NAME}.data.address`)
});
const mapDispatchToProps = {
  setField,
  setErrors,
  storeNewLedgerEntry
};

export default connect(mapStateToProps, mapDispatchToProps)(PayoutDialog);