import React, { useState, useEffect } from "react";
import { useAuth } from "../providers/AuthProvider";
import DataService from "../services/DataService";
import GoalList from "../components/GoalList";

import styled from "styled-components";

import {
  Form,
  FormField,
  FormFieldLabel,
  Input,
  Button,
  Text,
} from "@smooth-ui/core-sc";

const Container = styled.div`
  padding: 20px 20px;
`;

const Goal = styled.div`
  border: 1px solid black;
  margin: 15px 0;
  padding: 10px;
  max-width: 200px;
`;

const Home = () => {
  const [user, setUser] = useAuth();
  let [goals, setGoals] = useState([]);
  const [goal, setGoal] = useState({});

  useEffect(() => {
    if (user && user.token) {
      DataService.getGoals({ token: user.token })
        .then((res) => {
          setGoals(res.data);
        })
        .catch((err) => {
          console.log(err);
        });
    }
  }, [user]);

  const addGoal = (e) => {
    e.preventDefault();
    DataService.createGoal({ token: user.token, goal })
      .then((res) => {
        setGoals([...goals, res.data]);
        setGoal({ content: "" });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const removeGoal = (goal) => {
    DataService.removeGoal({ token: user.token, goal: goal })
      .then((res) => {
        setGoals(goals.filter((goal) => goal.id !== parseInt(res.data.id)));
      })
      .catch((err) => {
        console.log(err);
      });
  };

  return (
    <Container>
      <Text>Goals</Text>
      <GoalList goals={goals} removeGoal={removeGoal} />
      <Form>
        <FormField>
          <FormFieldLabel name="password">Email</FormFieldLabel>
          <Input
            name="Add Goal"
            placeholder="One big thing"
            type="text"
            onChange={(e) => setGoal(e.target.value)}
            value={goal.content}
          />
        </FormField>
        <FormField row scale="lg">
          <Button onClick={(e) => addGoal(e)} type="submit">
            Submit
          </Button>
        </FormField>
      </Form>
    </Container>
  );
};

export default Home;
