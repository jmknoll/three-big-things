import React from "react";

import {
  Form,
  FormField,
  FormFieldLabel,
  Input,
  Button,
  Text
} from "@smooth-ui/core-sc";

const AddGoalForm = ({ user }) => {
  return (
    <Form>
      <FormField>
        <FormFieldLabel name="password">Email</FormFieldLabel>
        <Input
          name="email"
          placeholder="you@email.com"
          type="text"
          onChange={e => setEmail(e.target.value)}
        />
      </FormField>
      <FormField>
        <FormFieldLabel name="password">Password</FormFieldLabel>
        <Input
          name="password"
          type="password"
          onChange={e => setPassword(e.target.value)}
        />
      </FormField>
      <FormField>{error && <ErrorText>{error}</ErrorText>}</FormField>
      <FormField row scale="lg">
        <Button onClick={e => signIn(e)} type="submit">
          Submit
        </Button>
      </FormField>
    </Form>
  );
};

export default AddGoalForm;
