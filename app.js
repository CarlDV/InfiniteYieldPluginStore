(() => {
    'use strict';

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

    async function init() {
        try {
            const res = await fetch('data/plugins.json');
            const data = await res.json();
            allPlugins = data.plugins || [];
            $('stat-total').textContent = allPlugins.length;
            const authors = new Set(allPlugins.map(p => p.author?.username).filter(Boolean));
            $('stat-authors').textContent = authors.size;

            if (data.scraped_at) {
                const scrapedDate = new Date(data.scraped_at);
                const updateLiveTime = () => {
                    const diff = Math.floor((new Date() - scrapedDate) / 1000);
                    if (diff < 0) {
                        $('stat-updated').textContent = 'Just now';
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

                    $('stat-updated').textContent = str;
                    $('stat-updated').title = scrapedDate.toLocaleString();
                };
                updateLiveTime();
                setInterval(updateLiveTime, 1000);
            } else {
                $('stat-updated').textContent = 'Unknown';
            }

            loading.classList.add('hidden');

            const observer = new IntersectionObserver((entries) => {
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

    window.addEventListener('hashchange', handleDeepLink);

    function render() {
        let list = [...allPlugins];

        if (query) {
            const q = query.toLowerCase();
            list = list.filter(p =>
                (p.name || '').toLowerCase().includes(q)
            );
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

        pageItems.forEach(p => {
            const card = document.createElement('div');
            card.className = 'card';

            // Avatar
            const initial = (p.author?.name || '?')[0].toUpperCase();
            const authorName = p.author?.name || 'Unknown';
            let avatarHTML;
            if (p.author?.avatar) {
                avatarHTML = `<img class="card-avatar" src="${escAttr(p.author.avatar)}" alt="" loading="lazy" onerror="this.outerHTML='<div class=\\'card-avatar-ph\\'>${esc(initial)}</div>'">`;
            } else {
                avatarHTML = `<div class="card-avatar-ph">${esc(initial)}</div>`;
            }

            // Description
            let desc = (p.description || '').replace(/```[\s\S]*?```/g, '').replace(/[*_~`#]/g, '').trim();
            if (!desc && p.files?.length) desc = p.files.map(a => a.filename).join(', ');

            // Tags
            let tags = '';
            if (p.files?.some(a => a.is_plugin)) tags += '<span class="tag tag-file">📁 File</span>';
            if (p.code_blocks?.length) tags += '<span class="tag tag-code">⟨/⟩ Code</span>';
            if (p.links?.length) tags += '<span class="tag tag-link">🔗 Link</span>';
            if (p.loadstring_urls?.length) tags += '<span class="tag tag-loadstring">⚡ Loadstring</span>';

            let dateColor = 'inherit';
            if (p.date) {
                const ms = new Date(p.date).getTime();
                if (!isNaN(ms)) {
                    const now = Date.now();
                    const oneYearAgo = now - ONE_YEAR_MS;
                    const ratio = Math.max(0, Math.min(1, (ms - oneYearAgo) / (now - oneYearAgo)));
                    const hue = ratio * 120; // 0 for >1yr old (red), 120 for newest (green)
                    dateColor = `hsl(${hue}, 80%, 65%)`;
                }
            }

            card.innerHTML = `
                <div class="card-header">
                    ${avatarHTML}
                    <div class="card-info">
                        <div class="card-name">${esc(p.name || 'Untitled')}</div>
                        <div class="card-author">${esc(authorName)}</div>
                    </div>
                    <div class="card-date" style="color: ${dateColor}; font-weight: 500;">${fmtDate(p.date)}</div>
                </div>
                <div class="card-desc">${esc(desc || 'No description')}</div>
                <div class="card-footer">
                    <div class="card-tags">${tags}</div>
                    <button class="card-share" title="Copy link">🔗</button>
                </div>
            `;

            card.querySelector('.card-share').addEventListener('click', (e) => {
                e.stopPropagation();
                const url = `${location.origin}${location.pathname}#${encodeURIComponent(p.id)}`;
                navigator.clipboard.writeText(url).then(() => {
                    const btn = e.currentTarget;
                    btn.textContent = '✅';
                    setTimeout(() => btn.textContent = '🔗', 1500);
                });
            });

            card.onclick = () => {
                openModal(p);
            };
            grid.appendChild(card);
        });

        currentPage++;
    }

    // ---- Modal ----
    function openModal(p) {
        history.replaceState(null, '', `#${encodeURIComponent(p.id)}`);
        // Avatar in modal
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

        // Loadstring URLs section
        if (p.loadstring_urls?.length) {
            html += `<div class="section"><div class="section-label">⚡ Loadstring URLs (${p.loadstring_urls.length})</div>`;
            p.loadstring_urls.forEach(url => {
                html += `<a class="loadstring-link" href="${escAttr(url)}" target="_blank" rel="noopener" onclick="event.stopPropagation()">${esc(url)}</a>`;
            });
            html += `</div>`;
        }

        let text = (p.description || '').trim();

        if (text) {
            html += `<div class="section"><div class="section-label">Description</div><div class="section-text">${discordFormat(text, p.id)}</div></div>`;
        }

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
                    <div class="att-actions">
                        ${prevBtn}
                        ${dlBtn}
                    </div>
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

            // Render Embeds first
            if (p.embeds?.length) {
                p.embeds.forEach(emb => {
                    html += renderEmbed(emb);
                });
            }

            // Render raw links that aren't already embedded (optional, but good for safety)
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

        // Download handlers
        $('m-body').querySelectorAll('.att-dl-btn').forEach(btn => {
            btn.onclick = e => {
                e.stopPropagation();
                const parts = btn.dataset.id.split('-');
                const pId = parts[1];
                const aIdx = parseInt(parts[2]);
                const plugin = allPlugins.find(p => p.id === pId);
                const attachment = plugin?.files?.[aIdx];

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
        overlay.classList.add('hidden');
        document.body.style.overflow = '';
        history.replaceState(null, '', location.pathname + location.search);
    }

    // ---- Events ----
    search.addEventListener('input', debounce(e => { query = e.target.value.trim(); render(); }, 200));
    sortEl.addEventListener('change', e => { sort = e.target.value; render(); });
    $('m-close').addEventListener('click', closeModal);
    overlay.addEventListener('click', e => { if (e.target === overlay) closeModal(); });
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') closeModal();
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') { e.preventDefault(); search.focus(); }
    });


    // ZIP Download All
    const dlAllBtn = $('dl-all');
    if (dlAllBtn) {
        dlAllBtn.addEventListener('click', async () => {
            const originalHTML = dlAllBtn.innerHTML;
            dlAllBtn.textContent = 'Zipping files...';
            dlAllBtn.disabled = true;

            try {
                if (!window.JSZip) throw new Error("JSZip library not loaded");
                const zip = new JSZip();
                const names = new Set();
                let count = 0;

                allPlugins.forEach(p => {
                    if (p.files) {
                        p.files.forEach(a => {
                            if (a.is_plugin && a.code && a.code.trim()) {
                                let name = a.filename;
                                if (names.has(name)) {
                                    const base = name.replace(/\.[^/.]+$/, "");
                                    const ext = name.substring(base.length);
                                    let counter = 1;
                                    while (names.has(`${base}_${counter}${ext}`)) { counter++; }
                                    name = `${base}_${counter}${ext}`;
                                }
                                names.add(name);
                                zip.file(name, a.code);
                                count++;
                            }
                        });
                    }
                });

                if (count === 0) throw new Error("No attachments found to zip.");

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
                alert('Failed to generate zip: ' + err.message);
            } finally {
                dlAllBtn.innerHTML = originalHTML;
                dlAllBtn.disabled = false;
            }
        });
    }

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
            // Very basic video handling, usually requires iframe for youtube/etc
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

        // Collapse 3 or more newlines (even with spaces) into just 2 newlines
        text = text.replace(/\n\s*\n\s*\n+/g, '\n\n');

        // Split by code blocks ```...```
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

                // Headings
                html = html.replace(/^###\s+(.*)$/gim, '<h5>$1</h5>');
                html = html.replace(/^##\s+(.*)$/gim, '<h4>$1</h4>');
                html = html.replace(/^#\s+(.*)$/gim, '<h3>$1</h3>');

                // Bold: **text**
                html = html.replace(/\*\*([^\*]+)\*\*/g, '<strong>$1</strong>');
                // Underline: __text__
                html = html.replace(/__([^_]+)__/g, '<u>$1</u>');
                // Italics: *text* or _text_
                html = html.replace(/\*([^\*]+)\*/g, '<em>$1</em>');
                html = html.replace(/_([^_]+)_/g, '<em>$1</em>');
                // Strikethrough: ~~text~~
                html = html.replace(/~~([^~]+)~~/g, '<s>$1</s>');
                // Spoiler: ||text||
                html = html.replace(/\|\|([\s\S]+?)\|\|/g, (match, $1) => `<span class="spoiler" onclick="this.classList.toggle('revealed')">${$1}</span>`);
                // Inline code: `text`
                html = html.replace(/`([^`]+)`/g, '<code class="inline-code">$1</code>');

                // Cleanup trailing # from headings
                html = html.replace(/(<\/h[3-5]>)(\s*#+)/gi, '$1');

                // Convert double newlines to paragraph breaks, single newlines to <br>
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
})();
