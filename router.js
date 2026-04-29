(() => {
    'use strict';

    // Wait for DOM
    document.addEventListener('DOMContentLoaded', () => {
        // Init mobile menu globally
        initMobileMenu();

        // Check if we need to load any script dynamically for the current route on first load
        // Only if it wasn't loaded (e.g. going directly to /authors.html loads authors.js natively)
        
        // Hook link clicks
        document.body.addEventListener('click', e => {
            const a = e.target.tagName === 'A' ? e.target : e.target.closest('A');
            if (a && a.origin === location.origin && !a.getAttribute('download') && a.target !== '_blank') {
                // Allow hash links on the same page to work natively
                if (a.hash && a.pathname === location.pathname) {
                    return;
                }
                
                // Allow deep linking between pages, but handle the routing
                e.preventDefault();
                navigate(a.href);
            }
        });

        // Hook back/forward buttons
        window.addEventListener('popstate', () => {
            navigate(location.href, false);
        });
        
        // Set initial active link
        updateActiveNavbarLink();
    });

    function initMobileMenu() {
        const btn = document.getElementById('burger-btn');
        const links = document.getElementById('header-links');
        if (btn && links) {
            // Remove old listeners by replacing clone
            const newBtn = btn.cloneNode(true);
            btn.parentNode.replaceChild(newBtn, btn);
            newBtn.addEventListener('click', function () {
                newBtn.classList.toggle('active');
                links.classList.toggle('open');
            });
        }
    }

    async function navigate(url, push = true) {
        if (push) history.pushState({}, '', url);

        const contentArea = document.getElementById('content-area');
        if (!contentArea) {
            window.location.href = url;
            return;
        }

        // Cleanup previous page
        if (typeof window.currentRouteCleanup === 'function') {
            window.currentRouteCleanup();
            window.currentRouteCleanup = null;
        }

        contentArea.style.opacity = '0.5';
        contentArea.style.transition = 'opacity 0.2s';

        try {
            const res = await fetch(url);
            const html = await res.text();
            const doc = new DOMParser().parseFromString(html, 'text/html');

            document.title = doc.title;

            const existingLinks = Array.from(document.querySelectorAll('link[rel="stylesheet"]')).map(l => l.href);
            const existingStyles = Array.from(document.querySelectorAll('style')).map(s => s.innerHTML);

            doc.querySelectorAll('link[rel="stylesheet"]').forEach(link => {
                if (!existingLinks.includes(link.href)) {
                    const newLink = document.createElement('link');
                    newLink.rel = 'stylesheet';
                    newLink.href = link.href;
                    document.head.appendChild(newLink);
                }
            });

            doc.querySelectorAll('style').forEach(style => {
                if (!existingStyles.includes(style.innerHTML)) {
                    const newStyle = document.createElement('style');
                    newStyle.innerHTML = style.innerHTML;
                    document.head.appendChild(newStyle);
                }
            });

            const newContent = doc.getElementById('content-area');
            if (newContent) {
                contentArea.innerHTML = newContent.innerHTML;
            } else {
                window.location.href = url;
                return;
            }

            // Use shared routing logic
            handleRoute(url);

            // Close mobile menu
            const btn = document.getElementById('burger-btn');
            const links = document.getElementById('header-links');
            if (btn) btn.classList.remove('active');
            if (links) links.classList.remove('open');

            // Handle hash after load
            const urlObj = new URL(url, location.origin);
            if (urlObj.hash) {
                setTimeout(() => window.dispatchEvent(new Event('hashchange')), 100);
            } else {
                window.scrollTo(0, 0);
            }
            
            updateActiveNavbarLink();

        } catch (e) {
            console.error("Routing error:", e);
            window.location.href = url;
        } finally {
            contentArea.style.opacity = '1';
        }
    }

    function handleRoute(url) {
        const urlObj = new URL(url, location.origin);
        let path = urlObj.pathname;
        if (path.endsWith('.html')) path = path.slice(0, -5);
        if (path.endsWith('/') && path !== '/') path = path.slice(0, -1);

        if (path === '/' || path === '/index' || path === '') {
            if (window.initHome) window.initHome();
            else loadScript('app.js', () => window.initHome && window.initHome());
        } else if (path === '/authors') {
            if (window.initAuthors) window.initAuthors();
            else loadScript('authors.js', () => window.initAuthors && window.initAuthors());
        } else if (path === '/maker') {
            if (window.initMaker) window.initMaker();
            else loadScript('maker.js', () => window.initMaker && window.initMaker());
        } else if (path === '/api' || path === '/tutorial') {
            if (path === '/tutorial') initTutorial();
            
            // Check if they need prism.js for highlighting
            if (document.querySelector('script[src*="prism.min.js"]') || document.querySelector('pre code')) {
                if (!window.Prism) {
                    loadScript('https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js', () => {
                        loadScript('https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-lua.min.js', () => {
                            if (window.Prism) Prism.highlightAll();
                        });
                    });
                } else {
                    Prism.highlightAll();
                }
            }
        }
    }

    async function initTutorial() {
        const list = document.getElementById('executor-list');
        if (!list) return;

        try {
            // Use abort controller to prevent multiple simultaneous fetches
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 8000);
            
            const res = await fetch('https://weao.xyz/api/status/exploits', { signal: controller.signal });
            clearTimeout(timeoutId);
            
            const data = await res.json();
            
            if (!Array.isArray(data)) throw new Error('Invalid data');

            // Sort by popularity/relevance (some have high index) and update status
            const exploits = data
                .filter(ex => !ex.hidden)
                .sort((a, b) => {
                    // Updated first, then by index, then by title
                    if (a.updateStatus !== b.updateStatus) return b.updateStatus ? 1 : -1;
                    if (a.index !== b.index) return (b.index || 0) - (a.index || 0);
                    return a.title.localeCompare(b.title);
                });

            list.innerHTML = exploits.map(ex => {
                const isFree = ex.free === true;
                const priceLabel = isFree ? 'Free' : (ex.cost || 'Paid');
                const priceClass = isFree ? 'price-free' : 'price-paid';

                return `
                <div class="executor-item">
                    <div class="executor-main">
                        <a href="${ex.websitelink || 'https://weao.gg'}" target="_blank" class="executor-name">${ex.title}</a>
                        <div style="font-size: 0.65rem; color: var(--text3); margin-top: 2px;">${ex.version || 'Unknown version'}</div>
                    </div>
                    <div class="executor-meta">
                        <span class="price-badge ${priceClass}">${priceLabel}</span>
                        <span class="executor-platform">${ex.platform}</span>
                        <span class="status-badge ${ex.updateStatus ? 'status-updated' : 'status-outdated'}">
                            ${ex.updateStatus ? 'Updated' : 'Outdated'}
                        </span>
                    </div>
                </div>
            `;
            }).join('');

        } catch (e) {
            console.error('WEAO API Error:', e);
            list.innerHTML = `
                <div class="executor-error">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="opacity: 0.5">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <span>Could not load live status.</span>
                    <a href="https://weao.gg" target="_blank" class="h-btn btn-alt" style="margin-top: 8px; font-size: 0.8rem; padding: 6px 12px;">View on WEAO.gg</a>
                </div>
            `;
        }
    }

    function loadScript(src, callback) {
        let existingScript = document.querySelector(`script[src="${src}"]`);
        if (existingScript) {
            if (existingScript.dataset.loaded) {
                if (callback) callback();
            } else if (callback) {
                existingScript.addEventListener('load', callback);
            }
            return;
        }
        const s = document.createElement('script');
        s.src = src;
        s.onload = () => {
            s.dataset.loaded = 'true';
            if (callback) callback();
        };
        document.body.appendChild(s);
    }
    
    function updateActiveNavbarLink() {
        const links = document.querySelectorAll('.header-links .h-link');
        const path = window.location.pathname;
        links.forEach(link => {
            const url = new URL(link.href);
            if(url.pathname === path) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    // Global utility for api.html and others
    window.copyCode = function(btn) {
        const pre = btn.closest('.api-code').querySelector('pre code');
        if (!pre) return;
        const text = pre.innerText;
        navigator.clipboard.writeText(text).then(() => {
            const original = btn.innerText;
            btn.innerText = 'Copied!';
            btn.classList.add('copied');
            setTimeout(() => {
                btn.innerText = original;
                btn.classList.remove('copied');
            }, 2000);
        });
    };

    window.copyFAQLink = function(id, btn) {
        const url = window.location.origin + window.location.pathname + '#' + id;
        navigator.clipboard.writeText(url).then(() => {
            btn.classList.add('copied');
            setTimeout(() => {
                btn.classList.remove('copied');
            }, 2000);
        });
    };

    // Handle hash scrolling
    window.addEventListener('hashchange', () => {
        const hash = window.location.hash;
        if (hash) {
            const el = document.querySelector(hash);
            if (el) {
                setTimeout(() => {
                    el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    el.style.borderColor = 'var(--accent)';
                    setTimeout(() => el.style.borderColor = '', 2000);
                }, 100);
            }
        }
    });

    // Perform initial routing on load
    handleRoute(location.href);
})();
