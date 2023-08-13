import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import AuthLayout from 'layouts/AuthLayout';
import Button from 'components/Button';
import FormInput from 'components/FormInput';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import { setTitle, setDescription } from 'redux/page';
import AuthApi from 'api/auth_api';
import { ensureLoggedOut } from 'lib/authman';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Icon from 'components/Icon';

const FORM_NAME = 'forgotPassword';

class ForgotPassword extends React.Component {
  static async getInitialProps(ctx) {
    const { req, res, reduxStore } = ctx;
    ensureLoggedOut(ctx);
    reduxStore.dispatch(setTitle('Recover Your Password - GuessGoals'));
    reduxStore.dispatch(setDescription('Recover your password by requesting a password reset link.'));
    return {};
  }

  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      errorCode: null,
      showSuccess: false
    }
  }

  handleSendResetLink = () => {
    this.setState({
      loading: true,
      errorCode: null,
    });
    AuthApi.sendResetLink(this.props.forgotPasswordForm)
      .then(() => {
        this.setState({
          loading: false,
          showSuccess: true
        });
      })
      .catch(error => {
        const errorCode = deepRead(error, 'response.data.error_code');
        this.setState({ errorCode, loading: false });
      });
  }

  render() {
    return (
      <AuthLayout>
        { this.renderForm() }
        { this.renderSuccess() }
      </AuthLayout>
    );
  }

  renderForm = () => {
    if (this.state.showSuccess) return;
    return (
      <Fragment>
        <Box mb={2}>
          <Heading center as="h1">Recover Your Password</Heading>
        </Box>
        <Box mb={2.5}>
          <FormInput
            name="email"
            formName={FORM_NAME}
            fieldName="email"
            placeholder="Email" 
          />
        </Box>
        <Box mb={1.5} center>
          <Button large={1} fluid={1} onClick={this.handleSendResetLink} loading={this.state.loading}>Send Reset Link</Button>
        </Box>
        <Box center gray>
          Don't have an account? <Link href="/auth/signup" as="/signup">Sign up</Link>
        </Box>
      </Fragment>
    );
  }
  renderSuccess = () => {
    if (!this.state.showSuccess) return;

    return (
      <Fragment>
        <Box mb={2}>
          <Heading center as="h1"><Icon name="im-checkmark" thick green mr={0.5} /> Check Your Email</Heading>
        </Box>
        <Box gray>
          <p>If the email you specified exists in our system, we've sent a password reset link to it.</p>
          <p>Thanks,<br />GuessGoals Support</p>
        </Box>
      </Fragment>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  forgotPasswordForm: deepRead(store, `form.${FORM_NAME}.data`) || {}
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(ForgotPassword);