---
name: modular-csharp
description: >-
  Apply when designing or reviewing module structure in C#/.NET — deciding what
  becomes a project/assembly, what is public vs internal, how to name and bound
  a module, or splitting/merging projects. A module is an ASSEMBLY, not a
  "modular monolith", a bounded context, a layer, or a folder. Use to keep
  "modular code" (Cooper's information-hiding style) from being conflated with
  "modular monolith" (a deployment/packaging pattern).
---

# Modular C#

Based on Ian Cooper, *Modular Code with Examples in C#* (NDC London 2026), which
draws on Parnas (1972), Yourdon & Constantine (1979), and Ousterhout
(*A Philosophy of Software Design*).

## The one thing to get right

**"Modular code" ≠ "modular monolith."** Modular code is an information-hiding
*programming style*; modular monolith is a *packaging/deployment* pattern. Don't
conflate them. The unit of design is the **module**: a logical unit with a narrow
public interface and a hidden implementation that encapsulates one design
decision likely to change (Parnas). The goal is maintainability, not topology.

## What a module is (and is not)

- **A module is an assembly.** In C# the assembly is the module boundary:
  `public` types are the module's *exports*; everything else is `internal` and
  free to change. The assembly is the only mechanism that actually performs
  information hiding.
- **Folders and namespaces are NOT modules.** They hide nothing. Do not use a
  folder as a module boundary.
- **Architecture tests are NOT a substitute** for a real boundary (they invite
  pathological coupling). Rely on the assembly + `internal`.
- **Deep modules, narrow façades.** Prefer a small public surface over a deep
  implementation (Ousterhout). Expose a façade — often an interface, to allow
  alternative implementations — and keep everything behind it `internal`.
- **A module is not a layer.** Never split one module across `Domain` /
  `Application` / `Infrastructure` *assemblies* — that is the classic .NET
  anti-pattern. Layers or ports-&-adapters may *organize* code *inside* a module
  via folders, but the assembly is not a layer.
- **A module is not a bounded context.** A bounded context may contain *several*
  modules; each module tells part of the domain story by hiding a distinct
  decision (Evans).
- **Name modules for the decision they hide, not the entity** — avoid the
  *Entity Trap*. Prefer capability names (e.g. `Resolution`, `Framing`,
  `Outcome`) over `...Manager` / `...Service` / aggregate-named modules.
- **Test at the boundary.** Drive modules through their public exports only.
  **No `[InternalsVisibleTo]`.** Internal classes emerge through refactoring and
  are exercised by tests that go through the public façade.

## Architecture organizes modules — not the other way round

Layers, Ports & Adapters (Hexagonal), Vertical Slice, CQRS, Pipes & Filters are
ways to *organize* modules. The architecture *contains* modules; modules do not
*express* the architecture. Don't rely on folders to convey it. These schemes
nest freely (a slice may be CQRS; a CQRS handler may be a driving port into a
ports-&-adapters module).

## Why this suits AI-assisted work

A module gives an agent a bounded context, a clear interface to implement
against, isolation to generate and verify in, and reduces merge conflicts to
public-interface changes only.

## Designing / reviewing a module — checklist

- **Parnas test:** can you state the one decision this module hides? Vague answer
  → reconsider the boundary.
- **Entity Trap:** is it just wrapping an entity/aggregate lifecycle, or named
  after one? Re-name around the capability/decision.
- **Surface:** is the `public` surface as narrow as possible, with everything
  else `internal`? Is there a façade?
- **Boundary mechanism:** is the boundary an *assembly* (not a folder/namespace,
  not enforced only by an arch test)?
- **Not-a-layer:** is any single module spread across separate layer assemblies?
  Collapse it.
- **Coupling:** keep efferent (depends-on) and afferent (depended-on-by) low;
  flag modules with high total coupling for review.
- **Tests:** do tests go through the public façade, with no `[InternalsVisibleTo]`?

## References

- Parnas, "On the Criteria to Be Used in Decomposing Systems into Modules" (1972)
- Yourdon & Constantine, *Structured Design* (1979)
- Ousterhout, *A Philosophy of Software Design*
- Evans, *Domain-Driven Design* (modules in the domain layer)
- Ian Cooper, *Modular Code with Examples in C#*, NDC London 2026