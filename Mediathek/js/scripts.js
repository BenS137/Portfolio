"use strict";

const API_URL ="https://hdm-stuttgart.de/mediathek/mediathek_api";

const IMAGE_URL ="https://hdm-stuttgart.de/mediathek/stage_mediafiles";

const currentPage = document.body.dataset.page;

// Liest die Projekt-ID aus einer URL
const projectIdFromUrl = new URLSearchParams(window.location.search).get("projekt_ID");

//API-Funktionen

// Lädt Daten von einem API-Endpunkt und wandelt die Antwort in JSON um
async function loadData(endpoint) {
    const response = await fetch(API_URL + endpoint);

    if (!response.ok) {
        throw new Error("API-Fehler: " + response.status);
    }

    return await response.json();
}


// Lädt Projektliste
async function loadProjects(endpoint) {
    const data = await loadData(endpoint);

    return findProjectArray(data);
}


function findProjectArray(data) {
    if (Array.isArray(data)) {
        return data;
    }

    if (data && typeof data === "object") {
        const array = Object.values(data).find(function (value) {
            return Array.isArray(value);
        });

        if (array) {
            return array;
        }
    }

    return [];
}


function getProjectId(project) {
    return project.projekt_ID;
}


function getProjectTitle(project) {
    return project.projekt_titel || "Projekt ohne Titel";
}


function getProjectDescription(project) {
    return project.untertitel || "";
}


// URL des Vorschaubildes erstellen

function getThumbnailUrl(projectId) {
    return (
        IMAGE_URL +
        "/" +
        projectId +
        "/medianight_web/klein.jpg"
    );
}


function setText(selector, text) {
    const element = document.querySelector(selector);

    if (element) {
        element.textContent = text;
    }
}


// Startseite

// Projektkarte erzeugen

function createProjectCard(project) {
    const projectId = getProjectId(project);
    const title = getProjectTitle(project);
    const description = getProjectDescription(project);

    const card = document.createElement("article");
    card.className = "project-card";

    const link = document.createElement("a");
    link.href =
        "detail.html?projekt_ID=" +
        encodeURIComponent(projectId);

    const image = document.createElement("img");
    image.className = "project-card-image";
    image.src = getThumbnailUrl(projectId);
    image.alt = "Vorschaubild von " + title;
    image.loading = "lazy";

    const content = document.createElement("div");
    content.className = "project-card-content";

    const heading = document.createElement("h3");
    heading.className = "project-card-title";
    heading.textContent = title;

    content.append(heading);

    // Beschreibung nur anzeigen, wenn eine vorhanden ist
    if (description) {
        const text = document.createElement("p");
        text.className = "project-card-description";
        text.textContent = description;

        content.append(text);
    }

    link.append(image, content);
    card.append(link);

    return card;
}


// Mehrere Projekte anzeigen

function showProjects(containerId, projects) {
    const container = document.querySelector("#" + containerId);

    if (!container) {
        return;
    }

    container.innerHTML = "";

    if (projects.length === 0) {
        container.textContent = "Keine Projekte gefunden.";
        return;
    }

    // Pro Themenband höchstens acht Projekte anzeigen
    projects.slice(0, 8).forEach(function (project) {
        container.append(createProjectCard(project));
    });
}


// Zufälliges Projekt im Hero-Bereich anzeigen

function showHeroProject(project) {
    const projectId = getProjectId(project);
    const title = getProjectTitle(project);
    const description = getProjectDescription(project);

    const hero = document.querySelector("#hero");
    const link = document.querySelector("#hero-link");

    if (!hero || !projectId) {
        return;
    }

    setText("#hero-title", title);

    setText(
        "#hero-description",
        description ||
        "Entdecke dieses Projekt aus der HdM-Mediathek."
    );

    if (link) {
        link.href =
            "detail.html?projekt_ID=" +
            encodeURIComponent(projectId);
    }

    hero.style.backgroundImage =
        "linear-gradient(90deg, " +
        "rgba(0, 0, 0, 0.9), " +
        "rgba(0, 0, 0, 0.25)), " +
        "url('" + getThumbnailUrl(projectId) + "')";
}


// Daten der Startseite laden

async function initializeHomePage() {
    try {
        const results = await Promise.all([
            loadProjects("/select_projekt_random"),
            loadProjects("/latest_added_projects"),
            loadProjects("/select_projekt_film"),
            loadProjects("/select_projekt_game"),
            loadProjects("/select_projekt_tv"),
            loadProjects("/select_projekt_ca")
        ]);

        const randomProjects = results[0];

        if (randomProjects.length > 0) {
            showHeroProject(randomProjects[0]);
        }

        showProjects("latest-projects", results[1]);
        showProjects("film-projects", results[2]);
        showProjects("game-projects", results[3]);
        showProjects("tv-projects", results[4]);
        showProjects("animation-projects", results[5]);

        await loadWatchlistProjects();

    } catch (error) {
        console.error("Fehler auf der Startseite:", error);
        showHomePageError();
    }
}


// Fehlermeldung anzeigen, falls die API nicht erreichbar ist

function showHomePageError() {
    const loadingMessages =
        document.querySelectorAll(".loading-message");

    loadingMessages.forEach(function (message) {
        message.textContent =
            "Die Projekte konnten nicht geladen werden.";
    });

    setText(
        "#hero-description",
        "Das Hero-Projekt konnte nicht geladen werden."
    );
}


// Detailseite

async function initializeDetailPage() {
    // Ohne Projekt-ID kann kein Projekt geladen werden
    if (!projectIdFromUrl) {
        showDetailError("Es wurde keine Projekt-ID angegeben.");
        return;
    }

    try {
        const endpoint =
            "/one_specific_video?projekt_ID=" +
            encodeURIComponent(projectIdFromUrl);

        // Detaildaten des ausgewählten Projekts laden
        const data = await loadData(endpoint);

        console.log("Detaildaten:", data);

        //Der Endpunkt liefert normalerweise ein Objekt.Falls ein Array zurückkommt, wird der erste Eintrag genutzt.

        const project = Array.isArray(data) ? data[0] : data;

        if (!project || !project.projekt_ID) {
            throw new Error("Projekt wurde nicht gefunden.");
        }

        // Text, Bild und weitere Projektinformationen anzeigen
        showProjectDetails(project);
        // Merkliste für dieses Projekt aktivieren
        initializeWatchlistButton(project.projekt_ID);

        // Erstes freigegebenes Projektvideo laden
        await loadProjectVideo(project.projekt_ID);
        
    } catch (error) {
        console.error("Fehler auf der Detailseite:", error);

        showDetailError(
            "Die Projektdaten konnten nicht geladen werden."
        );
    }
}



//Projektdaten in die Detailseite einsetzen

function showProjectDetails(project) {
    const projectId = project.projekt_ID;
    const title = project.projekt_titel || "Projekt ohne Titel";

    // Kurzer Text für den Hero-Bereich
    const subtitle = project.untertitel || "Keine Kurzbeschreibung vorhanden.";

    // Ausführlicher Text für den Informationsbereich
    const description = project.beschreibung || subtitle;

    const semester = project.semester || project.medianight_semester || "–";

    const supervisor = project.betreuer || "–";

    const courses = project.studiengaenge || "–";

    const software = project.software || "–";

    const team =  project.team || "–";

    // Titel des Browser-Tabs ändern
    document.title = title + " | HdM-Mediathek";

    // Hero-Bereich ausfüllen
    setText("#detail-title", title);
    setText("#detail-description", subtitle);

    // Ausführliche Projektbeschreibung
    setText("#project-description", description);

    // Projektinformationen anzeigen
    setText("#information-semester", semester);
    setText("#information-supervisor", supervisor);
    setText("#information-courses", courses);
    setText("#information-software", software);
    setText("#information-team", cleanTeamNames(team));

    // Externe Projektlinks anzeigen
    showProjectLinks(project.weblinks);

    const imageUrl = getThumbnailUrl(projectId);
    const detailHero = document.querySelector("#detail-hero");

    // Projektbild als Hintergrund des Hero-Bereichs setzen
    if (detailHero) {
        detailHero.style.backgroundImage =
            "linear-gradient(90deg, " +
            "rgba(0, 0, 0, 0.9), " +
            "rgba(0, 0, 0, 0.25)), " +
            "url('" + imageUrl + "')";
    }

    const video = document.querySelector("#project-video");

    // Projektbild als Vorschaubild des Videos verwenden
    if (video) {
        video.poster = imageUrl;
    }
}

function cleanTeamNames(team) {
    if (!team || team === "–") {
        return "–";
    }

    // Teilt die Namen an den Kommas auf, entfernt überflüssige Leerzeichen und verbindet sie wieder
    return team
        .split(",")
        .map(function (name) {
            return name.trim();
        })
        .filter(function (name) {
            return name !== "";
        })
        .join(", ");
}

function showProjectLinks(links) {
    const container = document.querySelector("#information-links");

    if (!container) {
        return;
    }

    container.innerHTML = "";

    if (!Array.isArray(links) || links.length === 0) {
        container.textContent =
            "Keine Weblinks vorhanden.";
        return;
    }

    links.forEach(function (url, index) {
        const link = document.createElement("a");

        link.href = url;
        link.target = "_blank";
        link.rel = "noopener noreferrer";
        link.className = "project-link";

        // Lesbare Bezeichnung statt der vollständigen URL
        link.textContent =
            getLinkName(url, index);

        container.append(link);
    });
}

// Erstellt eine verständliche Bezeichnung für die externen Projektlinks

function getLinkName(url, index) {

    if (
        url.includes("pages.mi.hdm-stuttgart.de") ||
        url.includes("gitlab")
    ) {
        return "Projektwebsite";
    }

    return "Weblink " + (index + 1);
}



function showDetailError(message) {
    setText("#detail-title", "Projekt nicht verfügbar");
    setText("#detail-description", message);

    const watchButton = document.querySelector("#watch-button");

    if (watchButton) {
        watchButton.disabled = true;
    }
}

// Lädt das erste freigegebene Video eines Projekts

async function loadProjectVideo(projectId) {
    const videoElement = document.querySelector("#project-video");

    if (!videoElement) {
        return;
    }

    try {
       
        const videos = await loadData("/generateVideoSources?projektID=" + encodeURIComponent(projectId));

        console.log("Geladene Videos:", videos);

        // Prüfen, ob mindestens ein Video vorhanden ist
        if (!Array.isArray(videos) || videos.length === 0) {
            throw new Error("Kein Video vorhanden.");
        }

        const selectedVideo = videos.find(function (video) {
return video.freigegeben === true;
        });

        if (!selectedVideo) {
            throw new Error("Kein freigegebenes Video vorhanden.");
        }

        // Prüfen, ob das Video mindestens eine Quelle besitzt
        if (
            !Array.isArray(selectedVideo.sources) ||
            selectedVideo.sources.length === 0
        ) {
            throw new Error("Keine Videoquelle vorhanden.");
        }

        // Nach einer 720p-Quelle suchen, falls keine vorhanden wird die erste Quelle verwendet
    
        const selectedSource =
            selectedVideo.sources.find(function (source) {
                return source.label === "720p";
            }) || selectedVideo.sources[0];

        // Videoquelle in das HTML5-video-Element einsetzen
        videoElement.src = selectedSource.src;
        videoElement.load();

        // Titel und Dauer unterhalb des Players anzeigen
        const duration = formatVideoDuration(selectedVideo.dauer);

        setText(
            "#video-message",
            selectedVideo.titel +
            " · " +
            selectedSource.label +
            " · " +
            duration
        );
    } catch (error) {
        console.error("Video konnte nicht geladen werden:", error);

        setText(
            "#video-message",
            "Für dieses Projekt ist kein abspielbares Video verfügbar."
        );
    }
}

// Wandelt Sekunden in Minuten und Sekunden um
function formatVideoDuration(seconds) {
    const totalSeconds = Number(seconds);

    if (!Number.isFinite(totalSeconds)) {
        return "Dauer unbekannt";
    }

    const minutes = Math.floor(totalSeconds / 60);
    const remainingSeconds = totalSeconds % 60;

    return (
        minutes +
        ":" +
        String(remainingSeconds).padStart(2, "0") +
        " min"
    );
}

// Button scrollt zum Videoplayer

function initializeWatchButton() {
    const watchButton = document.querySelector("#watch-button");
    const videoSection = document.querySelector("#video-section");

    if (!watchButton || !videoSection) {
        return;
    }

    watchButton.addEventListener("click", function () {
        videoSection.scrollIntoView({
            behavior: "smooth"
        });
    });
}

// Light- und Darkmode

function getSystemTheme() {
    const prefersDarkMode = window.matchMedia("(prefers-color-scheme: dark)");

    return prefersDarkMode.matches ? "dark" : "light";
}


function initializeTheme() {
    const savedTheme = localStorage.getItem("theme");
    const initialTheme = savedTheme || getSystemTheme();

    setTheme(initialTheme, false);

    const themeButton = document.querySelector("#theme-toggle");

    if (themeButton) {
        themeButton.addEventListener("click", function () {
            const currentTheme = document.documentElement.dataset.theme;

            const newTheme = currentTheme === "dark" ? "light" : "dark";

            // Manuelle Auswahl im Browser speichern
            setTheme(newTheme, true);
        });
    }

    // Reagiert auf Änderungen des Systemmodus

    const systemTheme = window.matchMedia("(prefers-color-scheme: dark)");

    systemTheme.addEventListener("change", function (event) {
        const savedTheme = localStorage.getItem("theme");

        if (!savedTheme) {
            const newTheme = event.matches ? "dark" : "light";

            setTheme(newTheme, false);
        }
    });
}


function setTheme(theme, saveSelection) {
    document.documentElement.dataset.theme = theme;

    if (saveSelection) {
        localStorage.setItem("theme", theme);
    }

    updateThemeButton(theme);
    updateBrowserThemeColor(theme);
}


function updateThemeButton(theme) {
    const themeButton = document.querySelector("#theme-toggle");

    if (!themeButton) {
        return;
    }

    if (theme === "dark") {
        themeButton.textContent = "Lightmode";
        themeButton.setAttribute("aria-pressed", "false");
    } else {
        themeButton.textContent = "Darkmode";
        themeButton.setAttribute("aria-pressed", "true");
    }
}



function updateBrowserThemeColor(theme) {
    const themeColor = document.querySelector("#theme-color");

    if (!themeColor) {
        return;
    }

    if (theme === "dark") {
        themeColor.content = "#101014";
    } else {
        themeColor.content = "#f4f4f6";
    }
}

// Suchseite

// Verbindet das Suchformular mit der API.

function initializeSearchPage() {
    const searchForm = document.querySelector("#search-form");

    const searchInput = document.querySelector("#search-input");

    if (!searchForm || !searchInput) {
        return;
    }

    searchForm.addEventListener("submit", function (event) {
        // Verhindert das normale Neuladen der Seite
        event.preventDefault();

        const searchText = searchInput.value.trim();

        if (searchText === "") {
            return;
        }

        searchProjects(searchText);
    });
}


// Projekte anhand eines Suchbegriffs laden

async function searchProjects(searchText) {
    const resultsContainer = document.querySelector("#search-results");

    if (!resultsContainer) {
        return;
    }

    // Während der Anfrage eine Rückmeldung anzeigen
    resultsContainer.innerHTML =
        '<p class="loading-message">Suche läuft …</p>';

    setText(
        "#search-heading",
        'Ergebnisse für „' + searchText + '“'
    );

    setText("#result-count", "");

    try {
        const data = await loadData("/suche/suche?suchtext=" + encodeURIComponent(searchText));

        // API-Antwort zum Überprüfen in der Browserkonsole
        console.log("Suchergebnisse:", data);

        const projects = findProjectArray(data);

        showSearchResults(projects);
    } catch (error) {
        console.error("Fehler bei der Suche:", error);

        resultsContainer.innerHTML =
            '<p class="empty-message">' +
            "Die Suche konnte nicht durchgeführt werden." +
            "</p>";
    }
}


// Gefundene Projekte als Karten anzeigen

function showSearchResults(projects) {
    const resultsContainer = document.querySelector("#search-results");

    if (!resultsContainer) {
        return;
    }

    resultsContainer.innerHTML = "";

    // Anzahl der gefundenen Projekte anzeigen
    setText(
        "#result-count",
        projects.length + " Projekte gefunden"
    );

    if (projects.length === 0) {
        const message = document.createElement("p");

        message.className = "empty-message";
        message.textContent =
            "Zu diesem Suchbegriff wurden keine Projekte gefunden.";

        resultsContainer.append(message);
        return;
    }

    // Für jedes Projekt eine bereits vorhandene Karte erzeugen
    projects.forEach(function (project) {
        resultsContainer.append(
            createProjectCard(project)
        );
    });
}
// Merkliste

const WATCHLIST_KEY = "hdm-watchlist";

// Liest die gespeicherten Projekt-IDs aus localStorage
function getWatchlist() {
    const savedWatchlist = localStorage.getItem(WATCHLIST_KEY);

    if (!savedWatchlist) {
        return [];
    }

    try {
        const projectIds = JSON.parse(savedWatchlist);

        return Array.isArray(projectIds)
            ? projectIds
            : [];
    } catch (error) {
        console.error(
            "Merkliste konnte nicht gelesen werden:",
            error
        );

        return [];
    }
}

// Speichert die Projekt-IDs im Browser
function saveWatchlist(projectIds) {
    localStorage.setItem(
        WATCHLIST_KEY,
        JSON.stringify(projectIds)
    );
}

function isProjectSaved(projectId) {
    const watchlist = getWatchlist();

    return watchlist.includes(String(projectId));
}

function toggleWatchlist(projectId) {
    const id = String(projectId);
    let watchlist = getWatchlist();

    if (watchlist.includes(id)) {
        watchlist = watchlist.filter(function (savedId) {
            return savedId !== id;
        });
    } else {
        watchlist.push(id);
    }

    saveWatchlist(watchlist);
    updateWatchlistButton(id);
}

function updateWatchlistButton(projectId) {
    const button = document.querySelector("#watchlist-button");

    if (!button) {
        return;
    }

    const saved = isProjectSaved(projectId);

    button.textContent = saved
        ? "Aus Merkliste entfernen"
        : "Zur Merkliste";

    button.classList.toggle("is-saved", saved);

    button.setAttribute(
        "aria-pressed",
        String(saved)
    );
}

async function loadWatchlistProjects() {
    const container = document.querySelector("#watchlist-projects");

    if (!container) {
        return;
    }

    const projectIds = getWatchlist();

    if (projectIds.length === 0) {
        container.innerHTML =
            '<p class="empty-message">' +
            "Du hast noch keine Projekte gespeichert." +
            "</p>";

        return;
    }

    container.innerHTML =
        '<p class="loading-message">' +
        "Merkliste wird geladen …" +
        "</p>";

    /*
     * allSettled sorgt dafür, dass ein einzelnes
     * fehlerhaftes Projekt nicht alles blockiert.
     */
    const results = await Promise.allSettled(
        projectIds.map(async function (projectId) {
            const data = await loadData("/one_specific_video?projekt_ID=" + encodeURIComponent(projectId));

            return Array.isArray(data)
                ? data[0]
                : data;
        })
    );

    const projects = results
        .filter(function (result) {
            return (
                result.status === "fulfilled" &&
                result.value &&
                result.value.projekt_ID
            );
        })
        .map(function (result) {
            return result.value;
        });

    if (projects.length === 0) {
        container.innerHTML =
            '<p class="empty-message">' +
            "Die gespeicherten Projekte konnten nicht geladen werden." +
            "</p>";

        return;
    }

    showProjects("watchlist-projects", projects);
}

function initializeWatchlistButton(projectId) {
    const button = document.querySelector("#watchlist-button");

    if (!button) {
        return;
    }

    updateWatchlistButton(projectId);

    button.addEventListener("click", function () {
        toggleWatchlist(projectId);
    });
}

// Allgemeine Funktionen

function setCopyrightYear() {
    const yearElement = document.querySelector("#copyright-year");

    if (yearElement) {
        yearElement.textContent =
            new Date().getFullYear();
    }
}


function initializePage() {
    initializeTheme();
    setCopyrightYear();

    if (currentPage === "home") {
        initializeHomePage();
    }

    if (currentPage === "detail") {
        initializeDetailPage();
        initializeWatchButton();
    }

    if (currentPage === "search") {
        initializeSearchPage();
    }
}

initializePage();