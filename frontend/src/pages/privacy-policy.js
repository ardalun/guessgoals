import React from 'react';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import Heading from 'components/Heading';
import Box from 'components/Box';
import PageContainer from 'components/PageContainer';

class PrivacyPolicyPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Privacy Policy - GuessGoals'));
    await reduxStore.dispatch(setDescription('Learn more about our Privacy Policy.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <PageContainer>
          <Heading as="h1">Privacy Policy</Heading>
          <Box body3 gray mb={1}>Last updated: 2019-09-25</Box>
          <Box lightGray mb={1}>
            This Privacy Policy describes the way in which GuessGoals (otherwise referred to herein as "we" or "us") deal with the
            information and data you provide to us to enable us to manage your relationship with GuessGoals.
          </Box>
          <Box lightGray mt={1} mb={2}>
            We will process any personal information provided to us (whether via the GuessGoals website ["the Website"], the customer
            application form or any other means) or otherwise held by us relating to you in the manner set out in this Privacy Policy. 
            By submitting your information to us and using the Website, you confirm your consent to the use of your personal 
            information as set out in this Privacy Policy. If you do not agree with the terms of this Privacy Policy, please do not 
            use the Website or otherwise provide us with your personal information.
          </Box>

          <Heading as="h2">Information Collected and How It Is Used</Heading>
          <Box lightGray mt={1}>
            The information and data about you which we may collect, use and process include the following:<br />

            1 - Information that you provide to us by filling in forms on the Website or any other information
            you submit to us via the Website or email;<br/>
            2 - Records of correspondence, whether via the Website, email, phone or any other means;<br />
            3 - Your responses to surveys or customer research that we may carry out;<br />
            4 - Retails of the transactions you carry out with us, whether via the Website or other means; and<br />
            5 - Details of your visits to the Website including, but not limited to, traffic data, location data, 
            weblogs and other communication data.
          </Box>
          <Box lightGray mt={1} mb={2}>
            We may use your personal information and data together with other information for the purposes of:<br />
            
            1 - Processing your bets, including card and online payments;<br />
            2 - Setting up, operating and managing your account;<br />
            3 - Complying with our legal and regulatory duties;<br />
            4 - Building up personal profiles;<br />
            5 - Carrying out customer research, surveys and analyses;<br />
            6 - Providing you with information about promotional offers and our products and services, where you have consented; and<br />
            7 - Monitoring transactions for the purposes of preventing fraud, irregular betting, money laundering and cheating.
          </Box>

          <Heading as="h2">Disclosing personal information to third parties</Heading>
          <Box lightGray mt={1} mb={2}>
            Your personal information will not be disclosed to anyone other than employees of the Company that require access to your 
            data in order to provide you with a service, with the exception where we may be required by law or legal process to disclose
            your personal information to relevant authorities.
          </Box>

          <Heading as="h2">Cookies</Heading>
          <Box lightGray mt={1} mb={2}>
            A cookie is a data packet which is used solely for web analytic purposes. Our Website uses cookies to recognise visitors
            and facilitate the login process.
          </Box>

          <Heading as="h2">Changes to Our Privacy Statement</Heading>
          <Box lightGray mt={1} mb={2}>
            Any changes we may make to our Privacy Policy in the future will be posted on this page and any such changes will 
            become effective upon posting of the revised Privacy Policy. If we make any material or substantial changes to this 
            Privacy Policy we will use reasonable endeavors to inform you by email, notice on the Website or other agreed 
            communications channels.
          </Box>
        </PageContainer>
      </MainLayout>
    );
  }
}

export default PrivacyPolicyPage;