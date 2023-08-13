import React from 'react';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import PageContainer from 'components/PageContainer';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Link from 'components/Link';

class ContactUsPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Contact Us - GuessGoals'));
    await reduxStore.dispatch(setDescription('Contact our support team.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <PageContainer>
          <Box mb={2}><Heading as="h1">Contact Us</Heading></Box>
          <Box lightGray>
            Our support team is always ready to provide you with more information or answer any questions you might have.
            If you have any questions or you need help, email us at <Link href="mailto:support@guessgoals.com">support@guessgoals.com</Link>.
          </Box>
          <Box lightGray mt={1}>We are also available on Instagram: <Link href="https://www.instagram.com/guessgoalsbetting/">@guessgoalsbetting</Link></Box>
        </PageContainer>
      </MainLayout>
    );
  }
}

export default ContactUsPage;