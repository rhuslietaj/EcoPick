// Edge Function "scan": menerima foto dari aplikasi, memanggil Gemini dengan
// kunci rahasia (GEMINI_API_KEY, disimpan sebagai Secret), lalu mengembalikan hasilnya.
// Kunci TIDAK pernah ada di aplikasi.

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });

const PROMPT = `Kamu adalah sistem pengenal sampah daur ulang untuk aplikasi EcoPick di Indonesia.
Lihat foto dan identifikasi sampah daur ulang UTAMA di dalamnya.
Balas HANYA dengan satu objek JSON, tanpa teks lain dan tanpa markdown, dengan kunci:
"terdeteksi": true jika ada sampah yang bisa didaur ulang, selain itu false
"jenis": salah satu dari "plastik","kertas","kaleng","kaca","kardus","lain"
"nama": nama singkat dalam bahasa Indonesia, contoh "Plastik PET (botol)"
"kondisi": "Bersih", "Kotor", atau "Basah"
"berat_kg": perkiraan total berat dalam kilogram sebagai angka desimal (tebakan terbaik dari ukuran objek)
"catatan": satu kalimat saran memilah dalam bahasa Indonesia
Jika tidak ada sampah: terdeteksi false, jenis "lain", nama "Tidak terdeteksi", kondisi "Bersih", berat_kg 0, dan jelaskan singkat di catatan.`;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });

  // 1) Hanya pengguna yang sudah login boleh memakai fungsi ini
  const who = await fetch(`${Deno.env.get('SUPABASE_URL')}/auth/v1/user`, {
    headers: {
      Authorization: req.headers.get('Authorization') ?? '',
      apikey: req.headers.get('apikey') ?? '',
    },
  });
  if (!who.ok) return json({ error: 'Belum login' }, 401);

  // 2) Baca foto
  let body: { image?: string; mime?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Body tidak valid' }, 400);
  }
  if (!body.image) return json({ error: 'Foto kosong' }, 400);
  if (body.image.length > 7_000_000) return json({ error: 'Foto terlalu besar' }, 413);

  // 3) Panggil Gemini memakai kunci rahasia
  const key = Deno.env.get('GEMINI_API_KEY');
  if (!key) return json({ error: 'GEMINI_API_KEY belum diisi di Secrets' }, 500);

const model = 'gemini-3-flash-preview';
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                inline_data: {
                  mime_type: body.mime ?? 'image/jpeg',
                  data: body.image,
                },
              },
              { text: PROMPT },
            ],
          },
        ],
        generationConfig: { temperature: 0.4 },
      }),
    },
  );
if (!res.ok) {
  const detail = await res.text();
  console.error('Gemini gagal:', res.status, detail);
  return json({ error: 'AI gagal', status: res.status, detail }, 502);
}

  const data = await res.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
  return json({ text });
});

