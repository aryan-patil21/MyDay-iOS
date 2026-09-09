# Product Requirements Document (PRD)
## Product Name: MyDay — Native iOS Lifestyle & Personal Intelligence

---

### Document Control
- **Document Version:** 1.0.0
- **Product Owner:** Aryan Patil (AI & Data Science)
- **Target OS:** iOS 17.0+ / iPadOS 17.0+
- **Status:** Baseline / Production Ready

---

## 1. Product Overview

**MyDay** is an integrated native iOS lifestyle application designed to foster personal productivity and mindful consistency. It combines three core domains:
1. **Action Management:** Due-date driven, prioritized daily tasks.
2. **Behavioral Routines:** Daily recurring habits with unbroken streak compounding.
3. **Mindful Self-Reflection:** Emotional check-ins with sentiment analysis and gratitude journaling.

All three domains converge on a centralized **"Today" Dashboard** that offers glanceable momentum and actionable on-device lifestyle intelligence.

---

## 2. User Journeys & Workflows

### 2.1 Morning Planning & Briefing (08:00 AM)
1. User opens MyDay.
2. The Dashboard displays a warm greeting (*"Good morning"*) with a yellow sun icon and today's full date.
3. The user reviews the **Daily Momentum** card (0% completed).
4. The user glances at the **Habits Quick-Strip** and taps their first completed routine (e.g., *"Drink Water"*), immediately feeling a haptic click and seeing the momentum bar advance.
5. The user reviews **Focus Tasks** due today.

### 2.2 Daytime Execution & Task Triage (02:00 PM)
1. User receives a local notification alert for a scheduled task.
2. User taps the notification or opens the app, checks off the task directly on the Dashboard.
3. The task animates with a strikethrough, moves to the completed group, and its pending system notification is automatically cancelled.

### 2.3 Evening Mindfulness Check-In (08:30 PM)
1. User receives a reminder: *"Time for Your Daily Reflection ✨"*.
2. User taps the banner, leading to the **Journal** tab.
3. User selects their mood emoji (`😄 Great`), taps feeling tags (`Productive`, `Grateful`), and writes a 2-sentence note.
4. User taps **Save**. Today's check-in banner celebrates: *"✨ Today's check-in complete!"*.

### 2.4 Weekly Intelligence Review
1. User reviews the **AI Daily Insights** card on the Dashboard.
2. The card highlights: *"Positive Reflection Tone: +0.82 sentiment score"*.
3. User taps **View Details** to open the `InsightsDetailSheet`, exploring their **Habit Impact on Mood** matrix to see which habits empirically drive positive days.

---

## 3. Functional Requirements (FR)

### FR-1: Unified "Today" Dashboard
- **FR-1.1:** The app must display a dynamic greeting (*"Good morning"*, *"Good afternoon"*, or *"Good evening"*) based on device clock hours (5-12, 12-17, 17-5) with corresponding icons (`sun.max.fill`, `sunset.fill`, `moon.stars.fill`).
- **FR-1.2:** The app must display a **Daily Momentum** progress indicator calculating:
  $$\text{Progress} = \frac{\text{Completed Habits} + (\text{Reflected Today} ? 1 : 0)}{\text{Total Habits} + \text{Pending Focus Tasks} + 1}$$
- **FR-1.3:** The Dashboard must provide an interactive horizontal scroll strip of habits with 1-tap circular completion toggles and spring physics.
- **FR-1.4:** The Dashboard must surface up to 3 top pending tasks with inline completion toggles.
- **FR-1.5:** The Dashboard must display a gear icon in the navigation bar opening `SettingsSheet`.

### FR-2: Task Management Engine
- **FR-2.1:** Users must be able to create tasks with a title, optional multi-line notes, due date & time, priority (`High`, `Medium`, `Low`), and optional due-date reminder toggle.
- **FR-2.2:** Tasks must be organized into collapsible or distinct sections: **Pending (count)** and **Completed (count)**.
- **FR-2.3:** Tasks must support real-time case-insensitive keyword searching across titles and notes.
- **FR-2.4:** Tasks must support native swipe-to-delete with animated removal from SwiftData storage.
- **FR-2.5:** Tapping a task checkbox must toggle completion with strikethrough animation and cancel any pending notification.

### FR-3: Habit & Consistency Engine
- **FR-3.1:** Users must be able to create daily habits selecting a title, an SF Symbol from a 12-icon curated grid, and a theme color from a 7-color iOS palette (`blue`, `green`, `purple`, `orange`, `pink`, `teal`, `indigo`).
- **FR-3.2:** Habits must calculate streaks accurately using day-boundary calendar arithmetic:
  - If completed today $\rightarrow$ streak includes today.
  - If not completed today but completed yesterday $\rightarrow$ streak remains active as of yesterday.
  - If yesterday was missed $\rightarrow$ streak resets to 0.
  - Multiple check-ins on the same calendar day normalize to a single completion.
- **FR-3.3:** The Habits tab must feature a top progress card showing total habits completed today with celebratory motivational copy.

### FR-4: Daily Mindfulness & Mood Journal
- **FR-4.1:** Users must be able to log daily reflections selecting from 5 predefined mood states (`Great` 😄, `Good` 🙂, `Neutral` 😐, `Down` 😔, `Stressed` 😣).
- **FR-4.2:** Users must be able to toggle multiple feeling tags (`Grateful`, `Productive`, `Relaxed`, `Energetic`, `Busy`, `Tired`, `Anxious`, `Inspired`).
- **FR-4.3:** The journaling view must provide an auto-expanding multi-line text input field (`TextField(axis: .vertical)`).
- **FR-4.4:** The Journal tab must present a chronological timeline sorted newest first, showing mood pills, feeling chips, and notes excerpts.

### FR-5: Local Notification & Reminders
- **FR-5.1:** The app must request native system notification authorization (`.alert`, `.sound`, `.badge`) through `NotificationManager`.
- **FR-5.2:** Tasks with reminders enabled must schedule a `UNCalendarNotificationTrigger` matching the exact due date.
- **FR-5.3:** Users must be able to configure a daily evening recurring notification with a native time picker stored via `@AppStorage`.
- **FR-5.4:** Completing or deleting a task must immediately remove its pending notification request (`removePendingNotificationRequests`).

### FR-6: On-Device AI & Lifestyle Insights
- **FR-6.1:** The app must evaluate reflection text using Apple's native `NaturalLanguage` framework (`NLTagger(tagSchemes: [.sentimentScore])`), outputting a continuous floating-point score between -1.0 and +1.0.
- **FR-6.2:** The app must compute empirical conditional probabilities correlating completed habits with days where mood was logged as `Great` or `Good`.
- **FR-6.3:** The Dashboard must present an AI Insights card with a gradient border, highlighting top sentiment scores, streak milestones, or task completion rates.
- **FR-6.4:** An `InsightsDetailSheet` must display an average sentiment score gauge, mood correlation rankings, and privacy disclosures.

### FR-7: Data Backup & Portability
- **FR-7.1:** The app must serialize all tasks, habits, and reflections into an ISO8601-formatted JSON backup file.
- **FR-7.2:** The app must offer native sharing via `ShareLink` for AirDrop, Files, or Messages.
- **FR-7.3:** The app must import and restore backup files using `.fileImporter` with duplicate-safe UUID verification.

### FR-8: Home Screen Widgets (`WidgetKit`)
- **FR-8.1:** The app must provide glanceable Home Screen widgets supporting `.systemSmall` and `.systemMedium` families.
- **FR-8.2:** Widgets must display dynamic hourly greeting text, daily momentum percentage, and top active habit streaks.

---

## 4. Non-Functional Requirements (NFR)

| NFR ID | Category | Requirement Description |
| :--- | :--- | :--- |
| **NFR-01** | **Performance** | UI animations must maintain 60 FPS (120 FPS on ProMotion devices). Local queries must execute in $< 15\text{ ms}$. |
| **NFR-02** | **Privacy & Security** | Zero network egress. 100% of data is stored in the app's local sandbox container. No third-party analytics. |
| **NFR-03** | **Offline Capability** | 100% of functionality (tasks, habits, journal, notifications, AI analysis) must operate without an active Internet connection. |
| **NFR-04** | **Accessibility** | All controls must support Dynamic Type scaling, VoiceOver labels, high-contrast modes, and standard Apple hit targets ($44 \times 44\text{ pt}$). |
| **NFR-05** | **Reliability** | SwiftData persistence must handle app termination and relaunch without state loss or data corruption. |
| **NFR-06** | **Apple HIG Compliance** | Strict adherence to iOS navigation paradigms (bottom `TabView`, native `NavigationStack`, sheet presentations, SF Symbols). |
