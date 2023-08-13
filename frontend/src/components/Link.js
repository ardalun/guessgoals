import Link from 'next/link';
import styled, { css } from 'styled-components';
import Box from 'components/Box';

const AnchorText = styled.a`
  font-family: 'Source Sans Pro';
  color: #FF7E00;
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  font-size: 1rem;
  transition: all 100ms ease;

  &:hover {
    color: #FF7E00 !important;
  }

  &:focus {
    text-decoration: none;
  }

  ${props => props.body2 && css`
    font-size: 0.875rem;
  `}

  ${props => props.body3 && css`
    font-size: 0.75rem;
  `}

  ${props => props.white && css`
    color: white;
  `}

  ${props => props.button && css`
    background: #FF7E00;
    color: white;
    border: none;
    padding: .375rem 1rem 0.625rem;
    border-radius: 3px;
    font-size: 1rem;
    font-family: 'Source Sans Pro';
    font-weight: 400;

    &:hover {
      color: white !important;
      background: #F05A22 !important;
    }
  `}

  ${props => props.button && props.large && css`
    font-size: 1.25rem;
    padding-left: 1.5rem;
    padding-right: 1.5rem;
  `}

  ${props => props.gray && css`
    color: #858585;
  `}

  ${props => props.fluid && css`
    width: 100%;
  `}
`;

export default (props) => {
  if (props.onClick) {
    return (<AnchorText onClick={props.onClick}><Box pl={1} pr={1} pt={0.5} pb={0.5}>{props.children}</Box></AnchorText>);
  } else {
    return (
      <Link href={props.href} as={props.as} passHref>
        <AnchorText 
          white={props.white} 
          gray={props.gray} 
          button={props.button} 
          large={props.large}
          fluid={props.fluid}
          body2={props.body2}
          body3={props.body3}
        >{props.children}</AnchorText>
      </Link>
    );
  }
}