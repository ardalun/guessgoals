import React, { Fragment } from 'react';
import styled from 'styled-components';
import Head from 'layouts/Head';
import logoSrc from 'assets/images/logo-dark-full.svg';
import Link from 'components/Link';

const Background = styled.div`
  min-height: 100vh;
  background: #1E262D;
`;

const Logo = styled.div`
  text-align: center;
  height: 100px;
  line-height: 100px;
`;

const FormBox = styled.div`
  width: 470px;
  padding: 2rem;
  background: #262F37;
  border-radius: 6px;
  margin: 0 auto;
  @media only screen and (max-width: 575px) {
    min-height: calc(100vh - 100px);
    width: 100%;
    border-radius: 0;
  }
`;

export default class AuthLayout extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Fragment>
        <Head />
        <Background>
          <Logo><Link href="/"><img src={logoSrc} /></Link></Logo>
          <FormBox>{this.props.children}</FormBox>
        </Background>
      </Fragment>
    );
  }
}