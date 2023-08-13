import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled, { css } from 'styled-components';
import Screen from 'lib/screen';
import Box from 'components/Box';
import BrandLogo from 'components/BrandLogo';
import Heading from 'components/Heading';
import Link from 'components/Link';

const ResourceSelectorContainer = styled.div`
  /* border-top: 1px solid #40474E; */
  margin-top: 1.5rem;
  margin-bottom: 1.5rem;

  ${Screen.max('lg')} {
    margin: 0;
    background: #1E262D;
    border-top: none;
    border-bottom: 1px solid #40474E;
  }
`;

const Resource = styled.span`
  font-family: 'Source Sans Pro';
  display: inline-block;
  position: relative;
  padding: 0.5rem 1rem;
  z-index: 1;
  
  ${props => props.active && css`
    border-top: 2px solid #FF7E00;
    color: white;
  `}
`;

class ResourceSelector extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <ResourceSelectorContainer>
        {/* { this.renderOption('Matches', '/matches') } */}
        {/* { this.renderOption('Highlights', '/highlights') } */}
      </ResourceSelectorContainer>
    );
  }

  renderOption = (label, pathName) => {
    const { currentLeagueHandle } = this.props;
    if (this.props.currentPathName === pathName) {
      return <Resource active>{label}</Resource>;
    } else {
      let asPath = '/football';
      
      if (currentLeagueHandle !== 'all') {
        asPath += `/${currentLeagueHandle}`;
      }
      if (pathName === '/highlights') {
        asPath += '/highlights'
      }

      return <Link href={`${pathName}?league_handle=${currentLeagueHandle}`} as={asPath} gray><Resource>{label}</Resource></Link>;
    }
  }
}

const mapStateToProps = (store, ownProps) => ({
  currentLeagueHandle: deepRead(store, 'page.query.league_handle'),
  currentPathName: deepRead(store, 'page.pathName')
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(ResourceSelector);