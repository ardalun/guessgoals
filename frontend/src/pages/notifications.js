import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import MainLayout from 'layouts/MainLayout';
import Notif from 'components/Notif';
import Box from 'components/Box';
import Pagination from 'components/Pagination';
import { setTitle, setDescription } from 'redux/page';
import { getNotifs, markUnseensAsSeen } from 'redux/notif-page';
import { requireLogin } from 'lib/authman';
import NoNotifsYet from 'assets/images/no-notifs-yet-dark.svg';
import EmptyState from 'components/EmptyState';

class NotificationsPage extends React.Component {
  
  static async getInitialProps(ctx) {
    const { req, res, reduxStore, query } = ctx;
    requireLogin(ctx);
    await reduxStore.dispatch(setTitle('Notifications - GuessGoals'));
    await reduxStore.dispatch(setDescription('Review your notifications'));
    await reduxStore.dispatch(getNotifs());
    return {};
  }

  componentDidMount() {
    this.props.markUnseensAsSeen();
  }

  getNotifsOfPage = (page) => {
    this.props.getNotifs(page)
      .then(() => {
        this.props.markUnseensAsSeen();
      });
  }

  render() {
    return (
      <MainLayout>
        { this.renderPagination() }
        { this.renderNotifs() }
        { this.renderEmptyState() }
      </MainLayout>
    );
  }

  renderPagination = () => {
    const { currentPage, recordsPerPage, totalRecords, notifs, loading } = this.props;

    return (
      <Pagination
        title="Notifications"
        currentPage={currentPage}
        currentPageRecords={notifs.length}
        recordsPerPage={recordsPerPage}
        totalRecords={totalRecords}
        loading={loading}
        getRecordsOfPage={this.getNotifsOfPage}
      />
    );
  }

  renderNotifs = () => {
    const { notifs } = this.props;
    if (notifs.length === 0) return;
    return (
      <div>
        {
          notifs.map(notif => {
            return (
              <Notif key={`notif_page_${notif.id}`} notif={notif} darkMode />
            );
          })
        }
      </div>
    );
  }

  renderEmptyState = () => {
    return (
      <EmptyState
        marginTop={10}
        show={this.props.notifs.length === 0}
        illustrationUrl={NoNotifsYet}
        title="No Notifications Yet"
        message="We will notify you once we have something for you."
      />
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  notifs:         deepRead(store, 'notifPage.notifs'),
  currentPage:    deepRead(store, 'notifPage.currentPage'),
  recordsPerPage: deepRead(store, 'notifPage.recordsPerPage'),
  totalRecords:   deepRead(store, 'notifPage.totalRecords'),
  loading:        deepRead(store, 'notifPage.loading')
});
const mapDispatchToProps = {
  getNotifs,
  markUnseensAsSeen
};

export default connect(mapStateToProps, mapDispatchToProps)(NotificationsPage);