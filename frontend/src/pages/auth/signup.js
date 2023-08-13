import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import Icon from 'components/Icon';
import AuthLayout from 'layouts/AuthLayout';
import Button from 'components/Button';
import FormInput from 'components/FormInput';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import { setErrors } from 'redux/form';
import AuthApi from 'api/auth_api';
import { setTitle, setDescription } from 'redux/page';
import { ensureLoggedOut } from 'lib/authman';
import styled from 'styled-components';
import Heading from 'components/Heading';
import Checkbox from 'components/Checkbox';
import Box from 'components/Box';
import { handleBackendError } from 'lib/errorman';

const FORM_NAME = 'signup';
class Signup extends React.Component {
  static async getInitialProps(ctx) {
    const { req, res, reduxStore } = ctx;
    ensureLoggedOut(ctx);
    await reduxStore.dispatch(setTitle('Sign Up - GuessGoals'));
    await reduxStore.dispatch(setDescription('Sign up for a new account.'));
    return {};
  }

  constructor(props) {
    super(props);
    this.state = {
      loading: false,
      boxChecked: false,
      showSuccess: false
    }
  }

  handleBoxCheckChanged = (e) => {
    this.setState({
      boxChecked: e.target.checked
    });
  }

  handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      this.handleSignup();
    }
  }

  handleSignup = () => {
    this.setState({
      loading: true,
      errorCode: null
    });

    AuthApi.signup(this.props.signupForm)
      .then(resp => {
        this.setState({
          loading: false,
          showSuccess: true
        });
      })
      .catch(error => {
        let stateUpdate = { 
          loading: false,
          boxChecked: false
        };
        const errorCode = deepRead(error, 'response.data.error_code');
        if (errorCode === 'validation_failed') {
          const errors = deepRead(error, 'response.data.validation_errors');
          this.props.setErrors(FORM_NAME, errors);
        } else {
          handleBackendError(error);
        }
        this.setState(stateUpdate);
      });
  }

  render() {
    return (
      <AuthLayout pageAttrs={this.props.pageAttrs}>
        { this.renderSignupForm() }
        { this.renderSuccess() }
      </AuthLayout>
    );
  }

  renderSignupForm = () => {
    const { boxChecked } = this.state;
    if (this.state.showSuccess) return;

    const FakeInput = styled.input`
      display: none;
    `;

    return (
      <Fragment>
        <Box mb={2}>
          <Heading center as="h1">Sign up</Heading>
        </Box>
        <FakeInput id="username" type="text" name="fakeusernameremembered" />
        <FakeInput id="password" type="password" name="fakepasswordremembered" />
        <Box mb={1}>
          <FormInput
            name="username"
            formName={FORM_NAME}
            fieldName="username"
            placeholder="Username"
            autoComplete="new-password"
            onKeyDown={this.handleKeyDown}
          />
        </Box>
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
        <Box mb={1}>
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
        <Box mb={2.5}>
          <Checkbox
            textGray
            checked={boxChecked}
            onChange={this.handleBoxCheckChanged}
          >I agree to the <Link href="/terms-and-conditions">Terms and Conditions</Link>.</Checkbox>
        </Box>
        <Box mb={1.5} center>
          <Button 
            large 
            fluid 
            onClick={this.handleSignup} 
            loading={this.state.loading}
            disabled={!boxChecked}
          >Sign up</Button>
        </Box>
        <Box center gray>
          Already have an account? <Link href="/auth/login" as="/login">Log in</Link>
        </Box>
      </Fragment>
    );
  }

  renderSuccess = () => {
    if (!this.state.showSuccess) return;

    return (
      <Fragment>
        <Box mb={1}>
          <Heading center as="h1"><Icon name="im-checkmark" thick green mr={0.5} /> Check Your Email</Heading>
        </Box>
        <Box gray>
          <p>An activation link has been sent to <strong>{this.props.signupForm.email}</strong>.</p>
          <p>Your account will be activated once you confirm your email address by clicking on the activation link.</p>
          <p>Thanks,<br />GuessGoals Support</p>
        </Box>
      </Fragment>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  signupForm: deepRead(store, `form.${FORM_NAME}.data`) || {}
});
const mapDispatchToProps = {
  setErrors
};

export default connect(mapStateToProps, mapDispatchToProps)(Signup);