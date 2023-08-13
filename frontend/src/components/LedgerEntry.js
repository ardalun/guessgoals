import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import Link from 'components/Link';
import { distanceInWordsToNow } from 'date-fns';
import styled, { css } from 'styled-components';
import Box from 'components/Box';
import Heading from 'components/Heading';
import Screen from 'lib/screen';
import { longTimeFormat } from 'lib/formatter';

const LedgerEntryContainer = styled.div`
  display: flex;
  border-bottom: 1px solid #40474E;
  padding: 1rem;
`;

const EntryInfo = styled.div`
  flex-grow: 1;
`;

const EntryAmount = styled.div`
  display: flex;
  justify-content: flex-end;
  min-width: 6rem;
  align-items: center;

  ${props => props.amount > 0 && css`
    color: #00B16A;
  `}

  ${props => props.amount < 0 && css`
    color: #F64747;
  `}
`;

const Status = styled.div`
  font-size: 0.6rem;
  display: inline-block;
  padding: 0.1rem 0.35rem;
  border-radius: 0.125rem;
  margin-right: 1rem;
  background-color: ${props => props.color};
`;

class LedgerEntry extends React.Component {
  constructor(props) {
    super(props);
  }

  getLabel = () => {
    const { ledgerEntry } = this.props;

    const valueToLabelMap = {
      processing: 'Processing',
      pending_confirmation: 'Pending Confirmation',
      is_confirmed: 'Confirmed'
    }

    if (ledgerEntry.status in valueToLabelMap) {
      return valueToLabelMap[ledgerEntry.status];
    } else {
      return 'Unkown';
    }
  }

  getColor = () => {
    const { ledgerEntry } = this.props;

    const valueToLabelMap = {
      processing: '#FF7E00',
      pending_confirmation: '#FF7E00',
      is_confirmed: '#00B16A'
    }

    if (ledgerEntry.status in valueToLabelMap) {
      return valueToLabelMap[ledgerEntry.status];
    } else {
      return '#858585';
    }
  }

  render() {
    const { ledgerEntry, timezone } = this.props;

    return (
      <LedgerEntryContainer>
        <EntryInfo>
          <Box mb={0.25}><Status color={this.getColor()}>{this.getLabel()}</Status></Box>
          <Box body2>{ledgerEntry.description}</Box>
          <Box body3 gray>{longTimeFormat(ledgerEntry.created_at, timezone)}</Box>
        </EntryInfo>
        <EntryAmount amount={ledgerEntry.total}>Ƀ {ledgerEntry.total > 0 ? '+' : '-'}{Math.abs(ledgerEntry.total)}</EntryAmount>
      </LedgerEntryContainer>
    );
  }
}

export default LedgerEntry;