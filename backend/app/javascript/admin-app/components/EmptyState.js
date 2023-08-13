import React from 'react';
import styled from 'styled-components';

const Box = styled.div`
  padding: 2rem;
  color: rgba(0,0,0,0.4);
  font-size: 1.75rem;
  text-align: center;
  border: 1px solid #eaeaea;
`;

export default class EmptyState extends React.Component {
  render() {
    return (
      <Box>
        {this.props.children}
      </Box>
    );
  }
}