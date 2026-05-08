// Naya Bingo DB Proxy v1.0
const SUPABASE_URL = 'https://dmqwpbbojuwblurklecg.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtcXdwYmJvanV3Ymx1cmtsZWNnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyNDU2OTEsImV4cCI6MjA5MzgyMTY5MX0.8Gxb60h6f_BxvaEm4gH5T61bEqqYN0pXqniKgh6_14Q';
const SUPABASE_SERVICE = process.env.SUPABASE_SERVICE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtcXdwYmJvanV3Ymx1cmtsZWNnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3ODI0NTY5MSwiZXhwIjoyMDkzODIxNjkxfQ.AqU8vk2HwZj3UrYHEEPruEj_zubDHhx3HdITaCAUGBY';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') return res.status(200).end();

  try {
    const { action, payload } = req.body || {};
    if (!action) return res.status(400).json({ error: 'Missing action' });

    const headers = {
      'apikey': SUPABASE_ANON,
      'Authorization': `Bearer ${SUPABASE_SERVICE}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation'
    };

    let result = null;

    switch (action) {
      case 'getPlayers': {
        const r = await fetch(`${SUPABASE_URL}/rest/v1/bingo_players?select=*&order=started_at.desc`, { headers });
        result = await r.json();
        break;
      }

      case 'markGiftSent': {
        const { id } = payload;
        await fetch(`${SUPABASE_URL}/rest/v1/bingo_players?id=eq.${id}`, {
          method: 'PATCH',
          headers,
          body: JSON.stringify({ gift_sent: true, gift_sent_at: new Date().toISOString() })
        });
        result = { success: true };
        break;
      }

      case 'logPlayer': {
        const { first_name, last_name, reservation_number, check_in_date, bear_token, region } = payload;
        const normRes = (reservation_number || '').trim().toLowerCase();
        const checkUrl = `${SUPABASE_URL}/rest/v1/bingo_players?select=id&limit=1&reservation_number=eq.${encodeURIComponent(normRes)}`;
        const checkR = await fetch(checkUrl, { headers });
        const existing = await checkR.json();

        let playerId = null;
        if (Array.isArray(existing) && existing.length > 0) {
          playerId = existing[0].id;
          const patchBody = { first_name, last_name, check_in_date, region, started_at: new Date().toISOString() };
          if (bear_token) patchBody.bear_token = bear_token;
          await fetch(`${SUPABASE_URL}/rest/v1/bingo_players?id=eq.${playerId}`, { method: 'PATCH', headers, body: JSON.stringify(patchBody) });
        } else {
          const insertR = await fetch(`${SUPABASE_URL}/rest/v1/bingo_players`, {
            method: 'POST', headers,
            body: JSON.stringify({
              first_name, last_name,
              reservation_number: normRes,
              check_in_date, region,
              started_at: new Date().toISOString(),
              completed_bingo: false,
              activities_completed: 0,
              photos_submitted: 0,
              bear_token: bear_token || null
            })
          });
          const inserted = await insertR.json();
          const row = Array.isArray(inserted) ? inserted[0] : inserted;
          playerId = row ? row.id : null;
        }
        result = { id: playerId };
        break;
      }

      case 'updatePlayerStats': {
        const { reservation_number, activities_completed, photos_submitted, completed_bingo, bear_token } = payload;
        const patchBody = { activities_completed, photos_submitted, completed_bingo };
        if (bear_token) patchBody.bear_token = bear_token;
        const normRes = reservation_number.trim().toLowerCase();
        await fetch(`${SUPABASE_URL}/rest/v1/bingo_players?reservation_number=eq.${encodeURIComponent(normRes)}`, {
          method: 'PATCH', headers, body: JSON.stringify(patchBody)
        });
        result = { success: true };
        break;
      }

      default:
        return res.status(400).json({ error: `Unknown action: ${action}` });
    }

    return res.status(200).json({ data: result, error: null });
  } catch (error) {
    console.error('DB proxy error:', error);
    return res.status(500).json({ data: null, error: error.message });
  }
}
