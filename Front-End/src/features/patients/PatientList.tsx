"use client";

import {
  Alert,
  Button,
  Input,
  Loading,
  Modal,
  Table,
  TableBody,
  TableCell,
  TableHeader,
  TableRow,
} from "@/components/ui";
import { usePatients } from "@/hooks";
import type { PatientCreateRequest } from "@/types";
import { formatDate } from "@/utils/cn";
import {
  CalendarIcon,
  EnvelopeIcon,
  EyeIcon,
  FunnelIcon,
  ListBulletIcon,
  MagnifyingGlassIcon,
  MapPinIcon,
  PencilIcon,
  PhoneIcon,
  PlusIcon,
  Squares2X2Icon,
  TrashIcon,
  UserGroupIcon,
  UserIcon,
} from "@heroicons/react/24/outline";
import Link from "next/link";
import { useMemo, useState } from "react";

export function PatientList() {
  const { patients, isLoading, error, createPatient, deletePatient } =
    usePatients();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [isCreating, setIsCreating] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterGender, setFilterGender] = useState<string>("all");
  const [viewMode, setViewMode] = useState<"grid" | "table">("grid");

  // Filter and search patients
  const filteredPatients = useMemo(() => {
    return patients.filter((patient) => {
      const matchesSearch =
        `${patient.first_name} ${patient.last_name}`
          .toLowerCase()
          .includes(searchQuery.toLowerCase()) ||
        patient.email?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        patient.phone?.includes(searchQuery);

      const matchesGender =
        filterGender === "all" || patient.gender === filterGender;

      return matchesSearch && matchesGender;
    });
  }, [patients, searchQuery, filterGender]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <Loading size="lg" text="Loading patients..." />
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-md mx-auto mt-8">
        <Alert variant="error">{error}</Alert>
      </div>
    );
  }

  const handleCreatePatient = async (patientData: PatientCreateRequest) => {
    setIsCreating(true);
    setCreateError(null);

    // Normalize phone: strip non-digit characters and validate presence/length
    const normalizedPhone = patientData.phone
      ? patientData.phone.replace(/\D/g, "")
      : "";

    // Backend requires primary_phone (mapped from phone)
    if (!normalizedPhone) {
      setCreateError("Phone number is required.");
      setIsCreating(false);
      return;
    }

    // Basic length check (assuming minimum 10 digits for a valid phone number)
    if (normalizedPhone.length < 10) {
      setCreateError("Phone number must have at least 10 digits.");
      setIsCreating(false);
      return;
    }

    // Backend requires address with min_length 5 for validity
    if (!patientData.address || patientData.address.trim().length < 5) {
      setCreateError("Address is required and must be at least 5 characters.");
      setIsCreating(false);
      return;
    }

    // Date of birth is required for all patients to be created
    if (!patientData.date_of_birth) {
      setCreateError("Date of birth is required.");
      setIsCreating(false);
      return;
    }

    const payload: PatientCreateRequest = {
      ...patientData,
      phone: normalizedPhone,
    };

    const result = await createPatient(payload);

    if (result.success) {
      setShowCreateModal(false);
    } else {
      setCreateError(result.error || "Failed to create patient");
    }

    setIsCreating(false);
  };

  const handleDeletePatient = async (
    patientId: string,
    patientName: string
  ) => {
    if (
      window.confirm(
        `Are you sure you want to delete ${patientName}? This action cannot be undone.`
      )
    ) {
      const result = await deletePatient(patientId);
      if (!result.success) {
        alert(result.error || "Failed to delete patient");
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Enhanced Header with Stats */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
            <div className="flex items-center space-x-4">
              <div className="bg-blue-100 rounded-xl p-3">
                <UserGroupIcon className="h-8 w-8 text-blue-600" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">
                  Patient Management
                </h1>
                <div className="flex items-center space-x-6 mt-2 text-sm text-gray-600">
                  <span className="flex items-center">
                    <div className="w-2 h-2 bg-blue-500 rounded-full mr-2"></div>
                    {filteredPatients.length} of {patients.length} patients
                  </span>
                  <span className="flex items-center">
                    <div className="w-2 h-2 bg-green-500 rounded-full mr-2"></div>
                    Active monitoring
                  </span>
                </div>
              </div>
            </div>
            <Button
              onClick={() => setShowCreateModal(true)}
              leftIcon={<PlusIcon className="h-5 w-5" />}
              className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl font-medium shadow-md hover:shadow-lg transition-all"
            >
              Add New Patient
            </Button>
          </div>
        </div>

        {/* Search and Filter Controls */}
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 mb-6">
          <div className="flex flex-col lg:flex-row gap-4 items-start lg:items-center justify-between">
            <div className="flex flex-col sm:flex-row gap-4 flex-1">
              {/* Search Bar */}
              <div className="relative flex-1 max-w-md">
                <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <Input
                  placeholder="Search by name, email, or phone..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10 pr-4 py-3 rounded-xl border-gray-200 focus:border-blue-500 focus:ring-blue-500"
                />
              </div>

              {/* Gender Filter */}
              <div className="relative">
                <FunnelIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
                <select
                  value={filterGender}
                  onChange={(e) => setFilterGender(e.target.value)}
                  className="pl-10 pr-8 py-3 rounded-xl border border-gray-200 focus:border-blue-500 focus:ring-blue-500 bg-white min-w-[140px]"
                >
                  <option value="all">All Genders</option>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>

            {/* View Mode Toggle */}
            <div className="flex items-center bg-gray-100 rounded-xl p-1">
              <button
                onClick={() => setViewMode("grid")}
                className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-all ${
                  viewMode === "grid"
                    ? "bg-white text-blue-600 shadow-sm"
                    : "text-gray-600 hover:text-gray-900"
                }`}
              >
                <Squares2X2Icon className="h-4 w-4 mr-2" />
                Grid
              </button>
              <button
                onClick={() => setViewMode("table")}
                className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-all ${
                  viewMode === "table"
                    ? "bg-white text-blue-600 shadow-sm"
                    : "text-gray-600 hover:text-gray-900"
                }`}
              >
                <ListBulletIcon className="h-4 w-4 mr-2" />
                Table
              </button>
            </div>
          </div>
        </div>

        {/* Patients Display */}
        {filteredPatients.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 text-center py-16">
            <div className="max-w-md mx-auto">
              <div className="bg-gray-100 rounded-full p-6 w-24 h-24 mx-auto mb-6">
                <UserGroupIcon className="w-12 h-12 text-gray-400" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                {searchQuery || filterGender !== "all"
                  ? "No matching patients"
                  : "No patients yet"}
              </h3>
              <p className="text-gray-600 mb-8">
                {searchQuery || filterGender !== "all"
                  ? "Try adjusting your search or filters to find patients."
                  : "Get started by adding your first patient to the system."}
              </p>
              {!searchQuery && filterGender === "all" && (
                <Button
                  onClick={() => setShowCreateModal(true)}
                  leftIcon={<PlusIcon className="h-5 w-5" />}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl"
                >
                  Add Your First Patient
                </Button>
              )}
            </div>
          </div>
        ) : viewMode === "grid" ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredPatients.map((patient) => (
              <div
                key={patient.id}
                className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden hover:shadow-md transition-all duration-200 group"
              >
                {/* Patient Card Header */}
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="bg-blue-100 rounded-full p-3">
                        <UserIcon className="h-6 w-6 text-blue-600" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-gray-900 text-lg">
                          {patient.first_name} {patient.last_name}
                        </h3>
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
                          {patient.gender || "Not specified"}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Patient Card Content */}
                <div className="p-6 space-y-4">
                  <div className="space-y-3">
                    <div className="flex items-center text-sm text-gray-600">
                      <CalendarIcon className="h-4 w-4 mr-2 text-gray-400" />
                      <span>Born: {formatDate(patient.date_of_birth)}</span>
                    </div>
                    {patient.email && (
                      <div className="flex items-center text-sm text-gray-600">
                        <EnvelopeIcon className="h-4 w-4 mr-2 text-gray-400" />
                        <span className="truncate">{patient.email}</span>
                      </div>
                    )}
                    {patient.phone && (
                      <div className="flex items-center text-sm text-gray-600">
                        <PhoneIcon className="h-4 w-4 mr-2 text-gray-400" />
                        <span>{patient.phone}</span>
                      </div>
                    )}
                    {patient.address && (
                      <div className="flex items-center text-sm text-gray-600">
                        <MapPinIcon className="h-4 w-4 mr-2 text-gray-400" />
                        <span className="truncate">{patient.address}</span>
                      </div>
                    )}
                  </div>

                  <div className="pt-4 border-t border-gray-100">
                    <div className="flex items-center justify-between">
                      <span className="text-xs text-gray-500">
                        Added {formatDate(patient.created_at)}
                      </span>
                      <div className="flex items-center space-x-2">
                        <Link href={`/patients/${patient.id}`}>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="p-2 hover:bg-blue-50 hover:text-blue-600 rounded-lg"
                          >
                            <EyeIcon className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Link href={`/patient-edit/${patient.id}/edit`}>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="p-2 hover:bg-gray-50 rounded-lg"
                          >
                            <PencilIcon className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() =>
                            handleDeletePatient(
                              patient.id,
                              `${patient.first_name} ${patient.last_name}`
                            )
                          }
                          className="p-2 hover:bg-red-50 hover:text-red-600 rounded-lg"
                        >
                          <TrashIcon className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <Table>
              <TableHeader>
                <TableRow className="bg-gray-50">
                  <TableCell header className="font-semibold text-gray-900">
                    Name
                  </TableCell>
                  <TableCell header className="font-semibold text-gray-900">
                    Date of Birth
                  </TableCell>
                  <TableCell header className="font-semibold text-gray-900">
                    Gender
                  </TableCell>
                  <TableCell header className="font-semibold text-gray-900">
                    Contact
                  </TableCell>
                  <TableCell header className="font-semibold text-gray-900">
                    Added
                  </TableCell>
                  <TableCell header className="font-semibold text-gray-900">
                    Actions
                  </TableCell>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredPatients.map((patient, index) => (
                  <TableRow
                    key={patient.id}
                    className={index % 2 === 0 ? "bg-white" : "bg-gray-50/30"}
                  >
                    <TableCell>
                      <div className="flex items-center space-x-3">
                        <div className="bg-blue-100 rounded-full p-2">
                          <UserIcon className="h-4 w-4 text-blue-600" />
                        </div>
                        <div>
                          <div className="font-medium text-gray-900">
                            {patient.first_name} {patient.last_name}
                          </div>
                          <div className="text-sm text-gray-500 capitalize">
                            {patient.gender || "Not specified"}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center text-gray-900">
                        <CalendarIcon className="h-4 w-4 mr-2 text-gray-400" />
                        {formatDate(patient.date_of_birth)}
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
                        {patient.gender || "Not specified"}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="space-y-1">
                        {patient.email && (
                          <div className="flex items-center text-sm text-gray-600">
                            <EnvelopeIcon className="h-3 w-3 mr-2 text-gray-400" />
                            <span className="truncate max-w-[150px]">
                              {patient.email}
                            </span>
                          </div>
                        )}
                        {patient.phone && (
                          <div className="flex items-center text-sm text-gray-600">
                            <PhoneIcon className="h-3 w-3 mr-2 text-gray-400" />
                            <span>{patient.phone}</span>
                          </div>
                        )}
                        {!patient.email && !patient.phone && (
                          <span className="text-gray-400 text-sm">
                            No contact info
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="text-sm text-gray-600">
                        {formatDate(patient.created_at)}
                      </span>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center space-x-1">
                        <Link href={`/patients/${patient.id}`}>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="p-2 hover:bg-blue-50 hover:text-blue-600 rounded-lg"
                          >
                            <EyeIcon className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Link href={`/patient-edit/${patient.id}/edit`}>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="p-2 hover:bg-gray-50 rounded-lg"
                          >
                            <PencilIcon className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() =>
                            handleDeletePatient(
                              patient.id,
                              `${patient.first_name} ${patient.last_name}`
                            )
                          }
                          className="p-2 hover:bg-red-50 hover:text-red-600 rounded-lg"
                        >
                          <TrashIcon className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}

        {/* Create Patient Modal */}
        <CreatePatientModal
          isOpen={showCreateModal}
          onClose={() => setShowCreateModal(false)}
          onSubmit={handleCreatePatient}
          isLoading={isCreating}
          error={createError}
        />
      </div>
    </div>
  );
}

interface CreatePatientModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: PatientCreateRequest) => void;
  isLoading: boolean;
  error: string | null;
}

function CreatePatientModal({
  isOpen,
  onClose,
  onSubmit,
  isLoading,
  error,
}: CreatePatientModalProps) {
  const [formData, setFormData] = useState<PatientCreateRequest>({
    first_name: "",
    last_name: "",
    date_of_birth: "",
    gender: "male",
    email: "",
    phone: "",
    address: "",
    emergency_contact: "",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleClose = () => {
    setFormData({
      first_name: "",
      last_name: "",
      date_of_birth: "",
      gender: "male",
      email: "",
      phone: "",
      address: "",
      emergency_contact: "",
    });
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleClose}
      title="Add New Patient"
      size="lg"
    >
      <div className="max-h-[80vh] overflow-y-auto">
        {/* Modal Header */}
        <div className="text-center mb-6">
          <div className="bg-blue-100 rounded-full p-4 w-16 h-16 mx-auto mb-4">
            <UserIcon className="w-8 h-8 text-blue-600" />
          </div>
          <h3 className="text-2xl font-bold text-gray-900 mb-2">
            Add New Patient
          </h3>
          <p className="text-gray-600">
            Enter patient information to create their profile
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Personal Information Section */}
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-6">
            <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <UserIcon className="h-5 w-5 mr-2 text-blue-600" />
              Personal Information
            </h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Input
                label="First Name"
                value={formData.first_name}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    first_name: e.target.value,
                  }))
                }
                placeholder="Enter first name"
                className="rounded-lg border-gray-200 focus:border-blue-500"
                required
              />
              <Input
                label="Last Name"
                value={formData.last_name}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    last_name: e.target.value,
                  }))
                }
                placeholder="Enter last name"
                className="rounded-lg border-gray-200 focus:border-blue-500"
                required
              />
              <Input
                label="Date of Birth"
                type="date"
                value={formData.date_of_birth}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    date_of_birth: e.target.value,
                  }))
                }
                className="rounded-lg border-gray-200 focus:border-blue-500"
                required
              />
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Gender
                </label>
                <select
                  className="w-full px-4 py-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white"
                  value={formData.gender}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      gender: e.target.value as "male" | "female" | "other",
                    }))
                  }
                  required
                >
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="other">Other</option>
                </select>
              </div>
            </div>
          </div>

          {/* Contact Information Section */}
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-xl p-6">
            <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <PhoneIcon className="h-5 w-5 mr-2 text-green-600" />
              Contact Information
            </h4>
            <div className="space-y-4">
              <Input
                label="Email Address"
                type="email"
                value={formData.email}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, email: e.target.value }))
                }
                placeholder="patient@example.com"
                className="rounded-lg border-gray-200 focus:border-green-500"
              />
              <Input
                label="Phone Number"
                type="tel"
                value={formData.phone}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, phone: e.target.value }))
                }
                placeholder="(555) 123-4567"
                className="rounded-lg border-gray-200 focus:border-green-500"
              />
              <Input
                label="Address"
                value={formData.address}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, address: e.target.value }))
                }
                placeholder="123 Main St, City, State 12345"
                className="rounded-lg border-gray-200 focus:border-green-500"
              />
            </div>
          </div>

          {/* Emergency Contact Section */}
          <div className="bg-gradient-to-r from-orange-50 to-amber-50 rounded-xl p-6">
            <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <PhoneIcon className="h-5 w-5 mr-2 text-orange-600" />
              Emergency Contact
            </h4>
            <Input
              label="Emergency Contact Information"
              value={formData.emergency_contact}
              onChange={(e) =>
                setFormData((prev) => ({
                  ...prev,
                  emergency_contact: e.target.value,
                }))
              }
              placeholder="Name and phone number"
              className="rounded-lg border-gray-200 focus:border-orange-500"
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-xl p-4">
              <Alert variant="error">{error}</Alert>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-3 pt-6 border-t border-gray-200">
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              className="flex-1 py-3 px-6 rounded-xl border-gray-300 hover:bg-gray-50"
              disabled={isLoading}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              isLoading={isLoading}
              className="flex-1 py-3 px-6 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-medium shadow-md hover:shadow-lg transition-all"
            >
              {isLoading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Creating Patient...
                </div>
              ) : (
                <div className="flex items-center">
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Create Patient
                </div>
              )}
            </Button>
          </div>
        </form>
      </div>
    </Modal>
  );
}
