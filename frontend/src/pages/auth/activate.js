import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import AuthLayout from 'layouts/AuthLayout';
import Link from 'components/Link';
import Box from 'components/Box';
import Icon from 'components/Icon';
import Heading from 'components/Heading';
import { setTitle, setDescription } from 'redux/page';
import AuthApi from 'api/auth_api';
import SuccessIcon from 'components/SuccessIcon';
import { ensureLoggedOut } from 'lib/authman';

class Activate extends React.Component {
  static async getInitialProps(ctx) {
    const {req, res, reduxStore} = ctx;
    ensureLoggedOut(ctx);

    let success = false;
    try {
      await AuthApi.activateAccount(req.params.token);
      success = true;
    } catch (error) {
      success = false;
    }

    reduxStore.dispatch(setTitle('Account Activation - GuessGoals'));
    reduxStore.dispatch(setDescription('Activate your account'));
    return {
      success
    };
  }

  render() {
    return (
      <AuthLayout>
        { this.renderInvalidTokenError() }
        { this.renderSuccess() }
      </AuthLayout>
    );
  }

  renderInvalidTokenError = () => {
    if (this.props.success) return;

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
    if (!this.props.success) return;

    return (
      <Fragment>
        <Box mb={1}>
          <Heading center as="h1"><Icon name="im-checkmark" thick green mr={0.5} /> Thank You</Heading>
        </Box>
        <Box center gray mb={2.5}>
          You account is now active.
        </Box>
        <Box center>
          <Link href="/auth/login" as="/login">Continue</Link>
        </Box>
      </Fragment>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(Activate);