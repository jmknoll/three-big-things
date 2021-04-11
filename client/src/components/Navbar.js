import React from "react";
import styled from "styled-components";
import { useAuth } from "../providers/AuthProvider";
import { Button } from "@smooth-ui/core-sc";

const Wrapper = styled.div`
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
`;

const Logo = styled.div`
  font-weight: 700;
`;

const Navbar = () => {
  const { dispatch } = useAuth();

  return (
    <Wrapper>
      <Logo>TBT</Logo>
      <Button
        onClick={() => {
          dispatch({ type: "LOGOUT" });
        }}
      >
        Logout
      </Button>
    </Wrapper>
  );
};

export default Navbar;
