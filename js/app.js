(() => {
    'use strict';

    let cleanup = null;

    window.initHome = function () {
        if (cleanup) cleanup();

        let isAborted = false;

        let allPlugins = [];
        let currentList = [];
        let sort = 'newest';
        let query = '';

        let currentPage = 0;
        const PAGE_SIZE = 40;
        const ONE_YEAR_MS = 365 * 24 * 60 * 60 * 1000;

        const $ = id => document.getElementById(id);
        const grid = $('grid');
        const loading = $('loading');
        const empty = $('empty');
        const search = $('search');
        const sortEl = $('sort');
        const overlay = $('overlay');
        const loadMoreTarget = $('load-more');

        let intervalId = null;

        async function init() {
            try {
                const res = await fetch(`./data/plugins.json?v=${Date.now()}`);
                const data = await res.json();

                if (isAborted) return;
                allPlugins = data.plugins || [];

                const counter = $('plugin-count');
                if (counter) counter.textContent = `${allPlugins.length} plugins`;

                const heroCount = $('stat-count');
                if (heroCount) heroCount.textContent = allPlugins.length.toLocaleString();

                const authorSet = new Set(allPlugins.map(p => p.author?.username || p.author?.name || 'Unknown'));
                const heroAuthors = $('stat-authors');
                if (heroAuthors) heroAuthors.textContent = authorSet.size.toLocaleString();

                if (data.scraped_at) {
                    const scrapedDate = new Date(data.scraped_at);
                    const updateLiveTime = () => {
                        const hu = $('header-updated');
                        const su = $('stat-updated');
                        if (isAborted || (!hu && !su)) return;
                        const diff = Math.floor((new Date() - scrapedDate) / 1000);
                        if (diff < 0) {
                            if (su) su.textContent = 'Just now';
                            if (hu) hu.textContent = 'Last updated: Just now';
                            return;
                        }
                        const d = Math.floor(diff / 86400);
                        const h = Math.floor((diff % 86400) / 3600);
                        const m = Math.floor((diff % 3600) / 60);
                        const s = diff % 60;

                        let str = '';
                        if (d > 0) str += `${d}d `;
                        if (h > 0 || d > 0) str += `${h}h `;
                        if (m > 0 || h > 0 || d > 0) str += `${m}m `;
                        str += `${s}s ago`;

                        if (su) {
                            su.textContent = str;
                            su.title = scrapedDate.toLocaleString();
                        }
                        if (hu) {
                            hu.textContent = `Last updated: ${str}`;
                            hu.title = scrapedDate.toLocaleString();
                        }
                    };
                    updateLiveTime();
                    intervalId = setInterval(updateLiveTime, 1000);
                } else {
                    if ($('stat-updated')) $('stat-updated').textContent = 'Unknown';
                    if ($('header-updated')) $('header-updated').textContent = 'Last updated: Unknown';
                }

                loading.classList.add('hidden');

                const observer = new IntersectionObserver(entries => {
                    if (entries[0].isIntersecting) {
                        renderMore();
                    }
                }, { rootMargin: '400px' });
                observer.observe(loadMoreTarget);

                render();
                handleDeepLink();
            } catch (e) {
                loading.textContent = 'Failed to load plugins.json';
            }
        }

        function handleDeepLink() {
            const hash = decodeURIComponent(location.hash.slice(1));
            if (!hash) return;
            const plugin = allPlugins.find(p => p.id === hash);
            if (plugin) openModal(plugin);
        }

        const onHashChange = handleDeepLink;
        window.addEventListener('hashchange', onHashChange);

        function render() {
            let list = [...allPlugins];

            if (query) {
                const q = query.toLowerCase();
                list = list.filter(p => {
                    if (q.startsWith('author:')) {
                        const aq = q.substring(7).trim();
                        return (p.author?.name || '').toLowerCase() === aq;
                    }
                    return (p.name || '').toLowerCase().includes(q) || (p.author?.name || '').toLowerCase().includes(q);
                });
            }

            if (sort === 'newest') list.sort((a, b) => new Date(b.date) - new Date(a.date));
            if (sort === 'oldest') list.sort((a, b) => new Date(a.date) - new Date(b.date));
            if (sort === 'name') list.sort((a, b) => (a.name || '').localeCompare(b.name || ''));

            grid.innerHTML = '';
            empty.classList.toggle('hidden', list.length > 0);

            currentList = list;
            currentPage = 0;

            renderMore();
        }

        function renderMore() {
            const start = currentPage * PAGE_SIZE;
            const end = start + PAGE_SIZE;
            const pageItems = currentList.slice(start, end);

            if (pageItems.length === 0) return;

            const frag = document.createDocumentFragment();

            pageItems.forEach(p => {
                const card = document.createElement('div');
                card.className = 'card';
                if (window.registerReveal) window.registerReveal(card);

                const initial = (p.author?.name || '?')[0].toUpperCase();
                const authorName = p.author?.name || 'Unknown';

                let avatarHTML;
                if (p.author?.avatar) {
                    avatarHTML = `<img class="card-avatar" src="${escAttr(p.author.avatar)}" alt="" loading="lazy" onerror="this.outerHTML='<div class=\\'card-avatar-ph\\'>${esc(initial)}</div>'">`;
                } else {
                    avatarHTML = `<div class="card-avatar-ph">${esc(initial)}</div>`;
                }

                let desc = (p.description || '').replace(/```[\s\S]*?```/g, '').replace(/[*_~`#]/g, '').trim();
                if (!desc && p.files?.length) desc = p.files.map(a => a.filename).join(', ');

                let tags = '';
                const hasVid = p.files?.some(f => /\.(mp4|webm|mov|avi|mkv)$/i.test(f.filename));
                const hasImg = p.files?.some(f => /\.(png|jpg|jpeg|gif|webp)$/i.test(f.filename));
                if (hasVid) tags += `<span class="tag tag-video"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect></svg>Video</span>`;
                if (hasImg) tags += `<span class="tag tag-image"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>Image</span>`;
                if (p.code_blocks?.length) tags += `<span class="tag tag-code"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>Code</span>`;
                if (p.links?.length) tags += `<span class="tag tag-link"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>Link</span>`;
                if (p.loadstring_urls?.length) tags += `<span class="tag tag-loadstring"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>Loadstring</span>`;

                let dateColor = 'inherit';
                if (p.date) {
                    const ms = new Date(p.date).getTime();
                    if (!isNaN(ms)) {
                        const now = Date.now();
                        const oneYearAgo = now - ONE_YEAR_MS;
                        const ratio = Math.max(0, Math.min(1, (ms - oneYearAgo) / (now - oneYearAgo)));
                        const hue = ratio * 120;
                        dateColor = `hsl(${hue}, 80%, 65%)`;
                    }
                }

                card.innerHTML = `
                <div class="card-header">
                    ${avatarHTML}
                    <div class="card-info">
                        <div class="card-name">${esc(p.name || 'Untitled')}</div>
                        <div class="card-author author-click" title="View all by ${escAttr(authorName)}">${esc(authorName)}</div>
                    </div>
                    <div class="card-date" style="color: ${dateColor}; font-weight: 500;">${fmtDate(p.date)}</div>
                </div>
                <div class="card-desc">${esc(desc || 'No description')}</div>
                <div class="card-footer">
                    <div class="card-tags">${tags}</div>
                    <button class="card-share" title="Copy link"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg></button>
                </div>
            `;

                card.querySelector('.card-share').addEventListener('click', (e) => {
                    e.stopPropagation();
                    const url = `${location.origin}${location.pathname}#${encodeURIComponent(p.id)}`;
                    navigator.clipboard.writeText(url).then(() => {
                        const btn = e.currentTarget;
                        btn.innerHTML = '<span style="font-size:0.85rem">✓</span>';
                        setTimeout(() => btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>', 1500);
                    });
                });

                const authorSpan = card.querySelector('.card-author');
                if (authorSpan) {
                    authorSpan.addEventListener('click', (e) => {
                        e.stopPropagation();
                        search.value = 'author:' + authorName;
                        syncSearch({ target: search });
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    });
                }

                card.onclick = () => openModal(p);
                frag.appendChild(card);
            });

            grid.appendChild(frag);
            currentPage++;
        }

        // ---- Modal ----
        function openModal(p) {
            history.replaceState(null, '', `#${encodeURIComponent(p.id)}`);

            const initial = (p.author?.name || '?')[0].toUpperCase();
            const authorName = p.author?.name || 'Unknown';
            if (p.author?.avatar) {
                $('m-avatar').innerHTML = `<img src="${escAttr(p.author.avatar)}" alt="">`;
            } else {
                $('m-avatar').innerHTML = `<span class="m-avatar-ph">${esc(initial)}</span>`;
            }

            let dateColor = 'inherit';
            if (p.date) {
                const ms = new Date(p.date).getTime();
                if (!isNaN(ms)) {
                    const now = Date.now();
                    const oneYearAgo = now - ONE_YEAR_MS;
                    const ratio = Math.max(0, Math.min(1, (ms - oneYearAgo) / (now - oneYearAgo)));
                    dateColor = `hsl(${ratio * 120}, 80%, 65%)`;
                }
            }

            $('m-title').textContent = p.name || 'Untitled';
            $('m-author').textContent = authorName;
            $('m-author').className = 'author-click';
            $('m-author').title = 'View all by ' + authorName;
            $('m-author').onclick = (e) => {
                e.stopPropagation();
                closeModal();
                search.value = 'author:' + authorName;
                syncSearch({ target: search });
                window.scrollTo({ top: 0, behavior: 'smooth' });
            };
            $('m-date').textContent = fmtDate(p.date);
            $('m-date').style.color = dateColor;
            $('m-date').style.fontWeight = '500';

            const msgLink = $('m-msg-link');
            if (p.message_url) {
                msgLink.href = p.message_url;
                msgLink.classList.remove('hidden');
            } else {
                msgLink.classList.add('hidden');
            }

            let html = '';

            if (p.loadstring_urls?.length) {
                html += `<div class="section"><div class="section-label">Loadstring URLs (${p.loadstring_urls.length})</div>`;
                p.loadstring_urls.forEach(url => {
                    html += `<a class="loadstring-link" href="${escAttr(url)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">${esc(url)}</a>`;
                });
                html += `</div>`;
            }

            const pluginFiles = (p.files || []).filter(f => {
                const lower = f.filename.toLowerCase();
                return lower.endsWith('.iy') || lower.endsWith('.lua');
            });
            if (pluginFiles.length) {
                html += `<div class="section"><div class="section-label">Quick Install (paste on your executor)</div>`;

                let writeAndAdd = pluginFiles.map(f => {
                    const fileUrl = `https://iyplugins.pages.dev/plugins/${p.id}/${f.filename}`;
                    return `writefile("${f.filename}", game:HttpGet("${fileUrl}"))\nif add then add("${f.filename}") end`;
                }).join('\n');

                let writeOnly = pluginFiles.map(f => {
                    const fileUrl = `https://iyplugins.pages.dev/plugins/${p.id}/${f.filename}`;
                    return `writefile("${f.filename}", game:HttpGet("${fileUrl}"))`;
                }).join('\n');

                let addOnly = pluginFiles.map(f => `add("${f.filename}")`).join(' ');

                const loadstringLaunch = `loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
local add = addPlugin or (shared and shared.addPlugin)
${writeAndAdd}`;

                const loadstringNoLaunch = `${writeOnly}
local add = addPlugin or (shared and shared.addPlugin)
if add then
    ${addOnly}
else
    warn("Saved to workspace. Run IY to use.")
end`;

                const cbId1 = `qi1-${p.id}`;
                const cbId2 = `qi2-${p.id}`;
                html += `
                <div class="code-wrap">
                    <div class="code-bar">
                        <span class="code-lang">Install &amp; Launch IY</span>
                        <button class="copy-btn" data-id="${cbId1}">Copy</button>
                    </div>
                    <pre class="code-block" id="${cbId1}">${esc(loadstringLaunch)}</pre>
                </div>
                <div class="code-wrap">
                    <div class="code-bar">
                        <span class="code-lang">Install Only (Autoload on IY)</span>
                        <button class="copy-btn" data-id="${cbId2}">Copy</button>
                    </div>
                    <pre class="code-block" id="${cbId2}">${esc(loadstringNoLaunch)}</pre>
                </div>`;

                html += `</div>`;
            }

            const text = (p.description || '').trim();
            if (text) {
                html += `<div class="section"><div class="section-label">Description</div><div class="section-text">${discordFormat(text, p.id)}</div></div>`;
            }

            if (p.files?.length) {
                html += `<div class="section"><div class="section-label">Files</div>`;
                p.files.forEach((a, i) => {
                    const isCode = a.filename.toLowerCase().match(/\.(lua|iy|txt)$/);
                    const isImage = a.filename.toLowerCase().match(/\.(png|jpg|jpeg|gif|webp)$/);
                    const isVideo = a.filename.toLowerCase().match(/\.(mp4|webm|mov)$/);

                    const fileUrl = a.url;
                    let dlName = a.filename;
                    if (isCode && dlName.toLowerCase().endsWith('.lua')) dlName = dlName.replace(/\.lua$/i, '.iy');
                    const prevBtn = isCode ? `<button class="att-prev-btn" data-url="${escAttr(fileUrl)}" data-id="prev-${p.id}-${i}">Preview</button>` : '';
                    const dlBtn = (isImage || isVideo) ? '' : `<a class="att-dl" href="${fileUrl}" download="${escAttr(dlName)}" onclick="event.stopPropagation()">Download</a>`;

                    html += `<div class="att-row">
                    <span class="att-name">${esc(a.filename)}</span>
                    <span class="att-size">${fmtBytes(a.size)}</span>
                    <div class="att-actions">
                        ${prevBtn}
                        ${dlBtn}
                    </div>
                </div>`;

                    if (isCode) {
                        const lang = a.filename.toLowerCase().endsWith('.txt') ? 'txt' : 'lua';
                        html += `<div id="prev-${p.id}-${i}" class="file-preview hidden"><div class="code-wrap"><div class="code-bar"><span class="code-lang">${lang}</span><button class="copy-btn" data-id="code-${p.id}-${i}">Copy</button></div><pre class="code-block" id="code-${p.id}-${i}"></pre></div></div>`;
                    } else if (isImage) {
                        html += `<div class="media-preview"><img src="${escAttr(a.url)}" alt="${escAttr(a.filename)}" loading="lazy" draggable="false"></div>`;
                    } else if (isVideo) {
                        html += `<div class="media-preview"><video src="${escAttr(a.url)}" controls controlsList="nodownload" preload="metadata"></video></div>`;
                    }
                });
                html += `</div>`;
            }

            if (p.links?.length || p.embeds?.length) {
                html += `<div class="section"><div class="section-label">Links &amp; Embeds</div>`;

                if (p.embeds?.length) {
                    p.embeds.forEach(emb => {
                        html += renderEmbed(emb);
                    });
                }

                if (p.links?.length) {
                    const embeddedUrls = new Set((p.embeds || []).map(e => e.url));
                    p.links.forEach(l => {
                        if (!embeddedUrls.has(l)) {
                            html += `<a class="link-item" href="${escAttr(l)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">${esc(l)}</a>`;
                        }
                    });
                }
                html += `</div>`;
            }

            if (!html) html = '<div class="section-text" style="color:var(--text3);text-align:center;padding:24px 0">No details available.</div>';

            $('m-body').innerHTML = html;

            // Preview handlers
            $('m-body').querySelectorAll('.att-prev-btn').forEach(btn => {
                btn.onclick = async e => {
                    e.stopPropagation();
                    const previewDiv = document.getElementById(btn.dataset.id);
                    const codeBlock = previewDiv.querySelector('.code-block');

                    if (!previewDiv.classList.contains('hidden') && codeBlock.textContent !== 'Loading...') {
                        previewDiv.classList.add('hidden');
                        btn.textContent = 'Preview';
                        return;
                    }

                    previewDiv.classList.remove('hidden');
                    btn.textContent = 'Hide';

                    const parts = btn.dataset.id.split('-');
                    const pId = parts[1];
                    const aIdx = parseInt(parts[2]);
                    const plugin = allPlugins.find(p => p.id === pId);
                    const attachment = plugin?.files?.[aIdx];

                    if (attachment && attachment.code) {
                        codeBlock.textContent = attachment.code;
                        return;
                    }

                    if (!codeBlock.textContent || codeBlock.textContent === 'Loading...') {
                        codeBlock.textContent = 'Loading...';
                        try {
                            const res = await fetch(btn.dataset.url);
                            if (!res.ok) throw new Error('Fetch failed');
                            const text = await res.text();
                            codeBlock.textContent = text;
                        } catch (err) {
                            codeBlock.textContent = 'Failed to load preview. Please Re-Scrape plugins to embed file contents directly.';
                        }
                    }
                };
            });

            // Copy handlers
            $('m-body').querySelectorAll('.copy-btn').forEach(btn => {
                btn.onclick = e => {
                    e.stopPropagation();
                    const el = document.getElementById(btn.dataset.id);
                    if (!el) return;
                    navigator.clipboard.writeText(el.textContent).then(() => {
                        btn.textContent = 'Copied!';
                        btn.classList.add('copied');
                        setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 1500);
                    });
                };
            });

            overlay.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            if (overlay.classList.contains('hidden') || overlay.classList.contains('closing')) return;
            overlay.classList.add('closing');
            setTimeout(() => {
                overlay.classList.remove('closing');
                overlay.classList.add('hidden');
                document.body.style.overflow = '';
            }, 220);
            history.replaceState(null, '', location.pathname + location.search);
        }

        // ---- Events ----
        const debouncedSearch = debounce(val => { query = val.trim(); render(); }, 200);
        const syncSearch = e => debouncedSearch(e.target.value);
        search?.addEventListener('input', syncSearch);

        const sortChange = e => {
            sort = e.target.value;

            document.querySelectorAll('.custom-select').forEach(customEl => {
                const targetId = customEl.dataset.target;
                if (targetId === 'sort') {
                    const opt = customEl.querySelector(`.select-option[data-value="${sort}"]`);
                    if (opt) {
                        customEl.querySelectorAll('.select-option').forEach(o => o.classList.remove('selected'));
                        opt.classList.add('selected');
                        customEl.querySelector('.select-val').textContent = opt.textContent;
                    }
                }
            });

            render();
        };
        sortEl?.addEventListener('change', sortChange);

        function setupCustomSelects() {
            document.querySelectorAll('.custom-select').forEach(customEl => {
                const btn = customEl.querySelector('.select-btn');
                const valSpan = customEl.querySelector('.select-val');
                const options = customEl.querySelectorAll('.select-option');
                const targetId = customEl.dataset.target;
                const targetSelect = document.getElementById(targetId);

                if (!btn || !targetSelect) return;

                btn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    document.querySelectorAll('.custom-select.active').forEach(el => {
                        if (el !== customEl) el.classList.remove('active');
                    });
                    customEl.classList.toggle('active');
                });

                options.forEach(opt => {
                    opt.addEventListener('click', (e) => {
                        e.stopPropagation();
                        targetSelect.value = opt.dataset.value;
                        targetSelect.dispatchEvent(new Event('change'));
                        customEl.classList.remove('active');
                    });
                });
            });

            document.addEventListener('click', () => {
                document.querySelectorAll('.custom-select.active').forEach(el => el.classList.remove('active'));
            });
        }
        setupCustomSelects();

        $('m-close')?.addEventListener('click', closeModal);

        const onOverlayClick = e => { if (e.target === overlay) closeModal(); };
        overlay?.addEventListener('click', onOverlayClick);

        const onKeyDown = e => {
            if (e.key === 'Escape' && !overlay?.classList.contains('hidden')) closeModal();
            if ((e.ctrlKey || e.metaKey) && e.key === 'k') { e.preventDefault(); search?.focus(); }
        };
        document.addEventListener('keydown', onKeyDown);

        async function doZipDownload(btn) {
            const originalHTML = btn.innerHTML;
            btn.textContent = 'Zipping...';
            btn.disabled = true;

            try {
                if (!window.JSZip) throw new Error('JSZip library not loaded');
                const zip = new JSZip();
                const names = new Set();
                let count = 0;

                const pluginsToFetch = [];
                allPlugins.forEach(p => {
                    if (p.files) {
                        p.files.forEach(a => {
                            if (a.is_plugin) pluginsToFetch.push(a);
                        });
                    }
                });

                btn.textContent = `Zipping (0/${pluginsToFetch.length})...`;
                const concurrency = 20;

                for (let i = 0; i < pluginsToFetch.length; i += concurrency) {
                    const chunk = pluginsToFetch.slice(i, i + concurrency);
                    await Promise.all(chunk.map(async (a) => {
                        try {
                            const res = await fetch(a.url);
                            if (!res.ok) return;
                            const code = await res.text();
                            if (!code || !code.trim()) return;

                            let name = a.filename;
                            if (names.has(name)) {
                                const base = name.replace(/\.[^/.]+$/, "");
                                const ext = name.substring(base.length);
                                let counter = 1;
                                while (names.has(`${base}_${counter}${ext}`)) { counter++; }
                                name = `${base}_${counter}${ext}`;
                            }
                            names.add(name);
                            zip.file(name, code);
                            count++;
                        } catch (e) {
                            console.error('Failed to fetch', a.url, e);
                        }
                    }));
                    btn.textContent = `Zipping (${Math.min(i + concurrency, pluginsToFetch.length)}/${pluginsToFetch.length})...`;
                }

                if (count === 0) throw new Error('No attachments found to zip.');

                const blob = await zip.generateAsync({ type: 'blob' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `iy-plugins-all.zip`;
                document.body.appendChild(a);
                a.click();
                URL.revokeObjectURL(url);
                document.body.removeChild(a);
            } catch (err) {
                await Dialog.alert('Failed to generate zip: ' + err.message);
            } finally {
                btn.innerHTML = originalHTML;
                btn.disabled = false;
            }
        }

        const dlAllBtn = $('dl-all');
        dlAllBtn?.addEventListener('click', () => doZipDownload(dlAllBtn));

        // ---- Util ----
        function fmtDate(iso) {
            if (!iso) return '';
            return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
        }

        function fmtBytes(b) {
            if (!b) return '';
            const u = ['B', 'KB', 'MB'];
            const i = Math.floor(Math.log(b) / Math.log(1024));
            return (b / Math.pow(1024, i)).toFixed(1) + ' ' + u[i];
        }

        function esc(s) {
            if (!s) return '';
            const d = document.createElement('div');
            d.textContent = s;
            return d.innerHTML;
        }

        function escAttr(s) {
            return (s || '').replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        function renderEmbed(emb) {
            const color = emb.color ? (emb.color.startsWith('0x') ? '#' + emb.color.slice(2) : emb.color) : '#202225';

            let authorHtml = '';
            if (emb.author) {
                authorHtml = `
                <a class="embed-author" href="${escAttr(emb.author.url || '#')}" target="_blank" rel="noopener">
                    ${emb.author.icon_url ? `<img class="embed-author-icon" src="${escAttr(emb.author.icon_url)}" alt="">` : ''}
                    <span>${esc(emb.author.name)}</span>
                </a>
            `;
            }

            let gridContent = `
            <div class="embed-text">
                ${emb.provider ? `<div class="embed-provider">${esc(emb.provider.name)}</div>` : ''}
                ${authorHtml}
                ${emb.title ? `<a class="embed-title" href="${escAttr(emb.url || '#')}" target="_blank" rel="noopener">${esc(emb.title)}</a>` : ''}
                ${emb.description ? `<div class="embed-description">${esc(emb.description)}</div>` : ''}
            </div>
        `;

            if (emb.thumbnail) {
                gridContent = `
                <div class="embed-grid">
                    ${gridContent}
                    <img class="embed-thumbnail" src="${escAttr(emb.thumbnail.url)}" alt="" loading="lazy">
                </div>
            `;
            }

            let mediaHtml = '';
            if (emb.video && emb.video.url) {
                if (emb.video.url.includes('youtube.com') || emb.video.url.includes('youtu.be')) {
                    const ytId = emb.video.url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([^&?]+)/)?.[1];
                    if (ytId) {
                        mediaHtml = `<div class="embed-video-wrap"><iframe class="embed-video" src="https://www.youtube.com/embed/${ytId}" allowfullscreen loading="lazy"></iframe></div>`;
                    }
                } else {
                    mediaHtml = `<div class="embed-video-wrap"><video class="embed-video" src="${escAttr(emb.video.url)}" controls></video></div>`;
                }
            } else if (emb.image) {
                mediaHtml = `<img class="embed-image" src="${escAttr(emb.image.url)}" alt="" loading="lazy">`;
            }

            return `
            <div class="embed-card">
                <div class="embed-border" style="background-color: ${color}"></div>
                <div class="embed-inner">
                    ${gridContent}
                    ${mediaHtml}
                </div>
            </div>
        `;
        }

        function discordFormat(text, pId) {
            if (!text) return '';

            text = text.replace(/\n\s*\n\s*\n+/g, '\n\n');

            const parts = text.split(/(```[\s\S]*?```)/g);
            let cbCount = 0;

            return parts.map(part => {
                if (part.startsWith('```') && part.endsWith('```')) {
                    const match = part.match(/```(?:(\w+)\s*\n)?([\s\S]*?)```/);
                    if (!match) return `<pre class="code-block">${esc(part)}</pre>`;

                    const lang = (match[1] || 'lua').toLowerCase();
                    const code = match[2].trim();
                    const id = `cb-${pId}-i${cbCount++}`;

                    return `<div class="code-wrap">
                    <div class="code-bar"><span class="code-lang">${esc(lang)}</span><button class="copy-btn" data-id="${id}">Copy</button></div>
                    <pre class="code-block" id="${id}">${esc(code)}</pre>
                </div>`;
                } else {
                    let segment = part.trim();
                    if (!segment) return '';

                    let html = esc(segment);

                    html = html.replace(/^###\s+(.*)$/gim, '<h5>$1</h5>');
                    html = html.replace(/^##\s+(.*)$/gim, '<h4>$1</h4>');
                    html = html.replace(/^#\s+(.*)$/gim, '<h3>$1</h3>');

                    html = html.replace(/\*\*([^\*]+)\*\*/g, '<strong>$1</strong>');
                    html = html.replace(/__([^_]+)__/g, '<u>$1</u>');
                    html = html.replace(/\*([^\*]+)\*/g, '<em>$1</em>');
                    html = html.replace(/_([^_]+)_/g, '<em>$1</em>');
                    html = html.replace(/~~([^~]+)~~/g, '<s>$1</s>');
                    html = html.replace(/\|\|([\s\S]+?)\|\|/g, (match, $1) => `<span class="spoiler" onclick="this.classList.toggle('revealed')">${$1}</span>`);
                    html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>');

                    html = html.replace(/(<\/h[3-5]>)(\s*#+)/gi, '$1');

                    html = html.replace(/\n\n/g, '</p><p>');
                    html = html.replace(/\n/g, '<br>');
                    html = `<p>${html}</p>`;

                    return html;
                }
            }).join('');
        }

        function debounce(fn, ms) {
            let t;
            return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };
        }

        init();

        cleanup = () => {
            isAborted = true;
            if (intervalId) clearInterval(intervalId);
            window.removeEventListener('hashchange', onHashChange);
            document.removeEventListener('keydown', onKeyDown);
        };
        window.currentRouteCleanup = cleanup;
    };
})();