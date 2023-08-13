import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled from 'styled-components';
import Box from 'components/Box';
import Screen from 'lib/screen';
import Heading from 'components/Heading';
import Button from 'components/Button';
import Link from 'components/Link';


const BannerContainer = styled.div`
  margin-top: 1.5rem;
  border-top: 2px solid #FF7E00;
  border-bottom: 1px solid #40474E;
  background: #1E262D;

  ${Screen.max('lg')} {
    margin-top: 0;
  }
`;

const Banner = (props) => {
  if (props.user) {
    return null;
  }

  return (
    <BannerContainer>
      <Box pl={2.5} pr={2.5} pb={2.5} pt={2.5}>
        <Heading as="h1" sizeLike="h2">Play Football Lottery With Bitcoin</Heading>
        <Box gray mb={1} mt={0.5}>Your ticket is your prediction.</Box>
        <Link button large href="/auth/signup" as="/signup">Get Started</Link>
      </Box>
    </BannerContainer>
  );
}

const mapStateToProps = (store, ownProps) => ({
  user: deepRead(store, 'session.user')
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(Banner);