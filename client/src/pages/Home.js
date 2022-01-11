import React, { Fragment, useState } from "react";
import { withRouter, Redirect } from "react-router-dom";
import SigninModal from "../components/SigninModal";

import { useAuth } from "../providers/AuthProvider";

const Home = (props) => {
  const [showModal, setShowModal] = useState(false);

  const { state } = useAuth(null);
  const { isAuthenticated } = state;

  const params = new URLSearchParams(window.location);
  const afterLogin = params.get("afterLogin");

  return (
    <>
      <div className="relative bg-gray-50 overflow-hidden">
        {isAuthenticated ? <Redirect to="/dashboard" /> : null}
        <div
          className="hidden sm:block sm:absolute sm:inset-y-0 sm:h-full sm:w-full"
          aria-hidden="true"
        >
          <div className="relative h-full max-w-7xl mx-auto"></div>
        </div>

        <div className="relative pt-6 pb-16 sm:pb-24">
          <main className="mt-16 mx-auto max-w-7xl px-4 sm:mt-24">
            <div className="text-center">
              <h1 className="text-4xl tracking-tight font-extrabold text-gray-900 sm:text-5xl md:text-6xl">
                <span className="block xl:inline">Better results through</span>{" "}
                <span className="block text-indigo-600 xl:inline">
                  better data
                </span>
              </h1>
              <p className="mt-3 max-w-md mx-auto text-base text-gray-500 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
                Goalbook provides rigorous mapping and tracking of daily and
                weekly goals, and provides you with the insight you need to
                actually achieve them.
              </p>
              <div className="mt-5 max-w-md mx-auto sm:flex sm:justify-center md:mt-8">
                <div className="rounded-md shadow">
                  <span
                    onClick={() => {
                      setShowModal(true);
                    }}
                    href="#"
                    className="w-full flex items-center justify-center px-8 py-3 border border-transparent text-base font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 md:py-4 md:text-lg md:px-10"
                  >
                    Get started
                  </span>
                </div>
              </div>
            </div>
          </main>
        </div>
      </div>
      {showModal ? (
        <SigninModal
          showModal={showModal}
          setShowModal={setShowModal}
          className="signin-modal"
        />
      ) : null}
    </>
  );
};

export default withRouter(Home);
