import React from "react";

export const Avatar = (props) => {
  const { name, size } = props;

  const processInitials = (name) => {
    const names = name.split(" ");
    const first = names[0]?.substring(0, 1);
    const last = names[names.length - 1]?.substring(0, 1);
    return `${first}${last}`;
  };

  if (!name) {
    return <Placeholder />;
  }

  return (
    <span
      className={`inline-flex items-center justify-center h-${size} w-${size} rounded-full bg-cyan-700`}
    >
      <span className="text-xs font-medium leading-none text-white">
        {processInitials(name)}
      </span>
    </span>
  );
};

Avatar.defaultProps = {
  name: null,
  size: 8,
};

export const Placeholder = (props) => {
  const { size } = props;
  return (
    <span
      className={`inline-block h-${size} w-${size} rounded-full overflow-hidden bg-gray-100`}
    >
      <svg
        className="h-full w-full text-gray-300"
        fill="currentColor"
        viewBox="0 0 24 24"
      >
        <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
      </svg>
    </span>
  );
};

Placeholder.defaultProps = {
  size: 8,
};
