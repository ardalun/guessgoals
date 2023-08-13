import React from 'react';
import styled, { css, keyframes } from 'styled-components';
import Screen from 'lib/screen';
import Heading from 'components/Heading';
import { fadeInUp } from 'react-animations';
import Box from 'components/Box';

const fadeInUpAnimation = keyframes`${fadeInUp}`;

const Sticker = styled.div`
  background: #1E262D;
  border-radius: 0.5rem;
  padding: 1rem;
  flex-grow: 1;
  margin: 1rem;
  text-align: center;
  min-width: 100px;
  
  ${props => props.animated && css`
    animation: ${props.animated}ms ${fadeInUpAnimation};
  `}

  ${props => props.onClick && css`
    background: #2F3942;
    cursor: pointer;
    &:hover {
      background: #37424C;
    }
  `}
  
  ${props => props.selected && css`
    background: #1E262D;
    border: 2px solid #FF7E00;
  `}

  ${Screen.max('md')} {
    margin: 0.5rem;
    padding: 0.75rem;
  }
  ${Screen.max('xs')} {
    margin: 0.25rem;
    padding: 0.75rem;
  }
`;

const Logo = styled.img`
  object-fit: contain;
  height: 6rem;
  width: 5rem;
  ${Screen.max('md')} {
    height: 4.5rem;
  }
`;

const LabelBox = styled(Box)`
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
  color: #858585;
  ${props => props.selected && css`
    color: #FF7E00;
  `}
`;

const Label = styled.span`
  font-size: .875rem;
  font-family: 'Source Sans Pro';
  font-weight: 600;
  color: #858585;

  ${Screen.max('md')} {
    font-size: .75rem;
  }

  ${props => props.selected && css`
    color: #FF7E00;
  `}
`;

class TeamSticker extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { logoUrl, animated, name, selected, onClick } = this.props;
    return (
      <Sticker animated={animated} selected={selected} onClick={!selected ? onClick : undefined}>
        <Logo src={logoUrl}/>
        <LabelBox mt={0.5} selected={selected}>
          <Label selected={selected}>{name}</Label>
        </LabelBox>
      </Sticker>
    );
  }
}

export default TeamSticker;