# Udyami Kutumba App — New Features Implementation Plan (v2)

**Prepared:** 11 September 2026 — updated same day after a second pass through the codebase, focused on the AI Leads screen design and re-checking the sector rollout and notification counts.
**Scope:** Leads (Own + AI), Notifications overhaul, Family/Profile matching, Primary–Secondary address switching, API optimization, Sector sub-sub-sector rollout

This plan is based on a direct review of the current codebase (`D:\DigiNik\Apps\udyamikutumba`) — every count below (screens, endpoints, hardcoded items) was checked against the actual files, not estimated. Two ticket references were mentioned — `963fb9ce-2cc8-41d7-b60e-d4293954e509` (notifications, backend) and `ead85da9-1d41-430e-9b71-13b98364c6b5` (API optimization). Neither ID, nor any chat/ticket export containing them, exists anywhere in the local project folder (checked `.scratch`, `scratch`, `payloads`, and the full `lib/` tree), so the numbers below are built entirely from what the code itself shows today. If either ticket contains scope not visible in the app, share it and the numbers can be adjusted.

**Team assumption driving the calendar plans:** 2 Flutter developers working full-time in parallel, plus a backend developer handling the notification and family-linking APIs alongside (there is already a backend ticket for notifications). If the actual team is smaller or larger, every calendar duration scales roughly in inverse proportion.

---

## 1. What the codebase actually shows today

| Area | Current state |
|---|---|
| Leads — Own (My Leads) | Built and functional (`my_leads_screen.dart`, `LeadAPI` with 9 wired endpoints: create, list, status update, completed/converted, free/paid tiers, and a matched-leads endpoint — see AI Leads row below). Needs final polish, not a rebuild. |
| Leads — AI Leads | UI shell only (`ai_lead_gen_screen.dart`, verified in full): 2 hardcoded sample rows, no API call, "Scan for new matches" button does nothing. **Updated finding:** `LeadAPI` already has a wired `getMatchedLeads(userId)` method hitting `GET /bni-lead/matched/{userId}` — a real backend matching endpoint exists today. The AI Leads screen simply isn't calling it yet. This removes the biggest risk from this item (previously this plan assumed the matching backend didn't exist yet); what's left is genuinely a frontend wiring + UX task, not a backend dependency. See Section 1a for the screen-design question you raised. |
| Leads — B2B / B2C / Social Channel / Communication / UBN management | Filtering by lead type already exists inside `lead_management_screen.dart`. But the five dedicated per-source **management** screens (`b2b_management_screen.dart`, `b2c_management_screen.dart`, `manual_management_screen.dart`, `social_media_management_screen.dart`, `ucn_management_screen.dart`) are confirmed empty — 2 bytes each, nothing built. |
| Notifications | `notifications_screen.dart` (verified in full) is a static list of exactly **9 hardcoded example cards**. No notification API client anywhere in `lib/core/api`, no unread/read state, no per-module counters, no push wiring, and the backend's own `swagger.json` has zero notification-tagged endpoints today. This is a from-scratch build on both frontend and backend. See Section 3 for the full breakdown of what "50+ notifications" means here. |
| Sector selection | `SectorAPI` (verified in full, 13 methods) already supports the new 3-level flow — `getAllSubSubSectors(subSectorId)` and `createOther` for custom entries exist server-side. **Updated finding:** one screen has already been fully converted — `passleadscreen.dart` ("Pass a Lead") wires Sector → Sub-Sector → **Sub-Sub-Sector** end to end, including a working "create all 3 levels" dialog. This is exactly the reference pattern the rollout below copies. Confirmed by grep across `lib/`: **7 screens still call `SectorAPI()` with only the 2-level flow** — `signup_screen.dart`, `profile_screen.dart`, `create_sector_request_screen.dart`, `my_sector_requests_screen.dart`, `sector_team_screen.dart`, `sector_join_review_screen.dart`, `sector_dashboard_screen.dart`. `ProfileDataModel` also has no `businessSubSubCategory`-equivalent field yet, so the profile model needs a small schema addition alongside the UI change. |
| Profile / family matching | `ProfileDataModel` (verified in full) already stores `spouse` as a plain free-text field (no phone number, no link to another account), plus `children`, `familyCount`, `homeAddress`/`officeAddress` and separate lat/long for home (business coordinates live nested inside `BusinessDetailsModel`). There is no linked-account model at all — no invite mechanism, no bidirectional account linking, no "tap spouse's card to see their business" flow, confirmed by searching `profile_screen.dart` for any linking/invite logic (none found). This is a new feature end to end, needing both a data model and backend invite/link endpoints that don't exist yet. |
| Primary/secondary address | The underlying data (home address + coordinates, business/office address + coordinates) already exists on the profile model, just not unified under one flag. What's missing is an explicit "which one is my default public address" field, the toggle UI, and the display logic that picks which one is shown by default when someone views a profile — plus the explicit rule that geofencing/Member Map stays on business location regardless of that toggle. |
| API optimization | Debug-print scripts in the project root (`print_geo_all.js`, `print_roles.js`, `print_search.js`, `print_selects.js`, `print_check_profile.js`, `print_nearby2.js`, `print_load_map.js`, `print_loc2.js`, `print_tabs.js`, `print_web_map.js`, `print_area_filters.js` — 11 files) have patched 11 screens with console logging to trace slow calls. This is early diagnostic instrumentation, not an optimization pass — no caching, pagination, de-duplication, or payload trimming has been done yet. `lib/core/api` has **28 API client files** (recounted directly from the folder tree). Backend surface, from `swagger.json`, is **274 documented endpoints across 42 modules** — confirmed by parsing the file directly (269 paths, 274 operations, 42 tags). No `Notification` module exists in that backend spec at all yet. The app currently wires roughly 125–130 of the 274, so it calls under half of what the backend already exposes — and that gap will keep widening as these six features add their own new endpoints. |

### 1a. AI Leads — consolidated screen or spread across each lead-type screen?

You asked specifically about this, so here's a direct recommendation rather than leaving it open:

**Build AI Leads as one consolidated screen** (keep `ai_lead_gen_screen.dart` as that single home, don't duplicate "AI suggested" sections inside each of the 5 lead-management screens). Reasons this is both the better product decision and the cheaper build:

- The backend endpoint that exists today (`GET /bni-lead/matched/{userId}`) returns matches without a "which of the 5 lead sources is this" split baked in by design — it's naturally a single ranked feed, not five separate ones.
- The screen already has the right shape for this: each row has a colored source badge (teal/orange in the current mock) — that badge just needs to reflect the real source (UBN / B2B / B2C / Social Channel / Communication) once real data flows in, rather than being invented per-screen five times over.
- One "Accept" action, reusing the category auto-fill logic already built in `passleadscreen.dart` (it matches a selected member's business category → sector → sub-sector → tag automatically), converts a suggested match into a real lead in the correct bucket. That's one integration to build, not five.
- Building this into each of the 5 management screens instead would mean five separate "suggested for you" sections, five sets of accept/reject logic, and no single place to see everything AI has surfaced — worse for the user and roughly 4–5x the frontend work for no functional gain.

Practical build list for this screen once you proceed: call `getMatchedLeads(userId)` on load and on "Scan for new matches"; render each match with its real source badge; "Accept" opens the existing lead-creation flow pre-filled (same pattern as `passleadscreen.dart`'s auto-fill); "Pass/Reject" needs a dismiss action — there's no dedicated dismiss endpoint yet, so either reuse `updateLeadStatus` with a new status value (cheapest, needs backend to accept it) or add a small new endpoint. This item stays in the **4–6 person-day (AI-assisted)** range from the table below — the backend risk is now lower (the endpoint exists), but the frontend integration, empty/error states, and the accept/dismiss flow are still real work.

---

## 2. Does using Claude/Gemini-style AI coding assistants change the numbers?

Short answer: **it compresses the pure coding effort, but not the calendar floor.**

AI pair-coding genuinely speeds up the mechanical, pattern-heavy parts of this work — generating five near-identical CRUD management screens from the pattern `lead_management_screen.dart` already sets, wiring a new API client method per existing conventions, refactoring 28 files to remove debug prints and add caching, rolling the same sub-sub-sector dropdown out to the 7 screens identified above using `passleadscreen.dart` as the working template. Those items realistically compress by 25–35%.

It does **not** compress:
- **Play Store internal/closed testing** — Google's review queue plus a minimum real-tester soak period is elapsed calendar time, unrelated to how fast the code was written.
- **Backend API delivery** for notifications and family-linking — a second team's schedule, not this one's.
- **Family/spouse account linking UX** — invite flows, bidirectional linking, and "whose business shows on whose card" edge cases need human product judgement and real-device testing, not just code generation.
- **Cross-module notification testing** — each of the ~61 trigger types still needs to be triggered and verified on a device once wired, regardless of how quickly the wiring code itself was generated.

| | Without AI assistance (person-days) | With AI-assisted coding (person-days) |
|---|---|---|
| Total core engineering effort (8 build items) | 78–113 | **58–82** |
| Play Store elapsed/waiting time (not compressible) | 6–10 | 6–10 |
| **Grand total** | **84–123** | **64–92** |

This is the honest range the three plans below are built from. AI-assisted coding buys back real time on the build items, but the calendar floor is still set by testing cycles, backend dependencies, and human review — which is why the 45-day plan below is tight even with AI assistance, not slack.

---

## 3. Notifications — the specific question answered

**Current state:** 9 hardcoded cards, no backend, no per-module logic, no counts, no read/unread state.

**What "all possible places" actually means once mapped against this codebase** — every module that can plausibly need a notification, from the screens and API tags that exist today:

| # | Module | Trigger types | Count |
|---|---|---|---|
| 1 | Feed / Posts | new comment, new like, new follower, new post from someone you follow, post shared | 5 |
| 2 | Directory / Networking | connection request received, connection accepted, your profile/digital card viewed | 3 |
| 3 | Roles & Circles (Ward/Circle/Assembly/Coordinator) | **assigned to a role**, role assignment confirmed by admin, **role changed/removed** — kept as a distinct trigger from assignment, since a member who is *not* removed should keep receiving role-scoped notifications | 3 |
| 4 | Leads (Own/B2B/B2C/Social/UCN + AI) | lead assigned to you, lead status changed, lead appeal submitted/responded, lead converted, gratitude pending for a completed lead, AI-suggested match found | 6 |
| 5 | Meetings & Face-to-Face | meeting scheduled, meeting reminder, meeting rescheduled, meeting cancelled, F2F request received, F2F confirmed, attendance/QR check-in confirmed | 7 |
| 6 | Sector join requests | request submitted, endorsed, approved, rejected, new business tag created | 5 |
| 7 | Gratitude | gratitude slip received, gratitude milestone reached | 2 |
| 8 | Hall booking & Guests | booking confirmed/rejected, guest invited, guest RSVP received, guest checked in | 4 |
| 9 | Membership, wallet & campaigns | membership renewal due, payment received/failed, wallet coins low/recharged, campaign delivered, campaign failed, wallet/financial summary ready | 6 |
| 10 | Jobs & applications | new matching job posted, application received (poster side), application status changed (applicant side), job post approved/rejected | 4 |
| 11 | Requirements (B2B/B2C matching) | new requirement matches your business, requirement response received | 2 |
| 12 | UQueens, training & programmes | event registration open, training reminder, programme certificate/milestone ready | 3 |
| 13 | Ward/Assembly/leaderboards | ward rank changed, new member joined your ward, scorecard updated, points milestone reached | 4 |
| 14 | News & announcements | new news/announcement relevant to your ward/sector | 1 |
| 15 | Onboarding / profile | profile approved/verified, missing-field reminder, family member linked (once profile-matching ships) | 3 |
| 16 | Surveys, referrals & system messages | survey available, referral bonus earned, important SMS/email delivered as in-app notice | 3 |
| | **Total** | | **≈ 61** |

So "50+" was, if anything, conservative — a full sweep of every module in this app lands closer to **~60 distinct trigger types**, not 20. That is roughly three times the size of a typical 15–20 notification build, which is the real driver of the time below (no comparison to any other specific past project is implied — this is sized directly off this app's own module count).

**Time required**, broken into its three genuinely different components:

- **Core notification system** (live feed, unread/read state, per-module badge counts, settings, deep-link routing into the right screen, push registration): **8–11 days** with AI-assisted scaffolding of the repeated list/badge/settings UI.
- **Wiring all ~60 trigger types** across the 16 modules above (each needs a backend event or client-side trigger, a card template, a deep link, and on-device verification): **14–20 days**. AI assistance speeds up writing the repetitive per-type code, but each type still needs to be fired and checked on a device, which is where most of this time actually goes.
- **Play Store internal/closed testing track** (review queue + minimum real-tester soak period before it can go to production): **6–10 days elapsed**, essentially independent of trigger count or coding speed — this is Google's clock, not the dev team's.

**Total for notifications alone: roughly 28–41 days**, of which 6–10 days is elapsed waiting time that can run in parallel with other work rather than sitting on the critical path alone.

---

## 4. Three plans

### Plan 1 — Actual days needed (no calendar compression, AI-assisted pace)

This is the honest total engineering effort for all six feature areas, from Section 2's AI-assisted column, if it were done as pure sequential effort with no parallelization:

| Feature | Min days | Max days |
|---|---|---|
| Leads — Own: polish, edge cases, empty/error states | 1 | 2 |
| Leads — AI Leads: consolidated screen wired to the real matched-leads endpoint, accept/reject/pass | 4 | 6 |
| Leads — 5 management screens (B2B, B2C, Social, Communication, UCN) | 12 | 17 |
| Notifications — core system + ~60 trigger types (Section 3) | 22 | 31 |
| Notifications — Play Store testing cycle (elapsed) | 6 | 10 |
| Profile matching — family/spouse linked accounts, invite, tap-through | 8 | 12 |
| Primary/secondary address toggle + display logic | 3 | 4 |
| API optimization pass across ~125–130 wired endpoints / 28 files | 8 | 13 |
| Sector sub-sub-sector rollout to the 7 confirmed remaining screens (using `passleadscreen.dart` as the template) | 4 | 6 |
| **Total (person-days, AI-assisted)** | **68** | **101** |

With 2 developers running independent tracks in parallel (plus backend on its own ticket), this compresses to roughly **40–55 calendar days** before QA and release — which is exactly why the 45-day plan below is tight rather than padded, and why 60 days is the safer number if anything slips.

### Plan 2 — 45 calendar days (target finish ~25 October 2026)

Tight scope: both developers fully dedicated, backend delivers notification + family-link APIs on schedule, Play Store beta cycle overlapped with the final QA week.

| Phase | Days | Deliverables |
|---|---|---|
| Phase 1 | 1–9 | Sector sub-sub-sector rollout (7 remaining screens, copying the `passleadscreen.dart` pattern); primary/secondary address toggle + display logic; backend proceeds on notification + family-link APIs in parallel |
| Phase 2 | 7–20 | Leads: Own finalized, AI Leads consolidated screen wired to `getMatchedLeads`; Notifications core system built and the highest-priority ~30 of the ~60 trigger types wired |
| Phase 3 | 18–32 | Leads: all 5 management screens built; Profile family/spouse matching built (invite, link, tap-through) |
| Phase 4 | 30–39 | Remaining notification types wired to reach the full ~60; API optimization pass |
| Phase 5 | 38–45 | Full regression QA, Play Store closed-testing submission and monitoring, bug-fixing, release |

### Plan 3 — 11 September to 10 October (30-day window, the client's requested date)

This window is shorter than the 45-day plan above, so full scope will not be complete by 10 October with a 2-developer (+1 backend) team, even with AI-assisted coding. Realistically achievable by that date:

| Status by 10 Oct | Item |
|---|---|
| Done | Sector sub-sub-sector rollout across all 7 remaining screens |
| Done | Primary/secondary profile address switching |
| Done | Leads — Own (My Leads) finalized |
| Done | Leads — AI Leads consolidated screen live, wired to the real `getMatchedLeads` endpoint |
| Done | Notifications core system live (feed, read/unread, badges, deep links) plus roughly the top 20–25 of the ~60 trigger types |
| Partial | Leads management screens — realistically 2 of 5 built (e.g. B2B and B2C); Social Channel, Communication, and UCN carry over |
| Partial | Profile family matching — invite + linking flow likely built; multi-family-member support and full tap-through polish likely carries over |
| Not started / carried over | Remaining ~35–40 notification trigger types, full API optimization pass, Play Store closed-testing submission |

In short: 30 days covers the two smaller, self-contained items (sector rollout, address switching) plus the leads baseline and a working — but partially populated — notifications system. The heavier items (all 5 lead-management screens, the full ~60-notification catalogue, family matching at full scope, and the API optimization pass) need the additional 15–25 days captured in Plan 2.

---

## 5. Dependencies and risks worth flagging to the client

Notifications and the family-invite feature both need backend endpoints that don't exist yet — every plan above assumes the backend developer delivers these in parallel and on schedule; any slip there pushes the corresponding frontend milestones directly. AI Leads is lower-risk than it looked at first pass: the backend matching endpoint (`GET /bni-lead/matched/{userId}`) already exists and is wired into the Flutter API client, so that item no longer depends on a not-yet-built backend feature — the remaining work is the consolidated screen, the accept/dismiss flow, and (if "dismiss" needs its own status) a small backend addition. The Play Store closed/internal testing track carries elapsed time outside the team's control (Google's review queue, plus a minimum soak period with real testers) — this is squeezed into the last week in Plan 2, which is the tightest point in that timeline. Finally, the 274-endpoint backend surface (42 modules) against ~125–130 currently wired means the app's API surface keeps growing as these six features land — the optimization pass above is scoped against today's ~130, not the full 274, so a second optimization pass should be expected once the new endpoints (leads management, notifications, family-linking) go live.
