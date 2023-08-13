import { Button } from 'antd';
import styled, { css } from 'styled-components';
import Spinner from './Spinner';

const StyledButton = styled(({large, fluid, secondary, plastic, alignRight, ...props}) => <Button {...props} />)`
  background: #FF7E00;
  color: white;
  box-shadow: none;
  border: none;
  padding: .4375rem 1rem 0.5625rem;
  font-size: 1rem;
  border-radius: 3px;
  font-family: 'Source Sans Pro';
  font-weight: 400;
  height: initial;
  touch-action: none;
  -webkit-transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
  transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);

  &::before {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 1;
    display: none;
    background: #F05A22;
    border-radius: inherit;
    opacity: 1;
    -webkit-transition: opacity 0.2s;
    transition: opacity 0.2s;
    pointer-events: none;
    content: '';
  }

  &:hover {
    background: #F05A22 !important;
    color: white;
  }

  &:focus {
    background: #FF7E00 !important;
    color: white;
  }

  &.ant-btn-loading:not(.ant-btn-circle):not(.ant-btn-circle-outline):not(.ant-btn-icon-only) {
    padding-left: 1rem;
  }
  
  ${props => props.large && css`
    font-size: 1.25rem;
  `}
  
  ${props => props.fluid && css`
    width: 100%;
  `}

  ${props => props.secondary && css`
    background: #2F3942;
    &:focus {
      background: #2F3942 !important;
    }
    &:hover {
      background: #37424C !important;
    }
  `}

  ${props => props.plastic && css`
    background: rgba(255,255,255,0.15);
    &:focus {
      background: rgba(255,255,255,0.15) !important;
    }
    &:hover {
      background: rgba(255,255,255,0.25) !important;
    }
  `}

  ${props => props.alignRight && css`
    float: right;
  `}

  &[disabled]{
    background: #2F3942 !important;
    color: #858585;
    &:focus {
      background: #2F3942 !important;
      color: #858585;
    }
    &:hover {
      background: #2F3942 !important;
      color: #858585;
    }
  }
`;

const PositionedSpinner = styled(Spinner)`
  position: absolute;
  z-index: 1000;
`;

const FakeButton = styled.span`
  display: flex !important;
  justify-content: center;
  align-items: center;
`;

const HiddenButtonText = styled.span`
  visibility: hidden;
`;

const MyButton = (props) => {
  const { loading, children } = props;
  let cont = null;
  if (loading) {
    cont = (
      <FakeButton>
        <HiddenButtonText>{children}</HiddenButtonText>
        <PositionedSpinner />
      </FakeButton>
    );
  } else {
    cont = children;
  }
  return (
    <StyledButton 
      {...props}
      className={loading ? 'ant-btn-loading' : null} 
      loading={false}
    >{cont}</StyledButton>
  );
}

export default MyButton;