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
  createGoal: () => {}
};

export default DataService;
