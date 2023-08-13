import React from 'react';
import { distanceInWordsToNow } from 'date-fns';
import styled, { css } from 'styled-components';
import fundsReceived from 'assets/images/notifs/funds_received.svg';
import fundsConfirmed from 'assets/images/notifs/funds_confirmed.svg';
import fundsDeclined from 'assets/images/notifs/funds_declined.svg';
import microFundsReceived from 'assets/images/notifs/micro_funds_received.svg';
import microFundsConfirmed from 'assets/images/notifs/micro_funds_confirmed.svg';
import microFundsDeclined from 'assets/images/notifs/micro_funds_declined.svg';
import playAccepted from 'assets/images/notifs/play_accepted.svg';
import playDeclined from 'assets/images/notifs/play_declined.svg';
import announcement from 'assets/images/notifs/announcement.svg';
import poolWon from 'assets/images/notifs/pool_won.svg';
import payout from 'assets/images/notifs/payout.svg';
import payoutConfirmed from 'assets/images/notifs/payout_confirmed.svg';


const NotifContainer = styled.div`
  display: flex;
  
  ${props => !props.forNotify && css`
    padding: 1rem 2rem;
    border-bottom: 1px solid #eaeaea;
  `}

  ${props => props.seen && css`
    background: rgba(0,0,0,0.04);
  `}

  ${props => props.darkMode && css`
    border-bottom: 1px solid #40474e;
    background: unset;

    ${props => props.seen && css`
      background: #2F3942;
    `}
  `}
`;

const NotifIconContainer = styled.div`
  min-width: 3rem;
  max-width: 3rem;
  display: flex;
  align-items: flex-start;
  justify-content: flex-end;
`;

const NotifIcon = styled.img`
  margin-right: 1rem;
  max-width: ${props => props.maxWidth ? `${props.maxWidth}rem` : 'unset'};
  max-height: ${props => props.maxHeight ? `${props.maxHeight}rem` : 'unset'};
`;

const NotifMessage = styled.div`
  flex-grow: 1;
  font-size: 0.75rem;

  ${props => props.darkMode && css`
    color: #FFFFFF;
  `}
`;

const NotifTime = styled.div`
  font-size: 0.75rem;
  margin-top: 0.5rem;
  color: #adadad;
`;

class Notif extends React.Component {
  constructor(props) {
    super(props);
  }

  getIconUrl = () => {
    const mapKindToIcon = {
      funds_received: fundsReceived,
      funds_confirmed: fundsConfirmed,
      funds_declined: fundsDeclined,
      micro_funds_received: microFundsReceived,
      micro_funds_confirmed: microFundsConfirmed,
      micro_funds_declined: microFundsDeclined,
      play_accepted: playAccepted,
      play_declined: playDeclined,
      match_started: announcement,
      pool_won: poolWon,
      pool_lost: announcement,
      payout_requested: payout,
      payout_sent: payout,
      payout_confirmed: payoutConfirmed,
    }
    const kind = this.props.notif.kind;
    if (kind in mapKindToIcon) {
      return mapKindToIcon[kind];
    } else {
      return announcement;
    }
  }

  getIconSizeProps = () => {
    const mapKindToSizeProps = {
      funds_received:        {maxHeight: 1.75},
      funds_confirmed:       {maxHeight: 1.75},
      funds_declined:        {maxHeight: 1.75},
      micro_funds_received:  {maxHeight: 1.75},
      micro_funds_confirmed: {maxHeight: 1.75},
      micro_funds_declined:  {maxHeight: 1.75},
      play_accepted:         {maxHeight: 1.75},
      play_declined:         {maxHeight: 1.75},
      match_started:         {maxHeight: 1.5},
      pool_won:              {maxHeight: 1.7},
      pool_lost:             {maxHeight: 1.5},
      payout_requested:      {maxHeight: 1.3},
      payout_sent:           {maxHeight: 1.3},
      payout_confirmed:      {maxHeight: 1.75},
    }
    const kind = this.props.notif.kind;
    if (kind in mapKindToSizeProps) {
      return mapKindToSizeProps[kind];
    } else {
      return {maxHeight: 1.5};
    }
  }

  getNotifTime = () => {
    return distanceInWordsToNow(
      new Date(this.props.notif.created_at),
      {
        addSuffix: true,
        includeSeconds: true
      }
    );
  }

  kindIsValid = () => {
    const validKinds = [
      'funds_received', 'funds_confirmed', 'funds_declined', 
      'micro_funds_received', 'micro_funds_confirmed', 
      'micro_funds_declined', 'play_accepted', 'play_declined', 
      'match_started', 'pool_won', 'pool_lost', 'payout_requested', 
      'payout_sent', 'payout_confirmed'
    ]
    if (validKinds.includes(this.props.notif.kind)) return true;
    return false;
  }

  render() {
    const { darkMode, notif, forNotify } = this.props;

    if (!this.kindIsValid()) return;
    return (
      <NotifContainer darkMode={darkMode} seen={notif.seen} forNotify={forNotify}>
        <NotifIconContainer>
          <NotifIcon src={this.getIconUrl()} {...this.getIconSizeProps()} />
        </NotifIconContainer>
        <NotifMessage darkMode={darkMode}>
          { this.renderMessage() }
          <NotifTime>
            { this.getNotifTime() }
          </NotifTime>
        </NotifMessage>
      </NotifContainer>
    );
  }

  renderMessage = () => {
    const { kind } = this.props.notif;
    switch (kind) {
      case 'funds_received' :        { return this.renderFundsReceivedMessage() }
      case 'funds_confirmed' :       { return this.renderFundsConfirmedMessage() }
      case 'funds_declined' :        { return this.renderFundsDeclinedMessage() }
      case 'micro_funds_received' :  { return this.renderMicroFundsReceivedMessage() }
      case 'micro_funds_confirmed' : { return this.renderMicroFundsConfirmedMessage() }
      case 'micro_funds_declined' :  { return this.renderMicroFundsDeclinedMessage() }
      case 'play_accepted' :         { return this.renderPlayConfirmedMessage() }
      case 'play_declined' :         { return this.renderPlayDeclinedMessage() }
      case 'match_started' :         { return this.renderMatchStartedMessage() }
      case 'pool_won' :              { return this.renderPoolWonMessage() }
      case 'pool_lost' :             { return this.renderPoolLostMessage() }
      case 'payout_requested' :      { return this.renderPayoutRequestedMessage() }
      case 'payout_sent' :           { return this.renderPayoutSentMessage() }
      case 'payout_confirmed' :      { return this.renderPayoutConfirmedMessage() }
    }
  }
  
  renderFundsReceivedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        A <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was detected on your wallet.
      </div>
    );
  }
  renderFundsConfirmedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was confirmed.
      </div>
    );
  }
  renderFundsDeclinedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was removed from your wallet due to confirmation being late. We will re-add it to your wallet if we receive a confirmation for it in future.
      </div>
    );
  }
  renderMicroFundsReceivedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        A <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was detected on your wallet. Unfortunately, we have to decline this transaction due to amount being less than <strong>{data.minimum_acceptable_amount} BTC</strong> (the minimum acceptable amount). You can send the funds back to yourself once it is confirmed.
      </div>
    );
  }
  renderMicroFundsConfirmedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your formerly declined <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was confirmed and is now available for refund.
      </div>
    );
  }
  renderMicroFundsDeclinedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>credit transaction</strong> of <strong>{data.amount} BTC</strong> was removed from your wallet due to confirmation being late. We will re-add it to your wallet if we receive a confirmation for it in future.
      </div>
    );
  }
  renderPlayConfirmedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your bet on <strong>{data.match_name}</strong> was confirmed.
      </div>
    );
  }
  renderPlayDeclinedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your bet on <strong>{data.match_name}</strong> was declined due to funds used were not confirmed on time.
      </div>
    );
  }
  renderMatchStartedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        <strong>{data.match_name}</strong> was started. Prize pool is <strong>{data.real_prize} BTC</strong> and your chance is about <strong>{data.real_chance}%</strong>.
      </div>
    );
  }
  renderPoolWonMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Congratulations. Your bet on <strong>{data.match_name}</strong> won <strong>{data.prize_share} BTC</strong>. Feel free to withdraw your prize any time or use it towards playing more games.
      </div>
    );
  }
  renderPoolLostMessage = () => {
    const { data } = this.props.notif;
    const play_rank = data.play_rank;
    let suffix = 'th';
    if (play_rank == 2) {
      suffix = 'nd';
    } else if (play_rank == 3) {
      suffix = 'rd';
    }
    const rank = `${play_rank}${suffix}`;
    return (
      <div>
        <strong>{data.match_name}</strong> was finished and your bet was ranked <strong>{rank}</strong>.
      </div>
    );
  }
  renderPayoutRequestedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>payout request</strong> of <strong>{data.amount} BTC</strong> was received and is being processed. We will let you know once we created your payout transaction.
      </div>
    );
  }
  renderPayoutSentMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>payout transaction</strong> of <strong>{data.amount} BTC</strong> was created.
      </div>
    );
  }
  renderPayoutConfirmedMessage = () => {
    const { data } = this.props.notif;
    return (
      <div>
        Your <strong>payout transaction</strong> of <strong>{data.amount} BTC</strong> was confirmed.
      </div>
    );
  }
}

export default Notif;