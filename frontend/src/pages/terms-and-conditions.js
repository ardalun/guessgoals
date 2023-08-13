import React from 'react';
import MainLayout from 'layouts/MainLayout';
import { setTitle, setDescription } from 'redux/page';
import Heading from 'components/Heading';
import Box from 'components/Box';
import PageContainer from 'components/PageContainer';
import Link from 'components/Link';

class TermsAndConditionsPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    await reduxStore.dispatch(setTitle('Terms and Conditions - GuessGoals'));
    await reduxStore.dispatch(setDescription('Learn more about our Terms of Use.'));
    return {};
  }

  render() {
    return (
      <MainLayout>
        <PageContainer>
          <Heading as="h1">Terms and Conditions</Heading>
          <Box body3 gray mb={1}>Last updated: 2019-09-25</Box>
          <Box lightGray mb={2}>
            In order to place bets with the digital currency Bitcoin or fractions thereof, you will need to create an account on 
            Guessgoals.com (the “Website”). By using and/or visiting any part, page or section of the website, and/or opening an
            account with GuessGoals, you are deemed to have understood, accepted and agreed to be bound by these Terms and Conditions.
          </Box>
          <Heading as="h2">1. Agreement</Heading>
          <Box lightGray mt={1}>
            1.1. You must read these Terms and Conditions carefully in their entirety before creating an account. If you do not 
            agree with any provision of these Terms and Conditions, you must not create an account or continue to use the website.
          </Box>
          <Box lightGray mt={1} mb={2}>
            1.2. We are entitled to make amendments to these Terms and Conditions at any time and without advanced notice. 
            If we make such amendments, we may take appropriate steps to bring such changes to your attention (such as by 
            email or placing a notice on a prominent position on the Website, together with the amended terms and conditions) 
            but it shall be your sole responsibility to check for any amendments, updates and/or modifications. Your continued 
            use of the GuessGoals website after any such amendment to the Terms and Conditions will be deemed as your acceptance
            and agreement to be bound by such amendments, updates and/or modifications.
          </Box>

          <Heading as="h2">2. Binding Declarations</Heading>
          <Box lightGray mt={1}>
            You hereby represent and warrant that:
          </Box>
          <Box lightGray mt={1}>
            2.1. You are over (a) 18 or (b) such other legal age or age of majority as determined by any laws which are applicable 
            to you, whichever age is greater.
          </Box>
          <Box lightGray mt={1}>
            2.2. You have full capacity to enter into a legally binding agreement with us and you are not restricted by any form of 
            limited legal capacity.
          </Box>
          <Box lightGray mt={1}>
            2.3. You understand that by using our services you may lose bitcoin on bets placed and accept that you are fully 
            responsible for any such loss.
          </Box>
          <Box lightGray mt={1}>
            2.4. You participate in the Games strictly in your personal and non-professional capacity; and participate for recreational and entertainment purposes only;
          </Box>
          <Box lightGray mt={1}>
            2.5. You participate in the Games and make bets on your own behalf and not on the behalf of any other person.
          </Box>
          <Box lightGray mt={1}>
            2.6. You will not use our services while located in any jurisdiction that prohibits the placing and/or accepting of bets
            denominated in bitcoin online, and/or playing casino and/or poker games for and/or with bitcoin.
          </Box>
          <Box lightGray mt={1}>
            2.7. You are permitted in the jurisdiction in which you are located to use online sports betting.
          </Box>
          <Box lightGray mt={1}>
            2.8. You are not depositing bitcoin which originates from criminal and/or other illegal and/or unauthorized activities 
            and/or intending to use your account in connection with such activities and that you shall not use and/or allow other 
            persons to use the services provided by us and your account for any criminal and/or otherwise unlawful activities including,
            without limitation, money laundering, under any law applicable to you or us.
          </Box>
          <Box lightGray mt={1}>
            2.9. You understand that the value of Bitcoin can change dramatically depending on the market value.
          </Box>
          <Box lightGray mt={1}>
            2.10. You understand that Bitcoin is not considered a legal currency or tender and as such on the Website they are treated 
            as virtual funds with no intrinsic value.
          </Box>
          <Box lightGray mt={1}>
            2.11. You are not an officer, director, employee, consultant, affiliate or agent of GuessGoals or working for any company
            related to GuessGoals, or a relative or spouse of any of the foregoing.
          </Box>
          <Box lightGray mt={1}>
            2.12. You are not diagnosed or classified as a compulsive or problem gambler or consider yourself to be the same.
          </Box>
          <Box lightGray mt={1}>
            2.13. You accept and acknowledge that we reserve the right to detect and prevent the use of prohibited techniques, 
            including but not limited to fraudulent transaction detection, automated registration and signup, gameplay and screen 
            capture techniques. These steps may include, but are not limited to, examination of Players device properties, 
            detection of geo-location and IP masking, transactions and blockchain analysis.
          </Box>
          <Box lightGray mt={1} mb={2}>
            2.14. You accept our right to terminate and/or change any games or events being offered on the Website, and 
            to refuse and/or limit bets.
          </Box>

          <Heading as="h2">3. Privacy</Heading>
          <Box lightGray mt={1}>
            3.1. Information that you provide to us will be kept confidential and otherwise processed in accordance with 
            our <Link href="/privacy-policy">Privacy Policy</Link> which is accessible on our Website.
          </Box>
          <Box lightGray mt={1}>
            3.2. By agreeing to these Terms and Conditions, you agree that you have read, understood and agree to be bound by 
            our <Link href="/privacy-policy">Privacy Policy</Link> which is accessible on our Website.
          </Box>
          <Box lightGray mt={1}>
            3.3. Your personal data will not be disclosed to third parties, unless such a disclosure is either required by law 
            or is necessary for the use of our service, in which case, you are deemed to have consented to such disclosures to
            a third party.
          </Box>
          <Box lightGray mt={1} mb={2}>
            3.4. You accept that our website uses cookies and we therefore collect certain basic information transmitted to our
            server from your browser.
          </Box>

          <Heading as="h2">4. Accounts</Heading>
          <Box lightGray mt={1}>
            4.1. In order for you to be able to place bets at GuessGoals.com, you must first personally register an account with us.
          </Box>
          <Box lightGray mt={1}>
            4.2. We do not wish to and shall not accept registration from visitors resident in jurisdictions that prohibit you from 
            participating in online sports betting, gambling, gaming, and/or games of skill, for and/or with bitcoin.
          </Box>
          <Box lightGray mt={1}>
            4.3. You are aware that the right to access and use the website and any products there offered, may be considered illegal in
            certain countries. We are not able to verify the legality of service in each and every jurisdiction, consequently, you
            are responsible in determining whether your accessing and using our website is compliant with the applicable laws in 
            your country and you warrant to us that gambling is not illegal in the territory where you reside. For various legal 
            or commercial reasons, we do not permit accounts to be opened or used by customers resident in certain jurisdictions, 
            including the United States of America (and her dependencies, military bases and territories), Australia, United Kingdom,
            Estonia, or other restricted jurisdictions (“Restricted Jurisdiction”) as communicated by us from time to time. 
            By using the Website you confirm you are not a resident in a Restricted Jurisdiction.
          </Box>
          <Box lightGray mt={1}>
            4.4. When attempting to open an account or using the Website, it is the responsibility of the player to verify whether 
            gambling is legal in that particular jurisdiction. If you open or use the Website while residing in a 
            Restricted Jurisdiction: your account may be closed by us immediately; any winnings and bonuses will be confiscated and 
            remaining balance returned (subject to reasonable charges), and any returns, winnings or bonuses which you have gained 
            or accrued will be forfeited by you and may be reclaimed by us; and you will return to us on demand any such funds which 
            have been withdrawn.
          </Box>
          <Box lightGray mt={1}>
            4.5. You agree to provide complete and accurate registration information to us. You agree to inform us promptly, 
            in writing, of any changes to such information.
          </Box>
          <Box lightGray mt={1}>
            4.6. You will inform us as soon as you become aware of any errors with respect to your account or any calculations
            with respect to any bet you have placed. We reserve the right to declare null and void any bets that are the subject
            of such an error.
          </Box>
          <Box lightGray mt={1}>
            4.7. You are allowed to have only one account at GuessGoals.com. If you attempt to open more than one account, all of 
            your accounts may be blocked, suspended or closed and any funds credited to your account/s will be frozen.
          </Box>
          <Box lightGray mt={1}>
            4.8. As part of the registration process, you will have to choose a username which will be shown in the scoreboards 
            to all participants of the games you took part in. You will have to choose a username which is not racist, sexist, 
            disruptive or offensive. You accept that if you fail to do so, we reserve the right to block, suspend or close your 
            account at any time which will result in any funds credited to your account being frozen immediately.
          </Box>
          <Box lightGray mt={1} mb={2}>
            4.9. You must not disclose your login details to anyone. We are not liable or responsible for any abuse or misuse of 
            your account by third parties due to your disclosure, whether intentional, accidental, active or passive, of your login
            details to any third party.
          </Box>

          <Heading as="h2">5. Bitcoin Funds</Heading>
          <Box lightGray mt={1}>
            5.1. Should your account become overdrawn due to a duplicate payment error, for example, if a withdrawal request 
            being processed twice for whatever reason, you agree to fully reimburse GuessGoals for any such overdrawn amounts.
          </Box>
          <Box lightGray mt={1} mb={2}>
            5.2. GuessGoals is not a banking institution. You will not be paid interest on any outstanding account balances.
          </Box>

          <Heading as="h2">6. Client Account Management</Heading>
          <Box lightGray mt={1}>
            6.1. Any amounts which are mistakenly credited as winnings to your account remain the property of GuessGoals and will
            automatically be deducted from your account upon the error being detected. Any winnings mistakenly credited to your 
            account and subsequently withdrawn by you will constitute a valid legally-enforceable debt owed by you to GuessGoals
            in the amount of such wrongfully attributed winnings. We reserve the right to instigate debt recovery procedures in
            such circumstances if you fail to voluntarily satisfy the outstanding debt.
          </Box>
          <Box lightGray mt={1}>
            6.2. Payment of any taxes, fees, charges or levies that may apply to your winnings under any applicable laws shall be
            your sole responsibility.
          </Box>
          <Box lightGray mt={1}>
            6.3. It is possible to deposit or withdraw only bitcoin from your account. We do not accept any other form of consideration. 
          </Box>
          <Box lightGray mt={1}>
            6.4. The minimum deposit amount in Bitcoin is ฿0.001 (m฿1, µ฿1,000). Deposits of smaller value may be refused.
          </Box>
          <Box lightGray mt={1}>
            6.5. We will not accept withdrawal requests made otherwise than via the facilities provided in the Wallet page of 
            the Website. Our employees and any agents are not authorised to effect movements of bitcoin in any other manner.
          </Box>
          <Box lightGray mt={1} mb={2}>
            6.6. You agree that upon requesting a withdrawal, you must provide an address that belongs to yourself and is not
            provided to you by GuessGoals.com. GuessGoals will not be responsible for withdrawal of funds to an address that
            does not belong to you and was entered by mistake.
          </Box>

          <Heading as="h2">7. Closing Accounts</Heading>
          <Box lightGray mt={1} mb={2}>
            7.1. If you wish to close your account, you may do so at any time by contacting Customer Support in written form 
            via <Link href="https://guessgoals.com/contact-us">https://guessgoals.com/contact-us</Link>. The effective closure 
            of the Account will correspond to the termination of the Terms and Conditions. If the reason behind the closure of
            the Account is related to problem gambling, you shall indicate this in writing when requesting the account closure.
          </Box>

          <Heading as="h2">8. General Betting Rules</Heading>
          <Box lightGray mt={1}>
            8.1. A bet, which has been placed and accepted, cannot be amended, withdrawn or cancelled by you. The list of all the
            bets, their status and details are available to you on the Website.
          </Box>
          <Box lightGray mt={1}>
            8.2. Should GuessGoals become aware that you have placed a number of bets from different accounts you have irregularly
            opened, all bets will be voidable at the unfettered discretion of GuessGoals. GuessGoals retains the right to take 
            further action as it deems necessary.
          </Box>
          <Box lightGray mt={1}>
            8.3. If a match does not start on the scheduled starting date or starts but is later postponed and/or abandoned and is
            not completed (resumed) by the end of the next calendar date, all bets will be void.
          </Box>
          <Box lightGray mt={1} mb={2}>
            8.4. Your bets will only be accepted if any bitcoin funds used to pay for the ticket has at least received one block
            confirmation by the match start time.
          </Box>

         <Heading as="h2">9. Limitation of Liability</Heading>
          <Box lightGray mt={1}>
            9.1. You enter the Website and place bets at your own risk. The Website is provided
            without any warranty whatsoever, whether express or implied.
          </Box>
          <Box lightGray mt={1}>
            9.2. Under no circumstances will GuessGoals be liable for any damage caused by any incorrect, delayed, or abusive 
            transfer of data via the internet. GuessGoals is permitted to commence any technologically reasonable action to
            protect customer information, but will not be liable and will not take responsibility if third parties obtain 
            control of, any process, or user information despite such action. No claims for damages may be asserted against 
            GuessGoals, in any such circumstances.
          </Box>
          <Box lightGray mt={1}>
            9.3. GuessGoals reserves the right to declare a wager void, partially or in full, if GuessGoals deems it obvious that
            there was an error, mistake, misprint or technical error on the software. We shall not be liable to you whatsoever
            for any unrealised winnings as a result of voiding a wager in this scenario. Refunds are given solely at the 
            discretion of the GuessGoals management.
          </Box>
          <Box lightGray mt={1} mb={2}>
            9.4. You hereby agree to fully hold harmless us, our directors, employees, partners, and service providers for 
            any cost, expense, loss, damages, claims and liabilities howsoever caused that may arise in relation to your use 
            of the Website or participation in the Games.
          </Box>
          
          <Heading as="h2">10. Force majure</Heading>
          <Box lightGray mt={1} mb={2}>
            10.1. Any failure or delay in performance by GuessGoals in respect of its obligations of service shall not be deemed 
            a breach of its obligations to you as customer if such a failure or delay is deemed by GuessGoals to be caused by 
            force majeure, which shall include but not be limited to flood, fire, earthquake, or any other element of nature, 
            act of war, riots or terrorist attack, public utility electrical failure, lockouts and strikes, delays or disruptions
            of the Internet and telecommunications networks caused by human or natural factors, or any other such event beyond 
            the reasonable control of GuessGoals. GuessGoals shall not be liable for any consequences arising out of any such 
            force majeure events.
          </Box>

          <Heading as="h2">11. Complaints</Heading>
          <Box lightGray mt={1} mb={2}>
            11.1. If you have a complaint to make regarding our services, you may contact our customer support 
            via <Link href="https://guessgoals.com/contact-us">https://guessgoals.com/contact-us</Link>
          </Box>
        </PageContainer>
      </MainLayout>
    );
  }
}

export default TermsAndConditionsPage;