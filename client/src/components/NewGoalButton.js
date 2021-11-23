import React from "react";

export const NewGoalButton = (props) => {
  const { setShowGoalModal } = props;

  return (
    <button
      type="button"
      className="text-gray-500 flex flex-col justify-center items-center border-2 border-gray-300 border-dashed rounded-lg p-12 text-center hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-cyan-500"
      onClick={() => {
        props.setType(props.type);
        setShowGoalModal(true);
      }}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M12 4v16m8-8H4"
        />
      </svg>
      <span className="mt-2 block text-sm font-medium">Add a new goal</span>
    </button>
  );
};
