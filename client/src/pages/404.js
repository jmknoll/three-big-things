import React from "react";
import { Link } from "react-router-dom";

const NoMatch = () => {
  return (
    <>
      <p>Page Not Found</p>
      <Link to="/home">Home</Link>
    </>
  );
};

export default NoMatch;
