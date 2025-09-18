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
      color: "purple",
      bgGradient: "from-purple-500 to-violet-500"
    },
    {
      label: "Records with Notes",
      value: recordsWithNotes,
      icon: ChartBarIcon,
      color: "violet",
      bgGradient: "from-violet-500 to-purple-500"
    },
    {
      label: "Unique Doctors",
      value: uniqueDoctors,
      icon: UserIcon,
      color: "purple",
      bgGradient: "from-purple-600 to-purple-500"
    },
    {
      label: "Days Since Last",
      value: mostRecentDate ? Math.floor((Date.now() - mostRecentDate.getTime()) / (1000 * 60 * 60 * 24)) : "N/A",
      icon: ClockIcon,
      color: "violet",
      bgGradient: "from-violet-600 to-purple-500"
    }
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat, index) => (
        <Card key={index} className="p-4 bg-gradient-to-br from-purple-50 to-violet-50 border-purple-200 hover:shadow-lg transition-all duration-200 hover:border-purple-300">
          <div className="flex items-center">
            <div className={`p-3 rounded-lg bg-gradient-to-br ${stat.bgGradient} shadow-md`}>
              <stat.icon className="h-6 w-6 text-white" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-purple-700">{stat.label}</p>
              <p className="text-2xl font-bold text-purple-900">{stat.value}</p>
            </div>
          </div>
        </Card>
      ))}
    </div>
  );
}