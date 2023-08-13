import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import Box from 'components/Box';
import BrandLogo from 'components/BrandLogo';
import Heading from 'components/Heading';
import LeagueItem from 'components/LeagueItem';

class LeaguesMenu extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { leagues, leagueHandle, onItemSelect } = this.props;
    return (
      <div>
        <Box mb={2.5}>
          <Link href="/matches?league_handle=all" as="/football"><BrandLogo /></Link>
        </Box>
        <Box mb={0.75}><Heading as="span" sizeLike="h2">Football</Heading></Box>
        {
          leagues.map(league => (
            <LeagueItem 
              key={`league_${league.id}`} 
              league={league} 
              active={leagueHandle === league.handle} 
              onSelect={onItemSelect}
            />
            )
          )
        }
      </div>
    );
  }
} 

const mapStateToProps = (store, ownProps) => ({
  leagues: Object.values(deepRead(store, 'navigation.leagues')),
  leagueHandle: deepRead(store, 'page.query.league_handle'),
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(LeaguesMenu);