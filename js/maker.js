(() => {
    let cleanup = null;

    window.initMaker = function () {
        if (!document.querySelector('.maker-main')) return;
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
        let activeTabType = 'plugin';
        let activeTabCmdId = null;

        const tourSteps = [
            {
                target: '.maker-header',
                title: 'Welcome to Plugin Maker!',
                desc: 'Create, customize, and export Infinite Yield plugins visually without writing the boilerplate code yourself.'
            },
            {
                target: '#import-area',
                title: 'Import Plugins',
                desc: 'Have an existing .iy plugin? Drag-and-drop it here or click to upload and edit it immediately.'
            },
            {
                target: '.form-group',
                title: 'Configure Plugin Info',
                desc: 'Set your plugin\'s name and description. These values define the signature and name of the exported script.'
            },
            {
                target: '#ide-mode-toggle',
                title: 'Full Web IDE Mode',
                desc: 'Toggle this button to swap into a full-screen, code-centric workspace optimized for larger viewports.'
            },
            {
                target: '.commands-header',
                title: 'Manage Custom Commands',
                desc: 'Filter commands with the search bar, copy command lists, or add as many custom commands as you want.'
            },
            {
                target: '#add-cmd-btn',
                title: 'Launch Command Editor',
                desc: 'Let\'s open the command details workspace where you define metadata and script logic.'
            },
            {
                target: '.modal-fields-sidebar',
                title: 'Define Command Details',
                desc: 'Set the command\'s internal key, usage format (including arguments like [arg]), description, and optional comma-separated aliases.',
                requiresModal: true
            },
            {
                target: '#monaco-cmd-editor',
                title: 'Write Lua Logic',
                desc: 'Write your custom Lua logic here. You have access to "args" for input values and "speaker" for the player running the command.',
                requiresModal: true
            },
            {
                target: '#save-cmd-btn',
                title: 'Save & Update',
                desc: 'Click Save to record your command. The modal will close, and your command will instantly update in the live preview.',
                requiresModal: true
            },
            {
                target: '.maker-preview-section',
                title: 'Real-time Code Preview',
                desc: 'Watch your Lua plugin code generate automatically in real-time. You can manually edit the code here or expand the view.'
            },
            {
                target: '#download-btn',
                title: 'Export Plugin',
                desc: 'Once you are happy, click Download to save the compiled .iy plugin file directly into your exploit\'s workspace folder.'
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

        function setupEditorListeners() {
            const nameInput = document.getElementById('plugin-name');
            const descInput = document.getElementById('plugin-desc');

            if (nameInput) {
                nameInput.addEventListener('input', () => {
                    pluginData.name = nameInput.value;
                    updatePreview();
                });
            }

            if (descInput) {
                descInput.addEventListener('input', () => {
                    pluginData.description = descInput.value;
                    updatePreview();
                });
            }

            const headersInput = document.getElementById('plugin-headers');
            if (headersInput) {
                headersInput.addEventListener('input', () => {
                    pluginData.headerCode = headersInput.value;
                    updatePreview();
                });
            }
        }

        // Call listeners setup
        setTimeout(setupEditorListeners, 100);

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
                if (isProgrammaticUpdate) return;

                const val = previewEditor.getValue();
                if (activeTabType === 'plugin') {
                    if (autoSyncEnabled) {
                        autoSyncEnabled = false;
                        document.getElementById('sync-warning').classList.remove('hidden');
                    }
                } else if (activeTabType === 'globals') {
                    pluginData.headerCode = val;
                    const headersInput = document.getElementById('plugin-headers');
                    if (headersInput) headersInput.value = val;
                } else if (activeTabType === 'command') {
                    let cmd = pluginData.commands.find(c => c.id === activeTabCmdId);
                    if (cmd) {
                        cmd.code = val;
                    }
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

            // Enable Alt+Z to toggle word wrap
            const enableAltZWordWrap = (editor) => {
                editor.addCommand(monaco.KeyMod.Alt | monaco.KeyCode.KeyZ, () => {
                    const currentWrap = editor.getOption(monaco.editor.EditorOption.wordWrap);
                    editor.updateOptions({ wordWrap: currentWrap === 'on' ? 'off' : 'on' });
                });
            };
            enableAltZWordWrap(previewEditor);
            enableAltZWordWrap(cmdEditor);

            // Expand preview button listener
            const expandPreviewBtn = document.getElementById('expand-preview-btn');
            if (expandPreviewBtn) {
                expandPreviewBtn.addEventListener('click', () => {
                    const container = document.querySelector('.maker-container');
                    container.classList.toggle('preview-expanded');

                    const isExpanded = container.classList.contains('preview-expanded');
                    expandPreviewBtn.innerHTML = isExpanded
                        ? `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 14h6v6M20 10h-6V4M14 10l7-7M10 14l-7 7"/></svg> Collapse`
                        : `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg> Expand`;

                    if (previewEditor) {
                        previewEditor.layout();
                        setTimeout(() => previewEditor.layout(), 100);
                        setTimeout(() => previewEditor.layout(), 300);
                    }
                });
            }

            // IDE mode additional controls
            const ideFormatBtn = document.getElementById('ide-format-btn');
            if (ideFormatBtn) {
                ideFormatBtn.addEventListener('click', async () => {
                    if (previewEditor) {
                        const currentVal = previewEditor.getValue();
                        const formatted = formatLuaCode(currentVal);

                        isProgrammaticUpdate = true;
                        previewEditor.setValue(formatted);
                        isProgrammaticUpdate = false;

                        // Also trigger state update if it was a command or globals tab
                        if (activeTabType === 'globals') {
                            pluginData.headerCode = formatted;
                            const headersInput = document.getElementById('plugin-headers');
                            if (headersInput) headersInput.value = formatted;
                            updatePreview();
                        } else if (activeTabType === 'command') {
                            let cmd = pluginData.commands.find(c => c.id === activeTabCmdId);
                            if (cmd) {
                                cmd.code = formatted;
                            }
                            updatePreview();
                        } else if (activeTabType === 'plugin') {
                            // Can't save back fully generated preview since it includes wrapper code, 
                            // so we show a brief visual cue or warning
                            await Dialog.alert('Formatted full plugin source preview. Note: changes here will be overwritten on the next state sync.');
                        }
                    }
                });
            }
            const ideWrapBtn = document.getElementById('ide-wrap-btn');
            if (ideWrapBtn) {
                let previewWordWrap = false;
                ideWrapBtn.addEventListener('click', () => {
                    previewWordWrap = !previewWordWrap;
                    if (previewEditor) {
                        previewEditor.updateOptions({ wordWrap: previewWordWrap ? 'on' : 'off' });
                    }
                    ideWrapBtn.classList.toggle('active', previewWordWrap);
                });
            }

            const ideMinimapBtn = document.getElementById('ide-minimap-btn');
            if (ideMinimapBtn) {
                let previewMinimap = false;
                ideMinimapBtn.addEventListener('click', () => {
                    previewMinimap = !previewMinimap;
                    if (previewEditor) {
                        previewEditor.updateOptions({ minimap: { enabled: previewMinimap } });
                    }
                    ideMinimapBtn.classList.toggle('active', previewMinimap);
                });
            }

            const ideCopyBtn = document.getElementById('ide-copy-btn');
            if (ideCopyBtn) {
                ideCopyBtn.addEventListener('click', () => {
                    let code = previewEditor ? previewEditor.getValue() : generateLua();
                    navigator.clipboard.writeText(code).then(() => {
                        const originalHTML = ideCopyBtn.innerHTML;
                        ideCopyBtn.innerHTML = `✓ Copied!`;
                        setTimeout(() => {
                            ideCopyBtn.innerHTML = originalHTML;
                        }, 2000);
                    });
                });
            }

            const ideDownloadBtn = document.getElementById('ide-download-btn');
            if (ideDownloadBtn) {
                ideDownloadBtn.addEventListener('click', () => {
                    const downloadBtn = document.getElementById('download-btn');
                    if (downloadBtn) downloadBtn.click();
                });
            }

            const tabScrollContainer = document.getElementById('ide-tab-bar');
            if (tabScrollContainer) {
                tabScrollContainer.addEventListener('wheel', (e) => {
                    if (e.deltaY !== 0) {
                        e.preventDefault();
                        tabScrollContainer.scrollLeft += e.deltaY;
                    }
                });
            }

            document.querySelectorAll('.sidebar-collapsible-trigger').forEach(trigger => {
                trigger.addEventListener('click', () => {
                    trigger.parentElement.classList.toggle('active');
                });
            });

            // Attach search listener
            const cmdSearch = document.getElementById('cmd-search');
            if (cmdSearch) {
                cmdSearch.addEventListener('input', (e) => {
                    cmdSearchQuery = e.target.value.toLowerCase().trim();
                    renderCommands();
                });
            }

            // Attach tour listeners
            const startTourBtn = document.getElementById('start-tour-btn');
            const tourNextBtn = document.getElementById('tour-next');
            const tourBackBtn = document.getElementById('tour-back');
            const tourSkipBtn = document.getElementById('tour-skip');

            if (startTourBtn) startTourBtn.addEventListener('click', startTour);
            if (tourNextBtn) tourNextBtn.addEventListener('click', nextTourStep);
            if (tourBackBtn) tourBackBtn.addEventListener('click', prevTourStep);
            if (tourSkipBtn) tourSkipBtn.addEventListener('click', endTour);

            // Store Integration Logic
            let allStorePlugins = [];
            const storeModal = document.getElementById('store-modal');
            const storePluginsList = document.getElementById('store-plugins-list');
            const storeSearch = document.getElementById('store-search-input');

            async function fetchStorePlugins() {
                if (allStorePlugins.length > 0) return;
                try {
                    // Use relative path to ensure fetching works across different hosting routes
                    const resp = await fetch('data/plugins.json');
                    if (!resp.ok) throw new Error('Network response was not ok');
                    const data = await resp.json();
                    allStorePlugins = (data.plugins || []).sort((a, b) => {
                        const dateA = new Date(a.date || 0);
                        const dateB = new Date(b.date || 0);
                        return dateB - dateA;
                    });
                    const counter = document.getElementById('plugin-count');
                    if (counter) counter.textContent = `${allStorePlugins.length} plugins`;
                    renderStorePlugins();
                } catch (e) {
                    console.error('Failed to fetch plugins', e);
                    if (storePluginsList) {
                        storePluginsList.innerHTML = `<div class="loading-state">Failed to load plugins. Database file not found or connection issue. <br><small>${e.message}</small></div>`;
                    }
                }
            }

            // Helper functions for rendering
            function esc(str) {
                if (!str) return '';
                return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }

            function fmtDate(dateStr) {
                if (!dateStr) return 'Unknown date';
                const date = new Date(dateStr);
                if (isNaN(date.getTime())) return 'Unknown date';
                return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
            }

            let storeLimit = 24;

            function renderStorePlugins(filter = '', limit = storeLimit) {
                if (!storePluginsList) return;
                storeLimit = limit;
                const query = filter.toLowerCase();
                const filtered = allStorePlugins.filter(p =>
                    p.name.toLowerCase().includes(query) ||
                    (p.author && (typeof p.author === 'string' ? p.author : p.author.name).toLowerCase().includes(query))
                );

                if (filtered.length === 0) {
                    storePluginsList.innerHTML = '<div class="loading-state">No plugins found matching your search.</div>';
                    return;
                }

                const paginated = filtered.slice(0, limit);

                let html = paginated.map(p => {
                    const author = p.author && typeof p.author === 'object' ? p.author : { name: p.author || 'Unknown' };
                    const authorName = author.name;
                    const avatarHTML = author.avatar
                        ? `<img src="${author.avatar}" class="card-avatar" alt="">`
                        : `<div class="card-avatar-ph">${esc(authorName[0].toUpperCase())}</div>`;

                    let tags = '';
                    if (p.files && p.files.length > 0) tags += '<span class="tag tag-file">.iy file</span>';
                    if (p.code_blocks && p.code_blocks.length > 0) tags += '<span class="tag tag-code">Source</span>';

                    return `
                <div class="card" onclick="importFromStore('${p.id}')">
                    <div class="card-header">
                        ${avatarHTML}
                        <div class="card-info">
                            <div class="card-name">${esc(p.name || 'Untitled')}</div>
                            <div class="card-author">by ${esc(authorName)}</div>
                        </div>
                        <div class="card-date">${fmtDate(p.date)}</div>
                    </div>
                    <div class="card-desc">${esc(p.description || 'No description provided.')}</div>
                    <div class="card-footer">
                        <div class="card-tags">${tags}</div>
                        <div class="remix-badge">REMIX</div>
                    </div>
                </div>
            `;
                }).join('');

                if (filtered.length > limit) {
                    html += `
                <div class="load-more-container" style="grid-column: 1/-1; display:flex; justify-content:center; padding: 20px 0;">
                    <button class="btn btn-secondary" id="load-more-store-btn" onclick="window.loadMoreStore()">Load More Plugins</button>
                </div>
            `;
                }

                storePluginsList.innerHTML = html;
            }

            window.loadMoreStore = function () {
                renderStorePlugins(storeSearch ? storeSearch.value : '', storeLimit + 24);
            };

            window.importFromStore = async function (id) {
                const plugin = allStorePlugins.find(p => p.id === id);
                if (!plugin) return;

                if (await Dialog.confirm(`Are you sure you want to remix "${plugin.name}"? This will overwrite your current project.`)) {
                    // The source code is inside the first file object for these plugins
                    let sourceCode = '';
                    if (plugin.files && plugin.files.length > 0) {
                        try {
                            const url = `https://iyplugins.pages.dev/plugins/${plugin.id}/${plugin.files[0].filename}`;
                            sourceCode = await fetch(url).then(res => res.text());
                        } catch (e) {
                            await Dialog.alert('Failed to fetch source: ' + e.message);
                            return;
                        }
                    } else if (plugin.code) {
                        sourceCode = plugin.code;
                    }

                    if (sourceCode) {
                        parseLuaToForm(sourceCode);
                        if (storeModal) storeModal.classList.add('hidden');
                    } else {
                        await Dialog.alert('Could not find source code for this plugin.');
                    }
                }
            };

            const browseStoreBtn = document.getElementById('browse-store-btn');
            if (browseStoreBtn) {
                browseStoreBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopImmediatePropagation();

                    const modal = document.getElementById('store-modal');
                    if (modal) {
                        modal.classList.remove('hidden');
                        fetchStorePlugins();
                    } else {
                        console.error('Maker: Store modal not found in DOM.');
                    }
                });
            }

            const storeModalClose = document.getElementById('store-modal-close');
            if (storeModalClose) {
                storeModalClose.addEventListener('click', () => {
                    if (storeModal) storeModal.classList.add('hidden');
                });
            }

            if (storeSearch) {
                storeSearch.addEventListener('input', (e) => {
                    renderStorePlugins(e.target.value);
                });
            }

            // Close modal on escape
            window.addEventListener('keydown', (e) => {
                if (e.key === 'Escape' && storeModal && !storeModal.classList.contains('hidden')) {
                    storeModal.classList.add('hidden');
                }
            });

            // Attach IDE mode listener
            const ideToggle = document.getElementById('ide-mode-toggle');
            if (ideToggle) {
                ideToggle.addEventListener('click', () => {
                    const entering = document.body.classList.toggle('ide-mode');

                    if (entering) {
                        switchIDETab('plugin');
                    }

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

            const ideExitBtn = document.getElementById('ide-exit-btn');
            if (ideExitBtn && ideToggle) {
                ideExitBtn.addEventListener('click', () => {
                    ideToggle.click();
                });
            }

            // Handle window resizing
            let resizeTimer;
            window.addEventListener('resize', () => {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(() => {
                    // Disable IDE mode on mobile/tablet viewports
                    if (window.innerWidth <= 900 && document.body.classList.contains('ide-mode')) {
                        const ideToggle = document.getElementById('ide-mode-toggle');
                        if (ideToggle) ideToggle.click();
                    }
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

        // More listeners are handled via setupEditorListeners or deferred attachment after element presence check
        const resumeSyncBtn = document.getElementById('resume-sync-btn');
        if (resumeSyncBtn) {
            resumeSyncBtn.addEventListener('click', () => {
                autoSyncEnabled = true;
                const syncWarning = document.getElementById('sync-warning');
                if (syncWarning) syncWarning.classList.add('hidden');
                updatePreview();
            });
        }

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
            if (previewEditor) {
                if (activeTabType === 'plugin' && autoSyncEnabled) {
                    isProgrammaticUpdate = true;
                    previewEditor.setValue(generateLua());
                    isProgrammaticUpdate = false;
                }
            }
            renderIDETabs();
        }

        function renderIDETabs() {
            const tabBar = document.getElementById('ide-tab-bar');
            if (!tabBar) return;

            let html = '';

            // Main Plugin tab
            const safeName = (pluginData.name || '').replace(/[^a-zA-Z0-9_-]/g, '') || 'plugin';
            const mainActive = activeTabType === 'plugin' ? 'active' : '';
            html += `
                <div class="ide-tab ${mainActive}" data-type="plugin" title="Main plugin bundle (Everything compiled)">
                    <svg class="lua-icon" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px; pointer-events: none;">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                    </svg>
                    <span>${safeName}.iy</span>
                </div>
            `;

            // Globals tab
            const globalsActive = activeTabType === 'globals' ? 'active' : '';
            html += `
                <div class="ide-tab ${globalsActive}" data-type="globals" title="Global Variables & Helper scripts">
                    <span style="font-weight: bold; color: #f59e0b; margin-right: 4px; pointer-events: none;">⚙</span>
                    <span>globals.lua</span>
                </div>
            `;

            for (let cmd of pluginData.commands) {
                const cmdActive = (activeTabType === 'command' && activeTabCmdId === cmd.id) ? 'active' : '';
                html += `
                    <div class="ide-tab ${cmdActive}" data-type="command" data-cmd-id="${cmd.id}" title="Code logic for command: ${cmd.key}">
                        <span style="color: #60a5fa; margin-right: 4px; pointer-events: none;">{}</span>
                        <span>${cmd.key || 'untitled'}.lua</span>
                    </div>
                `;
            }

            tabBar.innerHTML = html;

            const activeTab = tabBar.querySelector('.ide-tab.active');
            if (activeTab) {
                activeTab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' });
            }

            tabBar.querySelectorAll('.ide-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    const type = tab.getAttribute('data-type');
                    const cmdId = tab.getAttribute('data-cmd-id');
                    switchIDETab(type, cmdId);
                });
            });
        }

        function switchIDETab(type, cmdId) {
            // Save current code to state before switching
            if (previewEditor) {
                const val = previewEditor.getValue();
                if (activeTabType === 'globals') {
                    pluginData.headerCode = val;
                    const headersInput = document.getElementById('plugin-headers');
                    if (headersInput) headersInput.value = val;
                } else if (activeTabType === 'command') {
                    let cmd = pluginData.commands.find(c => c.id === activeTabCmdId);
                    if (cmd) {
                        cmd.code = val;
                    }
                }
            }

            activeTabType = type;
            activeTabCmdId = cmdId;

            // Switch Monaco model value
            if (previewEditor) {
                isProgrammaticUpdate = true;
                if (type === 'plugin') {
                    previewEditor.setValue(generateLua());
                    previewEditor.updateOptions({ readOnly: false });
                } else if (type === 'globals') {
                    previewEditor.setValue(pluginData.headerCode || '');
                    previewEditor.updateOptions({ readOnly: false });
                } else if (type === 'command') {
                    let cmd = pluginData.commands.find(c => c.id === cmdId);
                    previewEditor.setValue(cmd ? cmd.code : '');
                    previewEditor.updateOptions({ readOnly: false });
                }
                isProgrammaticUpdate = false;
            }

            renderIDETabs();
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
                div.setAttribute('title', `${cmd.listName} - ${cmd.desc}`);
                div.innerHTML = `
            <div class="cmd-info">
                <h4>${cmd.listName}</h4>
                <p>Key: <code>${cmd.key}</code></p>
            </div>
            <div class="cmd-actions">
                <button class="btn btn-secondary btn-sm btn-icon" onclick="copySingleCommand('${cmd.id}', this)" title="Copy Description">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                        <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                    </svg>
                </button>
                <button class="btn btn-secondary btn-sm btn-icon" onclick="gotoCommand('${escLua(cmd.key)}')" title="Go to Code">
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

        window.copySingleCommand = function (id, btn) {
            let cmd = pluginData.commands.find(c => c.id === id);
            if (!cmd) return;

            const text = `${cmd.listName} - ${cmd.desc}`;
            navigator.clipboard.writeText(text).then(() => {
                const originalHTML = btn.innerHTML;
                btn.classList.add('btn-success');
                btn.innerHTML = `
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                `;
                setTimeout(() => {
                    btn.innerHTML = originalHTML;
                    btn.classList.remove('btn-success');
                }, 2000);
            });
        };

        // --- Tour Logic ---
        let tourRaf = null;

        function startTour() {
            // Exit IDE Mode to align spotlights correctly
            if (document.body.classList.contains('ide-mode')) {
                const ideToggle = document.getElementById('ide-mode-toggle');
                if (ideToggle) ideToggle.click();
            }

            // Exit expanded preview mode to align spotlights correctly
            const container = document.querySelector('.maker-container');
            if (container && container.classList.contains('preview-expanded')) {
                const expandBtn = document.getElementById('expand-preview-btn');
                if (expandBtn) expandBtn.click();
            }

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
        const copyCmdsBtn = document.getElementById('copy-cmds-btn');
        if (copyCmdsBtn) {
            copyCmdsBtn.addEventListener('click', async () => {
                if (pluginData.commands.length === 0) {
                    await Dialog.alert('No commands to copy!');
                    return;
                }
                const listText = pluginData.commands
                    .map(cmd => `${cmd.listName} - ${cmd.desc}`)
                    .join('\n');

                navigator.clipboard.writeText(listText).then(() => {
                    const originalHTML = copyCmdsBtn.innerHTML;
                    copyCmdsBtn.classList.add('btn-success');
                    copyCmdsBtn.innerHTML = `
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                    `;
                    setTimeout(() => {
                        copyCmdsBtn.innerHTML = originalHTML;
                        copyCmdsBtn.classList.remove('btn-success');
                    }, 2000);
                }).catch(async err => {
                    console.error('Failed to copy: ', err);
                    await Dialog.alert('Failed to copy to clipboard.');
                });
            });
        }

        const addCmdBtn = document.getElementById('add-cmd-btn');
        if (addCmdBtn) {
            addCmdBtn.addEventListener('click', () => {
                currentEditingCmdId = generateId();
                const keyInput = document.getElementById('cmd-key');
                const nameInput = document.getElementById('cmd-list-name');
                const descInput = document.getElementById('cmd-desc');
                const aliasesInput = document.getElementById('cmd-aliases');
                const modalTitle = document.getElementById('cmd-modal-title');
                const modal = document.getElementById('cmd-modal');
                const validationError = document.getElementById('cmd-validation-error');

                if (keyInput) keyInput.value = '';
                if (nameInput) nameInput.value = '';
                if (descInput) descInput.value = '';
                if (aliasesInput) aliasesInput.value = '';
                if (cmdEditor) cmdEditor.setValue('-- code here');
                if (validationError) validationError.classList.add('hidden');

                if (modalTitle) modalTitle.textContent = 'Add Command';
                if (modal) modal.classList.remove('hidden');
            });
        }

        window.editCommand = function (id) {
            let cmd = pluginData.commands.find(c => c.id === id);
            if (!cmd) return;

            currentEditingCmdId = id;
            const keyInput = document.getElementById('cmd-key');
            const nameInput = document.getElementById('cmd-list-name');
            const descInput = document.getElementById('cmd-desc');
            const aliasesInput = document.getElementById('cmd-aliases');
            const modalTitle = document.getElementById('cmd-modal-title');
            const modal = document.getElementById('cmd-modal');
            const validationError = document.getElementById('cmd-validation-error');

            if (keyInput) keyInput.value = cmd.key;
            if (nameInput) nameInput.value = cmd.listName;
            if (descInput) descInput.value = cmd.desc;
            if (aliasesInput) aliasesInput.value = cmd.aliases.join(', ');
            if (cmdEditor) cmdEditor.setValue(cmd.code);
            if (validationError) validationError.classList.add('hidden');

            if (modalTitle) modalTitle.textContent = 'Edit Command';
            if (modal) modal.classList.remove('hidden');
        };

        window.gotoCommand = function (key) {
            const cmd = pluginData.commands.find(c => c.key === key);
            if (document.body.classList.contains('ide-mode') && cmd) {
                switchIDETab('command', cmd.id);
                return;
            }
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

        window.deleteCommand = async function (id) {
            if (await Dialog.confirm('Are you sure you want to delete this command?')) {
                pluginData.commands = pluginData.commands.filter(c => c.id !== id);
                if (activeTabType === 'command' && activeTabCmdId === id) {
                    switchIDETab('plugin');
                }
                renderCommands();
                updatePreview();
            }
        };

        const cmdModalClose = document.getElementById('cmd-modal-close');
        if (cmdModalClose) {
            cmdModalClose.addEventListener('click', () => {
                const modal = document.getElementById('cmd-modal');
                if (modal) modal.classList.add('hidden');
            });
        }

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

        const cancelCmdBtn = document.getElementById('cancel-cmd-btn');
        if (cancelCmdBtn) {
            cancelCmdBtn.addEventListener('click', () => {
                const modal = document.getElementById('cmd-modal');
                if (modal) modal.classList.add('hidden');
            });
        }

        // Clear validation error when user types in key input
        const keyInput = document.getElementById('cmd-key');
        if (keyInput) {
            keyInput.addEventListener('input', () => {
                const validationError = document.getElementById('cmd-validation-error');
                if (validationError) validationError.classList.add('hidden');
            });
        }

        const saveCmdBtn = document.getElementById('save-cmd-btn');
        if (saveCmdBtn) {
            saveCmdBtn.addEventListener('click', () => {
                const keyInput = document.getElementById('cmd-key');
                const nameInput = document.getElementById('cmd-list-name');
                const descInput = document.getElementById('cmd-desc');
                const aliasesInput = document.getElementById('cmd-aliases');

                let key = (keyInput ? keyInput.value : '').trim() || 'cmd';
                let listName = (nameInput ? nameInput.value : '') || 'cmd';
                let desc = (descInput ? descInput.value : '') || 'No description';
                let aliasesRaw = aliasesInput ? aliasesInput.value : '';
                let aliases = aliasesRaw.split(',').map(s => s.trim()).filter(x => x);
                let code = cmdEditor ? cmdEditor.getValue() : '-- code here';

                // Check duplicate command key name
                const isDuplicate = pluginData.commands.some(c => c.id !== currentEditingCmdId && c.key.toLowerCase().trim() === key.toLowerCase());
                if (isDuplicate) {
                    const validationError = document.getElementById('cmd-validation-error');
                    if (validationError) {
                        validationError.classList.remove('hidden');
                        validationError.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                    }
                    return;
                }

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

                const modal = document.getElementById('cmd-modal');
                if (modal) modal.classList.add('hidden');
                renderCommands();
                updatePreview();
            });
        }

        // Download
        const downloadBtn = document.getElementById('download-btn');
        if (downloadBtn) {
            downloadBtn.addEventListener('click', () => {
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
        }

        // Drag and drop / Upload File overrides
        const dropZone = document.getElementById('drop-zone');
        const importArea = document.getElementById('import-area');

        if (importArea) {
            importArea.addEventListener('click', () => {
                document.getElementById('upload-plugin-file').click();
            });
        }

        const uploadInput = document.getElementById('upload-plugin-file');
        if (uploadInput) {
            uploadInput.addEventListener('change', async (e) => {
                if (e.target.files.length) {
                    let file = e.target.files[0];
                    if (!file.name.endsWith('.iy') && !file.name.endsWith('.lua')) {
                        await Dialog.alert('Please select a valid .iy or .lua plugin file.');
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
        }

        const onDragOver = (e) => {
            e.preventDefault();
            dropZone?.classList.remove('hidden');
        };
        document.addEventListener('dragover', onDragOver);

        if (dropZone) {
            dropZone.addEventListener('dragleave', (e) => {
                e.preventDefault();
                dropZone.classList.add('hidden');
            });
        }

        if (dropZone) {
            dropZone.addEventListener('drop', async (e) => {
                e.preventDefault();
                dropZone.classList.add('hidden');

                if (e.dataTransfer.files.length) {
                    let file = e.dataTransfer.files[0];
                    if (!file.name.endsWith('.iy') && !file.name.endsWith('.lua')) {
                        await Dialog.alert('Please drop a valid .iy or .lua plugin file.');
                        return;
                    }

                    let reader = new FileReader();
                    reader.onload = (evt) => {
                        parseLuaToForm(evt.target.result);
                    };
                    reader.readAsText(file);
                }
            });
        }

        function extractGlobalCode(text) {
            let header = "";
            let footer = "return Plugin";
            let commandsMatch = text.match(/\[(["'])Commands\1\]/);
            let cmdIdx = commandsMatch ? commandsMatch.index : -1;
            if (cmdIdx === -1) return { header, footer };

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
            return { header, footer };
        }

        async function parseLuaToForm(text) {
            try {
                let globals = extractGlobalCode(text);
                pluginData.headerCode = globals.header;
                pluginData.footerCode = globals.footer;

                const headersInput = document.getElementById('plugin-headers');
                if (headersInput) headersInput.value = globals.header || '';

                let nameMatch = text.match(/\[(["'])PluginName\1\]\s*=\s*(["'])(.*?)\2/);
                if (nameMatch) {
                    const nameInput = document.getElementById('plugin-name');
                    if (nameInput) nameInput.value = nameMatch[3];
                    pluginData.name = nameMatch[3];
                }

                let descMatch = text.match(/\[(["'])PluginDescription\1\]\s*=\s*(["'])(.*?)\2/);
                if (descMatch) {
                    const descInput = document.getElementById('plugin-desc');
                    if (descInput) descInput.value = descMatch[3];
                    pluginData.description = descMatch[3];
                }

                pluginData.commands = [];

                let commandsMatch = text.match(/\[(["'])Commands\1\]/);
                let commandsStart = commandsMatch ? commandsMatch.index : -1;
                if (commandsStart === -1) {
                    // Detect Remote Loaders (loadstring(game:HttpGet(...)))
                    let loaderRegex = /loadstring\s*\(\s*game\s*:\s*HttpGet\s*\(\s*\(?\s*(["'])(.*?)\1\s*\)?(?:\s*,\s*[^)]+)?\s*\)\s*\)\s*\(\s*\)/i;
                    let loaderMatch = text.match(loaderRegex);
                    if (loaderMatch) {
                        let url = loaderMatch[2];
                        let loaderUI = document.getElementById('loader-ui');
                        let urlPreview = document.getElementById('loader-url-preview');
                        if (loaderUI && urlPreview) {
                            urlPreview.textContent = url.length > 50 ? url.substring(0, 47) + '...' : url;
                            loaderUI.classList.add('active');

                            const dismissBtn = document.getElementById('loader-ui-dismiss');
                            if (dismissBtn) {
                                dismissBtn.onclick = () => {
                                    loaderUI.classList.remove('active');
                                };
                            }

                            const fetchBtn = document.getElementById('loader-ui-fetch');
                            if (fetchBtn) {
                                fetchBtn.onclick = async () => {
                                    fetchBtn.disabled = true;
                                    fetchBtn.innerHTML = '<span class="loader-shimmer">Fetching...</span>';
                                    loaderUI.classList.add('loader-shimmer');
                                    try {
                                        const resp = await fetch(url);
                                        if (!resp.ok) throw new Error('Fetch failed');
                                        const remoteCode = await resp.text();
                                        loaderUI.classList.remove('active', 'loader-shimmer');
                                        parseLuaToForm(remoteCode);
                                    } catch (e) {
                                        await Dialog.alert('Failed to fetch source: ' + e.message);
                                        fetchBtn.textContent = 'Fetch & Edit';
                                        fetchBtn.disabled = false;
                                        loaderUI.classList.remove('loader-shimmer');
                                    }
                                };
                            }
                        }
                    } else {
                        renderCommands();
                        updatePreview();
                        await Dialog.alert('Loaded plugin metadata, but no Commands block was found.');
                    }
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

                // Finds `["key"] = {` BUT only if the inner table immediately starts with a standard command key, e.g. `["ListName"]`
                let cmdRegex = /\[(["'])([^"']+)\1\]\s*=\s*\{(?=\s*(?:--[^\n]*\n\s*)*\[(["']))/g;
                let match;
                let indices = [];
                while ((match = cmdRegex.exec(commandsBody)) !== null) {
                    indices.push({ key: match[2], start: match.index });
                }

                for (let i = 0; i < indices.length; i++) {
                    let current = indices[i];
                    let next = indices[i + 1];

                    let blockStr = next ? commandsBody.substring(current.start, next.start) : commandsBody.substring(current.start);

                    let listNameMatch = blockStr.match(/\[(["'])ListName\1\]\s*=\s*(["'])(.*?)\2/);
                    let listName = listNameMatch ? listNameMatch[3] : "cmd";

                    let descMatch = blockStr.match(/\[(["'])Description\1\]\s*=\s*(["'])(.*?)\2/);
                    let desc = descMatch ? descMatch[3] : "";

                    let aliasesMatch = blockStr.match(/\[(["'])Aliases\1\]\s*=\s*\{([^}]*)\}/);
                    let aliases = aliasesMatch ? aliasesMatch[2].split(',').map(s => s.replace(/['"]/g, '').trim()).filter(x => x) : [];

                    let code = "-- code here";
                    let fnMatch = blockStr.match(/\[(["'])Function\1\]\s*=\s*function\s*\([^)]*\)/);
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

                    // normalize indentation
                    codeLines = codeLines.map(l => l.replace(/\t/g, '    '));

                    let minIndent = Infinity;
                    for (let line of codeLines) {
                        if (line.trim().length > 0) {
                            let wsMatch = line.match(/^([ ]*)/);
                            let indent = wsMatch ? wsMatch[1].length : 0;
                            if (indent < minIndent) minIndent = indent;
                        }
                    }
                    if (minIndent === Infinity) minIndent = 0;
                    codeLines = codeLines.map(l => l.substring(minIndent).trimEnd());

                    pluginData.commands.push({
                        id: generateId(),
                        key: current.key,
                        listName: listName,
                        desc: desc,
                        aliases: aliases,
                        code: codeLines.join('\n')
                    });
                }

                try {
                    renderCommands();
                    // Force autoSync active because we successfully parsed entirely client-side
                    autoSyncEnabled = true;
                    const syncWarn = document.getElementById('sync-warning');
                    if (syncWarn) syncWarn.classList.add('hidden');
                    updatePreview();
                } catch (syncErr) {
                    console.warn('Parser succeeded but UI sync failed:', syncErr);
                }

                if (pluginData.commands.length === 0) {
                    await Dialog.alert('Loaded plugin metadata, but could not automatically parse commands.');
                }

            } catch (e) {
                console.error('Error parsing Lua:', e);
                await Dialog.alert('Failed to parse the provided .iy file correctly. Check the console for details.');
            }
        }

        function formatLuaCode(code) {
            // 1. Tokenize literals and comments to prevent them from interfering with indentation rules
            const tokens = [];
            let tokenIdx = 0;

            function saveToken(match) {
                const id = `__LUA_TOKEN_${tokenIdx++}__`;
                tokens.push({ id, text: match });
                return id;
            }

            // Matches block comments, single-line comments, block strings, double-quote strings, and single-quote strings.
            const tokenizerRegex = /--\[(=*)\[[\s\S]*?\]\1\]|--[^\n]*|\[(=*)\[[\s\S]*?\]\2\]|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'/g;
            let skeleton = code.replace(tokenizerRegex, saveToken);

            // 2. Process indentation
            let lines = skeleton.split('\n');
            let formattedLines = [];
            let indentLevel = 0;
            const INDENT = "    "; // 4 spaces

            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                if (line.length === 0) {
                    formattedLines.push("");
                    continue;
                }

                // If current line begins with a closer, it decreases the current line's indent
                let decreaseCurrent = 0;
                if (/^(end|until|else|elseif)\b/.test(line) || /^}[\s,;)]*/.test(line)) {
                    decreaseCurrent = 1;
                }

                let currentIndent = Math.max(0, indentLevel - decreaseCurrent);
                formattedLines.push(INDENT.repeat(currentIndent) + line);

                // Calculate next indent level based on openers and closers in the current line
                let openers = (line.match(/\b(then|do|function|repeat|else)\b/g) || []).length;
                openers += (line.match(/\{/g) || []).length;

                let closers = (line.match(/\b(end|until|else|elseif)\b/g) || []).length;
                closers += (line.match(/\}/g) || []).length;

                indentLevel += (openers - closers);
                if (indentLevel < 0) indentLevel = 0;
            }

            let result = formattedLines.join('\n');

            // 3. Restore tokens
            for (let i = tokens.length - 1; i >= 0; i--) {
                result = result.replace(tokens[i].id, tokens[i].text);
            }

            return result;
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
