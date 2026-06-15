class DialogUI {
    constructor() {
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.init());
        } else {
            this.init();
        }
    }

    init() {
        if (document.getElementById('custom-dialog-overlay')) return;
        
        this.overlay = document.createElement('div');
        this.overlay.id = 'custom-dialog-overlay';
        this.overlay.className = 'overlay hidden';
        this.overlay.innerHTML = `
            <div class="modal dialog-modal">
                <div class="modal-header">
                    <h2 class="modal-title" id="dialog-title"></h2>
                </div>
                <div class="modal-body" id="dialog-body"></div>
                <div class="modal-footer" id="dialog-footer"></div>
            </div>
        `;
        document.body.appendChild(this.overlay);

        this.modal = this.overlay.querySelector('.dialog-modal');
        this.titleEl = this.overlay.querySelector('#dialog-title');
        this.bodyEl = this.overlay.querySelector('#dialog-body');
        this.footerEl = this.overlay.querySelector('#dialog-footer');
    }

    show(options) {
        if (!this.overlay) this.init();
        return new Promise(resolve => {
            this.titleEl.textContent = options.title || '';
            this.bodyEl.innerHTML = `<p>${options.message}</p>`;
            this.footerEl.innerHTML = '';

            options.buttons.forEach(btn => {
                const b = document.createElement('button');
                b.className = btn.class || 'btn h-btn dialog-btn';
                b.textContent = btn.text;
                b.onclick = () => {
                    this.close();
                    resolve(btn.value);
                };
                this.footerEl.appendChild(b);
            });

            if (options.title && (options.title.toLowerCase().includes('alert') || options.title.toLowerCase().includes('error') || options.title.toLowerCase().includes('failed') || options.message.toLowerCase().includes('failed') || options.message.toLowerCase().includes('invalid') || options.message.toLowerCase().includes('could not') || options.message.toLowerCase().includes('error'))) {
                if (window.playError) window.playError();
            } else {
                if (window.playSuccess) window.playSuccess();
            }

            this.overlay.classList.remove('hidden');
        });
    }

    close() {
        this.overlay.classList.add('closing');
        setTimeout(() => {
            this.overlay.classList.remove('closing');
            this.overlay.classList.add('hidden');
        }, 400); // matches the squish animation duration
    }

    alert(message, title = 'Alert') {
        return this.show({
            title,
            message,
            buttons: [{ text: 'OK', value: true }]
        });
    }

    confirm(message, title = 'Confirm') {
        return this.show({
            title,
            message,
            buttons: [
                { text: 'Cancel', value: false, class: 'btn btn-alt dialog-btn' },
                { text: 'Confirm', value: true, class: 'btn h-btn dialog-btn' }
            ]
        });
    }
}

window.Dialog = new DialogUI();
