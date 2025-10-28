//  GITIssueTracker_DeveloperNotes.swift
//  GIT IssueTracker LIGHT
//
//  Human‑readable developer notes for this project. Keep this file in source control.
//  When you (or ChatGPT/Claude) say: "add to developer notes", append the note under the
//  "Developer Notes Log" section below.
//
//  This file is intentionally mostly comments so it does not affect the build.
//

/*
====================================================
GIT IssueTracker LIGHT — Developer Notes
====================================================

Purpose
- Single place to capture decisions, TODOs, and workflow tips.
- Append new entries at the bottom in the "Developer Notes Log" section with a timestamp.
- Serves as PERSISTENT MEMORY & VIRTUAL SWAP FILE across AI chat sessions.

How to use this file
- When you want to record something, add a new entry under "Developer Notes Log" like:
  [YYYY-MMM-DD HHMM] (author) Short description of the decision, idea, or TODO.
- Keep entries concise. If longer, add a sub‑bullet list.
- Example: "[2025 SEP 26 1300] (MLF) GitHub Actions removed - repository now for sync only."

Rules & Guidance for ChatGPT/Claude (Persistent Memory)
- When the user says "check the developer notes" or "add to developer notes", they mean THIS file.
- Do NOT write logs to any runtime-accessible file. Only append comments inside this file.
- Do NOT wire this file into the app at runtime (do not import/read/parse it from app code).
- Append new entries under the section "Developer Notes Log" using this format:
  [YYYY MMM DD HHMM] (AUTHOR) Message. Assistant uses MLF when writing on behalf of the user; the user may sign as MLF. Use Claude for Claude entries; use ChatGPT for ChatGPT entries.
- Newest entries go at the TOP of the Project Status section; the Developer Notes Log can be chronological or reverse — keep newest at the top for quick scanning when requested.
- For multi-line notes, use simple "-" bullets. Avoid images and tables.
- If a note implies code changes, treat that as a separate, explicit task; do not change code unless requested.
- Assistant recap formatting: Keep recaps for instructions and steps within a single paragraph.
- Step numbering format: When batching steps, number them as 1) 2) 3) with a close parenthesis.
- CRITICAL WORKFLOW RULES:
- AI ASSISTANTS DO ALL HEAVY LIFTING: AI does 100% of coding, file creation, problem-solving, and technical work.
- USER DOES MINIMAL ACTIONS ONLY: User only performs actions that AI assistants are physically prohibited from doing in Xcode.
- STEP-BY-STEP SCREENSHOT METHODOLOGY:
  * AI gives THREE specific, minimal instruction (e.g., "Click the + button", "Select this menu item")
  * User performs ONLY that single action
  * User takes screenshot showing the result
  * User uploads screenshot to AI
  * AI MUST PAUSE and wait for screenshot before giving next instruction
  * This creates a calm, methodical, stress-free workflow
- USER PREFERS XCODE-ONLY WORKFLOW: No terminal commands ever.
- FOCUS ON BUGS/ERRORS ONLY: Enhancements and new features go in notes only, not implemented unless fixing a bug.

- Commit message style: short, imperative, informative (e.g., "Fix entry save bug").
- When asked to "summarize developer notes", summarize ONLY content from this file; do not invent or reference external logs.
- When asked to "clear notes" or remove entries, confirm explicitly before deleting or truncating any log content.
- Treat this file as the single source of truth for decisions, conventions, and project-wide guidance.
- Only ChatGPT and Claude will read and work from this file. Treat it as the collaboration ledger for this project.
- Maintain a running section titled "Project Status & Chat Summary" in this file; after each working session, append a brief summary with timestamp, current context, key changes, and next steps.
- This file serves as continuity between chat sessions since AI assistants don't remember previous conversations.

GitHub & Repository Policy
- GitHub serves ONLY as backup and sync service between multiple development machines
- NO automated builds, testing, or CI/CD pipelines
- NO GitHub Actions workflows
- Repository is purely for: push from Machine A → pull on Machine B
- Keep repository clean and simple for code sync only

====================================================
Project Status & Chat Summary
====================================================

- [2025 OCT 27 2100] (MLF/Claude) MAJOR REFACTOR COMPLETE: Normalized entire codebase from 1000+ line ContentView into feature-based folders. Created both macOS and iOS versions in separate ZIP archives. Removed Wiki (saved for PRO). Implemented full GitHub Discussions GraphQL API, complete GitHub Stats API with SwiftUI Charts visualizations, proper debug panel integration with ladybug toggle and ⌘D shortcut, and sandbox-compliant design. All placeholder code replaced with working implementations. Removed "Open on GitHub" button (sandbox compliance). Fixed GitHubService initialization bug. Total 26 files per platform organized as: Core (Services, Settings), Features (Comments, Debug, Discussion, Issues, Main, Repositories, Stats), App (entry point, dev notes).

- [2025 OCT 27 1205] (MLF/Claude) BUILD SUCCESS: Fixed WikiViewB argument errors by adding @State wikiModel = WikiModel() to ContentView, changing WikiViewB call parameters, and updating wikiModel.repositories. All build errors resolved.

- [2025 OCT 26 1532] (MLF/Claude) BUILD SUCCESS: Fixed "Cannot find ViewName in scope" errors by adding missing Swift files to macOS build target.

- [2025 OCT 26 1400] (MLF/Claude) MISSING FILE RULE ADDED: If AI cannot find a Swift file that code is trying to reference, AI must PAUSE and ask human before proceeding.

- [2025 OCT 26 1350] (MLF/Claude) PLATFORM TARGETING RULE ADDED: When AI sees platform-specific naming, must PAUSE and ask human to clarify platform before making suggestions.

- [2025 SEP 28 1140] (MLF/Claude) WORKFLOW VIOLATION: Claude created numbered duplicates despite new rule. REINFORCED RULE: Always use str_replace to replace entire file contents.

- [2025 SEP 28 1135] (MLF/Claude) CRITICAL WORKFLOW RULE ADDED: AI assistants CANNOT delete files in Xcode - only replace content. Use str_replace or pause and prompt user to delete manually.

- [2025 SEP 28 0931] (MLF) New timestamp format requirement: Use "2025 SEP 28 0931" format.

- [2025-09-27 11:12] (MLF) Communication preference: TL;DR concise (1–2 short paragraphs), single‑action step‑by‑step with pauses for screenshots.

- [2025-09-26 19:20] (MLF) Policy: GitHub is sync-only. No bells & whistles.

// Add new notes above this line. Keep newest entries at the top for quick scanning.
*/

