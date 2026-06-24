---
name: modular-design
description: >-
  Apply when designing or reviewing module structure in any language — deciding
  what becomes a module, what is exported vs hidden, how to discover and name
  modules, how to bound them, or how to organize them into an architecture.
  Covers discovery (workflow / actor-action), review (Parnas test, coupling,
  entity trap), organization (technical / domain / flow), and working with
  modules (testing, feature flags, deployment, AI). C# is the worked example;
  the principles are language-agnostic.
---

# Modular design

The principles here are language-agnostic — they apply to C# assemblies, Java
packages/JARs, Go packages, Rust crates, TypeScript modules, and so on; only the
*boundary mechanism* differs. C# is the worked example throughout.

## The one thing to get right

**Modular design is about maintainability, not topology.** "Modular code" (an
information-hiding *programming style*) is not the same as "modular monolith" (a
*packaging/deployment* pattern) — don't conflate them. The unit of design is the
**module**: *a responsibility assignment* (Parnas) — a logical unit with a narrow
public interface and a hidden implementation that encapsulates one design decision
likely to change.

## What a module is (and is not)

- **A module is a responsibility assignment** (Parnas): deal with the *name*, not
  the details (abstraction); don't couple to the details (information hiding).
  Treat it as a black box.
- **Hide decisions likely to change** (Parnas): data structures, algorithms,
  external dependencies. If a decision is hard to change later, hide it now.
- **Deep, not shallow** (Ousterhout): prefer a *narrow* interface over a *deep*
  implementation. A shallow module exposes almost as much as it hides — the
  abstraction isn't paying for itself (watch for lots of parameters/options).
  Expose a **façade** to create a deep module.
- **Interfaces over concretions for exports**: exports may be interfaces, to allow
  alternative implementations.
- **A module is not a layer.** Never split one module across `Domain` /
  `Application` / `Infrastructure` *boundaries*. Layers may *organize* code
  *inside* a module, but a layer is not a module.
- **A module is not a folder or namespace.** They hide nothing. Architecture tests
  are NOT a substitute for a real boundary (they invite pathological coupling).
- **A module is not a bounded context.** A bounded context may contain *several*
  modules; each hides a distinct decision and tells part of the domain story
  (Evans). Both monoliths and microservices may have many modules.

### How the boundary maps to C#

In C# the **assembly** is the module boundary — the only mechanism that actually
performs information hiding:

| Mechanism | Information hiding |
|-----------|--------------------|
| Method    | Body hidden behind its signature. |
| Class     | `private` hides class internals. |
| Namespace | **None** — visibility/organization only; can span many assemblies. |
| Assembly  | Exposes `public`, hides `internal`/`private`. **The module boundary.** |

- `public` = the module's **exports**; `internal` = implementation details, free
  to change; `private` = a class's internals.
- Keep exports **narrow**; make classes `internal` wherever possible; put a façade
  in front.
- Use folders *within* an assembly to organize a large module (e.g. separating
  exports from details) — but the folder is not the boundary.
- **No `[InternalsVisibleTo]`.** Refactoring changes a module's details but not its
  exports (`public`).

In other languages the equivalent boundary is: Java package/JAR + `public` vs
package-private; Go package + exported (capitalized) vs unexported; Rust
crate/module + `pub`; TypeScript module + `export`.

## Designing modules — the method

`Requirement → discover → review → organize → work with`.

### 1. Discover candidate modules

Two complementary lenses:
- **Workflow decomposition** — follow the work through the system
  (`Step 1 → Step 2 → …`); each major step is a candidate module. Sources: Event
  Storming, Value Stream Mapping, BPMN. Good for business processes / data flows.
- **Actor / Action** — `Actor performs Action on Target`. Sources: Use Cases,
  Domain Storytelling, Responsibility-Driven Design. Good for user-centric systems
  with clear responsibilities.

### 2. Review candidates before committing

- **Parnas test** — ask *"what decision does this module hide?"* Clear answer →
  good candidate; vague answer → reconsider the boundary. **Key insight: a
  workflow is independent of the tasks in the workflow** (tasks may be shared
  across workflows), so prefer hiding tasks/decisions over hiding entities.
- **Entity trap** — modules named after entities (`UserManager`, `OrderService`,
  `ContestHandler`) hide *data structure*, not decisions, and scatter behavior
  across "managers." Entities tend to be shared → coupling hotspots. Name modules
  after **capabilities or decisions** instead. (Hard to avoid entirely — sometimes
  a module centers on an aggregate because it must capture data others use.)
- **Coupling** — afferent `Ca` (who depends on me? high → harder to change) and
  efferent `Ce` (who do I depend on? high → more reasons to change). Total
  `CT = Ca + Ce`; high `CT` is a *potential* problem worth review. Minimize
  coupling while keeping cohesion. Splitting only pays when the resulting pieces
  are *genuinely independent* — carving coupled code into separate modules just
  adds coordination overhead.

### 3. Organize modules into an architecture

Architecture *contains* modules; modules do not *express* the architecture. Don't
rely on folders to convey it. Three families (different properties, no "best"):

- **Technical** — by technical role. *Layers* (rules about which modules may
  depend on which); *Ports & Adapters (Hexagonal)* — ports are sockets, adapters
  plug in; driving adapters activate the domain, driven adapters are activated by
  it; partitions *contain* modules, they are not modules.
- **Flow** — by data flow. *Pipes & Filters* / *Flow-Based Programming*: each
  filter is a module with an input/output façade — single transformation,
  composable, no knowledge of neighbors. Good for ETL / event streams.
- **Domain** — by business capability. *Vertical Slice* (layers per use case —
  often folders, which *lack* a real boundary → pathological-coupling risk; a
  slice should still contain real modules); *CQRS* (separate read/write models;
  command/query handlers form the façade to a module).

These **nest** ("turtles all the way down"): a filter may be ports-&-adapters; a
vertical slice may be CQRS whose handler is a façade to a domain module; a CQRS
handler may be a driving port. Don't express the architecture *through* modules —
organize modules *within* it.

## Working with modules

Deep modules with narrow interfaces pay off in:
- **Testing** — the module boundary is the natural test boundary. Test the
  interface/behavior, not the internals; refactor freely inside; no excessive
  mocking. Unit tests target a black box; integration tests sit *between* black
  boxes. **In C#: drive modules through public exports only, no
  `[InternalsVisibleTo]`** — internal classes emerge through refactoring and are
  covered via the public façade.
- **Feature flags** — toggle a whole module on/off (or features within it) at the
  boundary; callers must tolerate an optional module returning nothing. Far easier
  than flags spread through the code.
- **Deployment** — ship different versions of a module (canary), with feedback
  narrowed to that change; swap in a wholly different implementation as long as it
  honors the same façade.
- **AI-assisted work** — a module gives an agent a bounded context, a clear
  interface to implement against, isolation to generate and verify in, and reduces
  merge conflicts to public-interface changes only.

## Review checklist

- **Parnas test:** can you state the one decision this module hides? Vague → rebound.
- **Entity trap:** is it just wrapping an entity/aggregate, or named after one?
  Re-name around the capability/decision.
- **Surface:** is the exported surface as narrow as possible, everything else
  hidden, with a façade? (C#: `public` minimal, rest `internal`.)
- **Boundary mechanism:** is the boundary a real information-hiding unit (C#:
  assembly) — not a folder/namespace, not enforced only by an arch test?
- **Not-a-layer:** is any single module spread across separate layer boundaries?
  Collapse it.
- **Coupling:** keep `Ca` and `Ce` low; flag high-`CT` modules for review.
- **Tests:** do tests go through the public façade? (C#: no `[InternalsVisibleTo]`.)
- **Not a bounded context / not a modular monolith:** is "module" being conflated
  with a deployment unit or a DDD bounded context? Separate them.

## References

- Parnas, "On the Criteria to Be Used in Decomposing Systems into Modules" (1972)
- Yourdon & Constantine, *Structured Design* (1979)
- Ousterhout, *A Philosophy of Software Design*
- Evans, *Domain-Driven Design* (modules in the domain layer)
- Richards & Ford, *Fundamentals of Software Architecture*
- Khononov, *Balancing Coupling in Software Design*
- Ian Cooper, *Modular Code with Examples in C#*, NDC London 2026
  ([slides](https://github.com/iancooper/Presentations/blob/master/modular-csharp%20NDC%20London%202026.pptx))
