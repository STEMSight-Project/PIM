
import PatientEdit from "../../PatientEdit";

export default async function EditPage({ params }: { params: Promise<{ id: string }> }) {
  const unwrappedParams = await params; 
  return <PatientEdit patientId={unwrappedParams.id} />;
}