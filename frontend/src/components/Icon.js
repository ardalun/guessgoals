import styled, { css } from 'styled-components';

const StyledI = styled.i`
  ${props => props.thick && css`
    font-weight: 900;
  `}

  ${props => props.gray && css`
    color: #858585;
  `}
  ${props => props.orange && css`
    color: #FF7E00;
  `}
  ${props => props.yellow && css`
    color: #FF9900;
  `}
  ${props => props.red && css`
    color: #F64747;
  `}
  ${props => props.green && css`
    color: #00B16A;
  `}

  ${props => props.orange2 && css`
    background: linear-gradient(240deg, rgba(240,90,34,1) 0%, rgba(255,153,0,1) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  `}
  
  font-size: ${props => `${props.size}rem` || '0'};
  margin-right: ${props => `${props.mr}rem` || '0'};
  margin-left: ${props => `${props.ml}rem` || '0'};
`;

export default (props) => <StyledI className={props.name} {...props}></StyledI>;