"use client";

import { ReactNode } from "react";

interface ModalProps {
  children: ReactNode;
  hidden: boolean;
  className?: string;
}

export default function Modal({ children, hidden, className }: ModalProps) {
  return (
    <div className={className}>
      <div
        className={`
          fixed inset-0 z-10 flex items-center justify-center
          transition-opacity duration-300 ease-in-out
          ${hidden ? "opacity-0 pointer-events-none" : "opacity-100"}
        `}
        aria-labelledby="modal-title"
        role="dialog"
        aria-modal="true"
      >
        <div className="fixed inset-0 bg-gray-500/75" aria-hidden="true"></div>
        <div className="fixed inset-0 z-10 w-screen overflow-y-auto">
          <div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
            <div className="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
              <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div className="flex-col space-y-4 justify-items-center">
                  {children}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
