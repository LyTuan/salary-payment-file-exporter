# Salary Payment File Exporter

This is a Ruby on Rails API application designed to accept salary payment information, store it, and export it daily as a formatted text file.

---

## 📦 Tech Stack

*   **Ruby:** 3.3.4
*   **Rails:** 8.0 (API Mode)
*   **Database:** PostgreSQL (managed via Docker)
*   **Testing:** RSpec, FactoryBot, Shoulda-Matchers
*   **Containerization:** Docker & Docker Compose

---

## ⚙️ Prerequisites

Before you begin, ensure you have the following installed on your system:

*   [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (version 3.3.4, preferably managed with a tool like `rbenv` or `asdf`)
*   Bundler
*   Docker
*   Docker Compose

---

## 🚀 Getting Started

Follow these steps to get your development environment set up and running.

### 1. Clone the Repository

```sh
git clone <your-repository-url>
cd salary-payment-file-exporter
```

### 2. Install Dependencies

Install the required Ruby gems using Bundler.

```sh
bundle install
```

### 3. Start the Database

This project uses Docker Compose to manage the PostgreSQL database. Start the database container in the background:

```sh
docker-compose up -d
```

### 4. Create and Set Up the Database

With the database container running, create, migrate, and seed your development and test databases.

```sh
# Create the databases
rails db:create

# Run migrations
rails db:migrate

# Seed the database with initial data (e.g., a default company)
rails db:seed
```

### 5. Run the Application

Start the Rails server. By default, it will run on `http://localhost:3000`.

```sh
rails server
```

---

## ✅ How to Run the Test Suite

This project uses RSpec for testing.

1.  **Prepare the Test Database:**
    Ensure your test database schema is up to date.
    ```sh
    rails db:test:prepare
    ```

2.  **Run All Tests:**
    Execute the entire test suite with the following command:
    ```sh
    bundle exec rspec
    ```

---

## 🛠️ Usage

### API Endpoint: Create Payments

You can submit a batch of payments to the `POST /payments` endpoint.

**Example `curl` Request:**

```sh
curl -X POST http://localhost:3000/payments \
-H "Content-Type: application/json" \
-d '{
  "payment": {
    "company_id": 1,
    "payments": [
      {
        "employee_id": "E123",
        "bank_bsb": "062000",
        "bank_account": "12345678",
        "amount_cents": 500000,
        "currency": "AUD",
        "pay_date": "2024-10-28"
      },
      {
        "employee_id": "E456",
        "bank_bsb": "082000",
        "bank_account": "87654321",
        "amount_cents": 650000,
        "currency": "AUD",
        "pay_date": "2024-10-28"
      }
    ]
  }
}'
```

### Rake Task: Export Payments

To manually trigger the daily payment export job, run the following Rake task. This will query pending payments and generate a `.txt` file in the `/exports` directory.

```sh
rails exporter:run
```
