import React from 'react';
import { connect } from 'react-redux';
import { deepRead } from 'lib/helpers';
import styled, { css } from 'styled-components';
import Heading from 'components/Heading';
import Box from 'components/Box';
import TeamGoal from './TeamGoal';
import Screen from 'lib/screen';

import { changeTeamGoals } from 'redux/play';

import ReactDragList from 'react-drag-list';

const TeamGoalsContainer = styled.div`
  display: flex;
  padding: 0 9rem 0 4rem;
  max-height: 350px;
  overflow-y: auto;

  ${Screen.max('md')} {
    padding: 0;
    max-height: unset;
  }
`;

const GoalNumbers = styled.div`
  width: 6rem;
`;

const GoalNumber = styled.div`
  color: #858585;
  font-family: 'Source Sans Pro';
  margin-bottom: 0.5rem;
  padding: 0.5rem;
  text-align: right;
`;

const Goals = styled.div`
  flex-grow: 1;
`;

class Step4 extends React.Component {
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

  render() {
    const { teamGoals, changeTeamGoals, homeTeam, awayTeam } = this.props;
    const { animationsEnabled } = this.state;
    return (
      <div>
        <Heading as="span" sizeLike="h4" gray animated={animationsEnabled && 200}>LEVEL 4</Heading>
        <Heading as="span" sizeLike="h1" animated={animationsEnabled && 300}>In what order are the goals scored?</Heading>
        <Box animated={animationsEnabled && 400} mt={0.25}>Players with the most goals predicted in the correct order will win this pool.</Box>
        <Box mt={1.5} animated={animationsEnabled && 500}>
          <TeamGoalsContainer>
            { this.renderGoalNumbers() }
            <Goals>
              <ReactDragList
                key={Math.random()}
                dataSource={teamGoals}
                row={(record, index) => (
                  <TeamGoal key={index} team={record === 'home' ? homeTeam : awayTeam} />
                )}
                onUpdate={(e, newDataSource) => changeTeamGoals(newDataSource)}
                animation="100"
                handles={false}
                ghostClass="rdl-ghost"
              />
            </Goals>
          </TeamGoalsContainer>
        </Box>
      </div>
    );
  }

  renderGoalNumbers = () => {
    const { teamGoals } = this.props;
    return (
      <GoalNumbers>
        { 
          teamGoals.map((goal, index) => {
            return <GoalNumber key={`goal_number_${index + 1}`}>Goal #{index + 1}</GoalNumber>
          })
        }
      </GoalNumbers>
    );
  }
}

const mapStateToProps = (store, ownProps) => ({
  homeTeam: deepRead(store, 'play.match.home_team'),
  awayTeam: deepRead(store, 'play.match.away_team'),
  teamGoals: deepRead(store, 'play.play.team_goals') || [],
});
const mapDispatchToProps = {
  changeTeamGoals
};

export default connect(mapStateToProps, mapDispatchToProps)(Step4);