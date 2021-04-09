import React from "react";
import { Box } from "@smooth-ui/core-sc";
import styled from "styled-components";

const ShadowBox = styled(Box)`
  padding: 20px;
  border;
  background: #fff;
  border-radius: 2px;
  margin: 1rem 0;
  position: relative;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
  transition: all 0.25s ease-in-out;

  &:hover {
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.19), 0 6px 6px rgba(0, 0, 0, 0.23);
  }
`;

const Close = styled.div`
  position: absolute;
  top: 5px;
  right: 5px;
`;

const Goal = (props) => {
  return (
    <ShadowBox>
      <Close
        onClick={() => {
          props.removeGoal(props.goal);
        }}
      >
        &times;
      </Close>
      {props.goal.content}
    </ShadowBox>
  );
};

export default Goal;
