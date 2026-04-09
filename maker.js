(() => {
    let cleanup = null;

    window.initMaker = function() {
        if (cleanup) cleanup();
        let isAborted = false;

        let pluginData = {
            name: "ExamplePlugin",
    description: "This is a helpful template created using IY Plugin Maker.",
    headerCode: "",
    footerCode: "return Plugin",
    commands: [
        {
            id: 'cmd_initial',
            key: "example",
            listName: "example / ex",
            desc: "Prints a message to the console",
            aliases: ["ex"],
            code: "print(\"Hello from ExamplePlugin!\")"
        }
    ]
};

// Monaco editor instances
let previewEditor = null;
let cmdEditor = null;

// UI State
let currentEditingCmdId = null;
let isProgrammaticUpdate = false;
let autoSyncEnabled = true;
let cmdSearchQuery = '';

const tourSteps = [
    {
        target: '.maker-header',
        title: 'Welcome to Plugin Maker!',
        desc: 'This tool lets you build Infinite Yield plugins visually without writing the boilerplate code yourself.'
    },
    {
        target: '.usage-steps',
        title: 'Follow the Steps',
        desc: 'We\'ve outlined 4 simple steps to get your plugin from idea to .iy file. Use these as your checklist!'
    },
    {
        target: '#import-area',
        title: 'Import Existing Plugins',
        desc: 'Already have a .iy file? Drag and drop it here or click to import. You can edit any existing plugin with ease!'
    },
    {
        target: '#ide-mode-toggle',
        title: 'IDE Mode',
        desc: 'Toggle this for a code-centric focus. It maximizes your screen real estate for a true developer experience.'
    },
    {
        target: '.commands-header',
        title: 'Create Your Commands',
        desc: 'This is the heart of your plugin. Add multiple commands here. You can even search through them if you have many!'
    },
    {
        target: '#add-cmd-btn',
        title: 'Launch the Editor',
        desc: 'Clicking here opens the Command Editor modal. Let\'s see what\'s inside!'
    },
    {
        target: '.cmd-editor-modal',
        title: 'The Command Editor',
        desc: 'Everything you define here goes directly into your plugin\'s command list.',
        requiresModal: true
    },
    {
        target: '#cmd-key',
        title: 'Internal Name (Key)',
        desc: 'The unique ID used by IY. For example, if you set this to "fly", the code will be associated with that command ID internally.',
        requiresModal: true
    },
    {
        target: '#cmd-list-name',
        title: 'Usage Format',
        desc: 'This is how users see your command in the list. Use brackets like [arg] to show that your command accepts inputs!',
        requiresModal: true
    },
    {
        target: '#cmd-desc',
        title: 'Command Description',
        desc: 'Explain what your command does. This text appears when a user types "help" in the Infinite Yield console.',
        requiresModal: true
    },
    {
        target: '#cmd-aliases',
        title: 'Command Aliases',
        desc: 'Add shortcuts for your command! Separate multiple aliases with commas (e.g. "f" for "fly").',
        requiresModal: true
    },
    {
        target: '#monaco-cmd-editor',
        title: 'Logic Editor',
        desc: 'Write your Lua code here. You have access to "args" for inputs and "speaker" for the player running the command.',
        requiresModal: true
    },
    {
        target: '#save-cmd-btn',
        title: 'Save and Close',
        desc: 'Save your command to immediately see it in your list and update the live preview on the right!',
        requiresModal: true
    },
    {
        target: '.maker-preview-section',
        title: 'Live Preview',
        desc: 'As you make changes, the Lua code updates in real-time here. You can even manually edit this code if you need total control.'
    },
    {
        target: '#download-btn',
        title: 'Ready to Go?',
        desc: 'Once you\'re happy, click Download to save your plugin and place it in your exploit\'s workspace folder.'
    }
];
let currentTourStep = -1;

const MONACO_BASE = 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.46.0/min';

// Worker proxy — required for cross-origin / file:// usage
window.MonacoEnvironment = {
    getWorkerUrl: function () {
        return `data:text/javascript;charset=utf-8,${encodeURIComponent(`
            self.MonacoEnvironment = { baseUrl: '${MONACO_BASE}/' };
            importScripts('${MONACO_BASE}/vs/base/worker/workerMain.js');
        `)}`;
    }
};

window.monacoInitPromise = window.monacoInitPromise || null;

function initMonaco() {
    if (window.monacoInitPromise) return window.monacoInitPromise;

    window.monacoInitPromise = new Promise((resolve, reject) => {
        // 1. If already globally available
        if (window.monaco) {
            resolve();
            return;
        }

        // 2. If the loader script is already present but not finished, wait for it
        if (document.getElementById('monaco-loader-script')) {
            const check = setInterval(() => {
                if (window.monaco) {
                    clearInterval(check);
                    resolve();
                }
            }, 50);
            
            // Timeout after 10s to avoid infinite loop
            setTimeout(() => {
                clearInterval(check);
                if (!window.monaco) reject(new Error('Monaco loading timed out'));
            }, 10000);
            return;
        }

        // 3. Inject loader script
        const loaderScript = document.createElement('script');
        loaderScript.id = 'monaco-loader-script';
        loaderScript.src = `${MONACO_BASE}/vs/loader.min.js`;
        loaderScript.onload = () => {
            // Configure the loader to use CDNs for workers
            require.config({ 
                paths: { 'vs': `${MONACO_BASE}/vs` }
            });

            // Load main editor
            require(['vs/editor/editor.main'], () => {
                resolve();
            }, (err) => {
                reject(err);
            });
        };
        loaderScript.onerror = () => {
            reject(new Error('Failed to load Monaco loader script from CDN'));
        };
        document.head.appendChild(loaderScript);
    });
    return window.monacoInitPromise;
}

initMonaco().then(() => {
    if (isAborted) return;
    // Register Roblox Lua IntelliSense
    if (!window.monacoLuaRegistered) {
        monaco.languages.registerCompletionItemProvider('lua', {
        provideCompletionItems: function (model, position) {
            var word = model.getWordUntilPosition(position);
            var range = {
                startLineNumber: position.lineNumber,
                endLineNumber: position.lineNumber,
                startColumn: word.startColumn,
                endColumn: word.endColumn
            };
            var suggestions = [];
            
            const globals = ["game", "workspace", "script", "math", "string", "table", "coroutine", "task", "tick", "os", "debug", "Instance", "Vector3", "Vector2", "CFrame", "Color3", "UDim2", "UDim", "Ray", "RaycastParams", "TweenInfo", "Enum", "BrickColor", "pcall", "ypcall", "xpcall", "print", "warn", "error"];
            globals.forEach(kw => {
                suggestions.push({
                    label: kw,
                    kind: monaco.languages.CompletionItemKind.Class,
                    insertText: kw,
                    range: range
                });
            });

            const methods = ["GetService", "FindFirstChild", "WaitForChild", "GetChildren", "GetDescendants", "Clone", "Destroy", "IsA", "FindFirstChildOfClass", "FindFirstChildWhichIsA", "FireServer", "InvokeServer", "Connect", "Disconnect", "Wait", "ClearAllChildren"];
            methods.forEach(md => {
                suggestions.push({
                    label: md,
                    kind: monaco.languages.CompletionItemKind.Method,
                    insertText: md,
                    range: range
                });
            });

            const services = ["Players", "ReplicatedStorage", "ServerScriptService", "ServerStorage", "StarterGui", "StarterPack", "StarterPlayer", "Lighting", "MaterialService", "Workspace", "RunService", "TweenService", "UserInputService", "HttpService", "TeleportService", "DataStoreService", "CollectionService", "MarketplaceService", "PhysicsService", "SoundService", "TextService", "ContextActionService", "VoiceChatService"];
            services.forEach(sv => {
                suggestions.push({
                    label: sv,
                    kind: monaco.languages.CompletionItemKind.Interface,
                    insertText: sv,
                    range: range
                });
            });
            
            
            return { suggestions: suggestions };
        }
        });
        window.monacoLuaRegistered = true;
    }

    const previewEl = document.getElementById('monaco-preview');
    if (!previewEl) return;

    previewEditor = monaco.editor.create(previewEl, {
        value: generateLua(),
        language: 'lua',
        theme: 'vs-dark',
        readOnly: false,
        minimap: { enabled: false },
        scrollBeyondLastLine: false,
        padding: { top: 16, bottom: 16 },
        fontSize: 13,
        fontFamily: "'JetBrains Mono', monospace",
        automaticLayout: true
    });

    previewEditor.onDidChangeModelContent(e => {
        if (!isProgrammaticUpdate && autoSyncEnabled) {
            autoSyncEnabled = false;
            document.getElementById('sync-warning').classList.remove('hidden');
        }
    });

    const cmdEl = document.getElementById('monaco-cmd-editor');
    if (!cmdEl) return;

    cmdEditor = monaco.editor.create(cmdEl, {
        value: 'print("Hello World!")',
        language: 'lua',
        theme: 'vs-dark',
        minimap: { enabled: false },
        scrollBeyondLastLine: false,
        padding: { top: 12, bottom: 12 },
        fontSize: 13,
        fontFamily: "'JetBrains Mono', monospace",
        automaticLayout: true
    });

    renderCommands(); // Render the initial template command

    // Attach search listener
    const cmdSearch = document.getElementById('cmd-search');
    if (cmdSearch) {
        cmdSearch.addEventListener('input', (e) => {
            cmdSearchQuery = e.target.value.toLowerCase().trim();
            renderCommands();
        });
    }

    // Attach tour listeners
    document.getElementById('start-tour-btn').addEventListener('click', startTour);
    document.getElementById('tour-next').addEventListener('click', nextTourStep);
    document.getElementById('tour-back').addEventListener('click', prevTourStep);
    document.getElementById('tour-skip').addEventListener('click', endTour);

    // Attach IDE mode listener
    const ideToggle = document.getElementById('ide-mode-toggle');
    if (ideToggle) {
        ideToggle.addEventListener('click', () => {
            document.body.classList.toggle('ide-mode');
            
            // Resize Monaco editors
            const resizeEditors = () => {
                if (previewEditor) previewEditor.layout();
                if (cmdEditor) cmdEditor.layout();
            };

            // Instant layout for better feel
            resizeEditors();
            
            // Broader safety checks as the grid settles
            setTimeout(resizeEditors, 100);
            setTimeout(resizeEditors, 500);

            // End tour if active to prevent misalignment
            if (currentTourStep !== -1) endTour();
        });
    }

    // Handle window resizing
    let resizeTimer;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(() => {
            if (previewEditor) previewEditor.layout();
            if (cmdEditor) cmdEditor.layout();
        }, 100);
    });

}).catch(err => {
    console.error('Monaco failed to load:', err);
    const previewEl = document.getElementById('monaco-preview');
    if (previewEl) {
        previewEl.innerHTML = `
            <div style="padding:24px; color:#ef4444; background:rgba(239, 68, 68, 0.1); border-radius:8px; border:1px solid rgba(239, 68, 68, 0.2); font-family:sans-serif;">
                <h3 style="margin-top:0; font-size:1.1rem;">Monaco Editor Error</h3>
                <p style="font-size:0.9rem; line-height:1.5; margin-bottom:12px;">The code editor failed to initialize. This usually happens due to network issues or restrictive security protocols (like <code>file://</code>).</p>
                <div style="font-family:monospace; font-size:0.8rem; background:rgba(0,0,0,0.2); padding:8px; border-radius:4px; margin-bottom:16px;">${err.message || 'Unknown Error'}</div>
                <button class="btn btn-primary btn-sm" onclick="location.reload()">Reload Page</button>
            </div>
        `;
    }
});

// Setup listeners
document.getElementById('plugin-name').addEventListener('input', (e) => {
    pluginData.name = e.target.value;
    updatePreview();
});

document.getElementById('plugin-desc').addEventListener('input', (e) => {
    pluginData.description = e.target.value;
    updatePreview();
});

document.getElementById('resume-sync-btn').addEventListener('click', () => {
    autoSyncEnabled = true;
    document.getElementById('sync-warning').classList.add('hidden');
    updatePreview();
});

function generateLua() {
    let lua = "";

    if (pluginData.headerCode && pluginData.headerCode.trim().length > 0) {
        lua += pluginData.headerCode.trim() + "\n\n";
    }

    lua += `local Plugin = {\n`;
    lua += `    ["PluginName"] = "${escLua(pluginData.name)}",\n`;
    lua += `    ["PluginDescription"] = "${escLua(pluginData.description)}",\n`;
    lua += `    ["Commands"] = {\n`;

    for (let i = 0; i < pluginData.commands.length; i++) {
        let c = pluginData.commands[i];
        lua += `        ["${escLua(c.key)}"] = {\n`;
        lua += `            ["ListName"] = "${escLua(c.listName)}",\n`;
        lua += `            ["Description"] = "${escLua(c.desc)}",\n`;
        let aliasesStr = c.aliases.map(a => `"${escLua(a.trim())}"`).join(', ');
        lua += `            ["Aliases"] = {${aliasesStr}},\n`;
        lua += `            ["Function"] = function(args, speaker)\n`;

        // Indent each line of the user's code
        let lines = c.code.split('\n');
        for (let line of lines) {
            lua += `                ${line}\n`;
        }

        lua += `            end\n`;
        lua += `        }${i === pluginData.commands.length - 1 ? '' : ','}\n`;
    }

    lua += `    }\n`;
    lua += `}\n`;
    
    if (pluginData.footerCode && pluginData.footerCode.trim().length > 0) {
        lua += "\n" + pluginData.footerCode.trim() + "\n";
    } else {
        lua += `\nreturn Plugin\n`;
    }
    
    return lua;
}

function escLua(str) {
    return (str || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function updatePreview() {
    if (previewEditor && autoSyncEnabled) {
        isProgrammaticUpdate = true;
        previewEditor.setValue(generateLua());
        isProgrammaticUpdate = false;
    }
}

function renderCommands() {
    const list = document.getElementById('commands-list');
    list.innerHTML = '';

    const filtered = pluginData.commands.filter(cmd => {
        if (!cmdSearchQuery) return true;
        return (cmd.key && cmd.key.toLowerCase().includes(cmdSearchQuery)) || 
               (cmd.listName && cmd.listName.toLowerCase().includes(cmdSearchQuery)) ||
               (cmd.desc && cmd.desc.toLowerCase().includes(cmdSearchQuery));
    });

    if (filtered.length === 0 && pluginData.commands.length > 0) {
        list.innerHTML = '<div class="empty-search">No commands match your search.</div>';
    }

    filtered.forEach(cmd => {
        const div = document.createElement('div');
        div.className = 'cmd-item';
        div.innerHTML = `
            <div class="cmd-info">
                <h4>${cmd.listName}</h4>
                <p>Key: <code>${cmd.key}</code></p>
            </div>
            <div class="cmd-actions">
                <button class="btn btn-secondary btn-sm" onclick="gotoCommand('${escLua(cmd.key)}')" title="Go to Code">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="16 18 22 12 16 6"></polyline>
                        <polyline points="8 6 2 12 8 18"></polyline>
                    </svg>
                </button>
                <button class="btn btn-secondary btn-sm" onclick="editCommand('${cmd.id}')">Edit</button>
                <button class="btn btn-danger btn-sm" onclick="deleteCommand('${cmd.id}')">Delete</button>
            </div>
        `;
        list.appendChild(div);
    });
}

// --- Tour Logic ---
let tourRaf = null;

function startTour() {
    currentTourStep = 0;
    document.getElementById('tour-overlay').classList.remove('hidden');
    updateTourUI();
    if (tourRaf) cancelAnimationFrame(tourRaf);
    tourRaf = requestAnimationFrame(trackTour);
}

function nextTourStep() {
    currentTourStep++;
    if (currentTourStep >= tourSteps.length) {
        endTour();
    } else {
        updateTourUI();
    }
}

function prevTourStep() {
    if (currentTourStep > 0) {
        currentTourStep--;
        updateTourUI();
    }
}

function endTour() {
    // Final Exit Hook
    if (lastTourStep !== -1 && tourSteps[lastTourStep] && tourSteps[lastTourStep].onExit) {
        tourSteps[lastTourStep].onExit();
    }

    currentTourStep = -1;
    lastTourStep = -1;
    document.getElementById('tour-overlay').classList.add('hidden');
    if (tourRaf) cancelAnimationFrame(tourRaf);
    tourRaf = null;

    // Ensure state cleanup if modal was open
    const modal = document.getElementById('cmd-modal');
    if (modal && !modal.classList.contains('hidden')) {
        document.getElementById('cancel-cmd-btn').click();
    }
}

let lastTourStep = -1;

function updateTourUI() {
    const prevStep = lastTourStep !== -1 ? tourSteps[lastTourStep] : null;
    const step = tourSteps[currentTourStep];
    
    // Lifecycle Exit
    if (prevStep && prevStep.onExit) {
        prevStep.onExit();
    }

    // Lifecycle Enter
    if (step.onEnter) {
        step.onEnter();
    }

    // Modal state management
    const modal = document.getElementById('cmd-modal');
    if (step.requiresModal) {
        if (modal.classList.contains('hidden')) {
            document.getElementById('add-cmd-btn').click();
        }
    } else {
        if (!modal.classList.contains('hidden')) {
            document.getElementById('cancel-cmd-btn').click();
        }
    }

    const target = document.querySelector(step.target);
    
    if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    document.getElementById('tour-title').textContent = step.title;
    document.getElementById('tour-desc').textContent = step.desc;
    document.getElementById('tour-progress').textContent = `${currentTourStep + 1} / ${tourSteps.length}`;
    document.getElementById('tour-next').textContent = (currentTourStep === tourSteps.length - 1) ? 'Finish' : 'Next';
    
    // Toggle back button visibility
    document.getElementById('tour-back').classList.toggle('hidden', currentTourStep === 0);

    lastTourStep = currentTourStep;
}

function trackTour() {
    if (currentTourStep === -1) return;
    
    const step = tourSteps[currentTourStep];
    const target = document.querySelector(step.target);
    const spotlight = document.getElementById('tour-spotlight');
    const card = document.getElementById('tour-card');
    
    if (target) {
        const rect = target.getBoundingClientRect();
        const padding = 10;
        
        // Spotlight calculation (overlay is fixed, so relative to viewport constraints)
        spotlight.style.top = (rect.top - padding) + 'px';
        spotlight.style.left = (rect.left - padding) + 'px';
        spotlight.style.width = (rect.width + padding * 2) + 'px';
        spotlight.style.height = (rect.height + padding * 2) + 'px';
        
        // Card positioning constraints
        const cardRect = card.getBoundingClientRect();
        let cardTop = rect.bottom + 20;
        let cardLeft = rect.left + (rect.width / 2) - (cardRect.width / 2);
        
        // Horizontal constraint
        if (cardLeft < 20) cardLeft = 20;
        if (cardLeft + cardRect.width > window.innerWidth - 20) {
            cardLeft = window.innerWidth - cardRect.width - 20;
        }

        // Vertical flip check: if doesn't fit below, try above
        if (cardTop + cardRect.height > window.innerHeight - 20) {
            let topTry = rect.top - cardRect.height - 20;
            if (topTry > 20) {
                cardTop = topTry;
            } else {
                // If it doesn't fit above OR below, just center it in the screen or pick the one with more space
                cardTop = Math.max(20, (window.innerHeight / 2) - (cardRect.height / 2));
            }
        }

        // Final sanity check for top
        if (cardTop < 20) cardTop = 20;

        card.style.top = cardTop + 'px';
        card.style.left = cardLeft + 'px';
    }
    
    tourRaf = requestAnimationFrame(trackTour);
}

function generateId() {
    return 'cmd_' + Date.now() + Math.floor(Math.random() * 1000);
}

// Commands logic
document.getElementById('add-cmd-btn').addEventListener('click', () => {
    currentEditingCmdId = generateId();
    document.getElementById('cmd-key').value = '';
    document.getElementById('cmd-list-name').value = '';
    document.getElementById('cmd-desc').value = '';
    document.getElementById('cmd-aliases').value = '';
    if (cmdEditor) cmdEditor.setValue('-- code here');

    document.getElementById('cmd-modal-title').textContent = 'Add Command';
    document.getElementById('cmd-modal').classList.remove('hidden');
});

window.editCommand = function (id) {
    let cmd = pluginData.commands.find(c => c.id === id);
    if (!cmd) return;

    currentEditingCmdId = id;
    document.getElementById('cmd-key').value = cmd.key;
    document.getElementById('cmd-list-name').value = cmd.listName;
    document.getElementById('cmd-desc').value = cmd.desc;
    document.getElementById('cmd-aliases').value = cmd.aliases.join(', ');
    if (cmdEditor) cmdEditor.setValue(cmd.code);

    document.getElementById('cmd-modal-title').textContent = 'Edit Command';
    document.getElementById('cmd-modal').classList.remove('hidden');
};

window.gotoCommand = function (key) {
    if (!previewEditor) return;
    const model = previewEditor.getModel();
    const content = model.getValue();
    
    // Pattern used in generateLua: ["key"] = {
    const searchStr = `["${key}"] = {`;
    const index = content.indexOf(searchStr);
    
    if (index !== -1) {
        const pos = model.getPositionAt(index);
        previewEditor.revealLineInCenter(pos.lineNumber);
        previewEditor.setSelection({
            startLineNumber: pos.lineNumber,
            startColumn: pos.column,
            endLineNumber: pos.lineNumber,
            endColumn: pos.column + searchStr.length
        });
        
        // Brief visual highlight
        const decorations = previewEditor.deltaDecorations([], [
            {
                range: new monaco.Range(pos.lineNumber, 1, pos.lineNumber, model.getLineMaxColumn(pos.lineNumber)),
                options: {
                    isWholeLine: true,
                    className: 'editor-goto-highlight'
                }
            }
        ]);
        setTimeout(() => {
            previewEditor.deltaDecorations(decorations, []);
        }, 2000);
    } else {
        // Fallback search if manual edits changed the structure
        const match = model.findNextMatch(key, { lineNumber: 1, column: 1 }, false, false, null, true);
        if (match) {
            previewEditor.revealLineInCenter(match.range.startLineNumber);
            previewEditor.setSelection(match.range);
        }
    }
};

window.deleteCommand = function (id) {
    if (confirm('Are you sure you want to delete this command?')) {
        pluginData.commands = pluginData.commands.filter(c => c.id !== id);
        renderCommands();
        updatePreview();
    }
};

document.getElementById('cmd-modal-close').addEventListener('click', () => {
    const modal = document.getElementById('cmd-modal');
    modal.classList.add('hidden');
    // modal.classList.remove('expanded'); // Optional if we want it to reset
});

const expandBtn = document.getElementById('cmd-modal-expand');
if (expandBtn) {
    expandBtn.addEventListener('click', () => {
        const modal = document.getElementById('cmd-modal');
        modal.classList.toggle('expanded');
        const resizeEditor = () => { if (cmdEditor) cmdEditor.layout(); };
        resizeEditor();
        setTimeout(resizeEditor, 100);
        setTimeout(resizeEditor, 300);
    });
}

document.getElementById('cancel-cmd-btn').addEventListener('click', () => {
    document.getElementById('cmd-modal').classList.add('hidden');
});

document.getElementById('save-cmd-btn').addEventListener('click', () => {
    let key = document.getElementById('cmd-key').value || 'cmd';
    let listName = document.getElementById('cmd-list-name').value || 'cmd';
    let desc = document.getElementById('cmd-desc').value || 'No description';
    let aliasesRaw = document.getElementById('cmd-aliases').value;
    let aliases = aliasesRaw.split(',').map(s => s.trim()).filter(x => x);
    let code = cmdEditor ? cmdEditor.getValue() : '-- code here';

    let existingIndex = pluginData.commands.findIndex(c => c.id === currentEditingCmdId);
    let newCmd = {
        id: currentEditingCmdId,
        key: key,
        listName: listName,
        desc: desc,
        aliases: aliases,
        code: code
    };

    if (existingIndex >= 0) {
        pluginData.commands[existingIndex] = newCmd;
    } else {
        pluginData.commands.push(newCmd);
    }

    document.getElementById('cmd-modal').classList.add('hidden');
    renderCommands();
    updatePreview();
});

// Download
document.getElementById('download-btn').addEventListener('click', () => {
    let luaCode = previewEditor ? previewEditor.getValue() : generateLua();
    
    // Final enforcement of the signature on export
    const signature = "MADE WITH IY PLUGIN MAKER";
    if (!luaCode.includes(signature)) {
        const header = "--------------------------------------------------------------------------------\n" +
                       "-- MADE WITH IY PLUGIN MAKER (https://iyplugins.pages.dev/maker)\n" +
                       "-- This plugin was generated automatically using IY Plugin Maker.\n" +
                       "--------------------------------------------------------------------------------\n\n";
        luaCode = header + luaCode;
    }

    const blob = new Blob([luaCode], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    let safeName = pluginData.name.replace(/[^a-zA-Z0-9_-]/g, '') || 'plugin';
    a.download = safeName + '.iy';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
});

// Drag and drop / Upload File overrides
const dropZone = document.getElementById('drop-zone');
const importArea = document.getElementById('import-area');

if (importArea) {
    importArea.addEventListener('click', () => {
        document.getElementById('upload-plugin-file').click();
    });
}

document.getElementById('upload-plugin-file').addEventListener('change', (e) => {
    if (e.target.files.length) {
        let file = e.target.files[0];
        if (!file.name.endsWith('.iy')) {
            alert('Please select a valid .iy plugin file.');
            e.target.value = '';
            return;
        }

        let reader = new FileReader();
        reader.onload = (evt) => {
            parseLuaToForm(evt.target.result);
        };
        reader.readAsText(file);
        e.target.value = '';
    }
});

const onDragOver = (e) => {
    e.preventDefault();
    dropZone?.classList.remove('hidden');
};
document.addEventListener('dragover', onDragOver);

dropZone?.addEventListener('dragleave', (e) => {
    e.preventDefault();
    dropZone.classList.add('hidden');
});

dropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropZone.classList.add('hidden');

    if (e.dataTransfer.files.length) {
        let file = e.dataTransfer.files[0];
        if (!file.name.endsWith('.iy')) {
            alert('Please drop a valid .iy plugin file.');
            return;
        }

        let reader = new FileReader();
        reader.onload = (evt) => {
            parseLuaToForm(evt.target.result);
        };
        reader.readAsText(file);
    }
});

function extractGlobalCode(text) {
    let header = "";
    let footer = "return Plugin";
    let cmdIdx = text.indexOf('["Commands"]');
    if (cmdIdx === -1) cmdIdx = text.indexOf("['Commands']");
    if (cmdIdx === -1) return {header, footer};
    
    let prefix = text.substring(0, cmdIdx);
    let match;
    let regex = /(?:local\s+)?[a-zA-Z_]\w*\s*=\s*\{/g;
    let lastIndex = -1;
    while ((match = regex.exec(prefix)) !== null) {
        lastIndex = match.index;
    }
    
    if (lastIndex !== -1) {
        header = text.substring(0, lastIndex).trim();
        
        // Strip the IY Plugin Maker signature if it exists to prevent duplication on export
        const sigBlock = "--------------------------------------------------------------------------------\n" +
                         "-- MADE WITH IY PLUGIN MAKER (https://iyplugins.pages.dev/maker)\n" +
                         "-- This plugin was generated automatically using IY Plugin Maker.\n" +
                         "--------------------------------------------------------------------------------";
        
        if (header.includes(sigBlock)) {
            header = header.replace(sigBlock, "").trim();
        }

        let depth = 0;
        let inString = false;
        let stringChar = '';
        let endIdx = -1;
        for (let i = lastIndex; i < text.length; i++) {
            let char = text[i];
            if (inString) {
                if (char === '\\') { i++; continue; }
                if (char === stringChar) { inString = false; }
                continue;
            }
            if (char === '"' || char === "'") {
                inString = true; stringChar = char; continue;
            }
            if (char === '{') depth++;
            if (char === '}') {
                depth--;
                if (depth === 0) { endIdx = i; break; }
            }
        }
        if (endIdx !== -1) {
            footer = text.substring(endIdx + 1).trim();
        }
    }
    return {header, footer};
}

function parseLuaToForm(text) {
    try {
        let globals = extractGlobalCode(text);
        pluginData.headerCode = globals.header;
        pluginData.footerCode = globals.footer;

        let nameMatch = text.match(/\["PluginName"\]\s*=\s*(["'])(.*?)\1/);
        if (nameMatch) {
            document.getElementById('plugin-name').value = nameMatch[2];
            pluginData.name = nameMatch[2];
        }

        let descMatch = text.match(/\["PluginDescription"\]\s*=\s*(["'])(.*?)\1/);
        if (descMatch) {
            document.getElementById('plugin-desc').value = descMatch[2];
            pluginData.description = descMatch[2];
        }

        pluginData.commands = [];

        let commandsStart = text.indexOf('["Commands"]');
        if (commandsStart === -1) {
            renderCommands();
            updatePreview();
            alert('Loaded plugin metadata, but no Commands block was found.');
            return;
        }

        let firstBrace = text.indexOf('{', commandsStart);
        if (firstBrace === -1) {
            renderCommands();
            updatePreview();
            return;
        }

        let commandsBody = text.substring(firstBrace + 1);

        // Safe truncation mapping using depth counting isolated to tables
        let depth = 0;
        let inString = false;
        let stringChar = '';
        let inSingleComment = false;

        for (let i = 0; i < commandsBody.length; i++) {
            let char = commandsBody[i];
            let nextChar = commandsBody[i + 1];
            let prevChar = i > 0 ? commandsBody[i - 1] : '';

            if (inSingleComment) {
                if (char === '\n') inSingleComment = false;
                continue;
            }

            if (!inString && char === '-' && nextChar === '-') {
                inSingleComment = true;
                continue;
            }

            if ((char === '"' || char === "'") && prevChar !== '\\') {
                if (!inString) {
                    inString = true;
                    stringChar = char;
                } else if (char === stringChar) {
                    inString = false;
                }
            }

            if (!inString && !inSingleComment) {
                if (char === '{') {
                    depth++;
                } else if (char === '}') {
                    depth--;
                    if (depth === -1) {
                        commandsBody = commandsBody.substring(0, i);
                        break;
                    }
                }
            }
        }

        // Extremely robust lookahead logic:
        // Finds `["key"] = {` BUT only if the inner table immediately starts with a standard command key, e.g. `["ListName"]`
        // This physically prevents it from mapping things like `["Aliases"] = {"sps"}` as independent commands!
        let cmdRegex = /\["([^"]+)"\]\s*=\s*\{(?=\s*(?:--[^\n]*\n\s*)*\[")/g;
        let match;
        let indices = [];
        while ((match = cmdRegex.exec(commandsBody)) !== null) {
            indices.push({ key: match[1], start: match.index });
        }

        for (let i = 0; i < indices.length; i++) {
            let current = indices[i];
            let next = indices[i + 1];

            let blockStr = next ? commandsBody.substring(current.start, next.start) : commandsBody.substring(current.start);

            let listNameMatch = blockStr.match(/\["ListName"\]\s*=\s*(["'])(.*?)\1/);
            let listName = listNameMatch ? listNameMatch[2] : "cmd";

            let descMatch = blockStr.match(/\["Description"\]\s*=\s*(["'])(.*?)\1/);
            let desc = descMatch ? descMatch[2] : "";

            let aliasesMatch = blockStr.match(/\["Aliases"\]\s*=\s*\{([^}]*)\}/);
            let aliases = aliasesMatch ? aliasesMatch[1].split(',').map(s => s.replace(/['"]/g, '').trim()).filter(x => x) : [];

            let code = "-- code here";
            let fnMatch = blockStr.match(/\["Function"\]\s*=\s*function\s*\([^)]*\)/);
            if (fnMatch) {
                let fnStartIdx = fnMatch.index + fnMatch[0].length;
                let fnStr = blockStr.substring(fnStartIdx);

                let lastEnd = fnStr.lastIndexOf('end');
                if (lastEnd !== -1) {
                    code = fnStr.substring(0, lastEnd);
                } else {
                    code = fnStr;
                }
            }

            let codeLines = code.split('\n');
            while (codeLines.length && codeLines[0].trim() === '') codeLines.shift();
            while (codeLines.length && codeLines[codeLines.length - 1].trim() === '') codeLines.pop();

            let minIndent = Infinity;
            for (let line of codeLines) {
                if (line.trim().length > 0) {
                    let wsMatch = line.match(/^([ \t]*)/);
                    let indent = wsMatch ? wsMatch[1].length : 0;
                    if (indent < minIndent) minIndent = indent;
                }
            }
            if (minIndent === Infinity) minIndent = 0;
            codeLines = codeLines.map(l => l.substring(minIndent));

            pluginData.commands.push({
                id: generateId(),
                key: current.key,
                listName: listName,
                desc: desc,
                aliases: aliases,
                code: codeLines.join('\n')
            });
        }

        renderCommands();
        // Force autoSync active because we successfully parsed entirely client-side
        autoSyncEnabled = true;
        document.getElementById('sync-warning').classList.add('hidden');
        updatePreview();

        if (pluginData.commands.length === 0) {
            alert('Loaded plugin metadata, but could not automatically parse commands.');
        }

    } catch (e) {
        console.error('Error parsing Lua:', e);
        alert('Failed to parse the provided .iy file correctly.');
    }
}

        cleanup = () => {
            isAborted = true;
            document.body.classList.remove('ide-mode');
            document.removeEventListener('dragover', onDragOver);
            if (previewEditor) previewEditor.dispose();
            if (cmdEditor) cmdEditor.dispose();
        };
        window.currentRouteCleanup = cleanup;
    };
})();
