/* ============================================================
   Router — SPA navigation + page initializers
   Clean rewrite: no sound effects, no heavy animations.
   ============================================================ */

(() => {
    'use strict';

    document.addEventListener('DOMContentLoaded', () => {
        document.body.addEventListener('click', e => {
            const a = e.target.tagName === 'A' ? e.target : e.target.closest('A');
            if (a && a.origin === location.origin && !a.getAttribute('download') && a.target !== '_blank') {
                if (a.hash && a.pathname === location.pathname) {
                    e.preventDefault();
                    history.pushState(null, null, a.hash);
                    const el = document.querySelector(a.hash);
                    if (el) {
                        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }
                    return;
                }

                e.preventDefault();
                navigate(a.href);
            }
        });

        window.addEventListener('popstate', () => {
            navigate(location.href, false);
        });

        updateActiveNavbarLink();

        if (location.hash) {
            setTimeout(() => window.dispatchEvent(new Event('hashchange')), 200);
        }
    });

    async function navigate(url, push = true) {
        if (push) history.pushState({}, '', url);

        const contentArea = document.getElementById('content-area');
        if (!contentArea) {
            window.location.href = url;
            return;
        }

        if (window.clearRevealObserver) window.clearRevealObserver();
        if (typeof window.currentRouteCleanup === 'function') {
            window.currentRouteCleanup();
            window.currentRouteCleanup = null;
        }

        contentArea.style.opacity = '0.4';
        contentArea.style.transition = 'opacity 0.15s ease';

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

            const newHeader = doc.querySelector('header');
            const currentHeader = document.querySelector('header');
            if (newHeader && currentHeader) {
                currentHeader.innerHTML = newHeader.innerHTML;
            }

            handleRoute(url);

            const urlObj = new URL(url, location.origin);
            if (urlObj.hash) {
                setTimeout(() => window.dispatchEvent(new Event('hashchange')), 100);
            } else {
                window.scrollTo(0, 0);
            }

            updateActiveNavbarLink();
        } catch (e) {
            console.error('Routing error:', e);
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
            else loadScript('js/app.js?v=3', () => window.initHome && window.initHome());
        } else if (path === '/authors') {
            if (window.initAuthors) window.initAuthors();
            else loadScript('js/authors.js?v=3', () => window.initAuthors && window.initAuthors());
        } else if (path === '/maker') {
            if (window.initMaker) window.initMaker();
            else loadScript('js/maker.js?v=3', () => window.initMaker && window.initMaker());
        } else if (path === '/api' || path === '/tutorial') {
            if (path === '/tutorial') initTutorial();
            if (path === '/api') initApi();

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

    function initApi() {
        const sidebarLinks = document.querySelectorAll('.sidebar-link');
        const sections = document.querySelectorAll('.docs-section, .docs-hero');

        if (!sidebarLinks.length || !sections.length) return;

        function makeActive(link) {
            sidebarLinks.forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        }

        sidebarLinks.forEach(link => {
            link.addEventListener('click', () => makeActive(link));
        });

        const observerOptions = {
            root: null,
            rootMargin: '0px 0px -60% 0px',
            threshold: 0
        };

        const observer = new IntersectionObserver(entries => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const id = entry.target.id;
                    if (!id) return;
                    const activeLink = document.querySelector(`.sidebar-link[href="#${id}"]`);
                    if (activeLink) makeActive(activeLink);
                }
            });
        }, observerOptions);

        sections.forEach(section => {
            if (section.id) {
                observer.observe(section);
            } else {
                const heading = section.querySelector('h1[id], h2[id]');
                if (heading) observer.observe(heading);
            }
        });

        window.currentRouteCleanup = () => {
            observer.disconnect();
        };
    }

    async function initTutorial() {
        const list = document.getElementById('executor-list');
        if (!list) return;

        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 8000);

            const res = await fetch('https://weao.xyz/api/status/exploits', { signal: controller.signal });
            clearTimeout(timeoutId);

            const data = await res.json();

            if (!Array.isArray(data)) throw new Error('Invalid data');

            const exploits = data
                .filter(ex => !ex.hidden)
                .sort((a, b) => {
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
                        <a href="${ex.websitelink || 'https://weao.gg'}" target="_blank" rel="noopener" class="executor-name">${ex.title}</a>
                        <div style="font-size: 0.7rem; color: var(--text3); margin-top: 2px;">${ex.version || 'Unknown version'}</div>
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
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="opacity: 0.5">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <span>Could not load live status.</span>
                    <a href="https://weao.gg" target="_blank" rel="noopener" class="btn btn-secondary btn-sm" style="margin-top: 8px;">View on WEAO.gg</a>
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
            if (url.pathname === path) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    /* ---- Clipboard helpers ---- */
    window.copyCode = function (btn) {
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

    window.copyFAQLink = function (id, btn) {
        const url = window.location.origin + window.location.pathname + '#' + id;
        navigator.clipboard.writeText(url).then(() => {
            btn.classList.add('copied');
            setTimeout(() => {
                btn.classList.remove('copied');
            }, 2000);
        });
    };

    /* ---- Reveal (lightweight: single observer, no sounds, no stagger queue) ---- */
    const revealObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                revealObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.05, rootMargin: '0px 0px -24px 0px' });

    window.registerReveal = function (elements) {
        if (!elements) return;
        let items;
        if (typeof elements === 'string') {
            items = document.querySelectorAll(elements);
        } else if (elements instanceof NodeList || Array.isArray(elements)) {
            items = elements;
        } else if (elements.tagName || elements.nodeType) {
            items = [elements];
        } else if (typeof elements.forEach === 'function') {
            items = elements;
        } else {
            return;
        }
        items.forEach(el => {
            if (el.classList.contains('reveal-item')) return;
            el.classList.add('reveal-item');
            revealObserver.observe(el);
        });
    };

    window.clearRevealObserver = function () {
        revealObserver.disconnect();
    };

    /* ---- No-op sound API (kept for backwards compatibility with older scripts) ---- */
    const noop = () => {};
    window.playSuccess = noop;
    window.playClick = noop;
    window.playHover = noop;
    window.playTransition = noop;
    window.playReveal = noop;
    window.playError = noop;
    window.playType = noop;

    window.addEventListener('hashchange', () => {
        const hash = window.location.hash;
        if (hash) {
            const el = document.querySelector(hash);
            if (el) {
                setTimeout(() => {
                    el.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }, 100);
            }
        }
    });

    handleRoute(location.href);
})();