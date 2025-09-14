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
  EyeIcon,
  PencilIcon,
  PlusIcon,
  TrashIcon,
  UserGroupIcon,
} from "@heroicons/react/24/outline";
import Link from "next/link";
import { useState } from "react";

export function PatientList() {
  const { patients, isLoading, error, createPatient, deletePatient } =
    usePatients();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [isCreating, setIsCreating] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);

  if (isLoading) {
    return <Loading size="lg" text="Loading patients..." />;
  }

  if (error) {
    return <Alert variant="error">{error}</Alert>;
  }

  const handleCreatePatient = async (patientData: PatientCreateRequest) => {
    setIsCreating(true);
    setCreateError(null);

    const result = await createPatient(patientData);

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
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <UserGroupIcon className="h-8 w-8 text-blue-600" />
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Patients</h1>
            <p className="text-gray-600">{patients.length} total patients</p>
          </div>
        </div>
        <Button
          onClick={() => setShowCreateModal(true)}
          leftIcon={<PlusIcon className="h-4 w-4" />}
        >
          Add Patient
        </Button>
      </div>

      {/* Patients Table */}
      {patients.length === 0 ? (
        <div className="text-center py-12">
          <UserGroupIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">
            No patients
          </h3>
          <p className="mt-1 text-sm text-gray-500">
            Get started by adding a new patient.
          </p>
          <div className="mt-6">
            <Button
              onClick={() => setShowCreateModal(true)}
              leftIcon={<PlusIcon className="h-4 w-4" />}
            >
              Add Patient
            </Button>
          </div>
        </div>
      ) : (
        <div className="bg-white shadow-sm rounded-lg border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableCell header>Name</TableCell>
                <TableCell header>Date of Birth</TableCell>
                <TableCell header>Gender</TableCell>
                <TableCell header>Email</TableCell>
                <TableCell header>Phone</TableCell>
                <TableCell header>Created</TableCell>
                <TableCell header>Actions</TableCell>
              </TableRow>
            </TableHeader>
            <TableBody>
              {patients.map((patient) => (
                <TableRow key={patient.id}>
                  <TableCell>
                    <div className="font-medium text-gray-900">
                      {patient.first_name} {patient.last_name}
                    </div>
                  </TableCell>
                  <TableCell>{formatDate(patient.date_of_birth)}</TableCell>
                  <TableCell>
                    <span className="capitalize">{patient.gender}</span>
                  </TableCell>
                  <TableCell>{patient.email || "-"}</TableCell>
                  <TableCell>{patient.phone || "-"}</TableCell>
                  <TableCell>{formatDate(patient.created_at)}</TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-2">
                      <Link href={`/patients/${patient.id}`}>
                        <Button variant="ghost" size="sm">
                          <EyeIcon className="h-4 w-4" />
                        </Button>
                      </Link>
                      <Link href={`/patients/${patient.id}/edit`}>
                        <Button variant="ghost" size="sm">
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
                      >
                        <TrashIcon className="h-4 w-4 text-red-500" />
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
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <Input
            label="First Name"
            value={formData.first_name}
            onChange={(e) =>
              setFormData((prev) => ({ ...prev, first_name: e.target.value }))
            }
            required
          />
          <Input
            label="Last Name"
            value={formData.last_name}
            onChange={(e) =>
              setFormData((prev) => ({ ...prev, last_name: e.target.value }))
            }
            required
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
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
            required
          />
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Gender
            </label>
            <select
              className="w-full h-10 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
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

        <Input
          label="Email"
          type="email"
          value={formData.email}
          onChange={(e) =>
            setFormData((prev) => ({ ...prev, email: e.target.value }))
          }
        />

        <Input
          label="Phone"
          type="tel"
          value={formData.phone}
          onChange={(e) =>
            setFormData((prev) => ({ ...prev, phone: e.target.value }))
          }
        />

        <Input
          label="Address"
          value={formData.address}
          onChange={(e) =>
            setFormData((prev) => ({ ...prev, address: e.target.value }))
          }
        />

        <Input
          label="Emergency Contact"
          value={formData.emergency_contact}
          onChange={(e) =>
            setFormData((prev) => ({
              ...prev,
              emergency_contact: e.target.value,
            }))
          }
        />

        {error && <Alert variant="error">{error}</Alert>}

        <div className="flex space-x-3 pt-4">
          <Button
            type="button"
            variant="outline"
            onClick={handleClose}
            fullWidth
          >
            Cancel
          </Button>
          <Button type="submit" isLoading={isLoading} fullWidth>
            {isLoading ? "Creating..." : "Create Patient"}
          </Button>
        </div>
      </form>
    </Modal>
  );
}
