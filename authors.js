(() => {
    'use strict';

    let allAuthors = [];
    let allPlugins = [];
    let filteredAuthors = [];
    let searchQuery = '';
    let sortMode = 'plugins';

    const $ = id => document.getElementById(id);
    const grid = $('authors-grid');
    const loading = $('authors-loading');
    const empty = $('authors-empty');
    const searchInput = $('author-search');
    const sortEl = $('author-sort');
    const overlay = $('author-overlay');

    async function init() {
        try {
            const res = await fetch('data/plugins.json');
            const data = await res.json();
            allPlugins = data.plugins || [];

            // Build unique authors map
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
                // Track latest plugin date
                if (p.date) {
                    const d = new Date(p.date);
                    if (!author.latestDate || d > author.latestDate) {
                        author.latestDate = d;
                    }
                }
                // Use best available avatar
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

    function handleDeepLink() {
        const hash = decodeURIComponent(location.hash.slice(1));
        if (!hash) return;
        const author = allAuthors.find(a =>
            a.username.toLowerCase() === hash.toLowerCase() ||
            a.name.toLowerCase() === hash.toLowerCase()
        );
        if (author) openAuthorModal(author);
    }

    window.addEventListener('hashchange', handleDeepLink);

    function render() {
        let list = [...allAuthors];

        // Filter
        if (searchQuery) {
            const q = searchQuery.toLowerCase();
            list = list.filter(a =>
                a.name.toLowerCase().includes(q) ||
                a.username.toLowerCase().includes(q)
            );
        }

        // Sort
        if (sortMode === 'plugins') {
            list.sort((a, b) => b.plugins.length - a.plugins.length);
        } else if (sortMode === 'name') {
            list.sort((a, b) => a.name.localeCompare(b.name));
        } else if (sortMode === 'recent') {
            list.sort((a, b) => (b.latestDate || 0) - (a.latestDate || 0));
        }

        filteredAuthors = list;
        grid.innerHTML = '';
        empty.classList.toggle('hidden', list.length > 0);

        list.forEach(author => {
            const card = document.createElement('div');
            card.className = 'author-card';

            const initial = (author.name || '?')[0].toUpperCase();
            let avatarHTML;
            if (author.avatar) {
                avatarHTML = `<img class="author-card-avatar" src="${escAttr(author.avatar)}" alt="" loading="lazy" onerror="this.outerHTML='<div class=\\'author-card-avatar-ph\\'>${esc(initial)}</div>'">`;
            } else {
                avatarHTML = `<div class="author-card-avatar-ph">${esc(initial)}</div>`;
            }

            const usernameDisplay = author.username !== author.name ? `<div class="author-card-username">@${esc(author.username)}</div>` : '<div class="author-card-username">&nbsp;</div>';

            card.innerHTML = `
                ${avatarHTML}
                <div class="author-card-name">${esc(author.name)}</div>
                ${usernameDisplay}
                <div class="author-card-meta">
                    <div class="author-card-stat">
                        <span class="author-card-stat-num">${author.plugins.length}</span>
                        <span class="author-card-stat-lbl">${author.plugins.length === 1 ? 'plugin' : 'plugins'}</span>
                    </div>
                    ${author.latestDate ? `
                    <div class="sep"></div>
                    <div class="author-card-stat">
                        <span class="author-card-stat-lbl">Latest:</span>
                        <span class="author-card-stat-num" style="font-size:0.78rem">${fmtDate(author.latestDate)}</span>
                    </div>` : ''}
                </div>
                <button class="author-card-share" title="Copy link">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                        <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                    </svg>
                </button>
            `;

            // Share button
            card.querySelector('.author-card-share').addEventListener('click', (e) => {
                e.stopPropagation();
                const url = `${location.origin}${location.pathname}#${encodeURIComponent(author.username)}`;
                navigator.clipboard.writeText(url).then(() => {
                    const btn = e.currentTarget;
                    btn.innerHTML = '✅';
                    setTimeout(() => btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>', 1500);
                });
            });

            card.onclick = () => openAuthorModal(author);
            grid.appendChild(card);
        });
    }

    function openAuthorModal(author) {
        history.replaceState(null, '', `#${encodeURIComponent(author.username)}`);

        const initial = (author.name || '?')[0].toUpperCase();
        const avatarWrap = $('am-avatar-wrap');
        if (author.avatar) {
            avatarWrap.innerHTML = `<img class="author-modal-avatar" src="${escAttr(author.avatar)}" alt="">`;
        } else {
            avatarWrap.innerHTML = `<div class="author-modal-avatar-ph">${esc(initial)}</div>`;
        }

        const usernameLine = author.username !== author.name
            ? `<div class="author-modal-username">@${esc(author.username)}</div>`
            : '';

        // Earliest and latest dates
        let earliest = null, latest = null;
        author.plugins.forEach(p => {
            if (p.date) {
                const d = new Date(p.date);
                if (!earliest || d < earliest) earliest = d;
                if (!latest || d > latest) latest = d;
            }
        });

        let specialNotice = '';
        if (author.name === 'Deleted User' || author.username === 'Deleted User') {
            specialNotice = `<div style="margin: 12px 0; padding: 10px 12px; background: rgba(237, 66, 69, 0.1); border-left: 3px solid #ed4245; border-radius: 4px; font-size: 0.85rem; color: #f2f3f5; line-height: 1.4;">
                <strong style="color: #ed4245;">Note:</strong> This profile is a combination of multiple different authors whose accounts have been deleted.
            </div>`;
        }

        $('am-info').innerHTML = `
            <h2>${esc(author.name)}</h2>
            ${usernameLine}
            ${specialNotice}
            <div class="author-modal-stats">
                <span><strong>${author.plugins.length}</strong> ${author.plugins.length === 1 ? 'plugin' : 'plugins'}</span>
                ${earliest ? `<span><strong>First:</strong> ${fmtDate(earliest)}</span>` : ''}
                ${latest ? `<span><strong>Latest:</strong> ${fmtDate(latest)}</span>` : ''}
            </div>
        `;

        // Sort plugins newest first in modal
        const sorted = [...author.plugins].sort((a, b) => new Date(b.date || 0) - new Date(a.date || 0));

        let html = `
            <div class="author-modal-profile" style="justify-content: space-between;">
                <div></div>
                <button class="author-modal-share-btn" id="am-share-btn">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                        <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                    </svg>
                    Share Profile
                </button>
            </div>
            <div class="author-plugins-label">All Plugins (${author.plugins.length})</div>
        `;

        sorted.forEach(p => {
            let tags = '';
            if (p.code_blocks?.length) tags += '<span class="tag tag-code" style="font-size:0.65rem;padding:2px 8px">Code</span>';
            if (p.loadstring_urls?.length) tags += '<span class="tag tag-loadstring" style="font-size:0.65rem;padding:2px 8px">Loadstring</span>';
            if (p.files?.length) tags += '<span class="tag tag-file" style="font-size:0.65rem;padding:2px 8px">' + p.files.length + ' file' + (p.files.length > 1 ? 's' : '') + '</span>';

            html += `
                <div class="author-plugin-item" data-plugin-id="${escAttr(p.id)}">
                    <div class="author-plugin-name">${esc(p.name || 'Untitled')}</div>
                    <div class="author-plugin-tags">${tags}</div>
                    <div class="author-plugin-date">${fmtDate(p.date)}</div>
                </div>
            `;
        });

        $('am-body').innerHTML = html;

        // Share button in modal
        const shareBtn = $('am-share-btn');
        if (shareBtn) {
            shareBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                const url = `${location.origin}${location.pathname}#${encodeURIComponent(author.username)}`;
                navigator.clipboard.writeText(url).then(() => {
                    shareBtn.innerHTML = '✅ Copied!';
                    setTimeout(() => {
                        shareBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg> Share Profile';
                    }, 1500);
                });
            });
        }

        // Plugin click -> preview in floating modal
        $('am-body').querySelectorAll('.author-plugin-item').forEach(item => {
            item.addEventListener('click', () => {
                const pid = item.dataset.pluginId;
                const plugin = allPlugins.find(p => p.id === pid);
                if (plugin) openPluginModal(plugin);
            });
        });

        overlay.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }

    function closeModal() {
        overlay.classList.add('hidden');
        document.body.style.overflow = '';
        history.replaceState(null, '', location.pathname + location.search);
    }

    // Events
    searchInput.addEventListener('input', debounce(e => {
        searchQuery = e.target.value.trim();
        render();
    }, 200));

    // Fix closeModal to close whichever modal is active
    function closePluginModal() {
        $('plugin-overlay').classList.add('hidden');
    }

    sortEl.addEventListener('change', e => {
        sortMode = e.target.value;
        render();
    });

    $('am-close').addEventListener('click', closeModal);
    $('pm-close').addEventListener('click', closePluginModal);
    overlay.addEventListener('click', e => { if (e.target === overlay) closeModal(); });
    $('plugin-overlay').addEventListener('click', e => { if (e.target === $('plugin-overlay')) closePluginModal(); });
    
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') {
            if (!$('plugin-overlay').classList.contains('hidden')) closePluginModal();
            else if (!overlay.classList.contains('hidden')) closeModal();
        }
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') { e.preventDefault(); searchInput.focus(); }
    });

    // Plugin Modal
    const ONE_YEAR_MS = 365.25 * 24 * 60 * 60 * 1000;
    function openPluginModal(p) {
        const pOverlay = $('plugin-overlay');
        const initial = (p.author?.name || '?')[0].toUpperCase();
        const authorName = p.author?.name || 'Unknown';
        
        if (p.author?.avatar) {
            $('pm-avatar').innerHTML = `<img src="${escAttr(p.author.avatar)}" alt="">`;
        } else {
            $('pm-avatar').innerHTML = `<span class="m-avatar-ph">${esc(initial)}</span>`;
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
        $('pm-author').textContent = authorName;
        $('pm-author').className = 'author-click';
        $('pm-author').title = 'View author profile';
        $('pm-author').onclick = (e) => {
            e.stopPropagation();
            closePluginModal(); // Ensure we don't go back, we're already on the author!
        };
        $('pm-date').textContent = fmtDate(p.date);
        $('pm-date').style.color = dateColor;
        $('pm-date').style.fontWeight = '500';

        const msgLink = $('pm-msg-link');
        if (p.message_url) {
            msgLink.href = p.message_url;
            msgLink.classList.remove('hidden');
        } else {
            msgLink.classList.add('hidden');
        }

        let html = '';

        if (p.loadstring_urls?.length) {
            html += `<div class="section"><div class="section-label">⚡ Loadstring URLs (${p.loadstring_urls.length})</div>`;
            p.loadstring_urls.forEach(url => {
                html += `<a class="loadstring-link" href="${escAttr(url)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">${esc(url)}</a>`;
            });
            html += `</div>`;
        }

        let text = (p.description || '').trim();
        if (text) html += `<div class="section"><div class="section-label">Description</div><div class="section-text">${discordFormat(text, p.id)}</div></div>`;

        if (p.files?.length) {
            html += `<div class="section"><div class="section-label">Files</div>`;
            p.files.forEach((a, i) => {
                const isCode = a.filename.toLowerCase().match(/\.(lua|iy|txt)$/);
                const isImage = a.filename.toLowerCase().match(/\.(png|jpg|jpeg|gif|webp)$/);
                const isVideo = a.filename.toLowerCase().match(/\.(mp4|webm|mov)$/);

                const prevBtn = isCode ? `<button class="att-prev-btn" data-url="${escAttr(a.url)}" data-id="prev-${p.id}-${i}">Preview</button>` : '';
                const dlBtn = (isImage || isVideo) ? '' : (isCode ? `<button class="att-dl-btn att-dl" data-id="dl-${p.id}-${i}">Download</button>` : `<a class="att-dl" href="${escAttr(a.url)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">Download</a>`);

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
            html += `</div>`;
        }

        if (p.links?.length || p.embeds?.length) {
            html += `<div class="section"><div class="section-label">Links & Embeds</div>`;
            if (p.embeds?.length) p.embeds.forEach(emb => html += renderEmbed(emb));
            if (p.links?.length) {
                const embeddedUrls = new Set((p.embeds || []).map(e => e.url));
                p.links.forEach(l => {
                    if (!embeddedUrls.has(l)) html += `<a class="link-item" href="${escAttr(l)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">${esc(l)}</a>`;
                });
            }
            html += `</div>`;
        }

        if (!html) html = '<div class="section-text" style="color:var(--text3);text-align:center;padding:24px 0">No details available.</div>';

        $('pm-body').innerHTML = html;

        // Preview handlers
        $('pm-body').querySelectorAll('.att-prev-btn').forEach(btn => {
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
                const attachment = p.files?.[aIdx];

                if (attachment && attachment.code) {
                    codeBlock.textContent = attachment.code;
                    return;
                }

                if (!codeBlock.textContent || codeBlock.textContent === 'Loading...') {
                    codeBlock.textContent = 'Loading...';
                    try {
                        const res = await fetch(btn.dataset.url);
                        if (!res.ok) throw new Error('Fetch failed');
                        codeBlock.textContent = await res.text();
                    } catch (err) {
                        codeBlock.textContent = 'Failed to load preview.';
                    }
                }
            };
        });

        // Download handlers
        $('pm-body').querySelectorAll('.att-dl-btn').forEach(btn => {
            btn.onclick = e => {
                e.stopPropagation();
                const parts = btn.dataset.id.split('-');
                const pId = parts[1];
                const aIdx = parseInt(parts[2]);
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
            };
        });

        // Copy
        $('pm-body').querySelectorAll('.copy-btn').forEach(btn => {
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

        pOverlay.classList.remove('hidden');
    }

    // Utils
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

        if (emb.thumbnail) gridContent = `<div class="embed-grid">${gridContent}<img class="embed-thumbnail" src="${escAttr(emb.thumbnail.url)}" alt="" loading="lazy"></div>`;

        let mediaHtml = '';
        if (emb.video && emb.video.url) {
            if (emb.video.url.includes('youtube.com') || emb.video.url.includes('youtu.be')) {
                const ytId = emb.video.url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([^&?]+)/)?.[1];
                if (ytId) mediaHtml = `<div class="embed-video-wrap"><iframe class="embed-video" src="https://www.youtube.com/embed/${ytId}" allowfullscreen></iframe></div>`;
            } else mediaHtml = `<div class="embed-video-wrap"><video class="embed-video" src="${escAttr(emb.video.url)}" controls></video></div>`;
        } else if (emb.image) mediaHtml = `<img class="embed-image" src="${escAttr(emb.image.url)}" alt="" loading="lazy">`;

        return `<div class="embed-card"><div class="embed-border" style="background-color: ${color}"></div><div class="embed-inner">${gridContent}${mediaHtml}</div></div>`;
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
                return `<div class="code-wrap" style="margin: 12px 0;">
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
                return `<p>${html}</p>`;
            }
        }).join('');
    }

    function debounce(fn, ms) {
        let t;
        return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };
    }

    init();
})();
