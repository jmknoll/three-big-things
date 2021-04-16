import React from "react";
import styled from "styled-components";

import { withTheme } from "@material-ui/core/styles";

const Text = (props) => {
  return <div>{props.children}</div>;
};

export const ErrorText = withTheme(styled(Text)`
  color: ${(props) => props.theme.palette.error.main};
`);
