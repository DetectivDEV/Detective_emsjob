const screen = document.getElementById('death-screen');
const btnEms = document.getElementById('btn-ems');
const btnRespawn = document.getElementById('btn-respawn');
const respawnHint = document.getElementById('respawn-hint');
const emsCooldown = document.getElementById('ems-cooldown');

const digits = {
    m1: document.getElementById('digit-m1'),
    m2: document.getElementById('digit-m2'),
    s1: document.getElementById('digit-s1'),
    s2: document.getElementById('digit-s2'),
};

function post(name, data = {}) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    });
}

function setTimer(seconds) {
    const total = Math.max(0, Math.floor(seconds));
    const m = Math.floor(total / 60);
    const s = total % 60;
    const mm = String(m).padStart(2, '0');
    const ss = String(s).padStart(2, '0');

    digits.m1.textContent = mm[0];
    digits.m2.textContent = mm[1];
    digits.s1.textContent = ss[0];
    digits.s2.textContent = ss[1];
}

function setRespawnEnabled(enabled, readyText) {
    btnRespawn.disabled = !enabled;
    btnRespawn.classList.toggle('disabled', !enabled);
    if (enabled) {
        respawnHint.textContent = readyText || 'You may respawn now';
        respawnHint.classList.remove('hidden');
    } else {
        respawnHint.classList.remove('hidden');
    }
}

function setEmsEnabled(enabled, cooldownText) {
    btnEms.disabled = !enabled;
    if (cooldownText) {
        emsCooldown.textContent = cooldownText;
        emsCooldown.classList.remove('hidden');
    } else {
        emsCooldown.classList.add('hidden');
    }
}

btnEms.addEventListener('click', () => {
    if (btnEms.disabled) return;
    post('callEms');
});

btnRespawn.addEventListener('click', () => {
    if (btnRespawn.disabled) return;
    post('respawn');
});

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'show':
            if (data.locale) {
                const loc = data.locale;
                if (loc.death_title) document.getElementById('death-title').textContent = loc.death_title;
                if (loc.death_subtitle) document.getElementById('death-subtitle').textContent = loc.death_subtitle;
                if (loc.death_call_ems) document.getElementById('label-ems').textContent = loc.death_call_ems;
                if (loc.death_respawn) document.getElementById('label-respawn').textContent = loc.death_respawn;
                if (loc.death_respawn_wait) respawnHint.textContent = loc.death_respawn_wait;
            }
            setTimer(data.remaining ?? 0);
            setRespawnEnabled(!!data.canRespawn, data.respawnReadyText);
            setEmsEnabled(data.emsEnabled !== false, data.emsCooldown || '');
            screen.classList.remove('hidden');
            break;

        case 'update':
            setTimer(data.remaining ?? 0);
            if (typeof data.canRespawn === 'boolean') setRespawnEnabled(data.canRespawn, data.respawnReadyText);
            if (typeof data.emsEnabled === 'boolean') setEmsEnabled(data.emsEnabled, data.emsCooldown || '');
            break;

        case 'hide':
            screen.classList.add('hidden');
            break;
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') return;
});
