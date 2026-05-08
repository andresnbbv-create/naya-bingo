# Naya Homes Bingo

Interactive vacation bingo for Naya Homes guests in Puerto Vallarta and Nuevo Vallarta.

## Files

```
naya-bingo/
├── index.html     — Guest bingo app
├── admin.html     — Staff dashboard (password protected)
├── vercel.json    — Routing config
├── setup.sql      — Run once in Supabase SQL Editor
├── README.md      — This file
└── api/
    └── db.js      — Server-side database proxy
```

## Setup Steps

### 1. Create Supabase Project
1. Go to supabase.com → "New Project" → name it `naya-bingo`
2. Settings → API → copy your **Project URL**, **anon key**, and **service_role key**

### 2. Run Database SQL
1. Supabase → SQL Editor → New Query
2. Paste all of `setup.sql` → Run
3. Should say "Naya Bingo database setup complete!"

### 3. Replace Placeholders
In `index.html`, `admin.html`, and `api/db.js`, replace:
- `YOUR-NAYA-PROJECT.supabase.co` → your Supabase URL
- `YOUR_NAYA_SUPABASE_ANON_KEY_HERE` → your anon key
- `YOUR_NAYA_SERVICE_ROLE_KEY_HERE` → your service role key (db.js only)

### 4. Push to GitHub
Create a new repo called `naya-bingo`, upload all these files.

### 5. Deploy to Vercel
1. vercel.com → Add New Project → import your GitHub repo
2. Add Environment Variable: `SUPABASE_SERVICE_KEY` = your service role key
3. Deploy

### 6. Custom Domain (optional)
Vercel → Settings → Domains → add `bingo.nayahomes.com`
Add CNAME record in your domain registrar: `bingo` → `cname.vercel-dns.com`

## Adding Activities

In `index.html`, fill in the activity objects:

```javascript
const EG_PV = {
  beach_day: {
    n: "Beach Day at Playa Los Muertos",
    tip: "Go before 10am for the best spot",
    addr: "Playa Los Muertos, Puerto Vallarta",
    maps: "https://maps.google.com/?q=Playa+Los+Muertos+Puerto+Vallarta",
    photo: "https://raw.githubusercontent.com/YOUR-USER/naya-bingo/main/beach.jpg"
  },
  // ... more activities
};
```

Then add them to weekly cards:
```javascript
const WEEKLY_CARDS_PV = [
  // Week 1 — 25 activities
  [EG_PV.beach_day, EG_PV.malecon, ...],
  // Weeks 2-5...
];
```

## Admin Dashboard

URL: `/admin`
Password: `naya-bingo-admin-2026`

## Support

📞 +52 315 182 0301
✉️ farid@nayahomes.co
