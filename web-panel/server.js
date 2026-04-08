const express = require('express');
const cors    = require('cors');
const bcrypt  = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const fs   = require('fs');
const path = require('path');

const app  = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'data', 'users.json');

// ── Middleware ────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ── Data helpers ──────────────────────────────────────────────
if (!fs.existsSync(path.join(__dirname, 'data'))) {
    fs.mkdirSync(path.join(__dirname, 'data'), { recursive: true });
}

function loadUsers() {
    if (!fs.existsSync(DATA_FILE)) return {};
    try { return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8')); }
    catch { return {}; }
}

function saveUsers(users) {
    fs.writeFileSync(DATA_FILE, JSON.stringify(users, null, 2));
}

const DEFAULT_STATE = {
    // Aimbot
    AimEnabled:  false,
    SilentAim:   false,
    AimPart:     "Head",
    AimFOV:      100,
    AimSmooth:   3,
    TeamCheck:   false,
    // Visuals
    BoxESP:      false,
    BoxStyle:    "Full",
    NameESP:     false,
    DistESP:     false,
    HealthBar:   false,
    SkeletonESP: false,
    SkeletonColor: { r: 255, g: 255, b: 255 },
    ProjESP:     false,
    Chams:       false,
    ChamsMat:    "Neon",
    ChamsColor:  { r: 180, g: 100, b: 255 },
    RGBEsp:      false,
    RGBChams:    false,
    RGBSpeed:    3,
    // Local
    WalkSpeed:   16,
    JumpPower:   50,
    NoClip:      false,
    Spinbot:     false,
    SpinSpeed:   50,
    // Misc
    Watermark:   false
};

// ── Auth routes ───────────────────────────────────────────────
app.post('/api/register', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password)
        return res.status(400).json({ error: 'Preencha todos os campos.' });
    if (username.length < 3 || password.length < 6)
        return res.status(400).json({ error: 'Username ≥ 3 chars, senha ≥ 6 chars.' });

    const users = loadUsers();
    if (users[username])
        return res.status(409).json({ error: 'Usuário já existe.' });

    const hash  = await bcrypt.hash(password, 10);
    const token = uuidv4();
    users[username] = { hash, token, state: { ...DEFAULT_STATE }, createdAt: Date.now() };
    saveUsers(users);
    res.json({ token, username });
});

app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    const users = loadUsers();
    if (!users[username])
        return res.status(401).json({ error: 'Credenciais inválidas.' });

    const valid = await bcrypt.compare(password, users[username].hash);
    if (!valid)
        return res.status(401).json({ error: 'Credenciais inválidas.' });

    res.json({ token: users[username].token, username });
});

// ── State routes (used by Roblox & panel) ────────────────────
// Roblox polls this every few seconds
app.get('/api/state/:token', (req, res) => {
    const users = loadUsers();
    const user  = Object.values(users).find(u => u.token === req.params.token);
    if (!user) return res.status(404).json({ error: 'Token inválido.' });
    res.json(user.state);
});

// Panel sends updates here
app.put('/api/state/:token', (req, res) => {
    const users    = loadUsers();
    const username = Object.keys(users).find(k => users[k].token === req.params.token);
    if (!username) return res.status(404).json({ error: 'Token inválido.' });

    users[username].state = { ...users[username].state, ...req.body };
    saveUsers(users);
    res.json({ ok: true, state: users[username].state });
});

// Panel requests own profile info
app.get('/api/me/:token', (req, res) => {
    const users    = loadUsers();
    const username = Object.keys(users).find(k => users[k].token === req.params.token);
    if (!username) return res.status(404).json({ error: 'Token inválido.' });
    res.json({ username, state: users[username].state, token: req.params.token });
});

// Reset state to defaults
app.post('/api/reset/:token', (req, res) => {
    const users    = loadUsers();
    const username = Object.keys(users).find(k => users[k].token === req.params.token);
    if (!username) return res.status(404).json({ error: 'Token inválido.' });
    users[username].state = { ...DEFAULT_STATE };
    saveUsers(users);
    res.json({ ok: true });
});

app.listen(PORT, () => {
    console.log(`\n🛡️  Eternal Hub Panel → http://localhost:${PORT}\n`);
});
