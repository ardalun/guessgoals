import styled, { css, keyframes } from 'styled-components';
import { fadeInUp } from 'react-animations';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const h1 = (props) => <h1></h1>;
const h2 = (props) => <h2></h2>;
const h3 = (props) => <h3></h3>;
const h4 = (props) => <h4></h4>;
const h5 = (props) => <h5></h5>;
const span = (props) => <span></span>;

export default (props) => {
  let tag = h1;
  if (props.as === 'h2') { tag = h2; }
  else if (props.as === 'h3') { tag = h3; }
  else if (props.as === 'h4') { tag = h4; }
  else if (props.as === 'h5') { tag = h5; } 
  else if (props.as === 'span') { tag = span; }

  const Result = styled(tag)`
    color: white;
    font-size: 1rem;
    font-family: 'Source Sans Pro';
    font-weight: 600;
    line-height: 1.2;
    margin-bottom: 0;
    display: flex;
    align-items: center;

    ${props => props.as === 'h1' && css`
      font-size: 1.875rem;
    `}
    ${props => props.as === 'h2' && css`
      font-size: 1.25rem;
    `}
    ${props => props.as === 'h3' && css`
      font-size: 1rem;
    `}
    ${props => props.as === 'h4' && css`
      font-size: .875rem;
    `}
    ${props => props.as === 'h5' && css`
      font-size: .75rem;
    `}

    ${props => props.sizeLike === 'h1' && css`
      font-size: 1.875rem;
    `}
    ${props => props.sizeLike === 'h2' && css`
      font-size: 1.25rem;
    `}
    ${props => props.sizeLike === 'h3' && css`
      font-size: 1rem;
    `}
    ${props => props.sizeLike === 'h4' && css`
      font-size: .875rem;
    `}
    ${props => props.sizeLike === 'h5' && css`
      font-size: .75rem;
    `}
    
    ${props => props.center && css`
      text-align: center;
      justify-content: center;
    `}
    ${props => props.right && css`
      text-align: right;
      justify-content: flex-end;
    `}
    ${props => props.left && css`
      justify-content: flex-start;
    `}
    ${props => props.gray && css`
      color: #858585;
    `}
    ${props => props.dark && css`
      color: rgba(0, 0, 0, 0.65);
    `}
    ${props => props.orange && css`
      color: #FF7E00;
    `}
    ${props => props.inline && css`
      display: inline-flex;
    `}

    ${props => props.animated && css`
      animation: ${props.animated}ms ${fadeInUpAnimation};
    `}
  `;
  return <Result {...props} />
}