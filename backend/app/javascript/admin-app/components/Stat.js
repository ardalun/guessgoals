import React from 'react';
import styled, { css } from 'styled-components';

const StyledLink = styled.a`
  color: unset;

  &:hover {
    text-decoration: none;
    color: unset;
  }
`;

const StatContainer = styled.div`
  border: 1px solid #eaeaea;
  padding: 1rem 2rem;

  ${props => props.isLink && css`
    &:hover {
      background: rgba(0,0,0,0.05);
    }
  `}
`;

const StatValue = styled.div`
  font-size: 3rem;
`;

const StatLabel = styled.div`
  color: rgba(0,0,0,0.5);
`;

export default class Stat extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    if (this.props.href) {
      return (<StyledLink href={this.props.href}>{this.renderContent(true)}</StyledLink>)
    } else {
      return this.renderContent(false);
    }
  }

  renderContent = (isLink=false) => {
    return (
      <StatContainer isLink={isLink}>
        <StatValue>{this.props.value}</StatValue>
        <StatLabel>{this.props.label}</StatLabel>
      </StatContainer>
    );
  }
}