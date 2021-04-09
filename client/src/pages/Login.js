import React, { useState } from "react";
import styled from "styled-components";
import { withRouter } from "react-router-dom";
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
  const [user, setUser] = useAuth(null);

  const signIn = async (e) => {
    e.preventDefault();
    setError(null);
    const result = await DataService.signin({ email, password });
    if (result && result.user) {
      result.user["token"] = result.token;
      setUser(result.user);
      props.history.push("/home");
    } else {
      setError("Invalid username or password");
    }
  };

  return (
    <Container>
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
          <Button onClick={(e) => signIn(e)} type="submit">
            Submit
          </Button>
        </FormField>
      </Form>
    </Container>
  );
};

export default withRouter(Login);
