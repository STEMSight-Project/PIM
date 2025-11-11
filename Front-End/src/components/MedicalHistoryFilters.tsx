import { Button } from "@/components/ui/Button";
import { MagnifyingGlassIcon, XMarkIcon } from "@heroicons/react/24/outline";
import { useState } from "react";

interface MedicalHistoryFiltersProps {
  onSearch: (searchTerm: string) => void;
  onDoctorFilter: (doctorId: string) => void;
  onDateFilter: (dateRange: { start: string; end: string }) => void;
  onClearFilters: () => void;
  doctorOptions: string[];
}

export function MedicalHistoryFilters({
  onSearch,
  onDoctorFilter,
  onDateFilter,
  onClearFilters,
  doctorOptions,
}: MedicalHistoryFiltersProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedDoctor, setSelectedDoctor] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  const handleSearchChange = (value: string) => {
    setSearchTerm(value);
    onSearch(value);
  };

  const handleDoctorChange = (value: string) => {
    setSelectedDoctor(value);
    onDoctorFilter(value);
  };

  const handleClearAll = () => {
    setSearchTerm("");
    setSelectedDoctor("");
    setStartDate("");
    setEndDate("");
    onClearFilters();
  };

  const hasActiveFilters = searchTerm || selectedDoctor || startDate || endDate;

  return (
    <div className="bg-gradient-to-r from-purple-50 to-violet-50 p-4 border border-purple-200 rounded-lg shadow-md space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-purple-900">Filter Records</h3>
        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={handleClearAll}
            className="text-purple-600 hover:text-purple-800 hover:bg-purple-100"
          >
            <XMarkIcon className="h-4 w-4 mr-1" />
            Clear All
          </Button>
        )}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {/* Search */}
        <div>
          <label
            htmlFor="search"
            className="block text-sm font-medium text-purple-800 mb-1"
          >
            Search
          </label>
          <div className="relative">
            <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-purple-400" />
            <input
              id="search"
              type="text"
              value={searchTerm}
              onChange={(e) => handleSearchChange(e.target.value)}
              placeholder="Search diagnosis or notes..."
              className="pl-10 w-full px-3 py-2 border border-purple-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 bg-white placeholder-purple-400"
            />
          </div>
        </div>

        {/* Doctor Filter */}
        <div>
          <label
            htmlFor="doctor"
            className="block text-sm font-medium text-purple-800 mb-1"
          >
            Doctor
          </label>
          <select
            id="doctor"
            value={selectedDoctor}
            onChange={(e) => handleDoctorChange(e.target.value)}
            className="w-full px-3 py-2 border border-purple-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 bg-white text-purple-900"
          >
            <option value="">All Doctors</option>
            {doctorOptions.map((doctor) => (
              <option key={doctor} value={doctor}>
                {doctor}
              </option>
            ))}
          </select>
        </div>

        {/* Date Range */}
        <div>
          <label
            htmlFor="startDate"
            className="block text-sm font-medium text-purple-800 mb-1"
          >
            From Date
          </label>
          <input
            id="startDate"
            type="date"
            value={startDate}
            onChange={(e) => {
              setStartDate(e.target.value);
              if (e.target.value && endDate) {
                onDateFilter({ start: e.target.value, end: endDate });
              }
            }}
            className="w-full px-3 py-2 border border-purple-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 bg-white text-purple-900"
          />
        </div>

        <div>
          <label
            htmlFor="endDate"
            className="block text-sm font-medium text-purple-800 mb-1"
          >
            To Date
          </label>
          <input
            id="endDate"
            type="date"
            value={endDate}
            onChange={(e) => {
              setEndDate(e.target.value);
              if (startDate && e.target.value) {
                onDateFilter({ start: startDate, end: e.target.value });
              }
            }}
            className="w-full px-3 py-2 border border-purple-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 bg-white text-purple-900"
          />
        </div>
      </div>
    </div>
  );
}
