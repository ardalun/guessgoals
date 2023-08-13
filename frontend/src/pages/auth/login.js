import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import Icon from 'components/Icon';
import AuthLayout from 'layouts/AuthLayout';
import Button from 'components/Button';
import FormInput from 'components/FormInput';
import { deepRead } from 'lib/helpers';
import Router from 'next/router';
import { login } from 'redux/session';
import Link from 'components/Link';
import { setTitle, setDescription } from 'redux/page';
import { ensureLoggedOut } from 'lib/authman';
import styled from 'styled-components';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Spinner from 'components/Spinner';
import { subscribeToWalletUpdates, subscribeToNotifs } from 'lib/cable';
import { handleBackendError } from 'lib/errorman';

const FORM_NAME = 'login';

class Login extends React.Component {
  static async getInitialProps(ctx) {
    const { req, res, reduxStore } = ctx;
    ensureLoggedOut(ctx);
    await reduxStore.dispatch(setTitle('Log In - GuessGoals'));
    await reduxStore.dispatch(setDescription('Log in to your account.'));
    return {};
  }

  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      errorCode: null,
      showRedirecting: false
    }
  }

  handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      this.handleLogin();
    }
  }

  handleLogin = () => {
    this.setState({
      loading: true,
      errorCode: null
    });
    this.props.login(this.props.loginForm)
      .then(() => {
        this.setState({ loading: false, showRedirecting: true });
        subscribeToWalletUpdates();
        subscribeToNotifs();
        Router.push('/matches?league_handle=all', '/football');
      })
      .catch(error => {
        handleBackendError(error);
        this.setState({ loading: false });
      });
  }

  render() {
    return (
      <AuthLayout>
        <div className="c-auth">
          <i className="c-auth__logo i-brand"></i>
          <div className="c-auth__box">
            { this.renderLoginForm() }
            { this.renderRedirecting() }
          </div>
        </div>
      </AuthLayout>
    );
  }

  renderLoginForm = () => {
    if (this.state.showRedirecting) return;
    const FakeInput = styled.input`
      display: none;
    `;

    return (
      <Fragment>
        <Box mb={2}>
          <Heading center as="h1">Log in</Heading>
        </Box>
        <FakeInput id="email" type="text" name="fakeemailremembered" />
        <FakeInput id="password" type="password" name="fakepasswordremembered" />
        <Box mb={1}>
          <FormInput
            name="email"
            formName={FORM_NAME}
            fieldName="email"
            placeholder="Email"
            autoComplete="new-password"
            onKeyDown={this.handleKeyDown}
          />
        </Box>
        <Box mb={2.5}>
          <FormInput
            name="password"
            formName={FORM_NAME}
            fieldName="password"
            placeholder="Password"
            type="password"
            autoComplete="new-password"
            onKeyDown={this.handleKeyDown}
          />
        </Box>
        { this.renderError() }
        <Box mb={1.5} center>
          <Button large fluid onClick={this.handleLogin} loading={this.state.loading}>Log in</Button>
        </Box>
        <Box center gray>
          Don't have an account? <Link href="/auth/signup" as="/signup">Sign up</Link> <br />
          <Link href="/auth/forgot-password" as="/forgot-password">Forgot Password</Link>
        </Box>
      </Fragment>
    );
  }

  renderError = () => {
    if (!this.state.errorCode) return;
    return (
      <p style={{color: 'red'}}>
        <Icon type="close-circle" theme="twoTone" twoToneColor="red" mr={0.5} /> {translate(this.state.errorCode)}
      </p>
    );
  }

  renderRedirecting = () => {
    if (!this.state.showRedirecting) return;

    return (
      <Fragment>
        <Box mb={1}><Spinner large /></Box>
        <Heading center as="h1">Logging in...</Heading>
      </Fragment>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  loginForm: deepRead(store, `form.${FORM_NAME}.data`) || {},
  store
});
const mapDispatchToProps = {
  login
};

export default connect(mapStateToProps, mapDispatchToProps)(Login);