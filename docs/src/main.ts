import "./styles.css";
import {
  advancedPatterns,
  apiSections,
  features,
  heroSnippet,
  installMethods,
  themeTokens
} from "./data/api";

const app = document.querySelector<HTMLDivElement>("#app");

if (!app) {
  throw new Error("App root was not found.");
}

const createFeatureCards = () =>
  features
    .map(
      (feature) => `
        <article class="feature-card">
          <h3>${feature.title}</h3>
          <p>${feature.body}</p>
        </article>
      `
    )
    .join("");

const createInstallCards = () =>
  installMethods
    .map(
      (method) => `
        <article class="install-card">
          <header>
            <h3>${method.title}</h3>
            <p>${method.description}</p>
          </header>
          <div class="code-block">
            <button class="copy-button" data-copy="${encodeURIComponent(method.code)}">Copy</button>
            <pre><code>${method.code.replace(/</g, "&lt;")}</code></pre>
          </div>
        </article>
      `
    )
    .join("");

const createApiNavigation = () =>
  apiSections
    .map(
      (section) => `
        <a href="#${section.id}" class="sidebar-link">${section.title}</a>
      `
    )
    .join("");

const createApiSections = () =>
  apiSections
    .map(
      (section) => `
        <section class="api-section" id="${section.id}">
          <div class="section-heading">
            <span class="eyebrow">Reference</span>
            <h2>${section.title}</h2>
            <p>${section.description}</p>
          </div>
          <div class="api-grid">
            ${section.methods
              .map(
                (method) => `
                  <article class="api-card" data-search="${`${section.title} ${method.name} ${method.signature} ${method.description}`.toLowerCase()}">
                    <div class="api-card-top">
                      <h3>${method.name}</h3>
                      <code>${method.signature.replace(/</g, "&lt;")}</code>
                    </div>
                    <p>${method.description}</p>
                    ${
                      method.notes?.length
                        ? `<ul>${method.notes.map((note) => `<li>${note}</li>`).join("")}</ul>`
                        : ""
                    }
                  </article>
                `
              )
              .join("")}
          </div>
        </section>
      `
    )
    .join("");

const createPatternCards = () =>
  advancedPatterns
    .map(
      (item) => `
        <article class="pattern-card">
          <h3>${item.title}</h3>
          <p>${item.body}</p>
        </article>
      `
    )
    .join("");

app.innerHTML = `
  <div class="page-shell">
    <header class="hero">
      <nav class="topbar">
        <div class="brand">
          <div class="brand-mark">E</div>
          <div>
            <strong>Eldora UI</strong>
            <span>Detailed docs and API reference</span>
          </div>
        </div>
        <div class="topbar-links">
          <a href="#install">Install</a>
          <a href="#reference">Reference</a>
          <a href="#themes">Themes</a>
          <a href="#patterns">Patterns</a>
        </div>
      </nav>

      <div class="hero-grid">
        <section class="hero-copy">
          <span class="eyebrow">Roblox UI API</span>
          <h1>A polished executor-ready UI library with strong visuals, smooth animation, and a practical scripting API.</h1>
          <p>
            Eldora UI keeps the familiar flow people like in Rayfield-style libraries, but improves the visual finish,
            theme control, state management, and project presentation so the repo feels ready for public use.
          </p>
          <div class="hero-actions">
            <a class="primary-button" href="#install">Start Using It</a>
            <a class="ghost-button" href="#reference">Browse API</a>
          </div>
          <div class="feature-grid">
            ${createFeatureCards()}
          </div>
        </section>

        <section class="hero-code">
          <div class="code-block hero-block">
            <button class="copy-button" data-copy="${encodeURIComponent(heroSnippet)}">Copy</button>
            <pre><code>${heroSnippet.replace(/</g, "&lt;")}</code></pre>
          </div>
        </section>
      </div>
    </header>

    <main class="content-grid">
      <aside class="sidebar">
        <div class="sidebar-panel">
          <span class="eyebrow">Jump To</span>
          <div class="sidebar-links">
            <a href="#install" class="sidebar-link">Install</a>
            <a href="#themes" class="sidebar-link">Themes</a>
            <a href="#reference" class="sidebar-link">Reference</a>
            ${createApiNavigation()}
            <a href="#patterns" class="sidebar-link">Patterns</a>
          </div>
        </div>
      </aside>

      <div class="main-column">
        <section class="content-section" id="install">
          <div class="section-heading">
            <span class="eyebrow">Install</span>
            <h2>Three solid ways to ship it</h2>
            <p>
              The recommended distribution file is <code>dist/EldoraUI.lua</code>. Keep that as the stable public entrypoint
              so script users have one obvious URL to paste.
            </p>
          </div>
          <div class="install-grid">
            ${createInstallCards()}
          </div>
        </section>

        <section class="content-section" id="themes">
          <div class="section-heading">
            <span class="eyebrow">Theming</span>
            <h2>Preset themes plus full token overrides</h2>
            <p>
              Built-in presets include <code>Midnight</code>, <code>Ember</code>, and <code>Glacier</code>. You can also pass
              a partial theme table and only override the tokens you care about.
            </p>
          </div>
          <div class="theme-token-panel">
            ${themeTokens.map((token) => `<span class="token-chip">${token}</span>`).join("")}
          </div>
        </section>

        <section class="content-section" id="reference">
          <div class="section-heading">
            <span class="eyebrow">Reference</span>
            <h2>Everything in one place</h2>
            <p>
              Use the search box below to filter the API reference quickly by control name, method signature, or description.
            </p>
          </div>
          <div class="search-shell">
            <input id="api-search" type="search" placeholder="Search methods, controls, signatures..." />
          </div>
        </section>

        ${createApiSections()}

        <section class="content-section" id="patterns">
          <div class="section-heading">
            <span class="eyebrow">Patterns</span>
            <h2>Practical usage advice</h2>
            <p>
              These are the habits that make Eldora UI easiest to maintain once your script grows beyond a small proof of concept.
            </p>
          </div>
          <div class="pattern-grid">
            ${createPatternCards()}
          </div>
        </section>
      </div>
    </main>
  </div>
`;

const copyButtons = Array.from(document.querySelectorAll<HTMLButtonElement>(".copy-button"));

copyButtons.forEach((button) => {
  button.addEventListener("click", async () => {
    const encoded = button.dataset.copy ?? "";
    const code = decodeURIComponent(encoded);
    await navigator.clipboard.writeText(code);
    const original = button.textContent;
    button.textContent = "Copied";
    window.setTimeout(() => {
      button.textContent = original ?? "Copy";
    }, 1200);
  });
});

const searchInput = document.querySelector<HTMLInputElement>("#api-search");
const searchableCards = Array.from(document.querySelectorAll<HTMLElement>(".api-card"));
const apiSectionsRendered = Array.from(document.querySelectorAll<HTMLElement>(".api-section"));

searchInput?.addEventListener("input", () => {
  const value = searchInput.value.trim().toLowerCase();

  searchableCards.forEach((card) => {
    const haystack = card.dataset.search ?? "";
    const visible = haystack.includes(value);
    card.classList.toggle("hidden", !visible);
  });

  apiSectionsRendered.forEach((section) => {
    const visibleCards = Array.from(section.querySelectorAll(".api-card:not(.hidden)"));
    section.classList.toggle("hidden", visibleCards.length === 0);
  });
});
