import React from 'react';
import styled from 'styled-components';
import Box from 'components/Box';
import Screen from 'lib/screen';
import Heading from 'components/Heading';
import Button from 'components/Button';
import Icon from 'components/Icon';

const PageSelectorContainer = styled.div`
  border-top: 1px solid #40474E;
  margin-top: 1.5rem;
  display: flex;
  padding: 1rem;

  ${Screen.max('lg')} {
    margin: 0;
    background: #1E262D;
    border-top: none;
    border-bottom: 1px solid #40474E;
  }
`;

const RightContainer = styled.div`
  display: flex;
  flex-flow: row-reverse;
  flex-grow: 1;
`;
const LeftContainer = styled.div`
`;

class Pagination extends React.Component {
  constructor(props) {
    super(props);
  }

  isLastPage = () => {
    const { currentPage, recordsPerPage, totalRecords } = this.props;
    return Math.floor(totalRecords / recordsPerPage) + 1 === currentPage;
  }

  getOlderPage = () => {
    this.getRecordsOfPage(this.props.currentPage + 1);
  }

  getNewerPage = () => {
    this.getRecordsOfPage(this.props.currentPage - 1);
  }

  getRecordsOfPage = (page) => {
    this.props.getRecordsOfPage(page);
  }

  render() {
    const {
      title,
      currentPage, 
      currentPageRecords, 
      recordsPerPage, 
      totalRecords, 
      loading
    } = this.props;

    const showingFrom = (currentPage - 1) * recordsPerPage + 1;

    if (totalRecords === 0) return null;

    return (
      <PageSelectorContainer>
        <LeftContainer>
          <Heading as="h1" sizeLike="h1">{title}</Heading>
        </LeftContainer>
        {
          totalRecords <= recordsPerPage ? null : (
            <RightContainer>
              <Button secondary onClick={this.getOlderPage} disabled={loading || this.isLastPage()}>
                <Icon name="im-arrow-right" size={0.75} />
              </Button>
              <Box mr={1}>
                <Button secondary onClick={this.getNewerPage} disabled={loading || currentPage === 1}>
                  <Icon name="im-arrow-left" size={0.75} />
                </Button>
              </Box>
              <Box mr={1} flex>
                {showingFrom}-{showingFrom + currentPageRecords - 1} of {totalRecords}
              </Box>
            </RightContainer>
          )
        }
        
      </PageSelectorContainer>
    );
  }
}

export default Pagination;