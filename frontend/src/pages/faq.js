import React from 'react';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import Heading from 'components/Heading';
import Box from 'components/Box';
import PageContainer from 'components/PageContainer';
import Link from 'components/Link';

class FAQPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Frequently Asked Questions - GuessGoals'));
    await reduxStore.dispatch(setDescription('See frequently asked questions and our answers for them.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <PageContainer>
          <Box mb={2}><Heading as="h1">Frequently Asked Questions</Heading></Box>
          
          <Heading as="h2">What should I do if the payment screen is not updated after I sent the ticket fee?</Heading>
          <Box lightGray mt={1} mb={2}>
            On the payment screen, you can click on the link "I sent but this screen is not updating" which pulls any updates
            on the given address. If you see an error, your transaction is most likely not yet pushed to the blockchain mempool. 
            If for whatever reason your transaction is pushed to the mempool and still not seen when you click the above link,
            please <Link href="https://guessgoals.com/contact-us">contact us</Link> to let us know.
          </Box>
          
          <Heading as="h2">What is the minimum acceptable deposit amount?</Heading>
          <Box lightGray mt={1} mb={2}>
            The minimum acceptable deposit amount is 0.001 BTC. If you send anything less than this amount for example when adding
            credit to your wallet to pay for tickets your payment may be rejected.
          </Box>

          <Heading as="h2">How many blocks of confirmations are required before a transaction is considered confirmed?</Heading>
          <Box lightGray mt={1} mb={2}>
            We require one block confirmation before the match start.
          </Box>

          <Heading as="h2">Why am I awarded less than the prize pool value?</Heading>
          <Box lightGray mt={1} mb={2}>
            If your prize is less than the prize pool value you must have obtained an equal score with one or more other bettors,
            therefore the prize pool has been shared between all the winners. 
          </Box>

          <Heading as="h2">Why is my bet declined?</Heading>
          <Box lightGray mt={1} mb={2}>
            The funds you have used to pay for the ticket fee has not been confirmed on time (before the match started).
          </Box>

          <Heading as="h2">Will I be re-funded for the ticket fee if my bet is declined?</Heading>
          <Box lightGray mt={1} mb={2}>
            Yes. The bet fee should return to your wallet as soon as your bet is declined. If it has not, 
            please <Link href="https://guessgoals.com/contact-us">contact us</Link> to let us know.
          </Box>
        </PageContainer>
      </MainLayout>
    );
  }
}

export default FAQPage;