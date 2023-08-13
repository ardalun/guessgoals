import React from 'react';
import styled from 'styled-components';
import { Badge } from 'react-bootstrap';

const BadgeContainer = styled.div`
  display: flex;
  height: 1.5rem;
`;

const LeftBadgesMenu = styled.div`
  padding-left: 0.3rem;
`;

const RightBadgesMenu = styled.div`
  flex-grow: 1;
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
  padding-right: 0.3rem;
`;

const StatBadge = styled(Badge)`
  display: inline-table;
`;

export default class BadesBar extends React.Component {
  constructor(props) {
    super(props);
    this.state = { };
  }

  render() {
    const { leftBadges, rightBadges } = this.props;
    return (
      <BadgeContainer>
        <LeftBadgesMenu>
          {
            leftBadges.map((badge, i) => {
              return (
                <StatBadge key={`left_badges_${i}`} variant={badge.variant} className="mr-1">{badge.label}</StatBadge>
              );
            })
          }
        </LeftBadgesMenu>
        <RightBadgesMenu>
          {
            rightBadges.map((badge, i) => {
              return (
                <StatBadge key={`right_badges_${i}`} variant={badge.variant} className="ml-1">{badge.label}</StatBadge>
              );
            })
          }
        </RightBadgesMenu>
      </BadgeContainer>
    );
  }
}