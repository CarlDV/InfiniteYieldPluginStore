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
        if (window.playTransition) window.playTransition();
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
            else loadScript('js/app.js?v=2', () => window.initHome && window.initHome());
        } else if (path === '/authors') {
            if (window.initAuthors) window.initAuthors();
            else loadScript('js/authors.js?v=2', () => window.initAuthors && window.initAuthors());
        } else if (path === '/maker') {
            if (window.initMaker) window.initMaker();
            else loadScript('js/maker.js?v=4', () => window.initMaker && window.initMaker());
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

        const hero = document.querySelector('.docs-hero');
        if (window.registerReveal) {
            window.registerReveal(sidebarLinks);
            if (hero) window.registerReveal(hero);
        }

        function makeActive(link) {
            sidebarLinks.forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        }

        sidebarLinks.forEach(link => {
            link.addEventListener('click', () => {
                makeActive(link);
            });
        });

        const observerOptions = {
            root: null,
            rootMargin: '0px 0px -60% 0px',
            threshold: 0
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const id = entry.target.id;
                    if (!id) return;
                    const activeLink = document.querySelector(`.sidebar-link[href="#${id}"]`);
                    if (activeLink) {
                        makeActive(activeLink);
                    }
                }
            });
        }, observerOptions);

        const revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    revealObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

        sections.forEach(section => {
            if (section.id) {
                observer.observe(section);
            } else {
                const heading = section.querySelector('h1[id], h2[id]');
                if (heading) observer.observe(heading);
            }
            if (section.classList.contains('docs-section')) {
                revealObserver.observe(section);
            }
        });

        window.currentRouteCleanup = () => {
            observer.disconnect();
            revealObserver.disconnect();
        };
    }

    async function initTutorial() {
        const hero = document.querySelector('.tutor-hero');
        if (hero && window.registerReveal) window.registerReveal(hero);

        if (window.registerReveal) {
            window.registerReveal(document.querySelectorAll('.tutor-card, .faq-item, .weao-notice'));
        }

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

            if (window.registerReveal) {
                window.registerReveal(document.querySelectorAll('.executor-item'));
            }

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
            if (url.pathname === path) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        });
    }

    let audioCtx = null;
    function getAudioCtx() {
        if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
        return audioCtx;
    }

    let lastHoverTime = 0;
    function playHover() {
        const nowTime = Date.now();
        if (nowTime - lastHoverTime < 80) return;
        lastHoverTime = nowTime;
        try {
            const ctx = getAudioCtx();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sine';
            const now = ctx.currentTime;
            osc.frequency.setValueAtTime(150, now);
            osc.frequency.exponentialRampToValueAtTime(10, now + 0.01);
            gain.gain.setValueAtTime(0.015, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.01);
            osc.start(now);
            osc.stop(now + 0.01);
        } catch (_) {}
    }

    function playClick() {
        try {
            const ctx = getAudioCtx();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'triangle';
            const now = ctx.currentTime;
            osc.frequency.setValueAtTime(250, now);
            osc.frequency.exponentialRampToValueAtTime(80, now + 0.04);
            gain.gain.setValueAtTime(0.5, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
            osc.start(now);
            osc.stop(now + 0.04);
        } catch (_) {}
    }

    function playSuccess() {
        try {
            const ctx = getAudioCtx();
            const now = ctx.currentTime;
            const playTone = (freq, start, duration, type = 'sine', gainVal = 0.45) => {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.type = type;
                osc.frequency.setValueAtTime(freq, start);
                gain.gain.setValueAtTime(gainVal, start);
                gain.gain.exponentialRampToValueAtTime(0.001, start + duration);
                osc.start(start);
                osc.stop(start + duration);
            };
            playTone(1046.50, now, 0.12, 'sine', 0.12);
            playTone(1318.51, now + 0.04, 0.12, 'sine', 0.12);
            playTone(1567.98, now + 0.08, 0.15, 'sine', 0.12);
            playTone(2093.00, now + 0.12, 0.3, 'sine', 0.1);

            const osc2 = ctx.createOscillator();
            const gain2 = ctx.createGain();
            osc2.connect(gain2);
            gain2.connect(ctx.destination);
            osc2.type = 'sine';
            osc2.frequency.setValueAtTime(261.63, now);
            osc2.frequency.exponentialRampToValueAtTime(523.25, now + 0.25);
            gain2.gain.setValueAtTime(0.22, now);
            gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
            osc2.start(now);
            osc2.stop(now + 0.25);
        } catch (_) {}
    }

    function playTransition() {
        try {
            const ctx = getAudioCtx();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sine';
            const now = ctx.currentTime;
            osc.frequency.setValueAtTime(300, now);
            osc.frequency.exponentialRampToValueAtTime(600, now + 0.15);
            gain.gain.setValueAtTime(0.4, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
            osc.start(now);
            osc.stop(now + 0.15);
        } catch (_) {}
    }

    function playReveal(delay = 0) {
        try {
            const ctx = getAudioCtx();
            const now = ctx.currentTime + delay;
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sine';
            osc.frequency.setValueAtTime(450, now);
            osc.frequency.exponentialRampToValueAtTime(120, now + 0.05);
            gain.gain.setValueAtTime(0.03, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);
            osc.start(now);
            osc.stop(now + 0.05);
        } catch (_) {}
    }

    function playError() {
        try {
            const ctx = getAudioCtx();
            const now = ctx.currentTime;
            const playTone = (freq, start, duration) => {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.type = 'sine';
                osc.frequency.setValueAtTime(freq, start);
                gain.gain.setValueAtTime(0.4, start);
                gain.gain.exponentialRampToValueAtTime(0.001, start + duration);
                osc.start(start);
                osc.stop(start + duration);
            };
            playTone(180, now, 0.12);
            playTone(150, now + 0.1, 0.18);
        } catch (_) {}
    }

    function playType() {
        try {
            const ctx = getAudioCtx();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sine';
            const now = ctx.currentTime;
            const freq = 350 + Math.random() * 100;
            osc.frequency.setValueAtTime(freq, now);
            osc.frequency.exponentialRampToValueAtTime(10, now + 0.015);
            gain.gain.setValueAtTime(0.12, now);
            gain.gain.exponentialRampToValueAtTime(0.001, now + 0.015);
            osc.start(now);
            osc.stop(now + 0.015);
        } catch (_) {}
    }

    window.playSuccess = playSuccess;
    window.playClick = playClick;
    window.playHover = playHover;
    window.playTransition = playTransition;
    window.playReveal = playReveal;
    window.playError = playError;
    window.playType = playType;

    let intersectQueue = [];
    let intersectTimeout = null;

    const revealObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                intersectQueue.push(entry.target);
                revealObserver.unobserve(entry.target);
                
                if (!intersectTimeout) {
                    intersectTimeout = setTimeout(() => {
                        intersectQueue
                            .sort((a, b) => {
                                const rectA = a.getBoundingClientRect();
                                const rectB = b.getBoundingClientRect();
                                return (rectA.top - rectB.top) || (rectA.left - rectB.left);
                            })
                            .forEach((el, index) => {
                                const delay = index * 0.05;
                                el.style.animation = `fade-in-up 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) ${delay}s forwards`;
                                playReveal(delay);
                            });
                        intersectQueue = [];
                        intersectTimeout = null;
                    }, 40);
                }
            }
        });
    }, { threshold: 0.05 });

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
            el.classList.add('reveal-item');
            revealObserver.observe(el);
        });
    };

    window.clearRevealObserver = function () {
        revealObserver.disconnect();
        intersectQueue = [];
        if (intersectTimeout) {
            clearTimeout(intersectTimeout);
            intersectTimeout = null;
        }
    };

    let lastHovered = null;
    const interactiveSelector = 'a, button, select, input[type="submit"], input[type="button"], .card, .executor-item, .sidebar-link, .copy-btn, .ide-tab, .faq-item, .faq-share, .h-icon, .h-btn, .nav-link, .plugin-card, .btn, .theme-toggle, [role="button"]';

    document.addEventListener('mouseover', e => {
        const item = e.target.closest(interactiveSelector);
        if (item) {
            if (lastHovered !== item) {
                lastHovered = item;
                playHover();
            }
        } else {
            lastHovered = null;
        }
    });

    document.addEventListener('mouseout', e => {
        const item = e.target.closest(interactiveSelector);
        if (item && !item.contains(e.relatedTarget)) {
            lastHovered = null;
        }
    });

    document.addEventListener('click', e => {
        const item = e.target.closest(interactiveSelector);
        if (item) {
            const isDownload = item.hasAttribute('download') || item.classList.contains('dl-all-btn') || item.classList.contains('att-dl') || item.classList.contains('att-dl-link') || item.id === 'download-btn' || item.id === 'ide-download-btn';
            if (isDownload) {
                playSuccess();
            } else {
                playClick();
            }
        }
    });

    document.addEventListener('input', e => {
        const target = e.target;
        if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.isContentEditable) {
            playType();
        }
    });

    window.copyCode = function (btn) {
        const pre = btn.closest('.api-code').querySelector('pre code');
        if (!pre) return;
        const text = pre.innerText;
        playSuccess();
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
        playSuccess();
        navigator.clipboard.writeText(url).then(() => {
            btn.classList.add('copied');
            setTimeout(() => {
                btn.classList.remove('copied');
            }, 2000);
        });
    };

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
