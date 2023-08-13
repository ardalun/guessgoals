import styled, { css } from 'styled-components';

export default styled.div`
  margin: 0px auto;
  font-size: 13px;
  position: relative;
  text-indent: -9999em;
  border-top: .2em solid rgba(255, 255, 255, 0.2);
  border-right: .2em solid rgba(255, 255, 255, 0.2);
  border-bottom: .2em solid rgba(255, 255, 255, 0.2);
  border-left: .2em solid #ffffff;
  width: 18px;
  height: 18px;
  -webkit-transform: translateZ(0);
  -ms-transform: translateZ(0);
  transform: translateZ(0);
  -webkit-animation: c_loader_animation 0.5s infinite linear;
  animation: c_loader_animation 0.5s infinite linear;
  border-radius: 50%;

  &:after {
    border-radius: 50%;
    width: 10em;
    height: 10em;
  }

  ${props => props.large && css`
    width: 36px;
    height: 36px;
    font-size: 14px;
  `}
`;