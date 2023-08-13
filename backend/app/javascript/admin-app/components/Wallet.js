import React from 'react';
import styled from 'styled-components';

const WalletContainer = styled.div`
  border: 1px solid #eaeaea;
`;

const Divider = styled.div`
  border-right: 1px solid #eaeaea;
`;

const StatValue = styled.div`
  font-size: 2rem;
`;

const StatLabel = styled.div`
  color: rgba(0,0,0,0.5);
`;

const Section = styled.div`
  flex-grow: 1;
  text-align: center;
  width: 33%;
`;

const WalletSections = styled.div`
  display: flex;
  padding: 1rem 0;
`;

const WalletName = styled.div`
  background: rgba(0,0,0,0.05);
  padding: 0 0.5rem;
  font-size: 0.875rem;
`;

export default class Stat extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <WalletContainer>
        <WalletName>{this.props.name}</WalletName>
        <WalletSections>
          <Section>
            <StatValue>{this.props.total}</StatValue>
            <StatLabel>Total</StatLabel>
          </Section>
          <Divider />
          <Section>
            <StatValue>{this.props.unconfirmed}</StatValue>
            <StatLabel>Unconfirmed</StatLabel>
          </Section>
          <Divider />
          <Section>
            <StatValue>{this.props.unlocked}</StatValue>
            <StatLabel>Payout Ready</StatLabel>
          </Section>
        </WalletSections>
      </WalletContainer>
    );
  }
}