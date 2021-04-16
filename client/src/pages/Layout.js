import React from "react";
import Navbar from "../components/Navbar";
import styled from "styled-components";

const StyledLayout = styled.div`
  height: 100%;
`;

const Layout = (props) => {
  return (
    <StyledLayout>
      <Navbar></Navbar>
      {props.children}
    </StyledLayout>
  );
};

export default Layout;
