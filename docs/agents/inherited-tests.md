# Inherited test examples and hard rules (Playwright, Maestro)

> Moved verbatim out of `AGENTS.md` on 2026-10-04 so that file fits the 32 KiB Codex reads
> by default. Its rules still bind: `AGENTS.md` lists the hard ones inline and says when to
> read this file. Edit the rule here, not a copy of it.

## E2E (Playwright) — mandatory

**Why this is a hard rule.** Unit tests pass while the product is broken: the component renders, the
type-check is green, and then a real click hits an endpoint that doesn't exist, sends the wrong
payload shape, or returns 500. Mocked fetches hide exactly that class of bug, because the mock
encodes what the author *assumed* the API does. Only driving the running app against the real API
proves the feature works.

- **Every user flow needs a spec** — create / edit / delete, navigation, forms, filters, auth-gated
  screens. A slice with UI is not done until its flow has a Playwright spec.
- **Against the running app and the REAL API.** Boot the stack from Playwright's `webServer` (or a
  compose target) and hit real endpoints against a **disposable test database** — never the dev DB.
  **Do not stub the network layer in E2E**; that's what the unit/integration layer is for.
- **The minimum assert is not "the button exists".** A flow is verified when: the request actually
  goes out, it answers 2xx, the UI reflects the change, and **the change survives a reload**
  (i.e. it was persisted, not just optimistic local state).
- **Fail loudly on noise.** Wire `page.on('console')` and `page.on('response')` so the spec fails on
  console errors and on unexpected 4xx/5xx — those are the API mismatches this layer exists to catch.
- **Accessible locators only** — `getByRole`, `getByLabel`, `getByText`; never brittle CSS/XPath.
  This doubles as the semantics layer the agentic PR verification depends on (see
  [Agentic PR verification](pr-verification.md#agentic-pr-verification-mandatory-on-every-pr)).
- **Blocking on push.** `pnpm test:e2e` runs in the pre-push hook; a red E2E means no push.
- **A UI bug fix gets a failing E2E first**, then the fix — same rule as unit regressions.
- **Non-web surfaces generalize.** Native Android (Jetpack Compose) → **Maestro**, which has the same
  mandatory status Playwright has here — see
  [Native Android (Jetpack Compose) — Maestro](#native-android-jetpack-compose--maestro) below;
  desktop shell → Playwright's `_electron`; API-only services → a `pytest` + `httpx` (or supertest)
  smoke that exercises the real HTTP surface. The rule is "drive the real thing", not "use Playwright".

## Native Android (Jetpack Compose) — Maestro

**Maestro is the E2E engine for native Android, exactly as Playwright is for the web** — same status,
same rule: a slice with a Compose screen is not done until its journey has a committed flow that runs
green against the real APK on an emulator. It is also the **discovery** tool: how you find out what
the running app actually exposes, instead of guessing selectors from the source.

Flows are YAML under `.maestro/`, one file per user journey (optional workspace `config.yaml` at the
root):

```yaml
# .maestro/example-flow.yaml
appId: com.example.app
name: Example journey (not applicable to this repo)
tags:
  - smoke
---
- launchApp:
    clearState: true
- tapOn:
    id: "example_add_item"       # Modifier.testTag — needs the opt-in below
- inputText: "example text"
- tapOn: "Example visible label"     # visible text also works
- assertVisible:
    text: ".*example.*"        # selectors accept regex
- extendedWaitUntil:
    visible: "Example screen title"
    timeout: 10000
```

```bash
maestro list-devices                          # what is actually connected
maestro start-device --platform=android --device-model=pixel_6 --device-os=android-33
maestro test .maestro/                        # a directory works; whole suite
maestro test .maestro/example-flow.yaml -c          # --continuous: re-runs on save while you iterate
maestro test .maestro/ --include-tags=smoke --format=JUNIT --test-output-dir=build/maestro
maestro check-syntax .maestro/example-flow.yaml     # exits 1 on an invalid command — a usable hard gate
maestro record --local .maestro/example-flow.yaml   # video, for a bug report or a PR comment
```

**The Compose gotcha that costs an afternoon.** `Modifier.testTag("x")` is **invisible to Maestro by
default**: Compose keeps test tags in its own semantics tree, while Maestro reads the Android view
hierarchy through UiAutomator. Until you opt in, only `text` and `contentDescription` are matchable —
so flows silently fall back to user-visible strings and break on the first copy edit or in the other
locale. Turn tags into resource ids once, on a root composable:

```kotlin
@OptIn(ExperimentalComposeUiApi::class)
Box(Modifier.semantics { testTagsAsResourceId = true }) { ExampleAppNavHost() }
```

Then `tapOn: { id: "example_add_item" }` resolves.

### Discovery — ask the running app, don't guess

```bash
maestro hierarchy             # full view hierarchy of the connected device
maestro hierarchy --compact   # CSV: element_num,depth,attributes,parent_num — greppable
maestro mcp                   # MCP server over STDIO: device + automation as tools for an agent
```

`maestro hierarchy` is the ground truth about what is reachable: **if a control isn't in that tree, no
flow can tap it and no screen reader can announce it** — that is an accessibility bug before it is a
test problem. Run it before writing a flow and after adding a screen. `maestro mcp` exposes the same
capabilities to an LLM agent over MCP, which is what the agentic PR pass should drive instead of
screenshot coordinates.

> `maestro studio` was removed in Maestro 2.x — use `hierarchy` and `mcp`. Check `maestro --help`
> before trusting a command you remember; the CLI moves.

The rules mirror the Playwright ones:

- **Against the real APK on an emulator**, never a mocked backend. Boot one with `maestro start-device`
  if `maestro list-devices` shows nothing; `--device` picks the target when several are attached.
- **`clearState: true`** at the top makes a flow independent — and it **wipes that app's data on the
  device**, so flows belong on a dedicated emulator, never on a daily phone.
- **Prefer `id` over `text`** once `testTagsAsResourceId` is on. Text selectors are copy- and
  locale-dependent; if the app ships two locales, a text-only flow is a flow that passes in one of them.
- **A UI bug fix gets a failing flow first**, then the fix.
- **`maestro check-syntax` in the pre-commit hook** — it exits non-zero on an invalid command, so a
  typo'd `tapOnn` never reaches CI. `--format=JUNIT --test-output-dir=…` is what CI consumes.
- **`--headless` is web-only.** It does nothing for an Android run; don't reach for it when a flow hangs.

### Run before declaring done

| Change touches               | Run before claiming success                                          |
| ---------------------------- | -------------------------------------------------------------------- |
| backend service/controller   | `pnpm --filter @example/api test` (+ `pnpm test:e2e` if cross-module) |
| frontend component/hook/util | `pnpm --filter @example/web test`                                    |
| **any user-facing flow** (new screen, form, button wired to an endpoint) | `pnpm test:e2e` — **required**, unit tests do not prove the flow works |
| something ambiguous or large | `pnpm test:all`                                                      |

### What to test per folder

| Folder | What | Status |
| --- | --- | --- |
| `lib/` | Pure utilities, hooks — deterministic, minimal mocks | Pending |
| `components/` | Logic-bearing components: forms, dialogs, toggles. Mount + `user-event`. Exclude UI primitives | Pending |
| `hooks/` | Custom hooks via `renderHook`. Mock timers/fetch only when unavoidable | Pending |
| `src/*` services / `app/api/` | Call the exported handler/service directly; check status codes, validation, error paths | Pending |

### TDD — required for new logic

For new code in `services/`, `lib/`, `hooks/`, non-primitive `components/`, shared schemas and form logic:

1. **Red** — write a failing test that describes the behavior.
2. **Green** — implement the minimum to pass.
3. **Refactor** — clean up under green tests.

Exceptions (TDD not required): pure visual/style changes (CSS, layout, copy); UI primitives (tested
indirectly by consumers); spikes/exploration — but add tests before merging.

## Hard rules (no exceptions)

- **Never claim done without showing test output.** "Type-check passes" is not "it works".
- **New endpoint / DTO / hook / schema → needs a test.** No exceptions.
- **A bug fix needs a failing regression test first**, then the fix (see `systematic-debugging`).
- **Never delete, `.skip` or `.only` a test to get green.** Fix the code or the test on purpose.
- **No feature with UI is done without a green E2E against the real API.** Driving the running app
  is the proof — **Playwright** on web, a **Maestro flow on a real emulator** for a Compose screen;
  type-check, unit tests and a screenshot are not. If the flow has no spec, the flow is not finished.
- **Never mock the API to make an E2E pass.** A mocked E2E proves the mock works, not the product.
- **Don't lower the 80% gate to ship** — exclude untestable modules in config with a written reason.
- **Test over mock** — exercise real code with minimal stubs; don't mock entire modules.

### Operative conventions

- **Global setup file** — define `matchMedia`, `ResizeObserver`, `IntersectionObserver`,
  `localStorage` stubs once. Don't redefine per test.
- **Split by aspect** when a test file exceeds ~300 LoC: `.flow.test.ts`, `.errors.test.ts`,
  `.branches.test.ts`.
- **Exclude with justification** in config, never silently. Example:

  ```js
  // JSDOM cannot simulate layout/animation timing — cover via E2E
  exclude: ['src/hooks/use-grid-reflow.ts']
  ```
