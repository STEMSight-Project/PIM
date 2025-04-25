import React from "react";

const NewUserForm: React.FC = () => {
  return (
    <div className="max-w-2xl mx-auto p-6 bg-white rounded-2xl shadow-md">
      <h1 className="text-2xl font-bold mb-4">Create New Medical Account</h1>
      <form className="grid grid-cols-1 gap-4">
        {/* Full Name */}
        <div>
          <label className="block font-medium">Full Name</label>
          <input type="text" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Title */}
        <div>
          <label className="block font-medium">Title</label>
          <select className="w-full border rounded px-3 py-2">
            <option>Dr.</option>
            <option>EMT</option>
            <option>RN</option>
            <option>Paramedic</option>
            <option>Other</option>
          </select>
        </div>

        {/* Professional Role */}
        <div>
          <label className="block font-medium">Professional Role</label>
          <select className="w-full border rounded px-3 py-2">
            <option>Doctor</option>
            <option>Emergency Responder</option>
            <option>Nurse</option>
            <option>Other</option>
          </select>
        </div>

        {/* License Number */}
        <div>
          <label className="block font-medium">License / Certification Number</label>
          <input type="text" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Issuing Authority */}
        <div>
          <label className="block font-medium">Issuing Authority</label>
          <input type="text" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Affiliated Institution */}
        <div>
          <label className="block font-medium">Affiliated Institution</label>
          <input type="text" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Email */}
        <div>
          <label className="block font-medium">Work Email</label>
          <input type="email" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Password */}
        <div>
          <label className="block font-medium">Password</label>
          <input type="password" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Confirm Password */}
        <div>
          <label className="block font-medium">Confirm Password</label>
          <input type="password" className="w-full border rounded px-3 py-2" />
        </div>

        {/* Submit Button */}
        <div className="text-right">
          <button type="submit" className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700">
            Create Account
          </button>
        </div>
      </form>
    </div>
  );
};

export default NewUserForm;
