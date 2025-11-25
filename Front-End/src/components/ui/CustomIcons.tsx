import React from "react";
import Image from "next/image";

interface CustomIcons {
    className?: string;
}

export function CustomDash({ className }: CustomIcons) {
  return (
     <Image
          src="/dashboard-icon.svg"
          alt="Dashboard Icon"
          width={30}
          height={30}
      className={`${className ?? "h-5 w-5"}`}
     />
  );
}

export function CustomPatient({ className }: CustomIcons) {
  return (
     <Image
      src="/patients-icon.svg"
      alt="Patient Icon"
      width={30}
      height={30}
      className={`${className ?? "h-5 w-5"}`}
    />
  );
}

export function CustomRecent({ className }: CustomIcons) {
  return (
     <Image
      src="/recent-icon.svg"
      alt="Recent Icon"
      width={30}
      height={30}
      className={`${className ?? "h-5 w-5"}`}
    />
  );
}

export function CustomReplay({ className }: CustomIcons) {
  return (
     <Image
      src="/playback-icon.svg"
      alt="Replay Icon"
      width={30}
      height={30}
      className={`${className ?? "h-5 w-5"}`}
    />
  );
}

export function CustomCamera({ className }: CustomIcons) {
  return (
     <Image
      src="/camera-icon.svg"
      alt="Camera Icon"
      width={30}
      height={30}
      className={`${className ?? "h-5 w-5"}`}
    />
  );
}