import React, { useState, createContext } from "react";
import dataService from "../services/DataService";

const DataContext = createContext();

const useData = () => {
  const context = React.useContext(DataContext);
  if (!context) {
    throw new Error("useData must be used within a DataProvider");
  }
  return context;
};

const initialState = {
  goals: [],
  goal: {},
};

const DataProvider = (props) => {
  const [state, setState] = useState(initialState);
  const [error, setError] = useState("");

  const updateState = (key, val) => {
    setState((prevState) => {
      return { ...prevState, [key]: val };
    });
  };

  const fetchGoals = ({ token }) => {
    dataService
      .fetchGoals({ token: token })
      .then((res) => {
        updateState("goals", res.data);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const addGoal = ({ goal, token }) => {
    dataService
      .createGoal({ token, goal })
      .then((res) => {
        const goals = [...state.goals, res.data];
        updateState("goals", goals);
        updateState("goal", {});
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const removeGoal = ({ goal, token }) => {
    dataService
      .removeGoal({ token, goal })
      .then((res) => {
        const goals = state.goals.filter(
          (goal) => goal.id !== parseInt(res.data.id)
        );
        updateState("goals", goals);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const actions = {
    fetchGoals,
    addGoal,
    removeGoal,
  };

  return <DataContext.Provider value={{ actions, state }} {...props} />;
};

export { DataProvider, useData };
