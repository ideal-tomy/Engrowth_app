// OpenAI TTS プロキシ: キャッシュ優先 → ミス時のみ OpenAI 合成 → Storage 保存 → Public URL 返却
// API キーはサーバー側シークレット OPENAI_API_KEY を使用

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENAI_SPEECH_URL = "https://api.openai.com/v1/audio/speech";
const MODEL = "tts-1-hd";
const BUCKET = "tts-audio";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface ReqBody {
  text?: string;
  language?: string;
  speakingRate?: number;
  speed?: number; // alias for speakingRate (prefill 等の互換用)
  voice?: string;
  tts_session_id?: string; // クライアントログとの相関用
}

function errResponse(code: string, message: string, status: number): Response {
  return new Response(
    JSON.stringify({ code, message }),
    {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
      status,
    }
  );
}

async function sha256Hex(text: string): Promise<string> {
  const buf = new TextEncoder().encode(text);
  const hash = await crypto.subtle.digest("SHA-256", buf);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/** キャッシュキー用: trim + 改行を \n に統一 + 小文字化（prefill・アプリと完全一致） */
function normalizeTextForCache(text: string): string {
  return text
    .trim()
    .replace(/\r\n|\r/g, "\n")
    .toLowerCase();
}

function cacheKey(
  text: string,
  language: string,
  voice: string,
  speed: number,
  model: string
): string {
  return `${text}|${language}|${voice}|${speed}|${model}`;
}

Deno.serve(async (req) => {
  try {
    return await handleRequest(req);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error("TTS uncaught error:", msg, e);
    return errResponse("upstream_error", `Internal error: ${msg}`, 502);
  }
});

async function handleRequest(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        ...corsHeaders,
        "Content-Type": "text/plain",
      },
      status: 200,
    });
  }

  if (req.method !== "POST") {
    return errResponse("validation_error", "Method not allowed", 405);
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) {
    return errResponse(
      "upstream_error",
      "OpenAI API key not configured",
      502
    );
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !supabaseServiceKey) {
    return errResponse(
      "config_error",
      "Supabase not configured",
      502
    );
  }

  let body: ReqBody;
  try {
    body = (await req.json()) as ReqBody;
  } catch {
    return errResponse("validation_error", "Invalid JSON body", 400);
  }

  const rawText = typeof body.text === "string" ? body.text : "";
  const text = normalizeTextForCache(rawText);
  if (!text || text.length > 4096) {
    return errResponse(
      "validation_error",
      "text must be non-empty and at most 4096 characters",
      400
    );
  }

  const language = typeof body.language === "string" ? body.language : "en-US";
  const rawRateValue = typeof body.speakingRate === "number"
    ? body.speakingRate
    : typeof body.speed === "number"
    ? body.speed
    : 1.0;
  const rawRate = Math.min(4, Math.max(0.25, rawRateValue));
  const speakingRate = Math.round(rawRate * 100) / 100; // 浮動小数点誤差回避
  const voice = typeof body.voice === "string"
    ? body.voice
    : (language.startsWith("ja") ? "alloy" : "nova");

  const key = cacheKey(text, language, voice, speakingRate, MODEL);
  const keyHash = await sha256Hex(key);
  const storagePath = `${keyHash}.mp3`;
  const ttsSessionId = typeof body.tts_session_id === "string" ? body.tts_session_id : undefined;

  const client = createClient(supabaseUrl, supabaseServiceKey);

  const dbQueryStart = Date.now();
  // 1. キャッシュ参照
  const { data: asset } = await client
    .from("tts_assets")
    .select("storage_path, id")
    .eq("cache_key", keyHash)
    .maybeSingle();

  const dbQueryMs = Date.now() - dbQueryStart;

  if (asset?.storage_path) {
    await client
      .from("tts_assets")
      .update({ last_used_at: new Date().toISOString() })
      .eq("id", asset.id);

    // Public URL: asset.storage_path を優先（過去データの不整合を避ける）
    const pathToUse = asset.storage_path;
    const publicUrl = `${supabaseUrl}/storage/v1/object/public/${BUCKET}/${pathToUse}`;

    console.log(
      JSON.stringify({
        cache_hit: true,
        cache_key_hash: keyHash.slice(0, 8),
        voice,
        speed: speakingRate,
        text_length: text.length,
        db_query_ms: dbQueryMs,
        tts_session_id: ttsSessionId,
      })
    );

    return new Response(
      JSON.stringify({
        url: publicUrl,
        cache_hit: true,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
        status: 200,
      }
    );
  }

  // 2. ミス: OpenAI 合成
  const openAiStart = Date.now();
  const openAiBody = {
    model: MODEL,
    input: text,
    voice,
    response_format: "mp3",
    speed: speakingRate,
  };

  let bytes: ArrayBuffer;
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 25000);

    const res = await fetch(OPENAI_SPEECH_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(openAiBody),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      const errText = await res.text();
      return errResponse(
        "upstream_error",
        `OpenAI API error: ${res.status} ${errText}`,
        502
      );
    }

    bytes = await res.arrayBuffer();
  } catch (e) {
    const msg = String(e);
    if (msg.includes("abort") || msg.includes("timeout")) {
      return errResponse("timeout", "OpenAI API timeout", 504);
    }
    return errResponse("upstream_error", msg, 502);
  }
  const openAiMs = Date.now() - openAiStart;

  // 3. Storage 保存
  const { error: uploadErr } = await client.storage
    .from(BUCKET)
    .upload(storagePath, bytes, {
      contentType: "audio/mpeg",
      upsert: true,
    });

  if (uploadErr) {
    console.error("TTS storage upload error:", uploadErr);
    return errResponse(
      "storage_error",
      `Failed to save audio: ${uploadErr.message}`,
      502
    );
  }

  // 4. tts_assets メタ挿入
  await client.from("tts_assets").upsert(
    {
      cache_key: keyHash,
      storage_path: storagePath,
      model: MODEL,
      voice,
      language,
      speed: speakingRate,
      last_used_at: new Date().toISOString(),
    },
    { onConflict: "cache_key" }
  );

  // 5. Public URL を返却（バケット public 化済み前提）
  const publicUrl = `${supabaseUrl}/storage/v1/object/public/${BUCKET}/${storagePath}`;

  console.log(
    JSON.stringify({
      cache_hit: false,
      cache_key_hash: keyHash,
      cache_key_preview: key.slice(0, 80),
      voice,
      speed: speakingRate,
      text_length: text.length,
      db_query_ms: dbQueryMs,
      openai_ms: openAiMs,
      tts_session_id: ttsSessionId,
    })
  );

  return new Response(
    JSON.stringify({
      url: publicUrl,
      cache_hit: false,
    }),
    {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
      status: 200,
    }
  );
}
