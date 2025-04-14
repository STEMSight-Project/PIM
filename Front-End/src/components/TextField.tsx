import { ChangeEventHandler } from "react";

interface TextFieldProps {
  value?: string;
  onChange?: ChangeEventHandler<HTMLInputElement>;
  type?: string;
  placeholder?: string;
  disabled?: boolean;
  error?: string;
}

/*eslint-disable*/
export default function TextField({
  value = "",
  onChange = (event) => {},
  type = "text",
  placeholder = "",
  disabled = false,
  error = undefined,
}: TextFieldProps) {
  return (
    <input
      id="text-field"
      className={`bg-gray-50 border ${
        error ? "border-red-500" : "border-gray-900"
      } text-gray-900 focus:border-blue-600 focus:ring focus:ring-blue-600 focus:outline-0 text-sm rounded-lg w-full p-2.5`}
      value={value}
      onChange={onChange}
      type={type}
      placeholder={placeholder}
      disabled={disabled}
    />
  );
}
