import axios from "axios";

const signin = (params) => {
  const { email, password } = params;
  return axios
    .post(
      `${process.env.REACT_APP_BASE_URL}/auth`,
      {
        email,
        password,
      },
      {
        headers: { "Content-type": "application/json" },
      }
    )
    .then((res) => {
      return res.data;
    })
    .catch((err) => {
      return err;
    });
};

const oauth = (params) => {
  const { token } = params;
  return axios
    .post(
      `${process.env.REACT_APP_BASE_URL}/oauth`,
      {
        token,
      },
      {
        headers: {
          "Content-Type": "application/json",
        },
      }
    )
    .then((res) => {
      return { result: res.data, error: null };
    })
    .catch((err) => {
      return { result: null, error: err };
    });
};

const fetchUser = (params) => {
  const { token } = params;
  return axios
    .get(`${process.env.REACT_APP_BASE_URL}/me`, {
      headers: {
        "Content-type": "application/json",
        "x-access-token": token,
      },
    })
    .then((res) => ({ data: res.data, error: null }))
    .catch((err) => ({ data: null, error: err }));
};

const fetchGoals = (params) => {
  return axios.get(`${process.env.REACT_APP_BASE_URL}/goals`, {
    headers: {
      "Content-type": "application/json",
      "x-access-token": params.token,
    },
  });
};

const createGoal = (params) => {
  const { goal } = params;
  return axios.post(
    `${process.env.REACT_APP_BASE_URL}/goals`,
    { ...goal },
    {
      headers: {
        "Content-type": "application/json",
        "x-access-token": params.token,
      },
    }
  );
};

const removeGoal = (params) => {
  return axios.delete(
    `${process.env.REACT_APP_BASE_URL}/goals/${params.goal.id}`,
    {
      headers: {
        "Content-type": "application/json",
        "x-access-token": params.token,
      },
    }
  );
};

const dataService = {
  signin,
  oauth,
  fetchUser,
  fetchGoals,
  createGoal,
  removeGoal,
};

export default dataService;
