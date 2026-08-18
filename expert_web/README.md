# CropGuard Expert Web Application

Phase 6 separate React + Vite web portal for agricultural experts to review and ground-truth label uncertain crop disease predictions.

## Architecture

Expert Browser → FastAPI Backend (`/api/`) → MongoDB Atlas (`uncertain_samples`)

## Getting Started

### Step 1: Start FastAPI Backend Server
Before launching the web application, ensure the FastAPI backend server is running:

```bash
cd backend
python -m uvicorn api.main:app --reload --port 8000
```

### Step 2: Run Frontend Development Server
In a separate terminal, navigate to `expert_web` and run:

```bash
# Install dependencies
npm install

# Start Vite dev server
npm run dev
```

### Step 3: Access the Expert Portal
Open your browser at **[http://localhost:5173](http://localhost:5173)**.

### Default Login Credentials

- **Email**: `expert@cropguard.org`
- **Password**: `ExpertGuard#2026`

### Production Build

To build the static distribution bundle:

```bash
npm run build
```


## Features

- **Authentication**: JWT-based login (`/login`)
- **Dashboard**: Summary metrics (`/dashboard`)
- **Pending List**: Filtering & pagination for samples awaiting review (`/samples`)
- **Sample Review**: High-res image inspection & disease annotation (`/samples/:sampleId`)
- **Review History**: Verified ground-truth review archive (`/reviewed`)
