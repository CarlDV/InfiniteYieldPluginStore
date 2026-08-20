/* ============================================================
   Dialog — lightweight alert/confirm system
   API: Dialog.alert(message, title?)  -> Promise
        Dialog.confirm(message, title?) -> Promise<boolean>
   ============================================================ */

(() => {
    'use strict';

    class DialogUI {
        constructor() {
            this.overlay = null;
            this.modal = null;
            this.titleEl = null;
            this.bodyEl = null;
            this.footerEl = null;

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', () => this.init());
            } else {
                this.init();
            }
        }

        init() {
            if (document.getElementById('custom-dialog-overlay')) return;

            const overlay = document.createElement('div');
            overlay.id = 'custom-dialog-overlay';
            overlay.className = 'overlay hidden';

            overlay.innerHTML = `
                <div class="modal dialog-modal" role="dialog" aria-modal="true" aria-labelledby="dialog-title">
                    <div class="modal-header">
                        <h2 class="modal-title" id="dialog-title"></h2>
                    </div>
                    <div class="modal-body" id="dialog-body"></div>
                    <div class="modal-footer" id="dialog-footer"></div>
                </div>
            `;

            document.body.appendChild(overlay);

            this.overlay = overlay;
            this.modal = overlay.querySelector('.dialog-modal');
            this.titleEl = overlay.querySelector('#dialog-title');
            this.bodyEl = overlay.querySelector('#dialog-body');
            this.footerEl = overlay.querySelector('#dialog-footer');

            overlay.addEventListener('click', e => {
                if (e.target === overlay) this.close();
            });

            document.addEventListener('keydown', e => {
                if (e.key === 'Escape' && !overlay.classList.contains('hidden')) {
                    this.close();
                }
            });
        }

        show(options = {}) {
            if (!this.overlay) this.init();

            this.titleEl.textContent = options.title || '';
            this.bodyEl.innerHTML = `<p>${options.message || ''}</p>`;

            this.footerEl.innerHTML = '';
            const buttons = options.buttons || [];

            return new Promise(resolve => {
                buttons.forEach(btn => {
                    const button = document.createElement('button');
                    button.className = btn.class || 'btn dialog-btn';
                    button.textContent = btn.text;
                    button.addEventListener('click', () => {
                        this.close();
                        resolve(btn.value);
                    });
                    this.footerEl.appendChild(button);
                });

                this.overlay.classList.remove('hidden');
            });
        }

        close() {
            if (!this.overlay || this.overlay.classList.contains('hidden') || this.overlay.classList.contains('closing')) return;
            this.overlay.classList.add('closing');
            setTimeout(() => {
                this.overlay.classList.remove('closing');
                this.overlay.classList.add('hidden');
            }, 220);
        }

        alert(message, title = 'Alert') {
            return this.show({
                title,
                message,
                buttons: [{ text: 'OK', value: true, class: 'btn dialog-btn' }]
            });
        }

        confirm(message, title = 'Confirm') {
            return this.show({
                title,
                message,
                buttons: [
                    { text: 'Cancel', value: false, class: 'btn dialog-btn btn-alt' },
                    { text: 'Confirm', value: true, class: 'btn dialog-btn' }
                ]
            });
        }
    }

    window.Dialog = new DialogUI();
})();