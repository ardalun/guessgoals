import Box from 'components/Box';
import Icon from 'components/Icon';
import styled from 'styled-components';

const StyledBox = styled(Box)`
  height: 2.25rem;
  display: inline-flex;
  align-items: center;
  cursor: pointer;
  position: relative;

  &:hover {
    color: #FF7E00;
  }
`;

const NotifBadge = styled.div`
  background: #F05A22;
  color: white;
  height: 1rem;
  border-radius: 10rem;
  font-size: 0.75rem;
  padding: 0 0.3rem;
  position: absolute;
  display: flex;
  align-items: center;
  justify-content: center;
  top: 0.25rem;
  left: 1.75rem;
`;


const TopMenuItem = (props) => {
  let iconMargin = 0;
  if (props.badge) {
    iconMargin = (props.badge.toString().length) * 0.41;
  } else if (props.name) {
    iconMargin = 0.5;
  }
  return (
    <StyledBox 
      pr={props.pr || props.pr === 0 ? 0 : 1} 
      pl={props.pl || props.pl === 0 ? 0 : 1} 
      onClick={props.onClick}
    >
      <Icon 
        name={props.icon} 
        size={ props.iconSize || 1 } 
        mr={iconMargin} 
      />
      <span>{props.name}</span>
      { props.badge ? <NotifBadge>{props.badge}</NotifBadge> : null }
    </StyledBox>
  );
}

export default TopMenuItem;