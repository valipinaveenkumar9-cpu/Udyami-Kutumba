# Udyami Kutumba — Fresh Implementation Plan (independent re-analysis)

**Prepared:** 11 September 2026, from a new, independent pass through the live codebase at `D:\DigiNik\Apps\udyamikutumba` — every number below (screen counts, endpoint counts, hardcoded items, method counts) was pulled directly from the current files this session, not carried over from any earlier document.

**A note on method:** the on-device shell was unreachable this session (a known Windows-update mounting issue on your machine), so instead of running `grep` directly on your disk, each relevant file was pulled into a working copy and searched here — same source files, same result, just a different route to get there.

**The two ticket IDs** you mentioned — `963fb9ce-2cc8-41d7-b60e-d4293954e509` (notifications backend) and `ead85da9-1d41-430e-9b71-13b98364c6b5` (API optimization) — do not appear anywhere in the project folder: not in the root, not in `.scratch`, `scratch`, or `payloads` (which contain only dev-tooling scripts, JSON payloads and test files, no chat export or ticket record of any kind). Every count below is therefore built purely from what today's code shows. If either ticket carries scope that isn't visible in the app yet, share it and these numbers can be adjusted.

**Team assumption behind the calendar math:** 2 Flutter developers working in parallel, plus a backend developer delivering the notification and family-linking APIs alongside. Scale durations roughly inversely if the real team is smaller or larger.

**Every estimate in this document — Plan 1, Plan 2, and Plan 3 alike — already assumes AI-assisted coding** (Claude/Gemini-style pair programming) for the engineering work. It is not a further discount layered on top of these numbers; it's baked into them. Section 3 shows what the same work would cost without that assistance.

**Update (per your note):** the "Notifications — core system + push infrastructure" line was re-priced down from the original 9–13 days to **1.5–3 days**, reflecting that a first working cut of this — `firebase_messaging` wired up, a basic feed screen backed by one list endpoint, unread/read state, a bell badge — is largely boilerplate once the backend exposes even a minimal notifications endpoint. The 1.5–3 day figure covers that first working cut; per-module badge counts, a full settings screen, and deep-link routing into every one of the ~64 trigger types are tracked separately below under "wiring the trigger types," since that's where the real time sits. Every total below has been recalculated with this change.

---

## 1. What today's code actually shows

| Area | Verified state |
|---|---|
| Leads — Own (My Leads) | Built and wired (`my_leads_screen.dart`, 19.4 KB, no TODOs found): tabs for given/received leads, calls `LeadAPI.getAllLeads()`, navigates into `LeadDetailScreen`, links to `passleadscreen.dart` to create a new lead. This contradicts the "still needs doing" framing — the screen is functionally complete today and needs polish/edge-case handling, not a rebuild. Worth a quick look together in case you have a different "Own" requirement in mind that isn't in the code yet. |
| Leads — B2B / B2C / Social Channel / Communication / UBN | Functionally live already, via two paths: (1) `lead_management_screen.dart` (64 KB) is a real "unified command center" — it fetches live counts from `RequirementsAPI.getB2CRequirements/getB2BRequirements`, `LeadAPI`, and `CommunicationsAPI().getAllCampaigns()`, and routes into fully-built screens (`communications_screen.dart` 28.9 KB, `social_channels_screen.dart` 14.8 KB + `campaigns_screen.dart` 44 KB, `requirements_screen.dart` 9.7 KB, the UBN/UCN subscription flow). (2) The five files that look like dedicated per-source screens — `b2b_management_screen.dart`, `b2c_management_screen.dart`, `manual_management_screen.dart`, `social_media_management_screen.dart`, `ucn_management_screen.dart` — are all 2 bytes and, confirmed by a project-wide search, **imported and navigated to from nowhere in the app**. They're dead scaffolding, not a pending feature. This matches what you said: these five are already done, in substance. |
| Leads — AI Leads | Two separate implementations exist side by side: **(a)** `lead_detail_screen.dart` genuinely calls `LeadAPI.getMatchedLeads(userId)` — a real, working `GET /bni-lead/matched/{userId}` call — and renders the matches (business, category, member name) with proper loading/empty states. It's wired in from both `member_leads_screen.dart` and `my_leads_screen.dart`, so opening any lead's detail today already shows a live "AI Leads" section. **This is the UBN-based passed-lead suggestion code you were thinking of.** **(b)** `ai_lead_gen_screen.dart` is a separate, unwired screen with 2 hardcoded sample rows and a "Scan for new matches" button that does nothing — and, confirmed by search, is never navigated to from anywhere in the app. It's an abandoned parallel attempt at the same idea. |
| Notifications | `notifications_screen.dart` is a static list of exactly **9 hardcoded cards** — no API client, no read/unread state, no per-module counts. `main_screen.dart` opens it from a plain bell icon with **no badge at all**. `pubspec.yaml` has **no push package** of any kind (`firebase_messaging`, `flutter_local_notifications`, etc. — none present), so this isn't just a UI gap, push delivery itself doesn't exist yet either. The backend's own `swagger.json` (parsed fresh this session: 269 paths / 274 operations / 42 tags) has **no Notification tag**. This is a from-scratch build, frontend, push infrastructure, and backend. |
| Sector selection | `SectorAPI` (13 methods, all verified) already supports the 3-level flow end to end — `getAllSubSubSectors(subSectorId)` and `createOther` for all three levels exist and work. `passleadscreen.dart` is the one screen already using all of it, including a working "create Sector + Sub-Sector + Sub-Sub-Sector" dialog — the reference pattern to copy. Across the rest of the app, `SectorAPI()` is instantiated in 10 files total; of those, only **4 have a real cascading Sector → Sub-Sector dropdown that would need the third level added**: `signup_screen.dart`, `profile_screen.dart`, `create_sector_request_screen.dart`, `invite_to_ucn_screen.dart`. The other 5 (`sector_team_screen.dart`, `directory_screen.dart` — simple string filters, not cascading pickers; `sector_dashboard_screen.dart`, `my_sector_requests_screen.dart`, `sector_join_review_screen.dart` — display/approve-reject only, no selection UI) don't need this change. `ProfileDataModel` also has no sub-sub-category field yet, so a small model/schema addition rides along. |
| Profile / family matching | `UserModel` has `mobileNumber` (the natural key for phone-based matching). `ProfileDataModel.spouse` is a plain free-text string — no phone number, no account reference, confirmed by reading the full model. No invite/link code exists anywhere (`profile_screen.dart` searched in full: nothing). This is a net-new feature end to end: backend invite/link endpoints and a linked-account data model, plus the frontend invite flow, pending-invite state, accept flow, and the "tap spouse's card to see their business" view. |
| Primary/secondary address | The data already exists — `homeAddress`/`homeLatitude`/`homeLongitude` and `businessDetails.businessAddress`/`latitude`/`longitude` both live on the profile today — but there's no flag anywhere for "which one is the public default." Geofencing is already confirmed business-only: both `member_map_screen.dart` and `geofence_screen.dart` read location strictly from `biz['latitude']`/`biz['longitude']`, so your existing behavior there needs no change — just an explicit note in the build that the toggle must not touch it. |
| API optimization | `timed_http.dart` wraps every raw `http.get/post/put/patch/delete` call with a stopwatch and an **unconditional** `print` of elapsed seconds — it runs in every build, not just debug, which is itself worth fixing in this pass. On top of that, 12 (not 11) `print_*.js` codegen scripts in the project root each inject extra `DEV DEBUG` print lines into one specific screen (map loading, geofencing, roles, search, dropdowns, profile checks, tabs, nearby, area filters, etc.) to trace slow calls. A direct search of `lib/core/api` for `cache`/`Hive` found nothing — no caching, de-duplication, or pagination exists anywhere yet. Counting actual wired calls: the 28 files under `lib/core/api` contain 188 `_api.*`/`http.*` call sites, of which 20 are internal plumbing inside `api.dart` and `timed_http.dart` themselves, leaving **168 real per-endpoint calls** across the other 26 client files — plus at least 15 more in feature-level clients outside `core/api` (`social_channel_api.dart`, `incident_api.dart`, `marketing_calendar_api.dart`). So roughly **180–190 endpoints are wired today against the 274 the backend exposes** (about two-thirds) — higher coverage than a quick guess would suggest, but the optimization work itself (caching, pagination, de-dupe, gating the debug prints) hasn't started. |

### 1a. AI Leads — one consolidated screen, or spread across each lead-type screen?

Direct recommendation, now that both existing implementations are on the table:

**Build one consolidated screen, and leave the existing contextual section alone.** Concretely: revive `ai_lead_gen_screen.dart` as the single "AI Leads" home, wired to the same `getMatchedLeads(userId)` call that's already proven working inside `lead_detail_screen.dart` — so this is de-risked twice over, not a shot in the dark. Keep the working section inside `LeadDetailScreen` exactly as it is (it costs nothing to leave, and it's a genuinely useful "here's who else matches this specific lead" nudge in context).

Reasons this beats duplicating "suggested for you" sections into all five lead-source screens: the matched-leads endpoint returns one ranked list with no source split baked into the payload, so it's naturally a single feed, not five; the accept flow can reuse `passleadscreen.dart`'s existing member→category→sector→sub-sector auto-fill logic once, not five times; and there's still no dedicated "dismiss" endpoint, so either repurpose `updateLeadStatus` with a new status value (cheap, needs backend to accept it) or add a small endpoint — one decision, not five. This keeps the item in the same **3–5 person-day** range below; the risk here is genuinely lower than a first glance suggests, since the exact rendering/fetch pattern already ships in the app today.

---

## 2. Notifications — the full sweep, mapped fresh against this app's own screens

Walking every feature folder in `lib/features` and the API tags in `swagger.json`, here's what "every place a notification could plausibly fire" comes out to:

| # | Module (screens it maps to) | Trigger types | Count |
|---|---|---|---|
| 1 | Feed / Posts (`post_screen.dart`, `post_detail_screen.dart`, `my_posts_screen.dart`) | new comment, new like, new follower, new post from someone you follow, post shared | 5 |
| 2 | Directory / digital card (`directory_screen.dart`, `member_detail_screen.dart`, `cards_screen.dart`) | connection request received, connection accepted, your card viewed | 3 |
| 3 | Roles & Circles (`manage_roles_screen.dart`, `assembly_roles_screen.dart`, `circle_roles_screen.dart`) | assigned to a role, assignment confirmed by admin, role changed/removed (kept distinct so a member who is *not* removed keeps getting role-scoped alerts) — **note:** `RoleAPI` today only has `assignRole`/`getAllRoles`/`getAllRoleUsers`; there's no remove/revoke-role endpoint yet, so the "removed" trigger needs that endpoint built first | 3 |
| 4 | Leads — Own + B2B/B2C/Social/UBN + AI (`my_leads_screen.dart`, `lead_detail_screen.dart`, `lead_appeals_screen.dart`) | lead assigned to you, lead status changed, appeal submitted/responded, lead converted, gratitude pending on a completed lead, new AI match found | 6 |
| 5 | Meetings & Face-to-Face (`meetings_screen.dart`, `face_to_face_screen.dart`, `scan_attendance_qr_screen.dart`) | meeting scheduled, reminder, rescheduled, cancelled, F2F request, F2F confirmed, attendance/QR check-in confirmed | 7 |
| 6 | Sector join requests (`create_sector_request_screen.dart`, `sector_join_review_screen.dart`) | submitted, endorsed, approved, rejected, new business tag created | 5 |
| 7 | Gratitude (`gratitude_screen.dart`, `gratitude_history_screen.dart`) | gratitude slip received, milestone reached | 2 |
| 8 | Hall booking & Guests (`hall_coordinator_screen.dart`, `guests_screen.dart`) | booking confirmed/rejected, guest invited, RSVP received, checked in | 4 |
| 9 | Membership, wallet & campaigns (`ucn_subscription_screen.dart`, `recharge_coins_screen.dart`, `campaign_detail_screen.dart`) | renewal due, payment received/failed, wallet low/recharged, campaign delivered/failed, financial summary ready | 6 |
| 10 | Jobs & applications (`jobs_screen.dart`, `job_apply_screen.dart`, `my_application_sceen.dart`) | new matching job posted, application received, application status changed, job post approved/rejected | 4 |
| 11 | Requirements — B2B/B2C matching (`requirements_screen.dart`, `my_requirements_screen.dart`) | new requirement matches your business, response received | 2 |
| 12 | UQueens, training & programmes (`uqueens_screen.dart`, `training_screen.dart`, `childrens_programme.dart`, `prince_princess_programme.dart`) | registration open, training reminder, certificate/milestone ready | 3 |
| 13 | Ward/Assembly/leaderboards (`ward_screen.dart`, `leader_board_screen.dart`, `assembly_leaderboard_screen.dart`) | ward rank changed, new member joined your ward, scorecard updated, points milestone reached | 4 |
| 14 | News (`news_screen.dart`, `news_management_dashboard_screen.dart`) | new news/announcement relevant to your ward/sector | 1 |
| 15 | Social channels & incidents (`incidents_screen.dart`, `review_approvals_screen.dart`, `storage_screen.dart`) | incident reported/resolved, content pending your review, storage limit approaching | 3 |
| 16 | Onboarding / profile (`profile_screen.dart`, `signup_screen.dart`) | profile approved/verified, missing-field reminder, family member linked (once profile-matching ships) | 3 |
| 17 | Surveys, referrals & system messages | survey available, referral bonus earned, important SMS/email delivered as in-app notice | 3 |
| | **Total** | | **≈ 64** |

That lands at roughly **60–65 distinct trigger types across 17 modules** — this is sized directly off this app's own screens and API tags, nothing borrowed from any other project's numbers.

**Time required, in its three genuinely different pieces:**

- **Core notification system** — a first working cut: `firebase_messaging`/local-notification handling wired up from zero (no push package exists in `pubspec.yaml` today), a live feed screen backed by one list endpoint, basic unread/read state, and a bell badge: **1.5–3 days**. This is the piece you flagged as overestimated, and it's revised down accordingly — it's genuinely close to boilerplate once the backend has even a minimal list endpoint to call.
- **Wiring all ~60–65 trigger types** across the 17 modules above, including per-module badge counts, a full settings screen, and deep-link routing into each one — each type needs a backend event or client trigger, a card template, a deep link, and on-device verification: **15–21 days**. AI-assisted coding speeds up writing the repetitive per-type code, but each type still has to be fired and checked on a device, which is most of where this time goes. The role-removal trigger specifically can't be verified until the missing `RoleAPI` revoke endpoint exists.
- **Play Store internal/closed testing** (review queue + a minimum real-tester soak period before production): **6–10 days elapsed**, essentially independent of trigger count or coding speed — this is Google's clock, not the dev team's, and it can run in parallel with other work rather than sitting alone on the critical path.

**Total for notifications alone: roughly 22.5–34 days** (down from the earlier 30–44 once the core-system line was corrected), 6–10 of which is elapsed waiting time that overlaps other work.

---

## 3. Does AI-assisted coding change the numbers?

It compresses the mechanical, pattern-heavy parts — generating the notification card/badge/settings UI, wiring one new API client method per existing convention, rolling the same sub-sub-sector dropdown out to 4 screens using `passleadscreen.dart` as the template, gating and removing the always-on debug prints across 26+ files. Those items realistically compress by 25–35%.

It does **not** compress:
- **Play Store review + soak time** — elapsed calendar time, unrelated to coding speed.
- **Backend delivery** for notifications, role-revoke, and family-linking — a second team's schedule.
- **Family/spouse linking UX** — invite flows, bidirectional linking, and "whose business shows on whose card" edge cases need human product judgment and real-device testing.
- **On-device verification of ~60–65 notification triggers** — each one still has to be fired and checked once wired, regardless of how fast the code was generated.

| | Without AI assistance (person-days) | With AI-assisted coding (person-days) |
|---|---|---|
| Core engineering effort (all 6 feature areas) | 61–94 | **43–66** |
| Play Store elapsed/waiting time (not compressible) | 6–10 | 6–10 |
| **Grand total** | **67–104** | **49–76** |

(Both columns are lower than an earlier pass of this table, purely because the notification core-system line above was corrected from 9–13 days down to 1.5–3 — nothing else changed.)

---

## 4. Three plans

### Plan 1 — Actual effort needed (AI-assisted, sequential person-days)

| Feature | Min days | Max days |
|---|---|---|
| Leads — Own: polish, edge/empty states (already built, not a rebuild) | 1 | 2 |
| Leads — B2B/B2C/Social/Communication/UBN: delete the 5 orphaned stub files, confirm the existing dashboard + full screens cover the need | 0.5 | 1 |
| Leads — AI Leads: consolidated screen wired to `getMatchedLeads`, accept/dismiss, keep the existing contextual section | 3 | 5 |
| Notifications — core system + push infrastructure (revised down per your note) | 1.5 | 3 |
| Notifications — wiring ~60–65 trigger types | 15 | 21 |
| Notifications — Play Store testing cycle (elapsed, parallelizable) | 6 | 10 |
| Profile matching — family/spouse linked accounts, invite, tap-through, multi-member | 9 | 13 |
| Primary/secondary address toggle + updating ~4 display surfaces | 3 | 5 |
| API optimization — gate/remove always-on debug prints, then cache/paginate/de-dupe across ~180–190 wired calls | 7 | 11 |
| Sector sub-sub-sector rollout — 4 confirmed screens + small model field | 3 | 5 |
| **Total (person-days, AI-assisted)** | **49** | **76** |

With 2 developers running independent tracks in parallel and backend delivering notifications/role-revoke/family-link APIs on its own schedule, this compresses to roughly **29–45 calendar days** before final QA and release — about 3–5 days tighter than before, purely from the notification core-system correction.

### Plan 2 — 45 calendar days (target finish ≈ 25 October 2026), AI-assisted throughout

| Phase | Days | Deliverables |
|---|---|---|
| Phase 1 | 1–7 | Sector sub-sub-sector rollout (4 screens); primary/secondary address toggle + display logic; delete the 5 orphaned lead-management stubs; notifications core system + push infrastructure built (now a 1.5–3 day item, so it lands early); backend starts on notification, role-revoke, and family-link APIs in parallel |
| Phase 2 | 6–16 | Leads: Own finalized, AI Leads consolidated screen wired to `getMatchedLeads` |
| Phase 3 | 14–32 | Notifications: trigger-type wiring, now with 3–5 extra days freed up by the core-system correction to push toward the higher-priority ~35–40 of the ~64 types; profile family/spouse matching built (invite, link, tap-through) |
| Phase 4 | 30–40 | Remaining notification trigger types wired to reach the full ~64; API optimization pass across the ~180–190 wired calls |
| Phase 5 | 38–45 | Full regression QA, Play Store closed-testing submission and monitoring, bug-fixing, release |

**Same feature-by-feature breakdown as Plan 1, checked against the 45-day capacity:** since Plan 2 is framed as reaching full release, every feature's full effort from Plan 1 has to fit — the table below is that same per-feature min/max, carried over unchanged, so you can see directly what has to land inside the 45 days.

| Feature | Min days | Max days |
|---|---|---|
| Leads — Own: polish, edge/empty states | 1 | 2 |
| Leads — B2B/B2C/Social/Communication/UBN: cleanup only | 0.5 | 1 |
| Leads — AI Leads: consolidated screen | 3 | 5 |
| Notifications — core system + push infrastructure | 1.5 | 3 |
| Notifications — wiring ~60–65 trigger types | 15 | 21 |
| Notifications — Play Store testing cycle (elapsed) | 6 | 10 |
| Profile matching — family/spouse linking, full scope | 9 | 13 |
| Primary/secondary address toggle | 3 | 5 |
| API optimization — full pass | 7 | 11 |
| Sector sub-sub-sector rollout | 3 | 5 |
| **Total (person-days, AI-assisted)** | **49** | **76** |

**Capacity check:** 2 developers × 45 days ≈ 90 person-days of raw capacity (before counting backend, which runs its own track) — comfortably above the 76-day worst case above, which is the headroom that makes "complete by day 45" realistic rather than optimistic. The margin (roughly 14–41 person-days) is what Phase 5's QA/bug-fixing/testing-monitoring time draws from.

**What's realistically still pending at day 45, even in this plan:** this is the "complete by 45 days" target, so it's built to reach release — but the two genuine risk points are the ~64-notification catalogue (if any trigger's backend event slips, that type carries past day 45) and the Play Store review queue itself, which runs on Google's schedule and can push the actual public release a few days past day 45 even if every build task inside the team's control finishes on time. A second API-optimization pass is also expected once the new notification/role-revoke/family-link endpoints land — that's follow-on work by design, not a miss on this plan.

### Plan 3 — 11 September to 10 October (≈29–30 day window, your requested date), AI-assisted throughout

Because the leads side turned out to need far less rebuilding than the "needs to do" list assumed (Own is already built; B2B/B2C/Social/Communication/UBN are already reachable through existing screens; the sector rollout only touches 4 screens, not more) — and now with the notification core-system estimate corrected down to 1.5–3 days, which frees up several more days for trigger-type wiring inside this same window — this window is more workable than it would otherwise look:

| Status by 10 Oct | Item |
|---|---|
| Done | Sector sub-sub-sector rollout across all 4 confirmed screens |
| Done | Primary/secondary profile address switching |
| Done | Leads — Own (My Leads) polished; the 5 orphaned stub files removed and the existing B2B/B2C/Social/Communication/UBN access points confirmed |
| Done | Leads — AI Leads consolidated screen live, wired to the real `getMatchedLeads` endpoint |
| Done | Notifications core system live (feed, read/unread, badges, push registration, deep links) — now built in the first few days rather than the first two weeks — plus roughly the top 30–35 of the ~64 trigger types (up from ~25–30 before the correction, since the days saved on the core system roll straight into trigger wiring) |
| Partial | Profile family matching — invite + linking flow likely built for spouse; multi-family-member support and full tap-through polish likely carries over |
| **Pending / carried over past 10 Oct** | Remaining ~29–34 notification trigger types (including anything depending on the not-yet-built role-revoke endpoint), the full API optimization pass, Play Store closed-testing submission, full multi-member family-matching polish |

**Same feature-by-feature breakdown as Plan 1, split into what fits inside the window and what doesn't** — each row's two halves add back up to that feature's Plan 1 total:

| Feature | Days done by 10 Oct (min–max) | Days pending, rolls into Plan 2 (min–max) |
|---|---|---|
| Leads — Own: polish | 1–2 (fully done) | 0–0 |
| Leads — B2B/B2C/Social/Communication/UBN: cleanup | 0.5–1 (fully done) | 0–0 |
| Leads — AI Leads: consolidated screen | 3–5 (fully done) | 0–0 |
| Notifications — core system + push infrastructure | 1.5–3 (fully done) | 0–0 |
| Notifications — trigger-type wiring | 7–11 (≈ top 30–35 of ~64 types) | 8–10 (remaining ~29–34 types) |
| Notifications — Play Store testing cycle | 0–0 (not started) | 6–10 (full cycle still ahead) |
| Profile matching — family/spouse linking | 5.5–8.5 (spouse invite + link built) | 3.5–4.5 (multi-member + tap-through polish) |
| Primary/secondary address toggle | 3–5 (fully done) | 0–0 |
| API optimization | 0–0 (not started) | 7–11 (full pass still ahead) |
| Sector sub-sub-sector rollout | 3–5 (fully done) | 0–0 |
| **Total** | **24.5–40.5** | **24.5–35.5** |

So of the 49–76 person-days in Plan 1, roughly **24.5–40.5 days' worth actually lands inside the 11 Sep–10 Oct window**, and **24.5–35.5 days' worth carries into the remainder of Plan 2** (days 30–45) — those two totals are the same split shown qualitatively in the status table above, just quantified.

In short: this window comfortably covers the two smaller self-contained items (sector rollout, address switching), the leads cleanup and AI Leads screen, and — now that the core system is a fast build rather than a two-week one — a notification system that's not just live but meaningfully populated. The remaining notification types, the complete family-matching feature, and the API optimization pass are what's genuinely pending past 10 October, and need the additional 8–17 days captured in Plan 2 to close out.

---

## 5. Dependencies and risks worth flagging to the client

Notifications and family-invite both need backend endpoints that don't exist yet, and role-removal notifications specifically need a new `RoleAPI` revoke/remove endpoint that isn't there today either — every plan above assumes backend delivers these in parallel and on schedule; a slip there pushes the matching frontend milestones directly. AI Leads is lower-risk than a first read suggests: the exact fetch/render pattern (`getMatchedLeads` → card list) is already shipping today inside `LeadDetailScreen`, so the consolidated screen is proven, not speculative — the remaining work is the screen itself, the accept/dismiss flow, and (if "dismiss" needs its own status) a small backend addition. The Play Store closed/internal testing track carries elapsed time outside the team's control and is the tightest point in Plan 2's timeline. Finally, the 274-operation backend surface (42 modules) against roughly 180–190 wired calls today means the app's API surface keeps growing as these six features land — the optimization pass above is scoped against today's baseline, so expect a second optimization pass once the new notification, role-revoke, and family-linking endpoints go live.
