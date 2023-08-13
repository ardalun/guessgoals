import React, { Fragment } from 'react';
import Link from 'components/Link';
import styled from 'styled-components';
import Icon from 'components/Icon';
import Box from 'components/Box';

const ItemContainer = styled.div`
  display: flex;
  align-items: center;
`;

class LeagueItem extends React.Component {
  constructor(props) {
    super(props);
  }
  
  handleSelect = () => {
    if (this.props.onSelect) {
      this.props.onSelect();
    }
  }

  render() {
    return (
      <Fragment>
        { this.renderActiveItem() }
        { this.renderInactiveItem() }
      </Fragment>
    );
  }

  renderInactiveItem = () => {
    const { league, active, onSelect } = this.props;

    if (active) return;

    return (
      <ItemContainer onClick={this.handleSelect}>
        <Link fluid href={`/matches?league_handle=${league.handle}`} as={`/football/${league.handle}`} gray>
          <Box flex pt={0.25} pb={0.25}><Icon size={1.75} name={`im-${league.handle}`} mr={0.5} /> {league.name}</Box>
        </Link>
      </ItemContainer>
    );
  }

  renderActiveItem = () => {
    const { league, active } = this.props;
    if (!active) return;

    return (
      <ItemContainer>
        <Box flex pt={0.25} pb={0.25}><Icon size={1.75} name={`im-${league.handle}`} orange mr={0.5} /> {league.name}</Box>
      </ItemContainer>
    );
  }
}

export default LeagueItem;