import styled, { css } from 'styled-components';
import Screen from 'lib/screen';

export default styled.div`
  margin-top: 1.5rem;
  padding: 1rem;

  ${Screen.max('lg')} {
    margin: 0;
  }
`;