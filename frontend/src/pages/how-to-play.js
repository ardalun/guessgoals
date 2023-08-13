import React from 'react';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import Heading from 'components/Heading';
import Box from 'components/Box';
import PageContainer from 'components/PageContainer';

class HowToPlayPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('How To Play - GuessGoals'));
    await reduxStore.dispatch(setDescription('Learn how to play at GuessGoals.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <PageContainer>
          <Box mb={2}><Heading as="h1">How To Play?</Heading></Box>
        </PageContainer>
      </MainLayout>
    );
  }
}

export default HowToPlayPage;