import axios from "axios";

const DataService = {
  signup: params => {
    console.log(params);
  },
  signin: params => {
    return axios
      .post(
        `${process.env.REACT_APP_BASE_URL}/auth`,
        {
          email: params.email,
          password: params.password
        },
        {
          headers: { "Content-type": "application/json" }
        }
      )
      .then(res => {
        return res.data;
      })
      .catch(err => {
        return err;
      });
  },
  getGoals: params => {
    return axios.get(`${process.env.REACT_APP_BASE_URL}/goals`, {
      headers: {
        "Content-type": "application/json",
        "x-access-token": params.token
      }
    });
  },
  createGoal: params => {
    return axios.post(
      `${process.env.REACT_APP_BASE_URL}/goals`,
      { period: "daily", content: params.goal },
      {
        headers: {
          "Content-type": "application/json",
          "x-access-token": params.token
        }
      }
    );
  },
  removeGoal: params => {
    return axios.delete(
      `${process.env.REACT_APP_BASE_URL}/goals/${params.goal.id}`,
      {
        headers: {
          "Content-type": "application/json",
          "x-access-token": params.token
        }
      }
    );
  }
};

export default DataService;
