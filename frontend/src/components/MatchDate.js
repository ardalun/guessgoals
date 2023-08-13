import styled, { css } from 'styled-components';
import Heading from 'components/Heading';

const MatchDateContainer = styled.div`
  background: #1E262D;
  border-top: 2px solid #FF7E00;
  padding: 0.5rem 1rem;
`;

export default (props) => {
  return (
    <MatchDateContainer>
      <Heading as="span" sizeLike="h4">{props.dateString}</Heading>
    </MatchDateContainer>
  );
}