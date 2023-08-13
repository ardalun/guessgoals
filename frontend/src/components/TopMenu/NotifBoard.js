import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import styled, { css } from 'styled-components';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Screen from 'lib/screen';
import NoNotifsYet from 'assets/images/no-notifs-yet.svg';
import Spinner from 'components/Spinner';
import Notif from 'components/Notif';

const BoardContainer = styled.div`
  width: 400px;

`;

const EmptyStateImage = styled.img`
  width: 4rem;
  text-align: center;
`;

const StyledSpinner = styled(Spinner)`
  width: 50px;
  height: 50px;
  font-size: 8px;
  border-top: .2em solid #eaeaea;
  border-right: .2em solid #eaeaea;
  border-bottom: .2em solid #eaeaea;
  border-left: .2em solid #858585;
`;

class NotifBoard extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <BoardContainer>
        { this.renderLoadingState() }
        { this.renderEmptyState() }
        { this.renderBoardNotifs() }
      </BoardContainer>
    );
  }

  renderBoardNotifs = () => {
    const { boardIsLoading, boardNotifs } = this.props;
    if (boardIsLoading) return;
    if (boardNotifs.length === 0) return;
    return (
      <Box>
        {
          boardNotifs.map((notif, index) => {
            return (
              <Notif 
                key={`board_noitf_${notif.id}`} 
                animated={(index + 1) * 100} 
                notif={notif}
              />
            );
          })
        }
        <Box pt={0.75} pb={0.75} center>
          <Link href="/notifications">See All</Link>
        </Box>
      </Box>
    );
  }

  renderEmptyState = () => {
    const { boardIsLoading, boardNotifs } = this.props;
    if (boardIsLoading) return;
    if (boardNotifs.length > 0) return;

    return (
      <Box center pt={2} pb={2} pl={1} pr={1} animated={200}>
        <EmptyStateImage src={NoNotifsYet} />
        <Box mt={1}><Heading as="span" sizeLike="h3" center dark>No Notifications Yet!</Heading></Box>
        <Box body2>We will notify you once we have something for you</Box>
      </Box>
    );
  }

  renderLoadingState = () => {
    const { boardIsLoading } = this.props;
    if (!boardIsLoading) return;
    return (
      <Box pt={2} pb={2} pl={2} pr={2}>
        <StyledSpinner />
        <Box mt={1} center body2>Loading...</Box>
      </Box>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  boardIsLoading: deepRead(store, 'notifBoard.loading'),
  boardNotifs:    deepRead(store, 'notifBoard.notifs'),
  unseenNotifs:   deepRead(store, 'session.user.unseen_notifs')
});
const mapDispatchToProps = {};

export default connect(mapStateToProps, mapDispatchToProps)(NotifBoard);