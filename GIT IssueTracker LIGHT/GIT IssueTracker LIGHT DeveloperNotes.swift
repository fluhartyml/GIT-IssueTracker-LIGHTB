//2025 OCT 26 Blank Developer Notes

//2025 SEP 28 DeveloperNotes Clean
/* AiPlease find and replace  [project name placeholder] with the current xcode project we are working on (remove this line after successful completion) */
//  DeveloperNotes.swift
//  [project name placeholder]
//
//  Human‑readable developer notes for this project. Keep this file in source control.
//  When you (or ChatGPT) say: "add to developer notes", append the note under the
//  "Developer Notes Log" section below.
//
//  This file is intentionally mostly comments so it does not affect the build.
//


/*
====================================================
[project name placeholder] — Developer Notes
====================================================

Purpose
- Single place to capture decisions, TODOs, and workflow tips.
- Append new entries at the bottom in the "Developer Notes Log" section with a timestamp.
- Serves as PERSISTENT MEMORY & VIRTUAL SWAP FILE across AI chat sessions.

How to use this file
- When you want to record something, add a new entry under "Developer Notes Log" like:
  [YYYY-MMM-DD HHMM] (author) Short description of the decision, idea, or TODO.
- Keep entries concise. If longer, add a sub‑bullet list.
- Example: "[2025 SEP 26 1300] (MF) GitHub Actions removed - repository now for sync only."

Rules & Guidance for ChatGPT/Claude (Persistent Memory)
- When the user says "check the developer notes" or "add to developer notes", they mean THIS file: ProjectName_DeveloperNotes.swift.
- Do NOT write logs to any runtime-accessible file. Only append comments inside this file.
- Do NOT wire this file into the app at runtime (do not import/read/parse it from app code).
- Append new entries under the section "Developer Notes Log" using this format:
  [YYYY MMM DD HHMM] (AUTHOR) Message. Assistant uses MF when writing on behalf of the user; the user may sign as MLF. Use Claude for Claude entries; use ChatGPT for ChatGPT entries.
- Newest entries go at the TOP of the Project Status section; the Developer Notes Log can be chronological or reverse — keep newest at the top for quick scanning when requested.
- For multi-line notes, use simple "-" bullets. Avoid images and tables.
- If a note implies code changes, treat that as a separate, explicit task; do not change code unless requested.
- Assistant recap formatting: Keep recaps for instructions and steps within a single paragraph.
- Step numbering format: When batching steps, number them as 1) 2) 3) with a close parenthesis.
- If a note implies code changes, treat that as a separate, explicit task; do not change code unless requested.
- Assistant recap formatting: Keep recaps for instructions and steps within a single paragraph.
- If a note implies code changes, treat that as a separate, explicit task; do not change code unless requested.
- Assistant recap formatting: Keep recaps for instructions and steps within a single paragraph.
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
 - [2025 SEP 28 0931] (MLF) New timestamp format requirement: Use "2025 SEP 28 0931" format. Log tasks before conducting them to maintain crash recovery continuity.
   
- [2025-09-27 11:12] (MF) Communication preference reaffirmed: keep responses TL;DR concise (1–2 short paragraphs), use single‑action step‑by‑step with pauses for screenshots, avoid verbosity.
 - [2025-09-27 09:40] (MF) Preference: Keep assistant responses to one or two short paragraphs; I will ask for more detail if needed (TL;DR style).
 - [2025-09-27 09:18] (ChatGPT) Policy added: Number batched steps as 1) 2) 3) with a close parenthesis; continue single-paragraph recaps.
- [2025-09-27 09:00] (ChatGPT) Policy added: Keep all recaps of instructions and steps within a single paragraph; developer notes remain private and excluded from the app build.
 - [2025-09-26 19:50] (MF) Policy reaffirmed: Focus on bug/error fixes only; track enhancements in notes until app is running; implement before release.
 - [2025-09-26 19:40] (MF) PII policy: Keep personal name out of source/UI; assistant uses MF, I sign as MLF.
- [2025-09-26 19:20] (MF) Policy: GitHub is sync-only (staging/commit/pull/push via Xcode). No bells & whistles.
  - No GitHub Actions, workflows, badges, issue/PR templates, bots, webhooks, Pages, or CI services.
  - No third-party CI/CD or automation; no release pipelines.
  - Do not add code or dependencies solely to support GitHub features.
  - README stays minimal (no shields). Repository metadata optional.
  - Xcode-only workflow: use Source Control UI; no terminal.
  - Any future automation requires explicit approval in Developer Notes.
- [2025-09-26 19:10] (MF) GitHub setup parameters for this project (sync-only, Xcode-only workflow):
  - Visibility: public GitHub repository.
  - Purpose: Sync between machines only (no CI/CD, no GitHub Actions, no automated builds/tests).
  - Default branch: main.
  - Remote name: origin.
  - Auth: Xcode > Settings > Accounts with GitHub Personal Access Token (scope: repo). No terminal usage.
  - Workflow: Use Xcode Source Control for commit, pull, push. Avoid force-push.
  - Branching: Single main branch; short-lived feature branches optional; delete after merge.
  - Merge strategy: Xcode default merge; avoid rebase unless necessary.
  - .gitignore guidance: ignore .DS_Store, xcuserdata/, *.xcuserdatad, *.xcscmblueprint, .swiftpm/, .build/, Packages/; never commit DerivedData or user-specific files.
  - LFS: Not used.
  - Binary size: Keep committed files < 100 MB; avoid committing generated artifacts.
  - Issues/PRs: Optional; repo is for sync only.
  - Commit messages: short, imperative, informative (e.g., "Fix entry save bug").
  - Conflict resolution: Use Xcode's merge tool; build/tests should pass before pushing.
- [2025-09-26 18:58] (MF) Milestone: Persistent memory working across new chat sessions; assistant recognized context without retraining.
- [2025-09-26 18:50] (MF) Author tag convention: assistant uses (MF); I may write my full name in content as desired.
 - [2025-09-26 14:00] (Claude) Added critical workflow rules: AI does all coding/heavy lifting, user does minimal Xcode actions only, screenshot methodology.
- [2025-09-26 13:55] (Claude) Created developer notes file and established persistent memory system for project.
 
// Add new notes above this line. Keep newest entries at the top for quick scanning.
*/




/*
====================================================
Developer Notes Log
====================================================
- [2025 OCT 27 1205] (MLF/Claude) BUILD SUCCESS: Fixed WikiViewB argument errors by 1) adding @State wikiModel = WikiModel() to ContentView, 2) changing WikiViewB call from incorrect parameters (repositories:selectedRepository:) to correct parameters (viewModel:selectedRepo:), and 3) updating wikiModel.repositories when data is fetched with GitHub credentials. All build errors resolved.
- [2025 OCT 26 1532] (MLF/Claude) BUILD SUCCESS: Fixed "Cannot find ViewName in scope" errors by adding missing Swift files to macOS build target. Issue was files existed on disk with correct target membership but weren't included in Compile Sources build phase. Added AllIssuesView, IssueNavigatorView, RepositoryListView, WikiView, DebugPanel, RepositoryDetailView, IssueDetailView and others to build target. App now builds and runs successfully on macOS.
- [2025 OCT 26 1400] (MLF/Claude) MISSING FILE RULE ADDED: If AI cannot find a Swift file that code is trying to reference (build errors like "Cannot find 'ViewName' in scope"), AI must PAUSE and consult human before proceeding with ANY actions. Do not assume files exist, do not try to create files, do not make suggestions - STOP and ask human what should be done.
- [2025 OCT 26 1350] (MLF/Claude) PLATFORM TARGETING RULE ADDED: When AI sees platform-specific naming like ContentView[macOS].swift or ContentView[iOS].swift, BUT the build target appears to be for a different platform (iPhone/iPad vs Mac), AI must PAUSE and ask human to clarify the intended platform before making ANY suggestions or changes. This prevents iOS/macOS confusion and improper code modifications.
- [2025 SEP 28 1140] (MLF/Claude) WORKFLOW VIOLATION: Claude created more numbered duplicates (file 2.swift) despite new rule. MLF correctly pointed out: should have used str_replace to completely replace existing file content (Cmd+A equivalent), not create new files. REINFORCED RULE: Always use str_replace to replace entire file contents when "cleaning" files.
- [2025 SEP 28 1135] (MLF/Claude) CRITICAL WORKFLOW RULE ADDED: AI assistants CANNOT delete files in Xcode - only replace content. When AI tries to "create" an existing file, Xcode generates numbered duplicates (ContentView 2.swift, etc.) causing ambiguous type errors. NEW RULE: AI must either 1) Only replace existing file content with str_replace, OR 2) Pause and prompt user to manually delete file in Xcode, take screenshot confirmation, then proceed with file creation.

 - [2025-09-27 11:12] (MF) TL;DR style policy: concise answers (one short paragraph unless more is requested), single‑action instructions with screenshot pauses, number batched steps as 1) 2) 3), avoid tables and long preambles.
- [2025-09-27 09:40] (MF) Preference: Keep assistant responses to one or two short paragraphs; I will ask for more detail if needed (TL;DR style).
- [2025-09-27 09:18] (ChatGPT) Policy added: Number batched steps as 1) 2) 3) with a close parenthesis; continue single-paragraph recaps.
- [2025-09-27 09:00] (ChatGPT) Policy added: Keep all recaps of instructions and steps within a single paragraph; developer notes remain private and excluded from the app build.
- [2025-09-27 08:21] (MF) Policy reaffirmed: Focus on bug/error fixes only; track enhancements in notes until app is running; implement before release.
- [2025-09-26 19:50] (MF) Policy reaffirmed: Focus on bug/error fixes only; track enhancements in notes until app is running; implement before release.
- [2025-09-26 19:40] (MF) GitHub push successful: main branch now tracking origin/main; repo intentionally public for transparency; personal name removed from source.
- [2025-09-26 19:40] (MF) PII policy: Keep personal name out of source/UI; assistant uses MF, I sign as MLF.
- [2025-09-26 19:20] (MF) Policy: GitHub is sync-only (staging/commit/pull/push via Xcode). No bells & whistles.
  - No GitHub Actions, workflows, badges, issue/PR templates, bots, webhooks, Pages, or CI services.
  - No third-party CI/CD or automation; no release pipelines.
  - Do not add code or dependencies solely to support GitHub features.
  - README stays minimal (no shields). Repository metadata optional.
  - Xcode-only workflow: use Source Control UI; no terminal.
  - Any future automation requires explicit approval in Developer Notes.
- [2025-09-26 19:10] (MF) GitHub setup parameters for this project (sync-only, Xcode-only workflow):
  - Visibility: Private GitHub repository.
  - Purpose: Sync between machines only (no CI/CD, no GitHub Actions, no automated builds/tests).
  - Default branch: main.
  - Remote name: origin.
  - Auth: Xcode > Settings > Accounts with GitHub Personal Access Token (scope: repo). No terminal usage.
  - Workflow: Use Xcode Source Control for commit, pull, push. Avoid force-push.
  - Branching: Single main branch; short-lived feature branches optional; delete after merge.
  - Merge strategy: Xcode default merge; avoid rebase unless necessary.
  - .gitignore guidance: ignore .DS_Store, xcuserdata/, *.xcuserdatad, *.xcscmblueprint, .swiftpm/, .build/, Packages/; never commit DerivedData or user-specific files.
  - LFS: Not used.
  - Binary size: Keep committed files < 100 MB; avoid committing generated artifacts.
  - Issues/PRs: Optional; repo is for sync only.
  - Commit messages: short, imperative, informative (e.g., "Fix entry save bug").
  - Conflict resolution: Use Xcode's merge tool; build/tests should pass before pushing.
- [2025-09-26 18:58] (MF) Milestone: Persistent memory working across new chat sessions; assistant recognized context without retraining.
- [2025-09-26 18:50] (MF) Author tag convention: assistant uses (MF); I may write my full name in content as desired.
- [2025-09-26 13:55] (Claude) Created developer notes file and established persistent memory system for project.

// Add new notes above this line. Keep newest entries at the top for quick scanning.
*/
