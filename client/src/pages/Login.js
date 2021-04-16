import React, { useState } from "react";
import styled from "styled-components";
import GoogleLogin from "react-google-login";
import { withRouter, Redirect } from "react-router-dom";

import { useAuth } from "../providers/AuthProvider";
import DataService from "../services/DataService";

import {
  TextField,
  Button,
  FormControl,
  InputLabel,
  Input,
  Container,
  Paper,
} from "@material-ui/core";

import { withTheme } from "@material-ui/core/styles";

const dataService = new DataService();

const Page = withTheme(styled.div`
  background-color: ${(props) => props.theme.palette.primary.main};
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
  height: 100vh;
  padding-top: 75px;
`);

const StyledPaper = styled(Paper)`
  padding: 30px;
`;

const Card = styled.div``;

const Login = (props) => {
  const [error, setError] = useState(null);

  const { state, dispatch } = useAuth(null);
  const { isAuthenticated } = state;

  const handleLogin = async (googleData) => {
    const [result, error] = await dataService.oauth({
      token: googleData.tokenId,
    });
    if (result) {
      dispatch({
        type: "LOGIN",
        payload: { user: result.user, token: result.token },
      });
    }
  };

  return (
    <Page>
      <Container maxWidth="lg">
        {isAuthenticated ? <Redirect to="home" /> : null}

        {/* REMOVING EMAIL/PASSWORD LOGIN TEMPORARILY
        <TextField
          name="email"
          label="Email"
          variant="outlined"
          onChange={(e) => setEmail(e.target.value)}
        />

        <TextField
          name="password"
          type="password"
          label="password"
          variant="outlined"
          onChange={(e) => setPassword(e.target.value)}
        />

        <FormControl>{error && <ErrorText>{error}</ErrorText>}</FormControl>
        <FormControl row scale="lg">
          <Button variant="contained" color="primary">
            Submit
          </Button>
        </FormControl> */}
        <StyledPaper>
          <GoogleLogin
            clientId={process.env.REACT_APP_GAPI_CLIENT_ID}
            buttonText="Log in with Google"
            onSuccess={handleLogin}
            onFailure={handleLogin}
            cookiePolicy={"single_host_origin"}
          />
        </StyledPaper>
      </Container>
    </Page>
  );
};

export default withRouter(Login);
