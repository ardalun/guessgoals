import { Fragment } from 'react';
import styled, { css } from 'styled-components';
import Screen from 'lib/screen';
import logoFullSrc from 'assets/images/logo-dark-full.svg';
import logoShapeSrc from 'assets/images/logo-shape.svg';

const BrandLogo = styled.img`

  width: ${props => `${props.size}rem` || '11.25rem'};

  ${props => props.hideOnMobile && css`
    ${Screen.max('xs')} {
      display: none;
    }
  `}

  ${props => props.hideOnNonMobile && css`
    ${Screen.min('xs')} {
      display: none;
    }
  `}
`;

export default (props) => {
  if (props.smallerOnMobile) {
    return (
      <Fragment>
        <BrandLogo src={logoFullSrc} hideOnMobile />
        <BrandLogo src={logoShapeSrc} hideOnNonMobile size={2.75} />
      </Fragment>
    );
  } else {
    return (<BrandLogo src={logoFullSrc} />);
  }
}