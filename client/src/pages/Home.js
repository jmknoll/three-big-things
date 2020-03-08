import React, { useState, useEffect } from "react";
import { useAuth } from "../providers/AuthProvider";
import DataService from "../services/DataService";

import localforage from "localforage";

import { Text } from "@smooth-ui/core-sc";
import styled from "styled-components";

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
  const [goals, setGoals] = useState([]);

  useEffect(() => {
    if (user && user.token) {
      DataService.getGoals({ token: user.token })
        .then(res => {
          setGoals(res.data);
        })
        .catch(err => {
          console.log(err);
        });
    }
  }, [user]);

  return (
    <Container>
      <Text>Goals</Text>
      {goals.map(goal => (
        <Goal>
          <Text>{goal.content}</Text>
        </Goal>
      ))}
    </Container>
  );
};

export default Home;
