// AI会話応答生成: ユーザー発話とコンテキストから英語の返答を生成
// 入力: { transcript: string, context?: { title?: string, theme?: string, sampleUtterances?: string[] } }
// 出力: { reply: string }

const OPENAI_CHAT_URL = "https://api.openai.com/v1/chat/completions";
const MODEL = "gpt-4o-mini";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function errResponse(code: string, message: string, status: number): Response {
  return new Response(JSON.stringify({ code, message }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status,
  });
}

Deno.serve(async (req) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: { ...corsHeaders, "Content-Type": "text/plain" },
        status: 200,
      });
    }

    if (req.method !== "POST") {
      return errResponse("validation_error", "Method not allowed", 405);
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return errResponse("upstream_error", "OpenAI API key not configured", 502);
    }

    interface ReqBody {
      transcript?: string;
      context?: {
        title?: string;
        theme?: string;
        sampleUtterances?: string[];
      };
    }

    let body: ReqBody;
    try {
      body = (await req.json()) as ReqBody;
    } catch {
      return errResponse("validation_error", "Invalid JSON body", 400);
    }

    const transcript = typeof body.transcript === "string" ? body.transcript.trim() : "";
    if (!transcript) {
      return errResponse("validation_error", "transcript is required", 400);
    }

    const ctx = body.context ?? {};
    const title = typeof ctx.title === "string" ? ctx.title : "";
    const theme = typeof ctx.theme === "string" ? ctx.theme : "";
    const samples = Array.isArray(ctx.sampleUtterances)
      ? ctx.sampleUtterances.filter((s) => typeof s === "string").slice(0, 6)
      : [];

    const contextPart = [title, theme].filter(Boolean).join(" - ");
    const samplePart =
      samples.length > 0
        ? `\nSample conversation:\n${samples.map((s) => `- ${s}`).join("\n")}`
        : "";

    const systemPrompt = `You are an English conversation partner for a Japanese learner practicing spoken English.
Your role: Respond naturally and briefly (1-2 sentences) to keep the conversation flowing.
Rules:
- Reply ONLY in English. Never use Japanese.
- Keep responses short and conversational (10-25 words typical).
- Match the tone and formality of the conversation context.
- Be encouraging and natural, like a friendly conversation partner.
${contextPart ? `\nContext: ${contextPart}` : ""}${samplePart}`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 25000);

    const res = await fetch(OPENAI_CHAT_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          { role: "system", content: systemPrompt },
          {
            role: "user",
            content: `The learner said: "${transcript}"\nRespond in English:`,
          },
        ],
        max_tokens: 80,
        temperature: 0.7,
      }),
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

    const data = (await res.json()) as {
      choices?: Array<{ message?: { content?: string } }>;
    };
    const content =
      data.choices?.[0]?.message?.content?.trim() ?? "I didn't quite catch that. Could you say it again?";

    return new Response(
      JSON.stringify({ reply: content }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (e) {
    const msg = String(e);
    if (msg.includes("abort") || msg.includes("timeout")) {
      return errResponse("timeout", "OpenAI API timeout", 504);
    }
    console.error("conversation_reply error:", msg, e);
    return errResponse("upstream_error", `Internal error: ${msg}`, 502);
  }
});
