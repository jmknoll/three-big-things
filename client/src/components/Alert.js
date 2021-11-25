/* This example requires Tailwind CSS v2.0+ */
import { ExclamationIcon } from "@heroicons/react/solid";

const colors = {
  SUCCESS: "green",
  INFO: "blue",
  WARNING: "yellow",
  ALERT: "red",
};

const Alert = (props) => {
  const type = props.type || "SUCCESS";
  return (
    <div className={`rounded-md bg-${colors[type]}-50 p-3 alert`}>
      <div className="flex items-center">
        <ExclamationIcon
          className={`h-5 w-5 text-${colors[type]}-400`}
          aria-hidden="true"
        />
        <div className="ml-3">
          <div className={`text-sm text-${colors[type]}-700`}>
            <p>{props.content()}</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Alert;
