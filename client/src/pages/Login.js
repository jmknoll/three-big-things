import React, { useState } from "react";
import styled from "styled-components";
import { Link } from "react-router-dom";

import {
  Form,
  FormField,
  FormFieldLabel,
  Input,
  Button
} from "@smooth-ui/core-sc";

const Container = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  align-items: center;
`;

const Header = styled.h1``;

const Login = () => {
  return (
    <Container>
      <Header>Sign In</Header>
      <Form>
        <FormField>
          <FormFieldLabel name="password">Name</FormFieldLabel>
          <Input name="email" placeholder="you@email.com" type="text" />
        </FormField>
        <FormField>
          <FormFieldLabel name="password">Password</FormFieldLabel>
          <Input name="password" type="password" />
        </FormField>
        <FormField row scale="lg">
          <Link to="/home">
            <Button type="submit">Submit</Button>
          </Link>
        </FormField>
      </Form>
    </Container>
  );
};

export default Login;
