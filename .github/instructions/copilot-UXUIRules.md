# STEMSight PIM - UI/UX Design System Rules

## 🎨 Color Palette & Theme System

### Primary Color Scheme

The application uses a **blue-focused color palette** for professional healthcare interface:

#### **Blue Primary Colors**

```css
/* Primary Blues */
--blue-50: #eff6ff    /* Very light blue backgrounds */
--blue-100: #dbeafe   /* Light blue surfaces */
--blue-200: #bfdbfe   /* Light blue borders */
--blue-300: #93c5fd   /* Medium light blue accents */
--blue-400: #60a5fa   /* Medium blue elements */
--blue-500: #3b82f6   /* Primary blue (main brand) */
--blue-600: #2563eb   /* Primary blue dark */
--blue-700: #1d4ed8   /* Dark blue (buttons, headers) */
--blue-800: #1e40af   /* Very dark blue */
--blue-900: #1e3a8a   /* Darkest blue */
```

#### **Secondary Colors**

```css
/* Slate/Gray for neutrals */
--slate-50: #f8fafc
--slate-100: #f1f5f9
--slate-200: #e2e8f0
--slate-300: #cbd5e1
--slate-400: #94a3b8
--slate-500: #64748b
--slate-600: #475569
--slate-700: #334155
--slate-800: #1e293b
--slate-900: #0f172a

/* Status Colors */
--green-500: #10b981   /* Success, Live status */
--red-500: #ef4444     /* Errors, Alerts */
--amber-500: #f59e0b   /* Warnings */
--emerald-500: #10b981 /* Positive actions */
```

### **Color Usage Rules**

#### **Backgrounds**

- **Page Background**: `bg-slate-50` (light gray-blue)
- **Card Backgrounds**: `bg-white` with `border-slate-200`
- **Header Backgrounds**: `bg-gradient-to-r from-blue-600 to-blue-700`
- **Section Backgrounds**: `bg-blue-50` for highlighted sections

#### **Text Colors**

- **Primary Text**: `text-slate-900` (dark text)
- **Secondary Text**: `text-slate-600` (medium gray)
- **Muted Text**: `text-slate-500` (light gray)
- **On Blue Background**: `text-white` or `text-blue-100`

#### **Interactive Elements**

- **Primary Buttons**: `bg-blue-600 hover:bg-blue-700 text-white`
- **Secondary Buttons**: `border-blue-200 text-blue-700 hover:bg-blue-50`
- **Links**: `text-blue-600 hover:text-blue-700`
- **Focus States**: `ring-2 ring-blue-500 ring-offset-2`

## 🎯 Component Design Standards

### **Button System**

```tsx
// Primary Action Button
<Button className="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-2.5 rounded-lg shadow-sm transition-colors duration-200">
  Primary Action
</Button>

// Secondary Button
<Button className="border border-blue-200 text-blue-700 hover:bg-blue-50 font-medium px-6 py-2.5 rounded-lg transition-colors duration-200">
  Secondary Action
</Button>

// Outline Button
<Button className="border border-slate-300 text-slate-700 hover:bg-slate-50 font-medium px-4 py-2 rounded-lg">
  Outline Button
</Button>
```

### **Card System**

```tsx
// Standard Card
<Card className="bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-lg transition-shadow duration-300">
  <CardHeader className="pb-4 border-b border-slate-100">
    <h3 className="text-lg font-bold text-slate-900">Card Title</h3>
  </CardHeader>
  <CardContent className="p-6">
    Card content here
  </CardContent>
</Card>

// Highlighted Card (for important content)
<Card className="bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-200 rounded-xl">
  Content for highlighted cards
</Card>
```

### **Badge System**

```tsx
// Status Badges
const badgeVariants = {
  live: "bg-red-500 text-white animate-pulse border-2 border-red-400",
  success: "bg-emerald-100 text-emerald-800 border border-emerald-200",
  warning: "bg-amber-100 text-amber-800 border border-amber-200",
  secondary: "bg-slate-100 text-slate-700 border border-slate-200",
  default: "bg-blue-100 text-blue-800 border border-blue-200",
};
```

## 📐 Layout & Spacing Standards

### **Container System**

```tsx
// Main page container
<div className="min-h-screen bg-slate-50">
  <div className="container mx-auto px-6 py-8">Page content</div>
</div>
```

### **Grid Systems**

```tsx
// Dashboard grid (responsive)
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
  Grid items
</div>

// Two-column layout
<div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
  <div className="lg:col-span-2">Main content</div>
  <div>Sidebar</div>
</div>
```

### **Spacing Scale**

- **xs**: `space-x-1, gap-1` (4px)
- **sm**: `space-x-2, gap-2` (8px)
- **md**: `space-x-4, gap-4` (16px)
- **lg**: `space-x-6, gap-6` (24px)
- **xl**: `space-x-8, gap-8` (32px)

## 🎨 Header & Navigation Standards

### **Page Headers**

```tsx
// Standard page header
<div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden mb-8">
  <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-6">
    <div className="flex items-center justify-between">
      <div className="flex items-center space-x-4">
        <div className="bg-white/20 p-3 rounded-xl backdrop-blur-sm">
          <Icon className="h-8 w-8 text-white" />
        </div>
        <div>
          <h1 className="text-3xl font-bold text-white">Page Title</h1>
          <p className="text-blue-100 mt-1">Page description</p>
        </div>
      </div>
      <div className="hidden lg:flex items-center space-x-6">
        {/* Stats or actions */}
      </div>
    </div>
  </div>
</div>
```

### **Navigation Elements**

```tsx
// Navigation links
<a href="#" className="text-slate-700 hover:text-blue-600 font-medium transition-colors duration-200">
  Navigation Link
</a>

// Active navigation state
<a href="#" className="text-blue-600 font-semibold border-b-2 border-blue-600">
  Active Link
</a>
```

## 📊 Data Display Standards

### **Stats Cards**

```tsx
<Card className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
  <div className="flex items-center justify-between">
    <div className="flex items-center space-x-4">
      <div className="p-3 bg-blue-600 rounded-lg">
        <Icon className="w-6 h-6 text-white" />
      </div>
      <div>
        <p className="text-sm font-medium text-slate-600">Metric Label</p>
        <p className="text-2xl font-bold text-slate-900">Value</p>
        <p className="text-xs text-slate-500 mt-1">Trend indicator</p>
      </div>
    </div>
    <div className="flex items-center">
      <StatusIndicator />
    </div>
  </div>
</Card>
```

### **Status Indicators**

```tsx
// Live status indicator
<div className="flex items-center space-x-2">
  <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
  <span className="text-sm font-medium text-slate-700">System Online</span>
</div>

// Activity status
<div className="flex items-center space-x-2">
  <Icon className="h-4 w-4 text-blue-600" />
  <span className="text-sm text-slate-600">Status text</span>
</div>
```

## 🎭 Animation & Interaction Standards

### **Hover Effects**

```css
/* Card hover effects */
.hover-lift {
  @apply hover:shadow-lg hover:-translate-y-1 transition-all duration-300;
}

/* Button hover effects */
.button-hover {
  @apply transition-colors duration-200;
}

/* Link hover effects */
.link-hover {
  @apply transition-colors duration-200;
}
```

### **Loading States**

```tsx
// Loading spinner
<div className="relative mx-auto w-16 h-16 mb-8">
  <div className="absolute inset-0 rounded-full border-4 border-blue-200 animate-pulse"></div>
  <div className="absolute inset-0 rounded-full border-t-4 border-blue-600 animate-spin"></div>
</div>

// Loading dots
<div className="flex space-x-1">
  <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
  <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style={{animationDelay: '0.1s'}}></div>
  <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce" style={{animationDelay: '0.2s'}}></div>
</div>
```

## 🚨 Error & Alert Standards

### **Error Messages**

```tsx
<div className="bg-red-50 border border-red-200 rounded-xl p-6 mb-6">
  <div className="flex items-start space-x-4">
    <ExclamationTriangleIcon className="h-6 w-6 text-red-600 flex-shrink-0" />
    <div className="flex-1">
      <h3 className="text-lg font-semibold text-red-900 mb-1">Error Title</h3>
      <p className="text-red-700 mb-3">Error message description</p>
      <Button className="bg-red-600 hover:bg-red-700 text-white">
        Retry Action
      </Button>
    </div>
  </div>
</div>
```

### **Success Messages**

```tsx
<div className="bg-green-50 border border-green-200 rounded-xl p-4">
  <div className="flex items-center space-x-3">
    <CheckCircleIcon className="h-6 w-6 text-green-600" />
    <div>
      <p className="font-medium text-green-900">Success Title</p>
      <p className="text-green-700 text-sm">Success message</p>
    </div>
  </div>
</div>
```

## 📱 Responsive Design Rules

### **Breakpoint System**

- **sm**: 640px+ (Small tablets, large phones)
- **md**: 768px+ (Tablets)
- **lg**: 1024px+ (Small laptops)
- **xl**: 1280px+ (Laptops, desktops)
- **2xl**: 1536px+ (Large screens)

### **Mobile-First Responsive Patterns**

```tsx
// Responsive grid
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 lg:gap-6">

// Responsive text
<h1 className="text-2xl md:text-3xl lg:text-4xl font-bold">

// Responsive spacing
<div className="p-4 md:p-6 lg:p-8">

// Responsive flex direction
<div className="flex flex-col lg:flex-row gap-4">
```

## 🎯 Application-Specific Patterns

### **Camera/Streaming Interface**

```tsx
// Live stream card
<Card className="bg-white border border-slate-200 rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 hover:-translate-y-1">
  <CardHeader className="pb-4 bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-slate-100">
    <div className="flex items-center justify-between">
      <div className="flex items-center space-x-3">
        <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center">
          <UserIcon className="h-5 w-5 text-white" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-slate-900">Patient Name</h3>
          <p className="text-sm text-slate-600">Patient ID</p>
        </div>
      </div>
      <Badge variant="live">LIVE</Badge>
    </div>
  </CardHeader>
</Card>
```

### **Medical Data Display**

```tsx
// Medical info card with blue accent
<div className="bg-slate-50 rounded-lg p-4 border-l-4 border-blue-500">
  <div className="flex items-center justify-between mb-3">
    <span className="font-semibold text-slate-800">Medical Info</span>
    <Icon className="h-4 w-4 text-blue-600" />
  </div>
  <div className="text-sm text-slate-600">Medical content here</div>
</div>
```

## 🔧 Implementation Guidelines

### **CSS Custom Properties**

Add these to your global CSS:

```css
:root {
  --color-primary: #2563eb;
  --color-primary-dark: #1d4ed8;
  --color-secondary: #64748b;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-surface: #ffffff;
  --color-background: #f8fafc;
}
```

### **Tailwind Configuration**

Extend your Tailwind config:

```js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#eff6ff",
          500: "#3b82f6",
          600: "#2563eb",
          700: "#1d4ed8",
        },
      },
      animation: {
        "pulse-slow": "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
      },
    },
  },
};
```

## ✅ Quality Checklist

When implementing any UI component, ensure:

- [ ] Uses blue primary color scheme
- [ ] Has proper hover and focus states
- [ ] Includes appropriate transitions (200ms for interactions)
- [ ] Has consistent spacing using the scale
- [ ] Is fully responsive across all breakpoints
- [ ] Includes proper accessibility (ARIA labels, contrast ratios)
- [ ] Uses semantic HTML elements
- [ ] Has loading and error states where applicable
- [ ] Follows the component hierarchy (Card > CardHeader > CardContent)
- [ ] Uses consistent icon sizing and placement

## 🎨 Dark Mode Considerations

**Note**: The application currently forces light mode only. If dark mode is implemented in the future:

```css
/* Dark mode color overrides (for future use) */
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #0f172a;
    --color-surface: #1e293b;
    --color-primary: #3b82f6;
  }
}
```

---

**Remember**: Consistency is key. Every page should feel like part of the same professional healthcare application. Use these rules as your foundation and build upon them while maintaining the blue-focused, clean, and professional aesthetic.
