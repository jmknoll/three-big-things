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

const initialGoal = {};

const initialState = {
  goals: [],
  archivedGoals: [],
  goal: initialGoal,
};

const DataProvider = (props) => {
  const [state, setState] = useState(initialState);
  const [error, setError] = useState("");

  const updateState = (key, val) => {
    setState((prevState) => {
      return { ...prevState, [key]: val };
    });
  };

  const fetchGoals = ({ token, archived }) => {
    dataService
      .fetchGoals({ token, archived })
      .then((res) => {
        if (archived) {
          updateState("archivedGoals", res.data);
        } else {
          updateState("goals", res.data);
        }
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const createGoal = ({ goal, token }) => {
    dataService
      .createGoal({ token, goal })
      .then((res) => {
        const index = state.goals.findIndex((goal) => goal.id === res.data.id);
        // this handles the response from upsert to determine if it is a create or update
        const goals =
          index > -1
            ? Object.assign([], state.goals, { [index]: res.data })
            : [...state.goals, res.data];
        updateState("goals", goals);
        updateState("goal", {});
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const editGoal = async ({ goal, token }) => {
    try {
      let { data, error } = await dataService.editGoal({ token, goal });
      if (data && !error) {
        const idx = state.goals.findIndex((el) => el.id === data.id);
        const goals = Object.assign([], state.goals, { [idx]: data });
        updateState("goals", goals);
      }
    } catch (err) {
      console.log(err);
    }
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

  const dispatch = {
    fetchGoals,
    createGoal,
    editGoal,
    removeGoal,
  };

  return <DataContext.Provider value={{ dispatch, state }} {...props} />;
};

export { DataProvider, useData };
