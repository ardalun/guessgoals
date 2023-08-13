import React from 'react';
import styled, { css } from 'styled-components';
import Heading from 'components/Heading';
import Icon from 'components/Icon';

const TeamGoalContainer = styled.div`
  border-radius: 10rem;
  background: #2F3942;
  padding: 0.5rem 1rem;
  font-family: 'Source Sans Pro';
  display: flex;
  align-items: center;

  &:hover {
    background: #37424C;
  }
`;

const Logo = styled.img`
  width: 1.25rem;
  margin-right: 0.5rem;
`;

class TeamGoal extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { team } = this.props;

    return (
      <TeamGoalContainer>
        <Icon name="im-dragndrop" mr={1} size={0.75}/>
        <Logo src={team && team.logo_url} />
        {team && team.name}
      </TeamGoalContainer>
    );
  }
}

export default TeamGoal;