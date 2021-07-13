import React, { useState, useEffect } from "react";
import { useAuth } from "../providers/AuthProvider";
import DataService from "../services/DataService";
import GoalList from "../components/GoalList";
import Navbar from "../components/Navbar";

import styled from "styled-components";

const dataService = new DataService();

const Container = styled.div`
  padding: 20px 20px;
`;

const Home = () => {
  const { state } = useAuth();
  const { user, token } = state;
  let [goals, setGoals] = useState([]);
  const [goal, setGoal] = useState({});

  useEffect(() => {
    dataService
      .fetchGoals({ token: token })
      .then((res) => {
        setGoals(res.data);
      })
      .catch((err) => {
        console.log(err);
      });
  }, [false]);

  const addGoal = (e) => {
    e.preventDefault();
    dataService
      .createGoal({ token, goal })
      .then((res) => {
        setGoals([...goals, res.data]);
        setGoal({ content: "" });
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const removeGoal = (goal) => {
    dataService
      .removeGoal({ token: user.token, goal: goal })
      .then((res) => {
        setGoals(goals.filter((goal) => goal.id !== parseInt(res.data.id)));
      })
      .catch((err) => {
        console.log(err);
      });
  };

  return (
    <Container>
      <p>Goals</p>
      <GoalList goals={goals} removeGoal={removeGoal} />
      <form>
        <input
          type="text"
          label="Add New Goal"
          variant="outlined"
          onChange={(e) => setGoal(e.target.value)}
          value={goal.content}
        />

        <button
          variant="contained"
          color="primary"
          onClick={(e) => addGoal(e)}
          type="submit"
        >
          Submit
        </button>
      </form>
    </Container>
  );
};

export default Home;
