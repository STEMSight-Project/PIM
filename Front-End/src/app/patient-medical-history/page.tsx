import "./style.css";
import Image from "next/image";

export default function PatientMedicalHistory() {
  return (
    <div className="bg-white text-black min-h-screen">
      
      <nav className="bg-gray-800 text-white p-4 flex justify-between">
        <span className="text-xl font-bold">STEMSight </span>
        <ul className="flex gap-6">
          <li><a href="#" className="hover:underline">Home</a></li>
          <li><a href="#" className="hover:underline">Live Cameras</a></li>
          <li><a href="#" className="hover:underline">Records</a></li>
          <li><a href="#" className="hover:underline">Support</a></li>

          <li>
      <a href="#">
        <Image
          src="/profile-icon.svg" // The profile icon svg to pull up drop-down menu
          alt="Profile"
          width={24}
          height={24}
          className="cursor-pointer invert"
        />
      </a>
    </li>

        </ul>
      </nav>
      
      <header className="text-center p-6 text-2xl font-bold">
        Patient Name: <span className="text-blue-600">{`{Patient Name Placeholder}`}</span>
      </header>

      <main className="max-w-3xl mx-auto p-6">

        <h2 className="text-xl font-semibold mb-4">Medical History</h2>
        <div className="space-y-4">
          {}
          <div className="border p-4 rounded shadow">
            <p className="font-semibold">Condition: Diabetes</p>
            <p>Date Diagnosed: 2023-05-20</p>
            <p>Notes: Patient uses Insulin medication</p>
          </div>

          <div className="border p-4 rounded shadow">
            <p className="font-semibold">Condition: Hypertension</p>
            <p>Date Diagnosed: 2018-09-10</p>
            <p>Notes: The patient has a history of mild focal epilepsy and is 
                currently taking levetiracetam (Keppra) for seizure management. They 
                report a good response to the medication, with minimal to no seizures 
                and no significant side effects.</p>
          </div>
        </div>

      </main>
      <footer className="row-start-3 flex gap-6 flex-wrap items-center justify-center">
        &copy; 2025 STEMSight Inc. All rights reserved.
      </footer>
    </div>
  );
}
