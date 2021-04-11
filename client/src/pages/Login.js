import React, { useState } from "react";
import styled from "styled-components";
import GoogleLogin from "react-google-login";
import { withRouter, Redirect } from "react-router-dom";

import { useAuth } from "../providers/AuthProvider";
import DataService from "../services/DataService";

import {
  Form,
  FormField,
  FormFieldLabel,
  Input,
  Button,
  Text,
} from "@smooth-ui/core-sc";

const dataService = new DataService();

const Container = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
`;

const ErrorText = styled(Text)`
  color: rgb(189, 73, 50);
`;
const Header = styled.h1``;

const Login = (props) => {
  const [email, setEmail] = useState(null);
  const [password, setPassword] = useState(null);
  const [error, setError] = useState(null);
  const { state, dispatch } = useAuth(null);

  const handleLogin = async (googleData) => {
    const result = await dataService.oauth({ token: googleData.tokenId });
    dispatch({
      type: "LOGIN",
      payload: { user: result.user, token: result.token },
    });
  };

  return (
    <Container>
      {state.isAuthenticated ? <Redirect to="home" /> : null}
      <Header>Sign In</Header>
      <Form>
        <FormField>
          <FormFieldLabel name="password">Email</FormFieldLabel>
          <Input
            name="email"
            placeholder="you@email.com"
            type="text"
            onChange={(e) => setEmail(e.target.value)}
          />
        </FormField>
        <FormField>
          <FormFieldLabel name="password">Password</FormFieldLabel>
          <Input
            name="password"
            type="password"
            onChange={(e) => setPassword(e.target.value)}
          />
        </FormField>
        <FormField>{error && <ErrorText>{error}</ErrorText>}</FormField>
        <FormField row scale="lg">
          <Button type="submit">Submit</Button>
        </FormField>
        <GoogleLogin
          clientId={process.env.REACT_APP_GAPI_CLIENT_ID}
          buttonText="Log in with Google"
          onSuccess={handleLogin}
          onFailure={handleLogin}
          cookiePolicy={"single_host_origin"}
        />
      </Form>
    </Container>
  );
};

export default withRouter(Login);
