import React from "react";
import Goal from "./Goal";

const GoalList = props => {
  return props.goals.map(goal => {
    return <Goal goal={goal} removeGoal={props.removeGoal} />;
  });
};

export default GoalList;
