const palette = {
    background: "#171717",        // canvas background
    panel: "#3B4953",            // separation background
    accent: "#90AB8B",           // textArea background
    text: "#e6e6e6",             // text color
    textSecondary: "#a9a9a9"     // secondary text color
};

const defaultProjects = [
    {
        id: 1,
        title: "Company Logo",
        description: "Modern Company Logo.",
        category: "Logo",
        year: 2023,
        svgFile: "res/cat1.svg"
    },
    {
        id: 2,
        title: "App icons",
        description: "Minimalistic style, wide pourpose",
        category: "Icons",
        year: 2023,
        svgFile: "res/cat2.svg"
    },
    {
        id: 3,
        title: "Ilustration",
        description: "Abstract style, used for fashion article",
        category: "Ilustration",
        year: 2024,
        svgFile: "res/cat3.svg"
    },
    {
        id: 4,
        title: "Business card",
        description: "Business card project for a different company.",
        category: "Polygraphy",
        year: 2023,
        svgFile: "res/cat4.svg"
    },
    {
        id: 5,
        title: "Advertisement banner",
        description: "Used for company advertisement across different social media platforms",
        category: "Web Design",
        year: 2024,
        svgFile: "res/cat5.svg"
    }
];

let projects = [...defaultProjects];
let currentProjectIndex = 0;
let svgObjects = []; // Przechowuje dane SVG (XML string)
let svgDataUrls = []; // Przechowuje data URLs dla SVG
let loadedSVGs = []; // Flagi które SVG zostały załadowane
let svgElements = []; // Przechowuje DOM elementy SVG
let thumbnailDataUrls = []; // Data URLs dla miniaturek

// Transformacje dla podglądu SVG
let svgScale = 1;
let svgOffset = { x: 0, y: 0 };
let isDragging = false;
let dragStart = { x: 0, y: 0 };
let svgRotation = 0;

// Referencje do elementów DOM
let projectsContainer, currentProjectTitle, projectDetails;
let prevBtn, nextBtn, zoomInBtn, zoomOutBtn, resetViewBtn, rotateBtn;
let downloadBtn, zoomInfo, notification, loadingIndicator;
let svgContainer; // Kontener dla SVG

function setup() {
    const canvasContainer = document.getElementById('p5-canvas');
    const canvasWidth = canvasContainer.offsetWidth;
    const canvasHeight = canvasContainer.offsetHeight;
    
    let canvas = createCanvas(canvasWidth, canvasHeight);
    canvas.parent('p5-canvas');
    
    // Inicjalizacja referencji do elementów DOM
    initDOMElements();
    
    // kontener dla SVG
    svgContainer = createDiv('');
    svgContainer.parent('p5-canvas');
    svgContainer.id('svg-container');
    svgContainer.style('position', 'absolute');
    svgContainer.style('top', '0');
    svgContainer.style('left', '0');
    svgContainer.style('width', '100%');
    svgContainer.style('height', '100%');
    svgContainer.style('display', 'flex');
    svgContainer.style('align-items', 'center');
    svgContainer.style('justify-content', 'center');
    svgContainer.style('pointer-events', 'none');
    
    // grafiki SVG z plików
    loadSVGFiles();
    
    // Aktualizacja interfejsu
    updateProjectList();
    updateProjectView();
    
    // Nasłuchiwanie zdarzeń
    setupEventListeners();
}

function initDOMElements() {
    projectsContainer = document.getElementById('projects-container');
    currentProjectTitle = document.getElementById('current-project-title');
    projectDetails = document.getElementById('project-details');
    
    prevBtn = document.getElementById('prev-btn');
    nextBtn = document.getElementById('next-btn');
    zoomInBtn = document.getElementById('zoom-in-btn');
    zoomOutBtn = document.getElementById('zoom-out-btn');
    resetViewBtn = document.getElementById('reset-view-btn');
    rotateBtn = document.getElementById('rotate-btn');
    downloadBtn = document.getElementById('download-btn');
    
    zoomInfo = document.getElementById('zoom-info');
    notification = document.getElementById('notification');
    loadingIndicator = document.getElementById('loading-indicator');
}

async function loadSVGFiles() {
    loadingIndicator.classList.add('active');
    
    // Inicjalizacja tablicy SVG
    svgObjects = new Array(projects.length);
    svgDataUrls = new Array(projects.length);
    thumbnailDataUrls = new Array(projects.length);
    loadedSVGs = new Array(projects.length).fill(false);
    
    // Wczytanie plików svg
    const loadPromises = [];
    for (let i = 0; i < projects.length; i++) {
        loadPromises.push(loadSingleSVG(i));
    }
    
    // czeka na załadowanie wszystkich
    await Promise.all(loadPromises);
    
    loadingIndicator.classList.remove('active');
    updateSVGDisplay();
    updateProjectList(); // Odświeża listę, aby pokazać miniaturki
}

async function loadSingleSVG(index) {
    const project = projects[index];
    
    try {
        // czy plik istnieje
        if (!project.svgFile) {
            throw new Error(`Invalid path ${project.title}`);
        }
        
        // fetch do pobrania pliku SVG
        const response = await fetch(project.svgFile);
        if (!response.ok) {
            // Jeśli plik nie istnieje, fallback
            throw new Error(`Cannot load: ${project.svgFile}`);
        }
        
        const svgText = await response.text();
        svgObjects[index] = svgText;
        
        // data URL z SVG
        const svgBlob = new Blob([svgText], {type: 'image/svg+xml'});
        svgDataUrls[index] = URL.createObjectURL(svgBlob);
        
        // miniaturka
        createThumbnail(index, svgText);
        
        //  DOM dla SVG
        const parser = new DOMParser();
        const svgDoc = parser.parseFromString(svgText, 'image/svg+xml');
        const svgElement = svgDoc.documentElement;
        
        // for responsive size 
        svgElement.setAttribute('preserveAspectRatio', 'xMidYMid meet');
        svgElement.setAttribute('width', '100%');
        svgElement.setAttribute('height', '100%');
        
        svgElements[index] = svgElement;
        loadedSVGs[index] = true;
        
        console.log(`Loaded SVG: ${project.svgFile}`);
        
    } catch (error) {
        console.error(`Error occured ${project.title}:`, error);
        createFallbackSVG(index, project);
        loadedSVGs[index] = true;
    }
}

function createThumbnail(index, svgText) {
    try {
        // SVG na element
        const parser = new DOMParser();
        const svgDoc = parser.parseFromString(svgText, 'image/svg+xml');
        const svgElement = svgDoc.documentElement;
        
        // rozmiary dla miniaturki
        svgElement.setAttribute('width', '60');
        svgElement.setAttribute('height', '60');
        svgElement.setAttribute('preserveAspectRatio', 'xMidYMid meet');
        
        // element z powrotem do stringa
        const serializer = new XMLSerializer();
        const thumbnailSvg = serializer.serializeToString(svgElement);
        
        // data URL dla miniaturki
        const thumbnailBlob = new Blob([thumbnailSvg], {type: 'image/svg+xml'});
        thumbnailDataUrls[index] = URL.createObjectURL(thumbnailBlob);
        
    } catch (error) {
        console.error(`Thumbnail generating error:`, error);
        thumbnailDataUrls[index] = null;
    }
}

function createFallbackSVG(index, project) {
    // fallback SVG jeśli plik nie istnieje
    const fallbackSVG = `
        <svg width="400" height="400" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
            <rect width="400" height="400" fill="#2a363f"/>
            <rect x="50" y="50" width="300" height="300" rx="15" fill="#3B4953" stroke="#90AB8B" stroke-width="3"/>
            <text x="200" y="150" font-family="Arial" font-size="24" fill="#e6e6e6" text-anchor="middle">${project.title}</text>
            <text x="200" y="200" font-family="Arial" font-size="16" fill="#a9a9a9" text-anchor="middle">${project.category}</text>
            <text x="200" y="250" font-family="Arial" font-size="14" fill="#888" text-anchor="middle">Plik SVG nie został znaleziony</text>
            <circle cx="200" cy="320" r="40" fill="#90AB8B" opacity="0.3"/>
            <text x="200" y="325" font-family="Arial" font-size="12" fill="#171717" text-anchor="middle">SVG</text>
        </svg>
    `;
    
    svgObjects[index] = fallbackSVG;
    
    // data URL z fallback SVG
    const svgBlob = new Blob([fallbackSVG], {type: 'image/svg+xml'});
    svgDataUrls[index] = URL.createObjectURL(svgBlob);
    
    // miniaturka fallback
    createThumbnail(index, fallbackSVG);
    
    // Przetwarza na element DOM
    const parser = new DOMParser();
    const svgDoc = parser.parseFromString(fallbackSVG, 'image/svg+xml');
    svgElements[index] = svgDoc.documentElement;
    
    loadedSVGs[index] = true;
}

function updateSVGDisplay() {
    svgContainer.html('');
    
    if (currentProjectIndex < svgElements.length && svgElements[currentProjectIndex]) {
        // Klonuj element SVG aby uniknąć problemów z referencjami
        const svgClone = svgElements[currentProjectIndex].cloneNode(true);
        
        // atrybuty dla transformacji
        svgClone.style.transformOrigin = 'center center';
        svgClone.style.transform = `translate(${svgOffset.x}px, ${svgOffset.y}px) scale(${svgScale}) rotate(${svgRotation}deg)`;
        svgClone.style.transition = 'transform 0.1s ease-out';
        svgClone.style.maxWidth = '90%';
        svgClone.style.maxHeight = '90%';
        
        svgContainer.elt.appendChild(svgClone);
    }
}

function setupEventListeners() {
    // Przyciski nawigacji
    prevBtn.addEventListener('click', showPreviousProject);
    nextBtn.addEventListener('click', showNextProject);
    
    // Przyciski transformacji
    zoomInBtn.addEventListener('click', () => adjustZoom(0.2));
    zoomOutBtn.addEventListener('click', () => adjustZoom(-0.2));
    resetViewBtn.addEventListener('click', resetView);
    rotateBtn.addEventListener('click', rotateSVG);
    
    // Przycisk pobierania
    downloadBtn.addEventListener('click', downloadCurrentSVG);
    
    // Upload plików
    document.getElementById('svg-upload').addEventListener('change', handleFileUpload);
    
    // Responsywność canvas
    window.addEventListener('resize', function() {
        const canvasContainer = document.getElementById('p5-canvas');
        const canvasWidth = canvasContainer.offsetWidth;
        const canvasHeight = canvasContainer.offsetHeight;
        resizeCanvas(canvasWidth, canvasHeight);
        updateSVGDisplay();
    });
    
    // Event listener dla przeciągania SVG
    const canvasEl = document.getElementById('p5-canvas');
    
    canvasEl.addEventListener('mousedown', (e) => {
        if (e.target === canvasEl || e.target.parentElement === canvasEl) {
            isDragging = true;
            dragStart.x = e.clientX - svgOffset.x;
            dragStart.y = e.clientY - svgOffset.y;
        }
    });
    
    document.addEventListener('mousemove', (e) => {
        if (isDragging) {
            svgOffset.x = e.clientX - dragStart.x;
            svgOffset.y = e.clientY - dragStart.y;
            updateSVGDisplay();
        }
    });
    
    document.addEventListener('mouseup', () => {
        isDragging = false;
    });
    
    canvasEl.addEventListener('wheel', (e) => {
        e.preventDefault();
        const zoomFactor = 0.1;
        const rect = canvasEl.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        
        // nowe powiększenie
        const oldScale = svgScale;
        if (e.deltaY < 0) {
            svgScale = Math.min(5, svgScale + zoomFactor);
        } else {
            svgScale = Math.max(0.1, svgScale - zoomFactor);
        }
        
        // offset, aby zoom był względem pozycji myszy
        const scaleChange = svgScale - oldScale;
        svgOffset.x -= (mouseX - canvasEl.offsetWidth / 2) * scaleChange;
        svgOffset.y -= (mouseY - canvasEl.offsetHeight / 2) * scaleChange;
        
        updateZoomInfo();
        updateSVGDisplay();
    });
}

function draw() {
    
    background(palette.background);
    
    // ramka
    stroke(palette.accent);
    noFill();
    strokeWeight(2);
    rect(0, 0, width-1, height-1);
    
    // jeśli brak SVG
    if (!loadedSVGs[currentProjectIndex] || !svgElements[currentProjectIndex]) {
        fill(palette.textSecondary);
        textAlign(CENTER, CENTER);
        textSize(18);
        text("Loading project...", width/2, height/2);
    }
}

function adjustZoom(amount) {
    // Zmiana powiększenia za pomocą przycisków
    const oldScale = svgScale;
    svgScale = Math.max(0.1, Math.min(5, svgScale + amount));
    
    // Dostosuj offset dla płynnego zoomowania do środka
    const scaleChange = svgScale - oldScale;
    const canvasEl = document.getElementById('p5-canvas');
    svgOffset.x -= (canvasEl.offsetWidth / 2) * scaleChange;
    svgOffset.y -= (canvasEl.offsetHeight / 2) * scaleChange;
    
    updateZoomInfo();
    updateSVGDisplay();
}

function resetView() {
    // Resetowanie transformacji
    svgScale = 1;
    svgOffset = { x: 0, y: 0 };
    svgRotation = 0;
    updateZoomInfo();
    updateSVGDisplay();
}

function rotateSVG() {
    // Obrót SVG o 90 stopni
    svgRotation += 90;
    if (svgRotation >= 360) svgRotation = 0;
    updateSVGDisplay();
}

function updateZoomInfo() {
    // Aktualizacja informacji o powiększeniu
    zoomInfo.textContent = `Zoom - in : ${Math.round(svgScale * 100)}%`;
}

function updateProjectList() {
    // Wyczyść kontener
    projectsContainer.innerHTML = '';
    
    // każdy projekt do listy
    projects.forEach((project, index) => {
        const projectElement = document.createElement('div');
        projectElement.className = `project-item ${index === currentProjectIndex ? 'active' : ''}`;
        
        // Tworzenie HTML z miniaturką
        let thumbnailHTML = '';
        if (thumbnailDataUrls[index]) {
            thumbnailHTML = `<img src="${thumbnailDataUrls[index]}" alt="${project.title}">`;
        } else {
            thumbnailHTML = `<div class="project-thumbnail-placeholder">${project.category}</div>`;
        }
        
        projectElement.innerHTML = `
            <div class="project-thumbnail">
                ${thumbnailHTML}
            </div>
            <div class="project-info-content">
                <div class="project-title">${project.title}</div>
                <div class="project-description">
                    <span>${project.year}</span>
                    <span class="project-category">${project.category}</span>
                </div>
                ${project.svgFile ? `<div class="project-file" style="font-size: 0.8rem; color: ${palette.textSecondary}; margin-top: 3px;">${project.svgFile}</div>` : ''}
            </div>
            <button class="project-download-btn" data-index="${index}" title="Pobierz ten projekt">
                ↓
            </button>
        `;
        
        projectElement.addEventListener('click', (e) => {
            // Nie wybieraj projektu jeśli kliknięto przycisk pobierania
            if (!e.target.classList.contains('project-download-btn') && 
                !e.target.parentElement.classList.contains('project-download-btn')) {
                selectProject(index);
            }
        });
        
        projectsContainer.appendChild(projectElement);
    });
    
    // event listener dla przycisków pobierania w projektach
    document.querySelectorAll('.project-download-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation(); // Zapobiega wybieraniu projektu
            const index = parseInt(btn.getAttribute('data-index'));
            downloadSVG(index);
        });
    });
    
    // Aktualizacja stanu przycisków
    prevBtn.disabled = currentProjectIndex === 0;
    nextBtn.disabled = currentProjectIndex === projects.length - 1;
}

function updateProjectView() {
    // Aktualizacja podglądu projektu
    if (projects.length > 0 && currentProjectIndex < projects.length) {
        const project = projects[currentProjectIndex];
        currentProjectTitle.textContent = project.title;
        
        const fileInfo = project.svgFile ? 
            `<p><strong>Plik:</strong> ${project.svgFile}</p>` : 
            '<p><strong>Plik:</strong> Brak (wygenerowano proceduralnie)</p>';
        
        projectDetails.innerHTML = `
            ${fileInfo}
            <p><strong>Category:</strong> ${project.category}</p>
            <p><strong>Production year:</strong> ${project.year}</p>
            <p><strong>Description:</strong> ${project.description}</p>
            <p style="margin-top: 10px; color: ${palette.textSecondary}; font-size: 0.9rem;">
                <strong>Instrukcja:</strong> Drag the mouse to move the view. 
               Use scroll wheel to zoom in and out.
            </p>
            <p style="margin-top: 10px; color: ${palette.accent};">
                <strong>Downloading:</strong> Press the "Download SVG" button to upload chosen graphic to your drive.
            </p>
        `;
        
        // czy SVG jest załadowane
        if (!loadedSVGs[currentProjectIndex]) {
            // spróbuj załadować
            loadSingleSVG(currentProjectIndex).then(() => {
                updateSVGDisplay();
            });
        } else {
            updateSVGDisplay();
        }
    } else {
        currentProjectTitle.textContent = "No available projects";
        projectDetails.innerHTML = `<p>Dodaj pliki SVG, aby zobaczyć projekty.</p>`;
    }
    
    updateZoomInfo();
}

function selectProject(index) {
    // Wybór projektu do wyświetlenia
    currentProjectIndex = index;
    resetView();
    updateProjectList();
    updateProjectView();
    redraw();
}

function showPreviousProject() {
    if (currentProjectIndex > 0) {
        selectProject(currentProjectIndex - 1);
    }
}

function showNextProject() {
    if (currentProjectIndex < projects.length - 1) {
        selectProject(currentProjectIndex + 1);
    }
}

// Funkcja do pobierania SVG
function downloadSVG(index) {
    if (index < 0 || index >= svgObjects.length || !svgObjects[index]) {
        //showNotification("Nie można pobrać pliku. Brak danych SVG.");
        return;
    }
    
    const project = projects[index];
    const svgText = svgObjects[index];
    
   
    const fileName = project.title
        .toLowerCase()
        .replace(/[^a-z0-9]/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '') + '.svg';
    
    // Tworzy obiekt Blob z danymi SVG
    const blob = new Blob([svgText], { type: 'image/svg+xml;charset=utf-8' });
    
    // tymczasowy link do pobrania
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    
    //  link do dokumentu
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    
    // Zwolnienie URL
    URL.revokeObjectURL(url);
    
    //showNotification(`Pobrano plik: ${fileName}`);
}

function downloadCurrentSVG() {
    downloadSVG(currentProjectIndex);
}

async function handleFileUpload(event) {
    const files = event.target.files;
    if (files.length === 0) return;
    
    // wskaźnik ładowania
    loadingIndicator.classList.add('active');
    
    // Przetwarzanie każdego pliku
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        
        if (file.type === "image/svg+xml" || file.name.endsWith('.svg')) {
            // nowy projekt
            const newProjectId = projects.length + 1;
            const newProject = {
                id: newProjectId,
                title: `Nowy projekt ${newProjectId}: ${file.name.replace('.svg', '')}`,
                description: "User uploaded file",
                category: "User data",
                year: new Date().getFullYear(),
                svgFile: null 
            };
            
            // zawartość pliku jako tekst
            const reader = new FileReader();
            reader.onload = function(e) {
                const svgText = e.target.result;
                
                // Dodanie do tablicy projektów
                projects.push(newProject);
                
                // Dodanie do tablicy SVG
                const newIndex = projects.length - 1;
                svgObjects[newIndex] = svgText;
                
                // data URL
                const svgBlob = new Blob([svgText], {type: 'image/svg+xml'});
                svgDataUrls[newIndex] = URL.createObjectURL(svgBlob);
                
                // miniaturka
                createThumbnail(newIndex, svgText);
                
                // Przetwarza na element DOM
                const parser = new DOMParser();
                const svgDoc = parser.parseFromString(svgText, 'image/svg+xml');
                const svgElement = svgDoc.documentElement;
                svgElement.setAttribute('preserveAspectRatio', 'xMidYMid meet');
                svgElement.setAttribute('width', '100%');
                svgElement.setAttribute('height', '100%');
                svgElements[newIndex] = svgElement;
                loadedSVGs[newIndex] = true;
                
                // Aktualizuje interfejs
                updateProjectList();
                selectProject(newIndex);
                
                // Ukrywa wskaźnik ładowania po przetworzeniu wszystkich plików
                if (i === files.length - 1) {
                    loadingIndicator.classList.remove('active');
                }
                
                //showNotification(`Dodano projekt: ${newProject.title}`);
            };
            
            reader.readAsText(file);
        } else {
            //showNotification(`Plik ${file.name} nie jest plikiem SVG i został pominięty.`);
        }
    }
    
    // Czyści input, aby umożliwić ponowne wczytanie tego samego pliku
    event.target.value = '';
}