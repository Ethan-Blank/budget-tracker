# Budget Tracker (Phase 1 of Rewards Optimizer)

## 📌 Overview
A serverless budget tracking app built with **AWS (Lambda, API Gateway, DynamoDB)**, **React**, **Python**, and **Terraform**. Users can log income and expenses, view their balance, and track spending categories.

## 🏗 Tech Stack
- **Frontend:** React (Vite/CRA), Axios, Bootstrap/Tailwind (UI)
- **Backend:** Python (AWS Lambda + API Gateway), boto3 SDK
- **Database:** AWS DynamoDB (NoSQL, serverless)
- **Infrastructure:** Terraform (AWS IaC), AWS CLI
- **Extras:** CloudWatch (logs), GitHub Actions (CI/CD planned)

## 🗂 Architecture
```plaintext
DynamoDB → Lambda (Python) → API Gateway → React UI