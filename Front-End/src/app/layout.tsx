import { ThemeProvider } from "@/components/providers";
import { ClientOnly } from "@/components/ui";
import { AuthProvider } from "@/hooks/useAuth";
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Suspense } from "react";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "STEMSight PIM",
  description: "Posture and Movement Analysis Platform",
  icons: {
    icon: "/favicon.ico",
    shortcut: "/favicon.ico",
    apple: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="light">
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              document.documentElement.classList.add('light');
              document.documentElement.style.colorScheme = 'light';
            `,
          }}
        />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased light min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-slate-100`}
      >
        <ClientOnly
          fallback={
            <div className="min-h-screen bg-transparent flex items-center justify-center">
              <div className="text-center">
                <div className="relative mx-auto w-16 h-16 mb-8">
                  <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
                  <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
                </div>
                <p className="text-slate-600 font-medium">
                  Loading STEMSight...
                </p>
              </div>
            </div>
          }
        >
          <ThemeProvider>
            <AuthProvider>
              <Suspense
                fallback={
                  <div className="min-h-screen bg-transparent flex items-center justify-center">
                    <div className="text-center">
                      <div className="relative mx-auto w-16 h-16 mb-8">
                        <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
                        <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
                      </div>
                      <p className="text-slate-600 font-medium">
                        Initializing application...
                      </p>
                    </div>
                  </div>
                }
              >
                {children}
              </Suspense>
            </AuthProvider>
          </ThemeProvider>
        </ClientOnly>
      </body>
    </html>
  );
}
