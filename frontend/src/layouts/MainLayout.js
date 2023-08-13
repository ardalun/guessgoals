import React, { Fragment } from 'react';
import styled, { css } from 'styled-components';
import Head from 'layouts/Head';
import Screen from 'lib/screen'; 
import TopMenu from 'components/TopMenu/TopMenu';
import LeaguesMenu from 'components/LeaguesMenu';
import Footer from 'components/Footer';

const Background = styled.div`
  min-height: 100vh;
  background: linear-gradient(90deg, rgba(30,38,45,1) 0%, rgba(30,38,45,1) 50%, rgba(38,47,55,1) 50%, rgba(38,47,55,1) 100%);
`;

const Container = styled.div`
  max-width: 1440px;
  margin: 0 auto;
  background: red;
  display: flex;
`;

const Sidebar = styled.div`
  min-width: 300px;
  max-width: 300px;
  background: #1E262D;
  padding: 1.5rem 2.5rem;
  color: white;
  ${Screen.max("lg")} {
    display: none;
  }
`;

const Content = styled.div`
  background: #262F37;
  width: 100%;
  padding: 1.5rem 2.5rem;
  min-height: 100vh;
  color: white;

  ${Screen.max('lg')} {
    padding: 0rem;
    padding-top: 4.5625rem;
  }
`;

export default class MainLayout extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Fragment>
        <Head />
        <Background>
          <Container>
            <Sidebar>
              <LeaguesMenu />
            </Sidebar>
            <Content>
              <TopMenu />
              {this.props.children}
            </Content>
          </Container>
        </Background>
        <Footer />
      </Fragment>
    );
  }
}