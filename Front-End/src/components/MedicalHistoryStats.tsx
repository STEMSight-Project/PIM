import { Card } from "@/components/ui/Card";
import type { MedicalHistory } from "@/services/medicalHistoryService";
import { ChartBarIcon, ClockIcon, DocumentTextIcon, UserIcon } from "@heroicons/react/24/outline";

interface MedicalHistoryStatsProps {
  medicalHistories: MedicalHistory[];
}

export function MedicalHistoryStats({ medicalHistories }: MedicalHistoryStatsProps) {
  const totalRecords = medicalHistories.length;
  const recordsWithNotes = medicalHistories.filter(record => record.note && record.note.trim()).length;
  const uniqueDoctors = new Set(medicalHistories.map(record => record.doctor_id)).size;
  
  // Get most recent record date
  const mostRecentDate = medicalHistories.length > 0 
    ? new Date(Math.max(...medicalHistories.map(record => new Date(record.created_at).getTime())))
    : null;

  const stats = [
    {
      label: "Total Records",
      value: totalRecords,
      icon: DocumentTextIcon,
      color: "blue"
    },
    {
      label: "Records with Notes",
      value: recordsWithNotes,
      icon: ChartBarIcon,
      color: "green"
    },
    {
      label: "Unique Doctors",
      value: uniqueDoctors,
      icon: UserIcon,
      color: "purple"
    },
    {
      label: "Days Since Last",
      value: mostRecentDate ? Math.floor((Date.now() - mostRecentDate.getTime()) / (1000 * 60 * 60 * 24)) : "N/A",
      icon: ClockIcon,
      color: "orange"
    }
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat, index) => (
        <Card key={index} className="p-4">
          <div className="flex items-center">
            <div className={`p-2 rounded-md bg-${stat.color}-100`}>
              <stat.icon className={`h-6 w-6 text-${stat.color}-600`} />
            </div>
            <div className="ml-3">
              <p className="text-sm font-medium text-gray-600">{stat.label}</p>
              <p className="text-2xl font-semibold text-gray-900">{stat.value}</p>
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}