import styled, { css, keyframes } from 'styled-components';
import { fadeInUp } from 'react-animations';
import Screen from 'lib/screen';


const fadeInUpAnimation = keyframes`${fadeInUp}`;
export default styled.div`
  font-size: 1rem;
  
  margin-top: ${props => `${props.mt}rem` || '0'};
  margin-right: ${props => `${props.mr}rem` || '0'};
  margin-bottom: ${props => `${props.mb}rem` || '0'};
  margin-left: ${props => `${props.ml}rem` || '0'};
  
  padding-top: ${props => `${props.pt}rem` || '0'};
  padding-right: ${props => `${props.pr}rem` || '0'};
  padding-bottom: ${props => `${props.pb}rem` || '0'};
  padding-left: ${props => `${props.pl}rem` || '0'};
  
  ${props => props.inline && css`
    display: inline-block;
  `}
  ${props => props.center && css`
    text-align: center;
  `}
  ${props => props.right && css`
    text-align: right;
  `}
  ${props => props.left && css`
    text-align: left;
  `}
  ${props => props.body2 && css`
    font-size: 0.875rem;
  `}
  ${props => props.body3 && css`
    font-size: 0.75rem;
  `}
  ${props => props.body3 && css`
    color: 0.75rem;
  `}
  ${props => props.flex && css`
    display: flex;
    align-items: center;
  `}
  ${props => props.gray && css`
    color: #858585;
  `}
  ${props => props.lightGray && css`
    color: #afafaf;
  `}
  ${props => props.red && css`
    color: #F64747;
  `}
  ${props => props.green && css`
    color: #00B16A;
  `}

  ${props => props.smVisible && css`
    ${Screen.min('sm')} {
      display: none;
    }
  `}

  ${props => props.nonSmVisible && css`
    ${Screen.max('sm')} {
      display: none;
    }
  `}

  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}
`;