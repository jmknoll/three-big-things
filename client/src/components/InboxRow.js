import react, { useState } from "react";
import { Avatar } from "./Avatar";
import { CheckIcon, XIcon } from "@heroicons/react/outline";
import ReactMarkdown from "react-markdown";

const InboxRow = ({ goal, editGoal }) => {
  const [isVisible, setIsVisible] = useState(true);
  return (
    // <CSSTransition classNames="inbox-row" in={isVisible} timeout={500}>
    <div className="bg-white shadow overflow-hidden sm:rounded-md my-2">
      <li className>
        <a className="block hover:bg-gray-50">
          <div className="flex items-center px-4 py-4 sm:px-6">
            <div className="min-w-0 flex-1 flex items-center">
              <div className="flex-shrink-0">
                <Avatar
                  name={goal.period}
                  color={
                    goal?.period === "WEEKLY" ? "bg-red-700" : "bg-indigo-700"
                  }
                />
              </div>
              <div className="min-w-0 flex-1 px-4 md:grid md:grid-cols-2 md:gap-4">
                <div>
                  <p className="text-lg text-gray-800 font-medium truncate">
                    {goal.name}
                  </p>
                  <p className="prose mt-2 text-sm text-gray-500">
                    <ReactMarkdown children={goal.content} />
                  </p>
                </div>
              </div>
            </div>
            <div>
              <button
                type="button"
                className="inline-flex mr-4 items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-green-500 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
              >
                <CheckIcon
                  className="h-6 w-6"
                  aria-hidden="true"
                  onClick={() => {
                    setIsVisible(false);
                    editGoal({ ...goal, status: "COMPLETE" });
                  }}
                />
              </button>
              <button
                type="button"
                className="inline-flex items-center p-2 border border-transparent rounded-full shadow-sm text-white bg-red-500 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
              >
                <XIcon
                  className="h-6 w-6"
                  aria-hidden="true"
                  onClick={() => editGoal({ ...goal, status: "NOT_COMPLETED" })}
                />
              </button>
            </div>
          </div>
        </a>
      </li>
    </div>
    // </CSSTransition>
  );
};

export default InboxRow;
