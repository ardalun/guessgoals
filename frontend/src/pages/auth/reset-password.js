import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import AuthLayout from 'layouts/AuthLayout';
import Button from 'components/Button';
import FormInput from 'components/FormInput';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import Box from 'components/Box';
import Icon from 'components/Icon';
import Heading from 'components/Heading';
import { setTitle, setDescription } from 'redux/page';
import { setErrors } from 'redux/form';
import AuthApi from 'api/auth_api';
import SuccessIcon from 'components/SuccessIcon';
import { ensureLoggedOut } from 'lib/authman';

const FORM_NAME = 'resetPassword';

class ResetPassword extends React.Component {
  static async getInitialProps(ctx) {
    const { req, res, reduxStore } = ctx;
    let tokenIsValid = false;
    try {
      const resp = await AuthApi.validatePassResetToken(req.params.token);
      tokenIsValid = resp.data.token_is_valid;
    } catch (error) {
      tokenIsValid = false;
    }

    reduxStore.dispatch(setTitle('Reset Your Password - GuessGoals'));
    reduxStore.dispatch(setDescription('Set a new password for your account with guessgoals.'));
    return {
      tokenIsValid,
      token: req.params.token
    };
  }

  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      showSuccess: false
    }
  }

  handleResetPassword = () => {
    this.setState({
      loading: true,
    });
    AuthApi.resetPassword(this.props.token, this.props.resetPasswordForm)
      .then(resp => {
        this.setState({
          loading: false,
          showSuccess: true
        });
      })
      .catch(error => {
        const errorCode = deepRead(error, 'response.data.error_code');
        if (errorCode === 'validation_failed') {
          const errors = deepRead(error, 'response.data.validation_errors');
          this.props.setErrors(FORM_NAME, errors);
        }
        this.setState({ loading: false, errorCode });
      });
  }

  render() {
    return (
      <AuthLayout>
        { this.renderForm() }
        { this.renderInvalidTokenError() }
        { this.renderSuccess() }
      </AuthLayout>
    );
  }

  renderForm = () => {
    if (this.state.showSuccess || !this.props.tokenIsValid) return;
    return (
      <Fragment>
        <Box mb={2}>
          <Heading center as="h1">Recover Your Password</Heading>
        </Box>
        <Box mb={1}>
          <FormInput
            name="password"
            formName={FORM_NAME}
            fieldName="password"
            placeholder="Password"
            type="password"
            autoComplete="new-password"
          />
        </Box>
        <Box mb={2.5}>
          <FormInput
            name="password_repeat"
            formName={FORM_NAME}
            fieldName="password_repeat"
            placeholder="Password Repeat"
            type="password"
            autoComplete="new-password"
          />
        </Box>
        <Box center>
          <Button large fluid onClick={this.handleResetPassword} loading={this.state.loading}>Reset Password</Button>
        </Box>
      </Fragment>
    );
  }

  renderInvalidTokenError = () => {
    if (this.state.showSuccess || this.props.tokenIsValid) return;
    return (
      <Fragment>
        <Box mb={1}>
          <Heading center as="h1"><Icon name="im-error" thick red mr={0.5} /> Invalid Token</Heading>
        </Box>
        <Box center gray>
          We are sorry but this token is either invalid or expired.
        </Box>
      </Fragment>
    );
  }

  renderSuccess = () => {
    if (!this.state.showSuccess || !this.props.tokenIsValid) return;

    return (
      <Fragment>
        <Box mb={1}>
          <Heading center as="h1"><Icon name="im-checkmark" thick green mr={0.5} /> All Set</Heading>
        </Box>
        <Box center gray mb={2.5}>
          Your password was changed.
        </Box>
        <Box center>
          <Link href="/auth/login" as="/login">Continue</Link>
        </Box>
      </Fragment>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  resetPasswordForm: deepRead(store, `form.${FORM_NAME}.data`) || {}
});
const mapDispatchToProps = {
  setErrors
};

export default connect(mapStateToProps, mapDispatchToProps)(ResetPassword);