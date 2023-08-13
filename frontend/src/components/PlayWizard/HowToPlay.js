import React from 'react';
import styled, { css } from 'styled-components';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Link from 'components/Link';
import Screen from 'lib/screen';
import Icon from 'components/Icon';
import Level1Image from 'assets/images/level_1.svg';
import Level2Image from 'assets/images/level_2.svg';
import Level3Image from 'assets/images/level_3.svg';
import Level4Image from 'assets/images/level_4.svg';

const StyledBox = styled(Box)`
  padding: 1rem;
  ${Screen.max('md')} {
    padding: 1rem 0 10rem 0;
  }
`;

const Row = styled.div`
  display: flex;
  flex-flow: row wrap;
`;

const LevelItem = styled.div`
  display: inline-flex;
  flex-direction: column;
  margin-bottom: 1.5rem;
  width: 50%;
  padding-left: 1rem;
  padding-right: 1rem;
  flex-grow: 1;

  ${Screen.max('md')} {
    width: 100%;
  }
`;

const LevelImage = styled.img`
  height: 2.5rem;
  margin-bottom: 0.5rem;
  align-self: flex-start;
`;

const LevelDescription = styled.div`
  flex-grow: 1;
`;

const WizardFooter = styled.div`
  display: flex;
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: #262F37;
  border-radius: 0 0 0.25rem 0.25rem;
  padding: 1rem 1.5rem 1.5rem;
  justify-content: center;

  ${Screen.max('md')} {
    border-radius: 0;
    position: fixed;
    padding: 1rem;
    border-top: 1px solid #40474E;
    background: #1E262D;
    justify-content: flex-end;
  }
`;

const IconWrapper = styled.span`
  ${Screen.min('md')} {
    display: none;
  }
`;

class HowToPlay extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <StyledBox>
          <Heading as="span" sizeLike="h2" animated={200}>How To Play?</Heading>
          <Box animated={300} mt={0.25} mb={1.5} gray>
            Everyone pays a fixed ticket fee to a prize pool and places a four level prediction on a match.
            In each level, most accurate predictions knock others out and move to the next level.
            In order to win, you either have to survive all the levels or knock everyone else out early.
            In each level we ask a simple question:
          </Box>
          <Box animated={300}>
            <Row>
              <LevelItem>
                <LevelImage src={Level1Image} />
                <LevelDescription>
                  <Heading as="span" sizeLike="h3" animated={400}>1 - Which team wins?</Heading>
                  <Box mt={0.25} gray body2>
                    This is the first question we ask. Answer it correctly and you will knock 65% of other players out.
                  </Box>
                </LevelDescription>
              </LevelItem>
              <LevelItem>
                <LevelImage src={Level2Image} />
                <LevelDescription>
                  <Heading as="span" sizeLike="h3">2 - How many goals are scored?</Heading>
                  <Box mt={0.25} gray body2>
                    You do not have to be exact here. Just try to be more accurate than others.
                  </Box>
                </LevelDescription>
              </LevelItem>
            </Row>
            <Row>
              <LevelItem>
                <LevelImage src={Level3Image} />
                <LevelDescription>
                  <Heading as="span" sizeLike="h3">3 - Who score the goals?</Heading>
                  <Box mt={0.25} gray body2>
                    You have already beaten alot of oponents. How hard do you think it is to pick more correct scorers than other players left?
                  </Box>
                </LevelDescription>
              </LevelItem>
              <LevelItem>
                <LevelImage src={Level4Image} />
                <LevelDescription>
                  <Heading as="span" sizeLike="h3">4 - In what order are the goals scored?</Heading>
                  <Box mt={0.25} gray body2>
                    If you are not already a winner survive this last level and you will win this pool.
                  </Box>
                </LevelDescription>
              </LevelItem>
            </Row>
          </Box>
        </StyledBox>
        <WizardFooter>
          <Link button href="/auth/signup" as="/signup">
            Sign up to Get Started <IconWrapper><Icon name="im-arrow-right" size={0.75} ml={0.5} /></IconWrapper>
          </Link>
        </WizardFooter>
      </div>
    );
  }
}

export default HowToPlay;