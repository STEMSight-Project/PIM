# STEMSight PIM Frontend

 Overview

The STEMSight PIM  is a **Next.js 15** application  for monitoring camera AI performance and analyzing movement detection data from Raspberry Pi 4 devices. It provides dashboards for viewing live camera feeds, reviewing AI-detected postures and movements, and managing camera device configurations.


```
Front-End/
├── src/
│   ├── app/                    # Next.js App Router (Pages)
│   │   ├── layout.tsx         # Root layout
│   │   ├── page.tsx           # Login page
│   │   ├── dashboard/         # Main AI monitoring dashboard
│   │   ├── patient-dashboard/ # Subject-specific views
│   │   ├── patients/          # Patient management
│   │   │   └── [slug]/        # Dynamic patient detail pages
│   │   │       ├── page.tsx   # Patient overview with tabs
│   │   │       └── (tabs)     # Medical History, Detection History, Video Sessions
│   │   ├── recent-live-session/ # RPi camera session monitoring
│   │   ├── password-reset/    # Password reset flow
│   │   ├── streamingDash/     # Live camera streaming dashboard
│   │   └── video-playback/    # Video review and analysis
│   │
│   ├── components/            # Reusable UI Components
│   │   ├── ui/               # Base UI components (Button, Card, etc.)
│   │   ├── layouts/          # Layout components
│   │   │   ├── AuthLayout.tsx
│   │   │   └── DashboardLayout.tsx
│   │   ├── session-review/   # Video session analysis with AI detection
│   │   └── ModalPopUp/       # Modal dialogs
│   │
│   ├── hooks/                # Custom React Hooks
│   │   ├── useAuth.tsx       # Authentication context
│   │   ├── usePatients.ts    # Patient data management
│   │   ├── useStreaming.ts   # WebRTC streaming
│   │   ├── useVideos.ts      # Video management
│   │   ├── useMedicalHistory.ts # Medical records
│   │   └── useNotes.ts       # Notes and annotations
│   │
│   ├── services/             # API Service Layer
│   │   ├── api.ts           # Base API client
│   │   ├── authService.ts   # Authentication services
│   │   ├── patientService.ts # Patient CRUD operations
│   │   ├── videoService.ts  # Video management
│   │   ├── streamingService.ts # WebRTC streaming
│   │   └── index.ts         # Service exports
│   │
│   ├── types/               # TypeScript Definitions
│   │   ├── auth.ts         # Authentication types
│   │   ├── medical.ts      # Medical data types
│   │   ├── api.ts          # API response types
│   │   └── index.ts        # Type exports
│   │
│   ├── features/           # Feature-specific Components
│   │   └── patients/       # Patient management features
│   │
│   ├── store/             # State Management
│   │   └── (future Zustand store)
│   │
│   └── utils/             # Utility Functions
│       └── cn.ts          # Class name utilities
│
├── public/                # Static Assets
│   ├── STEMSight-Logo.png
│   └── videos/           # Sample video files
│
├── package.json          # Dependencies and scripts
├── next.config.ts        # Next.js configuration
├── tailwind.config.ts    # Tailwind CSS configuration
└── tsconfig.json         # TypeScript configuration
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn
- Backend running on http://localhost:8000

### Installation

1. **Navigate to frontend:**

   ```bash
   cd PIM/Front-End
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Configure environment:**

   ```bash
   # Create environment file
   echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:8000" > .env.local
   ```

4. **Start development server:**

   ```bash
   npm run dev
   ```

5. **Access application:**
   - Frontend: http://localhost:3000
   - Login with your healthcare provider credentials

## 🎯 Core Features

### 1. **Recent Live Session Monitoring**

- **Centralized Session Dashboard**: View all RPi 4 camera sessions in one place (`/recent-live-session`)
- **Session Statistics**: Real-time metrics on active sessions, total detections, and confidence scores
- **Session History**: Complete timeline of camera monitoring sessions with status tracking
- **RPi Integration**: Automatic session detection from Raspberry Pi 4 devices (no manual start required)

### 2. **Enhanced Patient Management**

- **Dynamic Patient Routes**: RESTful URLs with `/patients/[patientId]` structure
- **Tabbed Patient Interface**:
  - **Overview**: Personal information and monitoring statistics
  - **Medical History**: Clinical records and medical notes
  - **Detection History**: AI-detected movements and postures from recent sessions
  - **Video Sessions**: Recorded sessions and camera feeds
- **Patient-Specific Detection Analytics**: Detailed view of AI detection events per patient

### 3. **Live Patient Monitoring**

- Real-time video streams from Raspberry Pi 4 devices
- AI-powered posture and movement detection alerts
- Multi-patient dashboard view

### 4. **Medical Records Management**

- Patient information and demographics
- Medical history tracking
- Notes and annotations system

### 5. **Video Analysis**

- Session review and playback
- AI detection timeline
- Annotation and note-taking tools

### 6. **Role-Based Access**

- Healthcare provider dashboard (`/dashboard`)
- Patient-specific views (`/patient-dashboard`)
- Secure authentication with JWT tokens

## 🏛️ Architecture Patterns

### Service Layer Architecture

The frontend uses a **service layer pattern** to separate API logic from components:

```typescript
// services/patientService.ts
export const patientService = {
  async getAll(): Promise<ApiResponse<Patient[]>> {
    return api.get<Patient[]>("/patients/");
  },

  async getById(id: string): Promise<ApiResponse<Patient>> {
    return api.get<Patient>(`/patients/${id}`);
  },

  async create(data: PatientCreateRequest): Promise<ApiResponse<Patient>> {
    return api.post<Patient>("/patients/", data);
  },
};
```

### Custom Hooks Pattern

Business logic is encapsulated in custom hooks:

```typescript
// hooks/usePatients.ts
export function usePatients() {
  const [patients, setPatients] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchPatients = useCallback(async () => {
    setLoading(true);
    const response = await patientService.getAll();
    setPatients(response.data || []);
    setLoading(false);
  }, []);

  return { patients, loading, fetchPatients };
}
```

### Component Usage

```typescript
// app/dashboard/page.tsx
"use client";

import { usePatients } from "@/hooks";
import { DashboardLayout } from "@/components/layouts";

export default function Dashboard() {
  const { patients, loading, fetchPatients } = usePatients();

  useEffect(() => {
    fetchPatients();
  }, [fetchPatients]);

  return (
    <DashboardLayout>
      {loading ? <LoadingSpinner /> : <PatientList patients={patients} />}
    </DashboardLayout>
  );
}
```

## �️ Routing & Navigation

### Updated Navigation Structure

The application features an updated navigation with improved organization:

```typescript
// DashboardLayout navigation
const navigation = [
  { name: "Dashboard", href: "/dashboard", icon: HomeIcon },
  { name: "Subjects", href: "/patients", icon: UserGroupIcon },
  {
    name: "Recent Live Session",
    href: "/recent-live-session",
    icon: DocumentTextIcon,
  },
  { name: "Live Cameras", href: "/streamingDash", icon: VideoCameraIcon },
];
```

### Dynamic Patient Routing

Patient pages use RESTful dynamic routing patterns:

```
/patients/[patientId]           # Patient detail page with tabs
├── Overview Tab                # Personal info + monitoring stats
├── Medical History Tab         # Clinical records
├── Detection History Tab       # AI detection events
└── Video Sessions Tab          # Recorded camera sessions
```

**Key Benefits:**

- **SEO-friendly URLs**: `/patients/123` instead of `/patients?id=123`
- **Browser navigation**: Proper back/forward button support
- **Bookmarkable links**: Direct links to specific patients
- **RESTful structure**: Follows standard web conventions

### Session Management

- **RPi-Initiated Sessions**: Camera sessions are automatically started by Raspberry Pi devices
- **Frontend Monitoring**: Dashboard displays and manages existing sessions (no manual start controls)
- **Session Analytics**: Comprehensive view in `/recent-live-session` page

## �🔗 API Integration

### Base API Client

```typescript
// services/api.ts
import { useAuth } from "@/hooks/useAuth";

const api = {
  async get<T>(endpoint: string): Promise<ApiResponse<T>> {
    const token = getAuthToken();
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
    });
    return response.json();
  },
};
```

### Authentication Integration

```typescript
// hooks/useAuth.tsx
export function useAuth() {
  const [user, setUser] = useState<User | null>(null);

  const login = async (credentials: LoginRequest) => {
    const response = await authService.login(credentials);
    if (response.data) {
      setUser(response.data.user);
      localStorage.setItem("token", response.data.access_token);
    }
  };

  return { user, login, logout };
}
```

## 🎥 Streaming Integration

### WebRTC Streaming

```typescript
// hooks/useStreaming.ts
export function useStreaming() {
  const [isStreaming, setIsStreaming] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  const startStreaming = async (roomId: string) => {
    const response = await streamingService.publishViewer({
      room_id: roomId,
      viewer_type: "dashboard",
    });

    // Setup WebRTC connection
    const pc = new RTCPeerConnection();
    // ... WebRTC setup logic
  };

  return { isStreaming, videoRef, startStreaming };
}
```

### RPi 4 Integration

```typescript
// components/LiveStreamDashboard.tsx
export function LiveStreamDashboard() {
  const { activeStreams } = useStreaming();

  return (
    <div className="grid grid-cols-2 gap-4">
      {activeStreams.map((stream) => (
        <StreamCard
          key={stream.room_id}
          roomId={stream.room_id}
          patientId={stream.patient_id}
          status={stream.status} // "live" | "recent"
        />
      ))}
    </div>
  );
}
```

## 🎨 UI/UX Patterns

### Layout System

```typescript
// components/layouts/DashboardLayout.tsx
export function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();

  return (
    <div className="min-h-screen bg-gray-50">
      <NavigationBar user={user} />
      <Sidebar />
      <main className="ml-64 p-6">{children}</main>
    </div>
  );
}
```

### UI Components

```typescript
// components/ui/Button.tsx
interface ButtonProps {
  variant?: "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({
  variant = "primary",
  size = "md",
  children,
  onClick,
}: ButtonProps) {
  return (
    <button
      className={cn(
        "font-medium rounded-lg transition-colors",
        variantStyles[variant],
        sizeStyles[size]
      )}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

## 📱 Responsive Design

### Tailwind CSS Configuration

```typescript
// tailwind.config.ts
export default {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: "#0066cc",
        secondary: "#6b7280",
        danger: "#ef4444",
      },
      screens: {
        tablet: "768px",
        laptop: "1024px",
        desktop: "1280px",
      },
    },
  },
};
```

### Mobile-First Approach

```typescript
// Responsive grid for patient cards
<div className="grid grid-cols-1 tablet:grid-cols-2 laptop:grid-cols-3 gap-4">
  {patients.map((patient) => (
    <PatientCard key={patient.id} patient={patient} />
  ))}
</div>
```

## 🧪 Development Workflow

### Adding New Features

1. **Create service methods:**

   ```typescript
   // services/newFeatureService.ts
   export const newFeatureService = {
     async getData(): Promise<ApiResponse<Data[]>> {
       return api.get<Data[]>("/new-feature/");
     },
   };
   ```

2. **Create custom hook:**

   ```typescript
   // hooks/useNewFeature.ts
   export function useNewFeature() {
     // Hook logic here
   }
   ```

3. **Create page/component:**
   ```typescript
   // app/new-feature/page.tsx
   "use client";
   export default function NewFeaturePage() {
     // Component logic
   }
   ```

### Type Safety

```typescript
// types/newFeature.ts
export interface NewFeatureData {
  id: string;
  name: string;
  created_at: string;
}

export interface NewFeatureCreateRequest {
  name: string;
}
```

## 🔒 Authentication & Security

### Protected Routes

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, loading } = useAuth();

  if (loading) return <LoadingSpinner />;
  if (!user) redirect("/");

  return <DashboardLayout>{children}</DashboardLayout>;
}
```

### Token Management

```typescript
// Automatic token injection in API calls
const token = localStorage.getItem("token");
if (token) {
  headers["Authorization"] = `Bearer ${token}`;
}
```

## 📊 State Management

### Local Component State

```typescript
const [localState, setLocalState] = useState(initialValue);
```

### Context for Global State

```typescript
// hooks/useAuth.tsx - Authentication context
const AuthContext = createContext<AuthContextType | undefined>(undefined);
```

### Future: Zustand Store

```typescript
// store/useStore.ts (future implementation)
import { create } from "zustand";

interface AppState {
  patients: Patient[];
  setPatients: (patients: Patient[]) => void;
}

export const useStore = create<AppState>((set) => ({
  patients: [],
  setPatients: (patients) => set({ patients }),
}));
```

## 🧪 Testing Strategy

### Component Testing

```bash
# Future: Jest + React Testing Library
npm run test
```

### Manual Testing Checklist

- [ ] Login/logout functionality
- [ ] Patient dashboard loads correctly
- [ ] Live streaming connects to RPi 4
- [ ] Video playback works
- [ ] Medical history CRUD operations
- [ ] Notes and annotations system

## 📋 Available Scripts

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server

# Code Quality
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript checker

# Utility
npm run clean        # Clean build cache
```

## 🚨 Common Issues & Solutions

### Build Errors

```bash
# Clear Next.js cache
rm -rf .next
npm run dev
```

### API Connection Issues

- Verify backend is running on port 8000
- Check CORS configuration in backend
- Ensure proper authentication tokens

### Streaming Problems

- Check WebRTC browser compatibility
- Verify RPi 4 camera permissions
- Test with broadcaster utility from backend

## 🎯 Performance Optimization

### Code Splitting

```typescript
// Lazy load heavy components
const VideoPlayer = lazy(() => import("@/components/VideoPlayer"));

// Use in component
<Suspense fallback={<LoadingSpinner />}>
  <VideoPlayer />
</Suspense>;
```

### Image Optimization

```typescript
import Image from "next/image";

<Image
  src="/STEMSight-Logo.png"
  alt="STEMSight Logo"
  width={200}
  height={100}
  priority // For above-fold images
/>;
```

## 📚 Additional Resources

- [Next.js 15 Documentation](https://nextjs.org/docs)
- [React 18 Documentation](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## 🤝 Contributing

1. Follow the service layer pattern for API calls
2. Use custom hooks for business logic
3. Implement TypeScript interfaces for all data
4. Follow Tailwind CSS for styling
5. Use "use client" directive for interactive components
6. Test streaming functionality with real RPi 4 devices
7. Update this README when adding new features

## 🔄 Integration with Backend

### Expected API Response Format

```typescript
interface ApiResponse<T> {
  data: T | null;
  error: string | null;
  status?: number;
}
```

### Authentication Flow

1. User logs in via `/` page
2. Token stored in localStorage
3. Token automatically added to API headers
4. Protected routes check authentication status
5. Automatic redirect to login if unauthenticated
