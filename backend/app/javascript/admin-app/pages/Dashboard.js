import React from 'react';
import { Container, Row, Col } from 'react-bootstrap';
import Stat from '../components/Stat';
import Wallet from '../components/Wallet';
import Navbar from '../components/Navbar';
import BadgesBar from '../components/BadgesBar';

export default class Dashboard extends React.Component {
  constructor(props) {
    super(props);
    this.state = { };
  }

  render() {
    return (
      <div>
        <Navbar username={this.props.username} />
        { this.renderServiceStats() }
        { this.renderStats() }
        { this.renderAiWallet() }
        { this.renderMasterWallet() }
      </div>
    );
  }

  renderServiceStats = () => {
    const { sidekiq, postgres, redis, bitcoin, currentBalance } = this.props;

    const leftBadges = [
      {
        variant: sidekiq ? "primary" : "secondary",
        label: 'Sidekiq'
      },
      {
        variant: postgres ? "primary" : "secondary",
        label: 'Postgres'
      },
      {
        variant: redis ? "primary" : "secondary",
        label: 'Redis'
      },
      {
        variant: bitcoin ? "primary" : "secondary",
        label: 'Bitcoin'
      }
    ];
    const rightBadges = [
      {
        variant: "primary",
        label: currentBalance
      }
    ];
    return (
      <BadgesBar leftBadges={leftBadges} rightBadges={rightBadges} />
    );
  }

  renderStats = () => {
    const { users, plays, transfers, outstanding_payouts } = this.props;

    return (
      <Container className="mt-5">
        <Row>
          <Col xs={6} md={3} className="mb-4"><Stat value={users} label="Users" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={plays} label="Plays" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={transfers} label="Transfers" /></Col>
          <Col xs={6} md={3} className="mb-4"><Stat value={outstanding_payouts} label="Payouts" href="/admin/payouts" /></Col>
        </Row>
      </Container>
    );
  }

  renderAiWallet = () => {
    const { total, unlocked, unconfirmed } = this.props.ai_wallet;

    return (
      <Container className="mt-3">
        <Row>
          <Col>
            <Wallet name="Ai Wallet" total={total} unlocked={unlocked} unconfirmed={unconfirmed} />
          </Col>
        </Row>
      </Container>
    );
  }

  renderMasterWallet = () => {
    const { total, unlocked, unconfirmed } = this.props.master_wallet;

    return (
      <Container className="mt-3">
        <Row>
          <Col>
            <Wallet name="Master Wallet" total={total} unlocked={unlocked} unconfirmed={unconfirmed} />
          </Col>
        </Row>
      </Container>
    );
  }
}