import React from 'react';
import styled from 'styled-components';
import Box from 'components/Box';

const EmptyStateContainer = styled.div`
  color: #575F66;
  text-align: center;
`;

const EmptyHeading = styled.span`
  font-size: 1.25rem;
  font-family: 'Source Sans Pro';
  font-weight: 600;
`;

class EmptyState extends React.Component {
  constructor(props) {
    super(props);
  }
  
  render() {
    if (!this.props.show) return null;
    return (
      <Box mt={this.props.marginTop || 0}>
        <EmptyStateContainer>
          <img src={this.props.illustrationUrl} />
          <Box mt={1}>
            <EmptyHeading>{this.props.title}</EmptyHeading>
          </Box>
          <Box>{this.props.message}</Box>
        </EmptyStateContainer>
      </Box>
    );
  }
}

export default EmptyState;