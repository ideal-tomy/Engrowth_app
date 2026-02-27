// OpenAI TTS プロキシ: クライアントからのテキストを受け取り OpenAI Audio API で合成し MP3 を返す
// API キーはサーバー側シークレット OPENAI_API_KEY を使用

const OPENAI_SPEECH_URL = "https://api.openai.com/v1/audio/speech";
const MODEL = "tts-1-hd";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface ReqBody {
  text?: string;
  language?: string;
  speakingRate?: number;
  voice?: string;
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

Deno.serve(async (req) => {
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

  let body: ReqBody;
  try {
    body = (await req.json()) as ReqBody;
  } catch {
    return errResponse("validation_error", "Invalid JSON body", 400);
  }

  const text = typeof body.text === "string" ? body.text.trim() : "";
  if (!text || text.length > 4096) {
    return errResponse(
      "validation_error",
      "text must be non-empty and at most 4096 characters",
      400
    );
  }

  const language = typeof body.language === "string" ? body.language : "en-US";
  const speakingRate = typeof body.speakingRate === "number"
    ? Math.min(4, Math.max(0.25, body.speakingRate))
    : 1.0;
  const voice = typeof body.voice === "string"
    ? body.voice
    : (language.startsWith("ja") ? "alloy" : "nova");

  const openAiBody = {
    model: MODEL,
    input: text,
    voice,
    response_format: "mp3",
    speed: speakingRate,
  };

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

    const bytes = await res.arrayBuffer();
    return new Response(bytes, {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/octet-stream",
        "Content-Length": String(bytes.byteLength),
      },
      status: 200,
    });
  } catch (e) {
    const msg = String(e);
    if (msg.includes("abort") || msg.includes("timeout")) {
      return errResponse("timeout", "OpenAI API timeout", 504);
    }
    return errResponse("upstream_error", msg, 502);
  }
});
