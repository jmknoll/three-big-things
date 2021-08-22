import React from "react";
import styled from "styled-components";
import { useAuth } from "../providers/AuthProvider";

const Wrapper = styled.div`
  position: absolute;
  z-index: 2;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  box-shadow: 0px 2px 4px -1px rgba(0, 0, 0, 0.2),
    0px 4px 5px 0px rgba(0, 0, 0, 0.14), 0px 1px 10px 0px rgba(0, 0, 0, 0.12);
  background-color: white;
  position: fixed;
  width: 100%;
`;

const Logo = styled.div`
  font-size: 18px;
  color: black;
  font-weight: 700;
  cursor: pointer;
`;

const Navbar = () => {
  const { dispatch } = useAuth();

  return (
    <Wrapper position="fixed">
      <button
        onClick={() => {
          dispatch({ type: "LOGOUT" });
        }}
      >
        Logout
      </button>
    </Wrapper>
  );
};

export default Navbar;
