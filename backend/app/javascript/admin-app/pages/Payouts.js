import React from 'react';
import { Container, Row, Col, Table } from 'react-bootstrap';
import { formatRelative } from 'date-fns';
import Stat from '../components/Stat';
import Navbar from '../components/Navbar';
import EmptyState from '../components/EmptyState';
import BadgesBar from '../components/BadgesBar';
import axios from 'axios';

export default class Payouts extends React.Component {
  constructor(props) {
    super(props);
    this.state = { };
  }

  formatTime = (timeStr) => {
    return formatRelative(new Date(timeStr), new Date());
  }

  approvePayout = (e, ledgerEntryId) => {
    e.preventDefault();

    if (confirm('You sure?')) {
      axios.put(`/admin/payouts/${ledgerEntryId}/approve`)
        .then(resp => {
          location.reload();
        })
        .catch(error => {
          if (error.response && error.response.data && error.response.data.message) {
            alert(error.response.data.message);
          } else {
            alert('Unknown error');
          }
          console.log(error.response.data);
        });
    }
  }
  render() {
    return (
      <div>
        <Navbar username={this.props.username} />
        { this.renderServiceStats() }
        { this.renderStats() }
        { this.renderRecords() }
        { this.renderEmptyState() }
      </div>
    );
  }

  renderServiceStats = () => {
    const { currentBalance } = this.props;
    const rightBadges = [
      {
        variant: "primary",
        label: currentBalance
      }
    ];
    return (
      <BadgesBar leftBadges={[]} rightBadges={rightBadges} />
    );
  }

  renderStats = () => {
    const { total, outstanding, pending, confirmed } = this.props;

    return (
      <Container className="mt-5">
        <Row>
          <Col xs={6} md={3} className="mb-4"><Stat value={total} label="Total" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={outstanding} label="Processing" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={pending} label="Pending" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={confirmed} label="Confirmed" /></Col>
        </Row>
      </Container>
    );
  }

  renderRecords = () => {
    const { records } = this.props;
    if (records.length === 0) { return; }

    return (
      <Container>
        <h1 className="mt-2 mb-4">Outstanding Payouts</h1>
        <Table striped bordered hover>
          <thead>
            <tr>
              <th>Created At</th>
              <th>User</th>
              <th>Amount</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {
              records.map(record => {
                return (
                  <tr key={`payout_${record.id}`}>             
                    <td>{this.formatTime(record.created_at)}</td>
                    <td>{record.username}</td>
                    <td>{-1 * record.total}</td>
                    <td><a href="#" onClick={(e) => this.approvePayout(e, record.id)}>Approve</a></td>
                  </tr>
                );
              })
            }
          </tbody>
        </Table>
      </Container>
    );
  }

  renderEmptyState = () => {
    const { records } = this.props;
    if (records.length > 0) { return; }

    return (
      <Container>
        <EmptyState>There is no outstanding payouts ;)</EmptyState>
      </Container>
    );
  }
}