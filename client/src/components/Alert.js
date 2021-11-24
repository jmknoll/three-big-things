/* This example requires Tailwind CSS v2.0+ */
import { ExclamationIcon } from "@heroicons/react/solid";

const Alert = (props) => {
  return (
    <div className="rounded-md bg-yellow-50 p-3 alert">
      <div className="flex items-center">
        <ExclamationIcon
          className="h-5 w-5 text-yellow-400"
          aria-hidden="true"
        />
        <div className="ml-3">
          <div className="text-sm text-yellow-700">
            <p>{props.content()}</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Alert;
