import styled, { css } from 'styled-components';
import Screen from 'lib/screen'; 
import BrandLogo from 'components/BrandLogo';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Link from 'components/Link';

const FooterBG = styled.div`
  background: #171D23;
`;

const FooterContainer = styled.div`
  max-width: 1440px;
  margin: 0 auto;
  display: flex;
  padding: 4rem;
  color: white;
  ${Screen.max("md")} {
    display: block;
    padding: 2rem 1rem;
  }
`;

const BrandCol = styled.div`
  width: 50%;
  padding-right: 2.5rem;
  ${Screen.max("md")} {
    width: 100%;
    padding: 0;
  }
`;

const RightSection = styled.div`
  flex-grow: 1;
  display: inline-flex;
  justify-content: flex-end;
  ${Screen.max("md")} {
    margin-top: 2rem;
    width: 100%;
  }
`;

const SectionCol = styled.div`
  width: 25%;
  ${Screen.max("md")} {
    width: 100%;
    padding: 0;
  }
`;

const CopyRightContainer = styled.div`
  max-width: 1440px;
  margin: 0 auto;
`;
const CopyRight = styled.div`
  color: #858585;
  margin: 0 4rem;
  padding: 1rem 0;
  font-size: 0.75rem;
  border-top: 1px solid #40474E;
  ${Screen.max("md")} {
    margin: 0 1rem;
  }
`;

const Footer = (props) => (
  <FooterBG>
    <FooterContainer>
      <BrandCol>
        <BrandLogo/>
        <Box mt={1} body3 gray>
          GuessGoals is an innovative bitcoin-based betting game for football where players 
          pay a fixed price into a prize pool and then place a four level prediction on a match.
          This game is exactly like a lottery where player's prediction would act as their ticket. 
          In GuessGoals, the minimum prize pool is 2x the ticket fee with a 50 percent chance of winning.
          As more and more players bet on a match, the prize pool is raised while player's chance is affected
          due to competing with more bettors. Therefore, GuessGoals either offers a high chance of winning or
          a chance of winning big.

        </Box>
      </BrandCol>
      <RightSection>
        <SectionCol>
          <Heading as="h3" sizeLike="h3">Support</Heading>
          {/* <Box mt={1} mb={0.5}><Link href="/how-to-play" gray>How To Play</Link></Box> */}
          <Box mt={0.5} mb={0.5}><Link href="/faq" gray>FAQ</Link></Box>
          <Box mt={0.5} mb={0.5}><Link href="/contact-us" gray>Contact Us</Link></Box>
        </SectionCol>
        <SectionCol>
          <Heading as="h3" sizeLike="h3">About</Heading>
          <Box mt={1} mb={0.5}><Link href="/terms-and-conditions" gray>Terms and Conditions</Link></Box>
          <Box mt={0.5} mb={0.5}><Link href="/privacy-policy" gray>Privacy Policy</Link></Box>
        </SectionCol>
      </RightSection>
    </FooterContainer>
    <CopyRightContainer>
      <CopyRight>
        Copyright © 2019 guessgoals.com
      </CopyRight>
    </CopyRightContainer>
  </FooterBG>
);

export default Footer;