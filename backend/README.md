# ⚡ TRIBE Backend Engine (District Clone)

Enterprise-grade Node.js + TypeScript backend engineered for **TRIBE Experiences & Live Events** across Northeast India.

---

## 🛠️ Recommended Tech Stack

- **Runtime & Language**: Node.js v22 (TypeScript)
- **Framework**: Express.js with modular Nest-style domain architecture
- **Payment Gateway**: Official **Razorpay** SDK (`v2.9.6`) with server-side order generation & HMAC-SHA256 signature verification
- **Database ORM**: **Prisma ORM** + **PostgreSQL** (ACID compliance & PostGIS support for geolocation)
- **Concurrency & Locking**: **Redis**-backed distributed seat locking (10-minute hold on tickets & dining slots during checkout)
- **Security & Cryptography**: **Crypto HMAC-SHA256** for tamper-proof digital gate passes & webhook signature validation
- **Asset / QR Generation**: **QRCode** library generating Base64 entry pass data URLs for gate scanners

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment (`.env`)
```env
PORT=4000
NODE_ENV=development
API_PREFIX=/api/v1
CORS_ORIGIN=*

# Razorpay Test Credentials
RAZORPAY_KEY_ID=rzp_test_TjoMcngj0CGZMk
RAZORPAY_KEY_SECRET=rzp_test_secret_placeholder_replace_with_actual
RAZORPAY_WEBHOOK_SECRET=tribe_webhook_secret_key_demo_2026

# PostgreSQL (Prisma)
DATABASE_URL="postgresql://tribe_admin:tribe_pass_secure@localhost:5432/tribe_db?schema=public"

# Redis (Seat Locking)
REDIS_URL="redis://localhost:6379"

# JWT
JWT_SECRET=tribe_jwt_super_secret_key_production_grade_99824
```

### 3. Run in Development Mode
```bash
npm run dev
```

### 4. Run Automated Tests
```bash
npm test
```

### 5. Build for Production
```bash
npm run build
npm start
```

---

## 📡 Core API Endpoints

### 1. Payments (`/api/v1/payments`)
- `POST /api/v1/payments/create-order`
  - Generates official Razorpay Order ID (`order_...`).
  - Holds inventory / seat lock for 10 minutes.
- `POST /api/v1/payments/verify`
  - Verifies cryptographic HMAC-SHA256 signature.
  - Generates authentic Pass ID (`TRB-XXXX-XXXX`) and signed QR payload.
- `POST /api/v1/payments/webhook`
  - Idempotent listener for `payment.captured`, `payment.failed`, and `refund.processed`.

### 2. Digital Entry Passes (`/api/v1/passes`)
- `POST /api/v1/passes/verify-gate-scan`
  - Endpoint for gate hostesses / staff.
  - Verifies cryptographic signature and prevents duplicate entry (`ALREADY_USED`).
- `GET /api/v1/passes/:passNumber`
  - Fetches pass status (`ACTIVE` vs `CHECKED_IN`).

### 3. Experiences & Cities (`/api/v1/events`)
- `GET /api/v1/events` — Filter concerts, dine-in, and tours by city and category.
- `GET /api/v1/events/cities` — 8 Northeast capitals with active experience counts.
- `GET /api/v1/events/:id` — Detailed package itinerary and pricing.
