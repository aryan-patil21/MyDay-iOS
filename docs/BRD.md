# Business Requirements Document (BRD)
## Project Name: MyDay — Native iOS Lifestyle & Personal Intelligence

---

### Document Control
- **Document Version:** 1.0.0
- **Author:** Aryan Patil (AI & Data Science)
- **Product:** MyDay iOS
- **Status:** Approved / Reverse-Engineered Baseline

---

## 1. Executive Summary

In the modern digital lifestyle landscape, individuals face severe digital fragmentation. A typical user relies on:
1. A to-do application (e.g., Apple Reminders, Todoist) for operational obligations.
2. A habit tracker (e.g., Streaks, Habitica) to build consistency.
3. A mood or journaling app (e.g., Day One, Apple Journal) for mental wellness.

This fragmentation creates cognitive overload, friction, and context switching. Furthermore, the majority of modern commercial apps rely on invasive cloud backends, subscription models, third-party analytics trackers, and external AI APIs that monetize or compromise sensitive personal thoughts.

**MyDay** solves this by unifying **tasks, habits, and mindful journaling into a single, cohesive command center**, powered by **100% on-device local intelligence** with **zero server costs, zero trackers, and complete data privacy**.

---

## 2. Business Objectives & Vision

| Objective ID | Business Objective | Success Metric / KPI |
| :--- | :--- | :--- |
| **BO-01** | **Unified Lifestyle Experience** | Eliminate app switching by unifying tasks, habits, and mood reflection into one landing view. |
| **BO-02** | **Zero Operational Infrastructure Cost** | $0.00/month recurring server costs. 100% of computation, storage, and AI run on-device. |
| **BO-03** | **Data Sovereignty & Privacy Moat** | Absolute local data storage with zero telemetry, zero analytics, and open JSON export/import. |
| **BO-04** | **Frictionless Habit Retention** | Increase daily return rates using calendar-accurate streak mechanics and native local notifications. |
| **BO-05** | **Actionable Intelligence** | Provide on-device machine learning insights correlating habits directly to mental well-being. |

---

## 3. Target Audience & User Personas

### Persona A: The High-Performing Student / Knowledge Worker (e.g., Alex, 21)
- **Demographics:** University student or young professional juggling coursework, projects, and personal health.
- **Pain Points:** Overwhelmed by fragmented tools; forgets recurring habits when busy; wants quick, glanceable daily focus.
- **Goal:** Wants to open one app in the morning, see high-priority focus tasks, tick off habits in seconds, and track momentum.

### Persona B: The Privacy-Conscious Mindful Practitioner (e.g., Maya, 28)
- **Demographics:** Technology professional mindful of burnout, mental well-being, and corporate telemetry.
- **Pain Points:** Distrusts cloud-based AI journals reading private reflections; hates subscription fatigue.
- **Goal:** Wants a private, offline safe space to log daily gratitude and track how daily routines impact emotional health.

---

## 4. Value Proposition & Competitive Differentiation

```mermaid
quadrantChart
    title Privacy vs. Feature Integration
    x-axis Low Privacy (Cloud Tracked) --> High Privacy (100% Local)
    y-axis Fragmented (Single Utility) --> Unified (Tasks + Habits + Journal)
    quadrant-1 "MyDay (Market Sweet Spot)"
    quadrant-2 "Apple Notes / Reminders"
    quadrant-3 "Ad-supported Habit Apps"
    quadrant-4 "Notion / Todoist / Day One"
    "MyDay": [0.95, 0.90]
    "Notion": [0.15, 0.85]
    "Day One": [0.30, 0.40]
    "Streaks": [0.85, 0.35]
    "Todoist": [0.20, 0.45]
```

- **Unified Synergy:** Tasks, habits, and reflections mutually enrich each other on the "Today" dashboard.
- **On-Device Apple Intelligence:** Uses Apple's Neural Engine (`NaturalLanguage` framework) rather than sending sensitive journal data to OpenAI or external cloud servers.
- **Zero Lock-In:** Full JSON export and restoration capability built directly into the app.

---

## 5. Scope & Boundary

### In Scope
- Single universal iOS/iPadOS native application.
- Local SQLite database management via Apple's modern SwiftData engine.
- 4-tab native navigation: Today Dashboard, Tasks, Habits, Journal.
- Local notifications for task due dates and daily evening reflection.
- On-device sentiment scoring and habit-mood correlation matrix.
- Interactive Home Screen widgets (`WidgetKit`).
- Automated unit testing suite (`Swift Testing`).

### Out of Scope (Intentional Design Exclusions)
- Cloud accounts, user login, social sharing, and external server synchronization (preserves 100% privacy and zero infrastructure costs).
- Third-party monetization SDKs or tracking pixels.

---

## 6. Financial & Operational Model

- **Infrastructure Expense:** **$0.00 / year** (Client-only compute; storage is sandboxed on the user's iPhone).
- **Maintenance Model:** Native Apple frameworks ensure long-term stability across iOS version updates with minimal maintenance overhead.
