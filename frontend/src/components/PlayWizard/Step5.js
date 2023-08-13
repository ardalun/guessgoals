import React, { Fragment } from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled, { css } from 'styled-components';
import Heading from 'components/Heading';
import Button from 'components/Button';
import Box from 'components/Box';
import Screen from 'lib/screen';
import Icon from 'components/Icon';
import Link from 'components/Link';
import { formatToTimeZone } from 'date-fns-timezone';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import { alertSuccess } from 'lib/alert';
import { pullAddressUpdates } from 'redux/session';

const Summary = styled.div`
  background-color: #1E262D;
  padding: 1rem;
  border-radius: 0.25rem;
  display: flex;
  flex-direction: column;
`;

const SummaryRow = styled.div`
  display: flex;
  ${Screen.max('md')} {
    flex-direction: column;
  }
`;
const SummaryCol = styled.div`
  flex-grow: 1;
  display: flex;
  flex-direction: column;
`;

const PaymentContainer = styled.div`
  margin-top: 1.5rem;
  display: flex;
  ${Screen.max('sm')} {
    flex-direction: column;
  }
`;

const PaymentInfo = styled.div`
  flex-grow: 1;

`;

const QrImage = styled.img`
  border-radius: 0.25rem;
`;

const PaymentInfoRow = styled.div`
  flex-grow: 1;
  display: flex;
  ${Screen.max('sm')} {
    flex-direction: column;
  }
`;

const ScrollableBox = styled(Box)`
  max-height: 100px;
  overflow-y: auto;
  margin: 0 0.25rem;
  
  &::-webkit-scrollbar {
    -webkit-appearance: none;
  }

  &::-webkit-scrollbar:vertical {
    width: 11px;
  }

  &::-webkit-scrollbar:horizontal {
    height: 11px;
  }

  &::-webkit-scrollbar-thumb {
    border-radius: 8px;
    background-color: rgba(0, 0, 0, .5);
  }
`;

const TinyLink = styled.span`
  font-size: 0.75rem;
  font-family: 'Source Sans Pro';
  color: #FF7E00;
  cursor: pointer;

  &:hover {
    text-decoration: underline;
  }
`;

class Step5 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      animationsEnabled: true
    }
  }
  
  componentDidMount() {
    this.animationTimer = setTimeout(() => {
      this.setState({ animationsEnabled: false });
    }, 1000);
  }

  componentWillUnmount() {
    clearTimeout(this.animationTimer);
  }

  getMatchDate = () => {
    const { matchStartsAt, timezone } = this.props;
    return formatToTimeZone(new Date(matchStartsAt), 'YYYY-MM-DD - h:mm A z', {timeZone: timezone});
  }

  getWinnerName = () => {
    const { homeTeamName, awayTeamName, winnerTeam } = this.props;
    if (winnerTeam === 'draw') {
      return 'Draw';
    } else if (winnerTeam === 'home') {
      return `${homeTeamName} wins`;
    } else {
      return `${awayTeamName} wins`;
    }
  }

  pullAddressUpdates = () => {
    this.props.pullAddressUpdates();
  }

  render() {
    const { animationsEnabled } = this.state;
    return (
      <div>
        <Heading as="span" sizeLike="h4" gray animated={animationsEnabled && 200}>You Are Almost There</Heading>
        <Heading as="span" sizeLike="h1" animated={animationsEnabled && 300}>Review and Pay</Heading>
        <Box mt={1} animated={animationsEnabled && 400}>
          { this.renderSummary() }
        </Box>
        <Box animated={animationsEnabled && 500}>
          { this.renderPayment() }
        </Box>
      </div>
    );
  }

  renderPayment = () => {
    const { walletTotal, ticketFee, addressCode, addressQr, placeBetLoading } = this.props;
    if (walletTotal >= ticketFee || placeBetLoading) return;

    return (
      <PaymentContainer>
        <PaymentInfo>
          <PaymentInfoRow>
            <Box mb={0.75}>
              <Box body3 gray>Ticket Fee</Box>
              <Box body2>{ticketFee} BTC</Box>
            </Box>
            <Box nonSmVisible mr={1} ml={1} mt={1}><Icon name="im-arrow-right" size={0.75} /></Box>
            <Box mb={0.75}>
              <Box body3 gray>Address</Box>
              <Box body2>{addressCode}</Box>
            </Box>
          </PaymentInfoRow>
          <div>
            <Box mb={1.5}>
              <CopyToClipboard 
                text={addressCode}
                onCopy={() => alertSuccess('Address copied.', 1)}
              >
                <Button secondary>Copy Address</Button>
              </CopyToClipboard>
            </Box>
            <Box body3 mb={0.25}>
              <Icon name="im-loading rotating" mr={0.25} />
              Waiting for Payment... [ <TinyLink onClick={this.pullAddressUpdates}>I sent but this screen is not updating</TinyLink> ]
            </Box>
            <Box body3 gray mb={2}><Icon name="im-info" /> 1 block confirmation is required before the match starts.</Box>
          </div>
        </PaymentInfo>
        <div>
          <QrImage src={addressQr} />
        </div>
      </PaymentContainer>
    );
  }

  renderSummary = () => {
    const {
      homeTeamName,
      awayTeamName,
      homeScore,
      awayScore,
      ticketFee
    } = this.props;
    return (
      <Summary>
        <SummaryRow>
          <SummaryCol>
            <Box body3 gray>Event</Box>
            <Box body3>{homeTeamName} - {awayTeamName}</Box>
            <Box body3 mb={0.5}>{this.getMatchDate()}</Box>
          </SummaryCol>
          <SummaryCol>
            <Box body3 gray>LEVEL 1 - Outcome</Box>
            <Box body3 mb={0.5}>{ this.getWinnerName() }</Box>
            <Box body3 gray>LEVEL 2 - Team Scores</Box>
            <Box body3 mb={0.5}>{homeTeamName} {homeScore} - {awayScore} {awayTeamName}</Box>
          </SummaryCol>
          { this.renderLevel3Summary() }
          { this.renderLevel4Summary() }
        </SummaryRow>
        <SummaryRow>
          <SummaryCol>
            <Box body3 gray>Ticket Fee</Box>
            <Heading as="span" sizeLike="h2">{ticketFee} BTC</Heading>
          </SummaryCol>
        </SummaryRow>
      </Summary>
    );
  }

  renderLevel3Summary = () => {
    const { homeScorers, awayScorers, steps } = this.props;
    let betSummary = <Box body3>N/A</Box>;
    
    if (steps.length >= 4) {
      betSummary = [];
      for (let key in homeScorers) {
        const scorer = homeScorers[key];
        betSummary.push(
          <Box key={`scorer_${key}`} body3>
            {`${scorer.player.name} ${scorer.goals > 1 ? `(x${scorer.goals})` : ''}`}
          </Box>
        )
      }
      for (let key in awayScorers) {
        const scorer = awayScorers[key];
        betSummary.push(
          <Box key={`scorer_${key}`} body3>
            {`${scorer.player.name} ${scorer.goals > 1 ? `(x${scorer.goals})` : ''}`}
          </Box>
        );
      }
    }

    return (
      <SummaryCol>
        <Box body3 gray>LEVEL 3 - Scorers</Box>
        <ScrollableBox mb={0.5}>{ betSummary }</ScrollableBox>
      </SummaryCol>
    );
  }

  renderLevel4Summary = () => {
    const { homeTeamName, awayTeamName, steps, teamGoals } = this.props;
    let betSummary = <Box body3>N/A</Box>;

    if (steps.length >= 5) {
      betSummary = teamGoals.map((team, i) => {
        return <Box key={`team_goal_${i}`} body3>{`${i + 1}. ${ team === 'home' ? homeTeamName : awayTeamName }`}</Box>;
      });
    }

    return (
      <SummaryCol>
        <Box body3 gray>LEVEL 4 - Goals Order</Box>
        <ScrollableBox mb={0.5}>{ betSummary }</ScrollableBox>
      </SummaryCol>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  timezone:        deepRead(store, 'session.timezone'),
  matchStartsAt:   deepRead(store, 'play.match.starts_at'),
  homeTeamName:    deepRead(store, 'play.match.home_team.name'),
  awayTeamName:    deepRead(store, 'play.match.away_team.name'),
  winnerTeam:      deepRead(store, 'play.play.winner_team'),
  homeScore:       deepRead(store, 'play.play.home_score'),
  awayScore:       deepRead(store, 'play.play.away_score'),
  homeScorers:     deepRead(store, 'play.play.home_scorers'),
  awayScorers:     deepRead(store, 'play.play.away_scorers'),
  teamGoals:       deepRead(store, 'play.play.team_goals') || [],
  steps:           deepRead(store, 'play.steps'),
  ticketFee:       deepRead(store, 'play.match.ticket_fee'),
  addressCode:     deepRead(store, 'session.user.wallet.address.code'),
  addressQr:       deepRead(store, 'session.user.wallet.address.qr'),
  walletTotal:     deepRead(store, 'session.user.wallet.total'),
  placeBetLoading: deepRead(store, 'play.placeBetLoading')
});
const mapDispatchToProps = {
  pullAddressUpdates
};

export default connect(mapStateToProps, mapDispatchToProps)(Step5);