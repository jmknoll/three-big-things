import React from "react";
import styled from "styled-components";

const StyledLayout = styled.div`
  height: 100%;
`;

const Layout = (props) => {
  return <StyledLayout>{props.children}</StyledLayout>;
};

export default Layout;
