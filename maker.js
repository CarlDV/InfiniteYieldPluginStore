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

function initMonaco() {
    return new Promise((resolve, reject) => {
        const loaderScript = document.createElement('script');
        loaderScript.src = `${MONACO_BASE}/vs/loader.min.js`;
        loaderScript.onload = function () {
            require.config({ paths: { 'vs': `${MONACO_BASE}/vs` } });
            require(['vs/editor/editor.main'], function () {
                resolve();
            }, function (err) {
                reject(err);
            });
        };
        loaderScript.onerror = function () {
            reject(new Error('Failed to load Monaco loader script'));
        };
        document.head.appendChild(loaderScript);
    });
}

initMonaco().then(() => {
    // Register Roblox Lua IntelliSense
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

    previewEditor = monaco.editor.create(document.getElementById('monaco-preview'), {
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

    cmdEditor = monaco.editor.create(document.getElementById('monaco-cmd-editor'), {
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
}).catch(err => {
    console.error('Monaco failed to load:', err);
    document.getElementById('monaco-preview').innerHTML = '<pre style="padding:16px;color:#ccc;font-family:monospace;">Monaco editor failed to load. Please use a local HTTP server (e.g. npx serve) instead of file://</pre>';
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

    pluginData.commands.forEach(cmd => {
        const div = document.createElement('div');
        div.className = 'cmd-item';
        div.innerHTML = `
            <div class="cmd-info">
                <h4>${cmd.listName}</h4>
                <p>Key: <code>${cmd.key}</code></p>
            </div>
            <div class="cmd-actions">
                <button class="btn btn-secondary btn-sm" onclick="editCommand('${cmd.id}')">Edit</button>
                <button class="btn btn-danger btn-sm" onclick="deleteCommand('${cmd.id}')">Delete</button>
            </div>
        `;
        list.appendChild(div);
    });
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

window.deleteCommand = function (id) {
    if (confirm('Are you sure you want to delete this command?')) {
        pluginData.commands = pluginData.commands.filter(c => c.id !== id);
        renderCommands();
        updatePreview();
    }
};

document.getElementById('cmd-modal-close').addEventListener('click', () => {
    document.getElementById('cmd-modal').classList.add('hidden');
});

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
    const luaCode = previewEditor ? previewEditor.getValue() : generateLua();
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

document.getElementById('upload-plugin-btn').addEventListener('click', () => {
    document.getElementById('upload-plugin-file').click();
});

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

document.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.remove('hidden');
});

dropZone.addEventListener('dragleave', (e) => {
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
