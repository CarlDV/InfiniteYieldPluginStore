/* ============================================================
   Authors page — clean rewrite
   No sounds, no blur, no overshoot. Flat, lightweight.
   Entry point: window.initAuthors (called by router.js)
   ============================================================ */

(() => {
    'use strict';

    let cleanup = null;

    window.initAuthors = function () {
        if (cleanup) cleanup();

        let isAborted = false;

        let allPlugins = [];
        let allAuthors = [];
        let searchQuery = '';
        let sortMode = 'plugins';
        let scrollLockCount = 0;
        let docClickHandler = null;

        const $ = id => document.getElementById(id);

        const grid = $('authors-grid');
        const loading = $('authors-loading');
        const empty = $('authors-empty');
        const searchInput = $('author-search');
        const sortEl = $('author-sort');
        const overlay = $('author-overlay');
        const pluginOverlay = $('plugin-overlay');

        const ONE_YEAR_MS = 365.25 * 24 * 60 * 60 * 1000;

        const SHARE_SVG = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>';
        const CHECK_SVG = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>';

        /* ---------- Utils ---------- */

        function fmtDate(iso) {
            if (!iso) return '';
            return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
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

        function fmtBytes(b) {
            if (!b) return '';
            const u = ['B', 'KB', 'MB'];
            const i = Math.floor(Math.log(b) / Math.log(1024));
            return (b / Math.pow(1024, i)).toFixed(1) + ' ' + u[i];
        }

        function debounce(fn, ms) {
            let t;
            return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };
        }

        function lockScroll() {
            scrollLockCount++;
            document.body.style.overflow = 'hidden';
        }

        function unlockScroll() {
            scrollLockCount = Math.max(0, scrollLockCount - 1);
            if (scrollLockCount === 0) document.body.style.overflow = '';
        }

        function copyShareLink(username, btn, isModal) {
            const url = `${location.origin}${location.pathname}#${encodeURIComponent(username)}`;
            navigator.clipboard.writeText(url).then(() => {
                const original = btn.innerHTML;
                btn.innerHTML = CHECK_SVG + (isModal ? ' Copied!' : '');
                setTimeout(() => { btn.innerHTML = original; }, 1500);
            }).catch(() => { });
        }

        function mkTag(label, cls) {
            const t = document.createElement('span');
            t.className = `tag ${cls}`;
            t.textContent = label;
            return t;
        }

        /* ---------- Data ---------- */

        async function load() {
            try {
                const res = await fetch(`./data/plugins.json?v=${Date.now()}`);
                const data = await res.json();
                if (isAborted) return;
                allPlugins = data.plugins || [];

                const counter = $('plugin-count');
                if (counter) counter.textContent = `${allPlugins.length} plugins`;

                const authorMap = new Map();
                allPlugins.forEach(p => {
                    const key = p.author?.username || p.author?.name || 'Unknown';
                    if (!authorMap.has(key)) {
                        authorMap.set(key, {
                            name: p.author?.name || 'Unknown',
                            username: p.author?.username || key,
                            avatar: p.author?.avatar || null,
                            plugins: [],
                            latestDate: null
                        });
                    }
                    const author = authorMap.get(key);
                    author.plugins.push(p);
                    if (p.date) {
                        const d = new Date(p.date);
                        if (!author.latestDate || d > author.latestDate) author.latestDate = d;
                    }
                    if (p.author?.avatar && (!author.avatar || author.avatar.includes('embed/avatars'))) {
                        author.avatar = p.author.avatar;
                    }
                });

                allAuthors = Array.from(authorMap.values());

                loading.classList.add('hidden');
                render();
                handleDeepLink();
            } catch (e) {
                loading.textContent = 'Failed to load plugin data.';
                console.error(e);
            }
        }

        /* ---------- Grid ---------- */

        function render() {
            let list = [...allAuthors];

            const q = searchQuery.toLowerCase();
            if (q) {
                list = list.filter(a =>
                    a.name.toLowerCase().includes(q) ||
                    a.username.toLowerCase().includes(q)
                );
            }

            if (sortMode === 'plugins') {
                list.sort((a, b) => b.plugins.length - a.plugins.length);
            } else if (sortMode === 'name') {
                list.sort((a, b) => a.name.localeCompare(b.name));
            } else if (sortMode === 'recent') {
                list.sort((a, b) => (b.latestDate || 0) - (a.latestDate || 0));
            }

            grid.innerHTML = '';
            empty.classList.toggle('hidden', list.length > 0);

            const frag = document.createDocumentFragment();

            list.forEach(author => {
                const card = document.createElement('div');
                card.className = 'author-card';
                if (window.registerReveal) window.registerReveal(card);

                const initial = (author.name || '?')[0].toUpperCase();

                const avatar = document.createElement('div');
                if (author.avatar) {
                    const img = document.createElement('img');
                    img.className = 'author-card-avatar';
                    img.src = author.avatar;
                    img.alt = '';
                    img.loading = 'lazy';
                    img.addEventListener('error', () => {
                        const ph = document.createElement('div');
                        ph.className = 'author-card-avatar-ph';
                        ph.textContent = initial;
                        avatar.replaceWith(ph);
                    });
                    avatar.appendChild(img);
                } else {
                    const ph = document.createElement('div');
                    ph.className = 'author-card-avatar-ph';
                    ph.textContent = initial;
                    avatar.appendChild(ph);
                }

                const nameEl = document.createElement('div');
                nameEl.className = 'author-card-name';
                nameEl.textContent = author.name;

                const usernameEl = document.createElement('div');
                usernameEl.className = 'author-card-username';
                usernameEl.textContent = author.username !== author.name ? `@${author.username}` : '\u00A0';

                const meta = document.createElement('div');
                meta.className = 'author-card-meta';

                const statPlugins = document.createElement('div');
                statPlugins.className = 'author-card-stat';
                statPlugins.innerHTML = `<span class="author-card-stat-num">${author.plugins.length}</span>` +
                    `<span class="author-card-stat-lbl">${author.plugins.length === 1 ? 'plugin' : 'plugins'}</span>`;
                meta.appendChild(statPlugins);

                if (author.latestDate) {
                    const sep = document.createElement('div');
                    sep.className = 'sep';
                    meta.appendChild(sep);

                    const statDate = document.createElement('div');
                    statDate.className = 'author-card-stat';
                    statDate.innerHTML = `<span class="author-card-stat-lbl">Latest:</span>` +
                        `<span class="author-card-stat-num" style="font-size:0.78rem">${fmtDate(author.latestDate)}</span>`;
                    meta.appendChild(statDate);
                }

                const share = document.createElement('button');
                share.className = 'author-card-share';
                share.title = 'Copy link';
                share.innerHTML = SHARE_SVG;

                share.addEventListener('click', e => {
                    e.stopPropagation();
                    copyShareLink(author.username, share, false);
                });

                card.addEventListener('click', () => openAuthorModal(author));

                card.append(avatar, nameEl, usernameEl, meta, share);
                frag.appendChild(card);
            });

            grid.appendChild(frag);
        }

        /* ---------- Author modal ---------- */

        function openAuthorModal(author) {
            history.replaceState(null, '', `#${encodeURIComponent(author.username)}`);

            const initial = (author.name || '?')[0].toUpperCase();

            const avatarWrap = $('am-avatar-wrap');
            avatarWrap.innerHTML = '';
            if (author.avatar) {
                const img = document.createElement('img');
                img.className = 'author-modal-avatar';
                img.src = author.avatar;
                img.alt = '';
                img.addEventListener('error', () => {
                    avatarWrap.innerHTML = '';
                    const ph = document.createElement('div');
                    ph.className = 'author-modal-avatar-ph';
                    ph.textContent = initial;
                    avatarWrap.appendChild(ph);
                });
                avatarWrap.appendChild(img);
            } else {
                const ph = document.createElement('div');
                ph.className = 'author-modal-avatar-ph';
                ph.textContent = initial;
                avatarWrap.appendChild(ph);
            }

            const usernameLine = author.username !== author.name
                ? `<div class="author-modal-username">@${esc(author.username)}</div>`
                : '';

            let earliest = null, latest = null;
            author.plugins.forEach(p => {
                if (p.date) {
                    const d = new Date(p.date);
                    if (!earliest || d < earliest) earliest = d;
                    if (!latest || d > latest) latest = d;
                }
            });

            let notice = '';
            if (author.name === 'Deleted User' || author.username === 'Deleted User') {
                notice = `<div style="margin:10px 0;padding:10px 12px;background:rgba(248,113,113,0.1);border-left:3px solid var(--red);border-radius:6px;font-size:0.85rem;color:var(--text2);line-height:1.5;">` +
                    `<strong style="color:var(--red);">Note:</strong> This profile is a combination of multiple different authors whose accounts have been deleted.</div>`;
            }

            $('am-info').innerHTML = `
                <h2>${esc(author.name)}</h2>
                ${usernameLine}
                ${notice}
                <div class="author-modal-stats">
                    <span><strong>${author.plugins.length}</strong> ${author.plugins.length === 1 ? 'plugin' : 'plugins'}</span>
                    ${earliest ? `<span><strong>First:</strong> ${fmtDate(earliest)}</span>` : ''}
                    ${latest ? `<span><strong>Latest:</strong> ${fmtDate(latest)}</span>` : ''}
                </div>`;

            const body = $('am-body');
            body.innerHTML = `
                <div class="author-modal-profile" style="justify-content: space-between; margin-bottom: 20px;">
                    <div class="author-plugins-label" style="margin:0;font-size:1.05rem;">All Plugins (${author.plugins.length})</div>
                    <button class="author-modal-share-btn" id="am-share-btn">${SHARE_SVG} Share</button>
                </div>
                <div class="am-toolbar">
                    <div class="am-search-wrap">
                        <svg class="search-icon" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="11" cy="11" r="8" />
                            <path d="m21 21-4.35-4.35" />
                        </svg>
                        <input type="text" id="am-search" placeholder="Search plugins..." autocomplete="off">
                    </div>
                    <div class="custom-select" id="am-sort-custom" data-target="am-sort">
                        <button class="select-btn" type="button" aria-haspopup="listbox">
                            <span class="select-val">Newest</span>
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </button>
                        <div class="select-dropdown">
                            <div class="select-option selected" data-value="newest">Newest</div>
                            <div class="select-option" data-value="oldest">Oldest</div>
                            <div class="select-option" data-value="az">A-Z</div>
                        </div>
                        <select id="am-sort" style="display: none;">
                            <option value="newest" selected>Newest</option>
                            <option value="oldest">Oldest</option>
                            <option value="az">A-Z</option>
                        </select>
                    </div>
                </div>
                <div id="am-plugin-list"></div>`;

            setupCustomSelects(body);

            const pluginList = $('am-plugin-list');
            const amSearch = $('am-search');
            const amSort = $('am-sort');

            function renderAuthorPlugins() {
                const query = amSearch.value.toLowerCase().trim();
                const sortVal = amSort.value;

                let filtered = author.plugins.filter(p =>
                    !query || (p.name || '').toLowerCase().includes(query)
                );

                if (sortVal === 'newest') {
                    filtered.sort((a, b) => new Date(b.date || 0) - new Date(a.date || 0));
                } else if (sortVal === 'oldest') {
                    filtered.sort((a, b) => new Date(a.date || 0) - new Date(b.date || 0));
                } else if (sortVal === 'az') {
                    filtered.sort((a, b) => (a.name || '').localeCompare(b.name || ''));
                }

                if (filtered.length === 0) {
                    pluginList.innerHTML = '<div class="status">No plugins match your search.</div>';
                    return;
                }

                const frag = document.createDocumentFragment();
                filtered.forEach((p, i) => {
                    const row = document.createElement('div');
                    row.className = 'author-plugin-item';
                    row.dataset.pluginId = p.id;
                    row.style.animation = `fade-in-up 0.35s var(--ease-out) ${Math.min(i, 10) * 0.03}s both`;

                    const name = document.createElement('div');
                    name.className = 'author-plugin-name';
                    name.textContent = p.name || 'Untitled';
                    row.appendChild(name);

                    const tags = document.createElement('div');
                    tags.className = 'author-plugin-tags';
                    if (p.code_blocks?.length) tags.appendChild(mkTag('Code', 'tag-code'));
                    if (p.loadstring_urls?.length) tags.appendChild(mkTag('Loadstring', 'tag-loadstring'));
                    if (p.files?.length) {
                        const n = p.files.length;
                        tags.appendChild(mkTag(`${n} file${n > 1 ? 's' : ''}`, 'tag-file'));
                    }
                    row.appendChild(tags);

                    const date = document.createElement('div');
                    date.className = 'author-plugin-date';
                    date.textContent = fmtDate(p.date);
                    row.appendChild(date);

                    row.addEventListener('click', () => {
                        const plugin = allPlugins.find(x => x.id === p.id);
                        if (plugin) openPluginModal(plugin);
                    });

                    frag.appendChild(row);
                });
                pluginList.innerHTML = '';
                pluginList.appendChild(frag);
            }

            amSearch.addEventListener('input', debounce(renderAuthorPlugins, 200));
            amSort.addEventListener('change', renderAuthorPlugins);
            renderAuthorPlugins();

            $('am-share-btn').addEventListener('click', e => {
                e.stopPropagation();
                copyShareLink(author.username, e.currentTarget, true);
            });

            overlay.classList.remove('hidden');
            lockScroll();
        }

        function closeAuthorModal() {
            if (overlay.classList.contains('hidden') || overlay.classList.contains('closing')) return;
            overlay.classList.add('closing');
            setTimeout(() => {
                overlay.classList.remove('closing');
                overlay.classList.add('hidden');
                unlockScroll();
            }, 220);
            history.replaceState(null, '', location.pathname + location.search);
        }

        /* ---------- Plugin modal ---------- */

        function openPluginModal(p) {
            const initial = (p.author?.name || '?')[0].toUpperCase();
            const authorName = p.author?.name || 'Unknown';

            const avatarEl = $('pm-avatar');
            avatarEl.innerHTML = '';
            if (p.author?.avatar) {
                const img = document.createElement('img');
                img.src = p.author.avatar;
                img.alt = '';
                img.addEventListener('error', () => {
                    avatarEl.innerHTML = `<span class="m-avatar-ph">${esc(initial)}</span>`;
                });
                avatarEl.appendChild(img);
            } else {
                avatarEl.innerHTML = `<span class="m-avatar-ph">${esc(initial)}</span>`;
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

            $('pm-title').textContent = p.name || 'Untitled';

            const authorEl = $('pm-author');
            authorEl.textContent = authorName;
            authorEl.className = 'author-click';
            authorEl.title = 'View author profile';
            authorEl.onclick = () => closePluginModal();

            const dateEl = $('pm-date');
            dateEl.textContent = fmtDate(p.date);
            dateEl.style.color = dateColor;
            dateEl.style.fontWeight = '500';

            const msgLink = $('pm-msg-link');
            if (p.message_url) {
                msgLink.href = p.message_url;
                msgLink.classList.remove('hidden');
            } else {
                msgLink.classList.add('hidden');
            }

            const body = $('pm-body');
            body.innerHTML = buildPluginModalHTML(p);
            wirePluginModal(body, p);

            pluginOverlay.classList.remove('hidden');
            lockScroll();
        }

        function closePluginModal() {
            if (pluginOverlay.classList.contains('hidden') || pluginOverlay.classList.contains('closing')) return;
            pluginOverlay.classList.add('closing');
            setTimeout(() => {
                pluginOverlay.classList.remove('closing');
                pluginOverlay.classList.add('hidden');
                unlockScroll();
            }, 220);
        }

        /* ---------- Plugin modal renderer ---------- */

        function buildPluginModalHTML(p) {
            let html = '';

            if (p.loadstring_urls?.length) {
                html += `<div class="section"><div class="section-label">Loadstring URLs (${p.loadstring_urls.length})</div>`;
                p.loadstring_urls.forEach(url => {
                    html += `<a class="loadstring-link" href="${escAttr(url)}" target="_blank" rel="noopener">${esc(url)}</a>`;
                });
                html += '</div>';
            }

            const pluginFiles = (p.files || []).filter(f => {
                const lower = f.filename.toLowerCase();
                return lower.endsWith('.iy') || lower.endsWith('.lua');
            });
            if (pluginFiles.length) {
                html += '<div class="section"><div class="section-label">Quick Install (paste on your executor)</div>';
                pluginFiles.forEach((f, i) => {
                    const fileUrl = `https://iyplugins.pages.dev/plugins/${p.id}/${f.filename}`;

                    const loadstringLaunch = `loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
local f = "${f.filename}"
writefile(f, game:HttpGet("${fileUrl}"))
local add = addPlugin or (shared and shared.addPlugin)
if add then add(f) end`;

                    const loadstringNoLaunch = `local f = "${f.filename}"
writefile(f, game:HttpGet("${fileUrl}"))
local add = addPlugin or (shared and shared.addPlugin)
if add then add(f) else warn("Saved to workspace. Run IY to use.") end`;

                    const cbId1 = `qi1-${p.id}-${i}`;
                    const cbId2 = `qi2-${p.id}-${i}`;
                    html += `
                        <div class="code-wrap" style="margin:8px 0;">
                            <div class="code-bar">
                                <span class="code-lang">Install & Launch IY</span>
                                <button class="copy-btn" data-id="${cbId1}">Copy</button>
                            </div>
                            <pre class="code-block" id="${cbId1}" style="white-space:pre-wrap;word-break:break-all;padding:10px 14px;">${esc(loadstringLaunch)}</pre>
                        </div>
                        <div class="code-wrap" style="margin:8px 0;">
                            <div class="code-bar">
                                <span class="code-lang">Install Only (Autoload on IY)</span>
                                <button class="copy-btn" data-id="${cbId2}">Copy</button>
                            </div>
                            <pre class="code-block" id="${cbId2}" style="white-space:pre-wrap;word-break:break-all;padding:10px 14px;">${esc(loadstringNoLaunch)}</pre>
                        </div>`;
                });
                html += '</div>';
            }

            const text = (p.description || '').trim();
            if (text) html += `<div class="section"><div class="section-label">Description</div><div class="section-text">${discordFormat(text, p.id)}</div></div>`;

            if (p.files?.length) {
                html += '<div class="section"><div class="section-label">Files</div>';
                p.files.forEach((a, i) => {
                    const isCode = a.filename.toLowerCase().match(/\.(lua|iy|txt)$/);
                    const isImage = a.filename.toLowerCase().match(/\.(png|jpg|jpeg|gif|webp)$/);
                    const isVideo = a.filename.toLowerCase().match(/\.(mp4|webm|mov)$/);

                    const prevBtn = isCode
                        ? `<button class="att-prev-btn" data-url="${escAttr(a.url)}" data-id="prev-${p.id}-${i}">Preview</button>`
                        : '';

                    let dlBtn = '';
                    if (isImage || isVideo) {
                        dlBtn = '';
                    } else if (isCode) {
                        dlBtn = `<button class="att-dl-btn att-dl" data-id="dl-${p.id}-${i}">Download</button>`;
                    } else {
                        dlBtn = `<a class="att-dl" href="${escAttr(a.url)}" target="_blank" rel="noopener">Download</a>`;
                    }

                    html += `<div class="att-row">
                        <span class="att-name">${esc(a.filename)}</span>
                        <span class="att-size">${fmtBytes(a.size)}</span>
                        <div class="att-actions">${prevBtn}${dlBtn}</div>
                    </div>`;

                    if (isCode) {
                        html += `<div id="prev-${p.id}-${i}" class="file-preview hidden"><div class="code-wrap"><div class="code-bar"><span class="code-lang">${esc(a.filename.split('.').pop())}</span><button class="copy-btn" data-id="code-${p.id}-${i}">Copy</button></div><pre class="code-block" id="code-${p.id}-${i}"></pre></div></div>`;
                    } else if (isImage) {
                        html += `<div class="media-preview"><img src="${escAttr(a.url)}" alt="${escAttr(a.filename)}" loading="lazy" draggable="false"></div>`;
                    } else if (isVideo) {
                        html += `<div class="media-preview"><video src="${escAttr(a.url)}" controls controlsList="nodownload" preload="metadata"></video></div>`;
                    }
                });
                html += '</div>';
            }

            if (p.links?.length || p.embeds?.length) {
                html += '<div class="section"><div class="section-label">Links & Embeds</div>';
                if (p.embeds?.length) p.embeds.forEach(emb => { html += renderEmbed(emb); });
                if (p.links?.length) {
                    const embeddedUrls = new Set((p.embeds || []).map(e => e.url));
                    p.links.forEach(l => {
                        if (!embeddedUrls.has(l)) {
                            html += `<a class="link-item" href="${escAttr(l)}" target="_blank" rel="noopener">${esc(l)}</a>`;
                        }
                    });
                }
                html += '</div>';
            }

            if (!html) {
                html = '<div class="section-text" style="color:var(--text3);text-align:center;padding:24px 0">No details available.</div>';
            }
            return html;
        }

        function wirePluginModal(body, p) {
            body.querySelectorAll('.att-prev-btn').forEach(btn => {
                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    const previewDiv = document.getElementById(btn.dataset.id);
                    if (!previewDiv) return;
                    const codeBlock = previewDiv.querySelector('.code-block');

                    if (!previewDiv.classList.contains('hidden') && codeBlock.textContent !== 'Loading...') {
                        previewDiv.classList.add('hidden');
                        btn.textContent = 'Preview';
                        return;
                    }

                    previewDiv.classList.remove('hidden');
                    btn.textContent = 'Hide';

                    const parts = btn.dataset.id.split('-');
                    const aIdx = parseInt(parts[parts.length - 1], 10);
                    const attachment = p.files?.[aIdx];

                    if (attachment && attachment.code) {
                        codeBlock.textContent = attachment.code;
                        return;
                    }

                    if (!codeBlock.textContent || codeBlock.textContent === 'Loading...') {
                        codeBlock.textContent = 'Loading...';
                        fetch(btn.dataset.url)
                            .then(res => {
                                if (!res.ok) throw new Error('Fetch failed');
                                return res.text();
                            })
                            .then(text => { codeBlock.textContent = text; })
                            .catch(() => { codeBlock.textContent = 'Failed to load preview.'; });
                    }
                });
            });

            body.querySelectorAll('.att-dl-btn').forEach(btn => {
                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    const parts = btn.dataset.id.split('-');
                    const aIdx = parseInt(parts[parts.length - 1], 10);
                    const attachment = p.files?.[aIdx];

                    if (attachment && attachment.code) {
                        const blob = new Blob([attachment.code], { type: 'application/octet-stream' });
                        const url = URL.createObjectURL(blob);
                        const a = document.createElement('a');
                        a.href = url;
                        a.download = attachment.filename;
                        a.click();
                        URL.revokeObjectURL(url);
                    } else if (attachment) {
                        window.open(attachment.url, '_blank');
                    }
                });
            });

            body.querySelectorAll('.copy-btn').forEach(btn => {
                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    const el = document.getElementById(btn.dataset.id);
                    if (!el) return;
                    navigator.clipboard.writeText(el.textContent).then(() => {
                        btn.textContent = 'Copied!';
                        btn.classList.add('copied');
                        setTimeout(() => {
                            btn.textContent = 'Copy';
                            btn.classList.remove('copied');
                        }, 1500);
                    }).catch(() => { });
                });
            });

            body.addEventListener('click', e => {
                const spoiler = e.target.closest('.spoiler');
                if (spoiler) spoiler.classList.toggle('revealed');
            });
        }

        /* ---------- Discord markdown ---------- */

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
                    return `<div class="code-wrap" style="margin:12px 0;">
                        <div class="code-bar"><span class="code-lang">${esc(lang)}</span><button class="copy-btn" data-id="${id}">Copy</button></div>
                        <pre class="code-block" id="${id}">${esc(code)}</pre>
                    </div>`;
                }

                const segment = part.trim();
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
                html = html.replace(/\|\|([\s\S]+?)\|\|/g, (m, g1) => `<span class="spoiler">${g1}</span>`);
                html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>');
                html = html.replace(/(<\/h[3-5]>)(\s*#+)/gi, '$1');
                html = html.replace(/\n\n/g, '</p><p>');
                html = html.replace(/\n/g, '<br>');
                return `<p>${html}</p>`;
            }).join('');
        }

        /* ---------- Embeds ---------- */

        function renderEmbed(emb) {
            const color = emb.color ? (emb.color.startsWith('0x') ? '#' + emb.color.slice(2) : emb.color) : '#202225';

            let authorHtml = '';
            if (emb.author) {
                authorHtml = `<a class="embed-author" href="${escAttr(emb.author.url || '#')}" target="_blank" rel="noopener">
                    ${emb.author.icon_url ? `<img class="embed-author-icon" src="${escAttr(emb.author.icon_url)}" alt="">` : ''}
                    <span>${esc(emb.author.name)}</span>
                </a>`;
            }

            let gridContent = `<div class="embed-text">
                ${emb.provider ? `<div class="embed-provider">${esc(emb.provider.name)}</div>` : ''}
                ${authorHtml}
                ${emb.title ? `<a class="embed-title" href="${escAttr(emb.url || '#')}" target="_blank" rel="noopener">${esc(emb.title)}</a>` : ''}
                ${emb.description ? `<div class="embed-description">${esc(emb.description)}</div>` : ''}
            </div>`;

            if (emb.thumbnail) {
                gridContent = `<div class="embed-grid">${gridContent}<img class="embed-thumbnail" src="${escAttr(emb.thumbnail.url)}" alt="" loading="lazy"></div>`;
            }

            let mediaHtml = '';
            if (emb.video && emb.video.url) {
                if (emb.video.url.includes('youtube.com') || emb.video.url.includes('youtu.be')) {
                    const ytId = emb.video.url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([^&?]+)/)?.[1];
                    if (ytId) {
                        mediaHtml = `<div class="embed-video-wrap"><iframe class="embed-video" src="https://www.youtube.com/embed/${ytId}" allowfullscreen></iframe></div>`;
                    }
                } else {
                    mediaHtml = `<div class="embed-video-wrap"><video class="embed-video" src="${escAttr(emb.video.url)}" controls></video></div>`;
                }
            } else if (emb.image) {
                mediaHtml = `<img class="embed-image" src="${escAttr(emb.image.url)}" alt="" loading="lazy">`;
            }

            return `<div class="embed-card"><div class="embed-border" style="background-color: ${color}"></div><div class="embed-inner">${gridContent}${mediaHtml}</div></div>`;
        }

        /* ---------- Deep linking ---------- */

        function handleDeepLink() {
            const hash = decodeURIComponent(location.hash.slice(1));
            if (!hash) {
                if (!overlay.classList.contains('hidden')) closeAuthorModal();
                return;
            }
            const author = allAuthors.find(a =>
                a.username.toLowerCase() === hash.toLowerCase() ||
                a.name.toLowerCase() === hash.toLowerCase()
            );
            if (author) openAuthorModal(author);
        }

        /* ---------- Custom selects ---------- */

        function setupCustomSelects(root) {
            root.querySelectorAll('.custom-select').forEach(customEl => {
                const btn = customEl.querySelector('.select-btn');
                const valSpan = customEl.querySelector('.select-val');
                const options = customEl.querySelectorAll('.select-option');
                const targetSelect = document.getElementById(customEl.dataset.target);

                if (!btn || !targetSelect) return;

                btn.addEventListener('click', e => {
                    e.stopPropagation();
                    document.querySelectorAll('.custom-select.active').forEach(el => {
                        if (el !== customEl) el.classList.remove('active');
                    });
                    customEl.classList.toggle('active');
                });

                options.forEach(opt => {
                    opt.addEventListener('click', e => {
                        e.stopPropagation();
                        targetSelect.value = opt.dataset.value;
                        customEl.querySelectorAll('.select-option').forEach(o => o.classList.remove('selected'));
                        opt.classList.add('selected');
                        valSpan.textContent = opt.textContent;
                        targetSelect.dispatchEvent(new Event('change'));
                        customEl.classList.remove('active');
                    });
                });
            });

            if (root === document) {
                docClickHandler = () => {
                    document.querySelectorAll('.custom-select.active').forEach(el => el.classList.remove('active'));
                };
                document.addEventListener('click', docClickHandler);
            }
        }

        /* ---------- Global handlers ---------- */

        const onHashChange = handleDeepLink;
        window.addEventListener('hashchange', onHashChange);

        const onSearchInput = debounce(e => {
            searchQuery = e.target.value.trim();
            render();
        }, 200);
        searchInput?.addEventListener('input', onSearchInput);

        const onSortChange = e => {
            sortMode = e.target.value;
            render();
        };
        sortEl?.addEventListener('change', onSortChange);

        $('am-close')?.addEventListener('click', closeAuthorModal);
        $('pm-close')?.addEventListener('click', closePluginModal);

        overlay?.addEventListener('click', e => {
            if (e.target === overlay) closeAuthorModal();
        });

        pluginOverlay?.addEventListener('click', e => {
            if (e.target === pluginOverlay) closePluginModal();
        });

        const onKeyDown = e => {
            if (e.key === 'Escape') {
                if (!pluginOverlay.classList.contains('hidden')) closePluginModal();
                else if (!overlay.classList.contains('hidden')) closeAuthorModal();
            }
            if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
                e.preventDefault();
                searchInput?.focus();
            }
        };
        document.addEventListener('keydown', onKeyDown);

        /* ---------- Start ---------- */

        setupCustomSelects(document);
        load();

        cleanup = () => {
            isAborted = true;
            window.removeEventListener('hashchange', onHashChange);
            document.removeEventListener('keydown', onKeyDown);
            if (docClickHandler) {
                document.removeEventListener('click', docClickHandler);
                docClickHandler = null;
            }
            scrollLockCount = 0;
            document.body.style.overflow = '';
        };
        window.currentRouteCleanup = cleanup;
    };
})();