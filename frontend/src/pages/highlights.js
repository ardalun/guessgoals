import React from 'react';
import { connect } from 'react-redux';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import Banner from 'components/Banner';
import ResourceSelector from 'components/ResourceSelector';
import Box from 'components/Box';

class Highlights extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Football Highlights - GuessGoals'));
    await reduxStore.dispatch(setDescription('Watch latest football highlights.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <Banner />
        <ResourceSelector />
        <Box mt={1.5}>
          This is the main content of the website.<br />
        </Box>
      </MainLayout>
    );
  }
}

export default connect()(Highlights);