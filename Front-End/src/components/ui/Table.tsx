"use client";

import React from "react";
import { cn } from "@/utils/cn";

interface TableProps {
  children: React.ReactNode;
  className?: string;
}

interface TableHeaderProps {
  children: React.ReactNode;
  className?: string;
}

interface TableBodyProps {
  children: React.ReactNode;
  className?: string;
}

interface TableRowProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  hover?: boolean;
}

interface TableCellProps {
  children: React.ReactNode;
  className?: string;
  header?: boolean;
  align?: "left" | "center" | "right";
}

export function Table({ children, className }: TableProps) {
  return (
    <div className="overflow-x-auto">
      <table className={cn("min-w-full divide-y divide-gray-200", className)}>
        {children}
      </table>
    </div>
  );
}

export function TableHeader({ children, className }: TableHeaderProps) {
  return <thead className={cn("bg-gray-50", className)}>{children}</thead>;
}

export function TableBody({ children, className }: TableBodyProps) {
  return (
    <tbody className={cn("bg-white divide-y divide-gray-200", className)}>
      {children}
    </tbody>
  );
}

export function TableRow({
  children,
  className,
  onClick,
  hover = true,
}: TableRowProps) {
  return (
    <tr
      className={cn(
        onClick && "cursor-pointer",
        hover && "hover:bg-gray-50 transition-colors",
        className
      )}
      onClick={onClick}
    >
      {children}
    </tr>
  );
}

export function TableCell({
  children,
  className,
  header = false,
  align = "left",
}: TableCellProps) {
  const Component = header ? "th" : "td";

  const alignClasses = {
    left: "text-left",
    center: "text-center",
    right: "text-right",
  };

  return (
    <Component
      className={cn(
        "px-6 py-4 text-sm",
        header
          ? "font-medium text-gray-900 tracking-wider uppercase"
          : "text-gray-500",
        alignClasses[align],
        className
      )}
    >
      {children}
    </Component>
  );
}
