import { PatientEvent } from "@/services/patientEventService";

export const mapEventToDetection = (event: PatientEvent) => {
  const colorMap: { [key: string]: string } = {
    myoclonus: "red",
    tremor: "yellow",
    decerebrate: "purple",
    decorticate: "blue",
    ballistic: "green",
    versive: "orange",
  };

  return {
    type: event.type,
    color: colorMap[event.type.toLowerCase()] || "gray",
  };
};

export const formatDateTime = (dateStr: string) => {
  const date = new Date(dateStr);

  const dateOptions: Intl.DateTimeFormatOptions = {
    year: "numeric",
    month: "long",
    day: "numeric",
  };
  const formattedDate = date.toLocaleDateString("en-US", dateOptions);

  const timeOptions: Intl.DateTimeFormatOptions = {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  };
  const formattedTime = date.toLocaleTimeString("en-US", timeOptions);

  return {
    date: formattedDate,
    time: formattedTime,
  };
};
