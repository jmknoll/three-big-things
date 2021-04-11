import axios from "axios";

class DataService {
  signin(params) {
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
  }

  oauth(params) {
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
      .then((res) => [res.data, null])
      .catch((err) => [null, err]);
  }

  fetchUser(params) {
    const { token } = params;
    return axios
      .get(`${process.env.REACT_APP_BASE_URL}/me`, {
        headers: {
          "Content-type": "application/json",
          "x-access-token": token,
        },
      })
      .then((res) => [res.data, null])
      .catch((err) => [null, err]);
  }

  fetchGoals(params) {
    return axios.get(`${process.env.REACT_APP_BASE_URL}/goals`, {
      headers: {
        "Content-type": "application/json",
        "x-access-token": params.token,
      },
    });
  }

  createGoal(params) {
    return axios.post(
      `${process.env.REACT_APP_BASE_URL}/goals`,
      { period: "daily", content: params.goal },
      {
        headers: {
          "Content-type": "application/json",
          "x-access-token": params.token,
        },
      }
    );
  }

  removeGoal(params) {
    return axios.delete(
      `${process.env.REACT_APP_BASE_URL}/goals/${params.goal.id}`,
      {
        headers: {
          "Content-type": "application/json",
          "x-access-token": params.token,
        },
      }
    );
  }
}

export default DataService;
