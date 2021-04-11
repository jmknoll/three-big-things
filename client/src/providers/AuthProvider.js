import React, { useEffect, useReducer } from "react";
import ProtectedRoute from "../components/ProtectedRoute";
import DataService from "../services/DataService";
const dataService = new DataService();

const AuthContext = React.createContext();

function useAuth() {
  const context = React.useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within a AuthProvider");
  }
  return context;
}

const initialState = {
  isAuthenticated: false,
  user: null,
  token: null,
};

const reducer = (state, action) => {
  console.log("running action", action);
  switch (action.type) {
    case "LOGIN":
      localStorage.setItem("user", JSON.stringify(action.payload.user));
      localStorage.setItem("token", JSON.stringify(action.payload.token));
      return {
        ...state,
        isAuthenticated: true,
        user: action.payload.user,
        token: action.payload.token,
      };
    case "LOGOUT":
      localStorage.clear();
      return {
        ...state,
        isAuthenticated: false,
        user: null,
        token: null,
      };
    default:
      return state;
  }
};

function AuthProvider(props) {
  const [state, dispatch] = useReducer(reducer, initialState);

  useEffect(() => {
    fetchUser();
  }, [false]);

  const fetchUser = async () => {
    try {
      const token = JSON.parse(localStorage.getItem("token"));
      const [result, error] = await dataService.fetchUser({ token });
      if (result) {
        dispatch({
          type: "LOGIN",
          payload: { user: result.user, token: result.token },
        });
      }
    } catch (e) {
      console.log(e);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        state,
        dispatch,
      }}
      {...props}
    />
  );
}

export { AuthProvider, useAuth };
